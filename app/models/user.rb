class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:facebook]
  validates_uniqueness_of :fbid

  def self.from_facebook(auth)
    user = where({:fbid => auth.uid}).first_or_create! do |user|
      user.email = "#{auth.uid}@facebook.com"
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
      user.gender = auth.extra.raw_info.gender
    end
    return user
  end
end
