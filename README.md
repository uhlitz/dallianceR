# dallianceR

dallianceR is an interactive genome browser for R. It's based on JavaScript library [dalliance](https://biodalliance.org) and implemented with [htmlwidgets](https://htmlwidgets.org). 

You can install dallianceR with devtools: 

```{}

devtools::install_github("uhlitz/dallianceR")

```

Have a look at our [vignette](vignettes/dallianceRManual.Rmd) to get started.


# How to use this?

    # clone repo
    git clone this-repo.git ~/dalliancer

    # build the package
    cd ~/dalliancer
    R CMD INSTALL --with-keep.source -l ~/R .

    # start the HTTP server
    mkdir ~/tmp/dalliance
    cd ~/tmp/dalliance
    cp ~/dalliancer/worker-all.js .
    python ~/dalliancer/serve_http.py

    # in R
    library("dallianceR");
    dalliance(genome="GRCh38",
              annotation="GENCODEv21",
              data=dummy,
              display=TRUE,
              path="~/tmp/dalliance")
