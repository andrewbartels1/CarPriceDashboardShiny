#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# https://rstudio.github.io/shinydashboard/structure.html#sidebar



server <- function(input, output, session) {
  #######################
  # Setup
  #######################
  source("./global.R", local = TRUE)
  source("./Models_Matt.R")
  
  db_path <- "../database/CraigslistCarsClean.sqlite3"
  
  # Connect to the database
  conn <- dbConnect(RSQLite::SQLite(), db_path)
  
  db_path_cleaned <- "../database/Top_5_Manufacturers.sqlite3"
  
  # Connect to the database
  conn_cleaned <- dbConnect(RSQLite::SQLite(), db_path_cleaned)
  
  
  
  # yank stuff from global that's supposed to run
  table_list <- dbListTables(conn)
  
  
  #######################
  # End Setup
  #######################
  
  
  #######################
  # Data Exploration Tab
  #######################
  # CARS STATS QUICK LOOK #
  output$manuf_bar_plot <- renderPlot({
    # Count per Manf
    if (input$firstplots == "count") {
      cars1 <-
        dbGetQuery(conn, paste("SELECT manufacturer FROM cars_clean;")) # make a query to the clean table!
      cars1 %>%
        group_by(manufacturer) %>%
        summarise(count = n()) %>%
        filter(count > 1000) %>%
        ggplot(aes(x = reorder(manufacturer, (count)), y = count)) +
        theme(axis.text = element_text(size = 12)) +
        theme(plot.margin = unit(c(.5, .5, .5, .5), "cm")) +
        theme(
          axis.text = element_text(size = 12),
          axis.title = element_text(size = 14, face = "bold"),
          axis.title.x = element_text(size = 14, face = "bold"),
          axis.title.y = element_text(size = 14, face = "bold")
        ) +
        geom_bar(stat = "identity",
                 width = 0.5,
                 fill = "cadetblue3") +
        labs(x = "Manufacturer", y = "Count", title = "Count of Cars per Manufacturers") +
        ylim(c(0, 80000)) +
        coord_flip()
    }
    # Average Price per Manf Plot
    else if (input$firstplots == "avgPrice") {
      cars1 <-
        dbGetQuery(conn,
                   paste("SELECT manufacturer, price FROM cars_clean;")) # make a query to the clean table!
      
      cars1 %>%
        group_by(manufacturer) %>%
        summarise_at(vars(price), list(avg_price = mean)) %>%
        droplevels() %>%
        ggplot(aes(x = reorder(manufacturer, (avg_price)), y = avg_price), na.rm = T) +
        theme(axis.text = element_text(size = 11)) +
        theme(axis.text.x = element_text(angle = 75, vjust = 0.25)) +
        theme(plot.margin = unit(c(.5, .5, .5, .5), "cm")) +
        theme(
          axis.text = element_text(size = 12),
          axis.title = element_text(size = 14, face = "bold"),
          axis.title.x = element_text(size = 14, face = "bold"),
          axis.title.y = element_text(size = 14, face = "bold")
        ) +
        geom_text(
          aes(label = avg_price),
          position = position_dodge(0.9),
          color = "black",
          vjust = 0.5,
          hjust = -0.5,
          angle = 75
        ) +
        geom_bar(
          stat = "identity",
          width = 0.55,
          fill = "green4",
          na.rm = T
        ) +
        labs(x = "Manufacturer", y = "Price", title = "Average Price Per Manufacturers") +
        ylim(c(0, 55000))
      
    } else if (input$firstplots == "medPrice") {
      cars1 <-
        dbGetQuery(conn, paste("SELECT state, price FROM cars_clean;")) # make a query to the clean table!
      
      cars1 %>%
        group_by(state) %>%
        summarise_at(vars(price), list(avg_price = mean)) %>%
        droplevels() %>%
        ggplot(aes(x = reorder(state, (avg_price)), y = avg_price), na.rm = T) +
        theme(axis.text = element_text(size = 11)) +
        theme(axis.text.x = element_text(angle = 60, vjust = 0.25)) +
        theme(plot.margin = unit(c(.5, .5, .5, .5), "cm")) +
        theme(
          axis.text = element_text(size = 12),
          axis.title = element_text(size = 14, face = "bold"),
          axis.title.x = element_text(size = 14, face = "bold"),
          axis.title.y = element_text(size = 14, face = "bold")
        ) +
        geom_text(
          aes(label = avg_price),
          position = position_dodge(0.9),
          color = "black",
          vjust = 0.25,
          hjust = -0.3,
          angle = 75
        ) +
        geom_bar(
          stat = "identity",
          width = 0.55,
          fill = "purple3",
          na.rm = T
        ) +
        labs(x = "State", y = "Price ($ USD)", title = "Average Price Per State") +
        ylim(c(0, 55000))
    }
    
  }, height = 525) # end first "Quick Stats Quick Look" plot
  # CARS STATS QUICK LOOK #
  
  # Option Plots #
  output$plotTable1 <- renderPlot({
    # Get query data for plotting if it isn't empty (it's an issue on startup)
    if (!(is_empty(input$columns1)) & !(is_empty(input$columns2))) {
      col1 <- as.character(input$columns1)
      col2 <-  as.character(input$columns2)
      plotData <-
        dbGetQuery(
          conn,
          paste(
            "SELECT",
            input$columns1,
            ",",
            input$columns2,
            "FROM",
            input$tables1,
            ";"
          )
        )
      
      
      if (input$plotType == "scatter") {
        p = ggplot(data = plotData,
                   aes_string(x = input$columns1, y = input$columns2)) +
          geom_point(alpha = 0.5, color = 'blue3') +
          labs(x = input$columns1, y = input$columns2)
        plot(p)
        grid()
      }
      
      # Average Price per Manf Plot
      else if (input$plotType == "Box Plot") {
        meltData <- melt(plotData)
        p <- ggplot(meltData, aes(factor(variable), value))
        p + geom_boxplot() + facet_wrap(~ variable, scale = "free")
        
        
      }
      else if (input$plotType == "simple linear model") {
        if (is.character(plotData$input$columns1)) {
          plotData$input$columns1 <- as.factor(plotData$input$columns1)
        }
        if (is.character(plotData$input$columns2)) {
          plotData$input$columns2 <- as.factor(plotData$input$columns2)
        }
        # plotData <- plotData[is.na(plotData) | plotData == "Inf"] <- NA  # Replace NaN & Inf with NA
        print(plotData)
        m <-
          lm(input$columns1 ~ input$columns2,
             data = plotData,
             na.action = na.omit)
        plot(
          plotData$input$columns1 ~ plotData$input$columns2,
          main = paste("Scatter Plot:", input$columns1, "vs. ", input$columns2),
          xlab = input$columns1,
          ylab = input$columns2
        )
        abline(m)
      }
      
      
      
      
    }
    
  }, height = 525) # end first "Quick Stats Quick Look" plot
  # Option Plots #
  
  
  observe({
    updateSelectInput(session,
                      "tables1",
                      choices = table_list,
                      selected = "cars_clean")
  })
  
  observe({
    updateSelectInput(session,
                      "tables2",
                      choices = table_list,
                      selected = "cars_clean")
  })
  
  # Get the 2 Quick look tables from the input dropdowns
  tempTable2 <-
    reactive(dbGetQuery(conn, paste(
      "SELECT * FROM ", input$tables2, " LIMIT 100;"
    )))
  
  tempTable1 <-
    reactive(dbGetQuery(conn, paste(
      "SELECT * FROM ", input$tables1, " LIMIT 100;"
    )))
  
  observeEvent(input$tables1, {
    output$tableOutput1 <- renderDataTable({
      observe({
        updateSelectInput(
          session,
          "columns1",
          choices =
            names(tempTable1()[,!names(tempTable1()) %in% c("description")]),
          selected = "cylinders"
        )
      })# put the 1st 10 rows from the table selected
      observe({
        updateSelectInput(
          session,
          "columns2",
          choices =
            names(tempTable1()[,!names(tempTable1()) %in% c("description")]),
          selected = "year"
        )
      })# put the 1st 10 rows from the table selected
      # print(typeof(outputs1))
      outputs1 <-
        tempTable1()[,!names(tempTable1()) %in% c("description")]
      
    })
    
  })
  
  
  observeEvent(input$tables2, {
    # print(paste("SELECT * FROM ",input$tables2," LIMIT 10;")) # uncomment to print the tables being cast to dataTableOutput
    
    output$tableOutput2 <- renderDataTable({
      outputs2 <-
        tempTable2()[,!names(tempTable2()) %in% c("description")]
    })
    
  })
  
  #######################
  # End Data Exploration Tab
  #######################
  
  #######################
  # Analysis Tab
  #######################
  # Manf Drop down #
  observe({
    updateSelectInput(session,
                      "AnalysisManf")
  })
  # Manf Drop Down
  
  # Query temp table to select drop downs off of
  tempManfCleaned <-
    reactive(Clean_Cylinders(Clean_Drive(dbGetQuery(
      conn_cleaned, paste("SELECT * FROM cars;")
    ))))
  
  
  observeEvent(input$AnalysisManf, {
    updateSelectInput(session,
                      "MakeModel",
                      choices =
                        unique(
                          filter(tempManfCleaned(), manufacturer == input$AnalysisManf)[c("model")]
                        ),
                      selected = "Mustang")
    
  })
  
  observeEvent(input$AnalysisManf, {
    tempFilt <-
      filter(tempManfCleaned(), manufacturer == input$AnalysisManf)
    
    updateSelectInput(session,
                      "MakeYear",
                      choices =
                        unique(tempFilt[order(as.integer(tempFilt$year), decreasing = FALSE), "year"]),
                      selected = 2015)
    
  })
  
  # Pretty Box Plot
  output$model_box <-  renderPlot({
    Model_Box(tempManfCleaned(), input$AnalysisManf)
  })
  # Pretty Box Plot
  
  # Pretty Radar Plot
  output$avgPriceRegion <-  renderPlot({
    Avg_Price_Per_Region_Plot(tempManfCleaned(),
                              input$AnalysisManf,
                              input$MakeModel,
                              input$MakeYear)
  }, height = 750)
  # Pretty Radar Plot
  
  # Fuel type plot
  # Pretty Radar Plot
  output$ConditionComparison <-  renderPlot({
    Condition_Comparison(tempManfCleaned(),
                              input$AnalysisManf)
  }, height = 350)
  # Condition_Comparison(cars, "Ford")
  # Pretty Radar Plot
  output$FuelComparison <-  renderPlot({
    Fuel_Comparison(tempManfCleaned(),
                    input$AnalysisManf)
  }, height = 350)
  # Fuel_Comparison(cars, "Ford")
  
  
  #######################
  # End Analysis Tab
  #######################
  
  
  #######################
  # Prediction Tab
  #######################
  updateActionButton(
    session,
    "goButton",
    label = "Predicting Car Price!",
    icon = icon("chart-bar", lib = "font-awesome")
  )
  observeEvent(input$predState, {
    tempFilt <- filter(tempManfCleaned(), state == input$predState)
    
    updateSelectInput(session,
                      "predCity",
                      choices =
                        unique(tempFilt$city),
                      selected = "Yuba")
    
  })
  
  observeEvent(input$predState, {
    tempFilt <- filter(tempManfCleaned(), state == input$predState)
    
    updateSelectInput(session,
                      "predCity",
                      choices =
                        unique(tempFilt$city))
    
  })
  
  
  
  observeEvent(input$predManf, {
    updateSelectInput(session,
                      "predModel",
                      choices =
                        unique(filter(
                          tempManfCleaned(), manufacturer == input$predManf
                        )[c("model")]),
                      selected = "Mustang")
    
  })
  
  # observeEvent(input$predYear, {
  #   tempFilt <-
  #     filter(tempManfCleaned(), manufacturer == input$AnalysisManf)
  #
  #   # updateNumericInput(session,
  #   #                   "predYear",
  #   #                   selected = 2015)
  #
  # })
  
  
  
  
  
  counter <- reactiveValues(countervalue = 0)
  # for the model prediction output
  observeEvent(input$goButton, {
 
    # state lm
    state_pred_model_output <- National_Model_Prediction(
        tempManfCleaned(),
        input$predState,
        input$predCity,
        input$predManf,
        as.character(input$predModel),
        as.integer(input$predYear),
        as.integer(input$predMile),
        input$predCond,
        input$predDrive,
        as.integer(input$predCyl)
      )
    
    # national lm
    national_pred_model_output <- State_Model_Prediction(
      tempManfCleaned(),
      input$predState,
      input$predCity,
      input$predManf,
      as.character(input$predModel),
      as.integer(input$predYear),
      as.integer(input$predMile),
      input$predCond,
      input$predDrive,
      as.integer(input$predCyl)
    )
    # knn pred
    knn_pred_model_output <- State_Model_Prediction_KNNReg(
      tempManfCleaned(),
      input$predState,
      input$predCity,
      input$predManf,
      as.character(input$predModel),
      as.integer(input$predYear),
      as.integer(input$predMile),
      input$predCond,
      input$predDrive,
      input$predCyl
    )
    print(state_pred_model_output)
    print(national_pred_model_output)
    print(knn_pred_model_output)
    # national_pred_model_output <- National_Model_Prediction(tempManfCleaned(), "CA", "Sacramento", "Ford", "F-150", 2015, 100000, "good", "4wd", "8")
    output$verb <- renderText({
      paste(
        "You are now going to get a price prediction for",
        input$predYear,
        input$predManf,
        input$predModel,
        input$predDrive,
        input$predCyl,
        "cylinders, in ",
        input$predCity,
        ",",
        input$predState,
        " - ",
        input$predCond,
        "condition with",
        input$predMile,
        "miles in the Boxes below!"
        
      )
    })
    
    output$NationalPredictionEstimate <- renderValueBox({
      valueBox(
        round(national_pred_model_output[[3]][1]), "National Prediction Estimate", icon = icon("flag-usa", lib = "font-awesome"),
        color = "blue"
      )
    })
    output$StatePredictionEstimate <- renderValueBox({
      valueBox(
        round(state_pred_model_output[[3]][1]), "State Prediction Estimate", icon = icon("road", lib="font-awesome"),
        color = "aqua"
      )
    })
    output$KNNPredictionEstimate <- renderValueBox({
      valueBox(
        round(knn_pred_model_output[[3]][1]), "KNN Prediction Estimate", icon = icon("users", lib = "font-awesome"),
        color = "red"
      )
    })
    
  })
  
  
 

  
}
