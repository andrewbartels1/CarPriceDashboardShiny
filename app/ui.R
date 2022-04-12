#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# Define UI for application that draws a histogram
library(shiny)
library(shinythemes)

global_data <- reactiveVal(NULL)

ui <- fluidPage(theme = shinytheme("cerulean"),
  
  
  # tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.css")),
  navbarPage(
    "WHERE DID ALL THE CHEAP CARS GO?!",
    tabPanel(
      "Navbar 1",
      sidebarPanel(
        tags$h3("Input:"),
          sliderInput(inputId = "bins","Number of bins:",min = 1,max = 50, value = 5),
          numericInput("nrows", "Enter the number of rows to display:", 5),
          actionButton(inputId = "queryButton",label = "Query", icon = icon("fas fa-sync"), verify_fa = FALSE)
        
      ),
      img(
        height = "50%",
        width = "50%",
        src = "logo.png"
      ),
      # sidebarPanel
      mainPanel(h1("Exploring the Dataset"),
                h4("Table Query"),
                plotOutput("hist"),
                tableOutput("tbl"),
                
                verbatimTextOutput("txtout")) # mainPanel
      
    ),
    # Navbar 1, tabPanel
    tabPanel("Navbar 2", "This panel is intentionally left blank"),
    tabPanel("Navbar 3", "This panel is intentionally left blank")
    
  )# navbarPage
) # fluidPage
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