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


end
