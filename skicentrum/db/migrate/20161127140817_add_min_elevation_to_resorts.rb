class AddMinElevationToResorts < ActiveRecord::Migration
  def change
    add_column :resorts, :min_elevation, :integer
  end
end
