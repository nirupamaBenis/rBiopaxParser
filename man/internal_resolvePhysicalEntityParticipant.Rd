\name{internal_resolvePhysicalEntityParticipant}
\alias{internal_resolvePhysicalEntityParticipant}
\title{This function resolves physicalEntityParticipantIDs to their corresponding physicalEntityIDs}
\usage{
internal_resolvePhysicalEntityParticipant(biopax, physicalEntityId)
}
\arguments{
  \item{biopax}{A biopax model}

  \item{physicalEntityId}{string. IDs of
  physicalEntityParticipants to be resolved}
}
\value{
Returns ids of physicalEntity corresponding to the
specified physicalEntityParticipantIDs
}
\description{
This function resolves physicalEntityParticipantIDs to
their corresponding physicalEntityIDs. Every
physicalEntityParticipant corresponds exactly to one
physicalEntity.
}
\author{
fkramer
}

