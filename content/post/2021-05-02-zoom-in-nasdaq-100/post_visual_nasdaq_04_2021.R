#----------------------------------------------------------------------------
# Data and code for index visualizations
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Load R libraries and themes
#----------------------------------------------------------------------------
cat("\014") # Clear your console
rm(list = ls()) # Clear your environment

# Load in header file
source("/Users/jan/blog/jantau/content/post/header.R")

setwd("/Users/jan/blog/jantau/content/post/2021-05-02-zoom-in-nasdaq-100") 

#----------------------------------------------------------------------------
# Load data
#----------------------------------------------------------------------------

NASDAQ_100 <- read_excel("~/blog/Constituents_Weights_Indices.xlsx", 
                         sheet = "NASDAQ_04_2021", col_names = FALSE)

colnames(NASDAQ_100) <- c("Ticker", "Name", "Gewichtung", "Sektor", "ISIN")

NASDAQ_100$Sektor <- factor(NASDAQ_100$Sektor)

#nasdaq_all <- tq_get(NASDAQ_100[,1], 
 #               get  = "stock.prices",
  #              from = "2018-04-26",
   #             to = "2021-04-26")


# write.csv(nasdaq_all, "content/post/nasdaq_all.csv", row.names = FALSE)
nasdaq_all <- read_csv("nasdaq_all.csv")

nasdaq <- nasdaq_all

nasdaq_3_yrs <- nasdaq %>%
  select(1, 2, 8) %>%
  group_by(Ticker) %>%
  mutate(perc_3yr = (adjusted/first(adjusted)-1)*100) %>%
  slice_tail()

nasdaq_1_yrs <- nasdaq %>%
  select(1, 2, 8) %>%
  group_by(Ticker) %>%
  filter(date > "2020-04-26") %>%
  mutate(perc_1yr = (adjusted/first(adjusted)-1)*100) %>%
  slice_tail()

nasdaq_1_3_yr <- inner_join(nasdaq_1_yrs, nasdaq_3_yrs)

nasdaq_full <- left_join(nasdaq_1_3_yr, NASDAQ_100, by = "Ticker")

#----------------------------------------------------------------------------
# Create charts with highcharter
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Variables for charts
#----------------------------------------------------------------------------

caption_text <- "Datenanalyse und Visualisierung: jantau.com | Daten: finance.yahoo.com"


#----------------------------------------------------------------------------
# 1. Bubble chart
#----------------------------------------------------------------------------

# Create tooltip
x <- c("Aktie", "Gewicht. in %", "Perf. 1J in %", "Perf. 3J in %")
y <- sprintf("{point.%s}", c("Name","Gewichtung:.2f", "perc_1yr:.1f", "perc_3yr:.1f"))
tltip <- tooltip_table(x, y)


hc <- nasdaq_full %>%
  hchart(
    "scatter",
    hcaes(
      x = perc_3yr,
      y = perc_1yr,
      size = Gewichtung,
      group = Sektor
    ),
    showInLegend = TRUE,
    dataLabels = list(
      enabled = TRUE,
      format = '{point.Ticker}',
      filter = list(
        property = "Gewichtung",
        operator = ">",
        value = 0.3
      )
    ),
    minSize = 1,
    maxSize = 30
  ) %>%
  hc_title(text = "Zoom In Nasdaq 100 - Bubble Chart") %>%
  hc_subtitle(text = "5 Dimensionen: Einzelwerte, Einzelwertgewichtung, Sektorenaufteilung, 1J u. 3J Performance") %>%
  hc_caption(text = caption_text) %>%
  hc_xAxis(title = list(text = "Perf. 3J in %"),
           labels = list(format = "{value} %")) %>%
  hc_yAxis(
    min = -10,
    title = list(text = "Perf. 1J in %"),
    labels = list(format = "{value} %")
  ) %>%
  hc_tooltip(useHTML = TRUE,
             pointFormat = tltip)

saveWidget(hc, file = "nasdaq_bubble_chart.html", selfcontained = TRUE)

#----------------------------------------------------------------------------
# Correlations Test
#----------------------------------------------------------------------------


nasdaq_full %>%
  group_by(Sektor) %>%
  summarise(cor(perc_1yr, perc_3yr))

cor(nasdaq_full$perc_1yr, nasdaq_full$perc_3yr, method = "pearson")

x <- c(1,2,3,4,5,6,7,8,9,10)
y <- c(10,9,8,7,6,5,4,3,2,1)

cor(x,y, method = "spearman")

#----------------------------------------------------------------------------
# 2. Treemap
#----------------------------------------------------------------------------

x <- c("Sektor/Aktie", "Gewichtung")
y <- sprintf("{point.%s}", c("name","value:.2f"))

tltip <- tooltip_table(x, y)


hc <- hchart(
  data_to_hierarchical(
    data = nasdaq_full_bar,
    group_vars = c(Sektor, Ticker),
    size_var = Gewichtung
  ),
  type = "treemap",
  levelIsConstant = FALSE,
  animation = list(defer = 1000, duration = 0),
  allowDrillToNode = TRUE,
  #  allowTraversingTree = TRUE,
  layoutAlgorithm = "squarified",
  #levels = lvl_opts,
  levels = list(
    list(
      level = 1,
      dataLabels = list(enabled = TRUE),
      borderWidth = 4,
      colorVariation = list(key = 'brightness', to = 0.2)
    ),
    list(
      level = 2,
      dataLabels = list(enabled = FALSE),
      borderWidth = 1,
      colorVariation = list(key = 'brightness', to = 0.2)
    )
  )
) %>%
  hc_tooltip(useHTML = TRUE,
             pointFormat = tltip) %>%
  hc_title(text = "Zoom In Nasdaq 100 - Treemap Chart") %>%
  hc_subtitle(text = "3 Dimensionen: Einzelwerte, Einzelwertgewichtung, Sektorenaufteilung") %>%
  hc_caption(text = caption_text)

saveWidget(hc, file = "nasdaq_treemap_chart.html", selfcontained = TRUE)


# https://www.datacamp.com/community/tutorials/data-visualization-highcharter-r

#static treemap
#tm2 <- treemap::treemap(nasdaq_full, index = c("Sektor", "Ticker"),
#              vSize = "Gewichtung", vColor = "perc_1yr",
#              type = "value", palette = pal)


# interactive treemap without Sektor grouping

#nasdaq_full %>% # https://stackoverflow.com/questions/63145388/how-to-add-data-labels-for-a-treemap-in-highcharter-in-r
#  hchart("treemap", hcaes(name = Name, value = Gewichtung, color = perc_1yr)) %>%
#  hc_title(text = "Nasdaq 100") %>%
#  hc_subtitle(text = "Alle Werte") %>%
#  hc_chart(
#    backgroundColor = '#FFFFFF' # Chart Background Color
#  ) %>%
#  hc_exporting(enabled = TRUE,
#               filename = "Grizzlies Scoring")


#----------------------------------------------------------------------------
# 3. Barchart
#----------------------------------------------------------------------------

library(RColorBrewer)
cols <- brewer.pal(n = 9, name = "Greens") # color palette

nasdaq_full_bar <- nasdaq_full %>%
  group_by(Sektor) %>%
  mutate(sum = sum(Gewichtung)) %>%
  mutate(count = length(Sektor)) %>%
  arrange(desc(sum), desc(Gewichtung)) %>% # for ordering of chart
  ungroup() %>%
  mutate(Name = substr(Name, 1, 10)) %>% # to fit tooltip space
  mutate(coloract = colorize(x = perc_1yr, colors = cols)) # for color
# https://stackoverflow.com/questions/42443906/how-to-change-the-palette-colors-of-a-highcharter-column-plot-which-depends-on-a  


x <- c("Aktie", "Gewicht. in %", "Perf. 1J in %", "Perf. 3J in %")
y <- sprintf("{point.%s}", c("Name","Gewichtung:.2f", "perc_1yr:.1f", "perc_3yr:.1f"))

tltip <- tooltip_table(x, y)

hc <- nasdaq_full_bar %>%
  hchart(
    'bar',
    hcaes(
      x = Sektor,
      y = Gewichtung,
      color = colorize(x = perc_1yr, colors = cols)
    ),
    colorKey = "perc_1yr",
    stacking = "normal",
    showInLegend = FALSE,
    dataLabels = list(
      enabled = TRUE,
      format = '{point.Ticker}',
      filter = list(
        property = "Gewichtung",
        operator = ">",
        value = 0.5
      )
    )
  ) %>%
  hc_title(text = "Zoom In Nasdaq 100 - Bar Chart") %>%
  hc_subtitle(text = "4 Dimensionen: Einzelwerte, Einzelwertgewichtung, Sektorenaufteilung, 1J Performance") %>%
  hc_caption(text = caption_text) %>%
  hc_xAxis(title = list(text = NULL)) %>%
  hc_yAxis(title = list(text = "Anteil am Index"),
           max = 50,
           labels = list(format = "{value} %")) %>%
  hc_tooltip(
    headerFormat = as.character(tags$h4("{point.key}", tags$br())),
    pointFormat = tltip,
    useHTML = TRUE,
    # backgroundColor = "white",
    #  borderColor = "grey",
    shadow = FALSE,
    style = list(
      color = "black",
      fontSize = "0.8em",
      fontWeight = "normal"
    ),
  #  positioner = JS(
  #    "function () { return { x: this.chart.plotLeft, y: this.chart.plotRight }; }"
  #  ),
    shape = "square"
  ) %>%
  hc_colorAxis(
    min = min(nasdaq_full_bar$perc_1yr),
    max = max(nasdaq_full_bar$perc_1yr),
    stops = color_stops(length(unique(
      nasdaq_full_bar$coloract
    )), cols)
  ) %>%
  hc_legend(
    align = "right",
    verticalAlign = "top",
    layout = "vertical",
    x = 0,
    y = 100,
    title = list(text = "Perf. 1J in %")
  )

hc 

saveWidget(hc, file = "nasdaq_bar_chart.html", selfcontained = TRUE)

#----------------------------------------------------------------------------
# 3. Piechart/Sunburst
#----------------------------------------------------------------------------
pal <- got(7, option = "Daenerys", direction = -1)

nasdaq_hierarchial <- data_to_hierarchical(nasdaq_full, c(Sektor, Ticker), Gewichtung, colors = pal)

hchart(nasdaq_hierarchial, type = "sunburst", allowDrillToNode = TRUE)

hchart(nasdaq_hierarchial, type = "treemap", allowDrillToNode = TRUE)


#----------------------------------------------------------------------------
# 4. Packedbubble
#----------------------------------------------------------------------------

hc <- nasdaq_full_bar %>%
  hchart(hcaes(
    name = Ticker,
    value = Gewichtung,
    color = coloract,
    group = Sektor
  ),
  type = "packedbubble"
  #,
  #color = pal
  ) %>%
  hc_plotOptions(
    packedbubble = list(
      minSize = "10%",
      maxSize = "150%",
      zMin = 0,
      layoutAlgorithm = list(splitSeries = TRUE,
                             parentNodeLimit = TRUE),
      dataLabels = list(
        enabled = TRUE,
        format = "{point.Ticker}",
        filter = list(
          property = "Gewichtung",
          operator = ">",
          value = 1
        )
      )
    )
  ) %>%
    hc_title(text = "Zoom In Nasdaq 100 - Packed Bubble Chart") %>%
    hc_subtitle(text = "4 Dimensionen: Einzelwerte, Einzelwertgewichtung, Sektorenaufteilung, 1J Performance") %>%
    hc_caption(text = caption_text) %>%
    hc_tooltip(
      headerFormat = as.character(tags$h4("{point.key}", tags$br())),
      pointFormat = tltip,
      useHTML = TRUE,
      # backgroundColor = "white",
      #  borderColor = "grey",
      shadow = FALSE,
      #   style = list(color = "black", fontSize = "0.8em", fontWeight = "normal"),
      #  positioner = JS("function () { return { x: this.chart.plotLeft + 200, y: this.chart.plotTop + 50 }; }"),
      shape = "square"
    )
  
  saveWidget(hc, file = "nasdaq_packedbubble_chart.html", selfcontained = TRUE)
  
#----------------------------------------------------------------------------
# Traditional Line Chart for Nasdaq 100
#----------------------------------------------------------------------------
  
  
  n <-
    getSymbols("^NDX", from = Sys.Date() - years(3), auto.assign = FALSE)
  
  hc <- hchart(n, type = "line") %>%
    hc_title(text = "Konventionelle Darstellung vom Nasdaq 100") %>%
    hc_subtitle(text = "2 Dimensionen: Kursstand, 3 Jahre Zeitverlauf") %>%
    hc_caption(text = caption_text)
  
  saveWidget(hc, file = "nasdaq_line_chart.html", selfcontained = TRUE)

  
#----------------------------------------------------------------------------
# Test nested list
#----------------------------------------------------------------------------
  
  
  library(tidyverse)
  library(gapminder)
  data(gapminder, package = "gapminder")
  
  gp <- gapminder %>%
    arrange(desc(year)) %>%
    distinct(country, .keep_all = TRUE)
  
  gp2 <- gapminder %>%
    select(country, year, pop) %>% 
    nest(-country) %>%
    mutate(
      data = map(data, mutate_mapping, hcaes(x = year, y = pop), drop = TRUE),
      data = map(data, list_parse)
    ) %>%
    rename(ttdata = data)
  
  gptot <- left_join(gp, gp2, by = "country")
  
  hchart(
    gptot,
    "point",
    hcaes(lifeExp, gdpPercap, name = country, size = pop, group = continent, name = country)
  ) %>%
    hc_yAxis(type = "logarithmic") %>% 
    # here is the magic (inside the function)
    hc_tooltip(
      useHTML = TRUE,
      headerFormat = "<b>{point.key}</b>",
      pointFormatter = tooltip_chart(accesor = "ttdata")
    )  
  