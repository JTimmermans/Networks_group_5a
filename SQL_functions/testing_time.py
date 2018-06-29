from bs4 import BeautifulSoup
import requests
import os
import requests
import re
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy import MetaData

		

def connect_postgres_db(db = 'osm', user = 'postgres', host = 'localhost', port = '5432'):
    '''Returns a connection and a metadata object'''
		    
    #ask the user for a password and stores it in 'password'
    password = 'wachtwoord1'
    url = 'postgresql://{}:{}@{}:{}/{}'
    url = url.format(user, password, host, port, db)
    # The return value of create_engine() is our connection object
    con = create_engine(url, client_encoding='utf8')

    # We then bind the connection to MetaData()

    print(type(con))

    return con #returning con keeps you connected to the database, using con.execute('sql_syntax_here') excecutes and sql command.

		
con=connect_postgres_db()
con.execute('commit')

data = pd.read_excel('PointsforJoris.xlsx')
print(data.head(5))
