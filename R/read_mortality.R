#' Download microdata of death records from Brazil's census
#'
#' @description
#' Download microdata of death records from Brazil's census. Data collected in
#' the sample component of the questionnaire.
#'
#' @template year
#' @template columns
#' @template add_labels
#' @template as_data_frame
#' @template showProgress
#' @template cache
#'
#' @return An arrow `Dataset` or a `"data.frame"` object.
#' @export
#' @family Microdata
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' library(censobr)
#'
#' # return data as arrow Dataset
#' df <- read_mortality(year = 2010,
#'                      showProgress = FALSE)
#'
#' # dplyr::glimpse(df)
#'
#' # return data as data.frame
#' df <- read_mortality(year = 2010,
#'                      as_data_frame = TRUE,
#'                      showProgress = FALSE)
#'
#' # dplyr::glimpse(df)
#'
read_mortality <- function(year = 2010,
                           columns = NULL,
                           add_labels = NULL,
                           as_data_frame = FALSE,
                           showProgress = TRUE,
                           cache = TRUE){

  ### check inputs
  checkmate::assert_numeric(year)
  checkmate::assert_vector(columns, null.ok = TRUE)
  checkmate::assert_logical(as_data_frame)
  checkmate::assert_string(add_labels, pattern = 'pt', null.ok = TRUE)

  # available for the years:
  years <- c(2010)
  if (isFALSE(year %in% years)) { stop(paste0("Error: Data currently only available for the years ",
                                              paste(years, collapse = " ")))
      }

  ### Get url
  file_url <- paste0("https://github.com/ipeaGIT/censobr/releases/download/",
                     censobr_env$data_release, "/", year, "_mortality_",
                     censobr_env$data_release, ".parquet")


  ### Download
  local_file <- download_file(file_url = file_url,
                              showProgress = showProgress,
                              cache = cache)

  # check if download worked
  if(is.null(local_file)) { return(NULL) }

  ### read data
  df <- try(arrow::open_dataset(local_file), silent=FALSE)
  check_parquet_file(df)

  ### Select
  if (!is.null(columns)) { # columns <- c('V0002','V0011')
    df <- dplyr::select(df, dplyr::all_of(columns))
  }

  ### Add labels
  if (!is.null(add_labels)) { # add_labels = 'pt'
    df <- add_labels_mortality(arrw = df,
                               year = year,
                               lang = add_labels)
    }

  ### output format
  if (isTRUE(as_data_frame)) { return( dplyr::collect(df) )
  } else {
      return(df)
    }
}
