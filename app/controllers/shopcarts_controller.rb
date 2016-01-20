# encoding: UTF-8”
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
class ShopcartsController < InheritedResources::Base
  before_filter :authenticate_user! 
	
  def index
    @shopcarts = Shopcart.page(params[:page]).per(50)
    ＠total_shop_count=Shopcart.all.size
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', '訂購尺寸統計')
    data_table.new_column('number', '件數')
    data_table.add_rows(9)
    data_table.set_cell(0, 0, '5XL'   )
    data_table.set_cell(0, 1, Shopcart.sum(:X5L) )
    data_table.set_cell(1, 0, '4XL'      )
    data_table.set_cell(1, 1, Shopcart.sum(:X4L) )
    data_table.set_cell(2, 0, '3XL'      )
    data_table.set_cell(2, 1, Shopcart.sum(:X3L) )
    data_table.set_cell(3, 0, '2XL'      )
    data_table.set_cell(3, 1, Shopcart.sum(:X2L) )
    data_table.set_cell(4, 0, 'XL'      )
    data_table.set_cell(4, 1, Shopcart.sum(:XL) )
    data_table.set_cell(5, 0, 'L'      )
    data_table.set_cell(5, 1, Shopcart.sum(:L) )
    data_table.set_cell(6, 0, 'M'      )
    data_table.set_cell(6, 1, Shopcart.sum(:M) )
    data_table.set_cell(7, 0, 'S'       )
    data_table.set_cell(7, 1, Shopcart.sum(:S) )
    data_table.set_cell(8, 0, 'XS'       )
    data_table.set_cell(8, 1, Shopcart.sum(:XS) )



  opts   = {  :title => '訂購尺寸統計分布圖', :is3D => true }
  @chart = GoogleVisualr::Interactive::PieChart.new(data_table, opts)

  end	
 
  def new
  	if !current_user.phone 
  		 flash[:warning] = "您的註冊資料並未輸入電話,請先輸入桌盟註冊資料內之電話,否則無法購買！"
  		 redirect_to edit_registration_path(current_user)
  		 return
    end		
    if current_user.email.include? "hinet" 
  		 flash[:warning] = "您註冊的email為hinet之相關信箱,請您更改為非hinet相關信箱,否則無法購買！"
   		 redirect_to edit_registration_path(current_user)
  		 return
    end	
  	@shopcart = current_user.build_shopcart
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @shopcart }
    end  
  end
  def create
  @shopcart =  current_user.build_shopcart(params[:shopcart])
  #@gameholder.user_id=current_user.id
  #@gameholder.name=current_user.username
  if @shopcart.take_or_mail=='郵寄' && @shopcart.address==''
  	flash[:warning] = "取貨方式選擇郵寄者,請務必輸入正確郵寄地址!"
  	render action: "new"
  	return
  end	
  if !@shopcart.user_id
  	@shopcart.user_id=current_user.id
  end	
  respond_to do |format|
      if @shopcart.save
        
        format.html { redirect_to @shopcart, notice: '桌盟球衣訂購成功！' }
        format.json { render json: @shopcart, status: :created, location: @shopcart }
      else
        flash[:notice] = "訂購失敗,請跟管理員連絡辦理!"

        format.html { render action: "new", notice: '建檔資料失敗，請跟管理員連絡辦理!' }
        format.json { render json: @shopcart.errors, status: :unprocessable_entity }
      end
    end
  end
def update
  @shopcart = Shopcart.find(params[:id])
  if @shopcart.take_or_mail=='郵寄' && @shopcart.address==''
  	flash[:warning] = "取貨方式選擇郵寄者,請務必輸入正確郵寄地址!"
  	render action: "edit"
  	return
  end	
  if !@shopcart.user_id
  	@shopcart.user_id=current_user.id
  end	
  respond_to do |format|

    if @shopcart.update_attributes(params[:shopcart])
        
      format.html { redirect_to @shopcart, notice: '桌盟球衣訂單更改成功！' }
      format.json { render json: @shopcart, status: :created, location: @shopcart }
    else
      flash[:notice] = "訂單更改失敗,請跟管理員連絡辦理!"

      format.html { render action: "edit", notice: '訂單更改失敗，請跟管理員連絡辦理!' }
      format.json { render json: @shopcart.errors, status: :unprocessable_entity }
    end
  end
	
end
def manageedit
  @shopcart = Shopcart.find(params[:id])
end
end

