# Retrieve Pathway Categories

Retrieves pathway category options (e.g. KEGG, GOBP, etc.) for a given
species. May take longer for well-documented species (i.e. Human)

## Usage

``` r
path_categories(species_id = NULL)
```

## Arguments

- species_id:

  Numeric. The ID of a desired species from database, found using
  `srch_species()`

## Value

Data frame of pathway categories for given species

## Examples

``` r
if (FALSE) { # interactive() && curl::has_internet()
# Get pathway categories for species 99 (Indian Cobra)
categories <- path_categories(species_id = 99)
head(categories)
}
```
