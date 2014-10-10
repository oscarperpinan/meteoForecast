rasterGFS <- function(var, day = Sys.Date(), run = '00',
                      frames = 'complete',
                      box = NULL, names = NULL, remote = TRUE,
                      use00H = FALSE, ...) {
    if (is.null(box))
        ext <- mfExtent('gfs')
    else ext <- extent(box)

    ## GFS uses 0..360 for longitude. However, box is defined inside
    ## -180..180. Therefore, we have to divide `box` into the east and
    ## west hemispheres, and download separate rasters for each of them
    east <- extent(0, 180, -90, 90)
    eastExt <- intersect(ext, east)
    if (!is.null(eastExt)) {
        eastRaster <- rasterGFSBasic(var = var, day = day, run = run,
                                     frames = frames,
                                     box = eastExt,
                                     names = names, remote = remote,
                                     use00H = use00H, ...)
    }
    west <- extent(-180, 0, -90, 90)    
    westExt <- intersect(ext, west)
    if (!is.null(westExt)){
        ## The west hemisphere longitudes have to be adapted to the
        ## GFS requirements.
        westExt@xmin <- 360 + westExt@xmin
        westExt@xmax <- 360 + westExt@xmax
        westRaster <- rasterGFSBasic(var = var, day = day, run = run,
                                     frames = frames,
                                     box = westExt,
                                     names = names, remote = remote,
                                     use00H = use00H, ...)
    }
    ## Final: merge the east and west rasters, using `rotate` to
    ## change the longitudes of `westRaster` to -180..0.
    if (is.null(eastExt) & is.null(westExt))
        stop(' incorrect box definition.')
    if (is.null(eastExt)) {
        b <- shift(westRaster, -360)
    } else if (is.null(westExt)) {
        b <- eastRaster
    } else {
        ## Sometimes NOMADS produces 503 Service Unavailable so the
        ## eastRaster and westRaster may contain different layers. On
        ## the other hand, the `merge` function does not check the
        ## z-slot when joining layers. Thus, we have to use only the
        ## layers that intersect.
        EiW <- which(getZ(eastRaster) %in% getZ(westRaster))
        WiE <- which(getZ(westRaster) %in% getZ(eastRaster))
        
        b <- merge(eastRaster[[EiW]],
                   shift(westRaster[[WiE]], -360))
        ## `merge` drops the z-slot and the names
        b <- setZ(b, getZ(eastRaster)[EiW])
        names(b) <- names(eastRaster)[EiW]
    }
    b
}

