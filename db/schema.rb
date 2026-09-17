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

ActiveRecord::Schema[8.1].define(version: 2026_09_17_212928) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "customers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "company_name"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "external_id"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "status"
    t.uuid "store_id", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_customers_on_store_id"
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency", default: "EUR", null: false
    t.uuid "customer_id"
    t.decimal "discount", precision: 12, scale: 2, default: "0.0", null: false
    t.string "external_id", null: false
    t.string "order_number", null: false
    t.datetime "ordered_at"
    t.decimal "shipping", precision: 12, scale: 2, default: "0.0", null: false
    t.string "status", default: "pending", null: false
    t.uuid "store_id", null: false
    t.decimal "subtotal", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "tax", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["ordered_at"], name: "index_orders_on_ordered_at"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["store_id", "external_id"], name: "index_orders_on_store_id_and_external_id", unique: true
    t.index ["store_id", "order_number"], name: "index_orders_on_store_id_and_order_number", unique: true
    t.index ["store_id"], name: "index_orders_on_store_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
    t.index ["status"], name: "index_organizations_on_status"
  end

  create_table "products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency", default: "EUR", null: false
    t.text "description"
    t.string "external_id", null: false
    t.decimal "price", precision: 12, scale: 2
    t.string "product_type"
    t.string "sku"
    t.string "status", default: "active", null: false
    t.uuid "store_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["sku"], name: "index_products_on_sku"
    t.index ["status"], name: "index_products_on_status"
    t.index ["store_id", "external_id"], name: "index_products_on_store_id_and_external_id", unique: true
    t.index ["store_id"], name: "index_products_on_store_id"
  end

  create_table "stores", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency", default: "EUR", null: false
    t.string "domain"
    t.string "external_id", null: false
    t.datetime "last_synced_at"
    t.string "name", null: false
    t.uuid "organization_id", null: false
    t.string "platform", null: false
    t.string "status", default: "active", null: false
    t.string "timezone", default: "Europe/Paris", null: false
    t.datetime "updated_at", null: false
    t.index ["last_synced_at"], name: "index_stores_on_last_synced_at"
    t.index ["organization_id", "external_id"], name: "index_stores_on_organization_id_and_external_id", unique: true
    t.index ["organization_id"], name: "index_stores_on_organization_id"
    t.index ["platform"], name: "index_stores_on_platform"
    t.index ["status"], name: "index_stores_on_status"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.uuid "organization_id", null: false
    t.string "password_digest", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_users_on_active"
    t.index ["organization_id", "email"], name: "index_users_on_organization_id_and_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "customers", "stores"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "stores"
  add_foreign_key "products", "stores"
  add_foreign_key "stores", "organizations"
  add_foreign_key "users", "organizations"
end
