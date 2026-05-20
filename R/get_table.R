#' Get Table from Selected Database
#'
#' Retrieves a specific table from the database for a selected species.
#'
#' @param species_id Numeric. The selected species ID.
#'   If `NULL`, the function defaults to loading general organism info.
#' @param table Character. The name of the table to retrieve (e.g., "geneInfo", "pathway").
#'   If `NULL`, defaults to "geneInfo" (if `species_id` is provided) or "orgInfo"
#'   (if `species_id` is `NULL`).
#'
#' @returns A data frame containing the data from the selected table.
#'
#' @seealso \code{\link{list_tables}} to see available tables for a species.
#' @md
#' @export
#'
#' @examplesIf interactive() && curl::has_internet()
#' # Retrieve geneInfo table for Indian Cobra Species
#' cobra_genes <- get_table(species_id = 99,
#'                          table = "geneInfo")
#'
#' # View table
#' head(cobra_genes)
#'
get_table <- function(species_id = NULL,
                      table = NULL){
    conn <- connect_database(species_id)
    on.exit(DBI::dbDisconnect(conn = conn))

    if(is.null(table) && !is.null(species_id)) {
        table <- "geneInfo"
        message("No table provided, using geneInfo by default")
    } else if (is.null(table) && is.null(species_id)) {
        table <- "orgInfo"
        message("No table or species provided, using orgInfo by default")
    } else if (!is.character(table)){
        stop("Table selection must be character type")
    }

    # Retrieve table from database file
    x <- DBI::dbGetQuery(
        conn = conn,
        statement = paste0("select * from ", table, ";")
    )

    return(x)
}
