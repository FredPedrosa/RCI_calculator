library(shiny)
library(dplyr)
library(rciplot)
library(ggplot2)

# Function to calculate the RCI
calculate_RCI <- function(T1, T2, reliability, variable_name) {
  mean_T1 <- mean(T1)
  sd_T1 <- sd(T1)
  se_measurement <- sd_T1 * sqrt(1 - reliability)
  se_difference <- sqrt(2 * (se_measurement^2))
  RCI <- (T2 - T1) / se_difference
  upper_cutoff <- 1.96 * se_difference
  lower_cutoff <- -1.96 * se_difference
  interpretation <- ifelse(RCI > 1.96, "RPC", 
                           ifelse(RCI < -1.96, "RNC", "NRC"))
  
  data.frame(T1, T2, RCI, Interpretation = interpretation)
}

# User interface
ui <- fluidPage(
  titlePanel("Reliable Change Index estimator"),
  
  fluidRow(
    column(12,
           p("This application calculates the Reliable Change Index (RCI), and also Reliable Recovery, to determine reliable changes in measured variables over time. For that:"),
           p("1 - enter the number of participants, the measured variable name, and the reliability (p.e. Cronbach’s alpha or McDonald’s omega) of the variable."),
           p("2 - choose to calculate the cutoff point from the sample or specify a cutoff value."),
           p("3 - insert the values for each participant on the first measurement (T1) and the last measurement (T2)."),
           p("4 - click the Calculate RCI button."),
           p("The results in the table will show whether the change is a Reliable Positive Change (RPC), Reliable Negative Change (RNC), or No Reliable Change (NRC). Additionally, the plot will illustrate changes in terms os Reliable Recovery."),
           p("**Note: in the table the RPC will always indicate that the score in the T2 is higher than the score in T2. In the plot, if a higher score in T2 indicates deterioration, it will be shown on the legend.")
    )
  )
  ,
  
  sidebarLayout(
    sidebarPanel(
      numericInput("n_participants", "Number of Participants:", 1, min = 1, max = 100),
      textInput("variable_name", "Measured Variable Name:", "Cognition"),
      numericInput("reliability", "Variable Reliability:", 0.96, min = 0, max = 1),
      checkboxInput("higher_is_better", "Higher value is better", TRUE),
      radioButtons("cutoff_option", "Cutoff Option:",
                   choices = list("Calculate from sample" = "sample",
                                  "Specify cutoff value" = "specified")),
      numericInput("cutoff_value", "Specified Cutoff Value:", 68, min = 0),
      actionButton("add_participant", "Add more participants"),
      
      uiOutput("inputs_t1"),
      uiOutput("inputs_t2"),
      
      actionButton("calculate", "Calculate RCI")
    ),
    
    mainPanel(
      tableOutput("rci_table"),
      plotOutput("rci_plot"),
      div(
        p("[RPC = Reliable Positive Change; RNC = Reliable Negative Change; NRC = No Reliable Change; T1 = first measurement; T2 = last measurement.]"),
        p("How to cite the app: Pedrosa, F. G.. (2025). _Reliable Change Index estimator_. [Software]. https://fredpedrosa.shinyapps.io/rci_app/"),
        p("Plot made with: Hagspiel, M.. (2023). _rciplot: Plot Jacobson-Truax Reliable Change Indices_. R package version 0.1.1, <https://CRAN.R-project.org/package=rciplot>.")
      )
    )
  )
)

# Server function
server <- function(input, output, session) {
  
  # Reactive values to store T1 and T2 scores
  data_t1 <- reactiveVal()
  data_t2 <- reactiveVal()
  
  # Generate inputs for T1 and T2 dynamically
  output$inputs_t1 <- renderUI({
    lapply(1:input$n_participants, function(i) {
      numericInput(paste0("T1_", i), paste("T1 Participant", i), value = NULL)
    })
  })
  
  output$inputs_t2 <- renderUI({
    lapply(1:input$n_participants, function(i) {
      numericInput(paste0("T2_", i), paste("T2 Participant", i), value = NULL)
    })
  })
  
  # Action to add more participants
  observeEvent(input$add_participant, {
    updateNumericInput(session, "n_participants", value = input$n_participants + 1)
  })
  
  # Calculate the RCI and generate the table and plot
  observeEvent(input$calculate, {
    # Capture the values of T1 and T2 inputs
    t1_values <- sapply(1:input$n_participants, function(i) input[[paste0("T1_", i)]])
    t2_values <- sapply(1:input$n_participants, function(i) input[[paste0("T2_", i)]])
    
    # Update the reactive values of T1 and T2
    data_t1(t1_values)
    data_t2(t2_values)
    
    # Calculate the cutoff point
    if (input$cutoff_option == "sample") {
      mean_T1 <- mean(data_t1())
      sd_T1 <- sd(data_t1())
      PC <- round(mean_T1 + 2 * sd_T1, 2)
    } else {
      PC <- input$cutoff_value
    }
    
    # Calculate the RCI
    rci_result <- calculate_RCI(data_t1(), data_t2(), input$reliability, input$variable_name)
    
    # Display the table with the results
    output$rci_table <- renderTable({
      rci_result
    })
    
    # Generate the plot with rciplot and modify axis labels
    output$rci_plot <- renderPlot({
      data <- data.frame(pre_data = data_t1(), post_data = data_t2())
      plot_result <- rciplot(
        data = data,
        pre = 'pre_data',
        post = 'post_data',
        reliability = input$reliability,
        recovery_cutoff = PC,
        opacity = 1,
        higher_is_better = input$higher_is_better,
        size_points = 2.5,
        size_lines = 1
      )
      plot_result$plot + labs(x = "T1", y = "T2")
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)
