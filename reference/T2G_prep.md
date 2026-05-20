# TERM2GENE Data Prep for iDEP Database

Prepares background genes for enrichment analysis functions in the
format of TERM2GENE data, using pathway information from various
databases. Requires ID for a species, and can filter for specific vector
of genes.

## Usage

``` r
T2G_prep(species_id = NULL, category = "GOBP", genes = NULL)
```

## Arguments

- species_id:

  Numeric. The ID of a desired species from database, found using
  `srch_species()`

- category:

  Character. A vector or character constant of pathway
  categories/databases (e.g. KEGG, GOBP, GOCC, etc.). It is not
  recommended to use all categories, as some species have many, leading
  to performance issues

- genes:

  Character. A character vector of genes to add to query

## Value

A data frame containing TERM2GENE Data (pathways to genes)

## Examples

``` r
if (FALSE) { # interactive() && curl::has_internet()
# CAUTION: The human database is very large, running these examples require
# the download of the human database.

# Prepare background genes mapping for Hypoxia dataset
# Useful for pathway enrichment analysis of our data
bg_genes <- T2G_prep(
  species_id = 96,
  category = "KEGG",
  genes = rownames(hypoxia_deseq)
)
head(bg_genes)
}
```
