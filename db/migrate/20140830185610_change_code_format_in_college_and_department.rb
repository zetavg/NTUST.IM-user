class ChangeCodeFormatInCollegeAndDepartment < ActiveRecord::Migration
  def up
    change_column :colleges, :code, :string
    change_column :departments, :code, :string
  end

  def down
    change_column :colleges, :code, :integer
    change_column :departments, :code, :integer
  end
end
