pointRAP <- function(lon, lat, vars,
                     day=Sys.Date(), run='00'){

    if (!isInside(lon, lat, bbRAP)) stop('Point outside RAP region.')

    frames <- seq(0, 18, by = 1)
    files <- lapply(frames, FUN = function(tt){
        completeURL <- composeURL(vars, day, run,
                                  c(lon, lat), tt, 
                                  'rap', point=TRUE)
        tmpfile <- tempfile(fileext='.csv')
        success <- try(suppressWarnings(
            download.file(completeURL,
                          tmpfile, quiet=TRUE)),
                       silent=TRUE)
        if (class(success) == 'try-error') NULL else tmpfile
    })
    ## remove NULL elements
    files <- do.call(c, files)
    z <- do.call("rbind", lapply(files, read.csv, header = TRUE))
    idx <- as.POSIXct(z[,1], format='%Y-%m-%dT%H:%M:%SZ')
    lat <- as.numeric(as.character(z[1, 2]))
    lon <- as.numeric(as.character(z[1, 3]))
    z <- zoo(z[, -c(1, 2, 3)], idx)
    
    names(z) <- vars
    attr(z, 'lat') <- lat
    attr(z, 'lon') <- lon
    message('Files available at ', tempdir())
    z
}
