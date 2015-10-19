class AddPhoneEmailToHoldgame < ActiveRecord::Migration
  def change
  		add_column :holdgames, :contact_name, :string
  	  	add_column :holdgames, :contact_phone, :string
  	  	add_column :holdgames, :contact_email, :string
  end
end
