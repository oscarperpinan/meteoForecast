\name{options}
\alias{getMFOption}
\alias{setMFOption}
\alias{mfService}
\alias{mfExtent}
\alias{mfProj4}
\encoding{UTF-8}

\title{
Options and Internal Variables
}
\description{
Functions to get or set options, and to access internal parameters of
the package.
}
\usage{
getMFOption(name = NULL)
setMFOption(name, value)
mfService(service = NULL)
mfExtent(service, resolution = 12)
mfProj4(service)

}

\arguments{ \item{name}{Character, name of the option to get or set.}
  \item{value}{Character, value of the option to be changed.}
  \item{service}{Character, name of the service.}
  \item{resolution}{Numeric, value of the resolution (in
  kilometers). Only useful if \code{service = 'meteogalicia'}} }
  \details{ Use \code{getMFOption} to list the options of the
  package. Only one option, \code{service}, is available with this
  version. With \code{setMFOption} the option defined with \code{name}
  can be modified.

  \code{mfService}, a wrapper around \code{getMFOption} and
  \code{setMFOption}, displays the default service if used without
  arguments. It modifies the default service to the value of its
  argument.

  \code{mfExtent} and \code{mfProj4} provides the extent and the proj4
  string of the corresponding service.
  
}

\author{
Oscar Perpiñán Lamigueiro
}

\examples{
mfService()

mfExtent('meteogalicia', 36)

mfExtent('nam')

mfProj4('rap')
}

