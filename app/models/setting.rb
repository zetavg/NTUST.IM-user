class Setting < Settingslogic

  if File.file?("#{Rails.root.to_s}/config/configuration.yml")
    source "#{Rails.root.to_s}/config/configuration.yml"
  else
    source "#{Rails.root.to_s}/config/configuration.yml.example"
  end

  namespace Rails.env
end
# some subsequent processing actions are written in '/app/controllers/application_controller.rb#get_app_setting'
