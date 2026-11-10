dot_plot <- function(ego_data,  # Data from enrichGO
                     ont,       # Ontology for plotting
                     NO_DISPLAY # Number of terms to display in plot
                     ) {
  
  ego_data$negLogpadj <- -log10(ego_data$p.adjust)
  
  ego_data <- filter(ego_data,
              ONTOLOGY == ont)
  
  ego_data$GeneRatio <- vapply(
    strsplit(as.character(ego_data$GeneRatio), "/"),
    function(x) as.numeric(x[1])/as.numeric(x[2]),
    numeric(1)
  )
  
  plot_ready_ego <- ego_data |>
    mutate(Description = str_wrap(Description, width = 30)) |>
    slice_max(order_by = negLogpadj, n = NO_DISPLAY, with_ties = FALSE) |>
    mutate(Description = reorder(
      Description,
      GeneRatio
    ))
  
  ggplot(plot_ready_ego, aes(x = GeneRatio, y = Description)) +
    geom_point(
      aes(size = Count, colour = negLogpadj))+
    scale_colour_gradientn(
      colours = c("blue", "yellow","red"),
      limits = c(min(plot_ready_ego$negLogpadj), max(plot_ready_ego$negLogpadj)),
      name = expression(-log[10]("p.adjust"))
      )+
    labs(
      x = "Gene Ratio",
      y = NULL,
      size = "Gene Count"
    )+
    guides(size = guide_legend(order=1),
           colour = guide_colourbar(order = 2))+
    theme_classic()+
    theme(
      strip.placement = "outside"
    )
  
  
}