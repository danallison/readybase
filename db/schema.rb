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

ActiveRecord::Schema[7.1].define(version: 2023_11_14_032921) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "ready_databases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "domain", default: "localhost", null: false
    t.string "custom_id"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domain", "custom_id"], name: "index_ready_databases_on_domain_and_custom_id", unique: true
  end

  create_table "ready_resources", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "ready_database_id", null: false
    t.string "resource_type"
    t.string "custom_id"
    t.jsonb "data"
    t.jsonb "belongs_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ready_database_id", "resource_type", "custom_id"], name: "idx_on_ready_database_id_resource_type_custom_id_87e6669e7f", unique: true
    t.index ["ready_database_id", "resource_type"], name: "index_ready_resources_on_ready_database_id_and_resource_type"
    t.index ["ready_database_id"], name: "index_ready_resources_on_ready_database_id"
  end

  add_foreign_key "ready_resources", "ready_databases"
end
