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
#' @examples
#'
#' @docType methods
#' @rdname dalliance-methods
#' @export
setGeneric("dalliance",
           function(data=NULL,
                    genome=NULL,
                    annotation=NULL,
                    width=NULL,
                    height=NULL,
                    colors=NULL,
                    combine_replicates=FALSE,
                    outpath=NULL)
             standardGeneric("dalliance") )


# ---------------------------------------------------------------------------- #
#' @rdname dalliance-methods
#' @usage  \\S4method{dalliance}{data.frame}(data,genome, annotation, width, height)
setMethod("dalliance",signature("data.frame"),
          function(data=NULL, genome=NULL, annotation=NULL,
                   width = NULL, height = NULL){

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
    if(!is.null(color)){
      if(!length(color) == length(data$Sample)){
        stop('number of colors does not correspond to the number of samples')

      }else{
        if(combine_replicates){
          fac = with(data, paste(Sample, Replicate))

        }else{
          fac = data$sample
        }
        data$Color = colors[as.numeric(as.factor(fac))]
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
                      annotation = predefined_annotations(annotation))
    )

    # -------------------------------------------------------------- #
    # create the widget
    htmlwidgets::createWidget("dallianceR", x, width = width, height = height,
                              elementId='svgHolder')
})

# ---------------------------------------------------------------------------- #
#' @rdname dalliance-methods
#' @usage  \\S4method{dalliance}{GRanges}(data, genome, annotation, width, height, colors, combine_replicates, outpath)
setMethod("dalliance",signature("GRanges"),
          function(data, genome, annotation,
                   width, height, colors, combine_replicates, outpath){


          if(!is.character(outpath) | !file.exists(outpath))
            stop('outpath is not a valid path')

})

# ---------------------------------------------------------------------------- #
#' @rdname dalliance-methods
#' @usage  \\S4method{dalliance}{GRangesList}(data, genome, annotation, width, height, colors, combine_replicates, outpath)
setMethod("dalliance",signature("GRangesList"),
          function(data, genome, annotation,
                   width, height, colors, combine_replicates, outpath){


            if(!is.character(outpath) | !file.exists(outpath))
              stop('outpath is not a valid path')

          })
