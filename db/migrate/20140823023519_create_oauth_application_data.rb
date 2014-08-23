class CreateOauthApplicationData < ActiveRecord::Migration
  def change
    create_table :oauth_application_data do |t|
      t.integer :application_id
      t.integer :sms_quota, :null => false, :default => 0

      t.timestamps
    end
  end
end
