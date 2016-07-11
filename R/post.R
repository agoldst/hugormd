#' A Hugo markdown format
#'
#' An output format suitable for subsequent processing by hugo's Blackfriday.
#' Unlike the default markdown format, YAML is always preserved, no TOC is ever
#' generated, and text is not wrapped. A plot hook is set to output figures as
#' a \code{{{< figure >}}} shortcode unless chunk option \code{use_shortcode}
#' is FALSE.
#'
#' Other default knitting options set here:
#' \code{tidy,error,warning,message,prompt} are all FALSE; \code{autodep,cache}
#' are TRUE; the figure output path is set to \code{figure/}; output width is
#' set to 44; and the global option \code{knitr.table.format} is temporarily
#' set to \code{html} so that \code{\link[knitr]{kable}} will output tables in
#' HTML (it cannot output blackfriday-compatible markdown tables). These
#' settings can be overridden in the usual ways.
#'
#' @param fig_width,fig_height,fig_retina,dev as in
#' \code{\link[rmarkdown]{html_document}}
#' @param fig_path global setting for \code{fig.path} chunk option (a final
#' \code{/} is automatically added if absent)
#' @param highlight_shortcode If TRUE (default), fenced code blocks become
#' \code{{{< highlight >}}} blocks
#' @param transparent_plots If TRUE, set background of base and ggplot2 plots 
#' to transparent. FALSE by default.
#' @param includes,md_extensions,pandoc_args as in
#' \code{\link[rmarkdown]{md_document}}
#'
#' @export
post <- function (
        fig_width=7, fig_height=5,
        fig_retina=NULL, dev="png",
        fig_path="figure",
        highlight_shortcode=TRUE,
        transparent_plots=FALSE,
        includes=NULL, md_extensions=NULL,
        pandoc_args=NULL) {

    args <- c(rmarkdown::includes_to_pandoc_args(includes),
              "--no-wrap",
              pandoc_args)

    knitr_options <- rmarkdown::knitr_options_html(fig_width, fig_height,
        fig_retina, FALSE, dev)
    if (is.null(knitr_options$knit_hooks)) {
        knitr_options$knit_hooks <- list()
    }
    # set plot hook
    knitr_options$knit_hooks$plot <- plot_hook
    # set transparent theme hook
    knitr_options$knit_hooks$transparent <- set_transparent_theme

    # custom package hook option: use hugo figure shortcode
    knitr_options$opts_chunk$use_shortcode <- TRUE
    # other chunk-option defaults
    knitr_options$opts_chunk$tidy <- FALSE
    knitr_options$opts_chunk$error <- FALSE
    knitr_options$opts_chunk$warning <- FALSE
    knitr_options$opts_chunk$message <- FALSE
    knitr_options$opts_chunk$prompt <- FALSE
    knitr_options$opts_chunk$autodep <- TRUE
    knitr_options$opts_chunk$cache <- TRUE

    if (transparent_plots) {
        knitr_options$opts_chunk$transparent <- TRUE
        knitr_options$opts_chunk$dev.args <- list(bg="transparent")
    }

    # set figure path: ensure terminal /
    knitr_options$opts_chunk$fig.path <- sub("([^/])$", "\\1/", fig_path)

    # code output width
    if (is.null(knitr_options$opts_knit)) {
        knitr_options$opts_knit <- list()
    }
    knitr_options$opts_knit$width <- 44

    # configure `kable` to default to html output
    ktformat <- getOption("knitr.table.format")

    if (is.null(ktformat)) {
        options(knitr.table.format="html")
    }

    rmarkdown::output_format(
        knitr=knitr_options,
        pandoc=rmarkdown::pandoc_options(
            to="markdown",
            from=rmarkdown:::from_rmarkdown(extensions=md_extensions),
            args=args
        ),
        clean_supporting=FALSE,
        post_processor=post_process(highlight_shortcode, ktformat)
    )
}

post_process <- function (highlight_shortcode, ktformat) {
    function (metadata, input_file,
                          output_file, clean, verbose) {
        # reset option we fiddled
        options(knitr.table.format=ktformat)

        # yaml preservation (NOT via `pandoc --standalone`)
        # but copied from rmarkdown::md_document
        input_lines <- readLines(input_file, warn=FALSE)
        partitioned <- rmarkdown:::partition_yaml_front_matter(input_lines)
        output_body <- readLines(output_file, warn=FALSE)

        # de-sanitize shortcode delimiters
        output_body <- gsub("\\{\\{&lt; ", "{{< ", output_body)
        output_body <- gsub(" &gt;}}", " >}}", output_body)

        if (highlight_shortcode) {
            # pandoc translates ```r to ``` {.r}; replace with
            # {{< highlight r >}}
            output_body <- gsub("^``` \\{\\.(\\w+)\\}",
                "{{< highlight \\1 >}}", output_body)
            # ``` on its own is always(?) the terminator of a highlight block
            output_body <- gsub("^```$", "{{< /highlight >}}", output_body)
        }

        if (!is.null(partitioned$front_matter)) {
            output_lines <- c(
                partitioned$front_matter, "",
                output_body
            )
            writeLines(output_lines, output_file, useBytes=TRUE)
        }
        output_file
    }
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



