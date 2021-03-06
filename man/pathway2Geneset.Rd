\name{pathway2Geneset}
\alias{pathway2Geneset}
\title{This function generates the gene set of a pathway.}
\usage{
pathway2Geneset(biopax, pwid, returnIDonly = FALSE, biopaxlevel = 3)
}
\arguments{
  \item{biopax}{A biopax model}

  \item{pwid}{string}

  \item{returnIDonly}{logical. If TRUE only IDs of the
  components are returned. This saves tiem for looking up
  names for every single ID.}

  \item{biopaxlevel}{integer. Set the biopax level here if
  you supply a data.table directly.}
}
\value{
Returns the gene set of the supplied pathway. Returns NULL
if the pathway has no components.
}
\description{
This function generates a gene set of all physicalEntity's
of a pathway. First all interactions of the pathway are
retrieved and all components of these interactions are then
listed.
}
\examples{
# load data
 data(biopaxexample)
 pwid1 = "pid_p_100002_wntpathway"
 pathway2Geneset(biopax, pwid=pwid1)
}
\author{
Frank Kramer
}

