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

##===============================================================================
##  Create Plot to compare average price for different regions of the Country  ==
##===============================================================================

Avg_Price_per_Region_Plot <- function(input_manufacturer, input_model) {
  
  # Connect to db and create df based on input_manufacturer
  conn <- dbConnect(RSQLite::SQLite(), db_path)
  df <- dbGetQuery(conn, glue("SELECT state, city, manufacturer, model_clean, year, condition, odometer, price
                               FROM Ford"))
  # Close db connection
  dbDisconnect(conn)
  
  # Create different regions of the country
  southwest <- c("CA", "AZ", "NM", "HI","NV")
  west <- c("UT", "CO", "WY", "MT", "ND", "SD")
  pnw <- c("AK", "OR", "ID", "WA")
  n_east <- c("CT", "ME", "MA", "NH", "RI", "VT")
  east <- c("NJ", "NY", "DE", "MD", "PA", "VA", "DC", "WV")
  s_east <- c("AL", "FL", "GA", "KY", "MS", "NC", "SC", "TN")
  midwest <- c("IL", "IN", "MI", "MN", "OH", "WI")
  south <- c("TX", "AR", "LA", "OK")
  central <- c("IA", "KS", "MO", "NE")
  
  
  df <- df %>%
    mutate(region = case_when(state %in% southwest ~ "Southwest", 
                              state %in% west ~ "West",
                              state %in% pnw ~ "Pacific Northwest",
                              state %in% n_east ~ "Northeast",
                              state %in% east ~ "East",
                              state %in% s_east ~ "Southeast",
                              state %in% midwest ~ "Midwest",
                              state %in% south ~ "South",
                              state %in% central ~ "Central"
                              )
           )
  
  
  regions <- df %>% 
    filter(manufacturer == "Ford",
           model_clean == "F-150",
           year == 2017) %>% 
    group_by(region) %>%
    summarise(avg_price = mean(price),
              avg_odometer = mean(odometer),
              n = n()) %>% 
    mutate(avg_price = avg_price,
           avg_odometer = avg_odometer)
    
  
  
  
    plt <- ggplot(regions) +
    # Make custom panel grid
      geom_hline(aes(yintercept = y), data.frame(y = c(0:5) * 10000), color = "lightgrey") +
      geom_col(aes(x = region, y = avg_price, fill = n), position = "dodge2", show.legend = TRUE, alpha = .9) +
      
      # Add dots to represent the mean gain
      geom_point(aes(x = region, y = avg_price), size = 2, color = "gray12") +
      
      # Lollipop shaft for mean gain per region
      geom_segment(aes(x = region, y = 0, xend = region, yend = 40000), linetype = "dashed", color = "gray12") + 
      
      labs(title = "Average Price for 2017 Ford F-150",
           subtitle = "Compared Between US Regions",
           y = "Price", 
           x = "Region", 
           fill = "Number of Vehicles") +
      
      # Scale y axis so bars don't start in the center
      scale_y_continuous(
        limits = c(-1500, 45000),
        expand = c(0, 0),
        breaks = c(0, 10000, 20000, 30000, 40000)
      ) +
      
      annotate("text", x = 0, y = 21000, label = "20,000", size = 2) +
      annotate("text", x = 0, y = 31000, label = "30,000", size = 2) +
      annotate("text", x = 0, y = 41000, label = "40,000", size = 2) +
      
      theme(
        # Remove axis ticks and text
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text.y = element_blank(),
        # Use gray text for the region names
        axis.text.x = element_text(color = "gray12", size = 10),
        # Move the legend to the bottom
        legend.position = "bottom",
      ) +
      
      theme(
        
        # Set default color and font family for the text
        text = element_text(color = "gray12"),
        
        # Customize the text in the title, subtitle, and caption
        plot.title = element_text(face = "bold", size = 15, hjust = 0.5),
        plot.subtitle = element_text(size = 10, hjust = 0.5),
        plot.caption = element_text(size = 8, hjust = .5),
        
        # Make the background white and remove extra grid lines
        panel.background = element_rect(fill = "white", color = "white"),
        panel.grid = element_blank(),
        panel.grid.major.x = element_blank()
      ) + 
      
      # New fill and legend title for number of tracks per region
      scale_fill_gradientn(
        "Number of Vehicles",
        colours = c("#31688e", "#fcffa4","#ed6925", "#F8B195")
      ) +
      # Make the guide for the fill discrete
      guides(
        fill = guide_colorsteps(
          barwidth = 15, barheight = .5, title.position = "top", title.hjust = .5
        )
      ) +
      
      
      # Make it circular
      coord_polar()
    
      ggsave("plot.png", plt,width = 13, height = 8)
      
    plt
}


