#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# https://rstudio.github.io/shinydashboard/structure.html#sidebar



server <- function(input, output, session) {
  source("./global.R", local=TRUE)
  
  db_path <- "../CraigslistCarsClean.sqlite3"
  
  # Connect to the database
  conn <- dbConnect(RSQLite::SQLite(), db_path)
  
  # on.exit(dbDisconnect(conn))
  # yank stuff from global that's supposed to run
  table_list <- dbListTables(conn)
  
  #create a reactive object with a NULL starting value
  listofrows <- reactiveValues()
  
  
  ##===========================================
  ##  create 2 tables & columns and input from
  ##  dropdowns to a scatter plot? or something
  ##===========================================
  
  observe({
    updateSelectInput(session, "tables1", choices = table_list, selected="cars_clean")
  })
  observe({
    updateSelectInput(session, "tables2", choices = table_list, selected="cars_clean")
  })

  
  observeEvent(input$tables1, {
    
    
    output$tableOutput1 <-renderDataTable({
      
      tempTable <- dbGetQuery(conn,paste("SELECT * FROM ",input$tables1," LIMIT 100;"))
      
      observe({updateSelectInput(session, "columns1", choices =
                                 names(tempTable[, !names(tempTable) %in% c("description")]),
                                 selected="state")})# put the 1st 10 rows from the table selected
      # print(typeof(outputs1))
      outputs1 <- tempTable[, !names(tempTable) %in% c("description")]      
      
    })
    
  })
  
  
  observeEvent(input$tables2, {
    # print(paste("SELECT * FROM ",input$tables2," LIMIT 10;")) # uncomment to print the tables being cast to dataTableOutput

    output$tableOutput2 <-renderDataTable({

      tempTable <- dbGetQuery(conn,paste("SELECT * FROM ",input$tables2," LIMIT 100;"))
      # print(names(tempTable))

      
      observe({updateSelectInput(session, "columns2", choices =
                                   names(tempTable[, !names(tempTable) %in% c("description")]),
                                 selected = "year")})# put the 1st 10 rows from the table selected
      outputs1 <- tempTable[, !names(tempTable) %in% c("description")]
    })

  })


  output$selected_var1 <- renderText({
    paste("You have selected Table 1: ", input$tables1 )
  })
  output$selected_var2 <- renderText({
    paste("You have selected Table 2: ", input$tables2 )
  })
  output$selected_col1 <- renderText({
    paste("You have selected Column(s) for Table 1: \n\n", input$columns1) 
  })
  output$selected_col2 <- renderText({
    paste("You have selected Column(s) for Table 2: \n\n", input$columns2) 
  })


  # Progress boxes at bottom of Data Explorer tab
  output$progressBox <- renderInfoBox({
    infoBox(
      "Progress", paste0(25 + input$count, "%"), icon = icon("list"),
      color = "purple"
    )
  })
  output$approvalBox <- renderInfoBox({
    infoBox(
      "Approval", "80%", icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow"
    )
  })

  # Same as above, but with fill=TRUE
  output$progressBox2 <- renderInfoBox({
    infoBox(
      "Progress", paste0(25 + input$count, "%"), icon = icon("list"),
      color = "purple", fill = TRUE
    )
  })
  output$approvalBox2 <- renderInfoBox({
    infoBox(
      "Approval", "80%", icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow", fill = TRUE
    )
  })

  
}

