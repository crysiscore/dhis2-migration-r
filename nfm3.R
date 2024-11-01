
#--   We need these two libraries                    --#

library(httr2)
library(dplyr)
library(jsonlite)

wd <- "~/Projects/dhis2-upgrade"
setwd(wd)
source('misc_functions.R')
source('credentials.R')
############## Params
# Login Credentials
base.url<-"https://mail.ccsaude.org.mz:5459/"
base.url.v240<-"https://mail.ccsaude.org.mz:5470/"
org.unit.maputo <- 'ebcn8hWYrg3'               # CIDADE DE MAPUTO
org.unit.gaza <- 'ebcn8hWYrg3'               # CIDADE DE MAPUTO

# dhisLogin(username,password,base.url)

# Lista das US  da Cidade de Maputo
#  OrganizationUnit id= ebcn8hWYrg3 (Cidade de Maputo)
us.maputo <- getOrganizationUnits(base.url,org.unit.maputo)
# Add opening date
opening_date <- "2024-01-01"

us.maputo.v240 <- list()
us.maputo.v240$organisationUnits <- lapply(us.maputo, function(unit) {
  unit$openingDate <- opening_date
  return(unit)
})
#us.maputo.v240[["organisationUnits"]][[43]][["parent"]][["id"]]="tJiRCG6qT7T"

# convert to json
#us.maputo.json <- toJSON(us.maputo.v240, auto_unbox = TRUE)


# Envia organizacoes para o DHIS2
ou.response <- importOrganizationUnits_v240(base.url.v240,us.maputo.v240$organisationUnits[[43]])


# Todos data Elements do DHIS2
dataElements <- getDataElements(base.url)
dataElements$name <- as.character(dataElements$name)
dataElements$shortName <- as.character(dataElements$shortName)
dataElements$id <- as.character(dataElements$id)



# NFM3 Program stages
# NOTIFICAR O CASO  iD =KMjYg0iRcIR
programStages <- getProgramStages(base.url,program.id)
programStages$name <- as.character(programStages$name)
#programStages$description <- as.character(programStages$description)
programStages$id <- as.character(programStages$id)

# Get all events
events <- getEvents(base.url,org.unit,program.id,program.stage.id)
events$dataElement <- as.character(events$dataElement)
events$programStage <- as.character(events$programStage)
events$dataElement <- sapply(events$dataElement, findDataElementByID)
events$programStage <- sapply(events$programStage, findProgramStageByID)


# Get all events
#events <- getEnrollments(base.url,org.unit,program.id,program.stage.id)


# Drop lastupdate column
events= events[ , - which(names(events) %in% c("lastUpdated"))]
events=spread(events, dataElement, value)

# get TrackedInstances
trackedInstances <- getTrackedInstances(base.url,program.id,org.unit)
trackedInstances = trackedInstances[ , - which(names(trackedInstances) %in% c("Created","Organisation unit",
                                                                            "Tracked entity type","Last updated" ,
                                                                            "Organisation unit name", "Inactive" ))]
#pacientes <- sapply(events$trackedEntityIntance, findDataElementByID)
events <- dplyr::left_join(events,trackedInstances, by=c("trackedEntityIntance"="Instance") )


rm(dataElement,programStages,unidadesSanitarias)
