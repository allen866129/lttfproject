class CreateShopcarts < ActiveRecord::Migration
  def change
    create_table :shopcarts do |t|
      t.integer :user_id
      t.text :address
      t.integer :X5L
      t.integer :X4L
      t.integer :X3L
      t.integer :X2L
      t.integer :L
      t.integer :S
      t.integer :XS
      t.text :paymentinfo
      t.boolean :pay_check
      t.boolean :sent_flag
      t.date :sent_date

      t.timestamps
    end
  end
end
