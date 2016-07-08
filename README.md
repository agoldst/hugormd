The [Hugo](http://gohugo.io/) static site generator uses its own markdown processor (Blackfriday) and has its own supplements to markdown via "shortcodes." This output format tries to produce hugo-y markdown from R markdown, negotiating the fact that the `rmarkdown` package must *always run pandoc* even when it is just converting knitted markdown into...markdown.

Plots are placed in a `{{< figure >}}` shortcode block, with a possible `caption` parameter (and the source file set appropriately). Disable this by setting chunk option `use_shortcode=F`.

R source from code chunks is placed in a `{{< highlight r >}}` block. To process these successfully, hugo has to be able to find an installation of [pygments](http://pygments.org) (`pip install pygments`). See the Hugo documentation on [syntax highlighting](https://gohugo.io/extras/highlighting/). I have had better luck with this approach than with the javascript-based alternative. To disable this behavior, use the format option `highlight_shortcode`:

```yaml
output:
  hugormd::post:
    highlight_shortcode: false
```

A number of knitr chunk options are also set according to my usual defaults; these can be changed in the ordinary ways. In particular I turn cacheing on and set `error`, `warning`, and `message` all to `FALSE`.

Also included is an rmarkdown template for a post with an included Makefile for copying the generated markdown and accompanying figures into your Hugo site sources. This is a messy problem, because figures have to go in the `static` part of the Hugo hierarchy whereas posts go in `content`, but in the generated site the `figure` subdirectory has to end up under the same directory as the post's HTML. What I have works for me (sometimes?) but will need adjusting on any other system.

This is a work in progress, which I tweak whenever I discover some further eccentricity in Hugo or rmarkdown or pandoc. Use, copy, or modify at your own risk.

