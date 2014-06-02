getRasterDays <- function(var = 'swflx',
                          start = Sys.Date(), end,
                          box, remote = TRUE,
                          service = 'meteogalicia'){
    start <- as.Date(start)
    if (missing(end)) {
        getRaster(var, day = start, run='00', box = box, remote = remote, service = service)
    } else {
        end <- as.Date(end)
        stopifnot(end > start)
        days <- seq(start, end, by='day')
        lr <- lapply(days, FUN = function(d) {
            try(getRaster(var,
                          day = d, run = '00', frames = 24,
                          box = box, remote = remote,
                          service=service))
        })
        isOK <- sapply(lr, FUN = function(x) class(x)!='try-error')
        s <- stack(lr[isOK])
        tt <- do.call(c, lapply(lr[isOK], getZ))
        attr(tt, 'tzone') <- 'UTC'
        s <- setZ(s, tt)
        s
    }
}
