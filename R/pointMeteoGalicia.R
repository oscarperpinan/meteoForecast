pointMG <- function(lon, lat, vars,
                    day=Sys.Date(), run='00'){
    
    if (!isInside(lon, lat, bbMG)) stop('Point outside Meteogalicia region.')

    completeURL <- composeURL(vars, day, run,
                              c(lon, lat), '',
                              'meteogalicia',
                              point=TRUE)

    tmpfile <- tempfile(fileext='.csv')
    success <- try(suppressWarnings(
        download.file(completeURL,
                      tmpfile, quiet=TRUE)),
                   silent=TRUE)

    if (class(success) == 'try-error')
    stop('Data not found. Check the date and variables name.\nURL: ',
         completeURL)

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
}
