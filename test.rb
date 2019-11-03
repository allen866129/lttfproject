@aa=Attendant.all
@aa.each do |aa|

 if !aa.groupattendant 
 	puts aa.id
 	puts aa.player_id
   #aa.delete
 end  
end