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

ActiveRecord::Schema[7.1].define(version: 2026_03_20_112910) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "chats", force: :cascade do |t|
    t.string "title"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_chats_on_user_id"
  end

  create_table "communes", force: :cascade do |t|
    t.string "insee_code"
    t.string "name"
    t.string "department"
    t.string "region"
    t.decimal "avg_price_sqm"
    t.decimal "median_price_sqm"
    t.integer "total_transactions"
    t.integer "transactions_last_year"
    t.decimal "price_evolution_1y"
    t.decimal "price_evolution_3y"
    t.date "last_updated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "avg_rent_sqm"
    t.float "rent_quality"
    t.float "nb_obs_commune"
    t.integer "population"
    t.float "superficie_km2"
    t.integer "densite"
    t.integer "altitude_moyenne"
    t.integer "altitude_minimale"
    t.integer "altitude_maximale"
    t.float "latitude_mairie"
    t.float "longitude_mairie"
    t.float "latitude_centre"
    t.float "longitude_centre"
    t.integer "niveau_equipements_services"
    t.string "url_wikipedia"
    t.string "url_villedereve"
  end

  create_table "favorites", force: :cascade do |t|
    t.text "note"
    t.bigint "chat_id", null: false
    t.bigint "commune_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_favorites_on_chat_id"
    t.index ["commune_id"], name: "index_favorites_on_commune_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.string "role"
    t.bigint "chat_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_messages_on_chat_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "buyer"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chats", "users"
  add_foreign_key "favorites", "chats"
  add_foreign_key "favorites", "communes"
  add_foreign_key "messages", "chats"
end
