pointGFS <- function(lon, lat, vars,
                    day=Sys.Date(), run='00',
                    resolution = NULL, ...){
    

    completeURL <- composeURL(vars, day, run,
                              c(lon, lat), '&temporal=all',
                              resolution = resolution,
                              service = 'gfs',
                              point=TRUE)
    ## Check if point is inside bounding box
    extGFS <- mfExtent("gfs")
    if (!isInside(lon, lat, extGFS))
        stop('Point outside GFS-MG region.')

    tmpfile <- tempfile(fileext='.csv')
    success <- try(suppressWarnings(
        download.file(completeURL,
                      tmpfile, quiet=TRUE)),
                   silent=TRUE)

    if (class(success) == 'try-error')
    stop('Data not found. Check the date and variables name.\nURL: ',
         completeURL)

    z <- read.csv(tmpfile)

    idx <- as.POSIXct(z[,1], format='%Y-%m-%dT%H:%M:%SZ', tz = 'UTC')
    lat <- as.numeric(as.character(z[1, 2]))
    lon <- as.numeric(as.character(z[1, 3]))

    z <- zoo(z[, -c(1, 2, 3)], idx)
    names(z) <- vars
    attr(z, 'lat') <- lat
    attr(z, 'lon') <- lon

    message('File available at ', tmpfile)
    message('URL: ', completeURL)

    z
}
