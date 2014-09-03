class SiteNavigationMigration < ActiveRecord::Migration
  def self.up
    remove_column :applications, :login_url
    remove_column :applications, :logout_url
    rename_table :applications, :site_navigations
    add_column :site_navigations, :cross_domin, :boolean
  end

 def self.down
    remove_column :site_navigations, :cross_domin
    rename_table :site_navigations, :applications
    add_column :applications, :login_url, :string
    add_column :applications, :logout_url, :string
 end
end
