# encoding: UTF-8”
class Shopcart < ActiveRecord::Base
  attr_accessible :L, :S, :XXS,:M, :XL, :X2L, :X3L, :X4L, :X5L, :XS, :address, :pay_check, :paymentinfo, :sent_date, :sent_flag, :user_id
  attr_accessible :take_or_mail
  belongs_to :user
  default_scope order('user_id')
  def totalcarts
    
    @total_num=self.X5L+self.X4L+self.X3L+self.XL+self.X2L+self.L+self.M+
                  self.S+self.XS+self.XXS
    
    @total_num  	
  end
  def totalbilling
  	@totalbilling=self.totalcarts * 550 
    if self.take_or_mail=='郵寄'
    	@totalbilling+=80
    end   
  	@totalbilling
  end
  def self.totalcarts
  	@totalshopcarts=0
    @totalshopcarts=self.sum(:X5L)+self.sum(:X4L)+self.sum(:X3L)+self.sum(:X2L)+self.sum(:L)+self.sum(:M)
    self.sum(:S)+self.sum(:XS)
    #shopcarts=self.all
  	#shopcarts.each do |shopcart|
  	#@totalshopcarts+=shopcart.totalcarts 
    #end		
    @totalshopcarts
  end
  def self.totalbilling
  	@totalbilling=0
    shopcarts=self.all
  	shopcarts.each do |shopcart|
  	@totalbilling+=shopcart.totalbilling
    end	
    @totalbilling
  end 	

 
end
