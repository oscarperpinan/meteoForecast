rasterGFS <- function(var, day = Sys.Date(), run = '00',
                      frames = 'complete',
                      box = NULL, names = NULL, remote = TRUE) {
    ## Model initialization time
    run <- match.arg(run, c('00', '06', '12', '18'))
    ## Time Frames: GFS first frame is 0 hours since RUN
    if (frames == 'complete') frames <- seq(0, 192, by = 3)
    else frames <- seq(0, length = min(65, as.integer(frames)), by = 3)
    ## Name of files to be read/stored
    ncFile <- paste0(paste(var, ymd(day), run, frames,
                           sep='_'), '.nc')
    if (remote) {
        ## GFS provides a different file
        ## for each time frame
        pb <- txtProgressBar(style = 3, max = length(frames))
        success <- lapply(seq_along(frames), function(i) {
            completeURL <- composeURL(var, day, run,
                                      box, frames[i],
                                      'gfs')
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
    suppressWarnings(bNC <- stack(ncFile))
    ## Convert into a RasterBrick
    b <- brick(bNC)
    ## Get values in memory to avoid problems with time index and
    ## projection
    b[] <- getValues(bNC)
    ## Time index
    tt <- frames * 3600 + as.numeric(run) * 3600 + as.POSIXct(day, tz='UTC')
    attr(tt, 'tzone') <- 'UTC'
    b <- setZ(b, tt)
    ## Names
    if (is.null(names)) names(b) <- format(tt, 'd%Y-%m-%d.h%H')
    ## Here it goes!
    b
}
