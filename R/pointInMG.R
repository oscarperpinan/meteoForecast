pointInMG <-
    function(lon, lat){
        ext <- extent(-21.57982593066231, 6.358561301098035,
                      33.63652645596269, 49.56899908853894)
        isInside <- (lat <= ymax(ext) & lat >= ymin(ext)) &
            (lon <= xmax(ext) & lon >= xmin(ext))
        isInside
    }
