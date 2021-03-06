###############################################################################
#
# modifyBiopax.R: 	This file contains the all functions related to modifying a parsed Biopax model within R.
# author: Frank Kramer <dev@frankkramer.de>
#
# This is released under GPL-2.
# 
# Documentation was created using roxygen
#
###############################################################################


#' This function adds new instances to an existing biopax model.
#' 
#' This function adds new instances (supplied as a compatible data.table) to an existing biopax model via rbind. Usually you want to start out at createBiopax and addPhysicalEntity and work your way up the ontology ladder.
#' 
#' @param biopax A biopax model 
#' @param newInstancesDF data.table or data.frame. Must be compatible with internal biopax implementation.
#' @return Returns the supplied biopax model with the new instances added.
#' @author Frank Kramer
#' @export
#' @import data.table
#' @examples
#' # load data
#'  data(biopaxexample)
#'  biopax_temp = createBiopax(level=2)
#'  biopax_temp = addBiopaxInstance(biopax_temp, class="protein", id="id1", properties=list(NAME="protein1",SYNONYMS="p1"))
#'  selectInstances(biopax_temp)
#'  biopax = addBiopaxInstances(biopax, selectInstances(biopax_temp))
addBiopaxInstances <- function(biopax,newInstancesDF) {
	
	if(is.null(biopax)) stop("addBiopaxInstances: parameter biopax is null")
	if(is.null(newInstancesDF) || dim(newInstancesDF)[2] != 6 || dim(newInstancesDF)[1] == 0) {
		stop(paste("addBiopaxInstances: parameter newInstancesDF is null, empty or malformed. newInstancesDF:",paste(newInstancesDF, collapse="")))
	}
	
	biopax$dt = rbindlist(list(biopax$dt, newInstancesDF))
	setkey(biopax$dt, id, class, property)
	class(biopax$dt) <- c("biopax_df",class(biopax$dt))
	biopax
}

#' This function adds a new instance to an existing biopax model.
#' 
#' This function adds a new instance to an existing biopax model.
#' "properties" is a named list of vectors, with the vector name as the name of the property and every entry of the vector a property value.
#' Please note: case sensitivity! In Biopax Level 2 all properties are written in all capital letters. This will change in Biopax Level 3.
#' 
#' @param biopax A biopax model 
#' @param class string. Class name
#' @param id string. ID of the instance
#' @param properties named list of properties.
#' @param verbose logical. Be verbose about what was added.
#' @return Returns the supplied biopax model with the new instance added.
#' @author Frank Kramer
#' @export
#' @import data.table
#' @examples
#' biopax = createBiopax(level=2)
#' biopax = addBiopaxInstance(biopax, class="protein", id="id1", properties=list(NAME="protein1",SYNONYMS="p1"))
#' biopax$dt
addBiopaxInstance <- function(biopax, class, id, properties=list(NAME=c()), verbose=TRUE) {
	if(is.null(biopax)) stop("addBiopaxInstance: parameter biopax is null")
	if(is.null(class) || class=="" ) stop(paste("addBiopaxInstance: parameter class is null or empty. class:",paste(class, collapse="")))
	if(is.null(id) || id=="" ) stop(paste("addBiopaxInstance: parameter id is null or empty.",paste(id, collapse="")))
	if(is.null(properties) || !is.list(properties) || length(properties) == 0 || length(properties[[1]]) == 0) stop(paste("addBiopaxInstance: parameter properties is null, empty or malformed.",paste(properties, collapse="")))
	
	propertyDF = internal_propertyListToDF(class, id, properties, namespace_rdf=biopax$ns_rdf, biopaxlevel = biopax$biopaxlevel)
	biopax$dt = rbindlist(list(biopax$dt,propertyDF))
	setkey(biopax$dt, id, class, property)
	class(biopax$dt) <- c("biopax_df",class(biopax$dt))
	if(verbose) message(paste("Added", class, "with ID:", id))
	biopax
}

#' This function adds new properties to an existing biopax instance.
#' 
#' This function adds new properties to an existing biopax instance.
#' 
#' @param biopax A biopax model
#' @param id string. ID of the instance
#' @param properties named list of properties.
#' @return Returns the supplied biopax model with new properties added to this instance.
#' @author Frank Kramer
#' @export
#' @import data.table
#' @examples
#' biopax = createBiopax(level=2)
#' biopax = addBiopaxInstance(biopax, class="protein", id="id1", properties=list(NAME="protein1",SYNONYMS="p1"))
#' biopax$dt
#' biopax = addPropertiesToBiopaxInstance(biopax, id="id1", properties=list(COMMENT="this is my first protein!"))
#' biopax$dt
addPropertiesToBiopaxInstance <- function(biopax,id, properties) {
	if(is.null(biopax)) stop("addPropertiesToBiopaxInstance: parameter biopax is null")
	if(is.null(id) || id=="" ) stop(paste("addPropertiesToBiopaxInstance: parameter id is null or empty.",paste(id, collapse="")))
	if(is.null(properties) || !is.list(properties) || length(properties) == 0 || length(properties[[1]]) == 0) stop(paste("addBiopaxInstance: parameter properties is null, empty or malformed.",paste(properties, collapse="")))
	
	class = getInstanceClass(biopax,id)
	propertyDF = internal_propertyListToDF(class, id, properties, namespace_rdf=biopax$ns_rdf, biopaxlevel = biopax$biopaxlevel)
	biopax$dt = rbindlist(list(biopax$dt,propertyDF))
	setkey(biopax$dt, id, class, property)
	class(biopax$dt) <- c("biopax_df",class(biopax$dt))
	biopax
}

#' Internal function to build a data.frame from the list of properties for a new instance
#' 
#' Internal function to build a data.frame from the list of properties for a new instance
#' 
#' @param class string. Class name
#' @param id string. ID of the instance
#' @param properties named list of properties.
#' @param namespace_rdf string. This defines the rdf namespace to use.
#' @param biopaxlevel integer. This sets the version of BioPAX to generate, level 2 and level 3 are supported at the moment.
#' @return Returns a data.frame with the new properties for the given instance
#' @author Frank Kramer
#' @import data.table
internal_propertyListToDF <- function(class, id, properties, namespace_rdf="rdf", biopaxlevel = 2) {
	if(is.null(class) || class=="") stop(paste("internal_propertyListToDF: parameter class is null or empty. class:",paste(class, collapse="")))
	if(is.null(id) || id=="" ) stop(paste("internal_propertyListToDF: parameter id is null or empty. id:",paste(id, collapse="")))
	if(is.null(properties) || !is.list(properties) || length(properties) == 0 || length(properties[[1]]) == 0) stop(paste("internal_propertyListToDF: parameter properties is null, empty or malformed. properties:",paste(properties, collapse="")))
	
	
	ret = data.table(class="",id="",property="",property_attr="",property_attr_value="",property_value="", key=c("id","class","property"))
	#ret = copy(ret[,2:7, with=F])
	ret = copy(ret[0])
	setkey(ret, id, class, property)
	
	
	#every property of an instance is represented as 1 entry in the dt
	rowcount = 1
	
	classproperties = getClassProperties(class, biopaxlevel=biopaxlevel )
	
	for(n in names(properties)) {
		
		# find out if this is a value or a reference
		property_type = unlist(classproperties[tolower(classproperties$property) == tolower(n),]$property_type)[1]
		
		for(p in properties[[n]]) {
			#value
			if(grepl("string",property_type) || grepl("double",property_type) || grepl("float",property_type) || grepl("integer",property_type)) {
				ret = rbindlist(list(ret, list(
						class=class, id=id,
						property=n, #property				
						property_attr=paste(namespace_rdf,":datatype",sep=""), #property_attr
						property_attr_value=property_type, #property_attr_value
						property_value=p #property_value
				)))
			} else { #reference
				ret = rbindlist(list(ret, list(
						class=class, id=id,
						property=n, #property				
						property_attr=paste(namespace_rdf,":resource",sep=""), #property_attr
						property_attr_value=paste("#",p,sep=""), #property_attr_value
						property_value="" #property_value
				)))
			}
			rowcount = rowcount + 1
		}
	}
	ret
	
}


#' This function adds a new pathway to the biopax model.
#' 
#' This function adds a new pathway + its PATHWAY-COMPONENTS (references to interaction/pathways/pathwaySteps)
#' 
#' @param biopax A biopax model 
#' @param NAME string. Name of the pathway
#' @param PATHWAY_COMPONENTS character vector. IDs of the pathway components. This must be IDs of instances of type interaction/pathway/pathwayStep (or their subclasses).
#' @param id string. ID for the pathway. If NULL a new ID is generated with prefix "pathway".
#' @param ORGANISM string. Organism property of the pathway. optional.
#' @param COMMENT string. An optional comment 
#' @return Returns the biopax model with the added pathway.
#' @author fkramer
#' @export
#' @import data.table
#' @examples
#' biopax = createBiopax(level=2)
#' biopax = addPhysicalEntity(biopax, class="protein", id="p_id1", NAME="protein1")
#' biopax = addPhysicalEntityParticipant(biopax, "p_id1", id="PEP_p_id1")
#' biopax = addPhysicalEntity(biopax, class="protein", id="p_id2", NAME="protein2")
#' biopax = addPhysicalEntityParticipant(biopax, "p_id2", id="PEP_p_id2")
#' biopax = addBiochemicalReaction(biopax, LEFT=c("PEP_p_id1"), RIGHT=c("PEP_p_id2"), id="biochem_id_1")
#' biopax = addPhysicalEntity(biopax, class="protein", id="p_id3", NAME="controllerProtein1")
#' biopax = addPhysicalEntityParticipant(biopax, "p_id3", id="PEP_p_id3")
#' biopax = addControl(biopax, CONTROL_TYPE="ACTIVATION", CONTROLLER="PEP_p_id3", CONTROLLED="biochem_id_1", id="c_id1")
#' biopax = addPathway(biopax, NAME="mypathway1", PATHWAY_COMPONENTS=c("c_id1"), id="pw_id1")
#' biopax$dt
addPathway <- function(biopax, NAME, PATHWAY_COMPONENTS=c(), id=NULL, ORGANISM=NULL, COMMENT=NULL) {
	var_id = id
	rm(id)
	
	if(is.null(var_id)) var_id = generateNewUniqueID(biopax, id="pathway")
	if( var_id %chin% biopax$dt$id ) var_id = generateNewUniqueID(biopax, id=var_id)
	
	#support for bp level 2 and 3
	if(biopax$biopaxlevel == 2) {
		properties = list(NAME=c(NAME),'PATHWAY-COMPONENTS'=PATHWAY_COMPONENTS)
		if(!is.null(ORGANISM)) properties['ORGANISM']=c(ORGANISM)
		if(!is.null(COMMENT)) properties['COMMENT']=c(COMMENT)
		biopax = addBiopaxInstance(biopax, class="pathway", id=var_id, properties=properties)
	}
	if(biopax$biopaxlevel == 3) {
		properties = list(name=c(NAME),'pathwayComponent'=PATHWAY_COMPONENTS)
		if(!is.null(ORGANISM)) properties['organism']=c(ORGANISM)
		if(!is.null(COMMENT)) properties['comment']=c(COMMENT)
		biopax = addBiopaxInstance(biopax, class="Pathway", id=var_id, properties=properties)
	}

	biopax
}

#' This function adds pathway components to an existing pathway
#' 
#' This function adds pathway components to an existing pathway.
#' Property PATHWAY-COMPONENTS  are references to IDs of interaction/pathways/pathwaySteps (or subclasses of those)
#' 
#' @param biopax A biopax model
#' @param id string. ID for the pathway
#' @param PATHWAY_COMPONENTS character vector. IDs of the pathway components. This must be IDs of instances of type interaction/pathway/pathwayStep (or their subclasses).
#' @return Returns the biopax model with the pathway components added to the pathway
#' @author fkramer
#' @export
#' @import data.table
#' @examples
#' biopax = createBiopax(level=2)
#' biopax = addPhysicalEntity(biopax, class="protein", id="p_id1", NAME="protein1")
#' biopax = addPhysicalEntityParticipant(biopax, "p_id1", id="PEP_p_id1")
#' biopax = addPhysicalEntity(biopax, class="protein", id="p_id2", NAME="protein2")
#' biopax = addPhysicalEntityParticipant(biopax, "p_id2", id="PEP_p_id2")
#' biopax = addBiochemicalReaction(biopax, LEFT=c("PEP_p_id1"), RIGHT=c("PEP_p_id2"), id="biochem_id_1")
#' biopax = addPhysicalEntity(biopax, class="protein", id="p_id3", NAME="controllerProtein1")
#' biopax = addPhysicalEntityParticipant(biopax, "p_id3", id="PEP_p_id3")
#' biopax = addControl(biopax, CONTROL_TYPE="ACTIVATION", CONTROLLER="PEP_p_id3", CONTROLLED="biochem_id_1", id="c_id1")
#' biopax = addPathway(biopax, NAME="mypathway1", PATHWAY_COMPONENTS=c(), id="pw_id1")
#' biopax = addPathwayComponents(biopax, id="pw_id1", PATHWAY_COMPONENTS=c("c_id1"))
#' biopax$dt
addPathwayComponents <- function(biopax, id, PATHWAY_COMPONENTS=c()) {
	#support for bp level 2 and 3
	if(biopax$biopaxlevel == 2) {
		properties = list('PATHWAY-COMPONENTS'=PATHWAY_COMPONENTS)
	}
	if(biopax$biopaxlevel == 3) {
		properties = list('pathwayComponent'=PATHWAY_COMPONENTS)
	}
	
	biopax = addPropertiesToBiopaxInstance(biopax, id=id, properties=properties)
	biopax
}

#' This function adds a new control to the biopax model.
#' 
#' This function adds a new interaction of class control to the biopax model. This is a convenience function to add controls,
#' internally the function addBiopaxInstance is called with properties CONTROL-TYPE, CONTROLLER and CONTROLLED set.
#' 
#' @param biopax A biopax model
#' @param CONTROL_TYPE string. Specifies wether this is an activating or inhibiting control.
#' @param CONTROLLER string. ID of the physicalEntityParticipant instance that is the controller of this interaction.
#' @param CONTROLLED vector of strings. IDs of the interaction and/or pathway instances that are being controlled.
#' @param id string. ID for the control. If NULL a new ID is generated with prefix "control". 
#' @return Returns the biopax model with the added pathway.
#' @author fkramer
#' @export
#' @import data.table
#' @examples
#' biopax = createBiopax(level=2)
#' biopax = addPhysicalEntity(biopax, class="protein", id="p_id1", NAME="protein1")
#' biopax = addPhysicalEntityParticipant(biopax, "p_id1", id="PEP_p_id1")
#' biopax = addPhysicalEntity(biopax, class="protein", id="p_id2", NAME="protein2")
#' biopax = addPhysicalEntityParticipant(biopax, "p_id2", id="PEP_p_id2")
#' biopax = addBiochemicalReaction(biopax, LEFT=c("PEP_p_id1"), RIGHT=c("PEP_p_id2"), id="biochem_id_1")
#' biopax = addPhysicalEntity(biopax, class="protein", id="p_id3", NAME="controllerProtein1")
#' biopax = addPhysicalEntityParticipant(biopax, "p_id3", id="PEP_p_id3")
#' biopax = addControl(biopax, CONTROL_TYPE="ACTIVATION", CONTROLLER="PEP_p_id3", CONTROLLED="biochem_id_1", id="c_id1")
#' biopax$dt
addControl <- function(biopax, CONTROL_TYPE=c("ACTIVATION","INHIBITION"), CONTROLLER="", CONTROLLED=c(), id=NULL) {
	var_id = id
	rm(id)
	
	if(is.null(var_id)) var_id = generateNewUniqueID(biopax, id="control")
	if( var_id %chin% biopax$dt$id ) var_id = generateNewUniqueID(biopax, id=var_id)
	
	if(biopax$biopaxlevel == 2) {
		properties = list('CONTROL-TYPE'=c(CONTROL_TYPE[1]), CONTROLLER=c(CONTROLLER), CONTROLLED=CONTROLLED)
		biopax = addBiopaxInstance(biopax, class="control", id=var_id, properties=properties)
	}
	if(biopax$biopaxlevel == 3) {
		properties = list('controlType'=c(CONTROL_TYPE[1]), controller=c(CONTROLLER), controlled=CONTROLLED)
		biopax = addBiopaxInstance(biopax, class="Control", id=var_id, properties=properties)
	}
		
	biopax
}

#' This function adds a new biochemical reaction to the biopax model.
#' 
#' This function adds a new biochemical reaction of class biochemicalReaction to the biopax model. This is a convenience function,
#' internally the function addBiopaxInstance is called with properties LEFT and RIGHT set.
#' 
#' @param biopax A biopax model
#' @param LEFT vector of strings. IDs of the physicalEntityParticipant instances that are on the left side of this reaction.
#' @param RIGHT vector of strings. IDs of the physicalEntityParticipant instances that are on the right side of this reaction.
#' @param id string. ID for the control. If NULL a new ID is generated with prefix "biochemicalReaction". 
#' @return Returns the biopax model with the added pathway.
#' @author fkramer
#' @export
#' @import data.table
#' @examples
#' biopax = createBiopax(level=2)
#' biopax = addPhysicalEntity(biopax, class="protein", id="p_id1", NAME="protein1")
#' biopax = addPhysicalEntityParticipant(biopax, "p_id1", id="PEP_p_id1")
#' biopax = addPhysicalEntity(biopax, class="protein", id="p_id2", NAME="protein2")
#' biopax = addPhysicalEntityParticipant(biopax, "p_id2", id="PEP_p_id2")
#' biopax = addBiochemicalReaction(biopax, LEFT=c("PEP_p_id1"), RIGHT=c("PEP_p_id2"), id="biochem_id_1")
#' biopax$dt
addBiochemicalReaction <- function(biopax, LEFT=c(), RIGHT=c(), id=NULL) {
	var_id = id
	rm(id)
	
	if(is.null(var_id)) var_id = generateNewUniqueID(biopax, id="biochemicalReaction")
	if( var_id %chin% biopax$dt$id ) var_id = generateNewUniqueID(biopax, id=var_id)
	
	if(biopax$biopaxlevel == 2) {
		properties = list(LEFT=c(LEFT), RIGHT=c(RIGHT))
		biopax = addBiopaxInstance(biopax, class="biochemicalReaction", id=var_id, properties=properties)
	}
	if(biopax$biopaxlevel == 3) {
		properties = list(left=c(LEFT), right=c(RIGHT))
		biopax = addBiopaxInstance(biopax, class="BiochemicalReaction", id=var_id, properties=properties)
	}
	
	biopax
}

#' This function adds a new physical entity.
#' 
#' This function adds a new physical entity of chosen class to the biopax model. This is a convenience function to add physical entities,
#' internally the function addBiopaxInstance is called with properties NAME and ORGANISM set.
#' 
#' @param biopax A biopax model
#' @param class string. Class of the physical entity to add, choose from c("dna","rna","protein","smallMolecule","complex").  
#' @param NAME string. Name of the new physical entity
#' @param id string. ID for the physical entity. If NULL a new ID is generated with prefix "physicalEntity".
#' @param ORGANISM string. Organism property of the molecule. optional.
#' @param COMMENT string. An optional comment 
#' @return Returns the biopax model with the added physical entity.
#' @author fkramer
#' @export
#' @import data.table
#' @examples
#' biopax = createBiopax(level=2)
#' biopax = addBiopaxInstance(biopax, class="protein", id="id1", properties=list(NAME="protein1",COMMENT="this is my first protein!"))
#' biopax$dt
#' biopax = addPhysicalEntity(biopax, class="protein", id="id2", NAME="protein2", COMMENT="This is a protein added using the convenience function addPhysicalEntitiy")
#' biopax$dt
addPhysicalEntity <- function(biopax, class=c("dna","rna","protein","smallMolecule","complex")[1], NAME, id=NULL, ORGANISM=NULL, COMMENT=NULL) {
	var_id = id
	rm(id)
	
	if(is.null(var_id)) var_id = generateNewUniqueID(biopax, id="physicalEntity")
	if( var_id %chin% biopax$dt$id ) var_id = generateNewUniqueID(biopax, id=var_id)
	
	if(biopax$biopaxlevel == 2) {
		properties = list(NAME=c(NAME))
		if(!is.null(ORGANISM)) properties['ORGANISM']=c(ORGANISM)
		if(!is.null(COMMENT)) properties['COMMENT']=c(COMMENT)
		biopax = addBiopaxInstance(biopax, class=class, id=var_id, properties=properties)
	}
	if(biopax$biopaxlevel == 3) {
		properties = list(name=c(NAME))
		if(!is.null(ORGANISM)) properties['organism']=c(ORGANISM)
		if(!is.null(COMMENT)) properties['comment']=c(COMMENT)
		biopax = addBiopaxInstance(biopax, class=class, id=var_id, properties=properties)
	}
	
	biopax
}

#' This function adds a new physical entity participant.
#' 
#' This function adds a new physical entity participant instance, which is a placeholder for physicalEntity class instances in interactions. 
#' This is a convenience function to add physicalEntityParticipant instances, internally the function addBiopaxInstance is called.
#' 
#' @param biopax A biopax model
#' @param referencedPhysicalEntityID string. ID the new physicalEntity instance to reference here.
#' @param id string. ID for the physical entity participant. If NULL a new ID is generated with prefix "physicalEntityParticipant".
#' @return Returns the biopax model with the added physicalEntityParticipant.
#' @author fkramer
#' @export
#' @import data.table
#' @examples
#' biopax = createBiopax(level=2)
#' biopax = addPhysicalEntity(biopax, class="protein", id="p_id1", NAME="protein1")
#' biopax = addPhysicalEntityParticipant(biopax, "p_id1", id="PEP_p_id1")
#' biopax = addPhysicalEntity(biopax, class="protein", id="p_id2", NAME="protein2")
#' biopax = addPhysicalEntityParticipant(biopax, "p_id2", id="PEP_p_id2")
#' biopax = addBiochemicalReaction(biopax, LEFT=c("PEP_p_id1"), RIGHT=c("PEP_p_id2"), id="biochem_id1")
#' biopax$dt
addPhysicalEntityParticipant <- function(biopax, referencedPhysicalEntityID, id=NULL) {
	var_id = id
	rm(id)
	
	if(is.null(var_id)) var_id = generateNewUniqueID(biopax, id="physicalEntityParticipant")
	if( var_id %chin% biopax$dt$id ) var_id = generateNewUniqueID(biopax, id=var_id)
	
	properties = list('PHYSICAL-ENTITY'=c(referencedPhysicalEntityID))
	
	biopax = addBiopaxInstance(biopax, class="physicalEntityParticipant", id=var_id, properties=properties)
	biopax
}

#' This function generates a new unique id for a biopax model
#' 
#' This function generates a new unique id for a biopax model. Pass it an startin g point like "pathway" or "protein" to get a niceer looking id. 
#' 
#' @param biopax A biopax model
#' @param id string. This is used as a prefix for the id.
#' @return Returns an unused unique ID.
#' @author fkramer
#' @import data.table
#' @export
generateNewUniqueID <- function(biopax, id="") {
	if(id=="") id="id"
		
	for(i in 1:5000000) {
		myid = paste(id,i,sep="_")
		if( !(myid %chin% biopax$dt$id) ) {
			return(myid)
		}
	}
	stop("Error: generateNewUniqueID ran out of new ideas for ids :-(")
}


#' This function merges two given pathways 
#' 
#' This function merges two given pathways and appends it to the supplied biopax model. The user has to specify a new name for the pathways and can
#' supply ID, ORGANISM and COMMENT properties for the new pathway. If no ID is supplied, a new unique ID is generated. If no organism property is supplied
#' the organism property of the first pathway is re-used. If ORGANISM is NULL the property is not set. Optionally a comment can be added to the pathway.   
#' 
#' @param biopax A biopax model 
#' @param pwid1 string. ID of first pathway to merge
#' @param pwid2 string. ID of second pathway to merge
#' @param NAME string. Name of the new merged pathway
#' @param id string. ID for the pathway. If NULL a new ID is generated with prefix "pathway".
#' @param ORGANISM string. Organism property of the pathway. By default uses the same organism as the first supplied pathway. If NULL no organism property is set.
#' @param COMMENT string. An optional comment 
#' @return A biopax model with the merged pathway added.
#' @author fkramer
#' @import data.table
#' @export
mergePathways <- function(biopax, pwid1, pwid2, NAME, id=NULL, ORGANISM="", COMMENT=NULL) {
	var_id = id
	rm(id)
	
	if(is.null(var_id)) var_id = generateNewUniqueID(biopax, id="pathway")
	if( var_id %chin% biopax$dt$id ) var_id = generateNewUniqueID(biopax, id=var_id)
	
	PATHWAY_COMPONENTS = unique(c(listPathwayComponents(biopax,pwid1)$id,listPathwayComponents(biopax,pwid2)$id))
	
	#support for bp level 2 and 3
	if(biopax$biopaxlevel == 2) {
		properties = list(NAME=c(NAME),'PATHWAY-COMPONENTS'=PATHWAY_COMPONENTS)
		if(!is.null(ORGANISM)) if(ORGANISM=="") ORGANISM=getInstanceProperty(biopax, id=pwid1, property="ORGANISM")
		if(!is.null(ORGANISM)) if(length(ORGANISM)>0) properties['ORGANISM']=c(ORGANISM)
		if(!is.null(COMMENT)) properties['COMMENT']=c(COMMENT)
		biopax = addBiopaxInstance(biopax, class="pathway", id=var_id, properties=properties)
	}
	if(biopax$biopaxlevel == 3) {
		properties = list(name=c(NAME),'pathwayComponent'=PATHWAY_COMPONENTS)
		if(!is.null(ORGANISM)) if(ORGANISM=="") ORGANISM=getInstanceProperty(biopax, id=pwid1, property="ORGANISM")
		if(!is.null(ORGANISM)) if(length(ORGANISM)>0) properties['organism']=c(ORGANISM)
		if(!is.null(COMMENT)) properties['comment']=c(COMMENT)
		biopax = addBiopaxInstance(biopax, class="Pathway", id=var_id, properties=properties)
	}

	biopax
	
}

#' This function removes an instance
#' 
#' This function removes an instance from an existing biopax model.
#' 
#' @param biopax A biopax model
#' @param id string. ID of the instance
#' @return Returns the supplied biopax model with the instance removed from it.
#' @author Frank Kramer
#' @import data.table
#' @export
removeInstance <- function(biopax, id) {
	var_id = id
	rm(id)
	biopax$dt = biopax$dt[id != var_id, ]
	biopax
}

#' This function removes a property
#' 
#' This function removes a property fram an existing biopax instance.
#' 
#' @param biopax A biopax model
#' @param id string. ID of the instance
#' @param properties character vector. listing the properties to remove.
#' @return Returns the supplied biopax model with properties removed from this instance.
#' @author Frank Kramer
#' @import data.table
#' @export
removeProperties <- function(biopax, id, properties) {
	var_id = id
	rm(id)
	biopax$dt = biopax$dt[id != var_id | !(tolower(property) %in% tolower(properties)), ]
	biopax
}
