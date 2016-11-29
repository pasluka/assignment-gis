require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'

namespace :skieur do
  def import_resorts_data(json_file)
    json = File.read(json_file)
    resorts = JSON.parse(json)
    resorts.each do |resortdata|
      # 1. create resort
      sql = "INSERT INTO resorts (name, urlhelper, geometry, min_elevation, max_elevation, created_at, updated_at)
            VALUES ('#{(resortdata["skiResort"]).sub("'","''")}', '#{resortdata["urlHelper"]}', ST_SetSRID(ST_MakePoint(#{resortdata["longitude"]},#{resortdata["latitude"]}), 4326),
                    #{resortdata["minElevation"]}, #{resortdata["maxElevation"]}, '#{Time.now}', '#{Time.now}' )"
      ActiveRecord::Base.connection.execute(sql)
      id = Resort.order(:id).last.id
      # 2. create snowFalls
      resortdata["snowfalls"].each do |snowfalldata|
        snowfall = Snowfall.new
        snowfall.date = snowfalldata["date"]
        snowfall.new_snow = snowfalldata["newSnow"]
        snowfall.total_snow = snowfalldata["totalSnow"]
        snowfall.base_depth = snowfalldata["baseDepth"]
        snowfall.resort_id = id
        snowfall.save
      end
      # 3. create prices
      resortdata["prices"].each do |pricedata|
        ticket = Ticket.new
        ticket.ticket_type = pricedata["type"]
        ticket.price_child = pricedata["childPrice"]
        ticket.price_junior = pricedata["juniorPrice"]
        ticket.price_adult = pricedata["adultPrice"]
        ticket.price_senior = pricedata["seniorPrice"]
        ticket.resort_id = id
        ticket.save
      end
      # 4. regions create
      resortdata["regions"].each do |regiondata|
        region = Region.find_or_create_by(:name => regiondata["name"])
        # create M:N table row
        RegionsResort.new(:resort_id => id, :region_id => region.id).save
      end

    end

  end

  task :import_resorts, [:resorts_json] => :environment do |t, args|
    import_resorts_data(args.resorts_json)
  end
end