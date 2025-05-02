library(shiny)
library(dplyr)
library(rciplot)
library(ggplot2)

# Função para calcular o RCI
calcular_RCI <- function(T1, T2, confiabilidade, nome_variavel) {
  media_T1 <- mean(T1)
  sd_T1 <- sd(T1)
  se_medida <- sd_T1 * sqrt(1 - confiabilidade)
  se_diferenca <- sqrt(2 * (se_medida^2))
  RCI <- (T2 - T1) / se_diferenca
  corte_superior <- 1.96 * se_diferenca
  corte_inferior <- -1.96 * se_diferenca
  interpretacao <- ifelse(RCI > 1.96, "MPC", 
                          ifelse(RCI < -1.96, "MNC", "AMC"))
  
  data.frame(T1, T2, RCI, Interpretacao = interpretacao)
}

# Interface do usuário
ui <- fluidPage(
  titlePanel("Estimador do Índice de Mudança Confiável (RCI)"),
  
  fluidRow(
    column(12,
           p("Este aplicativo calcula o Índice de Mudança Confiável (RCI) e também a Recuperação Confiável, para determinar mudanças confiáveis em variáveis medidas ao longo do tempo. Para isso:"),
           p("1 - insira o número de participantes, o nome da variável medida e a confiabilidade (por exemplo, alfa de Cronbach ou ômega de McDonald) da variável."),
           p("2 - escolha calcular o ponto de corte a partir da amostra ou especificar um valor de corte."),
           p("3 - insira os valores para cada participante na primeira medição (T1) e na última medição (T2)."),
           p("4 - clique no botão Calcular RCI."),
           p("Os resultados na tabela mostrarão se a mudança é uma Mudança Positiva Confiável (MPC), Mudança Negativa Confiável (MNC) ou Ausência de Mudança Confiável (AMC). Além disso, o gráfico ilustrará as mudanças em termos de Recuperação Confiável."),
    )
  ),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("n_participantes", "Número de Participantes:", 1, min = 1, max = 100),
      textInput("nome_variavel", "Nome da Variável Medida:", "Cognição"),
      numericInput("confiabilidade", "Confiabilidade da Variável:", 0.96, min = 0, max = 1),
      checkboxInput("higher_is_better", "Valor mais alto é melhor", TRUE),
      radioButtons("cutoff_option", "Opção de Ponto de Corte:",
                   choices = list("Calcular a partir da amostra" = "amostra",
                                  "Especificar valor de corte" = "especificado")),
      numericInput("cutoff_value", "Valor de Corte Especificado:", 68, min = 0),
      actionButton("add_participant", "Adicionar mais participantes"),
      
      uiOutput("inputs_t1"),
      uiOutput("inputs_t2"),
      
      actionButton("calculate", "Calcular RCI")
    ),
    
    mainPanel(
      tableOutput("rci_table"),
      plotOutput("rci_plot"),
      div(
        p("[MPC = Mudança Positiva Confiável; MNC = Mudança Negativa Confiável; AMC = Ausência de Mudança Confiável; T1 = primeira medição; T2 = última medição.]"),
        p("Como citar o aplicativo: Pedrosa, F. G.. (2025). _Estimador do Índice de Mudança Confiável_. [Software]. https://fredpedrosa.shinyapps.io/JT_pt/"),
        p("Gráfico feito com: Hagspiel, M.. (2023). _rciplot: Plot Jacobson-Truax Reliable Change Indices_. Versão do pacote R 0.1.1, <https://CRAN.R-project.org/package=rciplot>.")
      )
    )
  )
)

# Função do servidor
server <- function(input, output, session) {
  
  # Valores reativos para armazenar os escores T1 e T2
  dados_t1 <- reactiveVal()
  dados_t2 <- reactiveVal()
  
  # Gerar inputs para T1 e T2 dinamicamente
  output$inputs_t1 <- renderUI({
    lapply(1:input$n_participantes, function(i) {
      numericInput(paste0("T1_", i), paste("T1 Participante", i), value = NULL)
    })
  })
  
  output$inputs_t2 <- renderUI({
    lapply(1:input$n_participantes, function(i) {
      numericInput(paste0("T2_", i), paste("T2 Participante", i), value = NULL)
    })
  })
  
  # Ação para adicionar mais participantes
  observeEvent(input$add_participant, {
    updateNumericInput(session, "n_participantes", value = input$n_participantes + 1)
  })
  
  # Calcular o RCI e gerar a tabela e o gráfico
  observeEvent(input$calculate, {
    # Capturar os valores dos inputs T1 e T2
    valores_t1 <- sapply(1:input$n_participantes, function(i) input[[paste0("T1_", i)]])
    valores_t2 <- sapply(1:input$n_participantes, function(i) input[[paste0("T2_", i)]])
    
    # Atualizar os valores reativos de T1 e T2
    dados_t1(valores_t1)
    dados_t2(valores_t2)
    
    # Calcular o ponto de corte
    if (input$cutoff_option == "amostra") {
      media_T1 <- mean(dados_t1())
      sd_T1 <- sd(dados_t1())
      PC <- round(media_T1 + 2 * sd_T1, 2)
    } else {
      PC <- input$cutoff_value
    }
    
    # Calcular o RCI
    rci_resultado <- calcular_RCI(dados_t1(), dados_t2(), input$confiabilidade, input$nome_variavel)
    
    # Exibir a tabela com os resultados
    output$rci_table <- renderTable({
      rci_resultado
    })
    
    # Gerar o gráfico com rciplot e modificar os rótulos dos eixos
    output$rci_plot <- renderPlot({
      dados <- data.frame(pre_data = dados_t1(), post_data = dados_t2())
      plot_resultado <- rciplot(
        data = dados,
        pre = 'pre_data',
        post = 'post_data',
        reliability = input$confiabilidade,
        recovery_cutoff = PC,
        opacity = 1,
        higher_is_better = input$higher_is_better,
        size_points = 2.5,
        size_lines = 1
      )
      plot_resultado$plot + labs(x = "T1", y = "T2")
    })
  })
}

# Executar o aplicativo
shinyApp(ui = ui, server = server)








