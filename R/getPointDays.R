getPointDays <- function(point,
                         vars = 'swflx',
                         start = Sys.Date(), end,
                         service = mfService(), ...){
    start <- as.Date(start)
    if (missing(end)) {
        getPoint(point, vars, day = start, run = '00', service = service, ...)
    } else {
        end <- as.Date(end)
        stopifnot(end > start)
        stopifnot(end <= Sys.Date())
        days <- seq(start, end, by='day')
        pb <- txtProgressBar(style = 3,
                             min = as.numeric(start),
                             max = as.numeric(end))
        lp <- lapply(days, FUN = function(d) {
            setTxtProgressBar(pb, as.numeric(d))
            try(suppressMessages(
                getPoint(point, vars,
                         day = d, run = '00',
                         service = service, ...)[1:24]
                )
                )
        })
        close(pb)
        isOK <- sapply(lp, FUN = function(x) class(x)!='try-error')
        z <- do.call(rbind, lp[isOK])
        attr(index(z), 'tzone') <- 'UTC'
        z
    }
}
    
