#encoding: UTF-8;”
class AddAuthconditioToGamegroup < ActiveRecord::Migration
  def change
  	add_column :gamegroups, :authcondition, :string, default: '參賽次數&認證單位核可符合任一項即可'
  end
end
