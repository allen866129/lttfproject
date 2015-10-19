class CreateAdvitems < ActiveRecord::Migration
  def change
    create_table :advitems do |t|
      t.string :provider_name
      t.string :provider_tel
      t.string :adv_link
      t.string :adv_photo
      t.date :end_date
      t.integer :creator_id

      t.timestamps
    end
  end
end
