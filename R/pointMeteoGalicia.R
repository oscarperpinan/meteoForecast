pointMG <- function(lon, lat, vars,
                    day=Sys.Date(), run='00',
                    resolution = 12, ...){
    

    completeURL <- composeURL(vars, day, run,
                              c(lon, lat), '&temporal=all',
                              resolution = resolution,
                              service = 'meteogalicia',
                              point=TRUE)
    ## Resolution default value 
    if (is.null(resolution)) resolution <- 12
    ## Valid choices in Meteogalicia
    resChoices <- c(4, 12, 36)
    idxRes <- match(resolution, resChoices)
    if (is.na(idxRes)) idxRes <- 2
    ## Check if point is inside bounding box
    extMG <- get("extents", envir = .mfEnv)[
                                c('meteogalicia4',
                                  'meteogalicia12',
                                  'meteogalicia36')]
    if (!isInside(lon, lat, extMG[[idxRes]]))
        stop('Point outside Meteogalicia region.')

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
