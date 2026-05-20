# Get Species Pathways

Retrieves pathway information for a specific species and optionally
filters for specific genes.

## Usage

``` r
get_pathways(species_id, genes = NULL, category = "GOBP")
```

## Arguments

- species_id:

  Numeric. The ID of the desired species (e.g., from `srch_species`).

- genes:

  A vector or column of a data frame containing gene IDs of interest. If
  `NULL` (default), returns all pathways for the species.

- category:

  Character. A vector or character constant of pathway
  categories/databases (e.g. KEGG, GOBP, GOCC, etc.). It is not
  recommended to use all categories, as some species have many, leading
  to performance issues

## Value

A data frame containing pathway information. If `genes` are provided,
the data frame is filtered to include only pathways containing those
genes and joined with gene mapping data.

## Details

The function first retrieves the `pathway` and `pathwayInfo` tables for
the specified species. If a list of genes is provided, it converts the
IDs to Ensembl IDs, matches them against the pathway map, and joins the
results with pathway metadata.

## Examples

``` r
if (FALSE) { # interactive() && curl::has_internet()
# CAUTION: The human database is very large, running these examples require
# the download of the human database.

# Get GOBP pathways for our genes of interest
path_info <- get_pathways(
  species_id = 96,
  genes = rownames(hypoxia_reads),
  category = "GOBP"
)
head(path_info)
}
```
