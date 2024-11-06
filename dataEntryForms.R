
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


#Get dataEntryForm ID
data.entry.form.id <- datim.dataset$dataEntryForm$id

#Get dataEntryForm

dataEntryForm <- getDataEntryForm(base.url, data.entry.form.id)

# Filter id,name,format ,htmlCode,format
df.dataEntryForm.filtered <- dataEntryForm[c("id","name","format","htmlCode","format","externalAccess")]


#Modify PublicAcess and Sharing Properties  in the df.dataEntryForm.filtered df
df.dataEntryForm.filtered$sharing <- sharing


# Send df.dataEntryForm.filtered object to DHIS2
response <- importDataEntryForms_v240(base.url.v240, df.dataEntryForm.filtered)

# Check the response
if(response$status_code == 201){
  print( paste0(df.dataEntryForm.filtered$name, " dataset was successfully imported"))} else {
    print( paste0(df.dataEntryForm.filtered$name, " dataset was not imported"))
  }

