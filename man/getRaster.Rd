\name{getRaster}
\alias{getRaster}
\alias{getRasterDays}
\alias{getRasterDay}
\alias{checkDays}
\encoding{UTF-8}

\title{NWP forecasts for a region}

\description{

  The \code{getRaster*} functions get outputs of the NWP models for a region.

}

\usage{

getRaster(var = "swflx", day = Sys.Date(), run = "00",
          frames = 'complete', box, resolution = NULL,
          names, remote = TRUE, service = mfService(),
          dataDir = ".", use00H = FALSE, ...)

getRasterDays(var = "swflx", start = Sys.Date(), end,
              remote = TRUE, dataDir = ".", ...)

getRasterDay(var = "swflx", day = Sys.Date(),
              remote = TRUE, dataDir = ".", ...)

checkDays(start, end, vars, remote = FALSE,
          service = mfService(), dataDir = '.')
}

\arguments{
  
  \item{var, vars}{Character. The name of the variable (or variables in \code{checkDays}) to retrieve. Use \code{\link{grepVar}} to know what variables are available in each service.}
  
  \item{day}{Date or character. In \code{getRaster} it defines the day when the forecast was produced. In \code{getRasterDay} it defines the day to be forecast.}
  
  \item{run}{Character. For example, the meteogalicia service executes the model at OOUTC and 12UTC. Therefore \code{run} can be '00' or '12'.}
  
  \item{start}{Date or character. First day of the time period to retrieve.}
  
  \item{end}{Date or character. Last day of the time period to retrieve.}
  
  \item{frames}{Numeric. It defines the number of hourly forecasts (frames) to retrieve. If \code{frames = 'complete'}, the full set of frames is downloaded. For example, the meteogalicia service produces 96 hourly forecasts (frames) with \code{run='00'} and 84 frames with \code{run='12'}.}
  
  \item{box}{The bounding box, defined using longitude and latitude values. A \code{\link{Extent}} or an object that can be coerced to that class with \code{\link{extent}}: a 2x2 matrix (first row: xmin, xmax; second row: ymin, ymax), vector (length=4; order= xmin, xmax, ymin, ymax) or list (with at least two elements, with names 'x' and 'y'). }

  \item{resolution}{Numeric. Resolution in kilometers of the raster. Valid choices are 4, 12, and 36. It is only used with \code{service = 'meteogalicia'}.}

  \item{names}{Character. Names of the layers of the resulting \code{RasterBrick}. If missing, a predefined vector is assigned the combination of day and hour.}
  
  \item{remote}{Logical. If \code{TRUE} (default) data is downloaded from the remote service. If \code{FALSE} the \code{RasterBrick} is produced with the files available in the local folder.}
  
  \item{service}{Character, which service to use, 'meteogalicia', 'gfs', 'nam' or 'rap'.}

  \item{use00H}{Logical. Only used when \code{service} is 'gfs', 'nam', or 'rap'. If \code{FALSE} (default), the first frame of each run or 00H "forecast" is not considered. This first frame is only produced for some variables. Therefore, with \code{use00H = TRUE} fewer frames that the number defined with \code{frames} could be obtained for some variables.)}

  \item{dataDir}{Character, path of the folder where files are stored (if \code{remote = 'FALSE'})}
  
  \item{\dots}{Additional arguments. Not used in \code{getRaster}.}
}

\details{
  
  \code{getRaster} downloads data from the MeteoGalicia and NCDC (GFS,
  RAP, and NAM) servers using the NetCDF Subset Service. The result is returned as a \code{RasterBrick} object, with one or more NetCDF files stored in the temporary folder (as defined by \code{tempdir()}). Each frame or layer of the \code{RasterBrick} corresponds to a certain hour of the forecast.

  \code{getRasterDay} uses \code{getRaster} to download the results corresponding to a certain \code{day}. If the \code{day} is in the future, the most recent forecast is downloaded with \code{getRaster}, and the corresponding frames are extracted. If the \code{day} is in the past, \code{getRaster} is used to download the corresponding frames of the forecast produced that day.
  
  \code{getRasterDays} uses \code{getRaster} to download the results cast each day comprised between \code{start} and \code{end} using the 00UTC run. Then it subsets the first 24 frames of each result, and binds them together to produce a \code{RasterBrick}. Therefore, each frame of this \code{RasterBrick} is a forecast for an hour of the day when the forecast was cast.

  \code{checkDays} explores a local folder looking for NetCDF files corresponding to a time sequence and a set of variables. It returns a \code{Date} vector comprising the days with files available for the requested variables. If \code{remote = TRUE} it only checks that \code{start} is after 2008-01-01 (first date of the archived forecasts of MeteoGalicia.)  }

\value{

  The \code{getRaster*} functions return a \code{RasterBrick} with a layer for each hour of the NWP forecast.

  The time zone of the time index of this \code{RasterBrick}, stored in its \code{z} slot (accesible with \code{\link{getZ}}) is UTC.

  MeteoGalicia, NAM, and RAP use the Lambert Conic Conformal projection. GFS files use longitude-latitude coordinates.

}

\references{
  \url{http://www.meteogalicia.es/web/modelos/threddsIndex.action}

  \url{https://www.ncei.noaa.gov/thredds/catalog/gfs-004-files/catalog.html}

  \url{https://www.ncei.noaa.gov/thredds/catalog/rap130/catalog.html}

  \url{https://www.ncei.noaa.gov/thredds/catalog/nam218/catalog.html}

}

\author{

  Oscar Perpiñán with contributions from Marcelo Almeida.
  
}


\examples{
\dontrun{
today <- Sys.Date()
testDay <- today - 7

## Retrieve raster data
wrf <- getRaster('temp', day = testDay)

## Display results with rasterVis
library(rasterVis)

levelplot(wrf, layers = 10:19)

hovmoller(wrf)

## Using box and frames specification
mfExtent('gfs')
cloudGFS <- getRaster('Temperature_surface',
                      day = testDay,
                      box = c(-10, 10, -10, 10),
                      service = 'gfs')

mfExtent('nam')
cloudNAM <- getRaster('Temperature_surface',
                      day = testDay,
                      box = c(-100, -80, 30, 50),
                      frames = 10,
                      service = 'nam')
mfExtent('rap')
cloudRAP <- getRaster('Temperature_surface',
                      day = testDay,
                      box = c(-100, -80, 30, 50),
                      frames = 10,
                      service = 'rap')


## Day sequence of cloud cover
wrfDays <- getRasterDays('cft',
                         start = testDay - 3,
                         end = testDay + 2,
                         box = c(-2, 35, 2, 40))

levelplot(wrfDays, layers = 10:19)

## animation
levelplot(wrfDays, layout = c(1, 1), par.settings = BTCTheme)

## Hövmoller graphic
hovmoller(wrfDays, par.settings = BTCTheme, contour = TRUE, cuts = 10)

NAMDays <- getRasterDays('Temperature_surface',
                         start = testDay - 3,
                         end = testDay + 2,
                         box = c(-100, -80, 30, 50),
                         service = 'nam')

## Extract data at some locations

st <- data.frame(name=c('Almeria','Granada','Huelva','Malaga','Caceres'),
               elev=c(42, 702, 38, 29, 448))

coordinates(st) <- cbind(c(-2.46, -3.60, -6.94, -4.42, -6.37),
                         c(36.84, 37.18, 37.26, 36.63, 39.47)
                         )
proj4string(st) <- '+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0'


## Extract values for some locations
vals <- extract(wrf, st)
vals <- zoo(t(vals), getZ(wrf))
names(vals) <- st$name

xyplot(vals)
}
}

\keyword{raster}
\keyword{spatial}
