
set_transparent_theme <- function (before, options, envir) {
    if (!options$transparent) return()

    if (requireNamespace("ggplot2", quietly=TRUE)) {
        if (before) {
            hugormd_local$gg_theme <- ggplot2::theme_get()
            ggplot2::theme_update(
                plot.background=ggplot2::element_rect(
                    fill="transparent", color=NA),
                panel.background=ggplot2::element_rect(
                    fill="transparent", color=NA),
                legend.background=ggplot2::element_rect(
                    fill="transparent", color=NA)
            )
        } else {
            ggplot2::theme_set(hugormd_local$gg_theme)
        }
    }
}

