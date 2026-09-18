class CreateIntegrations < ActiveRecord::Migration[8.1]
  def change
    create_table :integrations, id: :uuid do |t|
      t.references :organization,
        type: :uuid,
        null: false,
        foreign_key: true

      t.references :store,
        type: :uuid,
        foreign_key: true

      t.string :provider, null: false
      t.string :kind, null: false
      t.string :name, null: false
      t.string :status, null: false, default: "inactive"
      t.string :external_id
      t.jsonb :credentials

      t.timestamps
    end

    add_index :integrations,
      [:organization_id, :name],
      unique: true

    add_index :integrations, :provider
    add_index :integrations, :kind
    add_index :integrations, :status
    add_index :integrations, :external_id
  end
end
