class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id, null: false
      t.string :title, null: false
      t.text :content
      t.string :image
      t.string :type
      t.string :sender
      t.string :sender_url
      t.integer :sender_application_id
      t.string :icon
      t.string :url
      t.string :event_name
      t.datetime :datetime
      t.string :location
      t.integer :priority, null: false, default: 3
      t.integer :importance, null: false, default: 3
      t.boolean :dismissed, null: false, default: false
      t.boolean :pinned, null: false, default: false

      t.timestamps
    end
  end
end
