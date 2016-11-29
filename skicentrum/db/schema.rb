# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20161129051633) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "regions", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "regions_resorts", force: :cascade do |t|
    t.integer  "resort_id"
    t.integer  "region_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "regions_resorts", ["region_id"], name: "index_regions_resorts_on_region_id", using: :btree
  add_index "regions_resorts", ["resort_id"], name: "index_regions_resorts_on_resort_id", using: :btree

  create_table "resorts", force: :cascade do |t|
    t.string   "name"
    t.string   "urlhelper"
    t.geometry "geometry",      limit: {:srid=>0, :type=>"geometry"}
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "min_elevation"
    t.integer  "max_elevation"
  end

  create_table "snowfalls", force: :cascade do |t|
    t.date     "date"
    t.integer  "new_snow"
    t.integer  "total_snow"
    t.integer  "base_depth"
    t.integer  "resort_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "snowfalls", ["resort_id"], name: "index_snowfalls_on_resort_id", using: :btree

  create_table "tickets", force: :cascade do |t|
    t.string   "ticket_type"
    t.string   "price_adult"
    t.string   "price_junior"
    t.string   "price_child"
    t.string   "price_senior"
    t.integer  "resort_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "tickets", ["resort_id"], name: "index_tickets_on_resort_id", using: :btree

  add_foreign_key "regions_resorts", "regions"
  add_foreign_key "regions_resorts", "resorts"
  add_foreign_key "snowfalls", "resorts"
  add_foreign_key "tickets", "resorts"
end
