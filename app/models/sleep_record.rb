class SleepRecord < ApplicationRecord
  belongs_to :user

  scope :ordered_by_created, -> { order(created_at: :desc) }
end
