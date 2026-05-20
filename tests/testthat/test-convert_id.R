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
