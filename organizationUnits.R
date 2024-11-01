
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
us.maputo.v240 <- lapply(us.maputo, function(unit) {
  unit$openingDate <- opening_date
  return(unit)
})

# Filter all object with property level = 3
district.maputo.v240 <- us.maputo.v240[sapply(us.maputo.v240, function(x) x$level == 3)]

# Send district.maputo.v240 objects to DHIS
# loop all elemnts in the list district.maputo.v240 and send data individually
# store response in vector
vec.response.district <- list()
for (i in 1:length(district.maputo.v240)) {
  ou.response <- importOrganizationUnits_v240(base.url.v240,district.maputo.v240[[i]])
  vec.response.district[[i]] <- ou.response
}


# Filter all object with property level = 4
unidadesSanitarias <- us.maputo.v240[sapply(us.maputo.v240, function(x) x$level == 4)]

# Send unidadesSanitarias objects to DHIS
# loop all elemnts in the list unidadesSanitarias and send data individually
# store response in vector
vec.response.us <- list()
  for (i in 1:length(unidadesSanitarias)) {
    ou.response <- importOrganizationUnits_v240(base.url.v240,unidadesSanitarias[[i]])
    
    vec.response.us[[i]] <- ou.response
    
  }
