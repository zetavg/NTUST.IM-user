class UserRfidData < ActiveRecord::Base

  def user
    User.confirmed.where(student_id: self.sid).first
  end
end
