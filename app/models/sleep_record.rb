class SleepRecord < ApplicationRecord
  belongs_to :user

  scope :incomplete, -> { where(clock_out_at: nil) }
  scope :complete, -> { where.not(clock_out_at: nil) }
  scope :ordered_by_created, -> { order(created_at: :desc) }
  scope :from_past_week, -> { where('clock_in_at >= ?', 1.week.ago) }
end
