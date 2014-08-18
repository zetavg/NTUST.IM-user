ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

    # div class: "blank_slate_container", id: "dashboard_default_message" do
    #   span class: "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end

    columns do
      column do
        panel "System Info" do
          div Rails::Info.to_s.gsub(/\n/, '<br>').html_safe
          hr
          ul do
            Setting.each do |key, value|
              if key =~ /key$/ || key =~ /secret/ || key =~ /pepper$/
                li "#{key}: #{value[0..5] + value.gsub(/./, '*')}"
              else
                li "#{key}: #{value}"
              end
            end
          end
        end
      end
      column do
        panel "Recent Register Users" do
          table_for User.order("created_at DESC").limit(10) do
            column("Name") { |user| link_to(user.name, admin_user_path(user)) }
            column("Fbid") { |user| link_to(user.fbid, "https://facebook.com/#{user.fbid}", :target => "_blank") }
            column("Email") { |user| user.email }
            column("Created At") { |user| user.created_at }
            column("Updated At") { |user| user.updated_at }
            column("IP") { |user| user.current_sign_in_ip }
          end
        end
        panel "Recent Login Users" do
          table_for User.order("current_sign_in_at DESC").limit(10) do
            column("Name") { |user| link_to(user.name, admin_user_path(user)) }
            column("Fbid") { |user| link_to(user.fbid, "https://facebook.com/#{user.fbid}", :target => "_blank") }
            column("Email") { |user| user.email }
            column("Current Sign In At") { |user| user.current_sign_in_at }
            column("Sign In Count") { |user| user.sign_in_count }
            column("IP") { |user| user.current_sign_in_ip }
            column("Last Sign In Ip") { |user| user.last_sign_in_ip }
          end
        end
      end
    end
  end
end
