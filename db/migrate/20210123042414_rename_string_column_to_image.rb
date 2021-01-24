class RenameStringColumnToImage < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :string, :image
  end
end
