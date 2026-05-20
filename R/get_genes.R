#' Get Gene Information
#'
#' Retrieves gene information (e.g., Ensembl IDs, positions) for a specific
#' species, optionally filtered by a list of user-provided gene identifiers
#' after converting to Ensembl IDs.
#'
#' @param species_id Numeric. The ID of the desired species.
#' @param genes A vector or list of gene identifiers to filter by.
#'   If `NULL`, returns the full gene table.
#'
#' @returns A data frame containing gene information (from the `geneInfo` table).
#'   If `genes` are provided, the result is filtered to match the converted Ensembl IDs.
#' @md
#' @export
#'
#' @examplesIf interactive() && curl::has_internet()
#' # CAUTION: The human database is very large, running these examples require
#' # the download of the human database.
#'
#' # We have gene IDs that are not commonly recognized
#' head(rownames(hypoxia_reads))
#'
#' # Retrieve gene information for genes in our sample
#' # Converts to Ensembl IDs first
#' genes <- get_genes(species_id = 96,
#'                    genes = rownames(hypoxia_reads))
#'
#' head(genes)
#'
#' # Retrieve all genes for desired species
#' all_genes <- get_genes(species_id = 96)
#' head(all_genes)
#'
#' # This is the same as running get_table(96, "geneInfo")
#' all(get_genes(96) == get_table(96, "geneInfo"), na.rm = TRUE)
#'
get_genes <- function(species_id,
                      genes = NULL) {

    gene_table <- get_table(species_id = species_id,
                            table = "geneInfo")

    if (!is.null(genes)) {
        genes <- convert_id(genes = genes,
                            species_id = species_id)

        ix <- match(genes[, 2], gene_table$ensembl_gene_id)

        gene_table <- gene_table[ix, ]
    }

    return(gene_table)
}
