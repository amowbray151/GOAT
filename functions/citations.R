get_citations <- function() {
  
  cited_packages <- c("shiny", "shinycssloaders", "bslib",                                                # Shiny App
                      "GO.db", "clusterProfiler", "BiocParallel", "GOSemSim", "DOSE",                     # Enrichment
                      "enrichplot", "tidyverse",                                                          # Plots
                      "org.Hs.eg.db", "org.Mm.eg.db", "org.Rn.eg.db", "org.Sc.sgd.db", "org.Dm.eg.db")    # Organism Databases

  unlist(lapply(cited_packages, function(p) format(citation(p)[1], style = "text")))


}

citationsTab <- function() {
  app_version <- "1.0.0"
  cited <- get_citations()
  
  tags$body(
    tags$h4("Please cite:"),
    tags$ul(tags$b("clusterProfiler:"), paste(format(citation("clusterProfiler")[4], style = "text"))),
    tags$ul(tags$b("enrichplot:"), paste(format(citation("enrichplot")[1], style = "text"))),
    tags$h5("As well as the annotation database used:"),
    tags$ul(tags$b("Homo sapiens:"), paste(format(citation("org.Hs.eg.db")[1], style = "text"))),
    tags$ul(tags$b("Mus musculus:"), paste(format(citation("org.Mm.eg.db")[1], style = "text"))),
    tags$ul(tags$b("Rattus norvegicus:"), paste(format(citation("org.Rn.eg.db")[1], style = "text"))),
    tags$ul(tags$b("Saccharomyces cerevisiae:"), paste(format(citation("org.Sc.sgd.db")[1], style = "text"))),
    tags$ul(tags$b("Drosophila melanogaster:"), paste(format(citation("org.Dm.eg.db")[1], style = "text"))),
    
    tags$h4("Please acknowledge use of this app in your methods section:"),
    tags$ul(paste0("e.g. GO enrichment was run using clusterProfiler v", as.character(packageVersion("clusterProfiler")), ", via a custom Shiny interface (GOAT v", app_version, " https://github.com/amowbray151/GOAT)")),
    
    tags$h4("References:"),
    tags$ul(lapply(cited, tags$p))
)
}