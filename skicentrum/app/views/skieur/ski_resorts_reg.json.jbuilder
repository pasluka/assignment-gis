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