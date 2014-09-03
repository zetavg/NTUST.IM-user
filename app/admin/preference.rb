ActiveAdmin.register_page "Preference" do
  menu priority: 100, label: "系統設定"

  content do

    form :action => admin_preference_update_path, :method => :post do |f|
      f.input :name => 'authenticity_token', :type => :hidden, :value => form_authenticity_token.to_s
      panel "Preference" do
        fieldset do
          ol do

            li do
              label 'LOGO (可以是圖片網址、或是 svg 向量圖)'
              f.textarea :name => "data[app_logo]" do
                Preference.app_logo
              end
            end

            li do
              label '全站公告 (支援 markdown 語法)'
              f.textarea :name => "data[announcement]" do
                Preference.announcement
              end
            end

            li do
              label 'Facebook 專頁網址'
              f.input :name => "data[fb_page]", :type => 'text', :value => Preference.fb_page
            end

          end
        end
      end
      f.input :type => 'submit', :value => '更新'
    end
  end

  page_action :update, :method => :post do
    params['data'].each do |k, v|
      Preference[k] = v
    end
    redirect_to :back, :notice => "設定已更新"
  end
end
