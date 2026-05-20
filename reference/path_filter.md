# Filter Pathway Information By Category

Retrieves pathway mapping information for a specific species, filtered
by one or more pathway categories (e.g., "GOBP", "KEGG"). Optionally,
the results can be further restricted to a specific list of genes.

## Usage

``` r
path_filter(species_id, genes = NULL, category = "GOBP")
```

## Arguments

- species_id:

  Numeric. The ID of the species to search for.

- genes:

  Character vector (optional). A vector of gene IDs to filter the
  pathways. If `NULL` (default), pathways for all genes in the category
  are returned.

- category:

  Character or character vector. The pathway category or categories to
  filter by (e.g., `"GOBP"`, `"KEGG"`, `"GOCC"`). Default is `"GOBP"`.

## Value

A data frame containing the pathway mapping information (such as gene,
pathway ID, and description) for the specified categories and genes.

## Examples

``` r
if (FALSE) { # interactive() && curl::has_internet()
# Get all GO Biological Process pathways for Human (ID 96)
gobp_paths <- path_filter(species_id = 96, category = "GOBP")

# Get KEGG pathways for specific genes in a dataset
data(hypoxia_reads)
kegg_paths <- path_filter(
    species_id = 96,
    genes = rownames(hypoxia_reads)[1:100],
    category = "KEGG"
)
}
```
