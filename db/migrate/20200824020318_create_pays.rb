class CreatePays < ActiveRecord::Migration[5.2]
  def change
    create_table :pays do |t|
      t.integer :user_id
      t.integer :host_id
      t.integer :price
      t.integer :card_id

      t.timestamps
    end
  end
end
