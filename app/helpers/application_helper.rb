module ApplicationHelper

  def history_path(i)
    if session[:page_history]
      session[:page_history][i] || root_path
    else
      root_path
    end
  end

  def controller?(*controller)
    controller.include?(params[:controller])
  end

  def action?(*action)
    action.include?(params[:action])
  end

  def app_logo
    if Setting.app_logo.to_s != ''
      if Setting.app_logo.to_s.match(/^</)  # if SVG path
        Setting.app_logo.to_s.html_safe
      else
        image_tag Setting.app_logo
      end
    else
      Setting.app_name
    end
  end

  def apps_navigation
    Application.nav
  end

  def apps_menu
    Application.menu
  end

  def default_authorize_path
    user_omniauth_authorize_path(:facebook)
  end

  def regexp_parse(s)
    s.gsub('$', '').gsub('.+', '').gsub('\.', '.')
  end

  def fb_image_tag(id, size=100)
    image_tag 'https://graph.facebook.com/' + id.to_s + '/picture?width=' + size.to_s + '&height=' + size.to_s
  end

  def options_for_select_to_item_menu(s)
    s.gsub(/option/, 'div').gsub(/value/, 'class="item" data-value').html_safe
  end
end
