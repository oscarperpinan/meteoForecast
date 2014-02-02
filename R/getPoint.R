getPoint <- function(lon, lat, point, 
                     vars='swflx',
                     day=Sys.Date(), run='00',
                     service='meteogalicia'){
    
    service <- match.arg(service, c('meteogalicia', 'openmeteo'))
    
    if (!missing(point)) {
        lat <- coordinates(point)[2]
        lon <- coordinates(point)[1]
    }
        
    dd <- format(as.Date(day), format='%Y%m%d')
    pp <- paste0('&latitude=', lat, '&longitude=', lon)
    varstr <- paste(vars, collapse=',') 
        
    z <- switch(service,
                meteogalicia = {
                    if (!pointInMG(lon, lat)) stop('Point outside Meteogalicia region.')
                    mainURL <- 'http://mandeo.meteogalicia.es/thredds/ncss/grid/wrf_2d_'
                    run <- match.arg(run, c('00', '12'))
                    run <- paste0(run, '00')
                    completeURL <- paste0(mainURL, '12km',
                                          '/fmrc/files/', dd,
                                          '/wrf_arw_det_history_d02_',
                                          dd, '_', run, '.nc4?var=',varstr,
                                          '&point=true', pp)
                    tmpfile <- tempfile(fileext='.csv')
                    success <- try(suppressWarnings(download.file(completeURL, tmpfile, quiet=TRUE)), silent=TRUE)
                    if (class(success) == 'try-error')
                        stop('Data not found. Check the date and variables name.\nURL: ', completeURL)
                    z <- read.zoo(tmpfile, tz='UTC',
                                  header=TRUE, sep=',', dec='.', fill=TRUE,
                                  format='%Y-%m-%dT%H:%M:%SZ')
                        
                    lat <- as.numeric(z$lat[1])
                    lon <- as.numeric(z$lon[1])
                    z <- z[, -c(1, 2)]
        
                    names(z) <- vars
                    attr(z, 'lat') <- lat
                    attr(z, 'lon') <- lon
                    message('File available at ', tmpfile)
                    message('URL: ', completeURL)
                    z
                },
                openmeteo = {
                    completeURL <- paste0('http://api.ometfn.net/0.1/forecast/eu12/',
                                          lat, ',', lon, '/full.json')
                    om <- fromJSON(paste(readLines(completeURL), collapse=''))
                    tt <- as.POSIXct(om$times[-1], origin='1970-01-01', tz='UTC')
                    vals <- do.call(cbind, om[vars])
                    vals <- vals[-1, ]
                    zoo(vals, tt)
                })
}
