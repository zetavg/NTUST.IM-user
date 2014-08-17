module ApplicationHelper
  def fb_image_tag(id, size=100)
    image_tag 'https://graph.facebook.com/' + id.to_s + '/picture?width=' + size.to_s + '&height=' + size.to_s
  end
end
