class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :clock_in_at, presence: true
  validate :validate_clock_times

  before_save :calculate_duration

  scope :incomplete, -> { where(clock_out_at: nil) }
  scope :complete, -> { where.not(clock_out_at: nil) }
  scope :ordered_by_created, -> { order(created_at: :desc) }
  scope :from_past_week, -> { where('clock_in_at >= ?', 1.week.ago) }

  private

  def validate_clock_times
    if clock_out_at.present? && clock_out_at <= clock_in_at
      errors.add(:clock_out_at, "must be after clock in time")
    end
  end

  def calculate_duration
    if clock_in_at.present? && clock_out_at.present?
      self.duration_minutes = ((clock_out_at - clock_in_at) / 60).to_i
    end
  end
end
