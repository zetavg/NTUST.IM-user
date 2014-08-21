class Department < ActiveRecord::Base
  belongs_to :college
  has_many :students, class_name: "User", primary_key: "code"

  def self.get_options
    a = {}
    select([:college_id, :code, :name]).each { |d| (a[d.college.name] ||= []) << [d.name, d.code] }
    return a
  end
end
