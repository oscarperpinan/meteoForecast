getPointDays <- function(lon, lat, point=NULL,
                         vars = 'swflx',
                         start = Sys.Date(), end,
                         service = 'meteogalicia'){
    start <- as.Date(start)
    if (missing(end)) {
        getPoint(lon, lat, point, vars, day = start, run='00', service=service)
    } else {
        end <- as.Date(end)
        stopifnot(end > start)
        days <- seq(start, end, by='day')
        lp <- lapply(days, FUN = function(d) getPoint(lon, lat, point, vars,
                               day = d, run = '00', service=service)[1:24])
        z <- do.call(rbind, lp)
        attr(index(z), 'tzone') <- 'UTC'
        z
    }
}
    
