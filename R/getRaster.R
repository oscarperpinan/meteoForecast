getRaster <- function(var = 'swflx',
                      day = Sys.Date(), run = '00',
                      frames = 'complete', box,
                      resolution = NULL,
                      names,
                      remote = TRUE, 
                      service = mfService(),
                      dataDir = '.',
                      use00H = FALSE,
                      ...){

    service <- matchService(service)
    stopifnot(frames == 'complete' | is.numeric(frames))
    ## Set working directory depending on 'remote'
    if (remote) {
        old <- setwd(tempdir())
        on.exit(setwd(old))
    } else {
        old <- setwd(dataDir)
        on.exit(setwd(old))
    }
    ## Which function to use
    fun <- switch(service,
                  meteogalicia = 'rasterMG',
                  gfs = 'rasterGFS',
                  nam = 'rasterNAM',
                  rap = 'rasterRAP')

    b <- do.call(fun, list(var = var, day = as.Date(day),
                           run = run, frames = frames[1],
                           box = if (missing(box)) NULL else box,
                           resolution = resolution,
                           names = if (missing(names))  NULL else names,
                           remote = remote, use00H = use00H))

}

