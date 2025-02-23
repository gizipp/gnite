class AddOptimizedIndexForFollowingSleepRecords < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE INDEX index_sleep_records_follows_query 
      ON sleep_records (user_id, clock_in_at, duration_minutes DESC) 
      INCLUDE (clock_out_at) 
      WHERE clock_out_at IS NOT NULL
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX IF EXISTS index_sleep_records_follows_query
    SQL
  end
end
