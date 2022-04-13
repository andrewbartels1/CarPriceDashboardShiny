#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.

# Define UI for application that draws a histogram
library(shiny)
# library(shinythemes)

ui <- dashboardPage(
  dashboardHeader(title = "Car Price Dashbaord"),
  ## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Widgets", tabName = "widgets", icon = icon("th"))
    )
  ), # end sidebar content
  
  ## Body content
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "dashboard",
              fluidRow(
                box(plotOutput("plot1", height = 250)),
                
                box(
                  title = "Controls",
                  sliderInput("slider", "Number of observations:", 1, 100, 50)
                )
              )
      ),
      
      # Second tab content
      tabItem(tabName = "widgets",
              h2("Widgets tab content")
      )
    )
  )
)

# global_data <- reactiveVal(NULL)
# 
# ui <- fluidPage(
#   # import the theme from the static css stylesheet to make life easy
#   tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.css")),
#   
#   # start navbar
#   navbarPage(
#     "WHERE DID ALL THE CHEAP CARS GO?!",
#     tabPanel(
#       "Navbar 1",
#       sidebarPanel(
#         tags$h3("Input:"),
#           sliderInput(inputId = "bins","Number of bins:",min = 1,max = 50, value = 5),
#           numericInput("nrows", "Enter the number of rows to display:", 5),
#           actionButton(inputId = "queryButton",label = "Query", icon = icon("fas fa-sync"), verify_fa = FALSE)
#         
#       ),
#       img(
#         height = "50%",
#         width = "50%",
#         src = "logo.png"
#       ),
#       # sidebarPanel
#       mainPanel(h1("Exploring the Dataset"),
#                 h4("Table Query"),
#                 plotOutput("hist"),
#                 tableOutput("tbl"),
#                 
#                 verbatimTextOutput("txtout")) # mainPanel
#       
#     ),
#     # Navbar 1, tabPanel
#     tabPanel("Navbar 2", "This panel is intentionally left blank"),
#     tabPanel("Navbar 3", "This panel is intentionally left blank")
#     
#   )# navbarPage
# ) # fluidPage
#
#
#   # Header with image
#
#

#   sliderInput(inputId = "something","Number of bins:",min = 1,max = 50, value = 30),
#   numericInput("nrows", "Enter the number of rows to display:", 5),
#   actionButton(inputId = "queryButton",label = "Query"),
#
#   # Show a plot of the generated distribution
#
#   tabsetPanel(
#     tabPanel("Plot", plotOutput("plot")),
#     tabPanel("Data", verbatimTextOutput("summary"))
#   )
# )
# https://shiny.rstudio.com/app-stories/weather-lookup-bslib.html