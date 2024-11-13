#-- Libraries      --#
library(httr2)
library(dplyr)

source('misc_functions.R')
source('credentials.R')
load(file = "userGroupAccesses.RData")

############## Params
base.url<-"https://mail.ccsaude.org.mz:5459/"
base.url.v240<-"https://mail.ccsaude.org.mz:5470/"
org.unit.maputo <- 'ebcn8hWYrg3'               # CIDADE DE MAPUTO

# <dataSet id="hVEtsDr00yb">
#   <displayName>Seguimento Semanal - C&T</displayName>
# <dataSet id="ocwQQqWdVuB">
#   <displayName>Seguimento semanal - Previsao de perdas (TXML)</displayName>
# <dataSet id="VAXwvIaNB7S">
#   <displayName>NON MER - FARMAC</displayName>
# <dataSet id="LUsbbPX9hlO">
#   <displayName>NON MER - MDS e Avaliacao de Retencao</displayName>
# <dataSet id="hm1PzriuCcb">
#   <displayName>CCS - MER RESULTS - Trimestral</displayName>
  
vec_datasets_ids <- c("seg_semanal_ct"="hVEtsDr00yb","seg_semanal_txml" = "ocwQQqWdVuB","non_mer_farmac" = "VAXwvIaNB7S","non_mer_mds" = "LUsbbPX9hlO", "ccs_mer_results" ="hm1PzriuCcb")


# 1- Get all categoryOptions from DHIS2 v240
df_categoryOptions <- getAllCategoryOptions_v240(base.url.v240)

# 2- Get all categoryOptionCombos from DHIS2 v240
df_categoryOptionCombos <- getAllCategoryCombos_v240(base.url.v240)

# 3- Get all categories from DHIS2 v240
df_categories <- getAllCategories_v240(base.url.v240)

# 4- Get all dataElements from DHIS2 v240
df_dataElements <- getAllDataElements_v240(base.url.v240)

# 5- Get all organisationUnits from DHIS2 v240

df_organisationUnits <- getAllOrganisationUnits_v240(base.url.v240)

# For each dataset create an environment to store the data
for (id in 1:length(vec_datasets_ids) ) {
  
  # create and env for each dataset
  assign(paste0("ENV_",labels(vec_datasets_ids[id])), new.env(), )
  
  # Get the dataset from dhis2
  ds <- getDataSet(base.url, vec_datasets_ids[id])
  
  # Retrieve data elements ids from the dataset ds
  data_element_ids <- lapply(ds$dataSetElements, function(x) x$dataElement$id)
  
  # Get all data elements from DHIS2
  data_elements <- lapply(data_element_ids, function(x) getDataElements(base.url, x))
  
  # extract all categoryCombos from data_elements df
  category_combo_ids <- lapply(data_elements, function(x) x$categoryCombo$id)
  
  # Get all categoryCombos from DHIS2
  category_combos <- lapply(category_combo_ids, function(x) getCategoryCombos(base.url, x))
  
  # From the category_combos df  extract the category ids, beware that thare can be more than one category
  # and the categories are lists
  
  category_ids <- lapply(category_combos, function(x) x$categories)
  # Extract every value for each element of the list
  category_ids <- lapply(category_ids, function(x) lapply(x, function(y) y$id))
  
  #unlist the category_ids
  category_ids <-  unlist(category_ids)
  
  # Get all categories from DHIS2
  categories <- lapply(category_ids, function(x) getCategories(base.url, x))
  
  # Extract all categoryOptions ids  from categories df
  category_option_ids <- lapply(categories, function(x) x$categoryOptions)
  category_option_ids <- unlist(category_option_ids)
  
  # make a list of category_option_ids where each element is a list of category_option_ids
  
  for (v in 1:length(category_option_ids)) {
    category_option_ids[v] <- as.list(category_option_ids[v])
    
  }
  
  # Get all categoryOptions from DHIS2
  #categoryOptions <- lapply(category_option_ids, function(x) getCategoryOptions(base.url, x))
  
  category_options <- list()
  for (i in 1:length(category_option_ids)) {
    category_options[[i]] <- getCategoryOptions(base.url, category_option_ids[[i]])
    
  }
  
  # Extract names from each element in the list
  names_list <- sapply(category_options, function(x) x$name)
  unique_indices <- match(unique(names_list), names_list)
  
  # Subset the list to keep only unique elements
  unique_list <- category_options[unique_indices]
  
  
  # filter some fields from categoryOptions id, code, name, shortName, displayName
  df_categoryOptions_filtered <- lapply(unique_list, function(x) {
    x <- x[c("id", "name")]
    return(x)
  })
  
  #add code and displayNmae property  to the df_categoryOptions_filtered
  df_categoryOptions_filtered <- lapply(df_categoryOptions_filtered, function(x) {
    x$code <- ifelse(nchar(x$name) > 50, substr(x$name, 1, 40), x$name)
    x$shortName <- ifelse(nchar(x$name) > 50, substr(x$name, 1, 40), x$name)
    x$sharing <- sharing
    return(x)
  })
  
  
  # Extract all ids from the df_categoryOptions
  category_options_ids_list <- sapply(df_categoryOptions, function(x) x$id)
  
  # check which df_categoryOptions_filtered does not exists in the df_categoryOptions
  
  df_new_category_options <- lapply(df_categoryOptions_filtered, function(x) {

      if (x$id %in% category_options_ids_list) {
        return(NULL)
      } else {
        return(x)
      }
    
  })
  
  # Remove NULL elements from the list
  df_new_category_options <- df_new_category_options[sapply(df_new_category_options, function(x) !is.null(x))]
  
  ## STAGE I - Send categoryOptions objects to DHIS2
  # loop all elements in the list df.categoryOptions.filtered and send data individually

  vec_response_categoryOptions <- list()
  for (i in 1:length(df_new_category_options)) {
    
    ou.response <- importCategoryOptions_v240(base.url.v240,df_new_category_options[[i]])
    # wait 3 second berfore next request
    vec_response_categoryOptions[[i]] <- ou.response
    # if response status codeis  201   (created) print the response
    if (ou.response$status_code == 201) {
      print(paste0(i," ",df_new_category_options[[i]]$id , " -  created sucessfully"))
    } else {
      print(paste0(i," ",df_new_category_options[[i]]$id , " -  failed to create"))
    }
    Sys.sleep(3)
    
  }
  
  # Stage II - Send categories objects to DHIS2
  
  
  # Filter id, name, code ,dataDimensionType, publicAcess,externalAccess, publicAccess, categories
  df_categories_filtered <- lapply(categories, function(x) {
    x <- x[c("id","name","externalAccess","publicAccess","dimensionType","dataDimensionType","dataDimension","items","categoryOptions")]
    return(x)
  })
  
  
  #add shortName property  to the df_categories_filtered df
  df_categories_filtered <- lapply(df_categories_filtered, function(x) {
    x$shortName <- ifelse(nchar(x$name) > 50, substr(x$name, 1, 40), x$name)
    x$sharing <- sharing
    return(x)
  })
  
  
  category_ids_list <- sapply(df_categories_filtered, function(x) x$id)
  unique_indices <- match(unique(category_ids_list), category_ids_list)
  category_unique_list <- df_categories_filtered[unique_indices]
  
  # Extract all ids from the category_unique_list
  
  category_ids_list <- sapply(df_categories, function(x) x$id)
  
  
  # check which category_unique_list does not exists in the df_categories
  
  df_new_categories <- lapply(category_unique_list, function(x) {
    
    if (x$id %in% category_ids_list) {
      return(NULL)
    } else {
      return(x)
    }
    
  })
  
  # Remove NULL elements from the list
  df_new_categories <- df_new_categories[sapply(df_new_categories, function(x) !is.null(x))]
  
  
  # Send category_unique_list objects to DHIS2
  # loop all elemnts in the list category_unique_list and send data individually

  
  vec_response_categories <- list()
  
  for (i in 1:length(df_new_categories)) {
    
    ou.response <- importCategories_v240(base.url.v240,df_new_categories[[i]])
    
    vec_response_categories[[i]] <- ou.response
    # if response status codeis  201   (created) print the response
    if (ou.response$status_code == 201) {
      print(paste0(i," ",df_new_categories[[i]]$id ," " ,df_new_categories[[i]]$name , " -  created sucessfully"))
    } else {
      print(paste0(i," ",df_new_categories[[i]]$id  ," " ,df_new_categories[[i]]$name ," -  failed to create"))
    }
    Sys.sleep(3)
  }
  
  

  # Stage III - Send categoryOptionCombos objects to DHIS2
  
  # Filter id, name, code ,dataDimensionType, publicAcess,externalAccess, publicAccess, categories
  df_categoryCombos_filtered <- lapply(category_combos, function(x) x[c('id', 'name', 'dataDimensionType', 'externalAccess', 'categories')])
  
  
  #add sharing property  to the df_categoryCombos_filtered df
  df_categoryCombos_filtered <- lapply(df_categoryCombos_filtered, function(x) {
    x$sharing <- sharing
    x$code <- ifelse( nchar(x$name) > 50, substr(x$name, 1, 40), x$name)
    x$publicAcess <- "r-------"
    return(x)
  })
  
  
  category_combos_ids_list <- sapply(df_categoryCombos_filtered, function(x) x$id)
  unique_indices <- match(unique(category_combos_ids_list), category_combos_ids_list)
  category_combos_unique_list <- df_categoryCombos_filtered[unique_indices]
  
  
  # Extract all ids from the df_categoryOptionsCombos
  category_combos_ids_list <- sapply(df_categoryOptionCombos, function(x) x$id)
  
  # check which category_combos_unique_list does not exists in the df_categoryOptiopnCombos
  
  df_new_category_combos <- lapply(category_combos_unique_list, function(x) {
    
    if (x$id %in% category_combos_ids_list) {
      return(NULL)
    } else {
      return(x)
    }
    
  })
  
  # Remove NULL elements from the list
  df_new_category_combos <- df_new_category_combos[sapply(df_new_category_combos, function(x) !is.null(x))]

  
  
  # Send df_new_category_combos objects to DHIS2
  # loop all elemnts in the list df_new_category_combos and send data individually

  
  vec_response_categoryCombos <- list()
  
  for (i in 1:length(df_new_category_combos)) {
    
    ou.response <- importCategorieCombos_v240(base.url.v240,df_new_category_combos[[i]])
    
    vec_response_categoryCombos[[i]] <- ou.response
    # if response status codeis  201   (created) print the response
    if (ou.response$status_code == 201) {
      print(paste0(i," ",df_new_category_combos[[i]]$id ," " ,df_new_category_combos[[i]]$name , " -  created sucessfully"))
    } else {
      print(paste0(i," ",df_new_category_combos[[i]]$id  ," " ,df_new_category_combos[[i]]$name ," -  failed to create"))
    }
    Sys.sleep(3)
  }
  
  
  # Stage IV - Send dataElements objects to DHIS2
  
  # Filter id, name, valueType ,aggregationType, domainType,externalAccess, zeroIsSignificant, optionSetValue from dataElements
  df_dataElements_filtered <- lapply(data_elements, function(x) {
    x <- x[c("id","name","shortName","valueType","aggregationType","domainType","externalAccess",
             "zeroIsSignificant","optionSetValue","publicAccess","periodOffset","categoryCombo")]
    return(x)
    
  })
  
  
  #add shortName property  to the df_dataElements_filtered df
  df_dataElements_filtered <- lapply(df_dataElements_filtered, function(x) {
    x$shortName <- ifelse(nchar(x$shortName) > 50, substr(x$shortName, 1, 40), x$shortName)
    x$sharing <- sharing
    x$publicAccess <- "r-------"
    return(x)
  })
  
  
  
  
  data_element_ids_list <- sapply(df_dataElements_filtered, function(x) x$id)
  unique_indices <- match(unique(data_element_ids_list), data_element_ids_list)
  data_elements_unique_list <- df_dataElements_filtered[unique_indices]
  
  # Extract all ids from the df_dataElements
  data_element_ids_list <- sapply(df_dataElements, function(x) x$id)
  
  # check which data_elements_unique_list does not exists in the df_dataElements
  
  df_new_data_elements <- lapply(data_elements_unique_list, function(x) {
    
    if (x$id %in% data_element_ids_list) {
      return(NULL)
    } else {
      return(x)
    }
    
  })
  
  # Remove NULL elements from the list
  df_new_data_elements <- df_new_data_elements[sapply(df_new_data_elements, function(x) !is.null(x))]
  
  
  # Find all  elements that have the categoryCombo id property = "nSPCuYWOkrg" and
  # replace the id to bjDvmb4bfuf in the df_new_data_elements
  
  data_element_default_id <- sapply(df_new_data_elements, function(x) x$categoryCombo$id)
  default_indexes <- which(data_element_default_id=="nSPCuYWOkrg")
  if(length(default_indexes)>0){
    for (i in default_indexes) {
      df_new_data_elements[[i]]$categoryCombo$id <- "bjDvmb4bfuf"
    }
  }
  
  
  # Send df_new_data_elements objects to DHIS2
  # loop all elemnts in the list df_new_data_elements and send data individually

  
  vec_response_data_elements <- list()
  
  for (i in 1:length(df_new_data_elements)) {
    
    ou.response <- importDataElements_v240(base.url.v240,df_new_data_elements[[i]])
    
    vec_response_data_elements[[i]] <- ou.response
    # if response status codeis  201   (created) print the response
    if (ou.response$status_code == 201) {
      print(paste0(i," ",df_new_data_elements[[i]]$id ," " ,df_new_data_elements[[i]]$name , " -  created sucessfully"))
    } else {
      print(paste0(i," ",df_new_data_elements[[i]]$id  ," " ,df_new_data_elements[[i]]$name ," -  failed to create"))
    }
    Sys.sleep(3)
  }
  


  # STAGE V - Send dataEntryForm objects to DHIS2  
  
  #Get data_entry_form ID
  data_entry_form_id <- ds$dataEntryForm$id
  
  #Get dataEntryForm
  
  data_entry_form <- getDataEntryForm(base.url, data_entry_form_id)
  
  # Filter id,name,format ,htmlCode,format
  df_data_entry_form_filtered <- data_entry_form[c("id","name","format","htmlCode","format","externalAccess")]
  
  
  #Modify PublicAcess and Sharing Properties  in the df_data_entry_form_filtered df
  df_data_entry_form_filtered$sharing <- sharing
  
  
  # Send df_data_entry_form_filtered object to DHIS2
  response <- importDataEntryForms_v240(base.url.v240, df_data_entry_form_filtered)
  
  # Check the response
  if(response$status_code == 201){
    print( paste0(df_data_entry_form_filtered$name, " dataset was successfully imported"))} else {
      print( paste0(df_data_entry_form_filtered$name, " dataset was not imported"))
    }
  
# STAGE VI - Send dataSet objects to DHIS2
  
  # Replace the categoryCombo id property = "nSPCuYWOkrg" with  id  "bjDvmb4bfuf" in the datim.dataset
  if(ds$categoryCombo$id == "nSPCuYWOkrg"){
    ds$categoryCombo$id <- "bjDvmb4bfuf"
    
  }
  
  
  
  # Filter id,name,expiryDays,openFuturePeriods,periodType,openPeriodsAfterCoEndDate,
  #publicAccess,dataSetElements, categoryCombo,indicators,organisationUnits from the datim.dataset
  df_dataset_filtered <- ds[c("id","name","expiryDays","openFuturePeriods","periodType","openPeriodsAfterCoEndDate",
                                         "publicAccess","dataSetElements", "categoryCombo","indicators","dataEntryForm","organisationUnits")]
  
  
  
  #Modify PublicAcess and Sharing Properties  in the df_dataset_filtered df
  df_dataset_filtered$sharing <- sharing
  df_dataset_filtered$publicAccess <- "r-------"
  df_dataset_filtered$shortName <- ifelse(nchar(df_dataset_filtered$name) > 50, substr(df_dataset_filtered$name, 1, 40), df_dataset_filtered$name)
  
  
  # Remove dataSet Property from the dataSetElements list
  df_dataset_filtered$dataSetElements <- lapply(df_dataset_filtered$dataSetElements, function(x) {
    x$dataSet <- NULL
    return(x)
  })
  
  # Send df_dataset_filtered object to DHIS2
  response <- importDataSets_v240(base.url.v240, df_dataset_filtered)
  
  # Check the response
  if(response$status_code == 201){
    print( paste0(df_dataset_filtered$name, " dataset was successfully imported"))} else {
      print( paste0(df_dataset_filtered$name, " dataset was not imported"))
    }
  
  
  
}
