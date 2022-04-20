#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.

# Define UI for application that draws a histogram
library(shiny)

ui <- dashboardPage(
  dashboardHeader(title = "Car Price Dashbaord"),
  ## Sidebar content
  dashboardSidebar(sidebarMenu(
    menuItem(
      "Data Exploration",
      tabName = "dashboard",
      icon = icon("tachometer-alt")
    ),
    menuItem(
      "Analysis",
      tabName = "Analysis",
      icon = icon("signal", lib = "glyphicon")
    ),
    menuItem(
      "Prediction",
      tabName = "Prediction",
      icon = icon("chart-bar", lib = "font-awesome"),
      verify_fa = FALSE
    ),
    menuItem(
      "Results",
      tabName = "Results",
      icon = icon("list-alt"),
      verify_fa = FALSE
    )
  )),
  # end sidebar content
  
  ## Body content
  dashboardBody(tabItems(
    # First tab content
    tabItem(
      tabName = "dashboard",
      fluidRow(
        box(
          title = "1. User Input",
          status = "warning",
          varSelectInput(
            inputId = "tables1",
            label = "First Table To Select",
            "Names",
            selected = as.character("Ford")
          ),
          # First dropdown bar (tables)
          
          
          
          varSelectInput(
            inputId = "columns1",
            label = "Column(s) from Table 1 to Plot Below",
            "Names",
            multiple = TRUE,
            selected = list("region")
          ),
          # Second dropdown bar (columns)
          
          varSelectInput(
            inputId = "tables2",
            label = "Second Tables To Select for Plotting",
            "Names",
            selected = as.character("Ford")
          ),
          
          varSelectInput(
            inputId = "columns2",
            label = "Column(s) from Table 2 to Plot Below",
            "Names",
            multiple = TRUE,
            selected = as.character("year")
          ),
          # Debugging comment only to see drop down selection from backend          
          # textOutput("selected_var1"),
          # textOutput("selected_var2"),
          # textOutput("selected_col1"),
          # textOutput("selected_col2")
        ),
        
        # Plot box #
        box(
          title = "2. Select Plot type",
          selectInput(
            inputId = "plotType",
            label = "Plot Type to Select",
            list(
              "scatter",
              "line",
              "cluster",
              "Violin",
              "Counts",
              "Marginal Histogram / Boxplot",
              "Diverging bars",
              "Density plot",
              "Box Plot",
              "Treemap",
              "Clusters",
              "Spatial"
            )
          )
        ),
        # Plot box #
        
        # end of first row left box,
      ),
      fluidRow(
        # DROP DOWN BOXES #
        box(
          title = "Table 1 Quick Look",
          status = "primary",
          width = "6",
          collapsible = TRUE,
          collapsed = TRUE,
          tbl1 <-
            DT::dataTableOutput("tableOutput1"),
          style = "height:450px;
                          overflow-y: scroll;overflow-x: scroll;"
        ),
        # end of Plot 1
        
        # plotting selection ideas from: http://r-statistics.co/Top50-Ggplot2-Visualizations-MasterList-R-Code.html
        box(
          title = "Table 2 Quick Look",
          status = "primary",
          width = "6",
          collapsible = TRUE,
          collapsed = TRUE,
          tbl2 <-
            DT::dataTableOutput("tableOutput2"),
          style = "height:500px;
                          overflow-y: scroll;overflow-x: scroll;"
        ),
        # end of Plot 2
        
        tags$h1("Next thing is the Count Manuf, Avg Price per manf, med price THAT WILL GO HERE!"),
        # Clicking this will increment the progress amount
        # box(width = 4, actionButton("count", "Increment progress"))
        # DROP DOWN BOXES #
        
        # end of fist left column
        
      ),
      
      # selectInput("state", "Choose a state:",
      #             list(`East Coast` = list("NY", "NJ", "CT"),
      #                  `West Coast` = list("WA", "OR", "CA"),
      #                  `Midwest` = list("MN", "WI", "IA"))
      # ),
      # box(plotOutput("plot2", height = 250))
      
      
      # A static infoBox
      infoBox("New Orders", 10 * 2, icon = icon("credit-card")),
      # Dynamic infoBoxes
      infoBoxOutput("progressBox"),
      infoBoxOutput("approvalBox"),
      
      
      # infoBoxes with fill=TRUE
      fluidRow(
        infoBox(
          "New Orders",
          10 * 2,
          icon = icon("credit-card"),
          fill = TRUE
        ),
        infoBoxOutput("progressBox2"),
      ),
      
      
      
      # Second tab content
      tabItem(tabName = "Analysis",
              h2("Analysis tab content"))
    )
  ))
)
