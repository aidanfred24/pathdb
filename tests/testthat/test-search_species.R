test_that("Incorrect name type", {
    skip_if_offline()

    expect_error(search_species("Human", name_type = "alll"))
    expect_error(search_species("Human", name_type = 1))
    expect_error(
        search_species("Human",
                       name_type = data.frame(name_type = c("all", "id")))
    )
})

test_that("Correct result format", {
    skip_if_offline()

    expect_equal(class(search_species("Human", name_type = "all")),
                 "data.frame")
    expect_equal(class(search_species("Cobra", name_type = "all")),
                 "data.frame")
    expect_equal(class(search_species(99, name_type = "id")),
                 "data.frame")
    expect_equal(class(search_species("Cobra", name_type = "primary")),
                 "data.frame")
    expect_equal(class(search_species("homo", name_type = "academic")),
                 "data.frame")
})

test_that("No species found", {
    skip_if_offline()

    expect_null(
        suppressMessages(search_species("Alien Species", name_type = "all"))
    )
})
