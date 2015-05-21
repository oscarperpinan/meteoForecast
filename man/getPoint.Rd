\name{getPoint}
\alias{getPoint}
\alias{getPointDays}
\alias{getPointRuns}
\encoding{UTF-8}

\title{NWP forecasts for a location}


\description{

  The \code{getPoint*} functions get outputs of the NWP models run by MeteoGalicia and NCEP (GFS, RAP, NAM) for a single location.

}

\usage{
getPoint(point, vars = "swflx", day = Sys.Date(), run = "00",
         resolution = NULL, vertical = NA, service = mfService())

getPointDays(point, vars = "swflx", start = Sys.Date(), end,
             service = mfService(), ...)

getPointRuns(point, var = "swflx",
             start = Sys.Date() - 1, end = Sys.Date(),
             service = mfService(), ...) 


}
\arguments{

  \item{point}{Coordinates of the location. It can be a \code{SpatialPoints} or a \code{numeric} of length 2.}

  \item{var, vars}{Character. The name of the variables to retrieve. Inspect \code{\link{varsMG}}, \code{\link{varsNAM}}, \code{\link{varsRAP}}, and \code{\link{varsGFS}} to know what variables are available in each service. \code{getPointRuns} only works with one variable.}

  \item{day}{Date or character}
  
  \item{run}{Character. The meteogalicia service executes the model at OOUTC and 12UTC. Therefore \code{run} can be '00' or '12'. With GFS and NAM \code{run} can be '00', '06', '12', and '18'.  The RAP service is run every hour.}
  
  \item{start}{Date or character. First day of the time period to retrieve.}
  
  \item{end}{Date or character. Last day of the time period to retrieve.}

  \item{resolution}{Numeric. Resolution in kilometers of the raster. Valid choices are 4, 12, and 36. It is only used with \code{service = 'meteogalicia'}.}

  \item{vertical}{Numeric. Vertical coordinate for variables with several levels. Its default value is \code{NA}, meaning that only the first level will be retained.}
  
  \item{service}{Character, which service to use, 'meteogalicia', 'gfs', 'nam', or 'rap'.}
  
  \item{...}{Additional arguments for \code{\link{getPoint}}}

}

\details{

These functions download data from the MeteoGalicia and NCEP (GFS, RAP, NAM) servers using the NetCDF Subset Service. The result is returned as a \code{zoo} time series object, with one or more csv files stored in the temporary folder (as defined by \code{tempdir()}).

}

\value{
  
  \code{getPoint} and \code{getPointDays} produce a \code{zoo} time series with a column for each variable included in \code{vars}.

  The time series returned by \code{getPoint} starts at 01UTC of \code{day} if \code{run = '00'} or 13UTC if \code{run = '12'}. It spans over 4 days (96 hours) if \code{run = '00'} or 84 hours if \code{run = '12'}.

  The time series returned by \code{getPointDays} starts at 01UTC of \code{start} and finishes at 00UTC of \code{end + 1}. Each day comprised in the time period is constructed with the forecast outputs corresponding to the 00UTC run of that day. Therefore, only the first 24 values obtained with \code{getPoint} are used for each day.

  The time series returned by \code{getPointRuns} starts at 01UTC of \code{start} and finishes at 00UTC of \code{end + 1}. It has 4 columns, named "D3_00", "D2_00", "D1_00" and "D0_00". The column "D3_00" corresponds to the forecast results produced 3 days before the time stamp of each row, and so on.
    
}

\author{Oscar Perpiñán Lamigueiro with contributions from Marcelo Almeida}

\seealso{
  \code{\link{getRaster}}

  \code{\link{varsMG}}

  \code{\link{varsNAM}}

  \code{\link{varsRAP}}

  \code{\link{varsGFS}}
}

\examples{
\dontrun{
  ## temperature (Kelvin) forecast from meteogalicia
  tempK <- getPoint(c(0, 40), vars = 'temp')
  ## Cell does not coincide exactly with request
  attr(tempK, 'lat')
  attr(tempK, 'lon')
  ## Units conversion
  tempC <- tempK - 273

  library(lattice)
  ## Beware: the x-axis labels display time using your local timezone.
  Sys.timezone()

  ## Use Sys.setenv(TZ = 'UTC') to produce graphics with the timezone
  ## of the objects provided by meteoForecast.
  xyplot(tempC)

  ## Multiple variables
  vars <- getPoint(c(0, 40), vars = c('swflx', 'temp'))
  xyplot(vars)

  ## Vertical coordinates
  tempK1000 <- getPoint(c(101,6), vars = "Temperature", day = "2014-10-22",
                         service ="gfs", vertical = 1000)

  ## Time sequence
  radDays <- getPointDays(c(0, 40), start = '2015-01-01',
                          end = '2015-01-15')
  
  xyplot(radDays)

  ## Variability between runs
  radRuns <- getPointRuns(c(0, 40), start = '2015-01-01',
                          end = '2015-01-15')
  xyplot(radRuns, superpose = TRUE)
  
  ## variability around the average
  radAv <- rowMeans(radRuns)
  radVar <- sweep(radRuns, 1, radAv)
  xyplot(radVar, superpose = TRUE)
}
}
\keyword{spatial}
\keyword{time series}
