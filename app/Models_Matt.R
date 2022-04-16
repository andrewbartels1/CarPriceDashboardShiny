rm(list = ls())

##=================================
##  Load Libraries and set Path  ==
##=================================

library(tidyverse)
library(dplyr)
options(dplyr.summarise.inform = FALSE)

library(readxl) 
library(stringr) # string formatting
library(RSQLite) # to connect to SQlite database
library(roxygen2) # For Function Documentation: ctrl + option + shift + r
library(corrplot)
library(ggcorrplot)
library(glue) # to format strings

library(bannerCommenter) # input into console -> banner("display text", snug = TRUE, bandChar = "=")

db_path <- "CraigslistCarsClean.sqlite3"

##==================================
##  create df 'ford' for testing  ==
##==================================

# Connect to the database
conn <- dbConnect(RSQLite::SQLite(), db_path)
ford <- dbGetQuery(conn, "SELECT * FROM Ford")

# Close db connection
dbDisconnect(conn)

##==================================================================
##  Function to Create Box Plots Comparing Models                 ==
##==================================================================

#' Title: Model_Box
#'
#' @param input_manufacturer {string}
#'
#' @return: box plot
#' @export: box plot
#'
#' @examples: Model_Box("Ford")
#' 
#' 
Model_Box <- function(input_manufacturer){
  
  # Connect to the database
  conn <- dbConnect(RSQLite::SQLite(), db_path)
  df <- dbGetQuery(conn, glue("SELECT model_clean, price
                               FROM {input_manufacturer}"))
  # Close db connection
  dbDisconnect(conn)
  
  # Build box plots
  model_box <- df %>% 
    group_by(model_clean) %>% 
    summarise(count = n(), price = price) %>%
    # Filter out vehicles that have limited number of observations
    filter(count > 500) %>% 
    ggplot(aes(x = price, y = model_clean, color = model_clean)) +
    geom_boxplot() +
    labs(title = glue("{input_manufacturer} Models - Boxplot"), 
         y = "Model", 
         x = "Price", 
         color = "Model")
  
  # Return Plot
  plot(model_box)
  
}


##-----------------------------
##  Test Model_Box Function  --
##-----------------------------
Model_Box("Ford")


##==================================================================
##  Function to Make a Prediction based on user generated inputs  ==
##==================================================================

#' Title: Model_Prediction
#'
#' @param input_state {string}
#' @param input_city {string}
#' @param input_manufacturer {string} 
#' @param model {string}
#' @param year {int}
#' @param odometer {int}
#' @param input_condition {string} 
#' @param drive {string}
#' @param cylinders {string}
#'
#' @return list [n of observations, model summary, predicted price + confidence intervals]
#' @export
#'
#' @examples Local_Model_Prediction("CA", "Los Angeles", "Ford", "F-150", 2015, 100000, "good", "4wd", "8")
#' 
Local_Model_Prediction <- function(input_state, input_city, input_manufacturer, model, 
                             year, odometer, input_condition, drive, cylinders) {
  
  # Connect to db and create df based on input_manufacturer
  conn <- dbConnect(RSQLite::SQLite(), db_path)
  df <- dbGetQuery(conn, glue("SELECT state, city, manufacturer, model_clean, age, condition, 
                                      odometer, drive, cylinders, price, med_family_income, med_non_family_income
                               FROM {input_manufacturer}"))
  # Close db connection
  dbDisconnect(conn)
  
  # Create a df filtered by input state, manufacturer, and model
  df <- df %>%
    filter(state == input_state, 
           manufacturer == input_manufacturer, 
           model_clean == model,
           condition == input_condition
    )
  
  # Extract income values for model 
  med_inc <- df %>% filter(state == input_state, city == input_city)
  med_inc_fam <- med_inc$med_family_income[1]
  med_inc_non_fam <- med_inc$med_non_family_income[1]
  
  # Create linear model
  lm_model <- lm(price ~ age + odometer + drive + cylinders + med_family_income + med_non_family_income, data = df)
  
  # Create new data point from user inputs
  newData <- data.frame(model_clean = model,
                        age = 2021 - year,
                        odometer = odometer,
                        drive = drive,
                        cylinders = cylinders,
                        med_family_income = med_inc_fam,
                        med_non_family_income = med_inc_non_fam)
  
  # Create list of objects to return as list
  number_of_observations <- paste("Number of Training Observations = ", nrow(df))
  model_summary <- summary(lm_model)
  predictions <- predict(lm_model, newdata = newData, interval = "confidence", level = .95)
  
  
  return(list(number_of_observations, model_summary, predictions))
  
}

##------------------------------------
##  Test Model_Prediction Function  --
##------------------------------------

Local_Model_Prediction("CA", "Los Angeles", "Ford", "F-150", 2015, 100000, "good", "4wd", "8")


##======================================================
##  Create Function to get National Predicted Price  ==
##======================================================


#' Title: National_Model_Prediction
#'
#' @param input_state {string}
#' @param input_city {string}
#' @param input_manufacturer: {string}
#' @param model {string}
#' @param year {int}
#' @param odometer {int}
#' @param input_condition {string}
#' @param drive {string}
#' @param cylinders {string}
#'
#' @return list [n of observations, model summary, predicted price + confidence intervals]
#' @export
#'
#' @examples National_Model_Prediction("CA", "Los Angeles", "Ford", "F-150", 2015, 100000, "good", "4wd", "8")
#' 
National_Model_Prediction <- function(input_state, input_city, input_manufacturer, model, year, odometer, 
                                      input_condition, drive, cylinders) {
  
  # Connect to db and create df based on input_manufacturer
  conn <- dbConnect(RSQLite::SQLite(), db_path)
  df <- dbGetQuery(conn, glue("SELECT state, city, manufacturer, model_clean, age, condition, 
                                      odometer, drive, cylinders, med_family_income, med_non_family_income, price
                               FROM {input_manufacturer}"))
  # Close db connection
  dbDisconnect(conn)
  
  # Create a df filtered by input state, manufacturer, and model
  df <- df %>%
    filter(manufacturer == input_manufacturer, 
           model_clean == model,
           condition == input_condition
    )
  
  # Extract income values for newData
  med_inc <- df %>% filter(state == input_state, city == input_city)
  med_inc_fam <- med_inc$med_family_income[1]
  med_inc_non_fam <- med_inc$med_non_family_income[1]
  
  # Create linear model
  lm_model <- lm(price ~ age + odometer + drive + cylinders + med_family_income + med_non_family_income, data = df)
  
  # Create new data point from user inputs
  newData <- data.frame(model_clean = model,
                        age = 2021 - year,
                        odometer = odometer,
                        drive = drive,
                        cylinders = cylinders,
                        med_family_income = med_inc_fam,
                        med_non_family_income = med_inc_non_fam)
  
  # Create list of objects to return as list
  number_of_observations <- paste("Number of Training Observations = ", nrow(df))
  model_summary <- summary(lm_model)
  predictions <- predict(lm_model, newdata = newData, interval = "confidence", level = .95)
  
  
  return(list(number_of_observations, model_summary, predictions))
  
}

##---------------------------------------------
##  Test National_Model_Prediction Function  --
##---------------------------------------------

National_Model_Prediction("CA", "Los Angeles", "Ford", "F-150", 2015, 100000, "good", "4wd", "8")
