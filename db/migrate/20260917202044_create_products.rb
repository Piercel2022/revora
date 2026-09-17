class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products, id: :uuid do |t|
      t.references :store,
        type: :uuid,
        null: false,
        foreign_key: true

      t.string :external_id, null: false
      t.string :title, null: false
      t.text :description
      t.string :sku
      t.string :product_type
      t.string :status, null: false, default: "active"
      t.decimal :price, precision: 12, scale: 2
      t.string :currency, null: false, default: "EUR"

      t.timestamps
    end

    add_index :products, [:store_id, :external_id], unique: true
    add_index :products, :sku
    add_index :products, :status
  end
end
