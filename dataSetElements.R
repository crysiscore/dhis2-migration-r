
#-- Libraries      --#
library(httr2)
library(dplyr)


wd <- "~/Projects/dhis2-upgrade"
setwd(wd)
source('misc_functions.R')
source('credentials.R')

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


# Get all categoryOptions from DHIS2
categoryOptions <- lapply(category.option.ids, function(x) getCategoryOptions(base.url, x))









