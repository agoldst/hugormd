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
})

# cleanup
if (file.exists(testroot)) unlink(testroot, recursive=T)

    
