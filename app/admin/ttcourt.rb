ActiveAdmin.register Ttcourt do
  config.sort_order = "zipcode_asc"
  index do
  	column :id
  	column :placename
  	column :lng
  	column :lat
  	column :city
  	column :county
  	column :zipcode
  	column :address
  	column :opentime
  	column :facilities
  	column :playfee
  	column :contactinfo
    column :infosource
    column :infoURL
    column :courtphotos 
    actions
  end
end
