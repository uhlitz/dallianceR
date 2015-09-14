<<<<<<< HEAD
library(readr)
library(dplyr)
library(magrittr)
library(RColorBrewer)

dummy <- data_frame(Experiment = rep(c("MCF7", "HEK293"), times = c(6, 4)),
                    Sample = rep(c("A", "B"), times = 5),
                    Replicate = c(1, 1, 2, 2, 3, 3, 1, 1, 2, 2),
                    bigwig = paste0("examples/bigwig/",
                                   list.files("examples/bigwig/", pattern = ".bw$")))

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
=======
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
>>>>>>> 4daf32c522044d3529026826709520a12cfb5c43
                              "noDownsample: true",
                              "}"),
             style = paste0("{",
                            "type: 'default', ",
<<<<<<< HEAD
                            "method: '", Replicate, "', ",
=======
                            "method: '", Replicate, "', ", 
>>>>>>> 4daf32c522044d3529026826709520a12cfb5c43
                            "style: {",
                            "glyph: 'HISTOGRAM', ",
                            "BGCOLOR: '", Color,"', ",
                            "HEIGHT: 30, ",
                            "ALPHA: ", alpha,
<<<<<<< HEAD
                            "}}")) %>%
=======
                            "}}")) %>% 
>>>>>>> 4daf32c522044d3529026826709520a12cfb5c43
      do(track = paste0(",{",
                        "name: '", x, "', ",
                        "merge: 'concat', ",
                        "overlay: [", paste(.$overlay, collapse = ","), "], ",
                        "style: [", paste(.$style, collapse = ","), "]}")) %$%
<<<<<<< HEAD
      track
  }) %>%
    unlist %>% {
      do.call(cat, as.list(c(
        readLines("R/dalliance_pre.txt"),
        .,
        readLines("R/dalliance_post.txt"),
        sep = "\n\n")))
=======
      track 
  }) %>% 
    unlist %>% {
      do.call(cat, as.list(c(
        readLines("rna_seq/Rmd/dalliance_pre.txt"),
        ., 
        readLines("rna_seq/Rmd/dalliance_post.txt"),
        sep = "\n\n")))    
>>>>>>> 4daf32c522044d3529026826709520a12cfb5c43
    }
}

dalliance(dummy)

