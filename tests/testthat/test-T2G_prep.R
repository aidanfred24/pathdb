test_that("T2G_prep returns data frame", {
    skip_if_offline()

    t2g <- suppressMessages(T2G_prep(species_id = 99, category = "GOBP"))
    expect_s3_class(t2g, "data.frame")
    expect_in(c("description", "gene"), colnames(t2g))
})

test_that("T2G_prep filters by genes", {
    skip_if_offline()

    path_map <- suppressMessages(path_filter(species_id = 99,
                                             category = "GOBP"))
    test_genes <- path_map$gene[1:2]

    t2g_filtered <- suppressMessages(
        T2G_prep(species_id = 99, category = "GOBP", genes = test_genes)
    )
    expect_s3_class(t2g_filtered, "data.frame")
    expect_in(c("description", "gene"), colnames(t2g_filtered))
    expect_true(all(t2g_filtered$gene %in% test_genes))
})
