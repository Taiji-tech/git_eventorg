class RenameTextColumnToProfile < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :text, :profile
  end
end
