#encoding: UTF-8”
@holdgames=Holdgame.all
@holdgames.each do |holdgame|
  holdgame.gamedays=1 if !holdgame.gamedays || holdgame.gamedays<1
  holdgame.enddate=holdgame.startdate+holdgame.gamedays-1
  holdgame.save
  
end  
  
