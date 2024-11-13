
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

# Extract all categoryOptions ids  from categories df
category.option.ids <- lapply(categories, function(x) x$categoryOptions)
category.option.ids <- unlist(category.option.ids)
# make a list of category.option.ids where each element is a list of category.option.ids

for (v in 1:length(category.option.ids)) {
  category.option.ids[v] <- as.list(category.option.ids[v])
  
}

# Get all categoryOptions from DHIS2
#categoryOptions <- lapply(category.option.ids, function(x) getCategoryOptions(base.url, x))
category.Options <- list()
for (i in 1:length(category.option.ids)) {
  category.Options[[i]] <- getCategoryOptions(base.url, category.option.ids[[i]])
  
}

# Extract names from each element in the list
names_list <- sapply(category.Options, function(x) x$name)
unique_indices <- match(unique(names_list), names_list)

# Subset the list to keep only unique elements
unique_list <- category.Options[unique_indices]


# filter some fields from categoryOptions id, code, name, shortName, displayName
df.categoryOptions.filtered <- lapply(unique_list, function(x) {
  x <- x[c("id", "name")]
  return(x)
})

#add code and displayNmae property  to the df.categoryOptions.filtered
df.categoryOptions.filtered <- lapply(df.categoryOptions.filtered, function(x) {
  x$code <- ifelse(nchar(x$name) > 50, substr(x$name, 1, 40), x$name)
 # x$displayName <- x$name
 # x$shortName <- x$name
  x$shortName <- ifelse(nchar(x$name) > 50, substr(x$name, 1, 40), x$name)
  return(x)
})

#add userGroupAccesses property  to the df.categoryOptions.filtered (df.categoryOptions.filtered$userGroupAccesses)  
df.categoryOptions.filtered <- lapply(df.categoryOptions.filtered, function(x) {
  #x$userGroupAccesses <- userGroupAcesses
  x$sharing <- sharing
  return(x)
})

# Remove some objects 79 ,1,2,3,4
# df.categoryOptions.filtered <- df.categoryOptions.filtered[-c(6,7,8,9)]

# Send categoryOptions objects to DHIS2
# loop all elements in the list df.categoryOptions.filtered and send data individually
# store response in vector

vec.response.categoryOptions <- list()
for (i in 1:length(df.categoryOptions.filtered)) {
  
  ou.response <- importCategoryOptions_v240(base.url.v240,df.categoryOptions.filtered[[i]])
  # wait 3 second berfore next request
  vec.response.categoryOptions[[i]] <- ou.response
  # if response status codeis  201   (created) print the response
  if (ou.response$status_code == 201) {
    print(paste0(i," ",df.categoryOptions.filtered[[i]]$id , " -  created sucessfully"))
  } else {
    print(paste0(i," ",df.categoryOptions.filtered[[i]]$id , " -  failed to create"))
  }
  Sys.sleep(3)
  
}


save(df.categoryOptions.filtered,unique_list,
     category.Options,category.option.ids,category.ids,
     categories,categoryCombos,
     dataElements,datim.dataset.elements, file = "categoryOptions.RData")


