require(shiny)
library(shinydashboard)
library(tidyverse)
library(shinyjs)
library(rio)
library(bigrquery)
require(solvebio)

source("./util.R", local=TRUE)
source("./oauth2.R", local=TRUE)

# Increase max file upload
options(shiny.maxRequestSize=30*1024^2) 

