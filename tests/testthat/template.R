context("RMarkdown template")

testroot <- tempfile()
dir.create(testroot)
d <- file.path(testroot, "test")

test_that("template yields the expected files", {
    rmarkdown::draft(d, "post", "hugormd", edit=F)
    expect_true(dir.exists(d))
    expect_true(all(file.exists(
        file.path(d, c("test.Rmd", "Makefile"))
    )))
    expect_equal(system2("make", c("-C", d), stdout=F, stderr=F), 0)
    expect_true(file.exists(file.path(d, "test.md")))
    if (dir.exists(d)) {
        unlink(d, recursive=T)
    }
})

test_that("deployment does its thing", {
    dir.create(file.path(testroot, "hugo", "content", "post"), recursive=T)
    dir.create(file.path(testroot, "hugo", "static", "blog"), recursive=T)
    rmarkdown::draft(d, "post", "hugormd", edit=F)
    expect_equal(
        system2("make",
            c("-C", d, paste0("hugo_root=", file.path(testroot, "hugo")),
              "deploy"),
            stdout=F, stderr=F
        ),
        0
    )
    expect_true(file.exists(file.path(
        testroot, "hugo", "content", "post", "test.md"
    )))
    expect_equal(
        length(list.files(file.path(
            testroot, "hugo", "static", "blog"
        ))),
    0)

    Sys.sleep(1) # otherwise the file modification time will be identical at
                 # HFS+'s 1 second resolution, and make won't think there's a
                 # change!
    f <- file(file.path(d, "test.Rmd"), open="a")
    writeLines(
"
```{r cars}
ggplot(mtcars, aes(wt, mpg)) + geom_point()
```
",
        f
    )

    close(f)
    cnsl <- system2("make",
        c("-C", d, paste0("hugo_root=", file.path(testroot, "hugo")),
          "deploy"),
        stdout=T, stderr=T
    )
    expect_match(cnsl, "rmarkdown::render", all=F)
    expect_null(attr(cnsl, "status"))

    expect_true(file.exists(file.path(
        testroot, "hugo", "static", "blog", "test", "figure", "cars-1.png"
    )))
    expect_match(
        readLines(file.path(
            testroot, "hugo", "content", "post", "test.md"
        )),
        '{{< figure src="figure/cars-1.png" >}}',
        fixed=T, all=F
    )
})

# cleanup
if (file.exists(testroot)) unlink(testroot, recursive=T)

