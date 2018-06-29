DROP FUNCTION IF EXISTS combination();
CREATE OR REPLACE FUNCTION combination(IN xcoord1 double precision, ycoord1 double precision, xcoord2 double precision, ycoord2 double precision) 
RETURNS table(like parking_open2)
AS
$$
	from sys import path
	path.append( 'C:\Python27\ArcGISx6410.5\Lib\site-packages' )

	from bs4 import BeautifulSoup
	import requests
	import os
	import requests
	import re
	import pandas as pd
	from sqlalchemy import create_engine
	from sqlalchemy import MetaData

	#xcoord1=5.796220
	#ycoord1=52.963647
	#xcoord2=4.805900
	#ycoord2=52.376368
		

	def connect_postgres_db(db = 'osm', user = 'postgres', host = 'localhost', port = '5432'):
	    '''Returns a connection and a metadata object'''
		    
	    #ask the user for a password and stores it in 'password'
	    password = 'wachtwoord1'
	    url = 'postgresql://{}:{}@{}:{}/{}'
	    url = url.format(user, password, host, port, db)
	    # The return value of create_engine() is our connection object
	    con = create_engine(url, client_encoding='utf8')

	    # We then bind the connection to MetaData()
	    meta = MetaData(bind=con, reflect=True)

	    print(type(con))

	    return con, meta #returning con keeps you connected to the database, using con.execute('sql_syntax_here') excecutes and sql command.
	    print(xcoord1)
		
	con, meta =connect_postgres_db()

	#update parking
	update = con.execute('SELECT * FROM load_parking(1)').fetchone()
	print(update)
	con.execute('DROP TABLE IF EXISTS route_part1')
	con.execute('DROP TABLE IF EXISTS route_part2')

	#starting_point
	con.execute('commit')
	string_coord1 = r"SELECT source::integer FROM osm_nl_2po_4pgr ORDER BY geom_way <#> ST_GeometryFromText('POINT({} {})',4326) LIMIT 1".format(xcoord1, ycoord1)
	start = con.execute(string_coord1).fetchone()
	start1=start[0]
	print(start1)

	#destination
	con.execute('commit')
	string_coord2 = r"SELECT source::integer FROM osm_nl_2po_4pgr ORDER BY geom_way <#> ST_GeometryFromText('POINT({} {})',4326) LIMIT 1".format(xcoord2, ycoord2)
	destination = con.execute(string_coord2).fetchone()
	destination1=destination[0]
	print(destination1)


	#parking_segment
	string_park_segment = r"SELECT parking_open.name FROM parking_open ORDER BY geom <#> ST_GeometryFromText('POINT({} {})',4326) LIMIT 1".format(xcoord2, ycoord2)
	park_segment = con.execute(string_park_segment).fetchone()
	park_name=park_segment[0]
	print(park_name)


	#parking source
	string_parking_coord = r"SELECT source::integer FROM osm_nl_2po_4pgr, parking_open WHERE parking_open.name = '{}' ORDER BY osm_nl_2po_4pgr.geom_way <#> parking_open.geom LIMIT 1".format(park_name)
	parking = con.execute(string_parking_coord).fetchone()
	parking1=parking[0]
	print(parking1)

	#parking target
	string_parking_coord2 = r"SELECT target:integer FROM osm_nl_2po_4pgr, parking_open WHERE parking_open.name = '{}'ORDER BY osm_nl_2po_4pgr.geom_way <#> parking_open.geom LIMIT 1".format(park_name)
	parking2 = con.execute(string_parking_coord).fetchone()
	parking2=parking2[0]
	print(parking2)



	#route part 1
	string_route = r"CREATE TABLE route_part1 AS SELECT a.*, b.geom_way FROM pgr_dijkstra('SELECT id as id, source::integer, target::integer, cost::double precision AS cost, reverse_cost::double precision AS reverse_cost FROM osm_nl_2po_4pgr',{},{},false,false)AS a LEFT JOIN osm_nl_2po_4pgr as b ON (id2 = id) ORDER BY seq".format(start1, parking1)
	con.execute(string_route)

	#route part 2
	string_route = r"CREATE TABLE route_part2 AS SELECT a.*, b.geom_way FROM pgr_dijkstra('SELECT id as id, source::integer, target::integer, km::double precision AS cost, reverse_cost::double precision AS reverse_cost FROM osm_nl_2po_4pgr',{},{},false,false)AS a LEFT JOIN osm_nl_2po_4pgr as b ON (id2 = id) ORDER BY seq".format(parking2, destination1)
	con.execute(string_route)


	

	rv = con.execute("SELECT * FROM parking_open").fetchall()
	#park_name=park_segment[0]
	#d = rv.nrows()
	return rv

$$ LANGUAGE 'plpython3u';

