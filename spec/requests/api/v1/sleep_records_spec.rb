require 'rails_helper'

RSpec.describe "API V1 Sleep Records", type: :request do
  let(:user) { create(:user) }
  let(:headers) { { "X-User-Id" => user.id } }
  
  describe "GET /api/v1/sleep_records" do
    before { create_list(:sleep_record, 25, user: user) }
    
    it "returns sleep records" do
      get "/api/v1/sleep_records", headers: headers
      
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(25)
    end
  end
end
