class AddConfirmDataToUser < ActiveRecord::Migration
  def change
    add_column :users, :email_confirm_tries, :integer, :null => false, :default => 0
    add_column :users, :mobile_confirmation_token, :string
    add_column :users, :mobile_confirmation_sent_at, :datetime
    add_column :users, :mobile_confirm_tries, :integer, :null => false, :default => 0
  end
end
