library(shiny)

shinyUI(fluidPage(

  h1(textOutput("server_name")),
  #titlePanel(
  #  fluidRow(
  #    column(2, h2(textOutput("server_name"))),
  #    column(2, h2(textOutput("study_title")))
  #  )
  #),

  sidebarLayout(
    sidebarPanel(
      # This will handle login (to remove the need for netrc)
      #textInput("login", label = "Login", value = ""),
      #textInput("pwd", label = "Password", value = ""),
      #actionButton(inputId = "netrcButton", "Login"),
      #hr(),
      selectInput("server", "Server", choices = paste0(c("test", "www"), ".immunespace.org")),
      actionButton(inputId = "connectButton", "Connect"),
      hr(),
      selectInput("study_accession", "Study", choices = ""),
      actionButton(inputId = "ccButton", "Create Connection"),
      hr(),
      selectInput("display_dataset", "Dataset", choices = ""),
      #tags$div(title="Get the data as it is in the ImmPort database",
      #         style="float: right", icon("question-circle")),
      checkboxInput("gd_opts_CB", label = "ImmPort view"),
      actionButton(inputId = "gdButton", "Get dataset"),
      #hr(),
      #tags$div(title="Log-transform and substract baseline", 
      #         style="float: right", icon("question-circle")),
      checkboxInput("qp_opts_CB", label = "Normalize to baseline"),
      actionButton(inputId = "qpButton", "Quick plot"),
      hr()
    ),

    mainPanel(
      tabsetPanel(id="panels",
        tabPanel('Table',
                 hr(),
                 dataTableOutput("DT"),
                 downloadButton("download_dataset", "Download")
                 ),
        tabPanel('Plot',
                 hr(),
                 plotOutput("qp")
                 ),
        tabPanel('Debug',
                 hr(),
                 tags$div(
                   textInput("R_input", "Enter an R Command", ''),
                   tags$button(id = "R_send", type = "button", class = "btn action-button", "Submit",
                               style = "margin-bottom: 10px;")
                 ),
                 tags$div(
                   verbatimTextOutput("debug")
                 )
                 )
        )
      )
    )
))
