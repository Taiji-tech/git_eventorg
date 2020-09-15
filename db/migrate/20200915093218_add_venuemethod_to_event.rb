class AddVenuemethodToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :venue_method, :string
  end
end
