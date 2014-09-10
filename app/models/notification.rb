class Notification < ActiveRecord::Base
  validates :title, :presence => true
  validates_numericality_of :priority, :in => 0..3
  validates_numericality_of :importance, :in => 0..3

  belongs_to :user

  before_create :set_data

  def set_data
    if self.sender_application_id.to_s != ''
      application = Doorkeeper::Application.includes(:data).where(id: sender_application_id).first
      if application
        self.sender = application.name if self.sender.to_s == ''
        # self.sender_url = application.data.url if self.sender_url.to_s == ''
        # self.url = application.data.url if self.url.to_s == ''
      end
    end
  end
end
