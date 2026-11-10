footerUI <- function() {
  
  app_version <- "1.0.0"
  
  footer = tags$footer(
    class = "text-center text-muted small py-3 border-top",
    p(
      "A graphical interface for ",
      tags$a("clusterProfiler", href = "https://bioconductor.org/packages/clusterProfiler", target = "_blank"),
      " and ",
      tags$a("enrichplot", href = "https://bioconductor.org/packages/enrichplot", target = "_blank"),
      ". Not affiliated with the package authors. If you use results from this app, please cite the packages (see How to 'Cite')."
    ),
    p(
      paste0("GOAT v ", app_version),
      " | clusterProfiler v", as.character(packageVersion("clusterProfiler")),
      " | enrichplot v", as.character(packageVersion("enrichplot"))
    )
  )
}