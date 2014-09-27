rasterOM <- function(var, day=Sys.Date(), run='00',
                     frames='complete',
                     box = NULL, names = NULL, remote=TRUE, ...) {
    
    ## Init variables of the model
    runs <- mfRuns('openmeteo')
    tRes <- mfTRes('openmeteo')
    proj <- mfProj4('openmeteo')
    horizon <- mfProj4('openmeteo')

    ## Time of model initialization
    run <- match.arg(run, runs)
    ## Time Frames
    if (frames == 'complete') frames <- seq(1, horizon, tRes)
    else frames <- seq(1, as.integer(frames), tRes)
        
    ## Name of files to be read/stored
    ncFile <- paste0(paste(var, ymd(day), run, frames, 
                           sep='_'), '.nc')
        
    if (remote) {
        ## OpenMeteo provides a different file
        ## for each time frame
        pb <- txtProgressBar(style = 3, max = length(frames))
        success <- lapply(seq_along(frames), function(i) {
            completeURL <- composeURL(var, day, run,
                                      box, frames[i],
                                      'openmeteo')
            try(suppressWarnings(download.file(completeURL,
                                               ncFile[i],
                                               quiet = TRUE,
                                               mode='wb')), 
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
    ## https://forum.openmeteodata.org/index.php?topic=33.msg96#msg96
    b <- brick(nrow=309, ncol=495,
               nl=length(frames),
               xmn = -2963997.87057, ymn = -1848004.2008,
               xmx = 2964000.82884, ymx = 1848004.09676)
    ## Get values in memory to avoid problems with time index and
    ## projection
    b[] <- getValues(bNC)
    ## Projection parameters are either not well defined in the NetCDF
    ## files or incorrectly read by raster:
    ## https://forum.openmeteodata.org/index.php?topic=33.msg96#msg96
    projection(b) <- proj
    ## Use box specification
    if (!is.null(box)) {
        if (require(rgdal, quietly=TRUE)) {
            extPol <- as(extent(box), 'SpatialPolygons')
            proj4string(extPol) <- '+proj=longlat +ellps=WGS84'
            extPol <- spTransform(extPol, CRS(projection(b)))
            b <- crop(b, extent(extPol))
        } else {
            warning("you need package 'rgdal' to use 'box' with local files or openmeteo")
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
