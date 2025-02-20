require 'rails_helper'

RSpec.describe "API V1 Follows", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { { "X-User-Id" => user.id } }

  describe "POST /api/v1/follows" do
    it "creates a follow relationship" do
      expect {
        post "/api/v1/follows", params: { followed_id: other_user.id }, headers: headers
      }.to change(Follow, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    context "when trying to follow self" do
      it "doesn't create a follow and returns error" do
        expect {
          post "/api/v1/follows", params: { followed_id: user.id }, headers: headers
        }.not_to change(Follow, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when already following" do
      before { user.follow(other_user) }

      it "doesn't create duplicate follow" do
        expect {
          post "/api/v1/follows", params: { followed_id: other_user.id }, headers: headers
        }.not_to change(Follow, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /api/v1/follows/:id" do
    context "when following the user" do
      before { user.follow(other_user) }

      it "removes the follow relationship" do
        expect {
          delete "/api/v1/follows/#{other_user.id}", headers: headers
        }.to change(Follow, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when not following the user" do
      it "returns not found" do
        delete "/api/v1/follows/#{other_user.id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /api/v1/follows/following_sleep_records" do
    let(:friend1) { create(:user) }
    let(:friend2) { create(:user) }

    before do
      user.follow(friend1)
      user.follow(friend2)

      # Create sleep records for the past week
      create(:sleep_record, user: friend1,
             clock_in_at: 2.days.ago,
             clock_out_at: 1.day.ago,
             duration_minutes: 480)

      create(:sleep_record, user: friend2,
             clock_in_at: 3.days.ago,
             clock_out_at: 2.days.ago,
             duration_minutes: 540)

      create(:sleep_record, user: friend1,
             clock_in_at: 4.days.ago,
             clock_out_at: 3.days.ago,
             duration_minutes: 420)

      # Create sleep record outside past week
      create(:sleep_record, user: friend2,
             clock_in_at: 10.days.ago,
             clock_out_at: 9.days.ago)

      # Create incomplete sleep record
      create(:sleep_record, user: friend1,
             clock_in_at: 1.day.ago,
             clock_out_at: nil)
    end

    it "returns following users' sleep records from past week ordered by duration" do
      get "/api/v1/follows/following_sleep_records", headers: headers

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body.size).to eq(3)

      # Should be sorted by duration_minutes desc
      expect(body.first["duration_minutes"]).to eq(540)
      expect(body.last["duration_minutes"]).to eq(420)

      # Should include user information
      expect(body.first).to include("user")
      expect(body.first["user"]).to include("id", "name")
    end

    context "when not following anyone" do
      let(:lonely_user) { create(:user) }
      let(:lonely_headers) { { "X-User-Id" => lonely_user.id } }

      it "returns empty array" do
        get "/api/v1/follows/following_sleep_records", headers: lonely_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq([])
      end
    end
  end
end