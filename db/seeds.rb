# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Only run in development environment
return unless Rails.env.development?

puts "Starting seed for development environment..."

# Data seed for load test purpose
# Configuration for seed size
TOTAL_USERS = 1000
FOLLOWS_PER_USER = 50  # Each user follows 50 other users
SLEEP_RECORDS_PER_USER = 100  # Each user has 100 sleep records
DAYS_OF_HISTORY = 30  # Generate data for last 30 days

module SeedHelpers
  def self.random_time_between(start_time, end_time)
    Time.at((end_time.to_f - start_time.to_f) * rand + start_time.to_f)
  end

  def self.generate_sleep_record(user_id, date)
    # Sleep time between 8PM to 12AM
    clock_in = random_time_between(
      date.end_of_day - 4.hours,  # 8 PM
      date.end_of_day             # 12 AM
    )
    
    # Wake time between 5AM to 9AM next day
    clock_out = random_time_between(
      (date + 1.day).beginning_of_day + 5.hours,  # 5 AM
      (date + 1.day).beginning_of_day + 9.hours   # 9 AM
    )
    
    {
      user_id: user_id,
      clock_in_at: clock_in,
      clock_out_at: clock_out,
      duration_minutes: ((clock_out - clock_in) / 60).to_i,
      created_at: clock_in,
      updated_at: clock_out
    }
  end
end

ActiveRecord::Base.transaction do
  # Clean existing data
  puts "Cleaning existing data..."
  SleepRecord.delete_all
  Follow.delete_all
  User.delete_all

  # Reset PostgreSQL sequences
  ActiveRecord::Base.connection.execute("ALTER SEQUENCE users_id_seq RESTART WITH 1")
  ActiveRecord::Base.connection.execute("ALTER SEQUENCE sleep_records_id_seq RESTART WITH 1")
  ActiveRecord::Base.connection.execute("ALTER SEQUENCE follows_id_seq RESTART WITH 1")  
  
  # Create users in batches
  puts "Creating #{TOTAL_USERS} users..."
  users = []
  (1..TOTAL_USERS).each_slice(100) do |batch|
    user_batch = batch.map do |i|
      { name: "User #{i}", created_at: Time.current, updated_at: Time.current }
    end
    users.concat(User.insert_all!(user_batch).to_a)
  end
  
  # Create follows in batches
  puts "Creating follows relationships..."
  follows_data = []
  User.find_each do |user|
    # Select random users to follow (excluding self)
    users_to_follow = User.where.not(id: user.id).order("RANDOM()").limit(FOLLOWS_PER_USER)
    
    users_to_follow.each do |followed|
      follows_data << {
        follower_id: user.id,
        followed_id: followed.id,
        created_at: Time.current,
        updated_at: Time.current
      }
    end
    
    # Insert in batches of 1000
    if follows_data.size >= 1000
      Follow.insert_all!(follows_data)
      follows_data = []
    end
  end
  Follow.insert_all!(follows_data) if follows_data.any?
  
  # Create sleep records
  puts "Creating sleep records for the last #{DAYS_OF_HISTORY} days..."
  User.find_each.with_index do |user, index|
    sleep_records = []
    
    (1..SLEEP_RECORDS_PER_USER).each do |_|
      # Random date within the last DAYS_OF_HISTORY days
      random_date = rand(DAYS_OF_HISTORY).days.ago.to_date
      sleep_records << SeedHelpers.generate_sleep_record(user.id, random_date)
      
      # Insert in batches of 1000
      if sleep_records.size >= 1000
        SleepRecord.insert_all!(sleep_records)
        sleep_records = []
      end
    end
    SleepRecord.insert_all!(sleep_records) if sleep_records.any?
    
    # Progress indicator
    if (index + 1) % 100 == 0
      puts "Created sleep records for #{index + 1} users..."
    end
  end
end

# Print summary
puts "\nSeed completed!"
puts "Generated:"
puts "- #{User.count} users"
puts "- #{Follow.count} follow relationships"
puts "- #{SleepRecord.count} sleep records"