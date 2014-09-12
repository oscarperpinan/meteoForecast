## Day as character using YearMonthDay format
ymd <- function(x) format(x, format='%Y%m%d')


##################################################################
## Projections
##################################################################
## Projection parameters are either not well defined in the
## NetCDF files or incorrectly read by raster.
## Provided by gdalsrsinfo

projMG <- "+proj=lcc +lat_1=43 +lat_2=43 +lat_0=34.82300186157227 +lon_0=-14.10000038146973 +x_0=536402.34 +y_0=-18558.61 +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=km +no_defs"

projNAM <- '+proj=lcc +lat_1=25 +lat_0=25 +lon_0=-95 +k_0=1 +x_0=0 +y_0=0 +a=6367470.21484375 +b=6367470.21484375 +units=km +no_defs '

projRAP <- '+proj=lcc +lat_1=25 +lat_0=25 +lon_0=265 +k_0=1 +x_0=0 +y_0=0 +a=6371229 +b=6371229 +units=km +no_defs'

projOM <- "+proj=lcc +lon_0=4 +lat_0=47.5 +lat_1=47.5 +lat_2=47.5 +a=6370000. +b=6370000. +no_defs"

projGFS <- "+proj=longlat +datum=WGS84"

##################################################################
## Bounding Boxes
##################################################################

## Check is the point (lon, lat) is inside a bounding box defined by
## `box`
isInside <- function(lon, lat, box){
    (lat <= ymax(box) & lat >= ymin(box)) &
        (lon <= xmax(box) & lon >= xmin(box))
}

## Extracted from their WCS pages
bbMG <- extent(-21.57982593066231, 6.358561301098035,
               33.63652645596269, 49.56899908853894)

bbNAM <- extent(-153.03033819796906, -49.27221021871827,
                12.11335916285993, 57.369653102840736)

bbRAP <- extent(-139.96990801797577, -57.26853769473695,
                16.20865504970344, 55.516756978864535)

bbOM <- extent(-45.66076, 53.66080, 26.36829, 55.27661)



##################################################################
## Auxiliary functions
##################################################################
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
    pb <- txtProgressBar(style = 3, max = length(frames))
    success <- lapply(seq_along(frames), function(i) {
        completeURL <- composeURL(var, day, run,
                                  box, frames[i],
                                  service = service)
        setTxtProgressBar(pb, i)
        try(download.file(completeURL, quiet = TRUE,
                          ncFile[i], mode='wb'), 
            silent=TRUE)
    })
    close(pb)
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
