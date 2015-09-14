#' @import htmlwidgets
#' @export
dalliance <- function(data=NULL, width = NULL, height = NULL) {

    # create a list that contains the settings
#     settings <- list(
#       drawEdges = drawEdges,
#       drawNodes = drawNodes
#     )

    # pass the data and settings using 'x'
    x <- list(
      data = data
    )

    # create the widget
    htmlwidgets::createWidget("dallianceR", x, width = width, height = height,
                              elementId = "svgHolder")
  }
