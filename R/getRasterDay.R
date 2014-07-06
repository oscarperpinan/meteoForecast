
getRasterDay <- function(var = 'swflx', day = Sys.Date(),
                         remote = TRUE, service = 'meteogalicia',
                         dataDir = '.', ...){
  
  ## The possibilities for src can be expanded in the future
  runs <- switch(service, meteogalicia = '00')
  
  ## Time difference between runs
  delta <- 24
  ## Specific for runs '00' of meteogalicia
  
  if(!remote) {
      old <- setwd(dataDir)
      on.exit(setwd(old))
  }
  
  ### Read the first "delta" frames from each run to compose a list (zl)
  zl <- lapply(runs, FUN=function(run){
               r <- try(getRaster(var, day, run=run, frames=delta,
                              service=service, remote=remote, ...))
               })
  isOK <- sapply(zl, FUN = function(x) class(x)!='try-error')
  
  ### RasterBrick joining the elements of the list (zl)
  z <- brick(stack(zl[isOK]))
  
  ### Adding time index
  tt <- do.call(c, lapply(zl[isOK], getZ))
  attr(tt, 'tzone') <- 'UTC'
  z <- setZ(z, tt)
  
}
