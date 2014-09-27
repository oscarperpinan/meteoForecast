## Functions to interact with the internal environment

getMFOption <- function(name = NULL){
    mfOptions <- get('mfOptions', envir = .mfEnv)
    if (is.null(name)) return(mfOptions)
    else return(mfOptions[[name]])
}

setMFOption <- function(name, value){
    mfOptions <- get('mfOptions', envir = .mfEnv)
    mfOptions[[name]] <- value
    assign('mfOptions', mfOptions, envir = .mfEnv)
    message('Option ', name, ' changed to ', value)
}

## Check if `service` is correct
matchService <- function(service){
    services <- get('services', envir = .mfEnv)
    service <- match.arg(service, services)
    service
}

## Get or Set default service
mfService <- function(service = NULL){
    if (is.null(service)) getMFOption('service')
    else {
        service <- matchService(service)
        setMFOption('service', service)
    }
}

## Get extent of a service
mfExtent <- function(service, resolution = 12){
    service <- matchService(service)
    if (service == 'meteogalicia')
        service <- paste0(service, resolution)
    extent(get('extents', envir = .mfEnv)[[service]])
}
## Get proj4 string of a service
mfProj4 <- function(service){
    service <- matchService(service)
    get('projections', envir = .mfEnv)[[service]]
}

## Get Runs of a service
mfRuns <- function(service){
    service <- matchService(service)
    get('runs', envir = .mfEnv)[[service]]
}

## Get Forecast Horizon of a service
mfHorizon <- function(service){
    service <- matchService(service)
    get('horizon', envir = .mfEnv)[[service]]
}

## Get Time Resolution of a service
mfTRes <- function(service){
    service <- matchService(service)
    get('tRes', envir = .mfEnv)[[service]]
}
