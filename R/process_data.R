#' Process Gene Expression Data
#'
#' Performs pre-processing, missing value imputation, filtering, and
#' transformation on gene expression count data.
#'
#' @param data A numeric matrix or data frame (> 1 columns) of gene expression
#' counts.
#' @param missing_value Character. Method to handle missing values. Options:
#'   * `"geneMedian"`: Impute using the median expression of the gene across
#'   samples.
#'   * `"treatAsZero"`: Replace NAs with 0.
#'   * `"groupMedian"`: Impute using the median of the sample group
#'   (detected from colnames).
#' @param min_cpm Numeric. Minimum counts per million threshold for filtering
#'   genes.
#' @param n_min_samples Numeric. Minimum number of samples that must meet
#'   the `min_cpm` threshold for a gene to be retained.
#' @param rescale Logical. TRUE allows for rescaling if values are exceedingly
#'   large.
#'
#' @returns The processed and transformed data matrix.
#'
#' @export
#' @examples
#' # Check example data
#' summary(pathdb::hypoxia_reads)
#' nrow(pathdb::hypoxia_reads)
#'
#' # YOU decide how your data is transformed.
#' # Here, we want to:
#' # Replace missing values with median
#' # Set minimum counts-per-million of 0.4
#' # Meet CPM threshold in 2 samples
#' # Keep raw counts
#'
#' hypox_filtered <- process_data(data = pathdb::hypoxia_reads,
#'                                missing_value = "geneMedian",
#'                                min_cpm = 0.4,
#'                                n_min_samples = 2)
#'
#' # Check filtered data
#' summary(hypox_filtered)
#' nrow(hypox_filtered)
#'
process_data <- function(data,
                         missing_value = "geneMedian",
                         min_cpm = 0.5,
                         n_min_samples = 1,
                         rescale = FALSE) {

    # Check for gene ids in data frame
    if (is.data.frame(data)) {
        char_cols <- sapply(data, function(x) is.character(x) || is.factor(x))

        if (sum(char_cols) > 1) {
            stop(paste0("Data frame must have only one column of character ",
                        "or factor (gene IDs) data."))

        } else if (sum(char_cols) == 1) {

            # Assign gene ids to rownames
            id_col <- which(char_cols)
            rownames(data) <- trimws(as.character(data[, id_col]))
            data <- data[, !char_cols]

        }
    }
    # Sort by standard deviation
    data <- data[order(-apply(data[, 1:dim(data)[2], drop = FALSE],1,
                              function(x) sd(x, na.rm = TRUE)
    )
    ), ]

    # Missing values in expression data
    if (sum(is.na(data)) > 0) {
        # Check param
        if (missing_value == "geneMedian") {
            # Get row medians
            row_medians <- apply(data, 1, function(y) median(y, na.rm = T))
            # Find missing vals in each column, replace with respective median
            for (i in 1:ncol(data)) {
                val_miss_row <- which(is.na(data[, i]))
                data[val_miss_row, i] <- row_medians[val_miss_row]
            }
        } else if (missing_value == "treatAsZero") {
            # Enter 0 for any NA
            data[is.na(data)] <- 0
        } else if (missing_value == "groupMedian") {
            # Detect column names in same experimental group
            sample_groups <- detect_groups(colnames(data))

            for (group in unique(sample_groups)) {
                samples <- which(sample_groups == group)
                # Row medians of sample group
                row_medians <- apply(
                    data[, samples, drop = F],
                    1,
                    function(y) median(y, na.rm = T)
                )
                # Find missing vals in each column, replace with group median
                for (i in samples) {
                    missing <- which(is.na(data[, i]))
                    if (length(missing) > 0) {
                        data[missing, i] <- row_medians[missing]
                    }
                }
            }
            # If any NAs left, replace with row median
            if (sum(is.na(data)) > 0) {
                row_medians <- apply(
                    data,
                    1,
                    function(y) median(y, na.rm = T)
                )
                for (i in 1:ncol(data)) {
                    missing <- which(is.na(data[, i]))
                    data[missing, i] <- row_medians[missing]
                }
            }
        }
    }

    data <- round(data, 0)
    # Check if any columns have all zeros
    if (any(apply(data, 2, function(col) all(col == 0)))) {
        return(as.matrix(data))
    }

    # Find data with cpm > min_cpm
    data <- data[which(
        apply(edgeR::cpm(edgeR::DGEList(counts = data)),
              1,
              function(y) sum(y >= min_cpm)
        ) >= n_min_samples), ]

    if (max(data) > 2e9) {

        if (rescale){
            # ratio of max data (problematic value) to largest integer
            scale_factor <- max(data) / (2^32 - 1)
            # round up scale_factor to the nearest integer
            scale_factor <- ceiling(scale_factor / 10 + 1) * 10
            # divide by scale factor and round to the nearest integer,
            # for the entire matrix,
            data <- round(data / scale_factor)

            message(paste0("Count data rescaled/divided by ", scale_factor,
                           " and rounded to nearest integer"))

        } else {
            message(paste0("Data contains values greater than 2 billion.",
                           " Values of this size may raise integer overflow",
                           " related errors for other packages. Not required,",
                           " but consider rescaling values with",
                           " rescale = TRUE"))
        }
    }

    # Sort by row standard deviation
    data <- data[order(-apply(data[, 1:dim(data)[2], drop = FALSE], 1, sd)), ]

    return(as.matrix(data))
}

#' Detect Groups by Sample Names
#'
#' Detects experimental groups based on column names in the data or an
#' optional sample info matrix.
#'
#' @param sample_names Vector of column names (sample IDs) from the data.
#' @param sample_info Optional matrix or data frame of experiment design information.
#'   If `NULL`, groups are inferred by stripping numeric suffixes and "Rep" labels
#'   from `sample_names`.
#'
#' @returns A character vector representing the group assignment for each sample.
#' @note This function is mainly called internally by other processing functions.
#' @noRd
detect_groups <- function(sample_names, sample_info = NULL) {
    # sample_names are col names parsing samples by either the name
    # or using a data frame of sample infos.
    # Note that each row of the sample_info data frame represents a sample.
    sample_group <- NULL
    if (is.null(sample_info)) {
        # Remove all numbers from end
        # remove "_" from end
        # remove "_Rep" from end
        # remove "_rep" from end
        # remove "_REP" from end
        sample_group <- gsub(
            "[0-9]*$", "",
            sample_names
        )
        sample_group <- gsub("_$", "", sample_group)
        sample_group <- gsub("_Rep$", "", sample_group)
        sample_group <- gsub("_rep$", "", sample_group)
        sample_group <- gsub("_REP$", "", sample_group)
    } else {
        # the orders of samples might not be the same.
        # The total number of samples might also differ
        match_sample <- match(sample_names, row.names(sample_info))
        sample_info2 <- sample_info[match_sample, , drop = FALSE]
        if (ncol(sample_info2) == 1) {
            # if there's only one factor
            sample_group <- sample_info2[, 1]
        } else {
            # multiple columns/factors
            foo <- function(y) paste(y, collapse = "_")
            sample_group <- unlist(apply(
                X = sample_info2,
                MARGIN = 1,
                FUN = foo
            ))
            names(sample_group) <- row.names(sample_info2)
            if (min(table(sample_group)) == 1) { # no replicates?
                sample_group <- sample_info2[, 1]
            }
        }
    }
    return(as.character(sample_group))
}
