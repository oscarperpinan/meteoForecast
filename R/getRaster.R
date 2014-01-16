getRaster <-
    function(var='swflx',
             day=Sys.Date(), run='00',
             box=c(-10, 5, 30, 40),
             names, service='meteogalicia',
             ...){
    dd <- format(as.Date(day), format='%Y%m%d')
    ext <- extent(box)
    box <- paste0('&north=', ymax(ext),
                  '&west=', xmin(ext),
                  '&east=', xmax(ext),
                  '&south=', ymin(ext))

    if (service == 'meteogalicia'){
        mainURL <- 'http://mandeo.meteogalicia.es/thredds/ncss/grid/wrf_2d_'
        run <- match.arg(run, c('00', '12'))
        completeURL <- paste0(mainURL, '12km',
                              '/fmrc/files/', dd,
                              '/wrf_arw_det_history_d02',
                              '_', dd,
                              '_', paste0(run, '00'),
                              '.nc4?var=', var,
                              box)
        projLCC <- "+proj=lcc +lon_0=-14.1 +lat_0=34.823 +lat_1=43 +lat_2=43 +x_0=536402.3 +y_0=-18558.61 +units=km +ellps=WGS84"
        
        } else if (service == 'openmeteo') {
            mainURL <- 'http://dap.ometfn.net/eu12-raw_'
            run <- match.arg(run, c('00', '06', '12', '18'))
            completeURL <- paste0(mainURL,
                                  dd, run, '_72',
                                  '.nc.nc?var=',var,
                                  box)
            projLCC <- "+proj=lcc +lon_0=4 +lat_1=47.5 +lat_2=47.5"
            } else stop('Service unknown.')

    ncFile <- paste0(paste(var, service, dd, run, sep='_'), '.nc')

    old <- setwd(tempdir())
    success <- try(suppressWarnings(download.file(completeURL, destfile=ncFile,
                                                  quiet=TRUE)), silent=TRUE)
    if (class(success) == 'try-error') {
        setwd(old)
        stop('Data not found. Check the date and variables name.\nURL: ', completeURL)
    } else {
        suppressWarnings(bNC <- brick(ncFile))
        b <- brick(bNC)
        b[] <- getValues(bNC)
        setwd(old)
        
        projection(b) <- projLCC

        tt <- as.numeric(getZ(bNC)) + as.numeric(run)*36 + as.POSIXct(day)
        b <- setZ(b, tt)
        if (missing(names)) names(b) <- format(tt, 'D%Y-%m-%d_H%H')
        message('File available at ', paste(tempdir(), ncFile, sep='/'))
        message('URL: ', completeURL)
        b
    }
}
