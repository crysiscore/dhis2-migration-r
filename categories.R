
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

# From the categoryCombos df  extract the category ids, beware that thare can be more than one category
# and the categories are lists

category.ids <- lapply(categoryCombos, function(x) x$categories)
# Extract every value for each element of the list
category.ids <- lapply(category.ids, function(x) lapply(x, function(y) y$id))

#unlist the category.ids
category.ids <-  unlist(category.ids)

# Get all categories from DHIS2
categories <- lapply(category.ids, function(x) getCategories(base.url, x))

# Filter id, name, code ,dataDimensionType, publicAcess,externalAccess, publicAccess, categories
df.categories.filtered <- lapply(categories, function(x) {
x <- x[c("id","name","externalAccess","publicAccess","dimensionType","dataDimensionType","dataDimension","items","categoryOptions")]
return(x)
})


#add shortName property  to the df.categories.filtered df
df.categories.filtered <- lapply(df.categories.filtered, function(x) {
x$shortName <- ifelse(nchar(x$name) > 50, substr(x$name, 1, 40), x$name)
x$sharing <- sharing
return(x)
})


category_ids_list <- sapply(df.categories.filtered, function(x) x$id)
unique_indices <- match(unique(category_ids_list), category_ids_list)
category.unique.list <- df.categories.filtered[unique_indices]

# Send category.unique.list objects to DHIS2
# loop all elemnts in the list category.unique.list and send data individually
# store response in vector

vec.response.categories <- list()

for (i in 1:length(category.unique.list)) {
  
ou.response <- importCategories_v240(base.url.v240,category.unique.list[[i]])

vec.response.categories[[i]] <- ou.response
# if response status codeis  201   (created) print the response
if (ou.response$status_code == 201) {
print(paste0(i," ",category.unique.list[[i]]$id ," " ,category.unique.list[[i]]$name , " -  created sucessfully"))
} else {
print(paste0(i," ",category.unique.list[[i]]$id  ," " ,category.unique.list[[i]]$name ," -  failed to create"))
}
Sys.sleep(3)
}
