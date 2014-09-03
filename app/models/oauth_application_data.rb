class OauthApplicationData < ActiveRecord::Base
  belongs_to :application, class_name: "Doorkeeper::Application"

  def self.get(id)
    OauthApplicationData.where('application_id = ?', id).first_or_create! do |data|
      data.application_id = id
    end
  end
end
