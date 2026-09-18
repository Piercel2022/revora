class CreateOpportunities < ActiveRecord::Migration[8.1]
  def change
    create_table :opportunities, id: :uuid do |t|
      t.references :organization,
        type: :uuid,
        null: false,
        foreign_key: true

      t.references :store,
        type: :uuid,
        foreign_key: true

      t.references :customer,
        type: :uuid,
        foreign_key: true

      t.string :name, null: false
      t.string :status, null: false, default: "open"
      t.decimal :value, precision: 12, scale: 2, null: false, default: 0
      t.datetime :expected_close_at

      t.timestamps
    end

    add_index :opportunities,
      [:organization_id, :name],
      unique: true

    add_index :opportunities, :status
    add_index :opportunities, :expected_close_at
  end
end
