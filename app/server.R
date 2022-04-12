#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
server <- function(input, output) {
  
  
  # Open up a connection to the database, probably put this somewhere else in the future
  con <- dbConnect(RSQLite::SQLite(), ":memory:")
  dbWriteTable(con, "iris", iris)
  dbListTables(con)
  

  iris_preview <- reactiveVal(data.frame())
  queryString <- sprintf("select * from iris limit %s", 5)
  iris_preview(dbGetQuery(con, queryString))
               
  observeEvent(input$queryButton, {
    queryString <- sprintf("select * from iris limit %s", input$nrows)
    iris_preview(dbGetQuery(con, queryString))
  })
  
  output$tbl <- renderTable({
    iris_preview()
  })
  
  output$hist <- renderPlot({
    # Require that the data is there
    req(iris_preview())
    
    title <- "Sepal.Length from Iris"
    # generate bins based on input$bins from ui.R
    bins <- seq(min(iris_preview()$Sepal.Length), max(iris_preview()$Sepal.Length), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    
    hist(iris_preview()$Sepal.Length, breaks=bins, col = 'darkgray', border = 'white', main= title)
  }) # end of hist render
  
  
}
