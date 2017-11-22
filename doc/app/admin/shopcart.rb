ActiveAdmin.register Shopcart do
  config.sort_order = "user_id_asc"
  index do
  	column :user_id
  	column :X5L
  	column :X4L
  	column :X3L
  	column :X2L
  	column :XL
  	column :L
  	column :M
  	column :S
  	column :XS
  	column :take_or_mail
  	column :address
    column :paymentinfo
    column :pay_check
    column :sent_flag 
    column :sent_date
    column :id
    actions
  end
end
