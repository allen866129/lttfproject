# encoding: UTF-8”
module TtcourtsHelper
def default_ttourts_meta_tags
  {
  	:site => '桌球愛好者聯盟',
    :title       => '台灣打桌球地圖',
    :description => '找尋台灣打桌球場地的好幫手',
    :og =>
    {
      :title       => '台灣打桌球地圖',
      :description => '找尋台灣打桌球場地的好幫手--本地圖是由桌球愛好者聯盟所提供，如需引用請註明出處!',
      :image => 'http://twlttf.org/LTTF_logo.png',
      :url => 'http://twlttf.org/lttfproject/ttcourts'
    }

 }
end
end
