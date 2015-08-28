#' dalliancer
#'
#' htmlwidget for biodalliance
#'
#' @param ...
#' @param viewStart
#' @param viewEnd
#' @param width
#' @param height
#'
#' @import htmltools
#' @import htmlwidgets
dalliance <- function(reference = x, viewStart = 1, viewEnd = 10,
                           width = NULL, height = NULL) {

  # read the gexf file
  data <- "My_title"

  # create a list that contains the settings
  settings <- list(
    viewStart = viewStart,
    viewEnd = viewEnd
  )

  # pass the data and settings using 'x'
  x <- list(
    data = data,
    settings = settings
  )

  # create the widget
  htmlwidgets::createWidget("dalliancer", x, width = width, height = height)
}

#' @export
dalliancer_html <- function(id, ...){
  div(id = "svgHolder")
}

