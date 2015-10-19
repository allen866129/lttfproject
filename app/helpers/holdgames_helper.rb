# encoding: UTF-8”
module HoldgamesHelper
def default_meta_tags
  {
    :site => '桌球愛好者聯盟',
    :title       =>'桌球愛好者聯盟積分系統',
    :description => '桌球愛好者聯盟積分賽系統',
    :og =>
    {
      :title       => '桌球愛好者聯盟積分賽系統',
      :description => '一個非以營利為目的之台灣地區桌球愛好者積分系統',
      :image => 'http://twlttf.org/LTTF_logo.png',
      :url => 'http://twlttf.org/'
    }

 }
end
end