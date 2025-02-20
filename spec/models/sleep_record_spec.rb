require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  it { should belong_to(:user) }
  it { should validate_presence_of(:clock_in_at) }

  describe "validations" do
    let(:user) { create(:user) }
    let(:sleep_record) { build(:sleep_record, user: user) }

    it "validates clock_out_at is after clock_in_at" do
      sleep_record.clock_in_at = 1.hour.ago
      sleep_record.clock_out_at = 2.hours.ago

      expect(sleep_record).not_to be_valid
      expect(sleep_record.errors[:clock_out_at]).to include("must be after clock in time")
    end
  end

  describe "duration calculation" do
    let(:user) { create(:user) }

    it "calculates duration in minutes" do
      sleep_record = create(:sleep_record,
                           user: user,
                           clock_in_at: 8.hours.ago,
                           clock_out_at: 1.hour.ago)

      expect(sleep_record.duration_minutes).to eq(420) # 7 hours = 420 minutes
    end

    it "does not calculate duration when clock_out_at is missing" do
      sleep_record = create(:sleep_record, :incomplete, user: user)
      expect(sleep_record.duration_minutes).to be_nil
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }

    before do
      create(:sleep_record, user: user, clock_in_at: 10.days.ago, clock_out_at: 9.days.ago)
      create(:sleep_record, user: user, clock_in_at: 5.days.ago, clock_out_at: 4.days.ago)
      create(:sleep_record, user: user, clock_in_at: 1.day.ago, clock_out_at: nil)
    end

    it "filters incomplete records" do
      expect(SleepRecord.incomplete.count).to eq(1)
    end

    it "filters complete records" do
      expect(SleepRecord.complete.count).to eq(2)
    end

    it "filters records from past week" do
      expect(SleepRecord.from_past_week.count).to eq(2)
    end

    it "orders by created_at desc" do
      ordered = SleepRecord.ordered_by_created
      expect(ordered.first.created_at).to be > ordered.last.created_at
    end
  end
end