FROM davecap/rshiny-base:latest

# RUN mkdir -p /srv/shiny-server/app/packrat/lib-R
# RUN mkdir -p /srv/shiny-server/app/packrat/lib-ext
# RUN R -e "setwd('/srv/shiny-server/app'); install.packages('packrat'); packrat::restore()"

# Install dependencies
WORKDIR /srv/shiny-server/app/
RUN Rscript init.R
