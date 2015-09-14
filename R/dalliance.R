library(readr)
library(dplyr)
library(magrittr)
library(RColorBrewer)
dummy <- read_tsv("R/example_input.tsv")

dalliance <- function(input, color = "Dark2") {

  input %>%
    group_by(Experiment, Sample) %>%
    mutate(n_times = length(Sample)) %>%
    group_by(Experiment) %>%
    mutate(n_row = Sample %>% unique %>% length) %>%
    do(ALPHA = {
      n_row <- .$n_row
      n_times <- group_by(., Sample) %>%
        distinct(n_times) %$%
        n_times
      Sample <- .$Sample %>% unique
      diag(nrow = n_row) %>%
        add(0.001) %>%
        add(diag(-0.501, nrow = n_row)) %>%
        as.data.frame %>%
        lapply(rep, times = n_times) %>%
        setNames(Sample)
    }) %$%
    ALPHA %>%
    unlist(recursive = F) %>%
    .[levels(input$Sample)] ->
    ALPHA_list

  input %>%
    mutate(Color = Experiment %>%
             unique %>%
             length %>%
             brewer.pal(color) %>%
             setNames(Experiment %>% unique) %>%
             .[Experiment]) ->
    colored_input

  lapply(names(ALPHA_list), function(x) {
    colored_input %>%
      filter(Sample == x) %$%
      Experiment %>%
      unique %>%
      {filter(colored_input, Experiment == .)} %>%
      mutate(alpha = ALPHA_list[[x]],
             overlay = paste0("{",
                              "name: '", Replicate, "', ",
                              "bwgURI: 'data/", bigwig, "', ",
                              "noDownsample: true",
                              "}"),
             style = paste0("{",
                            "type: 'default', ",
                            "method: '", Replicate, "', ",
                            "style: {",
                            "glyph: 'HISTOGRAM', ",
                            "BGCOLOR: '", Color,"', ",
                            "HEIGHT: 30, ",
                            "ALPHA: ", alpha,
                            "}}")) %>%
      do(track = paste0(",{",
                        "name: '", x, "', ",
                        "merge: 'concat', ",
                        "overlay: [", paste(.$overlay, collapse = ","), "], ",
                        "style: [", paste(.$style, collapse = ","), "]}")) %$%
      track
  }) %>%
    unlist %>% {
      do.call(cat, as.list(c(
        readLines("R/dalliance_pre.txt"),
        .,
        readLines("R/dalliance_post.txt"),
        sep = "\n\n")))
    }
}

dalliance(dummy)

