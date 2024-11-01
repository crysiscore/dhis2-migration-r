# Helper Links

# working with json https://www.tutorialspoint.com/r/r_json_files.htm


#############################################  Helper fuctions     ####################################################

dhisLoginV240 <- function(username, password, base.url) {
  url <- paste0(base.url, "api/33/me")
  r <- GET(url, authenticate(username, password))
  if (r$status == 200L) {
    print("Logged in successfully!")
  } else {
    print("Could not login")
  }
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
  #url <- paste0( base.url.v240, "api/metadata/" )
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

  url <- paste0( base.url.v240, "api/categoryOptions/" )
  #url <- paste0( base.url.v240, "api/metadata/" )
  response <- request(url) |> 
    req_auth_basic(username = dhis2.username.v240, password = dhis2.password.v240) |> 
    # Add a body, turning it into a POST
    req_body_json(data=category.options.json, type = "application/json") |> 
    req_retry(max_tries = 3) |> 
    req_perform() 
  
  response

}



