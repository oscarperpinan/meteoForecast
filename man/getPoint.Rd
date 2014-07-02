\name{getPoint}
\alias{getPoint}
\alias{getPointDays}
\alias{getPointRuns}

\title{
getPoint
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
getPoint(point, vars = "swflx", day = Sys.Date(), run = "00",
         service = "meteogalicia")

getPointDays(point, vars = "swflx", start = Sys.Date(), end,
             service = "meteogalicia")

getPointRuns(point, var = "swflx", start = Sys.Date() - 1, end = Sys.Date(),
             service = "meteogalicia") 


}
\arguments{

  \item{point}{Coordinates of the location. It can be a
    \code{SpatialPoints} or a \code{numeric} of length 2.}

  \item{var, vars}{Character. The name of the variables to retrieve. Inspect
    \code{\link{varsMG}} and \code{\link{varsOM}} to know what variables
    are available in each service. \code{getPointRuns} only allows for
    one variable.}

  \item{day}{Date or character}
  
  \item{run}{Character. The meteogalicia service executes the model at
    OOUTC and 12UTC. Therefore \code{run} can be '00' or '12'.}
  
  \item{start}{Date or character. First day of the time period to retrieve.}
  
  \item{end}{Date or character. Last day of the time period to retrieve.}

  \item{service}{Character, which service to use, 'meteogalicia' or
    'openmeteo'. Please note that the support for the 'openmeteo'
    service is still experimental and limited.}

}

\details{
%%  ~~ If necessary, more details than the description above ~~
}

\value{
  
  \code{getPoint} and \code{getPointDays} produce a \code{zoo} time
  series with a column for each variable included in \code{vars}.

  The time series returned by \code{getPoint} starts at 01UTC of
  \code{day} if \code{run = '00'} or 13UTC if \code{run = '12'}, and
  spans over 4 days (96 hours).

  The time series returned by \code{getPointDays} starts at 01UTC of
  \code{start} and finishes at 00UTC of \code{end + 1}. Each day
  comprised in the time period is constructed with the forecast outputs
  corresponding to that day. Therefore, only the first 24 values
  obtained with \code{getPoint} are used for each day.

  The time series returned by \code{getPointRuns} starts at 01UTC of
  \code{start} and finishes at 00UTC of \code{end + 1}. It has 4
  columns, named "D3_00", "D2_00", "D1_00" and "D0_00". The column
  "D3_00" corresponds to the forecast results produced 3 days before the
  time stamp of each row, and so on.
    
}

\references{
  \url{http://www.meteogalicia.es/web/modelos/threddsIndex.action}
  \url{https://openmeteoforecast.org/wiki/Main_Page}
}

\author{Oscar Perpiñán Lamigueiro with contributions from Marcelo Almeida}

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}

\examples{
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
