\name{createBiopax}
\alias{createBiopax}
\title{This function creates a new Biopax model from scratch}
\usage{
createBiopax(level = 3)
}
\arguments{
  \item{level}{integer. Specifies the BioPAX level.}
}
\value{
A biopax model
}
\description{
This function creates a new Biopax model from scratch. This
is not necessary if you want to parse a BioPAX export from
a file, please see: readBiopax. Returns a biopax model,
which is a list with named elements: \describe{
\item{df}{The data.frame representing the biopax in R}
\item{ns_rdf}{RDF Namespace} \item{ns_owl}{OWL Namespace}
\item{ns_bp}{Biopax Namespace} \item{file}{NULL} }
}
\examples{
biopax = createBiopax(level=2)
}
\author{
Frank Kramer
}

