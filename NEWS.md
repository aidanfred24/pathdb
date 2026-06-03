# pathdb (development version)

## Major Changes

 * Changed `convert_id` function to remove duplicates based on variance of RNA-seq data for each gene
  * This is an improvement from randomly removing genes
  * Removing duplicates as necessary, as unique IDs are required for Differential Expression and Pathway analysis

## Minor Changes

 * `convert_id` prints number of duplicate gene IDs detected and removed from the input data
 * `connect_database` now prints the path to the downloaded database file (in the package cache) and the size of the file


# pathdb 0.1.0

* Initial CRAN submission.
