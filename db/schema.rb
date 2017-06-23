# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170622180408) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attachinary_files", force: :cascade do |t|
    t.string   "attachinariable_type"
    t.integer  "attachinariable_id"
    t.string   "scope"
    t.string   "public_id"
    t.string   "version"
    t.integer  "width"
    t.integer  "height"
    t.string   "format"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["attachinariable_type", "attachinariable_id", "scope"], name: "by_scoped_parent", using: :btree
  end

  create_table "bills", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "reservation_id"
    t.datetime "date_time"
    t.integer  "status"
    t.string   "transaction_id"
    t.float    "amount"
    t.string   "one_time_nonce"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["reservation_id"], name: "index_bills_on_reservation_id", using: :btree
    t.index ["user_id"], name: "index_bills_on_user_id", using: :btree
  end

  create_table "clubs", force: :cascade do |t|
    t.string   "name"
    t.integer  "capacity"
    t.text     "description"
    t.string   "location"
    t.integer  "club_owner_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.float    "latitude"
    t.float    "longitude"
    t.index ["club_owner_id"], name: "index_clubs_on_club_owner_id", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.text     "information"
    t.datetime "datetime"
    t.integer  "reservation_id"
    t.integer  "user_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["reservation_id"], name: "index_comments_on_reservation_id", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "partygoers", force: :cascade do |t|
    t.integer  "partygoer_id"
    t.integer  "reservation_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["partygoer_id"], name: "index_partygoers_on_partygoer_id", using: :btree
    t.index ["reservation_id"], name: "index_partygoers_on_reservation_id", using: :btree
  end

  create_table "ratings", force: :cascade do |t|
    t.text     "information"
    t.integer  "score"
    t.integer  "club_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["club_id"], name: "index_ratings_on_club_id", using: :btree
    t.index ["user_id"], name: "index_ratings_on_user_id", using: :btree
  end

  create_table "res_tables", force: :cascade do |t|
    t.integer  "reservation_id"
    t.integer  "table_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["reservation_id"], name: "index_res_tables_on_reservation_id", using: :btree
    t.index ["table_id"], name: "index_res_tables_on_table_id", using: :btree
  end

  create_table "reservations", force: :cascade do |t|
    t.integer  "capacity"
    t.date     "date"
    t.integer  "reservation_owner_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "token"
    t.boolean  "kaparo_paid"
    t.index ["reservation_owner_id"], name: "index_reservations_on_reservation_owner_id", using: :btree
    t.index ["token"], name: "index_reservations_on_token", unique: true, using: :btree
  end

  create_table "tables", force: :cascade do |t|
    t.integer  "capacity"
    t.integer  "club_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.boolean  "kaparo_required"
    t.integer  "kaparo_amount"
    t.index ["club_id"], name: "index_tables_on_club_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "full_name"
    t.string   "provider"
    t.string   "uid"
    t.string   "facebook_picture_url"
    t.string   "token"
    t.datetime "token_expiry"
    t.string   "phone_number"
    t.string   "braintree_id"
    t.index ["braintree_id"], name: "index_users_on_braintree_id", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "bills", "reservations"
  add_foreign_key "bills", "users"
  add_foreign_key "clubs", "users", column: "club_owner_id"
  add_foreign_key "comments", "reservations"
  add_foreign_key "comments", "users"
  add_foreign_key "partygoers", "reservations"
  add_foreign_key "partygoers", "users", column: "partygoer_id"
  add_foreign_key "ratings", "clubs"
  add_foreign_key "ratings", "users"
  add_foreign_key "res_tables", "reservations"
  add_foreign_key "res_tables", "tables"
  add_foreign_key "reservations", "users", column: "reservation_owner_id"
  add_foreign_key "tables", "clubs"
end
