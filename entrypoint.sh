#!/bin/bash

# echo "Installing dependencies..."
# Rscript init.R

# # Install custom version of solvebio-r
# R -e "install.packages('githubinstall', repos='http://cran.us.r-project.org'); library(githubinstall); gh_install_packages('solvebio/solvebio-r', ref = 'custom-envs')"

echo "Setting up environment variables..."
TS=`date`
cat >config.R <<EOL
# DO NOT EDIT THIS FILE MANUALLY
# The contents of this file are set at runtime by
# shiny-server.sh when Docker runs.
# Generated ${TS}
APP_URL <- "${APP_URL:-}"
CLIENT_ID <- "${CLIENT_ID:-}"
EOL

echo "Running Shiny Server..."
exec "$@"
