class CreateSleepRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :sleep_records do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :clock_in_at
      t.datetime :clock_out_at
      t.integer :duration_minutes

      t.timestamps
    end
  end
end
