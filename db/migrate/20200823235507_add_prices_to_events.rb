class AddPricesToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :price, :integer
    add_column :events, :imgs, :string
    add_column :events, :end, :boolean
  end
end
