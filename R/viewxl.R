#' viewxl
#' @title Seamlessly manipulate any rectangular data file between an Excel window and R session.

#' @aliases viewxl
#' @keywords viewxl

#' @description You can use this function for loading and manipulating any data.frame, data_frame, tbl_df, matrix, table, vector, or DocumentTermMatrix objects into your system-default spreadsheet software (e.g., Excel) in a real time. This function has employed \code{\link[writexl]{write_xlsx}} under the hood.

#' @export viewxl
#' @param x An object of class data.frame, matrix, table, vector, or DocumentTermMatrix.
#' @param ... Any additional arguments available for \link[writexl]{write_xlsx}.

#' @details
#' See example below.

#' @return Data object opened in a preferable spreadsheet application window which will in turn be called on your R session again.

#' @examples
#' if (interactive()) {
#'   library(ezpickr)
#'   data(airquality)
#'   str(airquality)
#'
#'   ## View your data object in your spreadsheet software:
#'   viewxl(airquality)
#'   # Then, when necessary, you can modify the opened data
#'   # in the spreadsheet and save it as a new data.
#'
#'   # You can pass a list object to the `view()` function like below:
#'   l <- list(iris = iris, mtcars = mtcars, chickwts = chickwts, quakes = quakes)
#'   viewxl(l)
#'   # Then, each list item will appear in your Excel window sheet by sheet.
#' }
#' @author JooYoung Seo, \email{jooyoung@psu.edu}
#' @author Soyoung Choi, \email{sxc940@psu.edu}

# Function starts:
viewxl <-
  function(x, ...) {

    # only for interactive sessions
    if (interactive()) {
      if (is.matrix(x) || is.table(x) || is.atomic(x)) {
        x <- data.frame(x)
      } else if (class(x)[1] == "DocumentTermMatrix") {
        m <- as.matrix(x)
        df <- data.frame(m, row.names = rownames(m))
        colnames(df) <- colnames(m)
        x <- tibble::rownames_to_column(df, "Document/Term")
      } else if (class(x)[1] == "TermDocumentMatrix") {
        m <- as.matrix(x)
        df <- data.frame(m, row.names = rownames(m))
        colnames(df) <- colnames(m)
        x <- tibble::rownames_to_column(df, "Term/Document")
      }

      tmp <- tempfile(fileext = ".xlsx")
      x <- suppressWarnings(tidyr::unnest(x))
      writexl::write_xlsx(x, tmp, ...)
      utils::browseURL(tmp)

      Sys.sleep(5)
      file <- readline("Press **CTRL+S** in the open Excel file to pass any modified data content into this R session.\nEnter the file name you want to save as (press enter to skip): ")

      if (file != "") {
        if (!stringr::str_detect(file, "(.xlsx)$")) {
          new_file <- paste0(file, ".xlsx")
        } else {
          new_file <- file
        }

        file.copy(from = tmp, to = paste0(getwd(), "/", new_file))
      }

      return(if (length(readxl::excel_sheets(path = tmp)) > 1) {
        purrr::map(purrr::set_names(readxl::excel_sheets(path = tmp)), readxl::read_excel, path = tmp)
      } else {
        readxl::read_excel(tmp)
      })
      file.remove(tmp)
    } # end interactive
    else {
      warning("This function is only useful in interactive sessions.")
    } # end not interactive
    invisible(NULL)
    # Function ends.
  }
