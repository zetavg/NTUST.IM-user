ActiveAdmin.register Department do

  menu priority: 40

  permit_params :college, :code, :name

  index do
    selectable_column
    id_column
    column :college
    column :code
    column :name
    column :created_at
    column :updated_at
    actions
  end
end
