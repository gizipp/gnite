class SleepRecordSerializer < ActiveModel::Serializer
  attributes :id, :clock_in_at, :clock_out_at, :duration_minutes, :created_at
end