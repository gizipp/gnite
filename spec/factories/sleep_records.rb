FactoryBot.define do
  factory :sleep_record do
    user
    clock_in_at { Faker::Time.backward(days: 1, period: :evening) }
    clock_out_at { Faker::Time.forward(days: 1, period: :morning) }
    duration_minutes { rand(30..480) } # Random duration between 30 and 480 minutes (0.5 hours to 8 hours)
  end
end
