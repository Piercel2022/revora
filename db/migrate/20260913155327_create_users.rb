
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.references :organization, type: :uuid, null: false, foreign_key: true

      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :role, null: false, default: "member"
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :users, [:organization_id, :email], unique: true
    add_index :users, :role
    add_index :users, :active
  end
end