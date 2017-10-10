library(jsonlite)
library(httr)
library(urltools)



createSolveBio<-function(dataset_id){
  url<-paste0('https://my.solvebio.com/data/', dataset_id)
  final_url<-createLink(url,label="SolveBio")
  return(final_url)
}

createLink <- function(url,label="") {
  before<-"<a href="
  after<-paste0("target=\"_blank\" class=\"btn btn-primary\">",label,"</a>")
  full_link<-paste0(before,paste0("\"",url,"\""),after)
  return(full_link)
}

