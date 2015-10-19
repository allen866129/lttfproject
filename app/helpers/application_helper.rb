# encoding: UTF-8”
module ApplicationHelper
def default_meta_tags
  {
    :site => '桌球愛好者聯盟',
    :title       =>'桌球愛好者聯盟積分系統',
    :description => '桌球愛好者聯盟積分賽系統',
    :og =>
    {
      :title       => '桌球愛好者聯盟積分賽系統',
      :description => '一個非以營利為目的之台灣地區桌球愛好者積分系統',
      :image => 'http://twlttf.org/lttfgroupphoto.jpg',
      :url => 'http://twlttf.org/'
    }

 }
end
  def bootstrap_class_for(flash_type)
    case flash_type
    when :success
      "alert-success" # Green
    when :error
      "alert-error" # Red
    when :alert
      "alert-warning" # Yellow
    when :notice
      "alert-info" # Blue
    end
  end
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

end
