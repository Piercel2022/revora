class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders, id: :uuid do |t|
      t.references :store,
        type: :uuid,
        null: false,
        foreign_key: true

      t.references :customer,
        type: :uuid,
        foreign_key: true

      t.string :external_id, null: false
      t.string :order_number, null: false
      t.string :status, null: false, default: "pending"
      t.string :currency, null: false, default: "EUR"

      t.decimal :subtotal, precision: 12, scale: 2, null: false, default: 0
      t.decimal :tax, precision: 12, scale: 2, null: false, default: 0
      t.decimal :shipping, precision: 12, scale: 2, null: false, default: 0
      t.decimal :discount, precision: 12, scale: 2, null: false, default: 0
      t.decimal :total, precision: 12, scale: 2, null: false, default: 0

      t.datetime :ordered_at

      t.timestamps
    end

    add_index :orders, [:store_id, :external_id], unique: true
    add_index :orders, [:store_id, :order_number], unique: true
    add_index :orders, :status
    add_index :orders, :ordered_at
  end
end