class OauthApplicationData < ActiveRecord::Base
  def self.get(id)
    OauthApplicationData.where('application_id = ?', id).first_or_create! do |data|
      data.application_id = id
    end
  end
end
