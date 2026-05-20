# Database Access and Preparation

``` r

library(pathdb)
```

## Introduction

This vignette provides a tutorial for accessing the South Dakota State
University (SDSU) bioinformatics/genomic database used in Integrated
Differential Expression and Pathway Analysis
([iDEP](https://bioinformatics.sdstate.edu/idep/)). We will also discuss
how to leverage this package to prepare data for further analysis.

In current research scenarios, it is common to work with RNA-Seq counts
data. The data shown below, `hypoxia_reads`, is an example of this kind
of data that we may come across naturally. This data contains gene count
readings for glioblastoma stem-like cells derived from a U87MG cell line
under hypoxia, seen in the column names. The species of interest is
Human (Homo sapiens).

``` r

head(hypoxia_reads)
#>         MRS1220_hypoxia_rep1 MRS1220_hypoxia_rep2 vehicle_hypoxia_rep1
#> A1BG                       9                   11                    4
#> A1CF                       6                    1                    4
#> A2M                        0                    0                    1
#> A2ML1                      1                    1                    0
#> A2MP1                      0                    2                    0
#> A3GALT2                    0                    0                    0
#>         vehicle_hypoxia_rep2
#> A1BG                       6
#> A1CF                       2
#> A2M                        0
#> A2ML1                      1
#> A2MP1                      0
#> A3GALT2                    1
```

## The `search_species()` function

When considering Differential Expression and Pathway Analysis as methods
for research, it may first be best for a researcher to convert the gene
IDs of their data to the standard Ensembl or STRINGdb format. The SDSU
database is great for this use case, but first we need to know: Does the
database contain our species?

To answer this and discover how we can identify our species in the
database, we use the
[`search_species()`](https://aidanfred24.github.io/pathdb/reference/search_species.md)
function.

``` r

srch_results <- search_species(
  query = "Human",
  name_type = "all"
)

srch_results
```

    #>              ensembl_dataset
    #> 1      hsapiens_gene_ensembl
    #> 570         phumanus_eg_gene
    #> 2514 STRING.121224.Pediculus
    #>                                                                name
    #> 1                                            Human genes GRCh38.p14
    #> 570  Pediculus humanus corporis Human body louse, USDA genes PhumU2
    #> 2514                                     Pediculus humanus corporis
    #>                                                 name2          idType idCode
    #> 1                                               Human ensembl_gene_id    ens
    #> 570  Pediculus humanus corporis Human body louse_USDA ensembl_gene_id    ens
    #> 2514                       Pediculus humanus STRINGdb ensembl_gene_id    ens
    #>           id totalGenes          group taxon_id      academicName
    #> 1         96      23258        ENSEMBL     9606      homo sapiens
    #> 570      566      10785 EnsemblMetazoa   121224 pediculus humanus
    #> 2514 -121224      10761    STRINGv12.0   121224                  
    #>                                                                       file KEGG
    #> 1                                          hsapiens_gene_ensembl__Human.db  hsa
    #> 570  phumanus_eg_gene__Pediculus_humanus_corporis_Human_body_louse_USDA.db  phu
    #> 2514                         STRING.121224.Pediculus__Pediculus_humanus.db  phu
    #>      T.Number top
    #> 1      T01001   1
    #> 570    T01223  NA
    #> 2514           NA

This search through the database yields the following species:

- Human
- Pediculus humanus corporis Human body louse_USDA
- Pediculus humanus STRINGdb

So we have found that our species of interest, Human, is contained in
the bioinformatics database and is labeled with the **species ID 96**.
While searching with `name_type = "all"` is most efficient, we can also
search by primary name, academic name, and ID number. However, only
Ensembl encoded species have an available entry in the `academicName`
column, and searching by ID number requires prior knowledge of the
database, so searching by “primary” name (`name2` column) or “all” is
optimal for the most results. It is also often that the primary name
includes the academic name, regardless. Below are examples of these
search methods.

#### Primary Example

``` r

search_species(
  query = "Human",
  name_type = "primary"
)
```

    #>         ensembl_dataset                   name name2          idType idCode id
    #> 1 hsapiens_gene_ensembl Human genes GRCh38.p14 Human ensembl_gene_id    ens 96
    #>   totalGenes   group taxon_id academicName                            file KEGG
    #> 1      23258 ENSEMBL     9606 homo sapiens hsapiens_gene_ensembl__Human.db  hsa
    #>   T.Number top
    #> 1   T01001   1

#### Academic Example

``` r

search_species(
  query = "Homo sapiens",
  name_type = "academic"
)
```

    #>      ensembl_dataset
    #> 570 phumanus_eg_gene
    #>                                                               name
    #> 570 Pediculus humanus corporis Human body louse, USDA genes PhumU2
    #>                                                name2          idType idCode  id
    #> 570 Pediculus humanus corporis Human body louse_USDA ensembl_gene_id    ens 566
    #>     totalGenes          group taxon_id      academicName
    #> 570      10785 EnsemblMetazoa   121224 pediculus humanus
    #>                                                                      file KEGG
    #> 570 phumanus_eg_gene__Pediculus_humanus_corporis_Human_body_louse_USDA.db  phu
    #>     T.Number top
    #> 570   T01223  NA

#### ID Example

``` r

search_species(
  query = 96,
  name_type = "id"
)
```

    #>         ensembl_dataset                   name name2          idType idCode id
    #> 1 hsapiens_gene_ensembl Human genes GRCh38.p14 Human ensembl_gene_id    ens 96
    #>   totalGenes   group taxon_id academicName                            file KEGG
    #> 1      23258 ENSEMBL     9606 homo sapiens hsapiens_gene_ensembl__Human.db  hsa
    #>   T.Number top
    #> 1   T01001   1

The most important piece of information to retain from the data returned
by
[`search_species()`](https://aidanfred24.github.io/pathdb/reference/search_species.md)
is the `id` column. This is how many functions in this package will know
which species to use for their operations.

## Exploring Species Data Tables

Now that we know our species ID is 96, we might want to discover what
specific data and metadata is available for this species within the
database. The
[`list_tables()`](https://aidanfred24.github.io/pathdb/reference/list_tables.md)
function allows us to see all the tables present for a given species.

``` r

table_names <- list_tables(species_id = 96)

table_names
```

    #> [1] "categories"  "geneInfo"    "idIndex"     "mapping"     "pathway"    
    #> [6] "pathwayInfo" "source"

Once we have identified a table of interest, we can retrieve its
contents using the
[`get_table()`](https://aidanfred24.github.io/pathdb/reference/get_table.md)
function. For instance, we can fetch the “geneInfo” table, which
contains important gene metadata like chromosomes, start positions, GC
content, Ensembl IDs, and more.

``` r

gene_info <- get_table(
  species_id = 96,
  table = "geneInfo"
)

head(gene_info[, 1:5])
```

    #>   ensembl_gene_id   band chromosome_name start_position percentage_gc_content
    #> 1 ENSG00000000003  q22.1               X      100627108                 40.40
    #> 2 ENSG00000000005  q22.1               X      100584936                 40.78
    #> 3 ENSG00000000419 q13.13              20       50934867                 40.20
    #> 4 ENSG00000000457  q24.2               1      169849631                 40.14
    #> 5 ENSG00000000460  q24.2               1      169662007                 39.22
    #> 6 ENSG00000000938  p35.3               1       27612064                 52.92

The functions
[`get_genes()`](https://aidanfred24.github.io/pathdb/reference/get_genes.md)
and
[`get_pathways()`](https://aidanfred24.github.io/pathdb/reference/get_pathways.md)
can also be used to obtain gene metadata and pathway information
relative to the list of genes being studied. Below we use the genes from
our `hypoxia_reads` data to do so. Note that these functions rely on
Ensembl ID conversions from
[`convert_id()`](https://aidanfred24.github.io/pathdb/reference/convert_id.md),
discussed later in this vignette.

``` r

gene_info <- get_genes(
  species_id = 96,
  genes = rownames(hypoxia_reads)
)

head(gene_info[, 1:5])
```

    #>       ensembl_gene_id   band chromosome_name start_position
    #> 5171  ENSG00000121410 q13.43              19       58345178
    #> 9118  ENSG00000148584 q11.23              10       50799409
    #> 13986 ENSG00000175899 p13.31              12        9067664
    #> 11891 ENSG00000166535 p13.31              12        8822621
    #> 44451 ENSG00000256069 p13.31              12        9229376
    #> 15730 ENSG00000184389  p35.1               1       33306766
    #>       percentage_gc_content
    #> 5171                  55.80
    #> 9118                  36.24
    #> 13986                 37.18
    #> 11891                 44.23
    #> 44451                 37.12
    #> 15730                 54.19

When retrieving pathway information, it is important to know which
pathway databases (e.g. KEGG, GOBP, GOCC, etc.) are available for the
species of interest. For this, we may use
[`path_categories()`](https://aidanfred24.github.io/pathdb/reference/path_categories.md).

``` r

categories <- path_categories(species_id = 96)

head(categories, n = 10)
```

    #>                                         category
    #> 1                                Celltype.MSigDB
    #> 2                Co-expression.ARCHS4.Cell-lines
    #> 3 Co-expression.Allen.Brain.Atlas.10x.scRNA.2021
    #> 4           Co-expression.Allen.Brain.Atlas.down
    #> 5             Co-expression.Allen.Brain.Atlas.up
    #> 6             Co-expression.GTEx.Tissues.V8.2023

``` r

nrow(categories)
```

    #> [1] 140

We see here that the human species has 140 different pathway databases.
To retrieve all pathways from all databases would be very inefficient.
We speed up this process by using the `category` argument in
[`get_pathways()`](https://aidanfred24.github.io/pathdb/reference/get_pathways.md)
to filter to specific pathway databases. This argument can be a
character vector or only a single string. This feature of `pathdb` is
especially versatile, as one can use a vector of pathway database names,
e.g. `c("KEGG", "GOBP", "GOCC")`. In this way, we can check databases in
one function call, rather than pulling from KEGG, GO, and other
databases separately.

Now we may obtain the specific set of pathways relative to the genes in
our hypoxia data.

``` r

path_info <- get_pathways(
  species_id = 96,
  genes = rownames(hypoxia_reads),
  category = c("GOBP")
)

head(path_info)
```

    #>     pathwayID category
    #> 1      367054     GOBP
    #> 28     367055     GOBP
    #> 41     367056     GOBP
    #> 43     367057     GOBP
    #> 164    367058     GOBP
    #> 170    367059     GOBP
    #>                                                                       name
    #> 1      GOBP_hsapiens_ens_gskb_GO:0000002_Mitochondrial_genome_maintenance 
    #> 28           GOBP_hsapiens_ens_gskb_GO:0000012_Single_strand_break_repair 
    #> 41            GOBP_hsapiens_ens_gskb_GO:0000017_Alpha-glucoside_transport 
    #> 43      GOBP_hsapiens_ens_gskb_GO:0000018_Regulation_of_dna_recombination 
    #> 164 GOBP_hsapiens_ens_gskb_GO:0000019_Regulation_of_mitotic_recombination 
    #> 170          GOBP_hsapiens_ens_gskb_GO:0000022_Mitotic_spindle_elongation 
    #>                                         description   n
    #> 1      GO:0000002 Mitochondrial genome maintenance   33
    #> 28           GO:0000012 Single strand break repair   16
    #> 41            GO:0000017 Alpha-glucoside transport    2
    #> 43      GO:0000018 Regulation of dna recombination  145
    #> 164 GO:0000019 Regulation of mitotic recombination    7
    #> 170          GO:0000022 Mitotic spindle elongation   12
    #>                                                     memo golevel
    #> 1   https://amigo.geneontology.org/amigo/term/GO:0000002       6
    #> 28  https://amigo.geneontology.org/amigo/term/GO:0000012       8
    #> 41  https://amigo.geneontology.org/amigo/term/GO:0000017       8
    #> 43  https://amigo.geneontology.org/amigo/term/GO:0000018       8
    #> 164 https://amigo.geneontology.org/amigo/term/GO:0000019       9
    #> 170 https://amigo.geneontology.org/amigo/term/GO:0000022       9

## Converting/Filtering Genes

Once we have identified the correct species ID for our data (in this
case, our ID is 96), we can use the
[`convert_id()`](https://aidanfred24.github.io/pathdb/reference/convert_id.md)
function to standardize our gene IDs. This step is crucial for matching
the gene names in SDSU’s database, allowing us to retrieve pathway
information for our genes and proceed to further analysis.

If we only provide a vector of gene names to
[`convert_id()`](https://aidanfred24.github.io/pathdb/reference/convert_id.md),
it will return a table mapping our original IDs to the standard Ensembl
format. If we also provide the raw data frame, it will return the data
frame with Ensemble gene names substituted, automatically filtering out
genes that cannot be mapped.

``` r

head(rownames(hypoxia_reads))

# Providing just a vector
conv_table <- convert_id(
  genes = rownames(hypoxia_reads),
  species_id = 96
)

head(conv_table)
```

    #>        id             ens
    #> 1    A1BG ENSG00000121410
    #> 2    A1CF ENSG00000148584
    #> 3     A2M ENSG00000175899
    #> 4   A2ML1 ENSG00000166535
    #> 5   A2MP1 ENSG00000256069
    #> 6 A3GALT2 ENSG00000184389

``` r

# Providing a vector AND data
hypoxia_conv <- convert_id(
  genes = rownames(hypoxia_reads),
  data = hypoxia_reads,
  species_id = 96
)

knitr::kable(head(hypoxia_conv))
```

|  | MRS1220_hypoxia_rep1 | MRS1220_hypoxia_rep2 | vehicle_hypoxia_rep1 | vehicle_hypoxia_rep2 |
|:---|---:|---:|---:|---:|
| ENSG00000121410 | 9 | 11 | 4 | 6 |
| ENSG00000148584 | 6 | 1 | 4 | 2 |
| ENSG00000175899 | 0 | 0 | 1 | 0 |
| ENSG00000166535 | 1 | 1 | 0 | 1 |
| ENSG00000256069 | 0 | 2 | 0 | 0 |
| ENSG00000184389 | 0 | 0 | 0 | 1 |

Please note that, if our genes cannot be mapped to Ensembl IDs, we can
lose large portions of our data. To best negate this, ensure that your
IDs are well documented, have Ensembl counterparts, and contain few
special characters.

## Processing Data

After standardizing our gene IDs, the next step prior to analysis is
typically to clean our count data. This involves handling any missing
values, filtering out genes with consistently low expression across
samples, and potentially applying transformations to our count data,
making it more suited for further exploratory or differential analysis.

The
[`process_data()`](https://aidanfred24.github.io/pathdb/reference/process_data.md)
function provides a compact way to complete these steps in our analysis.
It can impute missing values using methods like `"geneMedian"` or
`"treatAsZero"`, filter genes based on Counts Per Million (CPM), and
apply normalizations such as base-2 log, Variance Stabilizing
Transformation (VST), or Regularized Log (rlog). Note that if the given
data contains a column of gene IDs, that column will be stored as the
rownames of the processed data.

Here is an example of processing the converted Human data using the
default settings, which include imputing missing values with the overall
gene median, filtering for genes with at least 0.5 CPM in at least 1
sample, and returning the raw counts without transformation.

``` r

nrow(hypoxia_conv)
#> [1] 26009

processed_data <- process_data(
  data = hypoxia_conv,
  missing_value = "geneMedian",
  min_cpm = 0.5,
  n_min_samples = 1
)

nrow(processed_data)
#> [1] 12453

knitr::kable(head(processed_data[, 1:3]))
```

|  | MRS1220_hypoxia_rep1 | MRS1220_hypoxia_rep2 | vehicle_hypoxia_rep1 |
|:---|---:|---:|---:|
| ENSG00000167996 | 295557 | 301342 | 328799 |
| ENSG00000106366 | 155149 | 147287 | 165520 |
| ENSG00000156508 | 198071 | 228044 | 195730 |
| ENSG00000111640 | 163113 | 174065 | 158049 |
| ENSG00000228499 | 108461 | 121423 | 111786 |
| ENSG00000099194 | 119269 | 106216 | 133842 |

The above information covers all that is needed to properly access the
SDSU bioinformatics database and prepare your own data for further
analysis like differential expression and pathway enrichment. Any extra
filtering of data will need to be on the user’s end or recommended to
the developers as a new feature. Feel free to make suggestions!
