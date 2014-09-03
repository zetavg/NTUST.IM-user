ActiveAdmin.register College do
  menu priority: 110, parent: "資料集"

  permit_params :code, :name

  index do
    selectable_column
    id_column
    column :code
    column :name
    actions
  end

end
