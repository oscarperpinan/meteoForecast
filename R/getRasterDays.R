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
    } else {
        end <- as.Date(end)
        stopifnot(end >= start)
        days <- seq(start, end, by='day')
        ## Progress bar is only enabled if end > start
        havePB <- (end > start)
        if (havePB) pb <- txtProgressBar(style = 3,
                                         min = as.numeric(start),
                                         max = as.numeric(end))
        lr <- lapply(days, FUN = function(d) {
            if (havePB) setTxtProgressBar(pb, as.numeric(d))
            try(suppressMessages(
                getRasterDay(var, day = d,
                             remote = remote,
                             dataDir = '.',
                             ...)
                ))
        })
        if (havePB) close(pb)
        isOK <- sapply(lr, FUN = function(x) class(x)!='try-error')
        if (!any(isOK)) stop('No data could be downloaded.')
        s <- stack(lr[isOK])
        tt <- do.call(c, lapply(lr[isOK], getZ))
        attr(tt, 'tzone') <- 'UTC'
        s <- setZ(s, tt)
        s
    }
}
