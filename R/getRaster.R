getRaster <-
    function(var='swflx',
             day=Sys.Date(), run='00',
             frames='complete',
             box, names, remote=TRUE,
             service='meteogalicia',
             dataDir = '.',
             ...){

        service <- match.arg(service, c('meteogalicia', 'openmeteo'))
        ## Model initialization time
        run <- switch(service,
                      meteogalicia = match.arg(run, c('00', '12')),
                      openmeteo = match.arg(run, c('00', '06', '12', '18'))
                      )
        day <- as.Date(day)
        dd <- format(day, format='%Y%m%d')
        ## Bounding box
        if (!missing(box)) {
            ext <- extent(box)
            box <- paste0('&north=', ymax(ext),
                          '&west=', xmin(ext),
                          '&east=', xmax(ext),
                          '&south=', ymin(ext))
        } else box <- ''

        ## Time Frames
        frames <- frames[1]
        stopifnot(frames == 'complete' | is.numeric(frames))
        frames <-  switch(service,
                          openmeteo = {
                              if (frames == 'complete') frames <- 1:72
                              else frames <- seq(1, as.integer(frames), by=1)
                          },
                          meteogalicia = {
                              if (remote) {
                                  if (frames == 'complete') frames <- ''
                                  else {
                                      present <- as.POSIXct(paste0(as.character(day),
                                                                   as.numeric(run),
                                                                   ':00:00Z'))
                                      ff <- present + 3600
                                      lf <- present + as.integer(frames)*3600
                                      frames <- paste0('&time_start=',
                                                       format(ff,
                                                              '%Y-%m-%dT%H:%M:%SZ'),
                                                       '&time_end=',
                                                       format(lf,
                                                              '%Y-%m-%dT%H:%M:%SZ')
                                                       )
                                  }
                              } else { ## remote=FALSE
                                  maxFrames <- switch(run, '00'=96, '12'=84)
                                  if (frames == 'complete') {
                                      frames <- seq(1, maxFrames, 1)
                                  } else {
                                      frames <- seq(1, min(frames, maxFrames), by=1)
                                  }
                              }
                          })
        
        ## Name of files to be read/stored
        ncFile <- switch(service,
                         meteogalicia = paste0(paste(var, dd, run, 
                             sep='_'), '.nc'), 
                         openmeteo = paste0(paste(var, dd, run, frames, 
                             sep='_'), '.nc')
                         )
        
        if (remote) {
            old <- setwd(tempdir())
            on.exit(setwd(old))
            success <- switch(service,
                              ## Meteogalicia provides a multilayer
                              ## file with all the time frames
                              meteogalicia = {
                                  completeURL <- composeURL(var, day, run,
                                                            box, frames, 
                                                            'meteogalicia')
                                  try(download.file(completeURL, ncFile, mode='wb'),
                                      silent=TRUE)
                              },
                              ## OpenMeteo provides a different file
                              ## for each time frame
                              openmeteo = 
                                  lapply(seq_along(frames), function(i) {
                                      completeURL <- composeURL(var, day, run,
                                                                box, frames[i],
                                                                'openmeteo')
                                      try(download.file(completeURL,
                                                        ncFile[i], mode='wb'), 
                                          silent=TRUE)
                                  })
                              )
            if (any(sapply(success, class) == 'try-error')) {
                stop('Data not found. Check the date and variables name')
            } else { ## Download Successful!
                message('File(s) available at ', tempdir())
            } ## End of Remote
        } else {
            old <- setwd(dataDir)
            on.exit(setwd(old))
        }
        ## Read files
        suppressWarnings(bNC <- stack(ncFile))
        ## Use frames with local files from meteogalicia
        if (remote==FALSE & service=='meteogalicia') bNC <- bNC[[frames]]
        ## Convert into a RasterBrick
        b <- switch(service,
                    meteogalicia = brick(bNC),
                    ## https://forum.openmeteodata.org/index.php?topic=33.msg96#msg96
                    openmeteo = brick(nrow=309, ncol=495,
                        nl=length(frames),
                        xmn = -2963997.87057, ymn = -1848004.2008,
                        xmx = 2964000.82884, ymx = 1848004.09676)
                    )
        ## Get values in memory to avoid problems with time index and
        ## projection
        b[] <- getValues(bNC)
        ## Projection parameters are either not well defined in the
        ## NetCDF files or incorrectly read by raster
        projection(b) <- switch(service,
                                ## Provided by gdalsrsinfo
                                meteogalicia = "+proj=lcc +lat_1=43 +lat_2=43 +lat_0=34.82300186157227 +lon_0=-14.10000038146973 +x_0=536402.34 +y_0=-18558.61 +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=km +no_defs",
                                ## https://forum.openmeteodata.org/index.php?topic=33.msg96#msg96
                                openmeteo = "+proj=lcc +lon_0=4 +lat_0=47.5 +lat_1=47.5 +lat_2=47.5 +a=6370000. +b=6370000. +no_defs"
                                )
        ## Use box specification with local files or openmeteo
        if (box!='' & (remote==FALSE | service=='openmeteo')) {
            if (require(rgdal, quietly=TRUE)) {
                extPol <- as(ext, 'SpatialPolygons')
                proj4string(extPol) <- '+proj=longlat +ellps=WGS84'
                extPol <- spTransform(extPol, CRS(projection(b)))
                b <- crop(b, extent(extPol))
                } else {
                    warning("you need package 'rgdal' to use 'box' with local files or openmeteo")
                }
        }
        ## Time index
        hours <- seq_len(nlayers(b))* 3600
        tt <- hours + as.numeric(run)*3600 + as.POSIXct(day, tz='UTC')
        attr(tt, 'tzone') <- 'UTC'
        b <- setZ(b, tt)
        ## Names
        if (missing(names)) names(b) <- format(tt, 'd%Y-%m-%d.h%H')
        ## Here it goes!
        b
    }
