rasterRAP <- function(var, day = Sys.Date(), run = '00',
                      frames = 'complete',
                      box = NULL, names = NULL, remote = TRUE) {
    ## Model initialization time
    ## RAP is initialized each hour!
    run <- match.arg(run, sprintf('%02d', 0:23))
    ## Time Frames: RAP first frame is 0 hours since RUN
    if (frames == 'complete') frames <- seq(0, 18, by = 1)
    else frames <- seq(0, length = min(19, as.integer(frames)), by = 1)
    ## Name of files to be read/stored
    ncFile <- paste0(paste(var, ymd(day), run, frames,
                           sep='_'), '.nc')
    if (remote) {
        ## RAP provides a different file
        ## for each time frame
        pb <- txtProgressBar(style = 3, max = length(frames))
        success <- lapply(seq_along(frames), function(i) {
            completeURL <- composeURL(var, day, run,
                                      box, frames[i],
                                      'rap')
            try(download.file(completeURL, quiet = TRUE,
                              ncFile[i], mode='wb'), 
                silent=TRUE)
            setTxtProgressBar(pb, i)
        })
        close(pb)
        isOK <- sapply(success, function(x) !inherits(x, "try-error"))
        if (any(!isOK)) {
            warning('Data not found. Check the date and variables name')
        } else { ## Download Successful!
            message('File(s) available at ', tempdir())
        } ## End of Remote
    } else {}
    ## Read files
    suppressWarnings(capture.output(bNC <- stack(ncFile)))
    ## Convert into a RasterBrick
    b <- brick(bNC)
    ## Get values in memory to avoid problems with time index and
    ## projection
    b[] <- getValues(bNC)
    ## Projection parameters are either not well defined in the
    ## NetCDF files or incorrectly read by raster.
    ## Provided by gdalsrsinfo
    projection(b) <- '+proj=lcc +lat_1=25 +lat_0=25 +lon_0=265 +k_0=1 +x_0=0 +y_0=0 +a=6371229 +b=6371229 +units=km +no_defs'
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
    tt <- frames * 3600 + as.numeric(run) * 3600 + as.POSIXct(day, tz='UTC')
    attr(tt, 'tzone') <- 'UTC'
    b <- setZ(b, tt)
    ## Names
    if (is.null(names)) names(b) <- format(tt, 'd%Y-%m-%d.h%H')
    ## Here it goes!
    b
}
