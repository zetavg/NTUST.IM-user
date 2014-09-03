class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:facebook]
  validates_uniqueness_of :fbid
  validates :name, :gender, :presence => true
  scope :confirmed, -> { where("confirmed_at IS NOT NULL") }

  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner
  belongs_to :department, primary_key: "code"
  belongs_to :admission_department, class_name: "Department", primary_key: "code"

  def avatar(size=100)
    'https://graph.facebook.com/' + fbid.to_s + '/picture?width=' + size.to_s + '&height=' + size.to_s
  end

  def admission_college_name
    admission_department && admission_department.college && admission_department.college.name
  end

  def admission_department_name
    admission_department && admission_department.name
  end

  def college_name
    department && department.college && department.college.name
  end

  def department_name
    department && department.name
  end

  def self.from_facebook(auth)
    user = where({:fbid => auth.uid}).first_or_create! do |user|
      user.email = "#{Devise.friendly_token[0,20]}@dev.null"
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
      user.gender = auth.extra.raw_info.gender
      get_info_connection = HTTParty.get("https://graph.facebook.com/me?access_token=#{auth.credentials.token}&locale=#{I18n.locale}")
      name = JSON.parse(get_info_connection.parsed_response)['name']
      user.name = name if name
    end
    user.fbtoken = auth.credentials.token
    get_info_connection = HTTParty.get("https://graph.facebook.com/me?fields=id,name,link,picture.height(500).width(500),cover,devices&access_token=#{auth.credentials.token}&locale=#{I18n.locale}")
    info = JSON.parse(get_info_connection.parsed_response)
    user.fblink = info['link']
    user.fbcover = info['cover']['source']
    user.avatar = info['picture']['data']['url']
    user.save
    return user
  end

  def api_get_data(scopes=[], admin=false)
    userdata = {}
    userdata['id'] = self.id
    userdata['uid'] = self.id
    userdata['email'] = self.email
    userdata['name'] = self.name
    userdata['gender'] = self.gender
    if self.mobile?
      userdata['mobile_verified'] = true
    else
      userdata['mobile_verified'] = false
    end
    if scopes.include?('school') || admin
      userdata['student_id'] = self.student_id
      userdata['identity'] = self.identity
      userdata['admission_year'] = self.admission_year
      userdata['admission_department_code'] = self.admission_department_id
      userdata['department_code'] = self.department_id
      userdata['college'] = self.department && self.department.college && self.department.college.name
      userdata['admission_department'] = self.admission_department && self.admission_department.name
      userdata['department'] = self.department && self.department.name
    end
    if scopes.include?('facebook') || admin
      userdata['fbid'] = self.fbid
      userdata['fbcover'] = self.fbcover
    end
    if scopes.include?('profile') || admin
      userdata['brief'] = self.brief
    end
    if admin
      userdata = userdata.merge(self.attributes)
    end
    userdata
  end

  def api_send_sms(message, application_id, scopes=[], admin=false)
    if scopes.include?('sms') || admin  # 有發送權
      if OauthApplicationData.get(application_id).sms_quota > 0  # 發送額度內
        if self.mobile? && self.mobile.to_s != ''  # 可被接收
          data = OauthApplicationData.get(application_id)
          data.sms_quota -= 1
          data.save
          nexmo = Nexmo::Client.new(key: Setting.nexmo_key, secret: Setting.nexmo_secret)
          begin
            nexmo.send_message(from: Setting.site_name, to: self.mobile.tr('^0-9', ''), type: "unicode", text: message)
          rescue
            return {:error => {:message => "Send error", :code => 503}, :status => 503}
          end
        else
          return {:error => {:message => "User has no mobile number", :code => 404}, :status => 404}
        end
      else
        return {:error => {:message => "Too many requests", :code => 429}, :status => 429}
      end
    else
      return {:error => {:message => "Not authorized", :code => 401}, :status => 401}
    end
    return {:success => {:message => "Ok", :code => 200}, :status => 200}
  end

  protected

  def send_confirmation_notification?
    false
  end
end
