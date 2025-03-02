# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_02_23_144633) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "follows", force: :cascade do |t|
    t.bigint "follower_id", null: false
    t.bigint "followed_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_follows_on_created_at"
    t.index ["followed_id"], name: "index_follows_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_follows_unique", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "sleep_records", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "clock_in_at"
    t.datetime "clock_out_at"
    t.integer "duration_minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clock_in_at"], name: "index_sleep_records_on_clock_in_at"
    t.index ["clock_out_at"], name: "index_sleep_records_on_clock_out_at"
    t.index ["created_at"], name: "index_sleep_records_on_created_at"
    t.index ["duration_minutes"], name: "index_sleep_records_on_duration_minutes"
    t.index ["user_id", "clock_in_at", "duration_minutes", "clock_out_at"], name: "index_sleep_records_follows_query", order: { duration_minutes: :desc }, where: "(clock_out_at IS NOT NULL)"
    t.index ["user_id"], name: "index_sleep_records_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["id"], name: "index_users_on_id"
    t.index ["name"], name: "index_users_on_name"
    t.index ["updated_at"], name: "index_users_on_updated_at"
  end

  add_foreign_key "follows", "users", column: "followed_id"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "sleep_records", "users"
end
