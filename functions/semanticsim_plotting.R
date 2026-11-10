semantic_sim_func <- function(organism, ontology, enrich_result) {
  
  semData <- godata(
    annoDb = organism,
    keytype = "SYMBOL",
    ont = ontology,
    computeIC = FALSE
  )
  
  paired_data <- pairwise_termsim(
    x = enrich_result,
    method = "Wang",
    semData = semData
  ) 
  
  paired_data@result$negLog10padj <- -log10(paired_data@result$p.adjust)
  
  return(paired_data)
  
}

enrichment_plot_func <- function(ego_plot_data, N) {
  
  emapplot(
    ego_plot_data,
    showCategory = N,
    color = "negLog10padj"
  )+ 
    scale_colour_gradientn(
    colours = c("blue", "yellow","red"),
    name = expression(-log[10]("p.adjust")),
    limits = c(min(ego_plot_data$negLog10padj), max(ego_plot_data$negLog10padj)),
  )+
    guides(
      size = guide_legend(title = "Count", order = 1),
      colour = guide_colourbar(order = 2)
    )
  
}

tree <- function(ego_tree_data, numberChoice, nclust) {
  
  p <- enrichplot::treeplot(
    x                     = ego_tree_data,
    showCategory          = numberChoice,
    color                 = "negLog10padj",
    nCluster              = nclust,          
    cladelab_offset       = rel(10),      
    hexpand               = 0.25,
    tiplab_offset         = 0.4
  )+ 
  scale_colour_gradientn(
      colours = c("blue", "yellow", "red"),
      name    = expression(-log[10]("p.adjust")),
      limits = c(min(ego_tree_data$negLog10padj), max(ego_tree_data$negLog10padj))
  )+
  guides(colour_ggnewscale_1 = "none")
  
  p$data$label <- ifelse(p$data$isTip,
                         stringr::str_wrap(p$data$label, 60),
                         p$data$label)

  p
  
}