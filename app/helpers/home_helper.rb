# encoding: UTF-8”
module HomeHelper
def default_home_meta_tags
  {
    :site => '桌球愛好者聯盟',
    :title       =>'桌球愛好者聯盟首頁',
    :description => '桌球愛好者聯盟首頁',
    :og =>
    {
      :title       => '桌球愛好者聯盟',
      :description => '一個非以營利為目的之台灣地區桌球愛好者聯盟網站',
      :image => 'http://twlttf.org/LTTF_logo.png',
      :url => 'http://twlttf.org/'
    }

 }
end
end
