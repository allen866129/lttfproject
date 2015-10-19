class CreateCourtphotos < ActiveRecord::Migration
  def change
    create_table :courtphotos do |t|
      t.string :ttcourt_id
      t.string :photo

      t.timestamps
    end
  end
end
