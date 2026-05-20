# Search for Species by Name

Searches the organism database for species matching a query string.

## Usage

``` r
search_species(query, name_type = "all")
```

## Arguments

- query:

  Character. The species name, partial name, or ID to search for.

- name_type:

  Character. The type of name to search against. Options:

  - `"all"`: Default. Searches both primary and academic names.

  - `"academic"`: Scientific name. (note: not available for all species)

  - `"primary"`: Primary name in database (common name or academic).

  - `"id"`: Exact species ID match.

## Value

A data frame containing information for all matching species. Throws an
error if no species are found.

## Examples

``` r
if (FALSE) { # interactive() && curl::has_internet()
# Search all names for "Human"
search_species(query = "Human", name_type = "all")

# Search primary names for "Human"
search_species(query = "Human", name_type = "primary")

# Search academic names for "Homo sapiens"
search_species(query = "Homo sapiens", name_type = "academic")

# Search by species ID
search_species(query = 96, name_type = "id")
}
```
