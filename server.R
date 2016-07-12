#Variables and functions
library(shiny)
library(Rlabkey)
library(ImmuneSpaceR)
library(gtools)

con <- NULL
labkey.url.base <- NULL

getStudies <- function(){
  sdys <- mixedsort(grep("^SDY", basename(lsFolders(getSession(labkey.url.base, "Studies"))), value = TRUE))
  sdys <- sdys[sdys != "SDY_template"]
  return(sdys)
}

#Server
shinyServer(function(input, output, session) {
  
  # This will be used to handle login
  ## LOGIN
  #output$server_title <- renderText({
  #  input$netrcButton
  #  isolate({
  #    if(input$netrcButton > 0){
  #      netrc_file <- tempfile("ImmuneSpaceR_tmp_netrc")
  #      netrc_string <- paste("machine www.immunespace.org login", input$login, "password", input$pwd)
  #      write(x = netrc_string, file = netrc_file)
  #      labkey.netrc.file <- netrc_file
  #    }
  #  })
  #})
  
  ## SERVER
  observeEvent(input$connectButton, { #Handle actionButtons
        labkey.url.base <<- input$server
        updateSelectInput(session, "study_accession", "Study", 
                          choices = getStudies())
        updateSelectInput(session, "display_dataset", choices = "") #cleanup the dataset dropdown
  })
  
  ## CONNECTION
  observeEvent(input$ccButton, {
    con <<- CreateConnection(input$study_accession)
    updateSelectInput(session, "display_dataset", "Dataset",
                      choices = con$available_datasets$Name)
  })
  
  ## DATASET
  output$dataset <- renderPrint({
    input$qpButton
    isolate({
      if(input$qpButton > 0){
        input$display_dataset
      }
    })
  })
  
  ## TABLE
  output$DT <- renderDataTable({
    input$gdButton
    isolate({
      if(input$gdButton > 0){
        dataset_dt <<- con$getDataset(input$display_dataset, original_view = input$gd_opts_CB)
        return(dataset_dt)
      }
    })
  })
  observe({
    if(input$gdButton > 0)
    #updateTabsetPanel should always be within an observer
    updateTabsetPanel(session, inputId = "panels", selected = "Table")
  })
  
  # File download known to not create files when used from Rstudio's viewer
  output$download_dataset <- downloadHandler(
    filename = function(){
      paste0(input$study_accession, "_", input$display_dataset, ".tsv")
    },
    content = function(file){
      write.table(dataset_dt, file = file, sep = "\t", quote = FALSE, row.names = FALSE)
    },
    contentType = "text/csv"
  )
    
  
  ## PLOT
  output$qp <- renderPlot({
    input$qpButton
    isolate({
      con$quick_plot(input$display_dataset, normalize_to_baseline = input$qp_opts_CB)
    })
  })
  observe({
    if(input$qpButton > 0)
      updateTabsetPanel(session, inputId = "panels", selected = "Plot")
  })
  
  ## DEBUG
  output$debug <- renderPrint({
    R_send <- input$R_send
    if (input$R_send == 0) {
      return( invisible(NULL) )
    }
    isolate({
      code <- input$R_input
      result <- eval( parse( text=code ) )
      return(result)
    })
  })
})
