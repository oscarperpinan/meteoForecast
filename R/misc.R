##################################################################
## Auxiliary functions (not exported)
##################################################################
## Day as character using YearMonthDay format
ymd <- function(x) format(x, format='%Y%m%d')


## Check is the point (lon, lat) is inside a bounding box defined by
## `box`
isInside <- function(lon, lat, box){
    box <- extent(box)
    (lat <= ymax(box) & lat >= ymin(box)) &
        (lon <= xmax(box) & lon >= xmin(box))
}


makeFrames <- function(frames, ff, lf, tRes){
    ## Maximum number of time frames
    maxFrames <- (lf - ff)/tRes + 1
    if (frames == 'complete') frames <- seq(ff, lf, by = tRes)
    else frames <- seq(ff,
                       length = min(maxFrames, as.integer(frames)),
                       by = tRes)
}

nameFiles <- function(var, day, run, frames){
    paste0(paste(var, ymd(day), run, frames,
                 sep='_'), '.nc')
}

## GFS, RAP, NAM services provide a different file for each time frame
downloadRaster <- function(var, day, run, box,
                           frames, ncFile,
                           service){
    hasPB <- length(frames) > 1
    if (hasPB) pb <- txtProgressBar(style = 3, max = length(frames))
    success <- lapply(seq_along(frames), function(i) {
        completeURL <- composeURL(var, day, run,
                                  box, frames[i],
                                  service = service)
        if (hasPB) setTxtProgressBar(pb, i)
        try(download.file(completeURL, quiet = TRUE,
                          ncFile[i], mode='wb'), 
            silent=TRUE)
    })
    if (hasPB) close(pb)
    message('File(s) available at ', tempdir())
    isOK <- sapply(success, function(x) !inherits(x, "try-error"))
    if (!any(isOK)) stop('No data could be downloaded. Check variables, date, and service status.')
    else isOK
}

readFiles <- function(ncFile){
    ## Read files
    suppressWarnings(capture.output(bNC <- stack(ncFile)))
    ## Convert into a RasterBrick
    b <- brick(bNC)
    ## Get values in memory to avoid problems with time index and
    ## projection
    b[] <- getValues(bNC)
    b
}

projectBrick <- function(b, proj4, box, remote){
    projection(b) <- proj4
    ## Use box specification with local files
    if (!is.null(box) & remote==FALSE){
        if (require(rgdal, quietly=TRUE)) {
            extPol <- as(extent(box), 'SpatialPolygons')
            proj4string(extPol) <- '+proj=longlat +ellps=WGS84'
            extPol <- spTransform(extPol, CRS(projection(b)))
            b <- crop(b, extent(extPol))
        } else {
            warning("you need package 'rgdal' to use 'box' with local files")
        }
    }
    b
}
    

timeIndex <- function(b, frames, run, day, names){
    ## Time index
    tt <- frames * 3600 + as.numeric(run) * 3600 + as.POSIXct(day, tz='UTC')
    attr(tt, 'tzone') <- 'UTC'
    b <- setZ(b, tt)
    ## Names
    if (is.null(names)) names(b) <- format(tt, 'd%Y-%m-%d.h%H')
    b
}
