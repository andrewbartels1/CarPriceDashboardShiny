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
library(viridis)

library(bannerCommenter) # input into console -> banner("display text", snug = TRUE, bandChar = "=")

##=======================================
##  Connect to Database and create df  ==
##=======================================

# My thinking here is that the app will query the "clean" table upon launch and assign the table to 
# appropriately named data frame called 'cars'. Currently, the only usable table with a clean model variable is "Ford".


# Create Path to SQLite db
db_path <- "CraigslistCarsClean.sqlite3"

# Establish connection
conn <- dbConnect(RSQLite::SQLite(), db_path)
cars <- dbGetQuery(conn, "SELECT * FROM Ford")

# Close db connection
dbDisconnect(conn)

##=================================================================================
##  Create Function to compare fuel types for different Vehicle types            ==
##=================================================================================

# This function takes in a dataframe, and returns a plot comparing different types 
# of vehicles with various fuel types and returns a stacked bar chart. This function
# can potentially be used on the "Analysis" tab of the app.


#' Title: Fuel Comparison
#'
#' @param df 
#' @param input_manufacturer {string}
#'
#' @return stacked bar plot
#' @export .png
#'
#' @examples Fuel_Comparison(cars, "Ford")
#' 
#' 
Fuel_Comparison <- function(df, input_manufacturer){
  
  # combine truck / pickup and unknown / other
  combine_truck_pickup <- c("truck", "pickup")
  combine_unk_other <- c("unknown", "other")
  
  # filter the dataframe, summarise, and arrange
  car_type <- df %>%
    filter(manufacturer == input_manufacturer) %>% 
    mutate(type = ifelse(type %in% combine_truck_pickup, "truck", type),
           type = ifelse(type %in% combine_unk_other, "other", type)
           ) %>% 
    group_by(fuel,type) %>% 
    summarize(count=n()) %>% 
    arrange(desc(count)) %>% 
    top_n(10)
  
  # create a plot object and flip the coordinates
  plot <- ggplot(car_type,aes(fill=fuel, x=reorder(type, count), y=count)) + 
    geom_bar(stat ="identity",position = "stack") +
    labs(title = glue("{input_manufacturer} - Vehicle Class by Fuel Type"), x = "Class of Vehicle", y = "Count", fill = "Fuel Type") +
    coord_flip()
  
  # export .png of plot
  ggsave(glue("{input_manufacturer}_stacked_bar_fuel_type.png"), width = 13, height = 8)
  
  return(plot)
}

##-------------------
##  test function  --
##-------------------

Fuel_Comparison(cars, "Ford")




##======================================================
##  Create Function to compare condition of vehicles  ==
##======================================================

# This function creates a violin plot showing the distribution
# of condition vs year. This plot might be useful for the Analysis tab.

#' Title: Condition_Comparison
#'
#' @param df 
#' @param input_manufacturer {string}
#'
#' @return violin plot
#' @export .png
#'
#' @examples Condition_Comparison(cars, "Ford")
#' 
#' 
Condition_Comparison <- function(df, input_manufacturer) {
  
  df <- df %>% filter(year > 1975)
  
  plot <- ggplot(df,aes(x = year, y = condition, color = condition)) + 
    geom_violin(scale = 'area') + 
    geom_boxplot(width = 0.1, colors = 'grey', alpha = 0.2) +
    labs(title = glue("{input_manufacturer} - Violin Plot by Condition"),
         subtitle = "Years: 1975 - 2021", 
         x = "Condition", 
         y = "Year",
         fill = "Fuel Type") +
    coord_flip()
  
  # export .png of plot
  ggsave(glue("{input_manufacturer}_violin_plot_condition.png"), width = 13, height = 8)
  
  return(plot)
  
}

##-------------------
##  test function  --
##-------------------

Condition_Comparison(cars, "Ford")


