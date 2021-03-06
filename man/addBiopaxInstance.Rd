\name{addBiopaxInstance}
\alias{addBiopaxInstance}
\title{This function adds a new instance to an existing biopax model.}
\usage{
addBiopaxInstance(biopax, class, id, properties = list(NAME = c()),
  verbose = TRUE)
}
\arguments{
  \item{biopax}{A biopax model}

  \item{class}{string. Class name}

  \item{id}{string. ID of the instance}

  \item{properties}{named list of properties.}

  \item{verbose}{logical. Be verbose about what was added.}
}
\value{
Returns the supplied biopax model with the new instance
added.
}
\description{
This function adds a new instance to an existing biopax
model. "properties" is a named list of vectors, with the
vector name as the name of the property and every entry of
the vector a property value. Please note: case sensitivity!
In Biopax Level 2 all properties are written in all capital
letters. This will change in Biopax Level 3.
}
\examples{
biopax = createBiopax(level=2)
biopax = addBiopaxInstance(biopax, class="protein", id="id1", properties=list(NAME="protein1",SYNONYMS="p1"))
biopax$dt
}
\author{
Frank Kramer
}

