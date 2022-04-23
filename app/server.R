#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# https://rstudio.github.io/shinydashboard/structure.html#sidebar



server <- function(input, output, session) {
  source("./global.R", local = TRUE)
  source("./Plots_Angie.R")
  source("./Models_Matt.R")
  
  db_path <- "../CraigslistCarsClean.sqlite3"
  
  # Connect to the database
  conn <- dbConnect(RSQLite::SQLite(), db_path)
  
  # yank stuff from global that's supposed to run
  table_list <- dbListTables(conn)
  
  # print(cars)
  #
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
  
  # Table 1 Plotting #
  output$plotTable1 <- renderPlot({
    
    # Select the 2 rows to plot from the table selected
    plotTable <- dbGetQuery(conn, paste(
      "SELECT", input$columns1, " ", input$columns2,  " FROM", input$tables, " ;"
    ))
    
    # Then per the drop down bar plot the type
    if (input$plotType == "scatter") {
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
    else if (input$plotType == "Counts") {
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
      
    } 
    else if (input$plotType == "medPrice") {
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
  # Table 1 Plotting #
  
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
            names(tempTable1()[, !names(tempTable1()) %in% c("description")]),
          selected = "state"
        )
      })# put the 1st 10 rows from the table selected
      observe({
        updateSelectInput(
          session,
          "columns2",
          choices =
            names(tempTable1()[, !names(tempTable1()) %in% c("description")]),
          selected = "year"
        )
      })# put the 1st 10 rows from the table selected
      # print(typeof(outputs1))
      outputs1 <-
        tempTable1()[, !names(tempTable1()) %in% c("description")]
       
    })
    
  })
  
  
  observeEvent(input$tables2, {
    # print(paste("SELECT * FROM ",input$tables2," LIMIT 10;")) # uncomment to print the tables being cast to dataTableOutput
    
    output$tableOutput2 <- renderDataTable({
      # print(names(tempTable))
      
      
      
      outputs2 <-
        tempTable2()[, !names(tempTable2()) %in% c("description")]
    })
    
  })
  
}
