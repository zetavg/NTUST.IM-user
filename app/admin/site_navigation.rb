ActiveAdmin.register SiteNavigation do
  menu priority: 80, label: "網站選單"

  permit_params :url, :name, :icon, :description, :color, :priority, :show_in_navigation, :show_in_menu, :enabled, :cross_domin

end
