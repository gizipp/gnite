class AddGeneralPurposeIndexes < ActiveRecord::Migration[7.0]
  def change
    # 1. Follows - also unique index to prevent duplicate follows
    add_index :follows,
              [:follower_id, :followed_id],
              unique: true,
              name: "index_follows_unique"

    # 2. Sleep Records - timestamps for filtering
    add_index :sleep_records, :clock_in_at
    add_index :sleep_records, :clock_out_at
    add_index :sleep_records, :created_at

    # 3. Sleep Records - duration for sorting
    add_index :sleep_records, :duration_minutes

    # 4. Users - name for searching
    add_index :users, :name

    # 5. General timestamps indexes
    add_index :users, :created_at
    add_index :users, :updated_at
    add_index :follows, :created_at

    # 6. General id indexes
    add_index :users, :id
    add_index :follows, :followed_id, if_not_exists: true
    add_index :follows, :follower_id, if_not_exists: true
    add_index :sleep_records, :user_id, if_not_exists: true
  end
end
