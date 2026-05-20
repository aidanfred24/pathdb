test_that("process_data returns processed matrix", {
    data(hypoxia_reads)
    sub_reads <- hypoxia_reads[1:100, ]
    
    proc <- process_data(data = sub_reads,
                         missing_value = "geneMedian",
                         min_cpm = 0.5,
                         n_min_samples = 1)
                         
    expect_true(is.matrix(proc))
    expect_true(nrow(proc) <= 100)
})

test_that("process_data groupMedian imputation", {
    data(hypoxia_reads)
    sub_reads <- hypoxia_reads[1:100, ]
    sub_reads[1, 1] <- NA
    
    proc <- process_data(data = sub_reads,
                         missing_value = "groupMedian",
                         min_cpm = 0.5,
                         n_min_samples = 1)
                         
    expect_true(is.matrix(proc))
    expect_false(any(is.na(proc)))
})

test_that("process_data invalid data stop error", {
    bad_df <- data.frame(
        gene1 = c("A", "B"),
        gene2 = c("C", "D"),
        val = c(1, 2)
    )
    expect_error(process_data(data = bad_df))
})
