#' A Hugo markdown format
#'
#' An output format suitable for subsequent processing by hugo's Blackfriday.
#'
#' Unlike the default markdown format, YAML is always preserved and no TOC is
#' ever generated.
#'
#' @export
post <- function (
        fig_width=7, fig_height=5,
        fig_retina=NULL, dev="png",
        includes=NULL, md_extensions=NULL,
        pandoc_args=NULL) {

    args <- c(rmarkdown::includes_to_pandoc_args(includes), pandoc_args)


    knitr_options <- rmarkdown::knitr_options_html(fig_width, fig_height, 
        fig_retina, FALSE, dev)
    if (is.null(knitr_options$knit_hooks)) {
        knitr_options$knit_hooks <- list()
    }

    knitr_options$knit_hooks$plot <- plot_hook

    # custom package hook option: use hugo figure shortcode
    knitr_options$opts_chunk$use_shortcode <- TRUE

    # by default, output figures directly to figure
    knitr_options$opts_chunk$fig.path <- "figure/"

    rmarkdown::output_format(
        knitr=knitr_options,
        pandoc=rmarkdown::pandoc_options(
            to="markdown",
            from=rmarkdown:::from_rmarkdown(extensions=md_extensions),
            args=args
        ), 
        clean_supporting=FALSE,
        post_processor=post_process
    )
}

post_process <- function (metadata, input_file,
                          output_file, clean, verbose) {
    # yaml preservation (NOT via `pandoc --standalone`)
    # but copied from rmarkdown::md_document
    input_lines <- readLines(input_file, warn=FALSE)
    partitioned <- rmarkdown:::partition_yaml_front_matter(input_lines)
    output_body <- readLines(output_file, warn=FALSE)
    
    # de-sanitize shortcode delimiters
    output_body <- gsub("\\{\\{&lt; ", "{{< ", output_body)
    output_body <- gsub(" &gt;}}", " >}}", output_body)

    if (!is.null(partitioned$front_matter)) {
        output_lines <- c(
            partitioned$front_matter, "",
            output_body
        )
        writeLines(output_lines, output_file, useBytes=TRUE)
    }
    output_file
}

plot_hook <- function (x, options) {
    cap <- options$fig.cap
    
    if (is.null(options$use_shortcode) || !options$use_shortcode) {
        if (is.null(cap)) {
            cap <- ""
        } 
        result <- paste0("![", cap, "](", x, ")")
    } else {
        result <- paste0("{{< figure src=\"", x, "\"")
        if (!is.null(cap)) {
            result <- paste0(result, " caption=\"", cap, "\"")
        }

        # TODO more options: out.width, out.height, alignment...

        result <- paste0(result, " >}}")
    }
    result
}



