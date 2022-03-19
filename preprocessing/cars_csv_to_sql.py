# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import os
from datetime import datetime
import pandas as pd
from pandas import read_csv
import sqlite3
from sqlite3 import Error
import csv

# =============================================================================
# Initialize some static variable
# =============================================================================
filename = 'vehicles.csv'
 
#ields = []; rows = []

data = read_csv(filename)
# id,url,region,region_url,price,year,manufacturer,model,condition,cylinders,
# fuel,odometer,title_status,transmission,VIN,drive,size,type,paint_color,
# image_url,description,county,state,lat,long,posting_date

test1 = ''
test2 = ''


def format_region(region):
    """
    this  is a function that does something, here's the explaination here!

    Parameters
    ----------
    region : string
        region of csv data.

    Returns
    -------
    region : TYPE
        DESCRIPTION.
    state : TYPE
        DESCRIPTION.

    """
    region = region.split('/')
    state = region[1]
    return region, state

# =============================================================================
# test on format 1
# =============================================================================
output_test1 = format_region(test1)
output_test2 = format_region(test2)

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
        
      