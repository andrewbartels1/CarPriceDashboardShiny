# Script where everything is applied to the scope of ALL files (server and UI)
if (!require("pacman")) install.packages("pacman")
pacman::p_load("DBI",
               "RSQLite",
               "shiny",
               "shinythemes",
               "shinyWidgets",
               "DT",
               "forecast",
               "ggplot2",
               "plotly",
               "maps",
               "shinydashboard",
               "stringr",
               "kknn",
               "randomForest",
               "reshape",
               install = TRUE, update = getOption("pac_update"))

# Put deps here!
library(DBI)
library(RSQLite)
library(shiny)
library(shinyWidgets)
library(shinyalert)
library(DT)
library(forecast)
library(ggplot2)
library(plotly)
library(maps)
library(bslib)
library(shinydashboard)
library(stringr)
library(kknn)
library(randomForest)
library(reshape)
