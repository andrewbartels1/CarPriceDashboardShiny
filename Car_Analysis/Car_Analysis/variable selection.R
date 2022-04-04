
# Functions for Variable Selection, plus a few basic models

# Author: Jason Young

#-------------------------------------------------------------------------
# Setup
#-------------------------------------------------------------------------
rm(list = ls()) # clear environment
library(tidyverse)
library(dplyr)
library(readxl) 
library(stringr) # string formatting
library(RSQLite) # to connect to SQlite database
library(roxygen2) # For Function Documentation: ctrl + option + shift + r
library(glmnet)

# SQLite Connection
# Using Matt's cleaned tables
db_path <- "/Users/jasonyoung/Desktop/group project/CraigslistCarsClean.sqlite3"
conn <- dbConnect(RSQLite::SQLite(), db_path)
dbListTables(conn)

#------------------------------------------------------------------------------
# Step 1: Create a simple dataframe to use for modeling and varible selection
#------------------------------------------------------------------------------

# Join the Percent of Employment Attributable to Outdoor Rec to the main cars table
query = '
  SELECT A.*, B.[Percent of total wage and salary employment1]
  FROM cars_clean A
  LEFT JOIN outdoor_rec_by_state B
    ON A.state = B.State
'
cars <- dbGetQuery(conn, query)
dbDisconnect(conn)
#rename new column
names(cars)[names(cars) == 'Percent of total wage and salary employment1'] <- 'perc_outdoor_employment'

# Create a new column for how old the car is (in years)
cars$age = (2021 - cars$year)

# Create a binary variable for title status
cars$has_clean_title = ifelse(cars$title_status == 'clean', 1, 0)

# filter out cars where price is too strange


# Next, I'll proceed with variable selection.
# Of course for the final models, we will want to include more variables

#------------------------------------------------------------------------------
# Step 2: Create models
#------------------------------------------------------------------------------

lin_mod <- lm(price ~ perc_outdoor_employment + age + has_clean_title, data = cars)
summary(lin_mod)

