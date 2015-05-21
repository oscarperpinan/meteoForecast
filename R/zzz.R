.mfEnv <- new.env()

## Internal variables
.onLoad <- function(libname, pkgname)
{
## Package options
assign('mfOptions',
       list(
           ## Default service
           service = 'meteogalicia'
           ),
       envir = .mfEnv)

## Available services
assign('services',
       c('meteogalicia',
         'gfs',
         'nam',
         'rap'),
       envir = .mfEnv)
##################################################################
## Projections
##################################################################
## Projection parameters are either not well defined in the
## NetCDF files or incorrectly read by raster.
## Provided by gdalsrsinfo

assign("projections",
       list(
           gfs = "+proj=longlat +datum=WGS84",
           meteogalicia = "+proj=lcc +lat_1=43 +lat_2=43 +lat_0=34.82300186157227 +lon_0=-14.10000038146973 +x_0=536402.34 +y_0=-18558.61 +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=km +no_defs",
           nam = '+proj=lcc +lat_1=25 +lat_0=25 +lon_0=-95 +k_0=1 +x_0=0 +y_0=0 +a=6367470.21484375 +b=6367470.21484375 +units=km +no_defs ',
           rap = '+proj=lcc +lat_1=25 +lat_0=25 +lon_0=265 +k_0=1 +x_0=0 +y_0=0 +a=6371229 +b=6371229 +units=km +no_defs'
           ),
       envir = .mfEnv)

##################################################################
## Bounding Boxes
##################################################################
## Extracted from their WMS pages

assign("extents",
       list(
           gfs = c(-180, 180, -90, 90),
           nam = c(-153.03033819796906, -49.27221021871827,
               12.11335916285993, 57.369653102840736),
           rap = c(-139.96990801797577, -57.26853769473695,
               16.20865504970344, 55.516756978864535),
           meteogalicia4 = c(-11.261331695726343, -5.101928395629246,
               40.421302033295945, 45.230011083267385),
           meteogalicia12 = c(-21.57982593066231, 6.358561301098035,
               33.63652645596269, 49.56899908853894),
           meteogalicia36 = c(-49.18259341789055, 18.788995948788816,
               24.03791184287805, 56.066076511429685)
           ),
       envir = .mfEnv)

##################################################################
## Runs, time resolution, and forecast horizon of each service
##################################################################

       
assign("runs",
       list(
           gfs = c('00', '06', '12', '18'),
           meteogalicia = c('00', '12'),
           nam = c('00', '06', '12', '18'),
           rap = sprintf('%02d', 0:23)
           ),
       envir = .mfEnv)

assign("tRes",
       list(
           gfs = 3,
           meteogalicia = 1,
           nam = 1,
           rap = 1),
       envir = .mfEnv)

assign("horizon",
       list(
           gfs = 192,
           meteogalicia = 96, ## run 00
           nam = 84,
           rap = 18),
       envir = .mfEnv)
}


    
