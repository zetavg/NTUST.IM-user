json.array!(@notifications) do |notification|
  json.extract! notification, :id, :title, :content, :url, :type, :sender, :sender_url, :icon, :url, :datetime, :location, :priority, :importance
  json.created_at notification.created_at.to_i
end
