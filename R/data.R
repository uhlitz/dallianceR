dummy <- data_frame(Experiment = rep(c("MCF7", "HEK293"), times = c(6, 4)),
                    Sample = c("A", "B", "A", "B", "A", "B", "C", "D", "C", "D"),
                    Replicate = c(1, 1, 2, 2, 3, 3, 1, 1, 2, 2),
                    bigwig = paste0("examples/bigwig/",
                                    list.files("examples/bigwig/", pattern = ".bw$")))
