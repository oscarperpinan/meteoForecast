\name{getRaster}
\alias{getRaster}
\alias{getRasterDay}
\alias{getRasterDays}
\alias{checkDays}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
getRaster
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
getRaster(var = "swflx", day = Sys.Date(), run = "00",
          frames = 'complete', box, names,
          remote = TRUE, service = "meteogalicia", ...)

getRasterDay(var = "swflx", day = Sys.Date(),
             remote = TRUE, service = "meteogalicia",
             dataDir = ".", ...)

getRasterDays(var = "swflx", start = Sys.Date(), end,
              remote = TRUE, dataDir = ".", ...)


checkDays(start, end, vars, remote = FALSE, service = 'meteogalicia',
          dataDir = '.')
}

\arguments{
  
  \item{var, vars}{Character. The name of the variable (or variables in
    \code{checkDays}) to retrieve. Inspect \code{\link{varsMG}} and
    \code{\link{varsOM}} to know what variables are available in each service.}
  
  \item{day}{Date or character}
  
  \item{run}{Character. The meteogalicia service executes the model at
    OOUTC and 12UTC. Therefore \code{run} can be '00' or '12'.}
  
  \item{start}{Date or character. First day of the time period to retrieve.}
  
  \item{end}{Date or character. Last day of the time period to retrieve.}
  
  \item{frames}{Numeric. It defines the number of hourly forecasts
    (frames) to retrieve. If \code{frames = 'complete'}, the full set of
    frames is downloaded. The meteogalicia service produces 96 hourly
    forecasts (frames) with \code{run='00'} and 84 frames with
    \code{run='84'}.}
  
  \item{box}{The bounding box. A \code{\link{Extent}} or an object that
    can be coerced to that class with \code{\link{extent}}: a 2x2 matrix
    (first row: xmin, xmax; second row: ymin, ymax), vector (length=4;
    order= xmin, xmax, ymin, ymax) or list (with at least two elements,
    with names 'x' and 'y'). }
  
  \item{names}{Character. Names of the layers of the resulting
    \code{RasterBrick}. If missing, a predefined vector is assigned the
    a combination of day and hour.}
  
  \item{remote}{Logical. If \code{TRUE} (default) data is downloaded
    from the remote service. If \code{FALSE} the \code{RasterBrick} is
    produced with the files available in the local folder.}
  
  \item{service}{Character, which service to use, 'meteogalicia' or
    'openmeteo'. Please note that the support for the 'openmeteo'
    service is still experimental and limited.}
  
  \item{dataDir}{Character, path of the folder where files are stored
    (if \code{remote = 'FALSE'})}
  
  \item{\dots}{Additional arguments. Not used in \code{getRaster}.}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
  \url{http://www.meteogalicia.es/web/modelos/threddsIndex.action}
  \url{https://openmeteoforecast.org/wiki/Main_Page}
}

\author{
Oscar Perpiñán with contributions from Marcelo Almeida.
}

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
\dontrun{
## Retrieve raster data
wrf <- getRaster('temp', '2014-01-25', '00', remote=TRUE)

## Define locations

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
}
}

\keyword{raster}
\keyword{spatial}
