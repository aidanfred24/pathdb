#' List Table Options
#'
#' Lists all available tables within the database for a specific species.
#'
#' @param species_id Numeric. The selected species ID.
#'   If `NULL`, loads the general organism info database.
#'
#' @returns A character vector of table names available in the database connection.
#' @md
#' @export
#'
#' @examplesIf interactive() && curl::has_internet()
#' # List all tables available for species 99 (Indian Cobra)
#' list_tables(species_id = 99)
#'
list_tables <- function(species_id = NULL) {
    conn <- connect_database(species_id)
    on.exit(DBI::dbDisconnect(conn))

    x <- DBI::dbListTables(conn)

    return(x)
}
