test_that("path_filter returns mapping table", {
    skip_if_offline()

    pf <- suppressMessages(path_filter(species_id = 99, category = "GOBP"))
    expect_s3_class(pf, "data.frame")
    expect_in(c("gene", "pathwayID", "category"), colnames(pf))
})

test_that("path_filter missing species error", {
    skip_if_offline()

    expect_error(path_filter(species_id = NULL))
})

test_that("path_filter unmapped genes error", {
    skip_if_offline()

    expect_error(
        suppressMessages(
            path_filter(species_id = 99,
                        genes = "UNMAPPED_GENE",
                        category = "GOBP")
        )
    )
})
