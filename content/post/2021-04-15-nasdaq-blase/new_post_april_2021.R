#----------------------------------------------------------------------------
# Nasdaq-Blase?
#----------------------------------------------------------------------------

cat("\014") # Clear console
rm(list = ls()) # Clear environment

source("/Users/jan/blog/jantau/content/post/header.R") # Load in header file

#----------------------------------------------------------------------------
# Load date from finance.yahoo.com
#----------------------------------------------------------------------------

index <- tq_get(c("^GDAXI", "^NDX", "^SP500TR"),
              get  = "stock.prices",
              from = "1995-01-01",
              to = Sys.Date())

#----------------------------------------------------------------------------
# Define date variables
#----------------------------------------------------------------------------

today <- Sys.Date() # Today
today_minus_5y <- today - years(5) # Today minus 5 years

financial_crisis <- date("2007-10-31") # Financial crisis
financial_crisis_minus_5y <- financial_crisis - years(5)

dotcom_bubble <- date("2000-03-27") # Dotcom Bubble
dotcom_bubble_minus_5y <- dotcom_bubble - years(5)

#----------------------------------------------------------------------------
# Filter date ranges and transform data
#----------------------------------------------------------------------------

index_filter <- index %>%
  group_by(symbol) %>%
  drop_na() %>%
  select(1, 2, 8) %>%
  filter(
    between(date, dotcom_bubble_minus_5y, dotcom_bubble) |
      between(date, financial_crisis_minus_5y, financial_crisis) |
      between(date, today_minus_5y, today)
  ) %>%
  ungroup() %>%
  mutate(
    index = case_when(
      symbol == "^GDAXI"  ~ "Dax 30",
      symbol == "^NDX"  ~ "NASDAQ 100",
      symbol == "^SP500TR"  ~ "S&P 500 TR",
    ),
    .after = symbol
  ) %>%
  mutate(
    period = case_when(
      between(date, dotcom_bubble_minus_5y, dotcom_bubble)  ~ "Dotcom-Blase",
      between(date, financial_crisis_minus_5y, financial_crisis)  ~ "Finanzkrise",
      between(date, today_minus_5y, today)  ~ "heute",
    ),
    .after = index
  ) %>%
  mutate(period_index = paste0(index, " vor ", period),
         .after = period) %>%
  group_by(period_index) %>%
  mutate(normalized = (adjusted / first(adjusted) - 1) * 100)

#----------------------------------------------------------------------------
# Create hc plots
#----------------------------------------------------------------------------

ndx_periods <- index_filter %>%
  filter(symbol == "^NDX") %>%
  hchart( "line", hcaes(x = date, y = normalized, group = period_index),
          tooltip = list(pointFormat = "<br>{point.period_index}<br>Kursstand: {point.adjusted:.0f}<br>Performance: <b>{point.normalized:.1f} %</b>"))

ndx_periods <- ndx_periods %>%
  hc_title(text = "%-Performance NASDAQ 100<br> 5 Jahre vor Dotcom-Blase, Finanzkrise und heute") %>%
  hc_caption(text = "Datenanalyse u. Visualisierung: <a href='https://finance.yahoo.com'>jantau.com</a> | Daten: <a href='https://www.jantau.com'>finance.yahoo.com</a>") %>%
  hc_xAxis(
    title = list(text = NULL),
    plotLines = list(
      list(
        label = list(text = "Höchststand vor Dotcom-Blase"),
        color = "#F0F0F0",
        width = 2,
        # value has to be timestamp https://stackoverflow.com/questions/41573626/highcharter-plotbands-plotlines-with-time-series-data
        value = datetime_to_timestamp(dotcom_bubble),
        # the zIndex is used to put the label text over the grid lines 
        zIndex = 1
      ),
      list(
        label = list(text = "Höchststand vor Finanzkrise"),
        color = "#F0F0F0",
        width = 2,
        # value has to be timestamp https://stackoverflow.com/questions/41573626/highcharter-plotbands-plotlines-with-time-series-data
        value = datetime_to_timestamp(financial_crisis),
        # the zIndex is used to put the label text over the grid lines 
        zIndex = 1
      ),
      list(
        label = list(text = "Stand 16. April 2021"),
        color = "#F0F0F0",
        width = 2,
        # value has to be timestamp https://stackoverflow.com/questions/41573626/highcharter-plotbands-plotlines-with-time-series-data
        value = datetime_to_timestamp(today),
        # the zIndex is used to put the label text over the grid lines 
        zIndex = 1
      )
    )
  ) %>%
  hc_yAxis(
    min = -50,
    title = list(text = "Performance"),
    labels = list(format = "{value} %"))


ndx_1995_today <- index %>%
  filter(symbol == "^NDX") %>%
  mutate(symbol = "NASDAQ 100") %>%
  hchart(
    "line",
    hcaes(x = date, y = adjusted),
    tooltip = list(pointFormat = "<br>{point.symbol}<br>Kursstand: <b>{point.adjusted:.0f}</b>")
  )

ndx_1995_today <- ndx_1995_today %>%
  hc_title(text = "Kursentwicklung NASDAQ 100<br>1995 bis heute") %>%
  hc_caption(text = "Datenanalyse u. Visualisierung: <a href='https://finance.yahoo.com'>jantau.com</a> | Daten: <a href='https://www.jantau.com'>finance.yahoo.com</a>") %>%
  hc_xAxis(title = list(text = NULL),
           plotLines = list(
             list(
               label = list(text = "Höchststand vor Dotcom-Blase", rotation = 0),
               color = "#F0F0F0",
               width = 2,
               # value has to be timestamp https://stackoverflow.com/questions/41573626/highcharter-plotbands-plotlines-with-time-series-data
               value = datetime_to_timestamp(dotcom_bubble),
               # the zIndex is used to put the label text over the grid lines 
               zIndex = 1
             ))) %>%
  hc_yAxis(title = list(text = "Kursstand"))
  
ndx_1995_today  
  
ndx_1995_today_log <-
  ndx_1995_today %>% hc_yAxis(type = "logarithmic") %>%
  hc_title(text = "Kursentwicklung NASDAQ 100<br>1995 bis heute<br>logarithmische Darstellung")

ndx_1995_today_log

#----------------------------------------------------------------------------
# Save plots as html files
#----------------------------------------------------------------------------
saveWidget(ndx_periods, file = "content/post/2021-04-15-nasdaq-blase/ndx_periods.html", selfcontained = TRUE)
saveWidget(ndx_1995_today, file = "content/post/2021-04-15-nasdaq-blase/ndx_1995_today.html", selfcontained = TRUE)
saveWidget(ndx_1995_today_log, file = "content/post/2021-04-15-nasdaq-blase/ndx_1995_today_logs.html", selfcontained = TRUE)


#----------------------------------------------------------------------------
# Calculate CAGRs # https://www.investopedia.com/terms/c/cagr.asp
#----------------------------------------------------------------------------

# CAGR Nasdaq 1995 bis 2020
# (12738/398)^(1/26)-1 = 0.1425968

# CAGR Nasdaq vor Dotcom-Blase
# (4705/457)^(1/5)-1 = 0.5941482

# CAGR Nasdaq vor Finanzkrise
# (2239/990)^(1/5)-1 = 0.1772909

# CAGR Nasdaq vor heute
# (14042/4569)^(1/5)-1 = 0.2517614
