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
      icon = icon("dashboard")
    ),
    menuItem("Analysis", tabName = "Analysis", icon = icon("signal", lib = "glyphicon")),
    menuItem("Prediction", tabName = "Prediction", icon = icon("bar-chart-o"),verify_fa = FALSE),
    menuItem("Results", tabName = "Results", icon = icon("search", lib = "glyphicon"),verify_fa = FALSE)
  )),
  # end sidebar content
  
  ## Body content
  dashboardBody(tabItems(
    # First tab content
    tabItem(tabName = "dashboard",
            fluidRow(
              box(
                title = "1. User Input",
                status = "warning",
                varSelectInput(inputId = "tables1",
                               label = "First Table To Select",
                               "Names"),
                textOutput("selected_var"),
                varSelectInput(inputId = "columns1",
                               label = "Column(s) from Table 1 to Plot Below",
                               "Names", multiple = T),
                varSelectInput(inputId = "tables2",
                               label = "Second Tables To Select for Plotting",
                               "Names"),
                varSelectInput(inputId = "columns2",
                               label = "Column(s) from Table 2 to Plot Below",
                               "Names", multiple = T),
                textOutput("selected_var1"),
                textOutput("selected_var2"),
                textOutput("selected_col1"),
                textOutput("selected_col2")), # end of first row left box,
              
              box( title = "Table 1 Quick Look", status = "primary", height =
                     "595",width = "6",solidHeader = T,
                   column(width = 12,
                          tbl1 <-  DT::dataTableOutput("tableOutput1"),style = "height:450px;
                          overflow-y: scroll;overflow-x: scroll;"
                   )), # end of Plot 1
              
              # plotting selection ideas from: http://r-statistics.co/Top50-Ggplot2-Visualizations-MasterList-R-Code.html
              box(title = "Show the Column Plot here",
                  varSelectInput(inputId = "plotType",
                                 label = "Plot Type to Select", c("scatter", "line", "cluster", "Violin", 
                                                                  "Counts", "Marginal Histogram / Boxplot",
                                                                  "Diverging bars","Density plot", "Box Plot",
                                                                  "Treemap","Clusters", "Spatial")),),
              
              box( title = "Table 2 Quick Look", status = "primary", height =
                     "595",width = "6",solidHeader = T,
                   column(width = 12,
                          tbl2 <- DT::dataTableOutput("tableOutput2"),style = "height:500px;
                          overflow-y: scroll;overflow-x: scroll;"
                   )
              ), # end of Plot 2
              
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
              infoBox("New Orders", 10 * 2, icon = icon("credit-card"), fill = TRUE),
              infoBoxOutput("progressBox2"),
              infoBoxOutput("approvalBox2")
            ),
            
            fluidRow(
              # Clicking this will increment the progress amount
              box(width = 4, actionButton("count", "Increment progress"))
            ),
            
            # Second tab content
            tabItem(tabName = "Analysis",
                    h2("Analysis tab content"))
    )))
)
