class CreateAuthcertunits < ActiveRecord::Migration
  def change
    create_table :authcertunits do |t|
      t.string :unitname
      t.string :address
      t.string :tel
      t.integer :majorcontact_id
      t.string :unitlogo

      t.timestamps
    end
  end
end
