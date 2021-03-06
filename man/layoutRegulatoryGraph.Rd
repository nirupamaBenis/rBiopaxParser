\name{layoutRegulatoryGraph}
\alias{layoutRegulatoryGraph}
\title{This function generates a (more or less) beautiful layout for a regulatory graph.}
\usage{
layoutRegulatoryGraph(mygraph, label = "", node.fixedsize = FALSE,
  edge.weights = c("green", "black", "red"), edge.arrowheads = c("normal",
  "tee"), subgraphs = list(), subgraphs.colors = c("#B3E2CD", "#FDCDAC",
  "#F4CAE4", "#E6F5C9", "#FFF2AE"))
}
\arguments{
  \item{mygraph}{graphNEL}

  \item{label}{Label of the graph}

  \item{node.fixedsize}{logical. If font size is fixed or
  variable in regards to the nodes.}

  \item{edge.weights}{vector. which colors to use for
  weighted edges}

  \item{edge.arrowheads}{vector. which arrowheads to use
  for weighted edges}

  \item{subgraphs}{A list of character vectors with node
  names defining the sub graphs.}

  \item{subgraphs.colors}{vector. which colors to use for
  subgraphs}
}
\value{
Returns the supplied graph in a layouted form with several
parameters set for regulatory graph plotting.
}
\description{
This function generates a (more or less) beautiful layout
for a regulatory graph. Call this after you generated a
graph with pathway2RegulatoryGraph. Since beauty is always
in the eye of the beholder consider this a starting point
for making your graphs even nicer. Rgraphviz with dot
layout is used. Edges are green/red with normal/tee
arrowheads for activations/inhibitions. If you want to
specifically paint subgraphs in different colors use lists
of vectors with node names for parameter subgraphs and
vector of color names for subgraphs.color for your choice
of color. The output can be further tweaked by setting
layout options using nodeRenderInfo(mygraph) <- list() ...
See the Rgraphviz and Graphviz documentations.
}
\author{
Frank Kramer
}

