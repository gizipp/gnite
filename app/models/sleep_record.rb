class SleepRecord < ApplicationRecord
  belongs_to :user

  scope :incomplete, -> { where(clock_out_at: nil) }
  scope :ordered_by_created, -> { order(created_at: :desc) }
end
