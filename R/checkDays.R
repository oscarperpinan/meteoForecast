
checkDays <- function(start, end, vars,
                      remote = FALSE,
                      service = mfService(),
                      dataDir = '.'){
    if (service != 'meteogalicia')
        stop(' implemented only for `meteogalicia` service.')

    start <- as.Date(start)
    end <- as.Date(end)
 
    stopifnot(start <= end)
    stopifnot(end <= Sys.Date()+1)
    
    seqDays <- seq(start, end, by='day')
  
    if(remote){
        ## Historic data of MG begins on 2008-01-01
        return(seqDays[seqDays >= '2008-01-01'])
    } else {
        ## The possibilities for src can be expanded in the future
        runs <- switch(service, meteogalicia = '00')
    
        old <- setwd(dataDir)
        on.exit(setwd(old))
    
        ## The pattern is defined for Meteogalicia files (varname_YYYYmmdd_run.nc)
        grid <- expand.grid(vars = vars,
                            days = format(seqDays, '%Y%m%d'),
                            run = runs)
        needed <- paste0(apply(grid, 1, paste, collapse='_'), '.nc')
        files <- dir(pattern='*.nc')
        found <- needed %in% files
        ok <- tapply(found, grid$days, FUN=all)
    
        if(any(ok==FALSE)){
            badDays <- seqDays[!ok]
            message('Files were not found in ',
                    normalizePath(dataDir),
                    ' for the following days:\n',
                    paste(badDays, collapse = ', '))
        }
        return(seqDays[ok])
    }
}
