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


## Deploy to shinyapps.io

First, [create a shinyapps account](https://www.shinyapps.io/admin/#/signup). Follow the instructions to install `rsconnect` and log in with your credentials.

**Make sure you create your SolveBio app and set up your `.Renviron` file (see the section above) before deploying.**

To deploy, open R in the app's directory and run:

    library(rsconnect)
    deployApp()


This may take a few minutes, and should automatically open up your browser to the app URL.
