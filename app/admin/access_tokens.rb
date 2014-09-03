ActiveAdmin.register Doorkeeper::AccessToken do
  menu priority: 61, label: "Access Token", parent: "應用程式"

  index do
    selectable_column
    id_column
    column :owner do |grant|
      u = User.find_by_id(grant.resource_owner_id)
      auto_link(u)
    end
    column :application
    column :token do |grant|
      div truncate(grant.token)
    end
    column :refresh_token do |grant|
      div truncate(grant.refresh_token)
    end
    column :expires_in
    column :created_at
    column :revoked_at
    column :scopes
    actions
  end
end
