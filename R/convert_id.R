#' Convert Gene IDs to Ensembl
#'
#' Queries the database to map user-provided gene identifiers to Ensembl/Entrez
#' IDs. To ensure best matching and conversion, please verify that all gene
#' identifiers have no whitespace and are at least 2 characters long.
#'
#' @param genes A vector or character string of gene identifiers to convert.
#' @param data Optional data frame or matrix. If provided, the function attempts
#'   to match `genes` to the row names or a column in `data` and merges the
#'   conversion results with the original data.
#' @param species_id Numeric. The ID of the species for the database connection.
#' @param id_type Character. The type of ID to convert to:
#'  * "ens" = Ensembl gene IDs (Default)
#'  * "entrez" = Entrez gene IDs
#'      * WARNING: Not all species or genes have Entrez gene IDs available
#'      * May take longer than Ensembl IDs
#'      * Will likely have duplicate Entrez IDs
#'
#' @returns A data frame.
#'   * If `data` is `NULL`: Returns a mapping table with original IDs and
#'   IDs of selected type.
#'   * If `data` is provided: Returns `data` merged with the IDs of selected
#'   type. Returns `NULL` if `species_id` is missing or no matches are found.
#'   * Any whitespace found in original IDs will be removed.
#' @md
#' @export
#'
#' @examplesIf interactive() && curl::has_internet()
#' # CAUTION: The human database is very large, running these examples require
#' # the download of the human database.
#'
#' # View our experimental gene IDs
#' head(rownames(hypoxia_reads))
#'
#' # Convert IDs to Ensembl format for further analysis
#' ens_conv <- convert_id(genes = rownames(hypoxia_reads),
#'                        species_id = 96)
#'
#' # Yields a conversion table for our genes
#' head(ens_conv)
#'
#' # Can also convert to Entrez IDs, if needed
#' entrez_conv <- convert_id(genes = rownames(hypoxia_reads),
#'                           species_id = 96,
#'                           id_type = "entrez")
#'
#' # Yields a conversion table for our genes
#' head(entrez_conv)
#'
#' # We want to automatically convert our IDs within our data
#' ens_hypoxia <- convert_id(genes = rownames(hypoxia_reads),
#'                           species_id = 96,
#'                           data = hypoxia_reads)
#'
#' # Original data
#' head(hypoxia_reads)
#'
#' # Converted data
#' head(ens_hypoxia)
#'
convert_id <- function(genes,
                       data = NULL,
                       species_id,
                       id_type = "ens") {
    if (is.null(species_id)) {
        message("Please provide species ID")
        return(NULL)
    } else if (!id_type %in% c("ens", "entrez")){
        message("Invalid ID type selected")
        return(NULL)
    }

    # Clean the raw genes vector
    # Remove quotes, raises SQL error
    cl_genes <- gsub(pattern = "[\"']", replacement = "", x = genes)

    # Split genes by tabs, whitespace, newlines; take first element
    # nothing is preserved following whitespace
    cl_genes <- sapply(strsplit(cl_genes, split = "[\t \n,]+"), function(x) x[1])

    # Make uppercase, trim any other whitespace
    cl_genes <- toupper(trimws(cl_genes))

    # genes should have at least two characters
    valid_id <- which(nchar(cl_genes) > 1)
    cl_genes <- cl_genes[valid_id]

    query_string <- paste0("('",
                           paste(unique(cl_genes), collapse = "', '"),
                           "')")

    conn_db <- connect_database(species_id = species_id)
    on.exit(DBI::dbDisconnect(conn_db))

    query_statement <- paste0(
        "select id,ens,idType from mapping where id IN ",
        query_string
    )

    result <- DBI::dbGetQuery(conn_db, query_statement)

    if (nrow(result) == 0) {
        message("No gene matches found")
        return(NULL)
    }

    if (id_type == "entrez"){
        entrez_string <- paste0("('",
                                paste(result$ens, collapse = "', '"),
                                "')")
        entrez_query <- paste0("select ensembl_gene_id, entrezgene_id from geneInfo where",
                               " ensembl_gene_id IN", entrez_string)
        entrez <- DBI::dbGetQuery(conn_db, entrez_query)

        result <- merge(x = result,
                        y = entrez,
                        by.x = "ens",
                        by.y = "ensembl_gene_id",
                        all.x = TRUE)

        result <- result[!is.na(result$entrezgene_id),]
    }

    # resolve multiple ID types, get the most matched
    best_id_type <- as.integer(
        names(
            sort(
                table(result$idType),
                decreasing = TRUE
            )
        )[1]
    )
    result <- result[result$idType == best_id_type, ]

    # Subject to change
    # one to many, keep one ensembl id, randomly
    # remove duplicates in query gene ids
    result <- result[which(!duplicated(result[, 1])), ]

    if (is.null(data) || is.null(dim(data))) {
        cl_genes <- as.data.frame(cl_genes)
        colnames(cl_genes)[1] <- "id"
        if (id_type == "ens"){
            result <- dplyr::left_join(
                x = result[, 1:2],
                y = cl_genes,
                by = "id"
            )
        } else {
            result <- dplyr::left_join(
                x = result[, c(2,4)],
                y = cl_genes,
                by = "id"
            )
        }
    } else {
        match_idx <- which(colSums(data == genes) == nrow(data))
        gene_col <- colnames(data)[match_idx]

        if (length(gene_col) == 0) {
            if (sum(rownames(data) == genes) == nrow(data)) {
                gene_col <- "rownames"
                # Create key from rownames
                data$rownames <- rownames(data)
            } else {
                stop("Genes not found in provided dataset")
            }
        }

        # Remove entries with length 1
        data <- data[valid_id,]
        # Replace gene column with cleaned gene IDs
        data[[gene_col]] <- cl_genes

        if (id_type == "entrez"){
            conversion_table <- result[,c(2,4)]
        } else {
            conversion_table <- result[,c(1,2)]
        }

        colnames(conversion_table) <- c(gene_col, id_type)

        result <- dplyr::left_join(
            x = conversion_table,
            y = data,
            by = gene_col
        )

        if (id_type == "ens"){
            result <- data.frame(result[,-2],
                                 row.names = result[,2])
        }

        if (gene_col == "rownames"){
            result <- result |>
                dplyr::select(-rownames)
        }
    }

    message(paste(nrow(result), "genes found with selected ID type"))
    return(result)
}
