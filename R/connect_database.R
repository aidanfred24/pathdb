#' Query Bioinformatics Database
#'
#' Retrieves database (.db file) from the SDSU bioinformatics database,
#'  creates a connection via SQLite
#'
#' @param species_id ID of species selected (Loads organism info data if NULL)
#'
#' @returns SQLite connection to the downloaded file
#' @export
#' @examplesIf interactive() && curl::has_internet()
#' # Connect to organism information database
#' conn <- connect_database()
#'
#' # Query information using connection
#' x <- DBI::dbGetQuery(
#'   conn = conn,
#'   statement = "select * from orgInfo;"
#'   )
#' head(x)
#'
#' # Disconnect from database file
#' DBI::dbDisconnect(conn = conn)
#'
#' # Connect to species information database (e.g. Indian Cobra)
#' conn <- connect_database(species_id = 99)
#'
#' # Query information using connection
#' x <- DBI::dbGetQuery(
#'   conn = conn,
#'   statement = "select * from geneInfo;"
#'   )
#' head(x)
#'
#' # Disconnect from database file
#' DBI::dbDisconnect(conn = conn)
#'
#'
connect_database <- function(species_id = NULL){

    # define where database is located
    db_ver <- "data113"
    db_url <- "https://bioinformatics.sdstate.edu/data/"

    # if environmental variable is not set, use relative path
    DATAPATH <- Sys.getenv("IDEP_DATABASE")[1]
    # if not defined in the environment, use user directory
    if (nchar(DATAPATH) == 0) {
        DATAPATH <- tools::R_user_dir("pathdb", which = "cache")
    }

    # create cache
    if (!dir.exists(DATAPATH)){
        dir.create(DATAPATH, recursive = TRUE)
    }

    # Organism info file
    org_info_file <- paste0(DATAPATH, "/orgInfo.db")
    db_file <- org_info_file

    # Download file from path
    if (!file.exists(org_info_file)) {

        # Create temporary directory for initial installation
        temp <- tempfile()
        dir.create(temp)

        file_name <- paste0(db_ver, ".tar.gz")
        options(timeout = 3000)
        # Attempt to download, warn if unable
        tryCatch(
            suppressWarnings(
                download.file(
                    url = paste0(db_url, db_ver, "/", file_name),
                    destfile = paste0(temp, "/", file_name),
                    mode = "wb",
                    quiet = FALSE
                )
            ),
            error = function(e){
                if (grepl("cannot open URL", e$message)){
                    stop("Cannot find database file locally",
                         " or open database URL for download.",
                         " Please verify internet connection and retry.")
                } else {
                    stop("Unknown error occured.",
                         " Please report error to development team")
                }
            }
        )
        # untar and unzip the files
        untar(paste0(temp, "/", file_name),
              files = paste0(db_ver, "/demo/orgInfo.db"),
              exdir = temp)
        # delete the tar file to save storage
        file.remove(paste0(temp, "/", file_name))

        # Move file to permanent cache
        file.copy(from = paste0(temp, "/", db_ver, "/demo/orgInfo.db"),
                  to = DATAPATH,
                  recursive = TRUE)

        # Remove temporary files
        unlink(temp, recursive = TRUE)
    }

    # Specific species selected
    if (!is.null(species_id)) {
        conn <- DBI::dbConnect(
            drv = RSQLite::dbDriver("SQLite"),
            dbname = org_info_file,
            flags = RSQLite::SQLITE_RO
        )
        # Find species in orgInfo database
        file <- tryCatch(
            DBI::dbGetQuery(
                conn,
                statement = paste0("select file from orgInfo where id = ",
                                   species_id, ";")
            ),
            error = function(e){"Species Not Found"}
        )
        DBI::dbDisconnect(conn)

        # Return error message if species not found
        if (is.null(nrow(file)) || nrow(file) == 0){
            stop("Species Not Found")
        }

        db_file <- paste0(DATAPATH, "/", file)

        if (!file.exists(db_file)) {
            file_name <- paste0(file, ".gz")
            options(timeout = 3000)
            # Attempt to download, warn if unable
            tryCatch(
                suppressWarnings(
                    download.file(
                        url = paste0(db_url, db_ver, "/db/", file_name),
                        destfile = paste0(db_file, ".gz"),
                        mode = "wb",
                        quiet = FALSE
                    )
                ),
                error = function(e){
                    if (grepl("cannot open URL", e$message)){
                        stop("Cannot find database file locally",
                             " or open database URL for download.",
                             " Please verify internet connection and retry.")
                    } else {
                        stop("Unknown error occured.",
                             " Please report error to development team")
                    }
                }
            )
            # Unzip species database file
            R.utils::gunzip(filename = paste0(DATAPATH, "/", file_name),
                            destname = db_file)
        }
    }

    return(DBI::dbConnect(
        drv = RSQLite::dbDriver("SQLite"),
        dbname = db_file,
        flags = RSQLite::SQLITE_RO
    ))
}
