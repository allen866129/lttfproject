A=Attendant.all
A.each do |ga|

if ga.groupattendant== nil
  puts(ga.id)
  Attendant.destroy(ga.id)
end

end