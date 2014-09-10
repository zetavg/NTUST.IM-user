class UserRfidData < ActiveRecord::Base
  validates :sid, uniqueness: true
  validates :encrypted_code, uniqueness: true

  def user
    User.confirmed.where(student_id: self.sid).first
  end
end
