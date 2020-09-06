class CreateTenants < ActiveRecord::Migration[5.2]
  def change
    create_table :tenants do |t|
      t.integer :user_id
      t.string :tenant_id

      t.timestamps
    end
  end
end
