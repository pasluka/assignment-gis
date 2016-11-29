require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'webrick/httputils'

class ResortData
  def initialize(name)
    @name = name
    @title = get_title
    @snowFalls = crawl_snowfall_data(2016) + crawl_snowfall_data(2015) + crawl_snowfall_data(2014) + crawl_snowfall_data(2013)
    @ticketPrices = crawl_prices_data
    @elevation = get_elevation
    @location = get_LatLng
    @regions = get_regions
  end

  def name
    @name
  end

  def title
    @title
  end

  def elevation
    @elevation
  end

  def location
    @location
  end

  def regions
    @regions
  end

  def snowFalls
    @snowFalls
  end

  def ticketPrices
    @ticketPrices
  end

  def to_hash
    {:skiResort => title, :urlHelper => name, :latitude => location[0], :longitude => location[1],
     :minElevation => elevation[0], :maxElevation => elevation[1],
     :prices =>
         ticketPrices.map do |price|
           {:type => price.type, :childPrice => price.childPrice, :juniorPrice => price.juniorPrice, :adultPrice => price.adultPrice, :seniorPrice => price.seniorPrice}
         end,
     :snowfalls =>
         snowFalls.map do |snowFall|
           {:date => snowFall.date, :newSnow => snowFall.newSnow, :totalSnow => snowFall.totalSnow, :baseDepth => snowFall.baseDepth}
         end,
     :regions =>
         regions.map do |region |
           {:name => region.name}
         end
    }
  end

  def get_title
    resort_url = ('http://www.onthesnow.co.uk/' + @name + '/ski-resort.html')
    doc = Nokogiri::HTML(open(resort_url))
    doc.at_css('title').text.split(" Ski Resort -")[0]
  end

  def get_elevation
    resort_url = 'http://www.onthesnow.co.uk/' + @name + '/ski-resort.html'
    doc = Nokogiri::HTML(open(resort_url))
    elevation_string = doc.css(".ovv_info")[0].css('tr')[1].css('td').text
    elev = elevation_string.split(' - ')
    min_elev = elev[0].split('m')[0]
    max_elev = elev[1].split('m')[0]
    [min_elev, max_elev]
  end

  def get_regions
    resort_url = 'http://www.onthesnow.co.uk/' + @name + '/ski-resort.html'
    doc = Nokogiri::HTML(open(resort_url))
    regions = []
    doc.css('.rel_regions').css('a').each do |relRegion|
      regions << Region.new(relRegion.text)
    end
    regions
  end



  def get_LatLng
    resort_url = 'http://www.onthesnow.co.uk/' + @name + '/ski-resort.html'
    doc = Nokogiri::HTML(open(resort_url))
    latlng = doc.css('#map_canvas').css('img')[0]['src'].split('shadow:1|')[1].split('&sensor=false')[0]
    values = latlng.split(',')
    lat = values[0]
    lng = values[1]
    [lat, lng]
  end

  def crawl_snowfall_data(year)
    snowfall_url = 'http://www.onthesnow.co.uk/' + @name + "/historical-snowfall.html?&y=#{year}&v=list"
    doc = Nokogiri::HTML(open(snowfall_url))
    all_data = []
    doc.css(".resortList")[0].css('tr').each do |row|
      if row.at_css('td')
        date_data = row.css('td').map(&:text).join(':')
        date_data = date_data.split(':')
        day = date_data[0]
        date_conv = Date.strptime(day,"%d %b %Y")
        new_snow = date_data[1].split(' cm')[0]
        total_snow = date_data[2].split(' cm')[0]
        base_depth = date_data[3].split(' cm')[0]
        all_data << SnowFallData.new(date_conv, new_snow, total_snow, base_depth)
      end
    end
    all_data
  end

  # problem: currency type Euro, Dollar, ... - will be decided in postgres database
  def crawl_prices_data
    tickets_url = 'http://www.onthesnow.co.uk/'+ @name + '/skipass.html'
    doc = Nokogiri::HTML(open(tickets_url))
    all_data = []
    doc.css('.resort_ticket_price')[0].css('tr').each do |row|
      if row.at_css('td')
        price_data = row.css('td').map(&:text).join(':')
        price_data = price_data.split(':')
        ticket_type = price_data[0]
        child_ticket = price_data[1]
        junior_ticket = price_data[2]
        adult_ticket = price_data[3]
        senior_ticket = price_data[4]
        all_data << TicketPrice.new(ticket_type, child_ticket, junior_ticket, adult_ticket, senior_ticket)
      end
    end
    all_data
  end

end

class SnowFallData

  def initialize(date, newSnow, totalSnow, baseDepth)
    @date = date
    @newSnow = newSnow
    @totalSnow = totalSnow
    @baseDepth = baseDepth
  end

  def date
    @date
  end

  def newSnow
    @newSnow
  end

  def totalSnow
    @totalSnow
  end

  def baseDepth
    @baseDepth
  end
end

class TicketPrice
  def initialize(type, childPrice, juniorPrice, adultPrice, seniorPrice)
    @type = type
    @childPrice = childPrice
    @juniorPrice = juniorPrice
    @adultPrice = adultPrice
    @seniorPrice = seniorPrice
  end

  def type
    @type
  end

  def childPrice
    @childPrice
  end

  def juniorPrice
    @juniorPrice
  end

  def adultPrice
    @adultPrice
  end

  def seniorPrice
    @seniorPrice
  end
end

class Region
  def initialize(name)
    @name = name
  end

  def name
    @name
  end
end


class SimpleSkiingCrawler

  def initialize
    @resortsData = []
  end
  def crawl
    countries = ['france','austria','italy','switzerland','andorra','scotland','spain','bulgaria',
    'czech-rep','romania','poland','germany','slovenia','slovakia','norway','sweden','finland']

    all_europe_resorts = []
    countries.each do |country|
      all_europe_resorts += get_country_resorts(country)
    end
    all_resorts_count = all_europe_resorts.length
    puts "All countries crawled successfully, " + all_resorts_count.to_s + " resorts found."
    i = 1
    all_europe_resorts.each do |resort|
      if resort.ascii_only?
        puts "Adding data for " + resort + " resort (" + i.to_s + "/" + all_resorts_count.to_s + ")..."
        add_resort_data(resort)
        puts "Resort data for " + resort + " added successfully."
      end
      i+=1
    end
  end

  def get_country_resorts(country)
    puts "Getting country resorts for: " + country + "..."
    country_resorts_url = "http://www.onthesnow.co.uk/#{country}/ski-resorts.html"
    doc = Nokogiri::HTML(open(country_resorts_url))
    all_data = []
    doc.css('.resScrollCol8')[0].css('tr').each do |row|
      if row.at_css('td') && row.css('.rLeft').at_css('.name')
        resort = row.css('.rLeft').css('.name').css('a')[0]['href'].split /\/ski-resort.html|\/profile.html/
        # identified problem with onthesnowweb - no existing link to resort
        if !resort[0].nil?
          #puts resort[0] + " " + resort[0].length.to_s
          resort = resort[0][1..resort[0].length]
          all_data << resort
        end
      end
    end
    puts "Country resorts for: " + country + " crawled successfully."
    all_data
  end


  def add_resort_data(resort)
    @resortsData << ResortData.new(resort)
  end

  def to_hash
    puts "Started hash conversion of data..."
    @resortsHash = @resortsData.map do |resort|
      resort.to_hash
    end
    puts "Hash conversion successfully finished"
    @resortsHash
  end
end

countries = ['france','austria','italy','switzerland','andorra','scotland','spain','bulgaria',
             'czech-rep','romania','poland','germany','slovenia','slovakia','norway','sweden','finland']
cc = 6
while cc<17
  skicrawler = SimpleSkiingCrawler.new
  countryX = countries[cc];
  country_resorts = skicrawler.get_country_resorts(countryX)
  i = 1
  all_resorts_count = country_resorts.length
  country_resorts.each do |country_resort|
    if country_resort.ascii_only?
      puts "Adding data for " + country_resort + " resort (" + i.to_s + "/" + all_resorts_count.to_s + ")..."
      skicrawler.add_resort_data(country_resort)
      puts "Resort data for " + country_resort + " added successfully."
    end
    i+=1
  end
  fjson = File.open(countryX+'.json','w');
  fjson.write(skicrawler.to_hash.to_json)
  fjson.close
  cc+=1
end

# FOR DATABASE BUILD
# create table resort
# - id
# - urlhelper
# - title
# - way
# - FK: country_id
# create table country
# - id
# - name
# create table mountain
# - id
# - name
# create table snowfall
# - id
# - FK: resort_id
# - new_snow: int
# - total_snowfall: int
# - base_depth: int
# - date: datetime
# create table lift_ticket
# - id
# - FK: resort_id
# - type: text (F.E.: day, halfday, 2-day, 6-day)
# - price_adult: (double) text
# - price_junior: (double) text
# - price_child: (double) text
# - price_senior: (double) text

