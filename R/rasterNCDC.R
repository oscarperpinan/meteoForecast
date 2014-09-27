## GFS, NAM and RAP works more or less the same. rasterNCDC is a
## general function for these three services.
rasterNCDC <- function(var, day, run,
                       frames, box, names, remote,
                       use00H, service, ...){
    ## Init variables of the model
    runs <- mfRuns(service)
    tRes <- mfTRes(service)
    proj <- mfProj4(service)
    horizon <- mfHorizon(service)
    ## Initialization time of the model
    run <- match.arg(run, runs)
    ## Time Frames: first frame is 0 hours since RUN for some
    ## variables. This 00H "forecast" is only used is use00H =
    ## TRUE. If not, the first frame corresponds with the time
    ## resolution of the service, `tRes`.
    ff <- ifelse(use00H, 0, tRes)
    ## Forecast horizon, last time frame
    lf <- horizon
    frames <-  makeFrames(frames, ff, lf, tRes)
    ## Name of files to be read/stored
    ncFile <- nameFiles(var, day, run, frames)
    if (remote) {
        isOK <- downloadRaster(var, day, run, box,
                               frames, ncFile,
                               service = service)
        if (any(!isOK)) {
            warning('Some data not found. Check the date and variables name')
            ncFile <- ncFile[isOK]
            frames <- frames[isOK]
        } else {} ## Download Successful!
    } else {} ## End of remote
    ## Make a RasterBrick with downloaded files
    b <- readFiles(ncFile)
    ## Projection parameters are either not well defined in the
    ## NetCDF files or incorrectly read by raster.
    if (service != 'gfs') b <- projectBrick(b, proj, box, remote)
    ## Add time index and names
    b <- timeIndex(b, frames, run, day, names)
    ## Result
    b
}

## Individual functions

## GFS needs its own function because of longitudes definition. Here
## we define the basic function, but there is another `rasterGFS`
## function that calls rasterGFSBasic
rasterGFSBasic <- function(var, day = Sys.Date(), run = '00',
                      frames = 'complete',
                      box = NULL, names = NULL, remote = TRUE,
                      use00H = FALSE,
                      ...){
    rasterNCDC(var = var, day = day, run = run,
               frames = frames, box = box, names = names,
               remote = remote, use00H = use00H,
               service = 'gfs', ...)
}

rasterNAM <- function(var, day = Sys.Date(), run = '00',
                      frames = 'complete',
                      box = NULL, names = NULL, remote = TRUE,
                      use00H = FALSE,
                      ...){
    rasterNCDC(var = var, day = day, run = run,
               frames = frames, box = box, names = names,
               remote = remote, use00H = use00H,
               service = 'nam', ...)
}

rasterRAP <- function(var, day = Sys.Date(), run = '00',
                      frames = 'complete',
                      box = NULL, names = NULL, remote = TRUE,
                      use00H = FALSE,
                      ...){
    rasterNCDC(var = var, day = day, run = run,
               frames = frames, box = box, names = names,
               remote = remote, use00H = use00H,
               service = 'rap', ...)
}

