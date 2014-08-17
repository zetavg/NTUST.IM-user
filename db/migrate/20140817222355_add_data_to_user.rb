class AddDataToUser < ActiveRecord::Migration
  def change
    add_column :users, :student_id, :string
    add_column :users, :identity, :string
    add_column :users, :admission_year, :integer
    add_column :users, :admission_department_id, :integer
    add_column :users, :department_id, :integer
    add_column :users, :mobile, :string
    add_column :users, :unconfirmed_mobile, :string
    add_column :users, :birthday, :date
    add_column :users, :address, :string
    add_column :users, :brief, :text
  end
end
