#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 28 07:34:14 2022

@author: bartelsaa
"""
# Import the functions
import os
from datetime import datetime
import pandas as pd
from pandas import read_csv
import sqlite3
from sqlite3 import Error
import numpy as np
import csv
import glob

# =============================================================================
# Helper functions
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
    
def connect2db(database_name: str ="CraigslistCars.sqlite3")-> None:
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
        
    return connection
        
# NOTE USED CURRENTLY!!
def execute_query(connection: sqlite3.Connection, query: str):
    """
    executes any query and returns a cursor

    Parameters
    ----------
    connection : sqlite3.Connection
        connection object to sqlite database.
    query : str
        Query as a string to do in the database.

    Returns
    -------
    TYPE
        DESCRIPTION.

    """
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

def print_table_schema(connection):
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM sqlite_master;")
    print(cursor.fetchall())
    cursor.close()
    return None

def drop_table_if_exists(connection: sqlite3.Connection, table: str) -> None:
    """
    Drop tables before inserting everything!

    Parameters
    ----------
    conenction : sqlite3.Connection
        open connection to the database
    table : str
        Name of table to drop/clean before inserting.

    Returns
    -------
    None
        doesn't output anything.

    """
    # Drop table if exists
    print(f"dropping table {table}")
    connection.execute(f"DROP TABLE IF EXISTS {table};")
    return None
    
def insert_tables(connection: sqlite3.Connection, fileDict: dict) -> bool:
    
    
    for file in fileDict:
        df = pd.read_csv(f'raw/{file}.csv')
        # maybe generate schema here?
        df.to_sql(name=file, con=connection)
        
    return True
    
def get_all_csv_files(path: str, filetype: str ='.csv') -> dict:
    """
    Function to grab all the csvs, and get all the keys, place them in a tuple
    and return them. 

    Parameters
    ----------
    path : path to RELATIVE folder path where all the csv files are
        DESCRIPTION.
    filetype : str, optional
        filetype, keeping it csv for now to keep it simple. The default is '.csv'.

    Returns
    -------
    dict --
        filelist: dict key
            list of files in path with filetype in name
        keys : list
            all keys (or colunns) of file
    """
    
    filelist = glob.glob(path + "*"+ filetype)
    filenames = []
    keys = []
    
    # get all the file names to make table names
    
    for file in filelist:
        filenames.append(os.path.split(file)[1].split('.')[0]) # get just the name for the table name
        
        with open(file) as f:
            reader = csv.DictReader(f)
            keys.append(reader.fieldnames)
        
    
    return dict(zip(filenames, keys))

def main(path):
    
    # make a dictionary of table names and keys    
    fileDict = get_all_csv_files(path)

    # open a connection to the sqlite database
    connection = connect2db()

    # drop all the tables before adding them.
    [drop_table_if_exists(connection, table) for table in fileDict]
    
    # call the function that gets all the types for a table and inserts them into the 
    # database.
    insert_tables(connection, fileDict)
    
    
    
    

if __name__ == "__main__":
    path = "raw/" # relative path where all the csvs live
    main(path)
