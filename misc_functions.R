# Helper Links

# working with json https://www.tutorialspoint.com/r/r_json_files.htm


#############################################  Helper fuctions     ####################################################
# Function to authenticate with DHIS2 using a PAT

dhisLoginV240 <- function(username, password, base.url) {
  url <- paste0(base.url.v240, "api/33/me")
  r <-request(url) %>%
    req_auth_basic(token = token) %>%
    req_retry(max_tries = 3) %>%
    req_perform()
  
  if (r$status == 200L) {
    print("Logged in successfully!")
  } else {
    print("Could not login")
  }
}

getDataSet <- function(base.url, dataset.id) {
  url <-
    paste0(base.url,
           "api/dataSets/", dataset.id)
  
  response <- request(url) %>%
    req_auth_basic(username = dhis2.username, password = dhis2.password) %>%
    req_retry(max_tries = 3) %>%
    req_perform() %>%
    resp_body_json()
  
  response
}

getDataEntryForm <- function(base.url, data.entry.form.id) {
  url <-
    paste0(base.url,
           "api/dataEntryForms/", data.entry.form.id)
  
  response <- request(url) %>%
    req_auth_basic(username = dhis2.username, password = dhis2.password) %>%
    req_retry(max_tries = 3) %>%
    req_perform() %>%
    resp_body_json()
  
  response
}


getDataSetElements <- function(base.url , dataset.id)  {
  url <-
    paste0(base.url,
           "api/dataSets/", dataset.id)
 
  response <- request(url) %>%
    req_auth_basic(username = dhis2.username, password = dhis2.password) %>%
    req_retry(max_tries = 3) %>%
    req_perform() %>%
    resp_body_json()
  
  
  response
}

getDataSet <- function(base.url , dataset.id)  {
  url <-
    paste0(base.url,
           "api/dataSets/", dataset.id)
  
  response <- request(url) %>%
    req_auth_basic(username = dhis2.username, password = dhis2.password) %>%
    req_retry(max_tries = 3) %>%
    req_perform() %>%
    resp_body_json()
  
  
  response
}
getIndicators <- function(base.url, indicator.id) {
  url <-
    paste0(base.url,
           "api/indicators/", indicator.id)
  
  response <- request(url) %>%
    req_auth_basic(username = dhis2.username, password = dhis2.password) %>%
    req_retry(max_tries = 3) %>%
    req_perform() %>%
    resp_body_json()
  
  response
}

getIndicatorType <- function(base.url) {
  url <-
    paste0(base.url,
           "api/indicatorTypes?paging=false")
  
  response <- request(url) %>%
    req_auth_basic(username = dhis2.username, password = dhis2.password) %>%
    req_retry(max_tries = 3) %>%
    req_perform() %>%
    resp_body_json()
  
  response$indicatorTypes
}

getIndicatorTypeByID <- function(base.url, indicator.type.id) {
  url <-
    paste0(base.url,
           "api/indicatorTypes/" , indicator.type.id)
  
  response <- request(url) %>%
    req_auth_basic(username = dhis2.username, password = dhis2.password) %>%
    req_retry(max_tries = 3) %>%
    req_perform() %>%
    resp_body_json()
  
  response
}


getDataElements <- function(base.url, data.element.id) {
  url <-
    paste0(base.url,
           "api/dataElements/", data.element.id)
  
   response <- request(url) %>%
    req_auth_basic(username = dhis2.username, password = dhis2.password) %>%
    req_retry(max_tries = 3) %>%
    req_perform() %>%
    resp_body_json()
  
  response
  
}

getCategoryCombos <- function(base.url, category.combo.id) {
  url <-
    paste0(base.url,
           "api/categoryCombos/", category.combo.id)
  
  response <- request(url) %>%
    req_auth_basic(username = dhis2.username, password = dhis2.password) %>%
    req_retry(max_tries = 3) %>%
    req_perform() %>%
    resp_body_json()
  
  response
}

getCategories <- function(base.url, category.id) {
  url <-
    paste0(base.url,
           "api/categories/", category.id)
  
  response <- request(url) %>%
    req_auth_basic(username = dhis2.username, password = dhis2.password) %>%
    req_retry(max_tries = 3) %>%
    req_perform() %>%
    resp_body_json()
  
  response
}

getCategoryOptions <- function(base.url, category.option.id) {
  url <-
    paste0(base.url,
           "api/categoryOptions/", category.option.id)
  
  response <- request(url) %>%
    req_auth_basic(username = dhis2.username, password = dhis2.password) %>%
    req_retry(max_tries = 3) %>%
    req_perform() %>%
    resp_body_json()
  
  response
  
}

  
# Get all organisation units from DHIS2
getOrganizationUnits <- function(base.url, location_id) {
  ## location pode ser distrito , provincia
  url <-
    paste0(
      base.url,
      paste0(
        "api/organisationUnits/",
        location_id,
        "?includeDescendants=true&paging=false&fields=id,level,name,shortName,parent"
      )
    )
  
  response <- request(url) %>%
    req_auth_basic(username = dhis2.username, password = dhis2.password) %>%
    req_retry(max_tries = 3) %>%
    req_perform() %>%
    resp_body_json()
  
  
  response$organisationUnits

}

#import orgunits to DHIS2
importOrganizationUnits_v240 <- function(base.url, org.units.json) {

  url <- paste0( base.url.v240, "api/organisationUnits/" )

  response <- request(url) |> 
    req_auth_basic(username = dhis2.username.v240, password = dhis2.password.v240) |> 
    # Add a body, turning it into a POST
    req_body_json(data=org.units.json, type = "application/json") |> 
    req_retry(max_tries = 3) |> 
    req_perform() 
  
  response

}

#import CategoryOptions to DHIS2
importCategoryOptions_v240 <- function(base.url, category.options.json) {

  url <- paste0( base.url.v240, "api/categoryOptions" )
  response <- request(url) |> 
    req_auth_basic(username = dhis2.username.v240, password = dhis2.password.v240) |>
    # Add a body, turning it into a POST
    req_body_json(data=category.options.json, type = "application/json") |> 
    req_retry(max_tries = 3) |> 
    req_perform() 
    #req_dry_run()
  
  response

}


#import Metadaa to DHIS2 using the api/metadata endpoint
importDhis2Metadata <- function(base.url, payload) {
  
  
  url <- paste0( base.url.v240, "api/metadata/" )

  
  response <- request(url) |> 
    req_auth_basic(username = dhis2.username.v240, password = dhis2.password.v240) |>
    req_url_query(importReportMode = "FULL",importStrategy = "CREATE_AND_UPDATE") |>
    #req_auth_basic(username = dhis2.username.v240, password = dhis2.password.v240) |> 
    # Add a body, turning it into a POST
    req_body_json(payload, type = "application/json") |> 
    req_retry(max_tries = 3) |> 
    req_perform() 
    req_dry_run()
  response
  
}

# import Categoriwa to DHIS2
importCategories_v240 <- function(base.url, category.json) {
  
  url <- paste0( base.url, "api/categories" )
  response <- request(url) |> 
    req_auth_basic(username = dhis2.username.v240, password = dhis2.password.v240) |>
    # Add a body, turning it into a POST
    req_body_json(data=category.json, type = "application/json") |> 
    req_retry(max_tries = 3) |> 
    req_perform() 
  #req_dry_run()
  
  response
  
}

# import importCategorieCombos_v240 to DHIS2
importCategorieCombos_v240 <- function(base.url, category.combo.json) {
  
  url <- paste0( base.url, "api/categoryCombos" )
  response <- request(url) |> 
    req_auth_basic(username = dhis2.username.v240, password = dhis2.password.v240) |>
    # Add a body, turning it into a POST
    req_body_json(data=category.combo.json, type = "application/json") |> 
    req_retry(max_tries = 3) |> 
    req_perform() 
  #req_dry_run()
  
  response
  
}

# Patch patchCategorieCombos_v240  DHIS2
patchCategorieCombos_v240 <- function(base.url, category.combo.json) {
  
  url <- paste0( base.url, "api/categoryCombos/", category.combo.json$id )
  
  # remove id property from category.combo.json
  category.combo.json$id <- NULL
  
  response <- request(url) |> 
    req_auth_basic(username = dhis2.username.v240, password = dhis2.password.v240) |>
    req_method("PUT") |>
    # Add a body, turning it into a POST
    req_body_json(data=category.combo.json, type = "application/json") |> 

    req_retry(max_tries = 3) |> 
    req_perform() 
    #req_dry_run()
  
  response
  
}

# Import indicatorsType to DHIS2
importIndicatorType_v240 <- function(base.url, indicator.type.json) {
  
  url <- paste0( base.url, "api/indicatorTypes" )
  response <- request(url) |> 
    req_auth_basic(username = dhis2.username.v240, password = dhis2.password.v240) |>
    # Add a body, turning it into a POST
    req_body_json(data=indicator.type.json, type = "application/json") |> 
    req_retry(max_tries = 3) |> 
    req_perform() 
  #req_dry_run()
  
  response
  
}

# Import Indicators to DHIS2
importIndicators_v240 <- function(base.url, indicator.json) {
  
  url <- paste0( base.url, "api/indicators" )
  response <- request(url) |> 
    req_auth_basic(username = dhis2.username.v240, password = dhis2.password.v240) |>
    # Add a body, turning it into a POST
    req_body_json(data=indicator.json, type = "application/json") |> 
    req_retry(max_tries = 3) |> 
    req_perform() 
  #req_dry_run()
  
  response
  
}

#import DataElements to DHIS2
importDataElements_v240 <- function(base.url, data.elements.json) {
  
  url <- paste0( base.url, "api/dataElements" )
  response <- request(url) |> 
    req_auth_basic(username = dhis2.username.v240, password = dhis2.password.v240) |>
    # Add a body, turning it into a POST
    req_body_json(data=data.elements.json, type = "application/json") |> 
    req_retry(max_tries = 3) |> 
    req_perform() 
  #req_dry_run()
  
  response
  
}

# Import DataSets to DHIS2
importDataSets_v240 <- function(base.url, data.sets.json) {
  
  url <- paste0( base.url, "api/dataSets" )
  response <- request(url) |> 
    req_auth_basic(username = dhis2.username.v240, password = dhis2.password.v240) |>
    # Add a body, turning it into a POST
    req_body_json(data=data.sets.json, type = "application/json") |> 
    req_retry(max_tries = 3) |> 
    req_perform() 
  #req_dry_run()
  
  response
  
}

# Import DataEntryForms to DHIS2
importDataEntryForms_v240 <- function(base.url, data.entry.forms.json) {
  
  url <- paste0( base.url, "api/dataEntryForms" )
  response <- request(url) |> 
    req_auth_basic(username = dhis2.username.v240, password = dhis2.password.v240) |>
    # Add a body, turning it into a POST
    req_body_json(data=data.entry.forms.json, type = "application/json") |> 
    req_retry(max_tries = 3) |> 
    req_perform() 
  #req_dry_run()
  
  response
  
}