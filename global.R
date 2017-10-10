library(shiny)
library(shinydashboard)
library(tidyverse)
library(shinyjs)
library(rio)
library(bigrquery)

source("./util.R", local=T)

# CLIENT_ID <- "Your app's client ID"

# TODO: Add OAuth2 support
api_key <- readLines("api_key.txt")[1]
api_host <-  readLines("api_host.txt")[1] # "https://api.solvebio.com"
solvebio::login(api_host = api_host, api_key = api_key)
vault <- solvebio::Vault.get_personal_vault()

VaultPath <- vault$full_path
SolveBio_Link <- "" ## used in createSolveBio function for url to dataset


labelMandatory <- function(label) {
  tagList(
    
    span("*", class = "mandatory_star"),
    label
  )
}

