library(jsonlite)
library(httr)
library(urltools)



createSolveBio<-function(dataset_id){
  before<-SolveBio_Link
  url<-paste0(before,dataset_id)
  final_url<-createLink(url,label="SolveBio")
  return(final_url)
}

createLink <- function(url,label="") {
  before<-"<a href="
  after<-paste0("target=\"_blank\" class=\"btn btn-primary\">",label,"</a>")
  full_link<-paste0(before,paste0("\"",url,"\""),after)
  return(full_link)
}

