pointInGFS <-
    function(lon, lat){
        box <- extent(-180, 180, -90, 90)
        isInside(lon, lat, box)
    }

pointGFS <- function(lon, lat, vars,
                     day=Sys.Date(), run='00', ...){
    if (!pointInGFS(lon, lat)) stop('Point outside GFS region.')
    ## We use longitudes in the range -180..180, but GFS needs 0..360
    lon <- ifelse(lon > 0, lon, 360 + lon)
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

    if (is.null(gfsFiles)) {
        stop(' no data could be retrieved. Check date, coordinates and variable(s).')
    } else {
        z <- do.call("rbind", lapply(gfsFiles, read.csv, header = TRUE))
        idx <- as.POSIXct(z[,1], format='%Y-%m-%dT%H:%M:%SZ', tz = 'UTC')
        lat <- as.numeric(as.character(z[1, 2]))
        ## GFS returns longitude in the -180..180 range, no additional
        ## conversion is needed.
        lon <- as.numeric(as.character(z[1, 3]))
        z <- zoo(z[, -c(1, 2, 3)], idx)
        
        names(z) <- vars
        attr(z, 'lat') <- lat
        attr(z, 'lon') <- lon
        message('Files available at ', tempdir())
        z
    }
}
