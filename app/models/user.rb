class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:facebook]
  validates_uniqueness_of :fbid
  scope :confirmed, -> { where("confirmed_at IS NOT NULL") }

  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner
  belongs_to :department, primary_key: "code"

  def avator(size=100)
    'https://graph.facebook.com/' + fbid.to_s + '/picture?width=' + size.to_s + '&height=' + size.to_s
  end

  def self.from_facebook(auth)
    user = where({:fbid => auth.uid}).first_or_create! do |user|
      user.email = "#{Devise.friendly_token[0,20]}@dev.null"
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
      user.gender = auth.extra.raw_info.gender
    end
    return user
  end

  protected

  def send_confirmation_notification?
    false
  end
end
