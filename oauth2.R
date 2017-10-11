# OAuth2 methods
# Provide the URL that will be used when deployed. This is the URL from
# the browser's/end-user's perspective.
APP_URL <- Sys.getenv('APP_URL', unset='')
if (APP_URL == '') {
    stop('APP_URL is required')
}

CLIENT_ID <- Sys.getenv('CLIENT_ID', unset='')
if (CLIENT_ID == '') {
    stop('CLIENT_ID is required')
}

hasAccessToken <- function(params) {
    return(!is.null(params$access_token))
}

makeAuthorizationURL <- function() {
    # TODO: Add state support
    url <- "https://my.solvebio.com/authorize?client_id=%s&redirect_uri=%s&response_type=token"
    sprintf(url,
            utils::URLencode(CLIENT_ID, reserved = TRUE, repeated = TRUE),
            utils::URLencode(APP_URL, reserved = TRUE, repeated = TRUE)
    )
}
