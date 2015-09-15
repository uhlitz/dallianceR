# ---------------------------------------------------------------------------- #
#' Description
#'
#' @param data \code{data.frame} , \code{GRanges}, a BAM file or a BigWig
#'  to be overlapped with ranges in \code{data}
#'
#' @param genome
#'
#' @param annotation
#'
#' @param width
#'
#' @param height
#'
#' @param colors
#'
#' @param combine_replicates
#'
#' @param outpath
#'
#' @param path
#'
#' @param display
#'
#' @param prefix
#'
#' @examples
#'
#' @docType methods
#' @rdname dalliance-methods
#' @export
setGeneric("dalliance",
           function(data=NULL,
                    genome="GRCh38",
                    annotation="GENCODEv21",
                    width=NULL,
                    height=NULL,
                    colors=NULL,
                    combine_replicates=FALSE,
                    outpath=NULL,
                    path="/tmp/dalliance",
                    display=FALSE,
                    prefix="http://localhost:8000/")
             standardGeneric("dalliance") )

# ---------------------------------------------------------------------------- #
# for NULL object
#' @rdname dalliance-methods
#' @usage  \\S4method{dalliance}{NULL}(data, genome, annotation, width, height,
#'                    colors, combine_replicates, outpath, path, display, prefix)
setMethod("dalliance",signature("data.frame"),
          function(data, genome, annotation,
                   width, height, colors,
                   combine_replicates, outpath,
                   path, display,
                   prefix){

        # constructs the arguments
        x <- list(

          ### implement combine replicates into wrangle tracks
          data = data,
          # data = wrangle_tracks(data, combine_replicates)

          settings = list(genome     = predefined_genomes(genome),
                          annotation = predefined_annotations(annotation),
                          prefix     = prefix)
        )

        # -------------------------------------------------------------- #
        # create the widget
        widget <- htmlwidgets::createWidget("dallianceR", x, width = width, height = height,
                                            elementId = "svgHolder")

        # "selfcontained" requires Pandoc to be installed.  We better not
        # add a dependency on Haskell for something as simple as
        # generating an HTML page.
        htmlwidgets::saveWidget(widget=widget,
                                file=file.path(path, "index.html"),
                                selfcontained=FALSE)

        if (display) {
            # TODO: run a local HTTP server first
            system2(command=getOption("browser"),
                    args=c(paste(prefix, "/index.html", sep="")))
        }


})


# ---------------------------------------------------------------------------- #
#' @rdname dalliance-methods
#' @usage  \\S4method{dalliance}{data.frame}(data,genome, annotation, width, height,
#'                    colors, combine_replicates, outpath, path, display, prefix)
setMethod("dalliance",signature("data.frame"),
          function(data, genome, annotation,
                   width, height, colors,
                   combine_replicates, outpath,
                   path, display,
                   prefix) {


    # -------------------------------------------------------------- #
    # checks the variables
    if(class(data) != 'data.frame')
      stop('data needs to be a data.frame object')

    columns.required = c('Experiment','Sample','Replicate','Path')
    if(!all(columns.required %in% colnames(data))){
      stop(paste('data is missing the following column names:',
                 setdiff(columns.required, colnames(data)), collapse=" "))
    }

    if(!is.character(genome))
        stop('genome needs to be a character vector')

    if(!is.character(annotation))
        stop('annotation needs to be a character vector')

    # -------------------------------------------------------------- #
    # Sets the colors
    if(!is.null(colors)){
      if(!length(colors) == length(data$Sample)){
        stop('number of colors does not correspond to the number of samples')

      }else{
        if(combine_replicates){
          fac = with(data, paste(Sample, Replicate))

        }else{
          fac = data$Sample
        }
        data$Color = colors[as.numeric(as.factor(fac))]
      }
    }

    # link all data files to the output directory, or else the HTTP
    # server won't be able to serve them.
    links <- file.path(path, basename(data$Path))
    for (i in 1:length(links)) {
        if (file.exists(data$Path[i])) {
            file.link(data$Path[i], links[i])
            data$Path[i] = basename(data$Path[i])
        }
    }

    # pass the data and settings using 'x'
    # -------------------------------------------------------------- #
    # constructs the arguments
    x <- list(

      ### implement combine replicates into wrangle tracks
      data = wrangle_tracks(data),
      # data = wrangle_tracks(data, combine_replicates)

      settings = list(genome     = predefined_genomes(genome),
                      annotation = predefined_annotations(annotation),
                      prefix     = prefix)
    )

    # -------------------------------------------------------------- #
    # create the widget
    widget <- htmlwidgets::createWidget("dallianceR", x, width = width, height = height,
                                        elementId = "svgHolder")

    # "selfcontained" requires Pandoc to be installed.  We better not
    # add a dependency on Haskell for something as simple as
    # generating an HTML page.
    htmlwidgets::saveWidget(widget=widget,
                            file=file.path(path, "index.html"),
                            selfcontained=FALSE)

    if (display) {
        # TODO: run a local HTTP server first
        system2(command=getOption("browser"),
                args=c(paste(prefix, "/index.html", sep="")))
    }
})

# ---------------------------------------------------------------------------- #
#' @rdname dalliance-methods
#' @usage  \\S4method{dalliance}{GRanges}(data, genome, annotation, width, height,
#'                    colors, combine_replicates, outpath, path, display, prefix)
setMethod("dalliance",signature("GRanges"),
          function(data, genome, annotation,
                   width, height, colors,
                   combine_replicates, outpath,
                   path, display,
                   prefix){


          if(!is.character(outpath) | !file.exists(outpath))
            stop('outpath is not a valid path')

})

# ---------------------------------------------------------------------------- #
#' @rdname dalliance-methods
#' @usage  \\S4method{dalliance}{GRangesList}(data, genome, annotation, width, height,
#'                    colors, combine_replicates, outpath, path, display, prefix)
setMethod("dalliance",signature("GRangesList"),
          function(data, genome, annotation,
                   width, height, colors,
                   combine_replicates, outpath,
                   path, display,
                   prefix){


            if(!is.character(outpath) | !file.exists(outpath))
              stop('outpath is not a valid path')

          })

# ---------------------------------------------------------------------------- #
#' @rdname dalliance-methods
#' @usage  \\S4method{dalliance}{tbl_df}(data, genome, annotation, width, height,
#'                    colors, combine_replicates, path, display, prefix)
setMethod("dalliance",signature("tbl_df"),
          function(data, genome, annotation,
                   width, height, colors,
                   combine_replicates,
                   path, display,
                   prefix){

          dalliance(as.data.frame(data), genome, annotation,width, height, colors,
                    combine_replicates, path, display,prefix)
})

