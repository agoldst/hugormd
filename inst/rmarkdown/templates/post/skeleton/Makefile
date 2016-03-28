## Configuration ##

# name of source
Rmd := $(wildcard *.Rmd)
# name of output: stem only, no suffix or file path
target := $(basename $(Rmd))

## Optional configuration ##

md := $(target).md
hugo_root := /Users/agoldst/www/andrewgoldstone.com
post_target := $(hugo_root)/content/post/$(md)

# the files_source directory is copied UNDER files_target:
post_files_source := figure
post_files_target := $(hugo_root)/static/blog/$(target)

## Knitting ##

markdown:
	R -e 'rmarkdown::render("$(Rmd)", output_file="$(md)")'

## Deployment ##

deploy: markdown
	cp -f $(md) $(post_target)
	mkdir -p $(post_files_target)
	cp -f -R $(post_files_source) $(post_files_target)

clean:
	rm -f $(md)
	rm -rf $(post_files_source)

.DEFAULT_GOAL := markdown

.PHONY: markdown deploy clean

