\name{hasProperty}
\alias{hasProperty}
\title{Checks if instances in the biopax data.table have a given property}
\usage{
hasProperty(df, property)
}
\arguments{
  \item{df}{A data.frame with biopax instances}

  \item{property}{A string containing the name of the
  property to check for}
}
\value{
Returns TRUE for every row in the data.frame with contains
the supplied property. Logical vector with length
corresponding to the number of rows in the data.frame.
}
\description{
Checks if instances in the biopax data.table have a given
property
}
\author{
Frank Kramer
}

