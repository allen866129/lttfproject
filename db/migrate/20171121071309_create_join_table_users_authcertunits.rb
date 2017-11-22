class CreateJoinTableUsersAuthcertunits < ActiveRecord::Migration
  def change
  	create_table :certifications do |t|
      t.belongs_to :user, index: true
      t.belongs_to :authcertunit, index: true

      t.timestamps
    end
  end
end
