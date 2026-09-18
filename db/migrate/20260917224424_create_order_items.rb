class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items, id: :uuid do |t|
      t.references :order,
        type: :uuid,
        null: false,
        foreign_key: true

      t.references :product,
        type: :uuid,
        null: false,
        foreign_key: true

      t.string :external_id
      t.string :title, null: false
      t.string :sku

      t.integer :quantity,
        null: false,
        default: 1

      t.decimal :unit_price,
        precision: 12,
        scale: 2,
        null: false,
        default: 0

      t.decimal :discount,
        precision: 12,
        scale: 2,
        null: false,
        default: 0

      t.decimal :tax,
        precision: 12,
        scale: 2,
        null: false,
        default: 0

      t.decimal :total,
        precision: 12,
        scale: 2,
        null: false,
        default: 0

      t.string :currency,
        null: false,
        default: "EUR"

      t.timestamps
    end

    add_index :order_items, :external_id
    add_index :order_items, [:order_id, :external_id], unique: true
  end
end
