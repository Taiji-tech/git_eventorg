class AddStartdateToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :start_date, :datetime
    add_column :events, :start_time, :time
    
    remove_column :events, :start, :datetime
  end
end
