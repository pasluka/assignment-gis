class CreateSnowfalls < ActiveRecord::Migration
  def change
    create_table :snowfalls do |t|
      t.date :date
      t.integer :new_snow
      t.integer :total_snow
      t.integer :base_depth
      t.references :resort, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
