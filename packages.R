#
# Example R code to install packages
# See http://cran.r-project.org/doc/manuals/R-admin.html#Installing-packages for details
#

###########################################################
# Update this line with the R packages to install:

my_packages = c("shinydashboard", "tidyverse", "shinyjs", "rio", "bigrquery", "DT", "urltools", "solvebio")
# install.packages("shinydashboard")
# install.packages("tidyverse")
# install.packages("shinyjs")
# install.packages("rio")
# install.packages("bigrquery")
# install.packages("DT")
# install.packages("urltools")
# install.packages("solvebio")

###########################################################

install_if_missing = function(p) {
      if (p %in% rownames(installed.packages()) == FALSE) {
              install.packages(p, dependencies = TRUE)
  }
  else {
          cat(paste("Skipping already installed package:", p, "\n"))
    }
}
invisible(sapply(my_packages, install_if_missing))
