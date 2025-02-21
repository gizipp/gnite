require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:sleep_records).dependent(:destroy) }
  it { should have_many(:follows).dependent(:destroy) }
  it { should have_many(:following).through(:follows) }
  it { should have_many(:reverse_follows).dependent(:destroy) }
  it { should have_many(:followers).through(:reverse_follows) }

  it { should validate_presence_of(:name) }

  describe "#follow" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    it "creates a follow relationship" do
      expect { user1.follow(user2) }.to change(Follow, :count).by(1)
    end

    it "does not allow following yourself" do
      expect { user1.follow(user1) }.not_to change(Follow, :count)
    end

    it "does not create duplicate follows" do
      user1.follow(user2)
      
      expect { user1.follow(user2) }.not_to change(Follow, :count)
    end
  end

  describe "#unfollow" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    before { user1.follow(user2) }

    it "removes a follow relationship" do
      expect { user1.unfollow(user2) }.to change(Follow, :count).by(-1)
    end
  end

  describe "#following?" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    it "returns true when following" do
      user1.follow(user2)
      expect(user1.following?(user2)).to be true
    end

    it "returns false when not following" do
      expect(user1.following?(user2)).to be false
    end
  end
end