#' Filter Pathway Information By Category
#'
#' Retrieves pathway mapping information for a specific species, filtered by
#' one or more pathway categories (e.g., "GOBP", "KEGG"). Optionally, the results
#' can be further restricted to a specific list of genes.
#'
#' @param species_id Numeric. The ID of the species to search for.
#' @param genes Character vector (optional). A vector of gene IDs to filter the pathways.
#'   If `NULL` (default), pathways for all genes in the category are returned.
#' @param category Character or character vector. The pathway category or categories
#'   to filter by (e.g., `"GOBP"`, `"KEGG"`, `"GOCC"`). Default is `"GOBP"`.
#'
#' @returns A data frame containing the pathway mapping information (such as
#'   gene, pathway ID, and description) for the specified categories and genes.
#' @export
#'
#' @examplesIf interactive() && curl::has_internet()
#' # Get all GO Biological Process pathways for Human (ID 96)
#' gobp_paths <- path_filter(species_id = 96, category = "GOBP")
#'
#' # Get KEGG pathways for specific genes in a dataset
#' data(hypoxia_reads)
#' kegg_paths <- path_filter(
#'     species_id = 96,
#'     genes = rownames(hypoxia_reads)[1:100],
#'     category = "KEGG"
#' )
path_filter <- function(species_id,
                        genes = NULL,
                        category = "GOBP") {
    # Check for species
    if (is.null(species_id)) {
        stop("species_id is required")
    }

    # Connect to database
    conn <- connect_database(species_id = species_id)
    on.exit(DBI::dbDisconnect(conn))

    # Convert genes if provided
    if (!is.null(genes)) {
        # Convert to ensembl IDs
        gene_map <- convert_id(genes = genes, species_id = species_id)

        if (is.null(gene_map) || nrow(gene_map) == 0) {
            stop("Could not map any genes to Ensembl IDs.")
        }

        # Build query string for genes
        ens_ids <- unique(gene_map$ens)
        genes_sql <- paste0("'", ens_ids, "'", collapse = ",")
    }

    # Construct Path Map Query

    # Build query string for categories
    category_sql <- paste0("'", category, "'", collapse = ",")
    query <- paste0(
        "select * from pathway where category IN (",
        category_sql,
        ")"
    )

    # Append gene query
    if (!is.null(genes)) {
        query <- paste0(
            query,
            " AND gene IN (",
            genes_sql,
            ")"
        )
    }
    query <- paste0(query, ";")

    # Run query
    path_map <- DBI::dbGetQuery(conn, statement = query)

    return(path_map)
}
