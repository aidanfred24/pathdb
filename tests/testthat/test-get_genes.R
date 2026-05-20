test_that("get_genes returns geneInfo table", {
    skip_if_offline()

    genes <- suppressMessages(get_genes(species_id = 99))
    expect_s3_class(genes, "data.frame")
    expect_in(c("ensembl_gene_id", "start_position",
                "percentage_gc_content", "gene_biotype",
                "description"), colnames(genes))
})

test_that("get_genes filtered by genes", {
    skip_if_offline()

    full_table <- suppressMessages(get_table(species_id = 99,
                                             table = "geneInfo"))
    test_genes <- full_table$ensembl_gene_id[1:3]

    filtered_genes <- suppressMessages(
        get_genes(species_id = 99, genes = test_genes)
    )
    expect_s3_class(filtered_genes, "data.frame")
    expect_in("ensembl_gene_id", colnames(filtered_genes))
    expect_true(nrow(filtered_genes) > 0)
})
