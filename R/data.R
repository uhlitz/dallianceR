dummy <- data_frame(Experiment = rep(c("MCF7", "HEK293"), times = c(6, 4)),
                    Sample = rep(c("A", "B"), times = 5),
                    Replicate = c(1, 1, 2, 2, 3, 3, 1, 1, 2, 2),
                    bigwig = paste0("examples/bigwig/",
                                    list.files("examples/bigwig/", pattern = ".bw$")))
