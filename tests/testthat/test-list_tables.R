test_that("list_tables() returns character vector", {
    skip_if_offline()
    expect_equal(class(list_tables()), "character")
    expect_equal(class(list_tables(species_id = 1)), "character")
})
