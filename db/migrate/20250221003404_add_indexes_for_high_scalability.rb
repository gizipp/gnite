class AddIndexesForHighScalability < ActiveRecord::Migration[7.0]
  def change
    add_index :sleep_records, :user_id, if_not_exists: true  # For quickly finding a user's records
    add_index :sleep_records, :duration_minutes              # For sorting by sleep duration
    add_index :sleep_records, [:user_id, :created_at]        # Composite index for user's records by creation time
    add_index :sleep_records, [:duration_minutes, :user_id]  # Composite index for sorting by sleep duration users

    add_index :follows, [:follower_id, :followed_id], unique: true # For composite and uniqueness constraint
    add_index :follows, :follower_id, if_not_exists: true          # For finding who a user follows
    add_index :follows, :followed_id, if_not_exists: true          # For finding a user's followers

    # For sorting purpose / analytic / misc
    add_index :users, :created_at
    add_index :users, :updated_at

    # TBD
    # 1. case [:duration_minutes, :user_id, clock_in_at] composite
    # 2. add_index :sleep_records, :clock_in_at # For date range queries
  end
end
