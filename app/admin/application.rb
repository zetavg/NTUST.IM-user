ActiveAdmin.register Application do

  menu priority: 80

  permit_params :url, :name, :icon, :description, :color, :priority, :show_in_navigation, :show_in_menu, :enabled, :login_url, :logout_url

end
