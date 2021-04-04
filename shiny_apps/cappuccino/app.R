library(directlabels)
library(gameofthrones) # farbpaletten
library(ggrepel)
library(ggtext)
library(lubridate)
library(scales)
library(shiny)
library(stringr)
library(tidyquant)
library(tidyverse)
library(xts)

theme_jantau <- theme(
  plot.title       = element_text(
    size = 14,
    face = "bold",
    hjust = 0.5,
    margin = ggplot2::margin(0, 0, 10, 0)
  ),
  plot.subtitle       = element_text(
    size = 10,
    face = "bold",
    hjust = 0.5,
    margin = ggplot2::margin(0, 0, 10, 0)
  ),
  axis.title.y     = element_text(
    face = "bold",
    size = 10,
    margin = ggplot2::margin(0, 10, 0, 0)
  ),
  axis.text.y      = element_text(color = "black"),
  axis.ticks.y     = element_line(color = "black"),
  axis.text.x      = element_text(color = "black"),
  axis.ticks.x     = element_line(color = "grey", size = 1.5),
  axis.title.x     = element_text(
    face = "bold",
    size = 10,
    margin = ggplot2::margin(10, 0, 0, 0)
  ),
  axis.line.x      = element_line(color = "grey", size = 1.3),
  axis.line.y      = element_line(color = "grey", size = 1.3),
  legend.key       = element_blank(),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  panel.border     = element_blank(),
  panel.background = element_blank(),
  plot.caption     = element_text(hjust = 0,
                                  size = 8)
)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Konsum-Asset-Rechner"),
    h5(tags$a(href = "https://www.jantau.com/", "jantau.com")),

    # Sidebar
    sidebarLayout(
        sidebarPanel(
            radioButtons(
                "liability",
                label = "Konsum",
                choices = list(
                    "Cappuccino (3 €)" = 3,
                    "iPhone (900 €)" = 900,
                    "Auto (15000 €)" = 15000
                ),
                selected = 3
            ),
            
            radioButtons(
                "index",
                label = "Asset",
                choices = list(
                  "S&P 500 TR (10.1 % Annualized Total Return 1990 bis 2020)" = 10.1,
                    "Dax 30 (6.8 % Annualized Total Return 1990 bis 2020)" = 6.8
                ),
                selected = 10.1
            ),
            
            sliderInput("inflation", 
                        "⌀ Inflation pro Jahr (1990 bis 2020 ⌀ 1.8 %)",
                        min = 0, max = 8,
                        value = 1.8, step = 0.1,
                        post = " %"
                        ),
            
            sliderInput("ter", 
                        "⌀ Gebühr pro Jahr",
                        min = 0, max = 2,
                        value = 0.2, step = 0.1,
                        post = " %"
            ),
            
            HTML('<p>Den für diese Web App erstellten Code findest du hier: <a href="https://github.com/jantau/jantau/tree/main/shiny_apps">https://github.com/jantau/jantau</a></p>'),
        ),
        
        # Show plot and text
        mainPanel(plotOutput("distPlot"))
    )
)


# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$distPlot <- renderPlot({
        
        pal <- got(3, option = "Daenerys", direction = 1)
        
        if (input$liability == "3") {
          title_variable <- "Cappuccino"
        } else if (input$liability == "900") {
          title_variable <- "neues iPhone"
        } else
          title_variable <- "gebrauchtes Auto"
        
        liability <- as.numeric(input$liability)
        index <- as.numeric(input$index)
        
        annual_rate <- index - input$inflation - input$ter
        
        #  annual_rate <- 4
        #   liability <- 2.5
        
        # Compound interest
        ten <- liability * (1 + annual_rate / 100) ^ 10
        twenty <- liability * (1 + annual_rate / 100) ^ 20
        thirty <- liability * (1 + annual_rate / 100) ^ 30
        fourty <- liability * (1 + annual_rate / 100) ^ 40
        
        dat <- data.frame(
          years = factor(
            c("heute", "nach 10", "20", "30", "40 Jahren"),
            levels = c("heute", "nach 10", "20", "30", "40 Jahren")
          ),
          asset = c(0, ten, twenty, thirty, fourty),
          liability = c(liability, 0, 0, 0, 0)
        )
        
        dat <-
          dat %>% pivot_longer(cols = c(asset, liability)) %>% mutate(name = factor(name, levels = c("liability", "asset")))
        
        # create plot
        ggplot(data = dat, aes(x = years, y = value, fill = name)) +
          geom_col(position = "identity") +
          scale_fill_manual(values = c(pal[1], pal[2])) +
          theme_jantau +
          theme(
            axis.title.x = element_blank(),
            axis.text.x = element_text(size = 20,),
            axis.title.y = element_blank(),
            axis.ticks.y = element_blank(),
            axis.line.y = element_blank(),
            axis.text.y = element_blank(),
            legend.position = "none",
            plot.title = element_markdown(size = 30)
          ) +
          geom_label(
            data = dat %>% filter(value > 0),
            aes(
              x = years,
              y = value,
              label = paste0(format(round(value, 0), big.mark = " "), " €")
            ),
            color = "white",
            size = 5
          ) +
          labs(
            title = paste0(
              "Ein ",
              title_variable,
              "!<br><span style='color:#792427;'>Konsum</span> oder <span style='color:#2B818E;'>Asset</span>?"
            ),
            subtitle = paste0(
              "inflationsbereinigt um jährl. ",
              input$inflation ,
              " % und inkl. jährl. Gebühr von ",
              input$ter,
              " %"
            ),
            caption = "Datenanalyse u. Visualisierung: jantau.com"
          )
    })
}

# Run the application
shinyApp(ui = ui, server = server)


