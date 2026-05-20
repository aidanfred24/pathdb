# Process Gene Expression Data

Performs pre-processing, missing value imputation, filtering, and
transformation on gene expression count data.

## Usage

``` r
process_data(
  data,
  missing_value = "geneMedian",
  min_cpm = 0.5,
  n_min_samples = 1,
  rescale = FALSE
)
```

## Arguments

- data:

  A numeric matrix or data frame (\> 1 columns) of gene expression
  counts.

- missing_value:

  Character. Method to handle missing values. Options:

  - `"geneMedian"`: Impute using the median expression of the gene
    across samples.

  - `"treatAsZero"`: Replace NAs with 0.

  - `"groupMedian"`: Impute using the median of the sample group
    (detected from colnames).

- min_cpm:

  Numeric. Minimum counts per million threshold for filtering genes.

- n_min_samples:

  Numeric. Minimum number of samples that must meet the `min_cpm`
  threshold for a gene to be retained.

- rescale:

  Logical. TRUE allows for rescaling if values are exceedingly large.

## Value

The processed and transformed data matrix.

## Examples

``` r
# Check example data
summary(pathdb::hypoxia_reads)
#>  MRS1220_hypoxia_rep1 MRS1220_hypoxia_rep2 vehicle_hypoxia_rep1
#>  Min.   :     0.0     Min.   :     0.0     Min.   :     0      
#>  1st Qu.:     0.0     1st Qu.:     0.0     1st Qu.:     0      
#>  Median :     0.0     Median :     1.0     Median :     1      
#>  Mean   :   554.5     Mean   :   554.9     Mean   :   540      
#>  3rd Qu.:   128.0     3rd Qu.:   131.0     3rd Qu.:   124      
#>  Max.   :295557.0     Max.   :301342.0     Max.   :328799      
#>  vehicle_hypoxia_rep2
#>  Min.   :     0      
#>  1st Qu.:     0      
#>  Median :     0      
#>  Mean   :   637      
#>  3rd Qu.:   128      
#>  Max.   :379017      
nrow(pathdb::hypoxia_reads)
#> [1] 35238

# YOU decide how your data is transformed.
# Here, we want to:
# Replace missing values with median
# Set minimum counts-per-million of 0.4
# Meet CPM threshold in 2 samples
# Keep raw counts

hypox_filtered <- process_data(data = pathdb::hypoxia_reads,
                               missing_value = "geneMedian",
                               min_cpm = 0.4,
                               n_min_samples = 2)

# Check filtered data
summary(hypox_filtered)
#>  MRS1220_hypoxia_rep1 MRS1220_hypoxia_rep2 vehicle_hypoxia_rep1
#>  Min.   :     0       Min.   :     0.00    Min.   :     0      
#>  1st Qu.:    70       1st Qu.:    72.25    1st Qu.:    67      
#>  Median :   284       Median :   283.00    Median :   269      
#>  Mean   :  1451       Mean   :  1452.09    Mean   :  1413      
#>  3rd Qu.:   937       3rd Qu.:   920.00    3rd Qu.:   886      
#>  Max.   :295557       Max.   :301342.00    Max.   :328799      
#>  vehicle_hypoxia_rep2
#>  Min.   :     0      
#>  1st Qu.:    70      
#>  Median :   289      
#>  Mean   :  1667      
#>  3rd Qu.:  1012      
#>  Max.   :379017      
nrow(hypox_filtered)
#> [1] 13458
```
