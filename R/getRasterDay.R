getRasterDay <- function(var = 'swflx', day = Sys.Date(),
                         remote = TRUE, dataDir = '.',
                         ...){
  
  day <- as.Date(day)
  today <- Sys.Date()

  if(!remote) {
      old <- setwd(dataDir)
      on.exit(setwd(old))
  }
  ## If I need a day in the future, I have to download the most recent
  ## file (today) and extract the frames that correspond to the day we
  ## need.
  if (day > today) {
      r <- getRaster(var = var, day = today,
                     frames = 'complete',
                     remote = remote, ...)
      idx <- which(day == as.Date(getZ(r)))
      r[[idx]]
  } else {
      ## If the day is in the past, use `getRaster` to obtain only the
      ## 24 frames that correspond to that day.
      r <- getRaster(var = var, day = day,
                     frames = 24, 
                     remote = remote, ...)
      r
  }
}
