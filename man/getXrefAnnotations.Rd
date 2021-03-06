\name{getXrefAnnotations}
\alias{getXrefAnnotations}
\title{This function returns the annotations of the supplied instances.}
\usage{
getXrefAnnotations(biopax, id, splitComplexes = FALSE,
  followPhysicalEntityParticipants = TRUE, biopaxlevel = 3)
}
\arguments{
  \item{biopax}{A biopax model}

  \item{id}{vector of strings. IDs of instances to get
  annotations}

  \item{splitComplexes}{logical. If TRUE complexes are
  split up into their components and the annotation of the
  components is added.}

  \item{followPhysicalEntityParticipants}{logical. If TRUE
  physicalEntityParticipants are resolved to their
  corresponding physicalEntities and their annotation is
  added.}

  \item{biopaxlevel}{integer. Set the biopax level here if
  you supply a data.table directly.}
}
\value{
Returns data.table with annotations
}
\description{
This function returns the annotations of the supplied IDs
in a data.table.
}
\examples{
# load data
 data(biopaxexample)
# example of annotation for a protein:
getXrefAnnotations(biopax, id="ex_m_100647")
# no annotations for exactly the complex
getXrefAnnotations(biopax, id="ex_m_100650")
# split up the complex and get annotations for all the molecules involved
getXrefAnnotations(biopax, id="ex_m_100650", splitComplexes=TRUE)
}
\author{
fkramer
}

