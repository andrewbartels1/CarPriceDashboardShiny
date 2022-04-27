
#title: "Random_Forest_Shawn"
#author: Shawn

  
  #### Clear Environment
rm(list = ls())


#### Load Libraries
library(tidyverse)
library(dplyr)
library(readxl) 
library(stringr) # string formatting
library(RSQLite) # to connect to SQlite database
library(roxygen2) # For Function Documentation: ctrl + option + shift + r

#random forest library, will also try with Caret Package
library(randomForest)

#set path to the database
db_path <- "../CraigslistCarsClean.sqlite3"

conn <- dbConnect(RSQLite::SQLite(), db_path)

#dbDisconnect(conn)

dbListTables(conn)

#Grab the Ford Table
ford <- dbGetQuery(conn, "SELECT * FROM Ford")

#Take a gander at the Ford Table
head(ford)
summary(ford)


#simple randomForest
#basic decsion tree
model = randomForest(price ~ ., data = ford, 
                     do.trace = TRUE)

#Note that the above simple randomForest will run 500 Trees, so I implemented do.trace = TRUE
# to see the progress

#Observe output
model

summary(model)


