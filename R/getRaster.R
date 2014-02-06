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
        ## Model initialization time
        run <- switch(service,
                      meteogalicia = match.arg(run, c('00', '12')),
                      openmeteo = match.arg(run, c('00', '06', '12', '18'))
                      )
        dd <- format(as.Date(day), format='%Y%m%d')
        ## Bounding box: it only works for meteogalicia
        if (!missing(box)) {
            ext <- extent(box)
            box <- paste0('&north=', ymax(ext),
                          '&west=', xmin(ext),
                          '&east=', xmax(ext),
                          '&south=', ymin(ext))
        } else box <- ''
        
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
                                  completeURL <- composeURL(var, dd, run,
                                                            box, '', 
                                                            'meteogalicia')
                                  try(download.file(completeURL, ncFile),
                                      silent=TRUE)
                              },
                              ## OpenMeteo provides a different file
                              ## for each time frame
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
        
        ## Read files
        suppressWarnings(bNC <- stack(ncFile))
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
        ## Time index
        hours <- switch(service,
                        meteogalicia = (seq_len(nlayers(b))) * 3600, 
                        openmeteo = frames * 3600 
                        )
        tt <- hours + as.numeric(run)*3600 + as.POSIXct(day)
        b <- setZ(b, tt)
        ## Names
        if (missing(names)) names(b) <- format(tt, 'D%Y-%m-%d_H%H')
        ## Here it goes!
        b
    }
