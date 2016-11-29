CREATE MATERIALIZED VIEW ski_schools AS
	SELECT name, tags, way FROM planet_osm_point
	WHERE amenity = 'ski_school';

CREATE MATERIALIZED VIEW ski_rentals AS
	SELECT name, tags, way FROM planet_osm_point
	WHERE amenity = 'ski_rental' OR tags -> 'rental' = 'ski';

CREATE MATERIALIZED VIEW accomodation AS
	SELECT name, tourism, tags, way FROM planet_osm_point
	WHERE tourism IN ('hotel', 'guest_house', 'alpine_hut', 'chalet', 'apartement', 'hostel', 'motel')
	UNION
	SELECT name, tourism, tags, way FROM planet_osm_polygon
	WHERE tourism IN ('hotel', 'guest_house', 'alpine_hut', 'chalet', 'apartement', 'hostel', 'motel');

CREATE INDEX ON accomodation USING GIST (way);

CREATE INDEX ON ski_schools USING GIST(way);

CREATE  INDEX ON ski_rentals USING GIST(way);

CREATE INDEX ON resorts USING GIST (geometry);

