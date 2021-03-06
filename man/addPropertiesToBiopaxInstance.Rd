\name{addPropertiesToBiopaxInstance}
\alias{addPropertiesToBiopaxInstance}
\title{This function adds new properties to an existing biopax instance.}
\usage{
addPropertiesToBiopaxInstance(biopax, id, properties)
}
\arguments{
  \item{biopax}{A biopax model}

  \item{id}{string. ID of the instance}

  \item{properties}{named list of properties.}
}
\value{
Returns the supplied biopax model with new properties added
to this instance.
}
\description{
This function adds new properties to an existing biopax
instance.
}
\examples{
biopax = createBiopax(level=2)
biopax = addBiopaxInstance(biopax, class="protein", id="id1", properties=list(NAME="protein1",SYNONYMS="p1"))
biopax$dt
biopax = addPropertiesToBiopaxInstance(biopax, id="id1", properties=list(COMMENT="this is my first protein!"))
biopax$dt
}
\author{
Frank Kramer
}

