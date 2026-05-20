# List Table Options

Lists all available tables within the database for a specific species.

## Usage

``` r
list_tables(species_id = NULL)
```

## Arguments

- species_id:

  Numeric. The selected species ID. If `NULL`, loads the general
  organism info database.

## Value

A character vector of table names available in the database connection.

## Examples

``` r
if (FALSE) { # interactive() && curl::has_internet()
# List all tables available for species 99 (Indian Cobra)
list_tables(species_id = 99)
}
```
