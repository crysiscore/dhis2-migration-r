
#-- Libraries      --#
library(httr2)
library(dplyr)


wd <- "~/Projects/dhis2-upgrade"
setwd(wd)
source('misc_functions.R')
source('credentials.R')
load(file = "userGroupAccesses.RData")

############## Params
# Login Credentials
base.url<-"https://mail.ccsaude.org.mz:5459/"
base.url.v240<-"https://mail.ccsaude.org.mz:5470/"
org.unit.maputo <- 'ebcn8hWYrg3'               # CIDADE DE MAPUTO
org.unit.gaza <- 'ebcn8hWYrg3'                 # CIDADE DE MAPUTO


#Dataset ids
datim.dataset.id <- "Z9agMHXo792"

datim.dataset.elements <- getDataSetElements(base.url, datim.dataset.id)

# Retrieve data elements ids from the dataset datim.dataset.elements
indicators.ids <- lapply(datim.dataset.elements$indicators, function(x) x$id)


# Get all data indicators from DHIS2
indicators <- lapply(indicators.ids, function(x) getIndicators(base.url, x))

# get indicators type
# indicators.type <-  getIndicatorType(base.url)
# df.indicators.type <- lapply(indicators.type,function(x) getIndicatorTypeByID(base.url, x$id))
# 
# # Filter  id, name, externalAccess, number, factor from df.indicators.type
# df.indicators.type.filtered <- lapply(df.indicators.type, function(x) {
#   x <- x[c("id","name","number","factor")]
#   return(x)
#   
# })

# Send df.indicators.type.filtered objects to DHIS2
# loop all elemnts in the list df.indicators.type.filtered and send data individually
# store response in vector
# Run once
# vec.response.indicators.type <- list()
# 
# for (i in 1:length(df.indicators.type.filtered)) {
#   
#   ou.response <- importIndicatorType_v240(base.url.v240, df.indicators.type.filtered[[i]])
#  
#   vec.response.indicators.type[[i]] <- ou.response
#   # if response status codeis  201   (created) print the response
#   if (ou.response$status_code == 201) {
#     print(paste0(i," ",df.indicators.type.filtered[[i]]$id ," " ,df.indicators.type.filtered[[i]]$name , " -  created sucessfully"))
#   } else {
#     print(paste0(i," ",df.indicators.type.filtered[[i]]$id  ," " ,df.indicators.type.filtered[[i]]$name ," -  failed to create"))
#   }
#   Sys.sleep(3)
# }


# Filter id, name, valueType ,aggregationType, domainType,externalAccess, zeroIsSignificant, optionSetValue from dataElements
df.indicators.filtered <- lapply(indicators, function(x) {
  x <- x[c("id","name","shortName","externalAccess","publicAccess","numeratorDescription","denominatorDescription","sharing",
           "numerator","denominator","annualized","indicatorType")]
  return(x)
  
})


#add shortName property  to the df.indicators.filtered df
df.indicators.filtered <- lapply(df.indicators.filtered, function(x) {
  x$shortName <- ifelse(nchar(x$shortName) > 50, substr(x$shortName, 1, 40), x$shortName)
  x$sharing <- sharing
  x$publicAccess <- "r-------"
  return(x)
})



indicators_ids_list <- sapply(df.indicators.filtered, function(x) x$id)
unique_indices <- match(unique(indicators_ids_list), indicators_ids_list)
indicators.unique.list <- df.indicators.filtered[unique_indices]

# Send indicators.unique.list objects to DHIS2
# loop all elemnts in the list indicators.unique.list and send data individually
# store response in vector

vec.response.indicators <- list()

for (i in 1:length(indicators.unique.list)) {
  
  ou.response <- importIndicators_v240(base.url.v240,indicators.unique.list[[i]])
  
  vec.response.indicators[[i]] <- ou.response
  # if response status codeis  201   (created) print the response
  if (ou.response$status_code == 201) {
    print(paste0(i," ",indicators.unique.list[[i]]$id ," " ,indicators.unique.list[[i]]$name , " -  created sucessfully"))
  } else {
    print(paste0(i," ",indicators.unique.list[[i]]$id  ," " ,indicators.unique.list[[i]]$name ," -  failed to create"))
  }
  Sys.sleep(3)
  
}
