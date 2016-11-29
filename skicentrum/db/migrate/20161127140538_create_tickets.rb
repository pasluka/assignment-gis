class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.string :ticket_type
      t.string :price_adult
      t.string :price_junior
      t.string :price_child
      t.string :price_senior
      t.references :resort, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
