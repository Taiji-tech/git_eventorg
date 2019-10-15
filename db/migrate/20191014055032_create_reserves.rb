class CreateReserves < ActiveRecord::Migration[5.2]
  def change
    create_table :reserves do |t|
      t.integer :event_id
      t.string :nickname
      t.string :email
      t.timestamps
    end
  end
end
