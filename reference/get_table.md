# Get Table from Selected Database

Retrieves a specific table from the database for a selected species.

## Usage

``` r
get_table(species_id = NULL, table = NULL)
```

## Arguments

- species_id:

  Numeric. The selected species ID. If `NULL`, the function defaults to
  loading general organism info.

- table:

  Character. The name of the table to retrieve (e.g., "geneInfo",
  "pathway"). If `NULL`, defaults to "geneInfo" (if `species_id` is
  provided) or "orgInfo" (if `species_id` is `NULL`).

## Value

A data frame containing the data from the selected table.

## See also

[`list_tables`](https://aidanfred24.github.io/pathdb/reference/list_tables.md)
to see available tables for a species.

## Examples

``` r
if (FALSE) { # interactive() && curl::has_internet()
# Retrieve geneInfo table for Indian Cobra Species
cobra_genes <- get_table(species_id = 99,
                         table = "geneInfo")

# View table
head(cobra_genes)
}
```
