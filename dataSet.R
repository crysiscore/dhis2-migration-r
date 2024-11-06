
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
datim.dataset<- getDataSet(base.url, datim.dataset.id)


# Replace the categoryCombo id property = "nSPCuYWOkrg" with  id  "bjDvmb4bfuf" in the datim.dataset
if(datim.dataset$categoryCombo$id == "nSPCuYWOkrg"){
  datim.dataset$categoryCombo$id <- "bjDvmb4bfuf"
  
}



# Filter id,name,expiryDays,openFuturePeriods,periodType,openPeriodsAfterCoEndDate,
#publicAccess,dataSetElements, categoryCombo,indicators,organisationUnits from the datim.dataset
df.dataset.filtered <- datim.dataset[c("id","name","expiryDays","openFuturePeriods","periodType","openPeriodsAfterCoEndDate",
         "publicAccess","dataSetElements", "categoryCombo","indicators","dataEntryForm","organisationUnits")]



#Modify PublicAcess and Sharing Properties  in the df.dataset.filtered df
df.dataset.filtered$sharing <- sharing
df.dataset.filtered$publicAccess <- "r-------"
df.dataset.filtered$shortName <- ifelse(nchar(df.dataset.filtered$name) > 50, substr(df.dataset.filtered$name, 1, 40), df.dataset.filtered$name)


# Remove dataSet Property from the dataSetElements list
df.dataset.filtered$dataSetElements <- lapply(df.dataset.filtered$dataSetElements, function(x) {
  x$dataSet <- NULL
  return(x)
})

# Send df.dataset.filtered object to DHIS2
response <- importDataSets_v240(base.url.v240, df.dataset.filtered)

# Check the response
if(response$status_code == 201){
  print( paste0(df.dataset.filtered$name, " dataset was successfully imported"))} else {
    print( paste0(df.dataset.filtered$name, " dataset was not imported"))
  }

