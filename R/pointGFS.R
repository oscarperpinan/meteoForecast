pointInGFS <-
    function(lon, lat){
        box <- extent(0, 360, -90, 90)
        isInside(lon, lat, box)
    }

pointGFS <- function(lon, lat, vars,
                     day=Sys.Date(), run='00', ...){
    if (!pointInGFS(lon, lat)) stop('Point outside GFS region.')
    
    frames <- seq(0, 192, by = 3)
    gfsFiles <- lapply(frames, FUN = function(tt){
        completeURL <- composeURL(vars, day, run,
                                  c(lon, lat), tt, 
                                  service = 'gfs',
                                  point=TRUE)
        tmpfile <- tempfile(fileext='.csv')
        success <- try(suppressWarnings(download.file(completeURL,
                                                      tmpfile, quiet=TRUE)),
                       silent=TRUE)
        if (class(success) == 'try-error') NULL else tmpfile
    })
    ## remove NULL elements
    gfsFiles <- do.call(c, gfsFiles)
    z <- do.call("rbind", lapply(gfsFiles, read.csv, header = TRUE))
    idx <- as.POSIXct(z[,1], format='%Y-%m-%dT%H:%M:%SZ', tz = 'UTC')
    lat <- as.numeric(as.character(z[1, 2]))
    lon <- as.numeric(as.character(z[1, 3]))
    z <- zoo(z[, -c(1, 2, 3)], idx)
    
    names(z) <- vars
    attr(z, 'lat') <- lat
    attr(z, 'lon') <- lon
    message('Files available at ', tempdir())
    z
}
