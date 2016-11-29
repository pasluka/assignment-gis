class SkiResort < ActiveRecord::Base

  # find all resorts withing bounds
  def self.all_resorts(params)
    query = <<-SQL
      SELECT *, ST_AsGeoJSON(geometry) as geometry FROM resorts
      WHERE min_elevation >= #{params[:minElev]} AND max_elevation <= #{params[:maxElev]} AND
         ST_WITHIN(geometry::geometry, ST_MakePolygon(
          ST_GeomFromText('LINESTRING(#{params[:minlng]} #{params[:minlat]}, #{params[:minlng]} #{params[:maxlat]}, #{params[:maxlng]} #{params[:maxlat]}, #{params[:maxlng]} #{params[:minlat]}, #{params[:minlng]} #{params[:minlat]})',4326)::geometry))
    SQL
    ActiveRecord::Base.connection.execute query
  end

  # find all resorts from region within bounds
  def self.resorts_in_region(params)
    query = <<-SQL
     SELECT *, ST_AsGeoJSON(r.geometry) as geometry FROM resorts r
      JOIN resort_regions rr ON rr.resort_id = r.id
      WHERE r.min_elevation >= #{params[:minElev]} AND r.max_elevation <= #{params[:maxElev]} AND rr.region_id = #{params[:region]} AND
         ST_WITHIN(r.geometry::geometry, ST_MakePolygon(
          ST_GeomFromText('LINESTRING(#{params[:minlng]} #{params[:minlat]}, #{params[:minlng]} #{params[:maxlat]}, #{params[:maxlng]} #{params[:maxlat]}, #{params[:maxlng]} #{params[:minlat]}, #{params[:minlng]} #{params[:minlat]})',4326)::geometry))
    SQL
    ActiveRecord::Base.connection.execute query
  end

  # find all facilities within bounds nearby resorts
  def self.all_facilities(params)
    distance = params[:distance]
    distance = distance.to_i * 1000
    query = <<-SQL
      SELECT f.*, ST_AsGeoJSON(f.way) as geometry FROM resorts r
      CROSS JOIN #{params[:facility]} f
      WHERE r.min_elevation >= #{params[:minElev]} AND r.max_elevation <= #{params[:maxElev]} AND
         ST_WITHIN(r.geometry::geometry, ST_MakePolygon(
          ST_GeomFromText('LINESTRING(#{params[:minlng]} #{params[:minlat]}, #{params[:minlng]} #{params[:maxlat]}, #{params[:maxlng]} #{params[:maxlat]}, #{params[:maxlng]} #{params[:minlat]}, #{params[:minlng]} #{params[:minlat]})',4326)::geometry))
         AND
        ST_Distance(r.geometry::geography, f.way::geography) <= #{distance}
      ORDER BY ST_Distance(r.geometry::geography, f.way::geography)
      LIMIT 100

    SQL
    ActiveRecord::Base.connection.execute query
  end

  # find all facilities within bounds nearby region resorts
  def self.all_facilities_in_region(params)
    distance = params[:distance]
    distance = distance.to_i * 1000
    query = <<-SQL
      SELECT f.*, ST_AsGeoJSON(f.way) as geometry FROM resorts r
      JOIN resort_regions rr ON rr.resort_id = r.id
      CROSS JOIN #{params[:facility]} f
      WHERE r.min_elevation >= #{params[:minElev]} AND r.max_elevation <= #{params[:maxElev]} AND rr.region_id = #{params[:region]} AND
         ST_WITHIN(r.geometry::geometry, ST_MakePolygon(
          ST_GeomFromText('LINESTRING(#{params[:minlng]} #{params[:minlat]}, #{params[:minlng]} #{params[:maxlat]}, #{params[:maxlng]} #{params[:maxlat]}, #{params[:maxlng]} #{params[:minlat]}, #{params[:minlng]} #{params[:minlat]})',4326)::geometry))
          AND
        ST_Distance(r.geometry::geography, f.way::geography) <= #{distance}
      ORDER BY ST_Distance(r.geometry::geography, f.way::geography)
      LIMIT 100
    SQL
    ActiveRecord::Base.connection.execute query
  end

end