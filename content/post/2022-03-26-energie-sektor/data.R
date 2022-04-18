#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Data and code for analysis of sector etfs/stocks in q1 2022 ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load R libraries and themes ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cat("\014") # Clear your console
rm(list = ls()) # Clear your environment

# Load in header file
source("/Users/jan/blog/jantau/content/post/header.R")
setwd("/Users/jan/blog/jantau/content/post/2022-03-26-energie-sektor") 

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Xtrackers sector etfs from xetra data  ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Isil of Xtrackers sector etfs 
xtracker_etfs <- c("IE00BM67HT60", "IE00BM67HK77", "IE00BM67HV82", "IE00BM67HL84", "IE00BM67HS53", "IE00BM67HR47", 
                   "IE00BM67HN09", "IE00BM67HM91", "IE00BM67HP23", "IE00BM67HQ30")

# Load xetra data from xetra etfs post
load("/Users/jan/blog/jantau/content/post/2022-02-12-die-beliebtesten-etfs-2021/xetra_df.Rdata")

# Create ticker list for yahoo.finance API 
xtracker_sector_etfs <- xetra_df %>%
  filter(isin %in% xtracker_etfs,
         month == "2021-12-31") %>%
  mutate(xetra_ticker = paste0(xetra_ticker, ".DE"))

# Query yahoo.finance API for q1 2022 data
xtracker_q1_2022 <- tq_get(xtracker_sector_etfs$xetra_ticker,
                           get  = "stock.prices",
                           from = "2021-12-29",
                           to = "2022-03-28") %>%
  group_by(symbol) %>%
  tq_transmute(select     = adjusted,
               mutate_fun = to.daily) %>%
  group_by(symbol) %>%
  mutate(adj_perc = round(adjusted/first(adjusted)-1, 3)) %>%
  ungroup() %>%
  # Enrich with xetra data
  left_join(xtracker_sector_etfs, by = c("symbol" = "xetra_ticker")) %>%
  # Shorten etf names
  mutate(etf_name = str_extract(etf_name, "(?<=World\\s).*(?=\\sUCITS)"))

# Create levels to arrange etfs according to their performance
levels <- xtracker_q1_2022 %>%
  group_by(etf_name) %>%
  filter(date == max(date)) %>%
  summarise(mean = adj_perc) %>%
  arrange(mean) %>%
  pull(etf_name)

xtracker_q1_2022 <- xtracker_q1_2022 %>%
  mutate(etf_name = factor(etf_name, levels = levels))


# Plot data
hovertext1 <-
  c(
    "<b>{etf_name}</b>
    Performance: {round(adj_perc*100, 1)} %
    {format(date, '%d. %b. %Y')}"
  )

sector_etfs <- 
  plot_ly() %>%
  add_lines(
    data = xtracker_q1_2022[xtracker_q1_2022$etf_name != "Energy",],
    x = ~ date,
    y = ~ adj_perc,
    color = ~ etf_name,
    colors = gray.colors(9, rev = TRUE),
    hoverinfo = "text",
    hovertext = ~ str_glue(hovertext1)
  ) %>%
  add_lines(
    data = xtracker_q1_2022[xtracker_q1_2022$etf_name == "Energy",],
    x = ~ date,
    y = ~ adj_perc,
    name = "Energy",
    line = list(color = "blue"),
    hoverinfo = "text",
   # hovertemplate = paste("<b>Energy</b><br>Performance: %{y}<extra></extra>"),
    hovertext = ~ str_glue(hovertext1)
  ) %>%
  layout(title = glue::glue("<span style='color: blue'>Energie-Sektor</span> vs. der Rest
                            <span style='font-size:8pt'>Sektoren-ETFs von Xtrackers MSCI World 
                            im 1. Quartal 2022</span>"),
         xaxis = list(title = FALSE),
         yaxis = list(title = "Performance Q1 2022", tickformat = ".0%"),
         legend = list(orientation = "h", traceorder = "reversed")) %>%
  config(displaylogo = FALSE, modeBarButtons = list(list("hoverClosestCartesian"), list("hoverCompareCartesian"), list("resetScale2d")))

sector_etfs
partial_bundle(sector_etfs) %>% saveWidget("sector_etfs.html", selfcontained = FALSE, libdir = "lib")


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Get data from ishares etfs to evaluate single stocks ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Ishares data for msci world
url <- "https://www.ishares.com/de/privatanleger/de/produkte/251882/ishares-msci-world-ucits-etf-acc-fund/1478358465952.ajax?fileType=csv&fileName=EUNL_holdings&dataType=fund"

# Change locale since ishares data uses european comma as decimal separator
ishares_msci_world <- read_csv(url, skip = 2, col_types = "ccccnnnnnccc", locale = locale(decimal_mark = ","))

# Use only first 10 stocks per sector
ishares_msci_world_top_10 <- ishares_msci_world %>%
  filter(!str_starts(Sektor, "Cash und")) %>%
  group_by(Sektor) %>%
  slice_head(n = 10)

# Query yahoo.finance API for q1 2022 data of single stocks
ishares_msci_world_top_10_price <- 
  tq_get(ishares_msci_world_top_10$Emittententicker,
         get  = "stock.prices",
         from = "2021-12-29",
         to = "2022-03-28") %>%
  group_by(symbol) %>%
  tq_transmute(select     = adjusted,
               mutate_fun = to.daily) %>%
  group_by(symbol) %>%
  mutate(adj_perc = round(adjusted/first(adjusted)-1, 3)) 

# Find tickers that do not work with yahoo.finance API
missing_tickers <- ishares_msci_world_top_10 %>%
  ungroup() %>%
  select(Emittententicker, Name) %>%
  left_join(ishares_msci_world_top_10_price %>% select(symbol) %>% distinct(), by = c("Emittententicker" = "symbol"), keep = TRUE) %>%
  filter(is.na(symbol))

# Change ticker if necessary with recode https://dplyr.tidyverse.org/reference/recode.html

level_key <- c("BP." = "BP.L", "BRKB" = "BRK-B", "HSBA" = "HSBA.L", "SIE" = "SIE.DE", 
               "GLEN" = "GLEN.L", "4063" = "4063.T", "NESN" = "NESN.SW", "DGE" = "DGE.L",
               "ULVR" = "ULVR.L", "IBE" = "IBE.MC", "ENEL" = "ENEL.MI", "NG." = "NG.L", 
               "7203" = "7203.T", "6758" = "6758.T")

ishares_msci_world_top_10 <- ishares_msci_world_top_10 %>%
  ungroup() %>%
  mutate(Emittententicker = recode(Emittententicker, !!!level_key))


# Join data
top_10_data <- ishares_msci_world_top_10_price %>%
  group_by(symbol) %>%
  filter(date == max(date)) %>%
  ungroup() %>%
  arrange(desc(adj_perc)) %>%
  mutate(rank = row_number()) %>%
  left_join(ishares_msci_world_top_10, by = c("symbol" = "Emittententicker")) %>%
  mutate(Sektor = fct_reorder(Sektor, adj_perc, mean))

# Plot data
hovertext <-
  c(
    "<b>{Name}</b>
    Sektor: {Sektor}
    Performance: {round(adj_perc*100, 1)} %
    Standort: {Standort}
    Gewichtung im MSCI World: {`Gewichtung (%)`} %"
  )

single_stocks <- 
  plot_ly() %>%
  add_markers(
    data = top_10_data[top_10_data$Sektor != "Energie",],
    x = ~ rank,
    y = ~ adj_perc,
    color = ~ Sektor,
    colors = gray.colors(10, rev = TRUE),
    text = ~ symbol,
    marker = list(size = 8),
    hoverinfo = "text",
    hovertext = ~ str_glue(hovertext)) %>%
  add_markers(
    data = top_10_data[top_10_data$Sektor == "Energie",],
    x = ~ rank,
    y = ~ adj_perc,
    name = "Energie",
    marker = list(color = "blue", size = 8),
    hoverinfo = "text",
    hovertext = ~ str_glue(hovertext)
  ) %>%
  layout(title = glue::glue("<span style='color: blue'>Energie-Aktien</span> vs. der Rest
                            <span style='font-size:7pt'>Top-10 Werte pro Sektor (nach Marktkap. MSCI World) 
                            im 1. Quartal 2022</span>"),
         xaxis = list(title = FALSE, zeroline = FALSE,
                      tickvals = c(1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110)),
         yaxis = list(title = "Performance Q1 2022", tickformat = ".0%"),
         legend = list(orientation = "h", traceorder = "reversed")) %>%
  config(displaylogo = FALSE, modeBarButtons = list(list("resetScale2d")))
single_stocks
partial_bundle(single_stocks) %>% saveWidget("single_stocks.html", selfcontained = FALSE, libdir = "lib")


# ,
# annotations = 
#   list(x = 0.5, y = 1, text = "Top-10 Werte im Q1 2022", 
#        showarrow = FALSE, xref='paper', yref='paper', 
#        xanchor='center', yanchor='center', xshift=0, yshift=0,
#        font=list(size=14))

hovertext <-
  c(
    "<b>{Sektor}</b>
    Gewichtung: {sum} %"
  )

sector_weight <-
  top_10_data %>%
  group_by(Sektor) %>%
  summarise(sum = sum(`Gewichtung (%)`), perc = mean(adj_perc)) %>%
  mutate(Sektor = fct_relevel(Sektor, rev)) %>%
 # arrange(desc(Sektor)) %>%
  plot_ly(x = ~Sektor,
          y = ~sum,
          marker = list(color = c(gray.colors(10, rev = TRUE), "blue")),
          hoverinfo = "text",
          hovertext = ~ str_glue(hovertext)) %>%
  add_bars() %>%
  layout(title = "Sektoren-Gewichtung im MSCI World<br><span style='font-size:8pt'>Top-10-Werte pro Sektor (nach Marktkap.)</span>",
         yaxis = list(title = "Gewichtung der Top-10-Aktien", ticksuffix = "%", zeroline = FALSE)) %>%
  config(displayModeBar = FALSE)
 
#sum(sector_weight$sum)
sector_weight
partial_bundle(sector_weight) %>% saveWidget("sector_weight.html", selfcontained = FALSE, libdir = "lib")

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# END ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
