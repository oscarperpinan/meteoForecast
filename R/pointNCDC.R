pointGFS <- function(lon, lat, vars, day = Sys.Date(), run = '00', ...){
    pointNCDC(lon = lon, lat = lat, vars = vars,
              day = day, run = run, service = 'gfs', ...)

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
    if (service == 'gfs')
    {
        ## We use longitudes in the range -180..180, but GFS needs 0..360
        ## GFS returns longitude in the -180..180 range, no additional
        ## conversion is needed.
        lon <- ifelse(lon > 0, lon, 360 + lon)
    }

    files <- lapply(frames, FUN = function(tt){
        completeURL <- composeURL(vars, day, run,
                                  c(lon, lat), tt, 
                                  service = service,
                                  point=TRUE, ...)
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
        readNCDC <- function(x){
            ## Only the first row is needed (variables with several
            ## vertical layers produce files with multiple rows,
            ## although this is solved with the `vertical` argument)
            vals <- read.csv(x, header = TRUE, nrows = 1)
            ## Idem, but now with columns: first column is the
            ## timestamp, second and third coordinates, and last
            ## column is the variable.
            vals[1, c(1:3, ncol(vals))]
        }
        z <- do.call("rbind", lapply(files, readNCDC))
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
