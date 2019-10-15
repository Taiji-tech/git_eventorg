class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.datetime  :start
      t.string  :venue
      t.string  :title
      t.text    :content
      t.text    :image
      t.integer :capacity
      t.string  :organizer
      t.text    :participant
      t.timestamps
    end
  end
end
