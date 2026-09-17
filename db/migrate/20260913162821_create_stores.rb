
class CreateStores < ActiveRecord::Migration[8.1]
  def change
    create_table :stores, id: :uuid do |t|
      t.references :organization, type: :uuid, null: false, foreign_key: true

      t.string :name, null: false
      t.string :platform, null: false
      t.string :external_id, null: false
      t.string :domain
      t.string :currency, null: false, default: "EUR"
      t.string :timezone, null: false, default: "Europe/Paris"
      t.string :status, null: false, default: "active"
      t.datetime :last_synced_at

      t.timestamps
    end

    add_index :stores, [:organization_id, :external_id], unique: true
    add_index :stores, :platform
    add_index :stores, :status
    add_index :stores, :last_synced_at
  end
end
