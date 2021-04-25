#----------------------------------------------------------------------------
# Kontrafaktischer Sparplanrechner
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Load R libraries and themes
#----------------------------------------------------------------------------

library(shiny)
library(tidyverse)
library(tidyquant)
library(highcharter)

#tickersList <- read.csv(file = "data/tickersList.csv") # shiny_apps/kontrafaktischer-sparplanrechner/

#----------------------------------------------------------------------------
# Shiny App
#----------------------------------------------------------------------------

ui <- fluidPage(

    # Application title
  titlePanel("Kontrafaktischer Aktiensparplanrechner"),
  h5(tags$a(href = "https://www.jantau.com/", target = "_blank", "jantau.com")), 

    sidebarLayout(
        sidebarPanel(
          selectizeInput(
            "stocks",
            "Aktie/Fonds:",
            choices = NULL,
            options = list(placeholder = "Wähle eine Aktie aus")
          ),
          dateRangeInput("dates",
                         "Zeitraum:",
                         start = "2010-01-01",
                         end = as.character(Sys.Date())), 
            
          numericInput(
            "savings",
            "Monatliche Einzahlung",
            min = 0,
            max = 10000,
            step = 1,
            value = 100
          ), 
            
       #     br(),
        #    checkboxInput("log", "Y-Achse mit logarithmischer Skalierung",
        #                  value = FALSE)
       
       HTML('<p>Den für diese Web App erstellten Code findest du hier: <a href="https://github.com/jantau/jantau/tree/main/shiny_apps" target="_blank">https://github.com/jantau/jantau</a></p>'),
        
       ),
       
        mainPanel(
           highchartOutput("distPlot")
        )
    )
)

server <- function(input, output, session) {
  tickersList <- read.csv(file = "data/tickersList.csv")
  
  updateSelectizeInput(
    session,
    "stocks",
    choices = tickersList$Name,
    server = TRUE,
    selected = "Apple Inc. - Common Stock"
  ) # Using selectize input https://shiny.rstudio.com/articles/selectize.html  
  
    dataInput <- reactive({
      # Use reactive expressions https://shiny.rstudio.com/tutorial/written-tutorial/lesson6/
      
      validate(
        need(input$stocks != "", "Daten werden geladen") # Write error messages for your UI with validate https://shiny.rstudio.com/articles/validation.html
      )
       # getSymbols(input$stocks, src = "yahoo",
        #           from = input$dates[1],
         #          to = input$dates[2],
          #         auto.assign = FALSE)
        
      stocks <-
        tickersList$Symbol[tickersList$Name == input$stocks]
      
      stock <- tq_get(stocks,
                      get  = "stock.prices",
                      from = input$dates[1],
                      to = input$dates[2])
        
        stock %>%
          drop_na() %>%
          select(1, 2, 8) %>%
          mutate(yearmon = floor_date(date, unit = "month"), .after = date) %>%
          group_by(yearmon) %>%
          mutate(saving = case_when(row_number(yearmon) == 1 ~ input$savings,
                                    TRUE ~ as.integer(0))) %>%
          ungroup() %>%
          mutate(saving_total = cumsum(saving))
    })
    
    output$distPlot <- renderHighchart({
      
      stock <- data.frame(dataInput())
      
      stock[1, "shares"] <-
        stock[1, "saving"] / stock[1, "adjusted"]
      stock[1, "portfolio"] <-
        stock[1, "shares"] * stock[1, "adjusted"] 
      
      for (i in 2:nrow(stock)) {
        stock[i, "shares"] <-
          stock[i - 1, "shares"] + (stock[i, "saving"] / stock[i, "adjusted"])
        stock[i, "portfolio"] <-
          stock[i, "shares"] * stock[i, "adjusted"]
      }
      
      stock <- stock %>%
        mutate(performance = ((portfolio / saving_total) - 1) * 100) %>%
        mutate(diffyears = as.numeric(difftime(date, first(date), unit = "weeks"))/52.25) %>%
        mutate(cagr = ((portfolio/saving_total)^(1/diffyears) - 1) * 100)
      
      highchart() %>%
        hc_add_series(
          data = stock,
          type = "line",
          hcaes(x = date, y = portfolio),
          name = input$stocks,
          tooltip = list(pointFormat = "Kursstand {point.symbol}: <b>{point.adjusted:.1f}</b><br><span style='color:#2f7ed8;'>Wert des Porfolios:</span> <b>{point.portfolio:.0f}</b><br>") # https://api.highcharts.com/highcharts/colors
        ) %>%
        hc_add_series(
          data = stock,
          type = "line",
          hcaes(x = date, y = saving_total),
          name = "Ansparen",
          tooltip = list(pointFormat = "<span style='color:#0d233a;'>Ansparsumme:</span> <b>{point.saving_total}</b><br>Gesamtwachstumsrate: <b>{point.performance:.0f} %</b><br>Jährliche Wachstumsrate (CAGR): <b>{point.cagr:.1f} %</b>")
        ) %>%
        hc_credits(enabled = TRUE,
                   text = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com",
                   href = "https://www.jantau.com") %>%
        hc_xAxis(title = list(text = NULL),
                 type = 'datetime') %>%
        hc_yAxis(title = list(text = "Wert des Portfolios u. Ansparsumme")) %>%
        hc_tooltip(crosshairs = TRUE,
                   shared = TRUE)
      
    })

}

# Run the application 
shinyApp(ui = ui, server = server)
