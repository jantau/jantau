# Find out more about building applications with Shiny here:
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(scales)
library(xts)
library(lubridate)
library(stringr)
library(gameofthrones) # farbpaletten
library(tidyquant)
library(directlabels)
library(ggrepel)

# Preparation of stationary data
# index_archive <- tq_get(c("^SP500TR", "^NDX", "^GDAXI"),
#                get  = "stock.prices",
#                from = "1990-01-01",
#                to = "2020-12-31")

# write.csv(index_archive,"shiny_apps/ter_surcharge/data/index_archive.csv", row.names = FALSE)

# Load data
index_archive <- read_csv(file = "data/index_archive.csv")

index_new <- tq_get(
    c("^SP500TR", "^NDX", "^GDAXI"),
    get  = "stock.prices",
    from = "2021-01-01",
    to = Sys.Date()
)

index <- rbind(index_archive, index_new) %>%
    drop_na()

index <- index %>%
    group_by(symbol) %>%
    arrange(date, .by_group = TRUE)

index <- index %>%
    select(1, 2, 8) %>%
    mutate(year = year(date)) %>%
    mutate(month = as.factor(month(date))) %>%
    mutate(year_mon = floor_date(date, "month")) %>%
    distinct(symbol, year_mon, .keep_all = T) %>%
    select(1, 2, 3)

pal <- got(2, option = "Daenerys", direction = 1)

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

# Define UI for application
ui <- fluidPage(
    # Application title
    titlePanel("Auswirkungen von Verwaltungs- und Ordergebühren auf die Rendite"),
    
    # Sidebar
    sidebarLayout(
        sidebarPanel(
            radioButtons(
                "radio",
                label = "Index",
                choices = list(
                    "S&P 500 TR" = "^SP500TR",
                    "NASDAQ 100" = "^NDX",
                    "Dax 30" = "^GDAXI"
                ),
                selected = "^SP500TR"
            ),
            
            numericInput(
                "savings",
                "Monatliche Einzahlung",
                min = 0,
                max = 10000,
                step = 1,
                value = 100
            ),
            
            numericInput(
                "one_time",
                "Einmalige Einzahlung",
                min = 0,
                max = 1000000,
                step = 1,
                value = 0
            ),
            
            numericInput(
                "ter",
                "Jährl. Verwaltungsgebühr (TER) oder Tracking Error in %",
                min = -15,
                max = 15,
                step = 0.01,
                value = 0.5
            ),
            
            numericInput(
                "bins",
                "Ordergebühren in %",
                min = 0,
                max = 50,
                step = 0.1,
                value = 1.5
            ),
            
            dateRangeInput(
                "dateRange",
                label = "Zeitraum",
                start = "2010-01-01",
                end = Sys.Date(),
                min = "1990-01-01",
                max = Sys.Date(),
                separator = " - ",
                startview = "year",
                weekstart = 1
            )
            # dateRangeInput results in Vector with two values
        ),
        
        # Show plot and text
        mainPanel(plotOutput("distPlot"),
                  verbatimTextOutput("result"))
    )
)


# Define server logic
server <- function(input, output) {
    output$distPlot <- renderPlot({
        net_savings_rate <- input$savings * ((100 - input$bins) / 100)
        net_one_time <- input$one_time * ((100 - input$bins) / 100)
        
        ter_month <- input$ter / 100 / 12
        
        index <- index %>%
            filter(symbol == input$radio) %>%
            filter(date >= input$dateRange[1] &
                       date <= input$dateRange[2])
        
        index_2 <- index %>%
            mutate(anteil_one_time = net_one_time/adjusted) %>%
            mutate(wert_one_time = first(anteil_one_time)*adjusted) %>%
            
            mutate(anteil_one_time_pure = input$one_time/adjusted) %>%
            mutate(wert_one_time_pure = first(anteil_one_time_pure)*adjusted) %>%
            
            mutate(anteil = net_savings_rate / adjusted) %>%
            mutate(anteil_cumsum = cumsum(anteil)) %>%
            mutate(wert = (anteil_cumsum * adjusted) + wert_one_time) %>%
            
            mutate(anteil_pure = input$savings / adjusted) %>%
            mutate(anteil_cumsum_pure = cumsum(anteil_pure)) %>%
            mutate(wert_pure = (anteil_cumsum_pure * adjusted) + wert_one_time_pure) %>%
            
            mutate(ansparen = input$savings) %>%
            mutate(ansparen_cumsum = cumsum(ansparen) + net_one_time)
        
        index_2[1, "wert_ter2"] <-
            ((net_savings_rate + net_one_time) * (1 - ter_month))
        
        for (i in 2:nrow(index_2)) {
            index_2[i, "wert_ter2"] <-
                (((index_2[i - 1, "wert_ter2"] / index_2[i - 1, "adjusted"]) + (net_savings_rate /
                                                                                    index_2[i, "adjusted"])
                ) * index_2[i, "adjusted"]) * (1 - ter_month)
        }
        
        ggplot(data = index_2) +
            geom_area(aes(
                x = date,
                y = ansparen_cumsum,
                fill = "Ansparsumme"
            ),
            alpha = 0.5) +
            
            geom_line(aes(
                x = date,
                y = wert_pure,
                color = "Betrag vor Kosten"
            ),
            size = 1) +
            geom_line(aes(
                x = date,
                y = wert_ter2,
                color = "Betrag nach Kosten"
            ),
            size = 1) +
            geom_ribbon(
                aes(
                    x = date,
                    ymin = wert_ter2,
                    ymax = wert_pure,
                    fill = "Differenz vor u. nach Kosten"
                ),
                alpha = 0.3
            ) +
            
            scale_color_manual(values = c(pal[1], pal[2])) +
            scale_fill_manual(values = c("grey", pal[1])) +
            guides(color = guide_legend(order = 1, reverse = TRUE)) +
            guides(fill = guide_legend(order = 2, reverse = TRUE)) +
            scale_y_continuous(labels = dollar_format(
                big.mark = " ",
                decimal.mark = ",",
                suffix = "",
                prefix = ""
            )) +
            theme_jantau +
            labs(title = paste0("Performance ", input$radio),
                 caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com") +
            theme(
                axis.title.x = element_blank(),
                axis.title.y = element_blank(),
                axis.ticks.y = element_blank(),
                axis.line.y = element_blank(),
                panel.grid.major.y = element_line(
                    colour = "grey",
                    size = 0.3,
                    linetype = "dashed"
                ),
                legend.position = "top",
                legend.title = element_blank(),
                #    legend.spacing = unit(-.2, "cm"), # legend.box.background = element_rect(colour = "grey"),
                axis.text.x = element_text(size = 12),
                axis.text.y = element_text(
                    hjust = 0,
                    vjust = -0.7,
                    margin = margin(l = 20, r = -45),
                    size = 12
                )
            )
    })
    
    output$result <- renderText({
        net_savings_rate <- input$savings * ((100 - input$bins) / 100)
        net_one_time <- input$one_time * ((100 - input$bins) / 100)
        
        ter_month <- input$ter / 100 / 12
        
        index <- index %>%
            filter(symbol == input$radio) %>%
            filter(date >= input$dateRange[1] &
                       date <= input$dateRange[2])
        
        index_2 <- index %>%
            mutate(anteil_one_time = net_one_time/adjusted) %>%
            mutate(wert_one_time = first(anteil_one_time)*adjusted) %>%
            
            mutate(anteil_one_time_pure = input$one_time/adjusted) %>%
            mutate(wert_one_time_pure = first(anteil_one_time_pure)*adjusted) %>%
            
            mutate(anteil = net_savings_rate / adjusted) %>%
            mutate(anteil_cumsum = cumsum(anteil)) %>%
            mutate(wert = (anteil_cumsum * adjusted) + wert_one_time) %>%
            
            mutate(anteil_pure = input$savings / adjusted) %>%
            mutate(anteil_cumsum_pure = cumsum(anteil_pure)) %>%
            mutate(wert_pure = (anteil_cumsum_pure * adjusted) + wert_one_time_pure) %>%
            
            mutate(ansparen = input$savings) %>%
            mutate(ansparen_cumsum = cumsum(ansparen) + net_one_time)
        
        index_2[1, "wert_ter2"] <-
            ((net_savings_rate + net_one_time) * (1 - ter_month))
        
        for (i in 2:nrow(index_2)) {
            index_2[i, "wert_ter2"] <-
                (((index_2[i - 1, "wert_ter2"] / index_2[i - 1, "adjusted"]) + (net_savings_rate /
                                                                                    index_2[i, "adjusted"])
                ) * index_2[i, "adjusted"]) * (1 - ter_month)
        }
        
        
        performance_loss <- round((1 - (
            last(index_2$wert_ter2) - last(index_2$ansparen_cumsum)
        ) / (
            last(index_2$wert_pure) - last(index_2$ansparen_cumsum)
        )) * 100, 2)
        
        performance_loss[performance_loss < 0] <- "NA"
        
        paste0(
            "Ergebnis\n",
            last(index_2$ansparen_cumsum),
            "\tAnsparsumme\n",
            round(last(index_2$wert_pure), 0),
            "\tEndbetrag vor Verwaltungs- und Ordergebühren\n",
            #     round((last(index_2$wert_pure) / last(index_2$ansparen_cumsum) - 1) * 100, 0), " %",
            #    "\tPerformance vor Verwaltungs- und Ordergebühren\n",
            round(last(index_2$wert_ter2), 0),
            "\tEndbetrag nach Verwaltungs- und Ordergebühren\n",
            #    round((last(index_2$wert_ter2) / last(index_2$ansparen_cumsum) - 1) * 100, 0), " %",
            #   "\tPerformance nach Verwaltungs- und Ordergebühren\n",
            round(last(index_2$wert_pure) - last(index_2$wert_ter2),
                  0),
            "\tVerwaltungs- und Ordergebühren\n",
            round((
                1 - last(index_2$wert_ter2) / last(index_2$wert_pure)
            ) * 100, 2),
            " %",
            "\tVerwaltungs- und Ordergebühren in % vom Endbetrag\n",
            performance_loss,
            " %",
            "\tRenditeverlust in % (Endbetrag - Ansparsumme)"
        )
    })
}

# Run the application
shinyApp(ui = ui, server = server)
