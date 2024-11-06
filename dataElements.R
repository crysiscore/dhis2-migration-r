
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
data.element.ids <- lapply(datim.dataset.elements$dataSetElements, function(x) x$dataElement$id)

# Get all data elements from DHIS2
dataElements <- lapply(data.element.ids, function(x) getDataElements(base.url, x))



# Filter id, name, valueType ,aggregationType, domainType,externalAccess, zeroIsSignificant, optionSetValue from dataElements
df.dataElements.filtered <- lapply(dataElements, function(x) {
x <- x[c("id","name","shortName","valueType","aggregationType","domainType","externalAccess",
         "zeroIsSignificant","optionSetValue","publicAccess","periodOffset","categoryCombo")]
return(x)

})


#add shortName property  to the df.dataElements.filtered df
df.dataElements.filtered <- lapply(df.dataElements.filtered, function(x) {
x$shortName <- ifelse(nchar(x$shortName) > 50, substr(x$shortName, 1, 40), x$shortName)
x$sharing <- sharing
x$publicAccess <- "r-------"
return(x)
})




data_element_ids_list <- sapply(df.dataElements.filtered, function(x) x$id)
unique_indices <- match(unique(data_element_ids_list), data_element_ids_list)
data.elements.unique.list <- df.dataElements.filtered[unique_indices]


# Find all  elements that have the categoryCombo id property = "nSPCuYWOkrg" and
# replace the id to bjDvmb4bfuf in the data.elements.unique.list.

data_element_default_id <- sapply(data.elements.unique.list, function(x) x$categoryCombo$id)
default_indexes <- which(data_element_default_id=="nSPCuYWOkrg")
if(length(default_indexes)>0){
  for (i in default_indexes) {
    data.elements.unique.list[[i]]$categoryCombo$id <- "bjDvmb4bfuf"
  }
}


# Send data.elements.unique.list objects to DHIS2
# loop all elemnts in the list data.elements.unique.list and send data individually
# store response in vector

vec.response.data.elements <- list()

for (i in 1:length(data.elements.unique.list)) {
  
ou.response <- importDataElements_v240(base.url.v240,data.elements.unique.list[[i]])

vec.response.data.elements[[i]] <- ou.response
# if response status codeis  201   (created) print the response
if (ou.response$status_code == 201) {
print(paste0(i," ",data.elements.unique.list[[i]]$id ," " ,data.elements.unique.list[[i]]$name , " -  created sucessfully"))
} else {
print(paste0(i," ",data.elements.unique.list[[i]]$id  ," " ,data.elements.unique.list[[i]]$name ," -  failed to create"))
}
Sys.sleep(3)
}
