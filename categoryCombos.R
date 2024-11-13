
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

# extract all categoryCombos from dataElements df
category.combo.ids <- lapply(dataElements, function(x) x$categoryCombo$id)

# Get all categoryCombos from DHIS2
categoryCombos <- lapply(category.combo.ids, function(x) getCategoryCombos(base.url, x))

# Filter id, name, code ,dataDimensionType, publicAcess,externalAccess, publicAccess, categories
df.categoryCombos.filtered <- lapply(categoryCombos, function(x) x[c('id', 'name', 'code', 'dataDimensionType', 'externalAccess', 'categories')])


#add sharing property  to the df.categoryCombos.filtered df
df.categoryCombos.filtered <- lapply(df.categoryCombos.filtered, function(x) {
  x$sharing <- sharing
  x$code <- ifelse(nchar(x$name) > 50, substr(x$name, 1, 40), x$name)
  x$publicAcess <- "r-------"
  return(x)
})


category.combos_ids_list <- sapply(df.categoryCombos.filtered, function(x) x$id)
unique_indices <- match(unique(category.combos_ids_list), category.combos_ids_list)
category.combos.unique.list <- df.categoryCombos.filtered[unique_indices]


# Send category.unique.list objects to DHIS2
# loop all elemnts in the list category.unique.list and send data individually
# store response in vector


vec.response.categoryCombos <- list()

for (i in 1:length(category.combos.unique.list)) {
  
  ou.response <- importCategorieCombos_v240(base.url.v240,category.combos.unique.list[[i]])
  
  vec.response.categoryCombos[[i]] <- ou.response
  # if response status codeis  201   (created) print the response
  if (ou.response$status_code == 201) {
    print(paste0(i," ",category.combos.unique.list[[i]]$id ," " ,category.combos.unique.list[[i]]$name , " -  created sucessfully"))
  } else {
    print(paste0(i," ",category.combos.unique.list[[i]]$id  ," " ,category.combos.unique.list[[i]]$name ," -  failed to create"))
  }
  Sys.sleep(3)
}




