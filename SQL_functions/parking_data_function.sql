DROP FUNCTION IF EXISTS load_parking();
CREATE OR REPLACE FUNCTION load_parking(integer) 
RETURNS integer
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



	url = 'http://opd.it-t.nl/Data/parkingdata/v1/amsterdam/dynamic/'
	baseurl = re.sub(r'(?<=(\.nl/|\.com)).*', r'', url)
	ext = 'json'

	def listFD(url, ext=''):
	    page = requests.get(url).text
	    soup = BeautifulSoup(page, 'html.parser')
	    return [baseurl + "/" + node.get('href') for node in soup.find_all('a') if node.get('href').endswith(ext)]

	df = pd.DataFrame(columns=['name', 'vacancies', 'status'])


	for file in listFD(url, ext):

	    r = requests.get(file)
	    park_data = r.json()
	  

	    parkeer_algemeen = park_data["parkingFacilityDynamicInformation"]
	  

	    name = parkeer_algemeen['name']
	  

	    parking_status = parkeer_algemeen['facilityActualStatus']
	 

	    vacancies = parking_status['vacantSpaces']
	    print(vacancies)

	    if vacancies <= 5:
	        x = True
	    else:
	        x = False


	    status = x
	   

	    df.loc[file] = name, vacancies, status

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


	con, meta = connect_postgres_db()
	df.to_sql('parking_data', con, schema=None, if_exists='replace')
	con.execute('DROP VIEW IF EXISTS parking_open')
	con.execute('DROP VIEW IF EXISTS parking_closed')
	con.execute('DROP TABLE IF EXISTS parking')
	con.execute('CREATE TABLE parking AS SELECT parking_data.name, parking_data.vacancies, parking_data.status, parking_locations.geom FROM parking_data INNER JOIN parking_locations ON parking_data.name = parking_locations.name')
	con.execute("CREATE VIEW parking_open AS SELECT * FROM parking WHERE parking.status = 't'")
	con.execute("CREATE VIEW parking_closed AS SELECT * FROM parking WHERE parking.status = 'f'")

	nonsense = 1
	return nonsense

$$ LANGUAGE 'plpython3u';

