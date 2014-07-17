## http://www.unidata.ucar.edu/software/thredds/current/tds/reference/NetcdfSubsetServiceReference.html
composeURL <- function(var, day, run, spatial, timeFrame,
                       service, point=FALSE){
    day <- as.Date(day)
    Ym <- format(day, format='%Y%m')
    Ymd <- format(day, format='%Y%m%d')
    if (point) {## getPoint
        spatial <- paste0('&point=true',
                          '&longitude=', spatial[1],
                          '&latitude=', spatial[2])

    }
    switch(service,
           meteogalicia = {
               today <- Sys.Date()
               ## meteogalicia stores 14 days of operational forecasts
               ## After 14 days the forecasts are moved to the WRF_HIST folder
               if (today - day <= 14) {
                   mainURL <- 'http://mandeo.meteogalicia.es/thredds/ncss/grid/wrf_2d_'
                   paste0(mainURL, '12km',
                          '/fmrc/files/', Ymd,
                          '/wrf_arw_det_history_d02',
                          '_', Ymd,
                          '_', paste0(run, '00'),
                          '.nc4?var=', var,
                          spatial, timeFrame)
               } else {
                   ## Historical forecasts. Only run 0 is available
                   mainURL <- 'http://mandeo.meteogalicia.es/thredds/ncss/grid/modelos/WRF_HIST/d02/'
                   year <- format(day, '%Y')
                   month <- format(day, '%m')
                   paste0(mainURL,
                          year, '/',
                          month, '/',
                          'wrf_arw_det_history_d02_',
                          Ymd,
                          '_', '0000',
                          '.nc4?var=', var,
                          spatial, timeFrame)
               }},
           gfs = {
               mainURL <- 'http://nomads.ncdc.noaa.gov/thredds/ncss/grid/gfs-004/'
               run <- paste0(run, '00')
               timeFrame <- sprintf('%03d', timeFrame)
               paste0(mainURL, Ym, '/', Ymd, '/',
                      'gfs_4_', Ymd, '_', run, '_', timeFrame,
                      '.grb2?var=', var, spatial)
               
           },
           openmeteo = {
               mainURL <- 'http://dap.ometfn.net/eu12-pp_'
               paste0(mainURL,
                      Ymd, run,
                      paste0('_', timeFrame),
                      '.nc.nc?',var)
           },
           'unknown'
           )
}
