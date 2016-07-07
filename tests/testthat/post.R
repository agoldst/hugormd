

d <- tempfile()
dir.create(d)
rmd <- file.path(d, "post.Rmd")
md <- file.path(d, "post.md")

test_that("Code blocks are output as {{< highlight >}} blocks", {
    writeLines(
"---
output: hugormd::post
---

```{r}
2 + 2
```
",
    rmd)

    rmarkdown::render(rmd)
    expect_true(file.exists(md))
    expect_equal(readLines(md),
        strsplit(
"---
output: hugormd::post
---

{{< highlight r >}}
2 + 2
{{< /highlight >}}

    ## [1] 4
",
        "\n", fixed=T)[[1]]
    )
})

# cleanup
if (file.exists(d)) unlink(d, recursive=T)

