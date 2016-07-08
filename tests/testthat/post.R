

d <- tempfile()
dir.create(d)
rmd <- file.path(d, "post.Rmd")
md <- file.path(d, "post.md")

strlines <- function (x) strsplit(x, "\n", fixed=T)[[1]]

test_that("Code blocks are output as {{< highlight >}} blocks", {
    writeLines(
"---
output: hugormd::post
---

```{r}
2 + 2
```

```html
<h2>cool</h2>
```
",
    rmd)

    rmarkdown::render(rmd, quiet=T)
    expect_true(file.exists(md))
    expect_equal(readLines(md), strlines(
"---
output: hugormd::post
---

{{< highlight r >}}
2 + 2
{{< /highlight >}}

    ## [1] 4

{{< highlight html >}}
<h2>cool</h2>
{{< /highlight >}}
"
        )
    )

    rmarkdown::render(rmd, output_format=hugormd::post(highlight_shortcode=F),
                      quiet=T)
    expect_equal(readLines(md), strlines(
"---
output: hugormd::post
---

``` {.r}
2 + 2
```

    ## [1] 4

``` {.html}
<h2>cool</h2>
```
"
        )
    )

})


test_that("Figures are output as {{< figure >}} blocks", {
    writeLines(
"---
output: hugormd::post
---

```{r plot, echo=F}
plot(1:10, 1:10)
```

```{r cap, fig.cap=\"Caption\", echo=F}
plot(1:10, 1:10)
```
",
    rmd)

    rmarkdown::render(rmd, quiet=T)
    expect_true(file.exists(md))
    expect_equal(readLines(md),
        strlines(
"---
output: hugormd::post
---

{{< figure src=\"figure/plot-1.png\" >}}

{{< figure src=\"figure/cap-1.png\" caption=\"Caption\" >}}
"
        )
    )
})

test_that("kable defaults to html", {
    ll <- strlines(
"---
output: hugormd::post
---

```{r, echo=F}
knitr::kable(mtcars[1:3, 1:3])
```
"
)
    writeLines(ll, rmd)
    rmarkdown::render(rmd, quiet=T)
    ll[6] <- "knitr::kable(mtcars[1:3, 1:3], format=\"html\")"
    rmd2 <- file.path(d, "post2.Rmd")
    writeLines(ll, rmd2)
    rmarkdown::render(rmd2, quiet=T)

    expect_equal(readLines(md), readLines(file.path(d, "post2.md")))
})

# cleanup
if (file.exists(d)) unlink(d, recursive=T)

