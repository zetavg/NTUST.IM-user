ActiveAdmin.register User do

  menu priority: 30

  permit_params :admin, :name, :email, :fbid, :gender, :identity, :student_id, :admission_year, :admission_department_id, :department_id, :mobile, :birthday, :address, :brief

  index do
    selectable_column
    id_column
    column :admin
    column :confirmed_at
    column :name
    column :email
    column :fbid
    column :gender
    column :created_at
    column :current_sign_in_at
    column :last_sign_in_at
    column :current_sign_in_ip
    column :last_sign_in_ip
    column :sign_in_count
    column :updated_at
    column :identity
    column :student_id
    column :admission_year
    column :admission_department_id
    column :department
    column :mobile
    column :birthday
    column :address
    column :brief
    column :unconfirmed_email
    actions
  end

  form do |f|
    f.inputs do
      f.input :admin
      f.input :name
      f.input :email
      f.input :fbid
      f.input :gender
      f.input :identity
      f.input :student_id
      f.input :admission_year
      f.input :admission_department_id
      f.input :department_id
      f.input :mobile
      f.input :birthday
      f.input :address
      f.input :brief
    end
    f.actions
  end
end
