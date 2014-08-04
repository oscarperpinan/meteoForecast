rasterGFS <- function(var, day = Sys.Date(), run = '00',
                      frames = 'complete',
                      box = NULL, names = NULL, remote = TRUE,
                      use00H = FALSE) {
    ## Model initialization time
    run <- match.arg(run, c('00', '06', '12', '18'))
    ## Model Time resolution
    tRes <- 3
    ## Time Frames: GFS first frame is 0 hours since RUN for some
    ## variables. This 00H "forecast" is only used is use00H = TRUE
    ff <- ifelse(use00H, 0, tRes)
    ## Forecast horizon, last time frame
    lf <- 192
    frames <-  makeFrames(frames, ff, lf, tRes)
    ## Name of files to be read/stored
    ncFile <- nameFiles(var, day, run, frames)
    if (remote) {
        isOK <- downloadRaster(var, day, run, box,
                               frames, ncFile, 'gfs')
        if (any(!isOK)) {
            warning('Some data not found. Check the date and variables name')
            ncFile <- ncFile[isOK]
            frames <- frames[isOK]
            } else {} ## Download Successful!
    } else {} ## End of remote
    b <- readFiles(ncFile)
    ## Add time index and names
    b <- timeIndex(b, frames, run, day, names)
    ## Here it goes!
    b
}
