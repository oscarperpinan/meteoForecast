\name{getRaster}
\alias{getRaster}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
getRaster
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
getRaster(var = "swflx", day = Sys.Date(), run = "00", box = c(-10, 5, 30, 44), names, service = "meteogalicia", ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{var}{
%%     ~~Describe \code{var} here~~
}
  \item{day}{
%%     ~~Describe \code{day} here~~
}
  \item{run}{
%%     ~~Describe \code{run} here~~
}
  \item{box}{
%%     ~~Describe \code{box} here~~
}
  \item{names}{
%%     ~~Describe \code{names} here~~
}
  \item{service}{
%%     ~~Describe \code{service} here~~
}
  \item{\dots}{
%%     ~~Describe \code{\dots} here~~
}
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
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
\dontrun{
library(sp)
library(zoo)
library(raster)
library(meteo)


## Define locations

st <- data.frame(name=c('Almeria','Granada','Huelva','Malaga','Caceres'),
               elev=c(42, 702, 38, 29, 448))

coordinates(st) <- cbind(c(-2.46, -3.60, -6.94, -4.42, -6.37),
                         c(36.84, 37.18, 37.26, 36.63, 39.47)
                         )
proj4string(st) <- '+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0'

## Retrieve raster data
setwd('/path/to/my/folder/')
wrf <- getRaster('temp', '2014-01-25', '00', remote=FALSE)

## Extract values for some locations
vals <- extract(wrf, st)
vals <- zoo(t(vals), getZ(wrf))
names(vals) <- st$name
}
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
