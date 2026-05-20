# Pathway Enrichment Analysis

## Introduction

Pathway enrichment analysis is a vital step in understanding the
biological relevance of differential expression results. By mapping
significant genes to known functional categories, researchers can gain
insights into the cellular processes and pathways affected by their
experimental conditions.

In this vignette, we will explore how to perform pathway enrichment
analysis using the `pathdb` package in conjunction with the popular
`clusterProfiler` package. We will utilize a sample dataset,
`hypoxia_deseq`, which contains differential expression results
comparing treatment under hypoxic conditions.

First, let’s load the required packages and the example dataset.

``` r

library(pathdb)
library(clusterProfiler)
library(dplyr)

# Preview the first few rows
head(hypoxia_deseq)
#>                  baseMean log2FoldChange      lfcSE      stat       pvalue
#> ENSG00000115461 217266.41      1.2667573 0.03538649 35.797765 2.147664e-59
#> ENSG00000108821 410517.90      0.2956573 0.04207132  7.027526 1.000000e+00
#> ENSG00000115414 412185.25     -0.5504696 0.08780420 -6.269285 9.479136e-01
#> ENSG00000164692 242139.02      0.1798710 0.04243381  4.238860 1.000000e+00
#> ENSG00000198804 179101.72      0.2049904 0.03395349  6.037389 1.000000e+00
#> ENSG00000168542  66677.09      1.4032737 0.03982160 35.239011 1.969715e-71
#>                         padj
#> ENSG00000115461 1.831612e-57
#> ENSG00000108821 1.000000e+00
#> ENSG00000115414 1.000000e+00
#> ENSG00000164692 1.000000e+00
#> ENSG00000198804 1.000000e+00
#> ENSG00000168542 2.451674e-69
```

## Identifying Differentially Expressed Genes (DEGs)

Before performing pathway enrichment, we need to classify our genes
based on their expression changes. We typically label genes as “UP”
regulated, “DOWN” regulated, or “NO” significant change based on their
fold change (`log2FoldChange`) and adjusted p-value (`padj`).

We apply a strict threshold to identify significant genes, such as an
adjusted p-value of less than 0.05.

``` r

# Define up- and down- regulation based on LFC and padj
df <- hypoxia_deseq |>
  as.data.frame() |>
  mutate(diffexp = case_when(
    log2FoldChange > 0 & padj < 0.05 ~ "UP",
    log2FoldChange < 0 & padj < 0.05 ~ "DOWN",
    TRUE ~ "NO" # using TRUE as catch-all for padj >= 0.1 or NA
  ))

# Filter out non-significant or missing adjusted p-value genes
df <- df[df$diffexp != "NO" & !is.na(df$diffexp), ]
```

Next, to ensure our gene IDs match the standard format expected by the
`pathdb` database, we can use the
[`convert_id()`](https://aidanfred24.github.io/pathdb/reference/convert_id.md)
function. Here our species of interest is human (Species ID: 96).

``` r

# Convert ids to Ensembl format to ensure compatibility
df <- convert_id(
  genes = rownames(df),
  data = df,
  species_id = 96
)
```

To facilitate enrichment analysis on both up- and down-regulated genes
separately, we split our data frame into a list.

``` r

# Split into up or down groups in a list
deg_results_list <- split(df, df$diffexp)
```

## Preparing the TERM2GENE Mapping

The `clusterProfiler` function `enricher` requires background annotation
data that maps pathway categories (TERMs) to gene IDs (GENEs). With the
`pathdb` package, fetching this information is streamlined using the
[`T2G_prep()`](https://aidanfred24.github.io/pathdb/reference/T2G_prep.md)
function.

We will extract the KEGG pathways mapping for all the genes in our
original `hypoxia_deseq` dataset, which acts as our background universe.
This feature of `pathdb` is especially versatile, as one can use a
vector of pathway database names, e.g. `c("KEGG", "GOBP", "GOCC")`. In
this way, we can check databases in one function call, rather than
pulling from KEGG, GO, and other databases separately.

``` r

bg_genes <- T2G_prep(
  species_id = 96,
  category = c("KEGG"),
  genes = rownames(hypoxia_deseq)
)
```

## Over-Representation Analysis (ORA)

With our gene lists and background annotation ready, we can perform an
Over-Representation Analysis (ORA). ORA determines whether known
pathways (biological functions or processes) are over-represented
(enriched) in an experimentally-derived gene list, such as our lists of
up- and down-regulated genes.

We apply the
[`enricher()`](https://rdrr.io/pkg/clusterProfiler/man/enricher.html)
function to both the “UP” and “DOWN” gene lists. We also set some
cutoffs to ensure our results are robust.

``` r

padj_cutoff <- 0.1
genecount_cutoff <- 5

# Apply enricher across Up/Down lists
res <- lapply(names(deg_results_list), function(direction) {
  enricher(
    gene = rownames(deg_results_list[[direction]]),
    pvalueCutoff = 0.05,
    TERM2GENE = bg_genes
  )
})

# Name the lists according to regulation
names(res) <- names(deg_results_list)
```

After performing enrichment, we can format and filter our results. It’s
often helpful to combine the “UP” and “DOWN” results into a single data
frame and transform the p-values for easier visualization.

``` r

# Bind results by row
res_df <- lapply(names(res), function(x) {
  res_chunk <- res[[x]]@result
  res_chunk$diffexp <- x # Keep track of the regulation direction
  return(res_chunk)
})
res_df <- do.call(rbind, res_df)

# Filter rows that meet our significance and count standards
target_pws <- res_df$p.adjust < padj_cutoff & res_df$Count > genecount_cutoff

# Filter and select top terms
res_sig <- res_df[target_pws, ] |>
  arrange(p.adjust) |>
  group_by(diffexp) |>
  slice_head(n = 20) |> # get up to 20 top pathways per direction
  ungroup()

# View enriched pathways for UP-regulated genes
res_up <- res_sig |> filter(diffexp == "UP")
head(res_up[, c("GeneRatio", "FoldEnrichment", "p.adjust")])
#> # A tibble: 6 × 3
#>   GeneRatio FoldEnrichment      p.adjust
#>   <chr>              <dbl>         <dbl>
#> 1 34/362              3.74 0.00000000203
#> 2 16/362              4.53 0.0000265    
#> 3 54/362              1.98 0.0000555    
#> 4 37/362              2.14 0.000479     
#> 5 11/362              4.38 0.00139      
#> 6 18/362              2.82 0.00237
# View enriched pathways for DOWN-regulated genes
res_down <- res_sig |> filter(diffexp == "DOWN")
head(res_up[, c("GeneRatio", "FoldEnrichment", "p.adjust")])
#> # A tibble: 6 × 3
#>   GeneRatio FoldEnrichment      p.adjust
#>   <chr>              <dbl>         <dbl>
#> 1 34/362              3.74 0.00000000203
#> 2 16/362              4.53 0.0000265    
#> 3 54/362              1.98 0.0000555    
#> 4 37/362              2.14 0.000479     
#> 5 11/362              4.38 0.00139      
#> 6 18/362              2.82 0.00237
```

## Gene Set Enrichment Analysis (GSEA)

Unlike ORA, which primarily relies on an artificial threshold to define
a “significant” gene list, Gene Set Enrichment Analysis (GSEA) uses all
the genes from your experiment. It determines whether members of a
pathway tend to occur toward the top (or bottom) of a ranked gene list.

To perform GSEA, we must rank all valid genes. One typical approach is
to calculate a metric based on the fold change and the significance
level. However, a simpler metric is often the `log2FoldChange` itself.

``` r

# Create a ranked geneList
geneList <- setNames(
  object = hypoxia_deseq$log2FoldChange,
  nm = rownames(hypoxia_deseq)
)

# Order the list from highest to lowest
geneList <- sort(geneList, decreasing = TRUE)
```

With the ranked `geneList`, we can run the
[`GSEA()`](https://rdrr.io/pkg/clusterProfiler/man/GSEA.html) function
from clusterProfiler. We will utilize the same background mapping
(`bg_genes`) downloaded earlier.

``` r

# Execute GSEA
gsea <- GSEA(
  geneList = geneList,
  TERM2GENE = bg_genes,
  pvalueCutoff = 0.05,
  maxGSSize = 2000
)

# Extract and filter top results
gsea_res <- gsea@result |>
  arrange(p.adjust) |>
  slice(1:20)

head(gsea_res[, c("setSize", "enrichmentScore", "NES", "p.adjust")])
#>                                                      setSize enrichmentScore
#> Path:hsa04110 Cell cycle                                 145      -0.6367113
#> Path:hsa04060 Cytokine-cytokine receptor interaction     134       0.5991773
#> Path:hsa04657 IL-17 signaling pathway                     67       0.6490940
#> Path:hsa04640 Hematopoietic cell lineage                  37       0.7350454
#> Path:hsa05323 Rheumatoid arthritis                        52       0.6672848
#> Path:hsa03030 DNA replication                             33      -0.7249150
#>                                                            NES     p.adjust
#> Path:hsa04110 Cell cycle                             -2.489013 1.665000e-08
#> Path:hsa04060 Cytokine-cytokine receptor interaction  2.312135 1.665000e-08
#> Path:hsa04657 IL-17 signaling pathway                 2.244758 8.502741e-06
#> Path:hsa04640 Hematopoietic cell lineage              2.307296 3.891374e-05
#> Path:hsa05323 Rheumatoid arthritis                    2.209989 5.143430e-05
#> Path:hsa03030 DNA replication                        -2.170165 1.080804e-04
```

By leveraging both ORA and GSEA, we can obtain complementary
perspectives on the functional changes induced by our experimental
conditions. The `pathdb` functions help seamlessly bridge basic
count/results data with advanced pathway analysis libraries.
