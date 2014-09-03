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
              elsif key =~ /logo$/ || key =~ /icon$/
                value = value[0..50] + '...' if value.length > 50
                li "#{key}: #{value}"
              else
                li "#{key}: #{value}"
              end
            end
          end
        end
      end
      column do
        panel "Recent Signed-In Users" do
          table_for User.where('current_sign_in_at IS NOT NULL').order("current_sign_in_at DESC").limit(10) do
            column("Name") { |user| link_to(user.name, admin_user_path(user)) }
            column("Fbid") { |user| link_to(user.fbid, "https://facebook.com/#{user.fbid}", :target => "_blank") }
            column("SID") { |user| user.student_id }
            column("Current Sign In") { |user| user.current_sign_in_at && distance_of_time_in_words_to_now(user.current_sign_in_at) }
            column("Sign In Count") { |user| user.sign_in_count }
            column("IP") { |user| user.current_sign_in_ip }
            column("Last Sign In Ip") { |user| user.last_sign_in_ip }
          end
        end
        panel "Recent Registered Users" do
          table_for User.order("created_at DESC").limit(10) do
            column("Name") { |user| link_to(user.name, admin_user_path(user)) }
            column("Fbid") { |user| link_to(user.fbid, "https://facebook.com/#{user.fbid}", :target => "_blank") }
            column("SID") { |user| user.student_id }
            column("Created At") { |user| user.created_at }
            column("Confirmed") do |user|
              if !!user.confirmed_at
                status_tag('Yes', :class => 'yes')
              else
                status_tag('No', :class => 'no')
              end
            end
            column("IP") { |user| user.current_sign_in_ip }
          end
        end
      end
    end
  end
end
