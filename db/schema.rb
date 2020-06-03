# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_31_181254) do

  create_table "accounts", force: :cascade do |t|
    t.string "username"
    t.string "prof_pic"
    t.string "category"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "clubs", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "picture"
    t.string "password"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "contracts", force: :cascade do |t|
    t.string "status"
    t.string "title"
    t.text "description"
    t.decimal "price"
    t.integer "market_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["market_id"], name: "index_contracts_on_market_id"
  end

  create_table "markets", force: :cascade do |t|
    t.string "status"
    t.string "title"
    t.text "description"
    t.string "picture"
    t.decimal "price"
    t.decimal "quantity"
    t.string "password"
    t.integer "season_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["season_id"], name: "index_markets_on_season_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.string "goes_to"
    t.string "category"
    t.integer "users_id"
    t.integer "clubs_id"
    t.integer "seasons_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["clubs_id"], name: "index_memberships_on_clubs_id"
    t.index ["seasons_id"], name: "index_memberships_on_seasons_id"
    t.index ["users_id"], name: "index_memberships_on_users_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.string "status"
    t.string "title"
    t.text "description"
    t.string "picture"
    t.string "password"
    t.integer "club_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["club_id"], name: "index_seasons_on_club_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "username"
    t.string "prof_pic"
    t.string "category"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
