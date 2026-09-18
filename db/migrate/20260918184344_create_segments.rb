class CreateSegments < ActiveRecord::Migration[8.1]
  def change
    create_table :segments, id: :uuid do |t|
      t.references :organization,
        type: :uuid,
        null: false,
        foreign_key: true

      t.string :name, null: false
      t.text :description
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :segments,
      [:organization_id, :name],
      unique: true

    add_index :segments, :status
  end
end
