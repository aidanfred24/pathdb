test_that("convert_id converts vector", {
    skip_if_offline()

    data(hypoxia_reads)
    genes <- rownames(hypoxia_reads)[1:10]

    conv <- suppressMessages(convert_id(genes = genes, species_id = 96))
    expect_s3_class(conv, "data.frame")
    expect_in(c("id", "ens"), colnames(conv))
})

test_that("convert_id converts with data", {
    skip_if_offline()

    data(hypoxia_reads)
    genes <- rownames(hypoxia_reads)[1:10]
    sub_data <- hypoxia_reads[1:10, ]

    conv_data <- suppressMessages(
        convert_id(genes = genes, data = sub_data, species_id = 96)
    )
    expect_s3_class(conv_data, "data.frame")
    expect_equal(class(rownames(conv_data)), "character")
})

test_that("convert_id errors and invalid inputs", {
    skip_if_offline()

    data(hypoxia_reads)
    genes <- rownames(hypoxia_reads)[1:10]

    expect_null(suppressMessages(convert_id(genes = genes, species_id = NULL)))
    expect_null(
        suppressMessages(
            convert_id(genes = genes, species_id = 96, id_type = "invalid")
        )
    )
})

test_that("convert_id resolves duplicates by variance for Ensembl IDs", {
    skip_if_offline()

    genes <- c("ENST00000373020", "ENST00000612152") # both map to ENSG00000000003
    
    # Case 1: ENST00000373020 has higher variance
    sub_data1 <- data.frame(
        col1 = c(10, 1),
        col2 = c(1, 2),
        row.names = genes
    )
    conv1 <- suppressMessages(
        convert_id(genes = genes, data = sub_data1, species_id = 96, id_type = "ens")
    )
    expect_equal(conv1["ENSG00000000003", "col1"], 10)
    expect_equal(conv1["ENSG00000000003", "col2"], 1)

    # Case 2: ENST00000612152 has higher variance
    sub_data2 <- data.frame(
        col1 = c(1, 10),
        col2 = c(2, 1),
        row.names = genes
    )
    conv2 <- suppressMessages(
        convert_id(genes = genes, data = sub_data2, species_id = 96, id_type = "ens")
    )
    expect_equal(conv2["ENSG00000000003", "col1"], 10)
    expect_equal(conv2["ENSG00000000003", "col2"], 1)
})

test_that("convert_id resolves duplicates by variance for Entrez IDs", {
    skip_if_offline()

    genes <- c("ENST00000376545", "ENST00000383587") # both map to Entrez ID 23
    
    # Case 1: ENST00000376545 has higher variance
    sub_data1 <- data.frame(
        col1 = c(20, 2),
        col2 = c(2, 3),
        row.names = genes
    )
    conv1 <- suppressMessages(
        convert_id(genes = genes, data = sub_data1, species_id = 96, id_type = "entrez")
    )
    expect_equal(conv1[conv1$entrez == 23, "col1"], 20)
    expect_equal(conv1[conv1$entrez == 23, "col2"], 2)

    # Case 2: ENST00000383587 has higher variance
    sub_data2 <- data.frame(
        col1 = c(2, 20),
        col2 = c(3, 2),
        row.names = genes
    )
    conv2 <- suppressMessages(
        convert_id(genes = genes, data = sub_data2, species_id = 96, id_type = "entrez")
    )
    expect_equal(conv2[conv2$entrez == 23, "col1"], 20)
    expect_equal(conv2[conv2$entrez == 23, "col2"], 2)
})

test_that("convert_id with id_type = 'entrez' and NULL data works", {
    skip_if_offline()

    genes <- c("ENST00000376545", "ENST00000383587")
    conv <- suppressMessages(
        convert_id(genes = genes, species_id = 96, id_type = "entrez")
    )
    expect_s3_class(conv, "data.frame")
    expect_in(c("id", "entrezgene_id"), colnames(conv))
})



