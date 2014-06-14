getPointDays <- function(point,
                         vars = 'swflx',
                         start = Sys.Date(), end,
                         service = 'meteogalicia'){
    start <- as.Date(start)
    if (missing(end)) {
        getPoint(point, vars, day = start, run='00', service=service)
    } else {
        end <- as.Date(end)
        stopifnot(end > start)
        stopifnot(end <= Sys.Date())
        days <- seq(start, end, by='day')
        lp <- lapply(days, FUN = function(d) {
            try(getPoint(point, vars,
                         day = d, run = '00',
                         service=service)[1:24])
        })
        isOK <- sapply(lp, FUN = function(x) class(x)!='try-error')
        z <- do.call(rbind, lp[isOK])
        attr(index(z), 'tzone') <- 'UTC'
        z
    }
}
    
