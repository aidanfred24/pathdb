test_that("path_categories returns data frame", {
    skip_if_offline()
    
    cats <- suppressMessages(path_categories(species_id = 99))
    expect_s3_class(cats, "data.frame")
    expect_in("category", colnames(cats))
})

test_that("path_categories missing species error", {
    skip_if_offline()
    
    expect_error(path_categories(species_id = NULL))
})
