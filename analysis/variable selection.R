
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
db_path <- "CraigslistCarsClean.sqlite3"
conn <- dbConnect(RSQLite::SQLite(), db_path)
dbListTables(conn)

#------------------------------------------------------------------------------
# Step 1: Create a simple dataframe to use for modeling and varible selection
#------------------------------------------------------------------------------

# Join the Percent of Employment Attributable to Outdoor Rec to the main cars table
query = '
  SELECT A.*
    ,B.[Percent of total wage and salary employment1]
    ,B.[Percent of total compensation1]
  FROM cars_clean A
  LEFT JOIN outdoor_rec_by_state B
    ON A.state = B.State
'
cars <- dbGetQuery(conn, query)
dbDisconnect(conn)
#rename new columns
names(cars)[names(cars) == 'Percent of total wage and salary employment1'] <- 'perc_outdoor_employment'
names(cars)[names(cars) == 'Percent of total compensation1'] <- 'perc_total_comp'

# Create a new column for how old the car is (in years)
cars$age = (2021 - cars$year)

# Create a binary variable for title status
cars$has_clean_title = ifelse(cars$title_status == 'clean', 1, 0)

# filter out cars where price too big/small
max_price = 100000
min_price = 1000
cars_new = 
  cars %>% 
    filter((price > min_price) & (price < max_price)) %>% 
    select(price, perc_outdoor_employment, perc_total_comp, age, has_clean_title)
nrow(cars) # = 400870 rows
nrow(cars_new) # = 359537 rows
head(cars_new)

# Next, I'll proceed with variable selection.
# Of course for the final models, we will want to include more variables


#------------------------------------------------------------------------------
# Step 2: Create models -- pretty basic ones for sample purpose
#------------------------------------------------------------------------------
lin_model <- lm(as.numeric(price) ~ perc_outdoor_employment + perc_total_comp + age + has_clean_title, data = cars_new)
log_employment_model <- lm(as.numeric(price) ~ log(perc_outdoor_employment) + age + has_clean_title, data = cars_new)
summary(lin_model)
summary(log_employment_model)


#------------------------------------------------------------------------------
# Step 3: Variable Selection Methods (Work in Progress)
#         hoping to create some reusable functions here
#------------------------------------------------------------------------------

# One-directional step-wise procedures

# Backward Elimination
model_back = lin_model
step(model_back, direction="backward", trace=1)

# Forward Selection
model_forward = lin_model 
step(model_forward,
     scope = formula(model_forward),
     direction= "forward", trace = 1) 

# Stepwise Regression
model_both = lin_model
step(model_both,
     scope = list(
       lower = formula(lm(as.numeric(price)~1, data = cars)), 
       upper = formula(model_both) 
       ),
     direction = "both",
     trace = 1 
     )

# My hope was that the variable selection procedures would eliminate one of the
#   outdoor rec fields, as I would expect these to have redundant information

# However, each of the stepwise procedures resulted in keeping all variables.
#   This may be due to the small number of variables in the current model.

# Next I will try global methods.


#------------------------------------------------------------------------------
# Step 4: Create Functions for Model Comparison (Work in Progress)
#------------------------------------------------------------------------------

