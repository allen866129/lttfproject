class CreateWebpageviews < ActiveRecord::Migration
  def change
    create_table :webpageviews do |t|
      t.integer :ttcourts_views , :limit => 8
      t.timestamps
    end
  end
end
