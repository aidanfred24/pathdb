# Query Bioinformatics Database

Retrieves database (.db file) from the SDSU bioinformatics database,
creates a connection via SQLite

## Usage

``` r
connect_database(species_id = NULL)
```

## Arguments

- species_id:

  ID of species selected (Loads organism info data if NULL)

## Value

SQLite connection to the downloaded file

## Examples

``` r
if (FALSE) { # interactive() && curl::has_internet()
# Connect to organism information database
conn <- connect_database()

# Query information using connection
x <- DBI::dbGetQuery(
  conn = conn,
  statement = "select * from orgInfo;"
  )
head(x)

# Disconnect from database file
DBI::dbDisconnect(conn = conn)

# Connect to species information database (e.g. Indian Cobra)
conn <- connect_database(species_id = 99)

# Query information using connection
x <- DBI::dbGetQuery(
  conn = conn,
  statement = "select * from geneInfo;"
  )
head(x)

# Disconnect from database file
DBI::dbDisconnect(conn = conn)

}
```
