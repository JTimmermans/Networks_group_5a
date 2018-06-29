from bs4 import BeautifulSoup
import requests
import os
import requests
import re
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy import MetaData
import time

		

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
'''
data = pd.read_excel('PointsforJoris.xlsx', chunk=1)
print(data.head(5))

data['input'] = data[['x2','y2','x1','y1']].apply(lambda x: ','.join(x.fillna('').map(str)), axis=1)
data['input'] = data['input'].str.strip(',')
print(data.head(5))
data.to_excel('joris.xls')


def dijkstra(dataframecolumn):
	start_time =time.time()
	
	string=r'SELECT * FROM combination({})'.format(dataframecolumn)
	con.execute(string)

	elapsed_time = time.time() - start_time
	return elapsed_time

count =13
chunkobject = pd.read_csv('joris.csv',sep=';', chunksize=1)
for chunk in chunkobject:
	

	chunk['dijkstra'] = chunk['input'].apply(dijkstra)
	print(chunk.head(5))
	string1 ='calculate_dijkstra/joris_output_dijkstra_{}.xls'.format(count)
	chunk.to_excel(string1)
	count+=1

#data['dijkstra'] = data.apply[[]]



import glob

all_data=pd.DataFrame()

for f in glob.glob("calculate_dijkstra/joris_output_dijkstra_*.xls"):
	df=pd.read_excel(f)
	all_data=all_data.append(df,ignore_index=True)

print(all_data.head(5))
all_data.to_excel('dijkstra_results.xls')

all_data1=pd.DataFrame()

for f in glob.glob("calculate/joris_output_astar_*.xls"):
	df=pd.read_excel(f)
	all_data1=all_data1.append(df,ignore_index=True)

print(all_data1.head(5))
all_data1.to_excel('astar_results.xls')

df2 =pd.merge(all_data, all_data1, left_on ='x1', right_on='x1')
print(df2)
df2.to_excel('results_combined.xls')
'''

from scipy import stats
from math import sqrt
from scipy.stats import t

data = pd.read_excel('results_combined2.xls')

ind_t_test = stats.ttest_ind(data['astar'], data['dijkstra'])

N1 = 14
N2 = 14
df = (N1 + N2 - 2)
std1 = data['astar'].std()
std2 = data['dijkstra'].std()
std_N1N2 = sqrt( ((N1 - 1)*(std1)**2 + (N2 - 1)*(std2)**2) /df )

diff_mean = data['astar'].mean() - data['dijkstra'].mean()

MoE = t.ppf(0.975, df) * std_N1N2 * sqrt(1/N1 + 1/N2)

print('The results of the indepent t-test are: \n\tt-value = {:4.3f}\n\tp-value = {:4.3f}'.format(ind_t_test[0], ind_t_test[1]))
print('The difference between groups is {:3.1f}, {:3.1f} to {:3.1f} (mean [95% CI])'.format(diff_mean, diff_mean - MoE, diff_mean + MoE))








