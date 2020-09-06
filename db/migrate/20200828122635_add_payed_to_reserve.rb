class AddPayedToReserve < ActiveRecord::Migration[5.2]
  def change
    add_column :reserves, :payed, :boolean, default: false
  end
end
