json.array! @ski_resorts do |ski_resort|
  json.type "Feature"
  json.geometry JSON.parse ski_resort["geometry"]
  json.properties do
    json.title ski_resort["name"]
    json.id ski_resort["id"]
    json.minElev ski_resort["min_elevation"]
    json.maxElev ski_resort["max_elevation"]
    json.set! "marker-color", "#0000FF"
    json.set! "marker-size", "large"
    json.set! "marker-symbol", "skiing"
  end
end
json.array! @facilities do |facility|
  json.type "Feature"
  json.geometry JSON.parse facility["geometry"]
  json.properties do
    json.title facility["name"]
    json.tourism facility["tourism"]
    json.tags facility["tags"]
    json.set! "marker-color", "#FF0000"
    json.set! "marker-size", "large"
    json.set! "marker-symbol", "building"
  end
end