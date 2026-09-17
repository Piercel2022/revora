class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers, id: :uuid do |t|
      t.references :store, type: :uuid, null: false, foreign_key: true
      t.string :external_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :company_name
      t.string :status

      t.timestamps
    end
  end
end