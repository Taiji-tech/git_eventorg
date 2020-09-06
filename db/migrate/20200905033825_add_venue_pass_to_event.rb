class AddVenuePassToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :venue_pass, :string
  end
end
