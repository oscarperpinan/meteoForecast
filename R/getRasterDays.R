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
        stopifnot(end > start)
        stopifnot(end <= Sys.Date())
        days <- seq(start, end, by='day')
        lr <- lapply(days, FUN = function(d) {
            try(getRaster(var, day = d,
                          run = '00', frames = 24,
                          remote = remote, dataDir = '.',
                          ...))
        })
        isOK <- sapply(lr, FUN = function(x) class(x)!='try-error')
        s <- stack(lr[isOK])
        tt <- do.call(c, lapply(lr[isOK], getZ))
        attr(tt, 'tzone') <- 'UTC'
        s <- setZ(s, tt)
        s
    }
}
