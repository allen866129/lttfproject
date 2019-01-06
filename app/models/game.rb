# encoding: UTF-8;”
class Game < ActiveRecord::Base
  attr_accessible :id, :detailgameinfo, :gamedate, :gamename, :originalfileurl, :players_result, :uploader
  def getplayersummary
    return nil if !self.players_result
    @currentgamesummery= self.players_result.split(/\n/)
    @playerssummery=Array.new

    @currentgamesummery.each do |playersummery|
      @player=Hash.new
      @dummy,@player["id"], @player["name"],@player["bgamescore"],@player["wongames"],@player["losegames"],@player["agamescore"],
                @player["scorechanged"],@player["suggestscore"],@player["adjustscore"],@player["original bscore"]= playersummery.split("_")
      @player["id"]=@player["id"].to_i
      @player["bgamescore"]=@player["bgamescore"].to_i
      @player["wongames"]=@player["wongames"].to_i
      @player["losegames"]=@player["losegames"].to_i
      @player["agamescore"]=@player["agamescore"].to_i
      @player["scorechanged"]=@player["scorechanged"].to_i
      @player["suggestscore"]=@player["suggestscore"].to_i if @player["suggestscore"]!=nil
      @player["adjustscore"]=@player["adjustscore"].to_i if @player["adjustscore"]!=nil
      @player["original bscore"]=@player["original bscore"].to_i if @player["original bscore"]!=nil
      @playerssummery.push(@player)
    end  

    @playerssummery  
  end 
  def self.game_breakdown (game)
    game_records=Array.new
    games_record_A=Array.new
    games_record_B=Array.new
    temparr=game["detailrecords"].split(';')
    for record in temparr
        rr=record.split(":")
        games_record_A.push(rr[0]) 
        games_record_B.push(rr[1]) 
    end  
    gameresult=game["gameresult"].split(':')
    games_record_A.push(gameresult[0]) 
    games_record_B.push(gameresult[1])
    game_records.push(games_record_A)
    game_records.push(games_record_B)
    game_records
  end
  def getdetailgamesrecord

    gamesrecords=Array.new
    if self.detailgameinfo

      detailgamesrecord= self.detailgameinfo.split("]")
      detailgamesrecord.each do |singlegamerecord|
    
      singlegame=singlegamerecord.split("|")
      if singlegame.count==4 #old format
        gamesarray=Hash.new
        gamesarray["group"]=singlegame[0]
        players=singlegame[1].split(":")
        gamesarray["Aplayer"]=players[0]
        gamesarray["Bplayer"]=players[1]
        gamesarray["gameresult"]=singlegame[2]
        dummy,gamesarray["detailrecords"] = singlegame[3].split("[")
        gamesarray["Players_scorechanged"]=nil
        gamesrecords.push(gamesarray)
      else  #new format count==5
          gamesarray=Hash.new
          gamesarray["group"]=singlegame[0]
          players=singlegame[1].split(":")
          gamesarray["Aplayer"]=players[0]
          gamesarray["Bplayer"]=players[1]
          gamesarray["gameresult"]=singlegame[2]
          gamesarray["Aplayer bgamescore"]=singlegame[3].to_i
          gamesarray["Bplayer bgamescore"]=singlegame[4].to_i
          gamesarray["Players_scorechanged"]=singlegame[5].to_i
          dummy,gamesarray["detailrecords"] = singlegame[6].split("[")
          gamesrecords.push(gamesarray)
      end  
    end
  end
    gamesrecords
  end  
  def self.qualified_players_for_prize_games_2018
    @adjkeyword="前置調整"
    @Prize_Gamelist_2018=Game.where("gamename not like ?","%#{ @adjkeyword}%")
          .where(:id =>1130..1417)   
    @qualified_players=Array.new
    @Prize_Gamelist_2018.each do |game|
      puts game

      if game.players_result
         @currentgamesummery= game.players_result.split(/\n/)
         @currentgamesummery.each do |playersummery|
            dummy,player_id, player_name,playe_bgamescore,player_wongames,player_lostgamse,player_agamescore,
                player_scorechanged,player_suggestscore,player_adjustscore,player_originalbscore= playersummery.split("_")
          @tempplayer=Playerprofile.find(player_id.to_i) 
          @qualified_players.push(@tempplayer) if !(@qualified_players.include? @tempplayer)      
         end       
      end
    end 
    return @qualified_players.uniq
  end 
end
