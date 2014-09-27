pointGFS <- function(lon, lat, vars, day = Sys.Date(), run = '00', ...){
    ## We use longitudes in the range -180..180, but GFS needs 0..360
    lon <- ifelse(lon > 0, lon, 360 + lon)
    pointNCDC(lon = lon, lat = lat, vars = vars,
              day = day, run = run, service = 'gfs', ...)
    ## GFS returns longitude in the -180..180 range, no additional
    ## conversion is needed.

}

pointNAM <- function(lon, lat, vars, day = Sys.Date(), run = '00', ...){
    pointNCDC(lon = lon, lat = lat, vars = vars,
              day = day, run = run, service = 'nam', ...)
}

pointRAP <- function(lon, lat, vars, day = Sys.Date(), run = '00', ...){
    pointNCDC(lon = lon, lat = lat, vars = vars,
              day = day, run = run, service = 'rap', ...)
}

pointNCDC <- function(lon, lat, vars, day, run, service, ...){
    ## initialization variables
    ext <- mfExtent(service)
    horizon <- mfHorizon(service)
    tRes <- mfTRes(service)
    ## Check if it's inside the service region
    if (!isInside(lon, lat, ext))
        stop('Point outside ', toupper(service), ' region.')
    ## Ok, download data
    frames <- seq(0, horizon, by = tRes)
    files <- lapply(frames, FUN = function(tt){
        completeURL <- composeURL(vars, day, run,
                                  c(lon, lat), tt, 
                                  service = service,
                                  point=TRUE)
        tmpfile <- tempfile(fileext='.csv')
        success <- try(suppressWarnings(
            download.file(completeURL,
                          tmpfile, quiet=TRUE)),
                       silent=TRUE)
        if (class(success) == 'try-error') NULL else tmpfile
    })
    ## remove NULL elements
    files <- do.call(c, files)
    if (is.null(files)) {
        stop(' no data could be retrieved. Check date, coordinates and variable(s).')
    } else {
        z <- do.call("rbind", lapply(files, read.csv, header = TRUE))
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
}
