getRaster <- function(var='swflx',
                      day=Sys.Date(), run='00',
                      frames='complete',
                      box, names, remote=TRUE,
                      service='meteogalicia',
                      dataDir = '.',
                      ...){
    
    service <- match.arg(service, c('meteogalicia',
                                    'gfs',
                                    'nam',
                                    'rap',
                                    'openmeteo'))

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
                  openmeteo = 'rasterOM',
                  gfs = 'rasterGFS',
                  nam = 'rasterNAM',
                  rap = 'rasterRAP')

    b <- do.call(fun, list(var = var, day = as.Date(day),
                           run = run, frames = frames[1],
                           box = if (missing(box)) NULL else box,
                           names = if (missing(names))  NULL else names,
                           remote = remote))

}

