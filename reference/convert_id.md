# Convert Gene IDs to Ensembl

Queries the database to map user-provided gene identifiers to
Ensembl/Entrez IDs. To ensure best matching and conversion, please
verify that all gene identifiers have no whitespace and are at least 2
characters long. Results are often more conservative of initial genes if
data is provided, as duplicate removal is done by variance of each gene
(highest variance is kept).

## Usage

``` r
convert_id(genes, data = NULL, species_id, id_type = "ens")
```

## Arguments

- genes:

  A vector or character string of gene identifiers to convert.

- data:

  Optional data frame or matrix. If provided, the function attempts to
  match `genes` to the row names or a column in `data` and merges the
  conversion results with the original data.

- species_id:

  Numeric. The ID of the species for the database connection.

- id_type:

  Character. The type of ID to convert to:

  - "ens" = Ensembl gene IDs (Default)

  - "entrez" = Entrez gene IDs

    - WARNING: Not all species or genes have Entrez gene IDs available

    - May take longer than Ensembl IDs

    - Will likely have duplicate Entrez IDs

## Value

A data frame.

- If `data` is `NULL`: Returns a mapping table with original IDs and IDs
  of selected type.

- If `data` is provided: Returns `data` merged with the IDs of selected
  type. Returns `NULL` if `species_id` is missing or no matches are
  found.

- Any whitespace found in original IDs will be removed.

## Examples

``` r
if (FALSE) { # interactive() && curl::has_internet()
# CAUTION: The human database is very large, running these examples require
# the download of the human database.

# View our experimental gene IDs
head(rownames(hypoxia_reads))

# Convert IDs to Ensembl format for further analysis
ens_conv <- convert_id(genes = rownames(hypoxia_reads),
                       species_id = 96)

# Yields a conversion table for our genes
head(ens_conv)

# Can also convert to Entrez IDs, if needed
entrez_conv <- convert_id(genes = rownames(hypoxia_reads),
                          species_id = 96,
                          id_type = "entrez")

# Yields a conversion table for our genes
head(entrez_conv)

# We want to automatically convert our IDs within our data
ens_hypoxia <- convert_id(genes = rownames(hypoxia_reads),
                          species_id = 96,
                          data = hypoxia_reads)

# Original data
head(hypoxia_reads)

# Converted data
head(ens_hypoxia)
}
```
