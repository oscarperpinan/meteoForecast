## http://www.unidata.ucar.edu/software/thredds/current/tds/reference/NetcdfSubsetServiceReference.html

##################################################################
## Main Function
##################################################################
composeURL <- function(var, day, run, spatial, timeFrame,
                       resolution = NULL, vertical = NA,
                       service, point = FALSE){

    if (!is.null(spatial)) {
        ## Bounding Box or Long-Lat
        if (point) {## getPoint
            spatial <- paste0('&point=true&accept=csv',
                              '&longitude=', spatial[1],
                              '&latitude=', spatial[2])
            
        } else { ## getRaster
            ext <- extent(spatial)
            spatial <- paste0('&north=', ymax(ext),
                              '&west=', xmin(ext),
                              '&east=', xmax(ext),
                              '&south=', ymin(ext))
        }
    } else spatial <- ''
    ## Multiple variables are allowed if point=TRUE
    if (point) var <- paste(var, collapse=',') else var <- var[1]

    if (!is.na(vertical)) vertical <- paste0('&vertCoord=', vertical)
        else vertical <- ''

    fun <- switch(service,
                  meteogalicia = 'urlMG',
                  gfs = 'urlGFS',
                  nam = 'urlNAM',
                  rap = 'urlRAP',
                  stop('Unknown service'))

    completeURL <- do.call(fun, list(var = var, day = day, run = run,
                                     spatial = spatial,
                                     timeFrame = timeFrame,
                                     resolution = resolution,
                                     vertical = vertical))
    completeURL
}

##################################################################
## MeteoGalicia
##################################################################
urlMG <- function(var, day, run, spatial, timeFrame, resolution, ...){
    today <- Sys.Date()
    ## Resolution default value 
    if (is.null(resolution)) resolution <- 12
    ## Valid choices in Meteogalicia
    resChoices <- c(36, 12, 4)
    idxRes <- match(resolution, resChoices)
    if (is.na(idxRes)) {
        resolution <- 12
        idxRes <- 2
        message('Valid choices for `resolution` are 4, 12 and 36. Resorting to default value, 12.')
    }
    resolution <- sprintf('%02dkm', resolution)
    ## meteogalicia stores 14 days of operational forecasts
    ## After 14 days the forecasts are moved to the WRF_HIST folder
    if (today - day <= 14) {
        mainURL <- 'http://mandeo.meteogalicia.es/thredds/ncss/grid/wrf_2d_'
        URL0 <- paste0(mainURL,
                       resolution,
                       '/fmrc/files/', ymd(day),
                       '/wrf_arw_det_history_d0', idxRes,
                       '_', ymd(day),
                       '_', paste0(run, '00'),
                       '.nc4')
    } else {
        ## Historical forecasts. Only run 0 is available
        mainURL <- paste0('http://mandeo.meteogalicia.es/thredds/ncss/grid/modelos/WRF_HIST/')
        year <- format(day, '%Y')
        month <- format(day, '%m')
        URL0 <- paste0(mainURL,
                       paste0('d0', idxRes, '/'),
                       year, '/',
                       month, '/',
                       'wrf_arw_det_history_',
                       paste0('d0', idxRes, '_'),
                       ymd(day),
                       '_', '0000',
                       '.nc4')
    } 
   if (!is.null(var)) {
        paste0(URL0, '?var=', var, spatial, timeFrame)
    } else {
        URL0
    }
}

##################################################################
## Global Forecast
##################################################################
urlGFS <- function(var, day, run, spatial, timeFrame, vertical, ...) {
    Ym <- format(day, format='%Y%m')
    mainURL <- 'http://nomads.ncdc.noaa.gov/thredds/ncss/grid/gfs-004/'
    run <- paste0(run, '00')
    timeFrame <- sprintf('%03d', timeFrame)
    URL0 <- paste0(mainURL, Ym, '/', ymd(day), '/',
                   'gfs_4_', ymd(day), '_', run, '_', timeFrame,
                   '.grb2')
    if (!is.null(var)) {
        paste0(URL0, '?var=', var, vertical, spatial)
    } else {
        URL0
    }
}

##################################################################
## North American Mesoscale Forecast System (NAM) 
##################################################################
urlNAM <- function(var, day, run, spatial, timeFrame, vertical, ...) {
    today <- Sys.Date()
    Ym <- format(day, format='%Y%m')
    ## NAM stores the last year results under the category "Near Real-Time"
    if (today - day < 365) {
        mainURL <- 'http://nomads.ncdc.noaa.gov/thredds/ncss/grid/nam218/'
        servId <- 'nam_218'
    } else {
        ## Previous results can be found under "Analysis only"
        mainURL <- 'http://nomads.ncdc.noaa.gov/thredds/ncss/grid/namanl/'
        servId <- 'namanl_218'
    }

    run <- paste0(run, '00')
    timeFrame <- sprintf('%03d', timeFrame)
    
    URL0 <- paste0(mainURL, Ym, '/', ymd(day), '/',
                   servId, '_',
                   ymd(day), '_',
                   run, '_',
                   timeFrame,
                   '.grb')
    if (!is.null(var)) {
        paste0(URL0, '?var=', var, vertical, spatial)
    } else {
        URL0
    }
}

##################################################################
## Rapid Refresh (RAP) 
##################################################################
urlRAP <- function(var, day, run, spatial, timeFrame, vertical, ...) {
    Ym <- format(day, format='%Y%m')
    mainURL <- 'http://nomads.ncdc.noaa.gov/thredds/ncss/grid/rap130/'
    run <- paste0(run, '00')
    timeFrame <- sprintf('%03d', timeFrame)
    URL0 <- paste0(mainURL, Ym, '/', ymd(day), '/',
                   'rap_130_', ymd(day), '_', run, '_', timeFrame,
                   '.grb2')
    if (!is.null(var)){
        paste0(URL0, '?var=', var, vertical, spatial)
    } else {
        URL0
    }
}

