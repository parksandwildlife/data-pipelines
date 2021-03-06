#' R functions to retrieve content from CKAN
#' @author Florian.Mayer@dpaw.wa.gov.au
#'

 # install.packages("devtools")
 # install.packages("dplyr")
 # remotes::install_github("ropensci/ckanr")

if (file.exists("~/.Rprofile")) source("~/.Rprofile")

if (!require("pacman")) install.packages("pacman")
pacman::p_load(bitops,
               ckanr,
               caTools,
               colorspace,
               dplyr,
               tidyr,
               ggplot2,
               Hmisc,
               knitr,
               lubridate,
               markdown,
               readr,
               rjson,
               RColorBrewer,
               RCurl,
               scales,
               shiny,
               stringr,
               update=F)


# Set CKAN_URL to DPaW data catalogue
Sys.setenv(CKAN_URL="https://data.dpaw.wa.gov.au")

# Setup ckanr
ckanr::ckanr_setup(url=Sys.getenv("CKAN_URL"), key=Sys.getenv("CKAN_API_KEY"))
# ckan <- ckanr::src_ckan(Sys.getenv("CKAN_URL"))

# # Set default resource ID
# default_resource_id <- "ccc68eb7-8105-4cc8-8112-57bf1558e82f"


#' #' Get CPR data from intermediary CSV by park and asset slug
#' #'
#' #' Requires a CSV with raw data at the speficied or supplied URL
#' #' The CSV used here is created in ../reports/publish.py
#' #'
#' #' @param prk The park name as String
#' #' @param ast The asset name as String
#' #' @param url The URL of the CSV
#' #' @return a data.frame with one row of factors park, asset, and the six CPR
#' #' indicator flags.
#' #' @export
#' getCPR <- function(prk, ast, url = "../reports/cpr.csv"
#'                    #url = ckan_res("ece209a7-5974-4e04-9711-ee6457bc4a59")$url
#' ){
#'   cpr = read.table(url, header=TRUE, skip=0, sep=",")
#'   subset(cpr, park == prk & asset == ast)
#' }

#' #' Texify a string of text
#' #'
#' #' Substitutes characters with special meaning in Latex
#' #' with their Latex counterpart.
#' #'
#' #' @param text A string of text to be substituted.
#' #' @return The input text after substitution.
#' #' @import Hmisc
#' #' @export
#' #' @usage
#' #' texify("Testing % ~ $ & _ m2 sqm mL-1 L-1 < > ≥ ≤ ±")
#' texify <- function(text){
#'   text = gsub("%", "\\\\%", text)
#'   text = gsub("~", "\\\\~", text)
#'   #text = gsub("$", "\\\\$", text)
#'   text = gsub("&", "\\\\&", text)
#'   text = gsub("_", " ", text)
#'   text = gsub("R2", "$R^2$", text)
#'   text = gsub("m2", "$m^2$", text)
#'   text = gsub("m-2", "$m^-2$", text)
#'   text = gsub("sqm ", "$m^2$ ", text)
#'   text = gsub(" mL-1 ", " $mL^{-1}$ ", text)
#'   text = gsub(" L-1 ", " $L^{-1}$ ", text)
#'   text = gsub("<", "$<$", text)
#'   text = gsub(">", "$>$", text)
#'   text = gsub("≥", "$\\\\geq$", text)
#'   text = gsub("≤", "$\\\\leq$", text)
#'   text = gsub("±", "$\\\\pm$", text)
#'   text = gsub("+/-", "$\\\\pm$", text)
#'   text = gsub("=", "$=$", text)
#'   text = gsub("°", "$\\\\textdegree$", text)
#'
#'
#'   # add more substitutions as required
#'   return(Hmisc::escapeBS(text))
#' }

#' #' Return the value of a key in a dictionary or display a "missing" message
#' #'
#' #' @param dict A dictionary, as returned by ckanr::package_show
#' #' @param key A key as quoted string
#' #' @param texify Whether to convert the value from markdown to latex (default: F)
#' get_key <- function(dict, key, texify=F){
#'   val = dict[[key]]
#'   if (is.null(val)) {
#'     val = "not available"
#'     print(paste("Missing key:", key, "at", dict$url))
#'   }
#'   if (texify==T){ val <- texify(val)}
#'   val
#' }

#' #' Return a named list of metadata of a CKAN resource and its dataset
#' #'
#' #' Onto a named list containing CKAN API's resource_show() response result,
#' #' various useful bits are added, such as the resource's package_show result,
#' #' as well as vigorously abbreviated important bits of metadata used in the
#' #' Latex macro `ckr`.
#' #'
#' #' @param resource_id An existing CKAN resource id
#' #' @param url The base url of the resource's CKAN catalogue,
#' #'  optional, default: configured ckanr default
#' #' @return A named list containing resource and dataset metadata:
#' #'  top level:
#' #'    23 default `ckanr::resource_show` keys
#' #'    d (containing 34 default `ckanr::package_show` keys)
#' #'    ind - the dataset's title (heading, texified)
#' #'    syn - the dataset's description (synopsis, texified)
#' #'    pth - the local file path if the url is downloaded with wget
#' #'    cap - the resource's description (caption, texified)
#' #'    ori - the dataset's url
#' #'    src - the dataset's extra field "citation", texified
#' #'    luo <- the dataset's "last updated on"
#' #'    lub <- the dataset's maintainer (last updated by)
#' #'
#' ckan_res <- function(resource_id,
#'                      url=get_default_url()){
#'   if (resource_id == "") resource_id <- default_resource_id
#'   r <- ckanr::resource_show(resource_id, url = url)
#'   d <- ckanr::package_show(r$package_id, url = url)
#'   r$d <- d
#'   r$ind <- texify(d$title)
#'   r$syn <- ""#texify(d$notes) # a hack to exclude the unused synopsis
#'   r$pth <- strsplit(r$url, "//")[[1]][2]
#'   r$cap <- texify(r$description)
#'   r$ori <- paste0(url, "dataset/", d$id)
#'   r$src <- texify(d$citation) #get_key(d, "citation", texify=T)
#'   r$luo <- d$last_updated_on #get_key(d, "last_updated_on")
#'   r$lub <- d$maintainer
#'   r
#' }

#' #' Return an R data.frame with content from CKAN as required for MPA Figures
#' #'
#' #' @param urlstring The resource id of the figure itself.
#' #' @param type The Indicator type (Condition, Pressure, Response) - kept for
#' #'  backwards compatibility
#' #' @param debug Debug noise
#' #' @param url The CKAN base url, optional, default: `ckanr::get_default_url()`
#' mpa <- function(url,
#'                 type = 'Condition', debug = FALSE, ckanurl=get_default_url()){
#'   r <- ckan_res(strsplit(url, '/')[[1]][7])
#'   r
#' }

#' Load CSV from CKAN's datastore given a resource id
#'
#' The resource must be in the datastore (green API button visible).
#' Column names will not be sanitised.
#'
#' @param res_id The resource id of a CKAN CSV resource
#' @return A tibble of the CKAN CSV with parsed dates and title cased colnames.
#' @importFrom ckanr src_ckan
#' @importFrom dplyr matches mutate_at
#' @importFrom lubridate make_date
#' @importFrom tibble as_tibble
load_ckan_dst <- function(res_id, ...){
  ckan <- ckanr::src_ckan(Sys.getenv("CKAN_URL"))
  dplyr::tbl(src = ckan$con, from = res_id) %>%
    tibble::as_tibble(.) %>%
    dplyr::mutate_at(
      dplyr::vars(dplyr::matches("date")),
      lubridate::make_date)
}

#' Load CSV from CKAN's resource URL given a resource id
#'
#' The resource should be in the datastore (green API button visible).
#' Column names will not be sanitised.
#'
#' @param res_id The resource id of a CKAN CSV resource
#' @return A tibble of the CKAN CSV with parsed dates and title cased colnames.
#' @importFrom ckanr resoruce_show
#' @importFrom dplyr matches mutate_at
#' @importFrom lubridate make_date
#' @importFrom readr read_csv
#' @importFrom tibble as_tibble
load_ckan_csv <- function(res_id, ...){
  r <- ckanr::resource_show(res_id)
  d <- readr::read_csv(r$url) %>%
    tibble::as_tibble(.) %>%
    dplyr::mutate_at(
      dplyr::vars(dplyr::matches("date")),
      lubridate::make_date)
}


#' Create or update a CKAN resource.
#'
#'
#' @details The data will be written to CSV in a directory `data/` with the resource title
#'   in snake_case. If no resource ID is given, a resource will be created.
#'   The resource ID is returned in either case.
#' @param data A data frame to write to disk
#' @param resource_title A CKAN resource title
#' @param dataset_id A CKAN dataset (package) ID
#' @param resource_id A CKAN resource ID, default: NULL
#' @return The resource ID of the created or updated resource.
#' @examples
#' \notrun{
#' d <- ckanr::package_show("threatened-ecological-communities-database")
#'
#' # Run this once to create resource and retrieve resource ID
#' upload_to_ckan(a_tibble, "Resource title", d$id, resource_id = NULL)
#' # returns "502c74d7-32be-453f-aff6-c50aedd3deed" - paste into resource_id
#'
#' # Re-run this to update resource with new data
#' upload_to_ckan(a_tibble, "Resource title", d$id, resource_id = "502c74d7-32be-453f-aff6-c50aedd3deed")
#' }
upload_to_ckan <- function(data,
                           resource_title,
                           dataset_id,
                           resource_id=NULL){

  resource_filename <- resource_title %>%
    stringr::str_to_lower(.) %>%
    stringr::str_replace_all(., " ", "_") %>%
    paste0(".csv") %>%
    file.path("data", .)

  write_delim(data, resource_filename, delim = ",")

  if (is.null(resource_id)){
    cat("No resource ID given, creating a new resource for", resource_title, ": ")
    r <- ckanr::resource_create(package_id = dataset_id,
                                format = "csv",
                                name = resource_title,
                                upload = resource_filename)
  } else {
    cat("Updating CKAN resource", resource_title, ": ")
    r <- ckanr::resource_update(resource_id,
                                resource_filename)
  }
  r$id
}
