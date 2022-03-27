# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
# =============================================================================
# Load Libraries and Packages
# =============================================================================
import os
from datetime import datetime
import pandas as pd
from pandas import read_csv
import sqlite3
from sqlite3 import Error
import numpy as np
import csv
import re

# =============================================================================
# Initialize some static variable and read in DataFrame
# =============================================================================
filename = 'raw/vehicles.csv'
data = read_csv(filename)
head = data.head(50)
tail = data.tail(50)

# id,url,region,region_url,price,year,manufacturer,model,condition,cylinders,
# fuel,odometer,title_status,transmission,VIN,drive,size,type,paint_color,
# image_url,description,county,state,lat,long,posting_date


# =============================================================================
# EDA
# =============================================================================
def data_eda(df):
    eda_df = {}
    eda_df['null_sum'] = df.isnull().sum()
    eda_df['null_pct'] = df.isnull().mean()
    eda_df['dtypes'] = df.dtypes
    eda_df['count'] = df.count()

    return pd.DataFrame(eda_df)


eda = data_eda(data)
# =============================================================================
# Create function to format region column
# =============================================================================


def format_region(region):
    """
    this function will convert region column into consistent format

    Parameters
    ----------
    region : string
        region of csv data.

    Returns
    -------
    city | city-city | city-region | city-city-region

    """
    if '/' in region:
        region = region.split('/')
        if len(region) == 2:
            city = region[0].strip()
            general = region[1].strip()
            reg = city + "-" + general
            return reg.lower()
        elif len(region) == 3:
            city1 = region[0].strip()
            city2 = region[1].strip()
            general = region[2].strip()
            reg = city1 + "-" + city2 + "-" + general
            return reg.lower()
        elif len(region) >= 4:
            return ValueError("ERROR: Too many cities and regions")
    else:
        return region.strip().lower()

# datetime.strptime(test[:-5], '%Y-%m-%dT%H:%M:%S') # HOW TO CAST TIME TO DATETIME

# =============================================================================
# test format_region function
# =============================================================================
# Test cases for our format region function
test1 = 'pierre / central SD'
test2 = 'corvallis/albany'
test3 = 'wausau'
test4 = 'raleigh / durham / Central SD'
test5 = 'raleigh / durham / Los Angeles / Central SD'
test6 = 'witchita falls'
test7 = 'witchita falls/Northern MI'

# Run String Tests
print(format_region(test1))
print(format_region(test3))
print(format_region(test4))
print(format_region(test5))
print(format_region(test6))
print(format_region(test7))

# =============================================================================
# Convert 'posting_date' Column to DT
# =============================================================================

data['posting_date'] = pd.to_datetime(data['posting_date'].str[:10],
                                      format="%Y-%m-%d"
                                      )

print(data['posting_date'].dtype)

# =============================================================================
# Format and insert into DataBase
# =============================================================================
def connect2db(database_name: str ="CraigslistCars.sqlite3",
               table_name: str ="cars")-> None:
    """
    This builds a pipe to the  database, drops the table, makes a new one with
    all the default columns, then returns the connection to be used later

    Parameters
    ----------
    database_name : str, optional
        DESCRIPTION. The default is "CraigslistCars.sqlite3".
    table_name : str, optional
        DESCRIPTION. The default is "cars".

    Returns
    -------
    None
        DESCRIPTION.

    """

    try:
        connection = sqlite3.connect(database_name)
        connection.text_factory = str
    except Error as e:
        print("Error occurred: " + str(e))
        print('\033[32m' + "Sample: " + '\033[m')
        
    # Drop table if exists
    print(f"dropping table {table_name}")
    connection.execute(f"DROP TABLE IF EXISTS {table_name};")
    
    return connection
        
def execute_query(connection, query):
    connection.execute("DROP TABLE IF EXISTS cars;")
    
    cursor = connection.cursor()
    try:
        if query == "":
            return "Query Blank"
        else:
            cursor.execute(query)

            return "Query executed successfully"
    except Error as e:
        return "Error occurred: " + str(e)
    return cursor

def print_table_schema():
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM sqlite_master;")
    print(cursor.fetchall())
    cursor.close()
    return None


generate_empty_table = """CREATE TABLE {table_name}(
                            id INTEGER NOT NULL PRIMARY KEY, 
                            region            TINYTEXT,
                            price             REAL,
                            year              INT,
                            manufacturer      TINYTEXT,
                            model            TINYTEXT,
                            condition        TINYTEXT,
                            cylinders        TINYTEXT,
                            fuel             TINYTEXT,
                            odometer         REAL,
                            title_status     TINYTEXT,
                            transmission     TINYTEXT,
                            VIN              TINYTEXT,
                            drive            TINYTEXT,
                            type             TINYTEXT,
                            paint_color      TINYTEXT,
                            image_url        TINYTEXT,
                            description      TEXT,
                            county           TINYTEXT,
                            state            TINYTEXT,
                            lat              REAL,
                            long             REAL,
                            posting_date     DATETIME
                            )""".format(table_name='cars')

    

# make table here!
connection = connect2db()


#  Make the empty table
execute_query(connection, generate_empty_table)

#  print the schema so we know we did things correctly
print_table_schema()


# this should be some sort of function, but it'll do for now
table_name = 'cars'
with open(filename, 'r') as csvfile:
    csvreader = csv.reader(csvfile)
    next(csvreader , None)  # skip the headers
    
    # inserting each column from csv into database
    for row in csvreader:
        #  there are a million ways to do this in a very clever way, but this is
        #  much more readable to know what's going on
        idd = row[0]
        region = format_region(row[2])
        price = row[4]
        year = row[5]
        manf = row[6]
        model = row[7]
        condition = row[8]
        cylinders = row[9]
        fuel = row[10]
        odometer = np.nan if row[11] == '' else float(row[11])    
        title_stat = row[12]
        transmission = row[13]
        VIN = row[14]
        drive = row[15]
        type_car = row[17]
        paint = row[18]
        image_url = row[19]
        description = row[20][0:255] #limit characters to first 255
        county = row[21]
        state = row[22]
        lat = float(row[23]) if type(row[23]) is not str else np.nan
        long = float(row[24]) if type(row[24]) is not str else np.nan
        posting_time = datetime.strptime(row[25][:-5], '%Y-%m-%dT%H:%M:%S') if len(row[25]) > 0 else np.nan
        
        # And then finally insert it into the database
        db_row = tuple([idd, region, price, year, manf, model, condition, cylinders,
                        fuel, "", title_stat, transmission, VIN, drive, type_car,
                        paint, image_url, description, county, state, lat, long, posting_time])
        connection.execute("""INSERT INTO {} VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,
                                                      ?,?,?,?,?,?,?,?,?,?)""".format(table_name), db_row)
        connection.commit()
    cursor = connection.execute("SELECT * FROM cars limit 10;")
    print(cursor.fetchall())    
# =============================================================================
#  ONLY SQL Stuff
# =============================================================================


    
# def sample(blah, JUST_A_SAMPLE_DONTRUN):
#     try:
#         connection = sqlite3.connect("sample")
#         connection.text_factory = str
#     except Error as e:
#         print("Error occurred: " + str(e))
#     print('\033[32m' + "Sample: " + '\033[m')
    
#     # Sample Drop table
#     connection.execute("DROP TABLE IF EXISTS sample;")
#     # Sample Create
#     connection.execute("CREATE TABLE sample(id integer, name text);")
#     # Sample Insert
#     connection.execute("INSERT INTO sample VALUES (?,?)",("1","test_name"))
#     
#     # Sample Select
     

    
    
    
    


# =============================================================================
# Make the actual table and insert the data
# =============================================================================




