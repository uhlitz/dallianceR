#' predefined_genomes
#'
#' get predefined genomes for a ggbd object
#'
#' @param name short name of predefined genome
#' @import magrittr
#' @import dplyr
#' @export
predefined_genomes <- function(name) {
  data(ref_tab)
  lookup <- name
  if(name %in% ref_tab$name) {
    ref_tab %>%
      dplyr::filter(name == lookup) %>%
      as.list %>%
      .[!is.na(.)]
  }
  else stop(paste("The genome you asked for is not predefined.",
                  "Predefined genomes are:",
                  paste(ref_tab$name, collapse = ", ")))
}
list_predefined_genomes <- function() {
  data(ref_tab)
  ref_tab$name
}
