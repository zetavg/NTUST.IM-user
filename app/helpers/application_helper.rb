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

  def regexp_parse(s)
    s.gsub('$', '').gsub('.+', '').gsub('\.', '.')
  end

  def fb_image_tag(id, size=100)
    image_tag 'https://graph.facebook.com/' + id.to_s + '/picture?width=' + size.to_s + '&height=' + size.to_s
  end

end
