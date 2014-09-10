class Department < ActiveRecord::Base
  belongs_to :college, primary_key: "code", foreign_key: "college_code"
  has_many :students, class_name: "User", primary_key: "code", foreign_key: "department_code"

  def self.get_options
    a = {}
    select([:college_code, :code, :name]).each { |d| (a[d.college.name] ||= []) << [d.name, d.code] }
    return a
  end
end
