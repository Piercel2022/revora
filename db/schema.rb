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

ActiveRecord::Schema[8.1].define(version: 2026_09_21_222659) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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

  create_table "integrations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "credentials"
    t.string "external_id"
    t.string "kind", null: false
    t.string "name", null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "status", default: "inactive", null: false
    t.uuid "store_id"
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_integrations_on_external_id"
    t.index ["kind"], name: "index_integrations_on_kind"
    t.index ["organization_id", "name"], name: "index_integrations_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_integrations_on_organization_id"
    t.index ["provider"], name: "index_integrations_on_provider"
    t.index ["status"], name: "index_integrations_on_status"
    t.index ["store_id"], name: "index_integrations_on_store_id"
  end

  create_table "opportunities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "customer_id"
    t.datetime "expected_close_at"
    t.string "name", null: false
    t.uuid "organization_id", null: false
    t.string "status", default: "open", null: false
    t.uuid "store_id"
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 12, scale: 2, default: "0.0", null: false
    t.index ["customer_id"], name: "index_opportunities_on_customer_id"
    t.index ["expected_close_at"], name: "index_opportunities_on_expected_close_at"
    t.index ["organization_id", "name"], name: "index_opportunities_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_opportunities_on_organization_id"
    t.index ["status"], name: "index_opportunities_on_status"
    t.index ["store_id"], name: "index_opportunities_on_store_id"
  end

  create_table "order_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency", default: "EUR", null: false
    t.decimal "discount", precision: 12, scale: 2, default: "0.0", null: false
    t.string "external_id"
    t.uuid "order_id", null: false
    t.uuid "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.string "sku"
    t.decimal "tax", precision: 12, scale: 2, default: "0.0", null: false
    t.string "title", null: false
    t.decimal "total", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "unit_price", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_order_items_on_external_id"
    t.index ["order_id", "external_id"], name: "index_order_items_on_order_id_and_external_id", unique: true
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
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

  create_table "segments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.uuid "organization_id", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "name"], name: "index_segments_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_segments_on_organization_id"
    t.index ["status"], name: "index_segments_on_status"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "customers", "stores"
  add_foreign_key "integrations", "organizations"
  add_foreign_key "integrations", "stores"
  add_foreign_key "opportunities", "customers"
  add_foreign_key "opportunities", "organizations"
  add_foreign_key "opportunities", "stores"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "stores"
  add_foreign_key "products", "stores"
  add_foreign_key "segments", "organizations"
  add_foreign_key "stores", "organizations"
  add_foreign_key "users", "organizations"
end
