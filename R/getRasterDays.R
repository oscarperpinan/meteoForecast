getRasterDays <- function(var = 'swflx',
                          start = Sys.Date(), end,
                          remote = TRUE, dataDir = '.',
                          ...){

    if(!remote) {
        old <- setwd(dataDir)
        on.exit(setwd(old))
    }

    start <- as.Date(start)
    if (missing(end)) {
        getRaster(var, day = start, run='00', ...)
    } else if(start == Sys.Date()+1) {
        lr <- try(suppressMessages(getRaster(var, day = start-1,
                                             run = '00', frames = 48,
                                             remote = remote,
                                             dataDir = '.',
                                             ...)
                  ))
        if(class(lr)!='try-error'){
            lr <- subset(lr, 25:48)
            tt <- getZ(lr)
            attr(tt, 'tzone') <- 'UTC'
            s <- setZ(lr, tt)
            s
        }
    } else {
        end <- as.Date(end)
        stopifnot(end >= start)
        stopifnot(end <= Sys.Date())
        days <- seq(start, end, by='day')
        ## Progress bar is only enabled if end > start
        havePB <- (end > start)
        if (havePB) pb <- txtProgressBar(style = 3,
                                         min = as.numeric(start),
                                         max = as.numeric(end))
        lr <- lapply(days, FUN = function(d) {
            if (havePB) setTxtProgressBar(pb, as.numeric(d))
            try(suppressMessages(
                getRaster(var, day = d,
                          run = '00', frames = 24,
                          remote = remote,
                          dataDir = '.',
                          ...)
                ))
        })
        if (havePB) close(pb)
        isOK <- sapply(lr, FUN = function(x) class(x)!='try-error')
        s <- stack(lr[isOK])
        tt <- do.call(c, lapply(lr[isOK], getZ))
        attr(tt, 'tzone') <- 'UTC'
        s <- setZ(s, tt)
        s
    }
}
