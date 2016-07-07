The [Hugo](http://gohugo.io/) static site generator uses its own markdown processor (Blackfriday) and has its own supplements to markdown via "shortcodes." This output format tries to produce hugo-y markdown from R markdown, negotiating the fact that the `rmarkdown` package must *always run pandoc* even when it is just converting knitted markdown into...markdown.

Plots are placed in a `{{< figure >}}` shortcode block, with a possible `caption` parameter (and the source file set appropriately).

R source from code chunks is placed in a `{{< highlight r >}}` block. To process these successfully, hugo to be able to find an installation of [pygments](http://pygments.org) (`pip install pygments`).

This is a work in progress, which I tweak when I hit some new eccentricity of Hugo. Use, copy, or modify at your own risk.
