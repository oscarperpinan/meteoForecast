## Day as character using YearMonthDay format
ymd <- function(x) format(x, format='%Y%m%d')


##################################################################
## Projections
##################################################################

projMG <- "+proj=lcc +lat_1=43 +lat_2=43 +lat_0=34.82300186157227 +lon_0=-14.10000038146973 +x_0=536402.34 +y_0=-18558.61 +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=km +no_defs"

projNAM <- '+proj=lcc +lat_1=25 +lat_0=25 +lon_0=-95 +k_0=1 +x_0=0 +y_0=0 +a=6367470.21484375 +b=6367470.21484375 +units=km +no_defs '

projRAP <- '+proj=lcc +lat_1=25 +lat_0=25 +lon_0=265 +k_0=1 +x_0=0 +y_0=0 +a=6371229 +b=6371229 +units=km +no_defs'

projOM <- "+proj=lcc +lon_0=4 +lat_0=47.5 +lat_1=47.5 +lat_2=47.5 +a=6370000. +b=6370000. +no_defs"

projGFS <- "+proj=longlat +datum=WGS84"

##################################################################
## Bounding Boxes
##################################################################

## Check is the point (lon, lat) is inside a bounding box defined by
## `box`
isInside <- function(lon, lat, box){
    (lat <= ymax(box) & lat >= ymin(box)) &
        (lon <= xmax(box) & lon >= xmin(box))
}

## Extracted from their WCS pages
bbMG <- extent(-21.57982593066231, 6.358561301098035,
               33.63652645596269, 49.56899908853894)

bbNAM <- extent(-153.03033819796906, -49.27221021871827,
                12.11335916285993, 57.369653102840736)

bbRAP <- extent(-139.96990801797577, -57.26853769473695,
                16.20865504970344, 55.516756978864535)

bbOM <- extent(-45.66076, 53.66080, 26.36829, 55.27661)



