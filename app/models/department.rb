class Department < ActiveRecord::Base
  belongs_to :college
  has_many :students, class_name: "User", primary_key: "code"
end
