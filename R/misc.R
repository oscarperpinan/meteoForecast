## Day as character using YearMonthDay format
ymd <- function(x) format(x, format='%Y%m%d')

## Check is the point (lon, lat) is inside a bounding box defined by `box`
isInside <- function(lon, lat, box){
    (lat <= ymax(box) & lat >= ymin(box)) &
        (lon <= xmax(box) & lon >= xmin(box))
}
