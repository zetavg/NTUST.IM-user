class AddCollegeIdToDepartment < ActiveRecord::Migration
  def change
    add_column :departments, :college_id, :integer
  end
end
