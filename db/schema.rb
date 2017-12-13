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

ActiveRecord::Schema.define(version: 20171213012208) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_object_associations", force: :cascade do |t|
    t.integer  "app_id"
    t.integer  "object_id"
    t.string   "association_name"
    t.string   "associated_type"
    t.integer  "associated_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["app_id", "associated_type", "associated_id"], name: "index_object_associations_on_app_id_and_associated_columns", using: :btree
    t.index ["app_id", "object_id"], name: "index_app_object_associations_on_app_id_and_object_id", using: :btree
  end

  create_table "app_objects", force: :cascade do |t|
    t.integer  "app_id"
    t.string   "type"
    t.jsonb    "belongs_to", default: {}
    t.jsonb    "data",       default: {}
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["app_id", "type"], name: "index_app_objects_on_app_id_and_type", using: :btree
    t.index ["app_id"], name: "index_app_objects_on_app_id", using: :btree
  end

  create_table "apps", force: :cascade do |t|
    t.string   "name"
    t.string   "public_id"
    t.integer  "owner_id"
    t.jsonb    "config",      default: {}
    t.jsonb    "public_data", default: {}
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["public_id"], name: "index_apps_on_public_id", unique: true, using: :btree
  end

  create_table "sessions", force: :cascade do |t|
    t.integer  "app_id"
    t.integer  "user_id"
    t.string   "token"
    t.string   "user_agent"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id", "token"], name: "index_sessions_on_app_id_and_token", unique: true, using: :btree
  end

  create_table "user_associations", force: :cascade do |t|
    t.integer  "app_id"
    t.integer  "user_id"
    t.string   "association_name"
    t.string   "associated_type"
    t.integer  "associated_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["app_id", "associated_type", "associated_id"], name: "index_user_associations_on_app_id_and_associated_columns", using: :btree
    t.index ["app_id", "user_id"], name: "index_user_associations_on_app_id_and_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.integer  "app_id"
    t.string   "email"
    t.string   "username"
    t.string   "password_digest"
    t.string   "token"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.jsonb    "belongs_to",             default: {}
    t.jsonb    "private_data",           default: {}
    t.jsonb    "public_data",            default: {}
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["app_id", "email"], name: "index_users_on_app_id_and_email", unique: true, using: :btree
    t.index ["app_id", "reset_password_token"], name: "index_users_on_app_id_and_reset_password_token", unique: true, using: :btree
    t.index ["app_id", "token"], name: "index_users_on_app_id_and_token", unique: true, using: :btree
    t.index ["app_id", "username"], name: "index_users_on_app_id_and_username", unique: true, using: :btree
  end

end
