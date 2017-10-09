library(shiny)
library(shinydashboard)
library(tidyverse)
library(shinyjs)
library(rio)
library(bigrquery)

source("./util.R", local=T)

VaultPath <- "solvebio:user-1" ## Need to add vaultPath
SolveBio_Link <- "" ## used in createSolveBio function for url to dataset

labelMandatory <- function(label) {
  tagList(
    
    span("*", class = "mandatory_star"),
    label
  )
}

