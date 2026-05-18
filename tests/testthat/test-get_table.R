test_that("orgInfo returned", {
    skip_if_offline()

    tab <- suppressMessages(get_table())

    expect_equal(class(tab), "data.frame")
    expect_in(c("name", "name2", "idType", "id"), colnames(tab))
})

test_that("geneInfo returned", {
    skip_if_offline()

    tab <- suppressMessages(get_table(species_id = 1))

    expect_equal(class(tab), "data.frame")
    expect_in(c("ensembl_gene_id", "band", "chromosome_name", "entrezgene_id"),
              colnames(tab))
})

test_that("Non-character error", {
    skip_if_offline()
    expect_error(get_table(table = 1))
    expect_error(get_table(table = data.frame(table = "orgInfo")))
})

test_that("Table not found", {
    skip_if_offline()
    expect_error(get_table(table = "geneInfo"))
    expect_error(get_table(species_id = 1, table = "orgInfo"))
})
