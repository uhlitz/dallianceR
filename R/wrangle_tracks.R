wrangle_tracks <- function(data, color = "Dark2") {

  data %>%
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
    .[data$Sample] ->
    ALPHA_list

  if (any("Color" %in% colnames(data))) {
  data %<>%
    mutate(Color = Experiment %>%
             unique %>%
             length %>%
             brewer.pal(color) %>%
             setNames(Experiment %>% unique) %>%
             .[Experiment])
  }

  lapply(ALPHA_list %>% names %>% unique, function(x) {
    data %>%
      filter(Sample == x) %$%
      Experiment %>%
      unique %>%
      {filter(data, Experiment == .)} %>%
      mutate(alpha = ALPHA_list[[x]])}) %>%
    setNames(unique(data$Sample)) -> ld
    do.call(rbind, lapply(names(ld), function(x){d=ld[[x]];d$group=x;d}))

}
