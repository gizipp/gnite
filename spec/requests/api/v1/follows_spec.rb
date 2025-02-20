require 'rails_helper'

RSpec.describe "API V1 Follows", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { { "X-User-Id" => user.id } }
  
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