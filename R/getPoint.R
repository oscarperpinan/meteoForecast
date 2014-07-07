getPoint <- function(point, vars='swflx',
                     day=Sys.Date(), run='00',
                     service='meteogalicia'){
    
    service <- match.arg(service, c('meteogalicia', 'openmeteo'))
    
    if (is(point, 'SpatialPoints')) {
        if (!isLonLat(point)) {
            if (require(rgdal, quietly=TRUE)) 
                point <- spTransform(point, CRS('+proj=longlat +ellps=WGS84'))
            else stop('`rgdal` is needed if `point` is projected.')
        }
        lat <- coordinates(point)[2]
        lon <- coordinates(point)[1]
    } else { ## point is a numeric of length 2
        lat <- point[2]
        lon <- point[1]
    }
    
    varstr <- paste(vars, collapse=',') 
        
    z <- switch(service,
                meteogalicia = {
                    if (!pointInMG(lon, lat)) stop('Point outside Meteogalicia region.')
                    completeURL <- composeURL(varstr, day, run,
                                              c(lon, lat), '',
                                              service, point=TRUE)
                    tmpfile <- tempfile(fileext='.csv')
                    success <- try(suppressWarnings(download.file(completeURL, tmpfile, quiet=TRUE)), silent=TRUE)
                    if (class(success) == 'try-error')
                        stop('Data not found. Check the date and variables name.\nURL: ', completeURL)
                    z <- read.csv(tmpfile)
                    idx <- as.POSIXct(z[,1], format='%Y-%m-%dT%H:%M:%SZ')
                    lat <- as.numeric(as.character(z[1, 2]))
                    lon <- as.numeric(as.character(z[1, 3]))
                    z <- zoo(z[, -c(1, 2, 3)], idx)
        
                    names(z) <- vars
                    attr(z, 'lat') <- lat
                    attr(z, 'lon') <- lon
                    message('File available at ', tmpfile)
                    message('URL: ', completeURL)
                    z
                },
                openmeteo = {
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
                })
    z
}
