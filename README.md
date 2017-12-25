# SolveBio R/Shiny Example

This is an example R/Shiny app that requires SolveBio login via OAuth2. The app shows datasets in the current user's personal vault. This app creates a simple Shiny app wrapped by SolveBio's "protected server", requiring users to authorize the app with their SolveBio account.

In order to run this app, it requires two environment variables:

* `CLIENT_ID`: The client ID of your SolveBio application.
* `APP_URL`: The full URL (host, port, and path if necessary) of your app once it is deployed (defaults to `http://127.0.0.1:3838`).


## Running Locally

Create a SolveBio client ID and create an `.Renviron` file in the app's directory with the following:

    CLIENT_ID=your-client-id


Install the dependencies for this app by running `init.R`:


    Rscript init.R


Now, run the Shiny app from your command-line:

    R -e "shiny::runApp(port=3838)"


Open [http://127.0.0.1:3838](http://127.0.0.1:3838) in your browser.


## Deploy to ShinyApps.io

First, [create a ShinyApps account](https://www.shinyapps.io/admin/#/signup). Follow the instructions to install `rsconnect` and log in with your credentials.

**Make sure you create your SolveBio app and set up your `.Renviron` file (see the section above) before deploying.**

To deploy, open R in the app's directory and run:

    library(rsconnect)
    deployApp()


This may take a few minutes, and should automatically open up your browser to the app URL.


## Deploy to Heroku

First, [create a Heroku account](https://heroku.com). Deploying to Heroku requires a [special buildpack](https://github.com/virtualstaticvoid/heroku-buildpack-r/tree/heroku-16) that supports R and Shiny, so you'll need to create the app using the [Heroku command line tools](https://devcenter.heroku.com/articles/heroku-cli).

The custom buildpack needs the following files:

* `Aptfile`: contains additional system dependencies
* `run.R`: signals to Heroku that this is an R Shiny app
* `init.R`: install additional R dependencies

First, create your app on Heroku:

    heroku create --buildpack http://github.com/virtualstaticvoid/heroku-buildpack-r.git#heroku-16


Once your app is created, set up the following environment variables:

* `CLIENT_ID`: Your SolveBio app's client ID
* `APP_URL`: The public URL of your app (e.g. `https://<APP NAME>.herokuapp.com`)


    # Set your SolveBio OAuth2 client ID
    heroku config:set CLIENT_ID=<your client id>

    # Set your app's public URL
    heroku config:set APP_URL=https://<your app>.herokuapp.com


Finally, deploy the app:

    git push heroku master


**NOTE: The first deploy can take upwards of 20 minutes to complete.**


## Using Docker (not recommended)

See the `docker/` directory for an example of how to run your Shiny app with Docker.
