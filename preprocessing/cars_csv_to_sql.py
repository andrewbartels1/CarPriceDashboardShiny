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
import csv

# =============================================================================
# Initialize some static variable and read in DataFrame
# =============================================================================
filename = '/Users/matt/Desktop/MGT 6203/Group Project/MGT6203-grp-project/vehicles.csv'
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
                                      format = "%Y-%m-%d"
                                      )

print(data['posting_date'].dtype)

# =============================================================================
# Format and insert into DataBase
# =============================================================================
# reading csv file
with open(filename, 'r') as csvfile:
    csvreader = csv.reader(csvfile)

    # inserting each column from csv into database
    for row in csvreader:
        region = row[2]
        format_region(region)
        # connection.execute("INSERT INTO {} VALUES (?,?,?,?,?)".format(table_name), tuple(row))

region = row[2]

# =============================================================================
#  ONLY SQL Stuff
# =============================================================================

# c = connection.cursor()
connection = sqlite3.connect("CraigslistCars.sqlite3")

part_aiii_sql = """CREATE TABLE {table_name}(
                            id INTEGER, 
                            region TINYTEXT,
                            birthday TEXT,
                            price INTEGER,
                            popularity FLOAT
                            )""".format(table_name='cars')
    
# make table here!
execute_query(connection, part_aiii_sql)
        
        
        
   
def execute_query(connection, query):
    
        cursor = connection.cursor()
        try:
            if query == "":
                return "Query Blank"
            else:
                cursor.execute(query)
                connection.commit()
                return "Query executed successfully"
        except Error as e:
            return "Error occurred: " + str(e)
  
 






     