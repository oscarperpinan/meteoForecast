composeURL <- function(var, dd, run, box, frame, service){
    switch(service,
           meteogalicia = {
               mainURL <- 'http://mandeo.meteogalicia.es/thredds/ncss/grid/wrf_2d_'
               run <- match.arg(run, c('00', '12'))
               paste0(mainURL, '12km',
                      '/fmrc/files/', dd,
                      '/wrf_arw_det_history_d02',
                      '_', dd,
                      '_', paste0(run, '00'),
                      '.nc4?var=', var,
                      box)
           },
           openmeteo = {
               mainURL <- 'http://dap.ometfn.net/eu12-pp_'
               run <- match.arg(run, c('00', '06', '12', '18'))
               paste0(mainURL,
                      dd, run,
                      paste0('_', frame),
                      '.nc.nc?',var,
                      box)
           },
           'unknown'
           )
}

getRaster <-
    function(var='swflx',
             day=Sys.Date(), run='00',
             frames=1:72,
             box, names, remote=TRUE, 
             service='meteogalicia',
             ...){

        service <- match.arg(service, c('meteogalicia', 'openmeteo'))

        run <- switch(service,
                      meteogalicia = match.arg(run, c('00', '12')),
                      openmeteo = match.arg(run, c('00', '06', '12', '18'))
                      )

        dd <- format(as.Date(day), format='%Y%m%d')
    
        if (!missing(box)) {
            ext <- extent(box)
            box <- paste0('&north=', ymax(ext),
                          '&west=', xmin(ext),
                          '&east=', xmax(ext),
                          '&south=', ymin(ext))
        } else box <- ''
        

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
                              meteogalicia = {
                                  completeURL <- composeURL(var, dd, run,
                                                            box, '', 
                                                            'meteogalicia')
                                  try(download.file(completeURL, ncFile),
                                      silent=TRUE)
                              },
                              openmeteo = 
                                  lapply(seq_along(frames), function(i) {
                                      completeURL <- composeURL(var, dd, run,
                                                                box, frames[i],
                                                                'openmeteo')
                                      try(download.file(completeURL,
                                                        ncFile[i]), 
                                          silent=TRUE)
                                  })
                              )
            if (any(sapply(success, class) == 'try-error')) {
                stop('Data not found. Check the date and variables name')
            } else { ## Download Successful!
                message('File(s) available at ', tempdir())
            }
        } ## End of Remote
        
        suppressWarnings(bNC <- stack(ncFile))
        b <- brick(bNC)
        b[] <- getValues(bNC)
        
        projection(b) <- switch(service,
                                meteogalicia = "+proj=lcc +lon_0=-14.1 +lat_0=34.823 +lat_1=43 +lat_2=43 +x_0=536402.3 +y_0=-18558.61 +units=km +ellps=WGS84",
                                openmeteo = "+proj=lcc +lon_0=4 +lat_1=47.5 +lat_2=47.5"
                                )
        
        hours <- switch(service,
                        meteogalicia = (1:96) * 3600, 
                        openmeteo = frames * 3600 
                        )
        tt <- hours + as.numeric(run)*36 + as.POSIXct(day)
        b <- setZ(b, tt)
        if (missing(names)) names(b) <- format(tt, 'D%Y-%m-%d_H%H')
        b
    }
