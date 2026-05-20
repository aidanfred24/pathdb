#' TERM2GENE Data Prep for iDEP Database
#'
#' Prepares background genes for enrichment analysis functions in the
#' format of TERM2GENE data, using pathway information from various databases.
#' Requires ID for a species, and can filter for specific vector of genes.
#'
#' @param species_id Numeric. The ID of a desired species from database, found
#' using `srch_species()`
#' @param category Character. A vector or character constant of pathway
#' categories/databases (e.g. KEGG, GOBP, GOCC, etc.). It is not recommended to
#' use all categories, as some species have many, leading to performance issues
#' @param genes Character. A character vector of genes to add to query
#'
#' @returns A data frame containing TERM2GENE Data (pathways to genes)
#'
#' @md
#' @export
#'
#' @examplesIf interactive() && curl::has_internet()
#' # CAUTION: The human database is very large, running these examples require
#' # the download of the human database.
#'
#' # Prepare background genes mapping for Hypoxia dataset
#' # Useful for pathway enrichment analysis of our data
#' bg_genes <- T2G_prep(
#'   species_id = 96,
#'   category = "KEGG",
#'   genes = rownames(hypoxia_deseq)
#' )
#' head(bg_genes)
#'
T2G_prep <- function(species_id = NULL,
                     category = "GOBP",
                     genes = NULL) {

    # Query pathways
    path_map <- path_filter(species_id = species_id,
                            genes = genes,
                            category = category)

    if (nrow(path_map) == 0) {
        warning("No pathways found for the given criteria")
        return(NULL)
    }

    conn <- connect_database(species_id = species_id)
    on.exit(DBI::dbDisconnect(conn))
    # Retrieve Pathway Info
    # Query unique pathway information
    pathway_ids <- unique(path_map$pathwayID)
    pathways_sql <- paste0("select * from pathwayInfo where id IN (",
                           paste0("'", pathway_ids, "'", collapse = ","),
                           ");")

    pathways <- DBI::dbGetQuery(conn, statement = pathways_sql)

    # Ensure same data type between tables
    path_map$pathwayID <- as.character(path_map$pathwayID)
    pathways$id <- as.character(pathways$id)

    DB <- dplyr::left_join(x = path_map,
                           y = pathways,
                           by = c("pathwayID" = "id"))

    if ("description" %in% names(DB) && "gene" %in% names(DB)) {
        return(DB[, c("description", "gene")])
    } else {
        warning("Pathway or gene columns not found in final data")
        return(NULL)
    }
}

