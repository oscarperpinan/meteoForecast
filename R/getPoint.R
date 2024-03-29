getPoint <- function(point, vars = 'swflx',
                     day = Sys.Date(), run = '00',
                     resolution = NULL, vertical = NA,
                     service = mfService()){

    
    service <- matchService(service)

    ## Extract longitude-latitude
    if (is(point, 'SpatialPoints')) {
        if (!isLonLat(point)) {
            if (requireNamespace('sf', quietly=TRUE)) 
                point <- as(sf::st_transform(
                                    sf::st_as_sf(point),
                                    sf::st_crs(CRS('+proj=longlat +ellps=WGS84'))),
                            "Spatial")
            else stop('`sf` is needed if `point` is projected.')
        }

        lat <- coordinates(point)[2]
        lon <- coordinates(point)[1]
    } else { ## point is a numeric of length 2
        lat <- point[2]
        lon <- point[1]
    }
    ## Which function to use?
    fun <- switch(service,
                  meteogalicia = 'pointMG',
                  gfs = 'pointGFS',
                  nam = 'pointNAM',
                  rap = 'pointRAP')
    ## Ok, use it.
    z <- do.call(fun, list(lon = lon, lat = lat,
                           vars = vars,
                           day = as.Date(day),
                           run = run,
                           resolution = resolution,
                           vertical = vertical))
}
