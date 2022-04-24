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
library(kknn) #for KNN model
library(bannerCommenter) # input into console -> banner("display text", snug = TRUE, bandChar = "=")

##==================================================================
##  Connect to Database and create df based on input_manufacturer ==
##==================================================================

# My thinking here is that the app will query the "clean" table upon launch and assign the table to 
# appropriately named data frame called 'cars'. Currently, the only usable table with a clean model variable is "Ford".


# Create Path to SQLite db
db_path <- "Top_5_Manufacturers.sqlite"

# Establish connection
conn <- dbConnect(RSQLite::SQLite(), db_path)

# List Tables
dbListTables(conn)

# Write Table to DB
#dbWriteTable(conn, "cars", cars, overwrite = FALSE)

# Write query
cars <- dbGetQuery(conn, "SELECT * FROM cars")

# Close db connection
dbDisconnect(conn)

##=================================================================================
##  Create Function to assign each row to a specific region of the country       ==
##=================================================================================

#This function will segment our DF into 9 different regions for comparison purposes: 

#' Title: Add_Regions
#' 
#' @param df {dataframe}
#' @return: dataframe
#' @examples: Add_Regions(cars)
#' 
Add_Regions <- function (df) {
  
  # Create 9 different regions of the country
  southwest <- c("CA", "AZ", "NM", "HI","NV")
  west <- c("UT", "CO", "WY", "MT", "ND", "SD")
  pnw <- c("AK", "OR", "ID", "WA")
  n_east <- c("CT", "ME", "MA", "NH", "RI", "VT")
  east <- c("NJ", "NY", "DE", "MD", "PA", "VA", "DC", "WV")
  s_east <- c("AL", "FL", "GA", "KY", "MS", "NC", "SC", "TN")
  midwest <- c("IL", "IN", "MI", "MN", "OH", "WI")
  south <- c("TX", "AR", "LA", "OK")
  central <- c("IA", "KS", "MO", "NE")
  
  # Add Regions to cars DF
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
  
 return(df) 
  
}

# Add regions to 'cars' df
# cars <- Add_Regions(cars)

##==================================================================
##  Function to Create Box Plots Comparing Models                 ==
##==================================================================

# This simple function creates a set of boxplots of the various model when given a 
# specific manufacturer as an input. 
# This function can be used on the ANALYSIS tab of the app

#' Title: Model_Box
#'
#' @param df {DataFrame}
#'
#' @return: box plot
#' @export: {manufacturer}Box_plot.png
#'
#' @examples: Model_Box(ford)
#' 
#' 
Model_Box <- function(df, input_manufacturer) {
  
  # Filter by the input_manufacturer
  df <- df %>% filter(manufacturer == input_manufacturer) %>% 
               filter(price <= 100000)
  df <- df[!df %in% boxplot.stats(df$price)$out]
  
  # Build box plots
  model_box <- df %>% 
    group_by(model) %>% 
    summarise(count = n(), price = price) %>%
    
    # Filter out vehicles that have limited number of observations.
    # In this case, I've removed all models with less than 500 total observations.
    
    filter(count > 500) %>% 
    ggplot(aes(x = price, y = model, color = model)) +
    geom_boxplot() +
    labs(title = glue("{input_manufacturer} Models - Boxplot"), 
         y = "Model", 
         x = "Price", 
         color = "Model")
  
  # export .png of plot
  # ggsave(glue("{input_manufacturer}_boxplot.png"), width = 13, height = 8)
  
  # Return Plot
  return(model_box)
  
}

##-----------------------------
##  Test Model_Box Function  --
##-----------------------------
# Model_Box(cars, "Ford")


##==================================================================
##  Function to Make a Prediction based on user generated inputs  ==
##==================================================================

# This function will create a linear model based on what the users inputs in the app. My thinking 
# is that the user will select from a pre-determined menu of available inputs, and this function will 
# return a predicted price, model summary, and number of observations it used to make the prediction. 
# We can also tweak the list of returns to include things like R2 or whatever else we want.
# This function could be used for the PREDICTIONS tab on the app.


#' Title: State_Model_Prediction
#'
#' @param df {dataframe}
#' @param input_state {string}
#' @param input_city {string}
#' @param input_manufacturer {string} 
#' @param input_model {string}
#' @param input_year {int}
#' @param input_odometer {int}
#' @param input_condition {string} 
#' @param input_drive {string}
#' @param input_cylinders {string}
#'
#' @return list [n of observations, model summary, predicted price + confidence intervals]
#' @export
#'
#' @examples Local_Model_Prediction(ford, "CA", "Los Angeles", "Ford", "F-150", 2015, 100000, "good", "4wd", "8")
#' 
#' 
#' 
State_Model_Prediction <- function(df, input_state, input_city, input_manufacturer, input_model, 
                                   input_year, input_odometer, input_condition, input_drive, input_cylinders) {
  
  # Create a df filtered by the user selected state, manufacturer, model, and condition.
  df <- df %>%
    filter(state == input_state,
           manufacturer == input_manufacturer, 
           model == input_model,
           condition == input_condition
    )
  
  # Extract income values for model. This is used to figure out what median income is in the user selected city.
  med_inc <- df %>% filter(state == input_state, city == input_city)
  med_inc_fam <- med_inc$med_family_income[1]
  med_inc_non_fam <- med_inc$med_non_family_income[1]
  
  # Create linear model
  lm_model <- lm(price ~ age + odometer + drive + cylinders + med_family_income + med_non_family_income, data = df)
  
  # Create new data point from user inputs
  newData <- data.frame(model = input_model,
                        age = 2021 - input_year,
                        odometer = input_odometer,
                        drive = input_drive,
                        cylinders = input_cylinders,
                        med_family_income = med_inc_fam,
                        med_non_family_income = med_inc_non_fam)
  
  # Create list of objects to return as list
  number_of_observations <- paste("Number of Training Observations = ", nrow(df))
  model_summary <- summary(lm_model)
  predictions <- predict(lm_model, newdata = newData, interval = "confidence", level = .95)
  
  
  return(list(head(df, 25), number_of_observations, model_summary, predictions))
  
}

##------------------------------------
##  Test Model_Prediction Function  --
##------------------------------------
#State_Model_Prediction(cars, "CA", "Sacramento", "Ford", "F-150", 2015, 100000, "good", "4wd", "8")

##======================================================
##  Create Function to get National Predicted Price  ==
##======================================================

# Similar to the State_Model_Prediction function, this function uses ALL models instead of filtering by state.
# It doesn't seem to perform as well but might be used as a comparison.
# This function could be used for the PREDICTIONS tab on the app.


#' Title: National_Model_Prediction
#' 
#' @param df {dataframe}
#' @param input_state {string}
#' @param input_city {string}
#' @param input_manufacturer: {string}
#' @param input_model {string}
#' @param input_year {int}
#' @param input_odometer {int}
#' @param input_condition {string}
#' @param input_drive {string}
#' @param input_cylinders {string}
#'
#' @return list [n of observations, model summary, predicted price + confidence intervals]
#'
#' @examples National_Model_Prediction(ford, "CA", "Los Angeles", "Ford", "F-150", 2015, 100000, "good", "4wd", "8")
#' 
#' 
#' 
National_Model_Prediction <- function(df, input_state, input_city, input_manufacturer, 
                                      input_model, input_year, input_odometer, input_condition, input_drive, input_cylinders) {
  
  # Create a df filtered by the user selected manufacturer, model, and condition.
  df <- df %>%
    filter(manufacturer == input_manufacturer,
           model == input_model,
           condition == input_condition)

  # Extract income values for newData
  med_inc <- df %>% filter(state == input_state, city == input_city)
  med_inc_fam <- med_inc$med_family_income[1]
  med_inc_non_fam <- med_inc$med_non_family_income[1]

  # Create linear model
  lm_model <- lm(price ~ age + odometer + drive + cylinders + med_family_income + med_non_family_income, data = df)

  # Create new data point from user inputs
  newData <- data.frame(model = input_model,
                        age = 2021 - input_year,
                        odometer = input_odometer,
                        drive = input_drive,
                        cylinders = input_cylinders,
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

#National_Model_Prediction(cars, "CA", "Sacramento", "Ford", "F-150", 2015, 100000, "good", "4wd", "8")

##===============================================================================
##  Create Plot to compare average price for different regions of the Country  ==
##===============================================================================

# this function compares a specific make, model, and year between various regions of the country.
# I think this function can be used on the ANALYSIS tab or the PREDICTION tab of the app.

#' Title: Avg_Price_Per_Region_Plot
#'
#' @param df {dataframe}
#' @param input_manufacturer {string}
#' @param input_model {string}
#' @param input_year {int}
#'
#' @return Circular Bar Plot
#' @export .png
#'
#' @examples Avg_Price_Per_Region_Plot(cars, "Ford", "Mustang", 2015)
#' 
#' 
#' 
Avg_Price_Per_Region_Plot <- function(df, input_manufacturer, input_model, input_year) {
  
  # Filter by manufacturer, model, year
  regions <- df %>% 
    filter(manufacturer == input_manufacturer,
           model == input_model,
           year == input_year) %>% 
    group_by(region) %>%
    # create avg price column, avg odometer column, and number of observations
    summarise(avg_price = mean(price),
              avg_odometer = mean(odometer),
              n = n()) %>% 
    mutate(avg_price = avg_price,
           avg_odometer = avg_odometer)
  
  if (nrow(regions) != 0) {

    # Create Plot
    print(nrow(df))
    
    
    plot <- ggplot(regions) +

    # Make custom panel grid
      geom_hline(aes(yintercept = y), data.frame(y = c(0:5) * 10000), color = "lightgrey") +
      geom_col(aes(x = region, y = avg_price, fill = n), position = "dodge2", show.legend = TRUE, alpha = .9) +

      # Add dots
      geom_point(aes(x = region, y = avg_price), size = 2, color = "gray12") +

      # Create a Lollipop shaft
      geom_segment(aes(x = region, y = 0, xend = region, yend = 40000), linetype = "dashed", color = "gray12") +

      # Create Labels for title, subtitle, x, y, and fill
      labs(title = glue("Average Price for {input_year} {input_manufacturer} {input_model}"),
           subtitle = "Comparison Between US Regions",
           y = "Price",
           x = "Region",
           fill = "Number of Vehicles") +

      # Scale y axis so bars don't start in the center
      scale_y_continuous(
        limits = c(-1500, 45000),
        expand = c(0, 0),
        breaks = c(0, 10000, 20000, 30000, 40000)
                         ) +
      
      annotate("text", x = 0, y = 21000, label = "20,000", size = 5) +
      annotate("text", x = 0, y = 31000, label = "30,000", size = 5) +
      annotate("text", x = 0, y = 41000, label = "40,000", size = 5) +
      
      theme(
        # Remove axis ticks and text
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text.y = element_blank(),
        # Use gray text for the region names
        axis.text.x = element_text(color = "gray12", size = 15),
        # Move the legend to the bottom
        legend.position = "bottom",
            ) +

      theme(

        # Set default color for the text
        text = element_text(color = "gray12"),

        # Customize the text in the title, subtitle, and caption

        plot.title = element_text(face = "bold", size = 20, hjust = 0.5),
        plot.subtitle = element_text(size = 20, hjust = 0.5),
        plot.caption = element_text(size = 26, hjust = .5),
        
        # Make the background white and remove extra grid lines
        panel.background = element_rect(fill = "white", color = "white"),
        panel.grid = element_blank(),
        panel.grid.major.x = element_blank()
           ) +

      # New fill and legend title for number of tracks per region
      scale_fill_gradientn(
        "Number of Vehicles",
        colours = c("#6C5B7B","#C06C84","#F67280","#F8B195")
                           ) +

      # Make the guide for the fill discrete
      guides(
        fill = guide_colorsteps(
          barwidth = 15, barheight = .5, title.position = "top", title.hjust = .5)
             ) +


      # Make it circular
      coord_polar()

      # Save the plot
      ggsave("circle_bar_plot.png", plot,width = 13, height = 8)

      return(plot)

  } else {
    
   return("Not enough data available for this Make / Model / Year. Please try a different selection")
   
  }
}

##---------------------------------------------
##  Test Avg_Price_Per_Region_Plot function --
##---------------------------------------------

Avg_Price_Per_Region_Plot(cars, "Toyota", "Tacoma", 2022)


# Avg_Price_Per_Region_Plot(cars, "Ford", "Mustang", 2015) # works!
# Avg_Price_Per_Region_Plot(cars, "Ford", "Mustang", 2022) # doesn't work?
# Avg_Price_Per_Region_Plot(cars, "Ford", "Mustang", 2022) # doesn't work?
# Avg_Price_Per_Region_Plot(cars, "Toyota", "Supra", 2022) # doesn't work?
# Avg_Price_Per_Region_Plot(cars, "Ford", "Crown Victoria", 2001) # works
 
##==================================================================
##  Function to Make a Prediction based on user generated inputs  == Angie
##==================================================================

# I borrowed Matt's functions to create a KNN Regression model based on what the users inputs in the app. I want to keep the similar
# algorithm/user inputs in order to make apple-to-apple comparison between models
# We can also tweak the list of returns to include things like R2 or whatever else we want.
# This function could be used for the PREDICTIONS tab on the app.


#' Title: State_Model_Prediction_KNNReg
#'
#' @param df {dataframe}
#' @param input_state {string}
#' @param input_city {string}
#' @param input_manufacturer {string} 
#' @param input_model {string}
#' @param input_year {int}
#' @param input_odometer {int}
#' @param input_condition {string} 
#' @param input_drive {string}
#' @param input_cylinders {string}
#'
#' @return list [n of observations, model summary, predicted price + confidence intervals]
#' @export
#'
#' @examples Local_Model_Prediction(ford, "CA", "Los Angeles", "Ford", "F-150", 2015, 100000, "good", "4wd", "8")
#' 
#' 
#' 
State_Model_Prediction_KNNReg <- function(df, input_city,input_state,input_manufacturer, input_model, 
                                   input_year, input_odometer, input_condition, input_drive, input_cylinders) {
  
  
  # Create a df filtered by the user selected state, manufacturer, model, and condition.
  df <- df %>%
    filter(state == input_state,
           city == input_city,
           manufacturer == input_manufacturer,
           model == input_model,
           #condition == input_condition
    )
  
  #My thinking is using the filtered data as raw source for training/test dataset split
  #so that we can get closer to the actual price given user inputs as conditions
  #select certain columns to train data since other user
  df_select <- df %>% select(year,odometer,price)
  #drop any NA
  #df_clean <- df_select[complete.cases(df_select),]
  
  #Generate a random number that is 80% of the total number of rows in dataset.
  random <- sample(1:nrow(df_select), 0.8 * nrow(df_select))
  
  #Extract Training Set
  df_train <- df_select[random,-3]

  
  #Preprocess training data
  #df_train_pp <- preProcess(df_train,method='range')
  
  #Extract Testing Set
  #df_test <- df_select[-random,-3]

  #Extract Price Category of train dataset 
  df_target_price <- df_select[random,'price']

  
  #Extract Price Category to measure the accuracy for test dataset
  #df_test_price <- df[-random,'price']
  
  #normalize train dataset
  #fit <- predict(df_train_pp,df_train)
  
  #calculate accuracy to choose optimal k
  # predicted <- rep(0,50) # predictions: start with a vector of all zeros
  # accuracy <- rep(0,50)
    # for each row, estimate its response based on the other rows
    
  # for (i in 1:50){
  #     
  #     # data[-i] means we remove row i of the data when finding nearest neighbors...
  #     #...otherwise, it'll be its own nearest neighbor!
  #     
  #     model <- kknn(df$price~df$year+df$odometer,df[-i,],df[i,],k=X, scale = TRUE) # use scaled data
  #     
  #     # record whether the prediction is at least 0.5 (round to one) or less than 0.5 (round to zero)
  #     
  #     predicted[i] <- as.integer(fitted(model)+0.5)
  #     accuracy[i] <- sum(predicted[i] == df$price[i]) / nrow(df)# round off to 0 or 1
  #   }
  #   
  #   
  # 
  # optimal_k <- which.max(accuracy)
  

  #set seed
  set.seed(1)
  
  # Create KNNReg model
  knnreg_model <- knnreg(df_train,df_target_price,k=2)
  
  # Create new data point from user inputs
  newData <- data.frame(city=input_city,
                        state = input_state,
                        manufacturer = input_manufacturer,
                        model = input_model,
                        year = input_year,
                        odometer = input_odometer,
                        condition=input_condition,
                        cylinders = input_cylinders,
                        drive = input_drive)
                        # med_family_income = med_inc_fam,
                        # med_non_family_income = med_inc_non_fam)
  
  #select column for newData to fit KNN Regression model
  newData_select <- newData %>% select(year,odometer)

  # Create list of objects to return as list
  number_of_observations <- paste("Number of Training Observations = ", nrow(df_train))
  predictions <- predict(knnreg_model, newdata = newData_select, interval = "confidence", level = .95)
  
  
  return(list(df_select, number_of_observations, knnreg_model, predictions))
  
}

##------------------------------------
##  Test Model_Prediction Function  --
##------------------------------------

# State_Model_Prediction_KNNReg(cars, "Sacramento","CA", "Ford", "F-150", 2015, 100000, "good", "4wd", "6")


# Filter by manufacturer, model, year


##------------------------------------
##  Example Code for the Prediction and Results Tab  --
##------------------------------------


# In the predictions tab it's assumed the user will select:

# df <- ("some thaat is an example")

# user inputs are "Ford", "Mustang", and 2015 (i.e. 3 drop  downs)
# Avg_Price_Per_Region_Plot(df, "Ford", "Mustang", 2015)

# print something here that the new model gives
# visualize with plot


# Results Example/Scratch
 


# Results Example/Scratch








