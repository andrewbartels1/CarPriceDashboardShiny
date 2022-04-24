#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.

# Define UI for application that draws a histogram
library(shiny)


## Sidebar content
sidebar <- dashboardSidebar(sidebarMenu(
  menuItem(
    "Data Exploration",
    tabName = "dashboard",
    icon = icon("tachometer-alt")
  ),
  menuItem(
    "Analysis",
    tabName = "analysis",
    icon = icon("signal", lib = "glyphicon")
  ),
  menuItem(
    "Prediction",
    tabName = "prediction",
    icon = icon("chart-bar", lib = "font-awesome")
  ),
  menuItem("Results",
           tabName = "results",
           icon = icon("list-alt"))
))
# end sidebar content

## Body content
body <- dashboardBody(tabItems(
  
  #######################
  # Data Exploration Tab
  #######################
  
  tabItem(
    tabName = "dashboard",
    fluidRow(column(
      4,
      
      box(
        title = "1. User Input",
        status = "warning",
        # width = "4",
        varSelectInput(
          inputId = "tables1",
          label = "First Table To Select",
          "Names"),
        # First dropdown bar (tables)
        
        varSelectInput(
          inputId = "columns1",
          label = "Column from Table 1 to Plot Below",
          "Names",
          multiple = FALSE
        ),
        # Second dropdown bar (columns)
        
        varSelectInput(
          inputId = "columns2",
          label = "Column from Table 2 to Plot Below",
          "Names",
          multiple = FALSE
        ),
        
        # For second quick look table
        tags$i("this drop down is just for the Table 2 Quick Look! (not plotted)"),
        varSelectInput(
          inputId = "tables2",
          label = "Second Tables To Select for Plotting",
          "Names",
          selected = c("Ford")
        ),
        
        # Debugging comment only to see drop down selection from backend
        # textOutput("selected_var1"),
        # textOutput("selected_var2"),
        # textOutput("selected_col1"),
        # textOutput("selected_col2")
      ),
      # end of first row left box,
      # Plot box #
      box(
        title = "2. Select Plot type",
        status = "warning",
        # width = "4",
        selectInput(
          inputId = "plotType",
          label = "Plot Type to Select",
          list(
            "scatter",
            "Box Plot",
            "simple linear model" 
            # probably good enough for now? agnostic plotting is pretty hard
            # "cluster",
            # "Violin",
            # "Counts",
            # "Marginal Histogram / Boxplot",
            # "Diverging bars",
            # "Density plot",
            # "Treemap",
            # "Clusters",
            # "Spatial"
          )
        )
      ),
      # Plot box #
    ), # end of first column
    column(
      8,
      # Simple stats Plot
      box(
        title = "Cars Stats Quick Look",
        status = "primary",
        width = "12",
        collapsible = TRUE,
        collapsed = FALSE,
        selectizeInput(
          inputId = "firstplots",
          label = "simple quick look plots",
          choices = c(
            "Count Manuf" = "count",
            "Avg Price per Manuf" = "avgPrice",
            "Median Price" = "medPrice"
          ),
          multiple = FALSE,
          selected = "count"
        ),
        plotOutput("manuf_bar_plot", width = "100%"),
        
      ),
      # Simple stats Plot
    ),),
    # end first fluid row!
    br(), br(), br(), br(), br(), br(), # Give me some space!
    fluidRow(
      # Simple stats Plot
      box(
        title = "Table 1 Plot",
        status = "primary",
        width = "12",
        collapsible = TRUE,
        collapsed = FALSE,
        plotOutput("plotTable1", width = "100%"),

      )
      # Simple stats Plot
    ), # End Fluid Row for scatter plotting etc.
    br(), br(), br(), br(), br(), br(), # Give me some space!
    fluidRow(
      # tags$h1("Next thing is the Count Manuf, Avg Price per manf, med price THAT WILL GO HERE!"),
      # Clicking this will increment the progress amount
      # box(width = 4, actionButton("count", "Increment prog ress"))
      # DROP DOWN BOXES #
      # DROP DOWN BOXES #
      
      # Plot 1 #
      box(
        title = "Table 1 Quick Look",
        status = "primary",
        width = "6",
        collapsible = TRUE,
        collapsed = FALSE,
        tbl1 <-
          DT::dataTableOutput("tableOutput1"),
        style = "height:450px;
                          overflow-y: scroll;overflow-x: scroll;"
      ),
      # end of Plot 1
      
      # plotting selection ideas from: http://r-statistics.co/Top50-Ggplot2-Visualizations-MasterList-R-Code.html
      # Plot 2 #
      box(
        title = "Table 2 Quick Look",
        status = "primary",
        width = "6",
        collapsible = TRUE,
        collapsed = FALSE,
        tbl2 <-
          DT::dataTableOutput("tableOutput2"),
        style = "height:500px;
                          overflow-y: scroll;overflow-x: scroll;"
      ),
      # end of Plot 2
      
      # end of fist left column
    )),
  
  #######################
  # End Data Exploration Tab
  #######################
  
  
  #######################
  # Analysis Tab
  #######################
  tabItem(tabName = "analysis",
          h2("Analysis tab contents"),
          tags$i("This tab contains some more complex visualizations for a 
                 specific Manufacturer to ensure the most value and consistent app experience."),
          fluidRow(
          # User inputs on Analysis tab
          box(
            title = "Select Manufacturer to Analyze",
            status = "primary",
            width = "12",
            collapsible = TRUE,
            collapsed = FALSE,
            selectizeInput(
              inputId = "AnalysisManf",
              label = "Select Manufacturer",
              choices = c(
                "Ford",
                "Chevrolet",
                "Toyota",
                "Honda",
                "Ram"
              ),
              multiple = FALSE,
              selected = "count"
            ),
            varSelectInput(
              inputId = "MakeModel",
              label = "Select the Make/Model",
              "Names")),
          # User inputs on Analysis tab
          
          # Pretty box plots
          box(
            title = "Per Make/Model Box",
            status = "primary",
            width = "12",
            collapsible = TRUE,
            collapsed = FALSE,
            plotOutput("model_box", width = "100%")),
          # Pretty plots
          
          # Pretty box plots
          box(
            title = "Per Make/Model Box Plots",
            status = "primary",
            collapsible = TRUE,
            collapsed = FALSE,
            width = "12",
            varSelectInput(
              inputId = "MakeYear",
              label = "Select the Year",
              "Names"),
            
            plotOutput("avgPriceRegion", width = "100%"),
            br(), br(), br(), br(), br(), br(),br(), br(), br(), br(), br(), br(),br(), br(), br(), br(), br(), br()# Give me some space!
            ),
          br(), br(), br(), br(), br(), br(),br(), br(), br(), br(), br(), br(),br(), br(), br(), br(), br(), br()# Give me some space!
                    # Pretty plots
          
          )),

  #######################
  # End Analysis Tab
  #######################
  
  
  
  #######################
  # Prediction Tab
  #######################
  tabItem(tabName = "prediction",
          h2("Car Selection and Prediction"),
          tags$i("This tab is for the user to select all the various options below to see where "), br(), 
          tags$i("the best location would be to purchase the choosen car and model based"), br(),
          tags$i("off aggregated US Average Income statistics such as median family income and other comparible cars"),
          
          
          ),
  
  #######################
  # Prediction Tab
  #######################
  
  
  tabItem(tabName = "results",
          h2("Results tab contents")) # end 4th Results tab
  
))



ui <- dashboardPage(dashboardHeader(title = "Car Price Dashbaord"),
                    sidebar,
                    body)


# Good ideas to keep 

# selectInput("state", "Choose a state:",
#             list(`East Coast` = list("NY", "NJ", "CT"),
#                  `West Coast` = list("WA", "OR", "CA"),
#                  `Midwest` = list("MN", "WI", "IA"))
# ),
# box(plotOutput("plot2", height = 250))


# infoBox(
#   "New Orders",
#   10 * 2,
#   icon = icon("credit-card"),
#   fill = TRUE
# )