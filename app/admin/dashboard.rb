# encoding: UTF-8”
ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span I18n.t("active_admin.dashboard_welcome.welcome")
        small I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end


    # Here is an example of a simple dashboard with columns and panels.
    #
      columns do
        column do
          panel "Recent Users" do
            table_for User.order(:id).limit(50) do
              column("編號")   {|user| status_tag(user.id)                                    } 
              column("姓名")   {|user| link_to(user.username, admin_user_path(user))                                    } 
              column("email")  {|user| status_tag(user.email)                                    } 
              column("FB帳號")   {|user| status_tag(user.fbaccount)                                    } 
            end
          end
        end
    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
      end
  end
end
