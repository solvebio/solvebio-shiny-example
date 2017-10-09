FROM davecap/rshiny-base:latest

RUN mkdir -p /srv/shiny-server/app/packrat/lib-R
RUN mkdir -p /srv/shiny-server/app/packrat/lib-ext
# Install dependencies
RUN R -e "setwd('/srv/shiny-server/app'); packrat::restore()"
