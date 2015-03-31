# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

#Variables and functions
library(shiny)
library(ImmuneSpaceR)
library(gtools)
con <- NULL
labkey.url.base <- "www.immunespace.org"
getStudies <- function(){
  sdys <- mixedsort(grep("^SDY", basename(lsFolders(getSession(labkey.url.base, "Studies"))), value = TRUE))
  return(sdys)
}

#Server
shinyServer(function(input, output, session) {
  
  ## CONNECTION
  updateSelectInput(session, "study_accession", "Study",
                    choices = getStudies())
  
  output$study_title <- renderText({
    input$ccButton
    isolate({
      if(input$ccButton >0){ #even with isolate, it would get executed once
        con <<- CreateConnection(input$study_accession)
        updateSelectInput(session, "display_dataset", "Dataset",
                          choices = con$available_datasets$Name)
        input$study_accession
      }
    })
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
        con$getDataset(input$display_dataset, original_view = input$gd_opts_CB)
      }
    })
  })
  observe({
    if(input$gdButton > 0)
    #updateTabsetPanel should always be within an observer
    updateTabsetPanel(session, inputId = "panels", selected = "Table")
  })
  
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
