test_that("get_pathways returns data frame", {
    skip_if_offline()

    pws <- suppressMessages(get_pathways(species_id = 99, category = "GOBP"))
    expect_s3_class(pws, "data.frame")
    expect_in(c("id", "name", "description", "n",
                "memo", "golevel"), colnames(pws))
})

test_that("get_pathways filtered by genes", {
    skip_if_offline()

    path_map <- suppressMessages(path_filter(species_id = 99,
                                             category = "GOBP"))
    test_genes <- path_map$gene[1:2]

    pws_filtered <- suppressMessages(
        get_pathways(species_id = 99, genes = test_genes, category = "GOBP")
    )
    expect_s3_class(pws_filtered, "data.frame")
    expect_in(c("pathwayID", "category", "name", "description", "n",
                "memo", "golevel"), colnames(pws_filtered))
})

test_that("get_pathways errors", {
    skip_if_offline()

    expect_error(
        get_pathways(species_id = 99,
                     genes = "NON_EXISTENT_GENE_ID",
                     category = "GOBP")
    )
})
