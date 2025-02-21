require 'rails_helper'

RSpec.describe "API V1 Sleep Records", type: :request do
  let(:user) { create(:user) }
  let(:headers) { { "X-User-Id" => user.id } }

  describe "GET /api/v1/sleep_records" do
    before { create_list(:sleep_record, 25, user: user) }

    it "returns sleep records" do
      get "/api/v1/sleep_records", headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(20)
    end

    it "paginates properly" do
      get "/api/v1/sleep_records", params: { page: 2 }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(5)
    end
  end

  describe "POST /api/v1/sleep_records/clock_in" do
    context "when there's no active sleep record" do
      it "creates a new sleep record" do
        expect {
          post "/api/v1/sleep_records/clock_in", headers: headers
        }.to change(SleepRecord, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to be_an(Array)
      end

      it "returns all sleep records ordered by created time" do
        create_list(:sleep_record, 3, user: user, clock_in_at: 1.day.ago, clock_out_at: 1.day.ago + 8.hour)

        post "/api/v1/sleep_records/clock_in", headers: headers

        body = JSON.parse(response.body)
        expect(body.size).to eq(4)
        expect(Time.parse(body.first["created_at"])).to be > Time.parse(body.last["created_at"])
      end
    end

    context "when there's an active sleep record" do
      before { create(:sleep_record, user: user, clock_out_at: nil) }

      it "returns an error" do
      expect {
          post "/api/v1/sleep_records/clock_in", headers: headers
        }.not_to change(SleepRecord, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to include("already have an active sleep session")
      end
    end
  end

  describe "PATCH /api/v1/sleep_records/:id/clock_out" do
    let!(:sleep_record) { create(:sleep_record, user: user, clock_out_at: nil) }

    it "updates the clock_out_at time" do
      patch "/api/v1/sleep_records/#{sleep_record.id}/clock_out", headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["clock_out_at"]).not_to be_nil
      expect(sleep_record.reload.duration_minutes).not_to be_nil
    end

    context "when sleep record is already clocked out" do
      before { sleep_record.update(clock_out_at: 1.hour.ago) }

      it "returns an error" do
        patch "/api/v1/sleep_records/#{sleep_record.id}/clock_out", headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to include("already clocked out")
      end
    end

    context "when sleep record doesn't belong to user" do
      let(:other_user) { create(:user) }
      let(:other_sleep_record) { create(:sleep_record, user: other_user) }

      it "returns not found" do
        patch "/api/v1/sleep_records/#{other_sleep_record.id}/clock_out", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
