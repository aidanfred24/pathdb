#' Get Species Pathways
#'
#' Retrieves pathway information for a specific species and optionally filters
#' for specific genes.
#'
#' @param species_id Numeric. The ID of the desired species
#'   (e.g., from `srch_species`).
#' @param genes A vector or column of a data frame containing gene IDs of interest.
#'   If `NULL` (default), returns all pathways for the species.
#' @param category Character. A vector or character constant of pathway
#' categories/databases (e.g. KEGG, GOBP, GOCC, etc.). It is not recommended to
#' use all categories, as some species have many, leading to performance issues
#'
#' @returns A data frame containing pathway information. If `genes` are provided,
#'   the data frame is filtered to include only pathways containing those genes
#'   and joined with gene mapping data.
#'
#' @details
#' The function first retrieves the `pathway` and `pathwayInfo` tables for the
#' specified species. If a list of genes is provided, it converts the IDs to
#' Ensembl IDs, matches them against the pathway map, and joins the results
#' with pathway metadata.
#' @md
#' @export
#'
#' @examplesIf interactive() && curl::has_internet()
#' # CAUTION: The human database is very large, running these examples require
#' # the download of the human database.
#'
#' # Get GOBP pathways for our genes of interest
#' path_info <- get_pathways(
#'   species_id = 96,
#'   genes = rownames(hypoxia_reads),
#'   category = "GOBP"
#' )
#' head(path_info)
#'
get_pathways <- function(species_id,
                         genes = NULL,
                         category = "GOBP") {

    path_map <- suppressMessages(
        path_filter(species_id = species_id,
                    genes = genes,
                    category = category)
    )

    pathways <- get_table(species_id = species_id,
                          table = "pathwayInfo")

    if (!is.null(genes)) {
        genes <- convert_id(genes = genes,
                            species_id = species_id)

        ix <- path_map$gene %in% genes[, 2]

        path_map <- path_map[ix,]
        path_map$pathwayID <- as.character(path_map$pathwayID)

        by <- dplyr::join_by(pathwayID == id)

        pathways <- dplyr::left_join(x = path_map,
                                     y = pathways,
                                     by)

        # remove the first column by name or index without copying the whole
        # object for the check
        pathways <- pathways[, -1]
        pathways <- unique(pathways)
    }

    if (nrow(pathways) == 0) {
        stop(
            paste("No pathways found. Check that the genes submitted are a",
                  "vector/column of known gene IDS.")
        )
    }

    return(pathways)
}
