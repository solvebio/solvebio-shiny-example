require(shiny)
library(shinydashboard)
library(tidyverse)
library(shinyjs)
library(rio)
library(bigrquery)
require(solvebio)

source("./util.R", local=T)

labelMandatory <- function(label) {
  tagList(
    
    span("*", class = "mandatory_star"),
    label
  )
}

# Increase max file upload
options(shiny.maxRequestSize=30*1024^2) 


# OAuth2 methods
# Provide the URL that will be used when deployed. This is the URL from
# the browser's/end-user's perspective.
APP_URL <- Sys.getenv('APP_URL', unset='')
if (APP_URL == '') {
    stop('APP_URL is required')
}

CLIENT_ID <- Sys.getenv('CLIENT_ID', unset='')
if (CLIENT_ID == '') {
    stop('CLIENT_ID is required')
}

hasAccessToken <- function(params) {
    return(!is.null(params$access_token))
}

makeAuthorizationURL <- function() {
    # TODO: Add state support
    url <- "https://my.solvebio.com/authorize?client_id=%s&redirect_uri=%s&response_type=token"
    sprintf(url,
            utils::URLencode(CLIENT_ID, reserved = TRUE, repeated = TRUE),
            utils::URLencode(APP_URL, reserved = TRUE, repeated = TRUE)
            )
}

#
# Server
#

server <- function(input, output, session) {
    # Handle OAuth2
    loginModal <- function() {
        onclick <- sprintf("window.location = '%s'", makeAuthorizationURL())
        modalDialog(
                    span('Please log in with SolveBio before proceeding.'),
                    footer = tagList(
                                     shiny::actionButton(inputId='login-button',
                                                         label="Log in with SolveBio", 
                                                         onclick=onclick)
                                     ),
                    easyClose = FALSE
                    )
    }

    app <- function(access_token) {
        env <- solvebio::createEnv(token=access_token, token_type="Bearer")
        # TODO: Show current user
        # user <- solvebio::User.retrieve(env=env)

        getFile<-reactive({
            inFile <- input$file2
            shiny::validate(
                            need(!is.null(inFile),"Upload csv file")
                            )

            input_file_format <- tools::file_ext(inFile$name)
            new_file_name<-paste0(inFile$datapath,".",input_file_format)
            file.rename(inFile$datapath,new_file_name)
            return(new_file_name)
        })

        getData<-reactive({
            data_file<-import(getFile())
            data_file<-as_data_frame(data_file)

        })
      
        output$file_summary = DT::renderDataTable({
            data<-getData()
            DT::datatable(data, selection = 'single', filter='top')
        })

        # Save data to SolveBio
        observeEvent(input$Go,
                     {
                         withProgress(message="creating dataset in Solvebio", value=0.5,
                                      {
                                          my_original_name=input$file2$name
                                          my_data<-getData()
                                          d <- 1:nrow(my_data)
                                          chunks <- split(d, ceiling(seq_along(d)/100000))
                                          x <- list()
                                          y <- list()
                                          my_json_name <- list()
                                          file_pattern <- paste0(my_original_name,"_")

                                          for(i in seq_along(chunks)){
                                              # cat(i)
                                              x[i]<-bigrquery:::export_json(my_data[chunks[[i]],])
                                              y[i]<-gsub("\n$","",x[[i]])
                                              my_json_name[i]<-tempfile(pattern=file_pattern,fileext = ".json.gz")
                                              write_lines(y[[i]],path=my_json_name[[i]])
                                          }

                                          files<-list.files(tempdir(),pattern=file_pattern)

                                          # vault = Vault.get_by_full_path(VaultPath, env=env)
                                          vault = Vault.get_personal_vault(env=env)

                                          ## set up dataset
                                          datasetName<-paste0("/",input$datasetName)

                                          dataset_full_path = paste(vault$full_path, datasetName, sep=":")

                                          my_pubmed=input$pmid
                                          my_url=input$url
                                          my_description=input$description
                                          dataset <- Dataset.get_or_create_by_full_path(dataset_full_path,
                                                                                        description=my_description,
                                                                                        metadata=list(source="SharedDatasetApp",
                                                                                                      url=my_url,
                                                                                                      pubmed_id=my_pubmed,
                                                                                                      original_file_name=my_original_name
                                                                                                      ),
                                                                                        env=env
                                                                                        )


                                          for(i in seq_along(files)){
                                              my_filename<-paste0(tempdir(),"/",files[i])
                                              object <- Object.upload_file(my_filename, vault$id, '/jsonl_files/')
                                              DatasetImport.create(dataset_id = dataset$id, 
                                                                   commit_mode = 'append', 
                                                                   object_id = object$id,
                                                                   env=env)

                                          }

                                      }
                         )

                         showModal(modalDialog(
                                               title = "Dataset loaded",
                                               "Depending on the size of the file, it might take a few minutes for it to register",
                                               easyClose = TRUE,
                                               footer = NULL
                                               )
                         )
                     }
        ) # observeEvent()

        # Browse
        retrieveDatasets <- reactive({
            # vault = Vault.get_by_full_path(VaultPath, env=env)
            vault = Vault.get_personal_vault(env=env)
            datasets<-Vault.datasets(vault$id, env=env)
            shiny::validate(need(nrow(datasets)>0,"No datasets saved"))
            return(datasets)
        })

        output$datasets_summary = DT::renderDataTable({
            data<-retrieveDatasets()
            data<-data[,c(3,13,7,5)] ## select only dataset_id filename description dataset_documents_count
            data<-data%>%
                mutate(solvebio_url=createSolveBio(data$dataset_id))%>%
                select(filename,description,solvebio_url,dataset_documents_count)

            DT::datatable(data,   
                          selection = 'single', 
                          escape=FALSE,
                          filter='none',
                          options = list(scrollX = TRUE)
                          )

        })

        retrieveData<-reactive({
            data<-retrieveDatasets()
            data<-data[,c(3,13,7,5)] ## select only dataset_id filename description dataset_documents_count
            s = input$datasets_summary_rows_selected
            shiny::validate(
                            need(!is.null(input$datasets_summary_rows_selected),"Select dataset")
                            )
            dataset_id <- data[s,1]
            y<-Dataset.query(dataset_id, env=env)
        })

        output$datasets_details = DT::renderDataTable({
            data<-retrieveData()
            DT::datatable(data,  
                          selection = 'single', 
                          escape=FALSE,
                          filter='top',
                          options = list(scrollX = TRUE)
                          )

        })
    } # app()

    observeEvent(session$clientData$url_hash, {
                     hash <- gsub(pattern = "#", replacement = "", x = session$clientData$url_hash)
                     hash <- parseQueryString(hash)
                     if (!hasAccessToken(hash)) {
                         session$userData$access_token <- NULL
                         showModal(loginModal())
                     }
                     else {
                         # access_token, token_type, expires_in, scope
                         session$userData$access_token = hash$access_token
                         shiny::updateQueryString("#", mode="replace", session)
                         app(session$userData$access_token)
                     }
            }, once = TRUE)
}


# 
# UI
#

loadPage <- function(){
    tabItem(tabName = "load",

            fluidPage(
                      fluidRow(
                               box(width=12,

                                   box(width=4,
                                       fileInput('file2', 'Upload dataset to share',
                                                 accept = c(
                                                            'text/csv',
                                                            'text/comma-separated-values',
                                                            'text/tab-separated-values',
                                                            'text/plain',
                                                            '.csv',
                                                            '.tsv'

                                                            )
                                                 )),
                                   box(width = 8,title = "Dataset contents",
                                       DT::dataTableOutput('file_summary'))
                                   )
                               ),

                      fluidRow(
                               box(width=12,title = "Step 2: Enter information about dataset",
                                   tabsetPanel(id="metadata_input",

                                               tabPanel("Dataset details", 

                                                        box(width=12,
                                                            box(
                                                                textInput(width='100%',"datasetName","Data Set Name",placeholder="no spaces"),
                                                                textAreaInput(width='100%',"description","Data Set description",""),
                                                                textInput(width='50%','pmid',"Pubmed ID"),
                                                                textInput(width='100%','url',"URL"),
                                                                selectizeInput(width='100%',"tags","Tag dataset",choices = c('genes','compounds'),
                                                                               multiple = TRUE,
                                                                               options = list(create = TRUE))
                                                                ),
                                                            actionButton("Go", "Step 3: Save to SolveBio")
                                                            )
                                                        )
                                               )

                                   )
                               )
                      )
            )
}

browsePage <- function(){
    tabItem(tabName = "browse",

            fluidPage(
                      fluidRow(
                               box(width = 12,title = "DataSets loaded into SolveBio via webpage ",
                                   DT::dataTableOutput('datasets_summary')
                                   )
                               ),
                      fluidRow(
                               box(width = 12,title = "Sample of dataset ",
                                   DT::dataTableOutput('datasets_details')
                                   )
                               )
                      )
            )
}

ui <- dashboardPage(
                    dashboardHeader(title="SolveBio"),
                    dashboardSidebar(
                                     sidebarMenu(id = "tabs",

                                                 menuItem("Browse datasets", tabName = "browse", icon = icon("upload")),
                                                 menuItem("Load file", tabName = "load", icon = icon("upload"))
                                                 )
                                     ),
                    dashboardBody(
                                  useShinyjs(),
                                  tabItems(

                                           browsePage(),
                                           loadPage()
                                           )
                                  )
                    )



shinyApp(ui, server)
