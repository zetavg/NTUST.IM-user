class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.string :url
      t.string :name
      t.string :icon
      t.text :description
      t.string :color
      t.integer :priority, :null => false, :default => 99999
      t.boolean :show_in_navigation, :null => false, :default => false
      t.boolean :show_in_menu, :null => false, :default => false
      t.boolean :enabled, :null => false, :default => false
      t.string :login_url
      t.string :logout_url

      t.timestamps
    end
  end
end
