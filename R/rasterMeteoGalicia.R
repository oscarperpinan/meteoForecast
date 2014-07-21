rasterMG <- function(var='swflx',
                     day=Sys.Date(), run='00',
                     frames='complete',
                     box = NULL, names = NULL, remote=TRUE) {
    ## Model initialization time
    run <- match.arg(run, c('00', '12'))
    ## Time Frames
    if (remote) {
        ## MeteoGalicia implements netCDF Time Subset. Therefore,
        ## `frames` is a character.
        if (frames == 'complete') frames <- ''
        else {
            present <- as.POSIXct(paste0(as.character(day),
                                         as.numeric(run),
                                         ':00:00Z'))
            ff <- present + 3600
            lf <- present + as.integer(frames)*3600
            frames <- paste0('&time_start=',
                             format(ff,
                                    '%Y-%m-%dT%H:%M:%SZ'),
                             '&time_end=',
                             format(lf,
                                    '%Y-%m-%dT%H:%M:%SZ')
                             )
        }
    } else { ## remote=FALSE
        maxFrames <- switch(run, '00'=96, '12'=84)
        if (frames == 'complete') {
            frames <- seq(1, maxFrames, 1)
        } else {
            frames <- seq(1, min(frames, maxFrames), by=1)
        }
    }
        
    ## Name of files to be read/stored
    ncFile <- paste0(paste(var, ymd(day), run, 
                           sep='_'), '.nc')
        
    if (remote) {
        ## Meteogalicia provides a multilayer
        ## file with all the time frames
        completeURL <- composeURL(var, day, run,
                                  box, frames, 
                                  'meteogalicia')
        success <- try(suppressWarnings(download.file(completeURL,
                                                      ncFile,
                                                      mode='wb')),
                       silent=TRUE)

        if (class(success) == 'try-error') {
            stop('Data not found. Check the date and variables name')
        } else { ## Download Successful!
            message('File(s) available at ', tempdir())
        } ## End of Remote
    } else {}
    ## Read files
    suppressWarnings(capture.output(bNC <- stack(ncFile)))
    ## Use frames with local files from meteogalicia
    if (remote==FALSE) bNC <- bNC[[frames]]
    ## Convert into a RasterBrick
    b <- brick(bNC)
    ## Get values in memory to avoid problems with time index and
    ## projection
    b[] <- getValues(bNC)
    ## Projection parameters are either not well defined in the
    ## NetCDF files or incorrectly read by raster.
    ## Provided by gdalsrsinfo
    projection(b) <- "+proj=lcc +lat_1=43 +lat_2=43 +lat_0=34.82300186157227 +lon_0=-14.10000038146973 +x_0=536402.34 +y_0=-18558.61 +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=km +no_defs"

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
    ## Time index
    hours <- seq_len(nlayers(b))* 3600
    tt <- hours + as.numeric(run)*3600 + as.POSIXct(day, tz='UTC')
    attr(tt, 'tzone') <- 'UTC'
    b <- setZ(b, tt)
    ## Names
    if (is.null(names)) names(b) <- format(tt, 'd%Y-%m-%d.h%H')
    ## Here it goes!
    b
}
