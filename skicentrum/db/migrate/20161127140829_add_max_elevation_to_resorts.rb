class AddMaxElevationToResorts < ActiveRecord::Migration
  def change
    add_column :resorts, :max_elevation, :integer
  end
end
