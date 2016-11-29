class CreateRegionsResorts < ActiveRecord::Migration
  def change
    create_table :regions_resorts do |t|
      t.references :resort, index: true, foreign_key: true
      t.references :region, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
