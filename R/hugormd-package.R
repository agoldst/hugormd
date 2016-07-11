#' R Markdown and Hugo: Stuff
#'
#' An R Markdown output format (\code{hugormd::post}) and template (also called
#' "post") for writing posts for the Hugo static site generator in R markdown.
#' The Makefile included in the template needs to be edited: at a minimum, the
#' \code{hugo_root} variable has to be set to the path to a hugo site. The
#' default is for my system.
#'
#' @examples \dontrun{
#' library(rmarkdown)
#' draft("newpost", "post", "hugormd", edit=F) # or RStudio "New R Markdown"
#' # generate markdown and figures and copy into ~/myhugosite
#' system2("make", c("-C", "newpost", "hugo_root=~/myhugosite", "deploy"))
#' }
#'
#' @name hugormd
#' @docType package
NULL

# Initialize local storage
hugormd_local <- new.env(parent=emptyenv())

