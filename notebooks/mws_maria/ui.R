
# want a graph to select by process type to show total jobs, hours and hours diff
# ditto for a table
fluidPage(
  
  # Application title
  navbarPage("Metalworking Solutions - Maria's Test App",
             
             tabPanel("Operations",
                      # sidebarLayout(
                      #   sidebarPanel(
                      #     selectInput("process", 
                      #                 label = "Choose Process:", 
                      #                 choices = c('ALL', job_ops |> distinct(short_description) |> pull(short_description) |> sort()),
                      #                 selected = 1),
                      #   ),
                        
                        
                        mainPanel(
                          plotOutput(outputId = "opsChart"),
                          DT::DTOutput(outputId = "opsTable")
                        )
                      #)
             ),
             
             tabPanel("Parts",
                      mainPanel(
                        plotOutput(outputId = "partsChart"),
                        DT::DTOutput(outputId = "partsTable")
                      )
             )
  )
)
