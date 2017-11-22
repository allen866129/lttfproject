#encoding: UTF-8;”
class AddAuthcertsToGamegroup < ActiveRecord::Migration
  def change
  	add_column :gamegroups, :minimal_LTTF_games_limited, :string, default: '無限制(0顆星)'
  	add_column :gamegroups, :authcerts, :string 
  	add_column :gamegroups, :need_authcert_flag, :boolean, default:false
  end
end
