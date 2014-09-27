pointOM <- function(lon, lat, vars,
                    day=Sys.Date(), run='00', ...){
    ext <- mfExtent('openmeteo')
    if (!isInside(lon, lat, ext))
        stop('Point outside OpenMeteo region.')

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
