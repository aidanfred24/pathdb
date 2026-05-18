#' Search for Species by Name
#'
#' Searches the organism database for species matching a query string.
#'
#' @param query Character. The species name, partial name, or ID to search for.
#' @param name_type Character. The type of name to search against. Options:
#'   - `"all"`: Default. Searches both primary and academic names.
#'   - `"academic"`: Scientific name. (note: not available for all species)
#'   - `"primary"`: Primary name in database (common name or academic).
#'   - `"id"`: Exact species ID match.
#'
#' @returns A data frame containing information for all matching species.
#'   Throws an error if no species are found.
#' @md
#' @export
#'
search_species <- function(query,
                           name_type = "all"){

    types <- setNames(c("name2", "academicName"),
                      c("primary", "academic"))

    if (!name_type %in% c(names(types), "all", "id")){
        stop("Invalid name type entered, see documentation")
    }

    org <- suppressMessages(get_table())

    if (name_type == "id") {
        results <- dplyr::filter(org, id == query)
    } else if (name_type == "all") {
        result_ind <- sapply(org[, unname(types)], function(x){
            sapply(x, function(y){
                grepl(toupper(query), toupper(y))
                })
            })

        result_ind <- unname(result_ind[,1] | result_ind[,2])
        results <- org[result_ind, ]
    } else {
        result_ind <- sapply(org[, unname(types[[name_type]])], function(x){
            grepl(toupper(query), toupper(x))
        })

        results <- org[result_ind, ]
    }

    if (nrow(results) == 0) {
        results <- NULL
        message("No Species Found")
    }

    return(results)
}
