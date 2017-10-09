require(shiny)
# Requires:
# install.packages("shinydashboard")
# install.packages("tidyverse")
# install.packages("shinyjs")
# install.packages("rio")
# install.packages("bigrquery")
# install.packages("DT")
# install.packages("urltools")
# install.packages("solvebio")

options(shiny.maxRequestSize=30*1024^2) # increase max file upload

shinyServer(function(input, output) {
   
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
  
  
  
  # Save data to solvebio --------------------------------------------------- 
  observeEvent(input$Go,{
    withProgress(message="creating dataset in Solvebio", value =0.5,{
    
    
    my_original_name=input$file2$name
    
    my_data<-getData()
    d <- 1:nrow(my_data)
    chunks <- split(d, ceiling(seq_along(d)/100000))
    x<-list()
    y<-list()
    my_json_name<-list()
    file_pattern<-paste0(my_original_name,"_")
    
    for(i in seq_along(chunks)){
      cat(i)
      x[i]<-bigrquery:::export_json(my_data[chunks[[i]],])
      y[i]<-gsub("\n$","",x[[i]])
      my_json_name[i]<-tempfile(pattern=file_pattern,fileext = ".json.gz")
      write_lines(y[[i]],path=my_json_name[[i]])
    }
    
    files<-list.files(tempdir(),pattern=file_pattern)
    
    vault = Vault.get_by_full_path(VaultPath)
    
    ## set up dataset
    datasetName<-paste0("/",input$datasetName)
    
    dataset_full_path = paste(vault$name, datasetName, sep=":")
    
    my_pubmed=input$pmid
    my_url=input$url
    my_description=input$description
    dataset <- Dataset.get_or_create_by_full_path(dataset_full_path,
                                                  description=my_description,
                                                  metadata=list(source="SharedDatasetApp",
                                                                url=my_url,
                                                                pubmed_id=my_pubmed,
                                                                original_file_name=my_original_name
                                                  )
                                                  )
    
    
    ###loop over files
    
    
    for(i in seq_along(files)){
      my_filename<-paste0(tempdir(),"/",files[i])
      object <- Object.upload_file(my_filename, vault$id, '/jsonl_files/')
      DatasetImport.create(dataset_id = dataset$id, 
                           commit_mode = 'append', 
                           object_id = object$id)
      
    }
    
    
    })
    
    showModal(modalDialog(
      title = "Dataset loaded",
      "Depending on the size of the file, it might take a few minutes for it to register",
      easyClose = TRUE,
      footer = NULL
    ))
  })
  
  # Browse ------------------------------------------------------------------
  retrieveDatasets<-reactive({
  
    vault = Vault.get_by_full_path(VaultPath)
    datasets<-Vault.datasets(vault$id)
    shiny::validate(
      need(nrow(datasets)>0,"No datasets saved")
    )
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
    dataset_name<-data[s,1]
    y<-Dataset.query(dataset_name)
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
  
})








