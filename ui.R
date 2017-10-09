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
              dashboardBody(useShinyjs(),
                            tabItems(

                                     browsePage(),
                                     loadPage()
                                     )
                            )
              )
