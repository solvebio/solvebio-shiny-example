# RShiny SolveBio Boilerplate

Deployment to Dokku requires a Dockerfile:

    # Install rize
    install.packages("devtools")
    library(devtools)
    devtools::install_github('cole-brokamp/rize')

    # Run rize
    rize::shiny_dockerize()


We can also use a custom Heroku buildpack with Dokku, although heroku-16 does not seem to work yet with the herokuish package. For example, this buildpack should work: https://github.com/virtualstaticvoid/heroku-buildpack-r/tree/heroku-16

Deploying a Dokku app with this buildpack results in the following error:

    ERROR: This version of the buildpack is intended for use with the 'heroku-16' stack


Although this issue shows that some people have gotten it to work somehow: https://github.com/gliderlabs/herokuish/issues/256



# Requirements

Use Packrat to install requirements if running locally:

    install.packages("packrat")
    packrat::restore()


Or install the dependencies manually:

    install.packages("shinydashboard")
    install.packages("tidyverse")
    install.packages("shinyjs")
    install.packages("rio")
    install.packages("bigrquery")
    install.packages("DT")
    install.packages("urltools")
    install.packages("solvebio")


# Run

To run locally:

    R -e "shiny::runApp('./')"
