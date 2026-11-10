#----- Nav Panel -----#

PlotTabUI <- function(id,          # Which plot are we making
                      title,       # Tab title
                      no_default,  # Default value for number of terms to plot
                      no_max,      # Maximum terms plotted
                      nClust,      # Number of clusters for tplot
                      disp_width,  # Width of display in web app
                      width_def,   # Default width for export
                      height_def)  # Default height for export
  { 

ns <- NS(id)
  
nav_panel(title,
          sidebarLayout(
            sidebarPanel(
              selectInput(ns("aspect"), 
                          label = "Choose which GO Aspect to Plot",
                          choices = 
                            list(
                              "Biological Processes",
                              "Molecular Functions", 
                              "Cellular Components"
                            ),
                          selected = "Biological Processes"
              ),
              sliderInput(ns("no_terms"), 
                          label = "Choose number of terms to display", 
                          value = no_default,
                          min = 1,
                          max = no_max),
              if (!is.null(nClust)) {
              sliderInput(ns("clust"), 
                          "Number of Clusters", 
                          value = 5, 
                          min = 1, 
                          max = no_max)
              },
              actionButton(ns("plot"), "Plot")
              
            ),
            mainPanel(
            conditionalPanel("input.plot > 0", ns = ns,
                card(
                     withSpinner(plotOutput(ns("plot_out"), width = disp_width, height = "70vh")),
                     downloadButton(ns("download"), "Download Plot"),
                     fluidRow(
                       column(numericInput(ns("width"), "Width (px)", value = width_def), width = 4, offset = 1, align = "center"),
                       column(numericInput(ns("height"), "Height (px)", value = height_def), width = 4, offset = 2, align = "center")
                     )) 
              ))
          )
)
}

#----- Server -----#
plotServer <- function(id, results, plot_org, prep_func, plot_func, DL_name) {
  moduleServer(id, function(input, output, session) {
    
    observeEvent(list(results(), input$aspect), {
      req(results())
      asp <- case_when(
        input$aspect == "Biological Processes" ~ "BP",
        input$aspect == "Molecular Functions"  ~ "MF",
        input$aspect == "Cellular Components"  ~ "CC"
      )
      n_available <- sum(as.data.frame(results())$ONTOLOGY == asp)
      n_available <- max(n_available, 1)   
      
      updateSliderInput(session, "no_terms",
                        max   = min(n_available, 30),
                        value = min(10, n_available))
      updateSliderInput(session, "clust",
                        max   = min(n_available, 30),
                        value = min(5, n_available))
    })
    
    for_plot <- eventReactive(input$plot, {
      req(results())
      #if (!is.null(plot_org())) {
      #  req(plot_org())
      #}
      
      aspect <- case_when(
        input$aspect == "Biological Processes" ~ "BP",
        input$aspect == "Molecular Functions" ~ "MF", 
        input$aspect == "Cellular Components" ~ "CC"
      )
      
      prep_func(asp = aspect,
                res = results(),
                org = plot_org())
      
      })
    
    DL_plot <- reactive({
      req(results(), for_plot())
      
      validate(need(nrow(as.data.frame(for_plot()$plot_data)) >= 2,
                    "Not enough significant terms in this GO aspect to draw this plot."))
      
      if (!is.null(input$clust)) {
        validate(
          need(input$clust <= input$no_terms,
               "Number of clusters can't be greater than the number of terms to plot.")
        )
      }
      
      tryCatch({
      plot_func(data = for_plot()$plot_data,
                asp = for_plot()$aspect,
                n_terms = input$no_terms,
                nclust = input$clust)
      
      }, error = function(e) {
        
        if (grepl("arguments imply differing number of rows:", 
                  conditionMessage(e))) {
          showNotification(
            "Unable to generate tree plot. Try a different number of clusters.",
            type = "error"
          )
        }
        })
        
      })
    
    output$plot_out <- renderPlot(DL_plot())
    
    output$download <- downloadHandler(
      filename = function() {
        paste0(DL_name, for_plot()$aspect, "_", Sys.Date(), ".png")
      },
      content = function(file) {
      req(DL_plot())
      
      ggsave(file,
             plot = (DL_plot()),
             width = input$width,
             height = input$height,
             units = "px"
             )
      }
    )
    
  })
}


#----------- Prep/Plot functions -------------#

dot_prep_func <- function(asp, res, org) {
  #org not used
  list(aspect = asp,
       plot_data = as.data.frame(res))
}
dot_plot_func <- function(data, asp, n_terms, nclust) {
  dot_plot(data,                              # prep function results
           asp,                               # GO aspect choice
           n_terms)                           # terms to display
}





cnet_prep_func <- function(asp, res, org) {
  #org not used
  list(aspect = asp,
       plot_data = filter(res, ONTOLOGY == asp))
}
cnet_plot_func <- function(data, asp, n_terms, nclust) {
  #asp not used
  cnet(data,                                  # prep function results
       n_terms)                               # terms to display
}





sem_prep_func <- function(asp, res, org) {
  filtered <- filter(res, ONTOLOGY == asp)
  prepped <- semantic_sim_func(org,           # Organism database for annotation
                               asp,           # GO Terms for plotting
                               filtered)      # enrichment object
  list(aspect = asp,
       plot_data = prepped)
}





eplot_plot_func <- function(data, asp, n_terms, nclust) {
  #asp not used
  enrichment_plot_func(data,                   # prep function results
                       n_terms)                # Number of categories to plot
}





tplot_plot_func <- function(data, asp, n_terms, nclust) {
  #asp not used
  tree(data,                                   # prep function results
       n_terms,
       nclust)                                # Number of categories to plot
}

#----------- Input Validation Function ---------------#

# Wasn't Sure where to put this so its here for now

check_inputs <- function(p,q,mingss,maxgss) {
  msgs <- character()
  
  if (anyNA(c(p,q,mingss,maxgss))) {
    return("Please fill in all threshold fields with numbers.")
  }
  
  if (p <= 0 || p > 1) msgs <- c(msgs, "p-value threshold must be greater than 0 and at most 1.")
  if (q <= 0 || q > 1) msgs <- c(msgs, "q-value threshold must be greater than 0 and at most 1.")
  if (mingss < 0)      msgs <- c(msgs, "Minimum term size can't be negative.")
  if (maxgss < 1)      msgs <- c(msgs, "Maximum term size must be at least 1.")
  if (mingss >= maxgss) msgs <- c(msgs, "Minimum term size must be smaller than maximum term size.")
  
  if (length(msgs) == 0) NULL else paste(msgs, collapse = "\n")
  
}



