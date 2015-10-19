# encoding: UTF-8”
module GamesmapsHelper
def default_gamesmap_meta_tags
  {
    :site => '桌球愛好者聯盟積分系統',
    :title       =>'台灣地區桌球比賽及活動地圖',
    :description => '桌球愛好者聯盟積分系統',
    :og =>
    {
      :title       => '台灣地區桌球比賽及活動地圖',
      :description => '歡迎球友透過此地圖資訊查詢及報名參加全台各地桌球運動的各項賽事及活動',
      :image => 'http://twlttf.org/LTTF_logo.png',
      :url => 'http://twlttf.org/lttfproject/gamesmaps'
    }

 }
end
def default_lttfgamesmap_meta_tags
  {
    :site => '桌球愛好者聯盟積分系統',
    :title       =>'桌球愛好者聯盟積分賽地圖',
    :description => '桌球愛好者聯盟積分系統',
    :og =>
    {
      :title       => '桌球愛好者聯盟積分賽地圖',
      :description => '歡迎球友透過此地圖資訊查詢及報名參加桌盟各項賽事。也歡迎各地球友及教練使用桌盟積分系統舉辦比賽!',
      :image => 'http://twlttf.org/LTTF_logo.png',
      :url => 'http://twlttf.org/lttfproject/gamesmaps/lttfgamesindex'
    }

 }
end
end