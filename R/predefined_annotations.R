#' predefined_annotations
#'
#' get predefined annotations to add to a ggbd object
#'
#' @param name short name of predefined annotation
#' @import magrittr
#' @import dplyr
#' @export
predefined_annotations <- function(name) {
  data(ann_tab)
  lookup <- name
  if(name %in% ann_tab$name) {
    ann_tab %>%
      dplyr::filter(name == lookup) %>%
      as.list %>%
      .[!is.na(.)]
  }
  else stop(paste("The annotation you asked for is not predefined.",
                  "Predefined annotations are:",
                  paste(ann_tab$name, collapse = ", ")))
}
list_predefined_annotations <- function() {
  data(ann_tab)
  ann_tab$name
}
