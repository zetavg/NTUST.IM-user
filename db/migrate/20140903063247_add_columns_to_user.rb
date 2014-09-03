class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :avatar, :string
    add_column :users, :fblink, :string
    add_column :users, :fbcover, :string
  end
end
