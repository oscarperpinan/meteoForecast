pointInOM <-
    function(lon, lat){
        box <- extent(-45.66076, 53.66080,
                      26.36829, 55.27662)
        isInside(lon, lat, box)
    }

pointOM <- function(lon, lat, vars,
                    day=Sys.Date(), run='00'){

    if (!pointInOM(lon, lat)) stop('Point outside OpenMeteo region.')

    baseURL <- 'http://api.ometfn.net/0.1/forecast/eu12/'
    completeURL <- paste0(baseURL,
                          sprintf('%.1f', lat), ',',
                          sprintf('%.1f', lon),
                          '/full.json')
    om <- fromJSON(paste(readLines(completeURL), collapse=''))
    tt <- as.POSIXct(om$times[-1], origin='1970-01-01', tz='UTC')
    vals <- do.call(cbind, om[vars])
    vals <- vals[-1, ]
    zoo(vals, tt)
}
