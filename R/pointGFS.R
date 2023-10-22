pointGFS <- function(lon, lat, vars,
                    day=Sys.Date(), run='00',
                    resolution = NULL, ...)
{

    completeURL <- composeURL(vars, day, run,
                              c(lon, lat), '&temporal=all',
                              resolution = resolution,
                              service = 'gfs',
                              point=TRUE, ...)
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
    vert <- any(grepl('vertCoord', names(z)))
    idx <- as.POSIXct(z[,1], format='%Y-%m-%dT%H:%M:%SZ', tz = 'UTC')
    lat <- as.numeric(as.character(z[1, 2]))
    lon <- as.numeric(as.character(z[1, 3]))
    if (vert)
        vertCoord <- as.numeric(as.character(z[1, 4]))

    ## Subset the columns with variables (time index, lat, long, and
    ## vertical coordinate are not needed)
    nc <- ncol(z)
    nv <- length(vars)
    z <- zoo(z[, (nc - nv + 1):nc], idx)
    names(z) <- vars

    attr(z, 'lat') <- lat
    attr(z, 'lon') <- lon
    if (vert) attr(z, 'vertCoord') <- vertCoord
    
    message('File available at ', tmpfile)
    message('URL: ', completeURL)

    z
}
