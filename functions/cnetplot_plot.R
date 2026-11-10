cnet <- function (enrichmentResult, m) {
  
  enrichplot::cnetplot(
    x = enrichmentResult,
    showCategory = m,
    node_label = 'share'
  )+guides(size = guide_legend(title = "Count"))
  
  
}
