pointInMG <-
    function(lon, lat){
        box <- extent(-21.57982593066231, 6.358561301098035,
                      33.63652645596269, 49.56899908853894)
        isInside(lon, lat, box)
    }

pointMG <- function(lon, lat, vars,
                    day=Sys.Date(), run='00'){
    
    if (!pointInMG(lon, lat)) stop('Point outside Meteogalicia region.')

    completeURL <- composeURL(vars, day, run,
                              c(lon, lat), '',
                              'meteogalicia',
                              point=TRUE)

    tmpfile <- tempfile(fileext='.csv')
    success <- try(suppressWarnings(download.file(completeURL,
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
