#-----Libraries-------#
## Shiny App
library(shiny)
library(shinycssloaders)
library(bslib)

## Enrichment
library(GO.db)
library(clusterProfiler)
library(BiocParallel)
library(GOSemSim)
library(DOSE)

## Plots
library(enrichplot)
library(tidyverse)

#---Function Sourcing---#
source("HTML/footer.R")
source("HTML/helpPanel.R")
source("functions/GO_enrichment.R")
source("functions/dotplot_plot.R")
source("functions/cnetplot_plot.R")
source("functions/moduleFunctions.R")
source("functions/semanticsim_plotting.R")
source("functions/citations.R")

#-------Shiny App-------#

#------ UI -------#
ui <- fluidPage(
    #Theme
    theme = bs_theme(bootswatch = "flatly"),
    tags$head(
      tags$link(
        rel = "icon",
        type = "image/png",
        href = "GOATtab.png"
      )
    ),

    # Application title
    titlePanel(
      title = div(
        style = "display: flex; align-items: center; padding-left: 10px; padding-top: 10px",
        img(
          src = "GOATicon.svg",
          height = "70px",
          style = "margin-right: 5px;"
        ),
        div(
          h2(
            "GOAT",
            style = "margin: 0; font-weight: bold"
          ),
          p(
            "Gene Ontology Analysis Tool",
            style = "margin: 4px 0 0 0; font-size: 18px; font-style: italic; color: #777;"
          )
        )
      ),
      windowTitle = "GOAT"
    ),
    navset_card_pill(
      #----------- GO Enrichment -----------#
      nav_panel("GO Enrichment",
                # Sidebar 
                sidebarLayout(
                  sidebarPanel(
                    # Organism Choice
                    selectInput("organism",
                                label = "Choose an organism",
                                choices = 
                                  list(
                                    "Homo sapiens (Human)",
                                    "Mus musculus (Mouse)", 
                                    "Rattus norvegicus (Rat)",
                                    "Saccharomyces cerevisiae (Yeast)", 
                                    "Drosophila melanogaster (Fruit Fly)"
                                  ),
                                selected = "Homo sapiens (Human)"),
                    
                    # User DEGs
                    textAreaInput("DEG", 
                                  "Paste list of DEGs", 
                                  height = "140px", 
                                  placeholder = "e.g Rspo1\nWnt3a\nDisp2\nCcn1\nCdca7\nHpcal4"),
                    textAreaInput("universe", 
                                  "Paste universe (or leave blank - not recommended)", 
                                  height = "140px", 
                                  placeholder = "e.g Car9\nB3gnt2\nChst4\nGm45351\nWdr86\nWnt7a"),
                    
                    # Thresholds and variables
                    selectInput("fdrMethod",
                                label = "Choose FDR method (if unsure leave default)",
                                choices = 
                                  list(
                                    "Benjamini-Hochberg",
                                    "Bonferroni", 
                                    "Holm",
                                    "Hommel", 
                                    "Benjamini-Yekutieli"
                                  ),
                                selected = "Benjamini-Hochberg"),
                    numericInput("pthresh", 
                                 label = "Input threshold for p-value", 
                                 value = 0.05, 
                                 step = 0.01,
                                 min = 0,
                                 max = 1),
                    numericInput("qthresh", 
                                 label = "Input threshold for q-value", 
                                 value = 0.05, 
                                 step = 0.01,
                                 min = 0,
                                 max = 1),
                    
                    numericInput("minGSS", 
                                 label = "Input minimum number of genes required in a GO term",
                                 value = 10,
                                 step = 1,
                                 min = 0),
                    numericInput("maxGSS", 
                                 label = "Input maximum number of genes required in a GO term",
                                 value = 500,
                                 step = 10,
                                 min = 1),
                    
                    # Run Button
                    actionButton("Run","Run"),
                    helpText("This will take a moment.")
                    
                  ),
          
                  mainPanel(
                    conditionalPanel(
                      condition = "input.Run > 0",
                      card(downloadButton("downloadData", "Download GO Terms"),
                           downloadButton("downloadRawData", "Download Raw (non-simplified) GO Terms")),
                      card("Top 10 Biological Processes",
                           withSpinner(tableOutput("go_table_BP"))),
                      card("Top 10 Molecular Functions",
                           withSpinner(tableOutput("go_table_MF"))),
                      card("Top 10 Cellular Components",
                           withSpinner(tableOutput("go_table_CC"))),
                      card("Unmapped Genes",
                           withSpinner(verbatimTextOutput("nomap")))
                    ),
                  ),
                )
              ),
      #----------- Plotting NavPanels  -----------#
      PlotTabUI (id = "dplot",                # Which plot are we making
                 title = "Dot Plot",          # Tab title
                 no_default = 10,             # Default value for number of terms to plot
                 no_max = 30,                 # Maximum terms plotted 
                 nClust = NULL,               # Number of clusters for tree plot
                 disp_width = "100%",        # Width of display in web app
                 width_def = 2160,            # Default width for export
                 height_def = 2160),          # Default height for export
      
      PlotTabUI (id = "eplot",             
                 title = "Enrichment Map Plot",
                 no_default = 10,          
                 no_max = 50,       
                 nClust = NULL,
                 disp_width = "100%",     
                 width_def = 3840,         
                 height_def = 2160),      
      
      PlotTabUI (id = "cplot",             
                 title = "Gene-Concept Network Plot",       
                 no_default = 5,           
                 no_max = 30,    
                 nClust = NULL,
                 disp_width = "100%",     
                 width_def = 2160,         
                 height_def = 2160),      
      
      PlotTabUI (id = "tplot",            
                 title = "Treeplot",      
                 no_default = 25,           
                 no_max = 50,      
                 nClust = 5,
                 disp_width = "100%",    
                 width_def = 3840,         
                 height_def = 2880),  
      
      #---------------- Help -----------------#
      nav_panel("Help",
                  helpmenu()
                ),
      nav_panel("How to Cite",
                citationsTab()
      )
      
    ),
    
    footerUI()
    
)

server <- function(input, output) {
  
  
  #--- Global Variables ---#
  
  results               <- reactiveVal(NULL)   # For usage of functional enrichment object
  plot_org              <- reactiveVal(NULL)   # For choice of organism in plots
  ego_raw               <- reactiveVal(NULL)   # For download of non-simplified GO Terms .csv
  
  #--- GO Enrichment ---#
  
  observeEvent(input$Run, {
    
    ego_raw(NULL)
    results(NULL)
    plot_org(NULL)
    
    output$go_table_BP <- renderTable(data.frame())
    output$go_table_MF <- renderTable(data.frame())
    output$go_table_CC <- renderTable(data.frame())

    GENELIST <- unique(unlist(strsplit(input$DEG, "\n")))
    GENELIST <- as.character(GENELIST[GENELIST != ""])
    
    REFLIST <- unique(unlist(strsplit(input$universe, "\n")))
    REFLIST <- as.character(REFLIST[REFLIST != ""])
    
    #Load relevant organism database
    ORG <- case_when(
      input$organism == "Homo sapiens (Human)" ~ "org.Hs.eg.db",
      input$organism == "Mus musculus (Mouse)" ~ "org.Mm.eg.db",  
      input$organism == "Rattus norvegicus (Rat)" ~ "org.Rn.eg.db",
      input$organism == "Saccharomyces cerevisiae (Yeast)" ~ "org.Sc.sgd.db", 
      input$organism == "Drosophila melanogaster (Fruit Fly)" ~ "org.Dm.eg.db"
    )
    
    switch(
      ORG,
      "org.Hs.eg.db"  = library(org.Hs.eg.db),  # Homo sapiens
      "org.Mm.eg.db"  = library(org.Mm.eg.db),  # Mus musculus
      "org.Rn.eg.db"  = library(org.Rn.eg.db),  # Rattus norvegicus
      "org.Sc.sgd.db" = library(org.Sc.sgd.db), # Saccharomyces cerevisiae
      "org.Dm.eg.db"  = library(org.Dm.eg.db)   # Drosophila melanogaster
          )
  
    FDR <- case_when(
      input$fdrMethod == "Benjamini-Hochberg" ~ "BH",
      input$fdrMethod == "Bonferroni" ~ "bonferroni", 
      input$fdrMethod == "Holm" ~ "holm",
      input$fdrMethod == "Hommel" ~ "hommel", 
      input$fdrMethod == "Benjamini-Yekutieli" ~ "BY"
      )
    
    PVAL <- as.numeric(input$pthresh)
    QVAL <- as.numeric(input$qthresh)
    MINGSS <- as.numeric(input$minGSS)
    MAXGSS <- as.numeric(input$maxGSS)
    
    problem <- check_inputs(PVAL, QVAL, MINGSS, MAXGSS)
    if (!is.null(problem)) {
      showNotification(problem, type = "error", duration = 10)
      return()
    }
    
    withCallingHandlers( 
      tryCatch({
        
      overlapping_genes <- GENELIST %in% keys(get(ORG), keytype="SYMBOL")
      output$nomap <- renderPrint(cat(GENELIST[!overlapping_genes], sep = "\n"))
        
      ego <- enrich(GENELIST, # User-input genes for enrichment
                    REFLIST,  # User-input universe
                    ORG,      # Organism database for annotation
                    FDR,      # FDR method (default = BH)
                    PVAL,     # p-value threshold (default = 0.05)
                    QVAL,     # q-value threshold (default = 0.05)
                    MINGSS,   # Minimum pathway size (default = 10)
                    MAXGSS    # Maximum pathway size (default = 500)
                    )
      ego_raw(ego)
      
      ego_df <- as.data.frame(ego)
      
      if (is.null(ego) || nrow(ego_df) == 0) {         
        showNotification("No significant GO terms found with these settings.", type = "warning", duration = 60) 
        ego_raw(NULL)
        results(NULL)
        return(invisible(NULL))
      }
      
      ego <- tryCatch(
        clusterProfiler::simplify(ego, cutoff = 0.7, by = "p.adjust",                #Removes degenerate terms
                                  select_fun = min, measure = "Wang"),
        error = function(e) {
          showNotification("Could not simplify terms; showing unsimplified results.",
                           type = "warning", duration = 60)
          ego
        }
      ) 
      
      ego_table <- as.data.frame(ego) |> mutate(
        across(
          any_of(c("pvalue", "p.adjust", "qvalue")),
          ~ formatC(as.numeric(.x), format = "e", digits = 2)
          )
      )
      
      results(ego)
      plot_org(ORG)
  
#Display Tables
    for (i in c("BP", "MF", "CC")) {
      local({
      ego_disp <- ego_table |>
        filter(ONTOLOGY == i) |>
        head(n = 10)
      
      term <- paste0("go_table_",i)
      
      if (nrow(ego_disp) == 0) {
        ego_disp <- data.frame(
          Message = "No significant terms found."
        )
      }
      output[[term]] <- renderTable(ego_disp, striped = TRUE, bordered = TRUE)
      })
    }
  
    }, error = function(e) {
      
      if (grepl("error in evaluating the argument 'x' in selecting a method for function 'as.data.frame':", 
                conditionMessage(e))) {
        showNotification(
          "Genes unrecognized. Please check your input genes and species",
          type = "error"
        )
      } else {
        showNotification(
          paste("An error has occurred: ", 
          conditionMessage(e)),
          type = "error"
        )
      }
      
    }), warning = function(w) {
      showNotification(paste(conditionMessage(w)),
                       type = "warning"
      )
    },
       message = function(m) {
         if (grepl("--> No gene can be mapped....", conditionMessage(m), fixed = TRUE)) {
         showNotification("No gene can be mapped. Did you forget to input your genes?", type ="warning")
       }
       }
  )
     
 })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("GO_enrichment_", Sys.Date(), ".csv")
    },
    content = function(file) {
      req(results())
      write.csv(results(),file,row.names = FALSE)
    }
  )
  output$downloadRawData <- downloadHandler(
    filename = function() {
      paste0("GO_enrichment_raw_", Sys.Date(), ".csv")
    },
    content = function(file) {
      req(ego_raw())
      write.csv(ego_raw(),file,row.names = FALSE)
    }
  )
  
  #--------- Plots -------------#
  
  plotServer(id = "dplot",
             results,
             plot_org = reactive(NULL),
             prep_func = dot_prep_func,
             plot_func = dot_plot_func,
             DL_name = "GO_dotplot_")
  
  plotServer(id = "cplot",
             results,
             plot_org = reactive(NULL),
             prep_func = cnet_prep_func,
             plot_func = cnet_plot_func,
             DL_name = "GO_cnetplot_")
  
  plotServer(id = "eplot",
             results,
             plot_org,
             prep_func = sem_prep_func,
             plot_func = eplot_plot_func,
             DL_name = "GO_enrichmentplot_")
  
  plotServer(id = "tplot",
             results,
             plot_org,
             prep_func = sem_prep_func,
             plot_func = tplot_plot_func,
             DL_name = "GO_treeplot_")
  

}

# Run the application 
shinyApp(ui = ui, server = server)
