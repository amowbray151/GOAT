<p align = "center"><img src="www/GOATicon.svg"></p>

 

# 

### Gene Ontology Analysis Tool, made with Shiny 

Welcome to GOAT! This ShinyApp uses the clusterProfiler package for R to run Over-Representation Analysis (ORA) GO enrichment. The enrichplot package is used for plotting functions. Supported organisms include:

- Homo sapiens

- Mus musculus

- Rattus norvegicus

- Saccharomyces cerevisiae

- Drosophila melanogaster

<p align = "center">
<img width = "50%"; src="images/dplotex.png">
<img width = "80%"; src="images/tplotex.png">
</p>
 

### Why should I use this tool over any other?

This tool runs clusterProfiler, making it highly customizable. It is also easy to make publication-quality plots.

 

Other web-based apps do exist for clusterProfiler, such as NASQAR2 and are equally as customizable, so within clusterProfiler interfaces, it is ultimately up to you on which you choose.

 

I also recommend running your enrichment on other softwares. There is a lot of variance between softwares due to annotation databases and mapping algorithms, so the results in one are unlikely to match another. Some examples of other softwares to try are:

 - GOShiny

- PANTHER

- g:Profiler



## Instructions

### Requirements

- R 4.6 or later (RStudio optional)

- An internet connection for the first install, to download packages

 

### Setup

1. Download or clone the repository:

```bash

git clone https://github.com/amowbray151/GOAT.git

```

2. Open the `GOAT` folder as a project in RStudio (or start R with the `GOAT` folder as your working directory). `renv` activates automatically.

You can do this by typing into the R console:

```r

setwd("Path/To/Extracted/GOAT-main")

```

For example:

```r

setwd("C:/Users/john/Downloads/GOAT-main")

```

4. Install the required packages. In the R console, run:

```r

install.packages("renv")

renv::restore()

```

This installs the exact package versions recorded in `renv.lock`, including clusterProfiler, enrichplot, and the annotation databases for the supported organisms. The first install can take several minutes.


### Running the app

In the R console, run:

```r

shiny::runApp()

```

