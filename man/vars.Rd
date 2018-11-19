\name{Forecast variables}
\alias{grepVar}

\docType{data}
\title{
Forecast Variables available in each model.
}

\description{The \code{grepVar} retrieves the XML file with the names,
  description, and labels of each variable available in the service, and
  searches for matches in the description field.}

\usage{
grepVar(x, service, day = Sys.Date() - 15, complete = FALSE)
}

\arguments{

  \item{x}{character string to be matched in the description field of
  the set of variables. Try \code{x = ""} and \code{complete = TRUE} to
  get the complete list of choices with the description field.}

  \item{service}{Character, to choose from 'meteogalicia', 'gfs', 'nam', and 'rap'}

  \item{day}{Date. Services change the variables availability over time.}

  \item{complete}{Logical, if \code{FALSE} (default) only the
  \code{name} of the variables is returned. If \code{TRUE} the name,
  label, and description columns are provided.}  }

\value{ If \code{complete = TRUE} this function provides a
\code{data.frame} with three columns, \code{name}, \code{label}, and
\code{description}. Use the elements of the \code{name} column to choose
a variable with the argument \code{var} of \code{\link{getRaster}} and
\code{\link{getPoint}}.  }

\source{
  MeteoGalicia: \url{http://www.meteogalicia.es/web/modelos/threddsIndex.action}

  GFS: \url{https://www.ncei.noaa.gov/thredds/catalog/gfs-004-files/catalog.html}

  NAM: \url{http://www.ncei.noaa.gov/thredds/catalog/nam218/catalog.html}

  RAP: \url{http://www.ncei.noaa.gov/thredds/catalog/rap130/catalog.html}
}

\examples{

\dontrun{
## Variables available recently
grepVar('cloud', service = 'gfs', complete = TRUE)

## Variables available some time ago
grepVar('cloud', service = 'gfs',
        day = Sys.Date() - 500,
        complete = TRUE)

## You can get the complete list with x = ""
grepVar("", service = 'meteogalicia', complete = TRUE)
}
}

\keyword{datasets}
