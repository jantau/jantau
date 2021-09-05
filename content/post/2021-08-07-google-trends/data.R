#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Data and code for google trend analysis ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load R libraries and themes ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cat("\014") # Clear your console
rm(list = ls()) # Clear your environment

# Load in header file
source("/Users/jan/blog/jantau/content/post/header.R")
setwd("/Users/jan/blog/jantau/content/post/2021-08-07-google-trends") 

library(gtrendsR)
library(maps)
library(raster)
library(highcharter)


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Variables ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#define the keywords
keywords = "ETF"
keywords=c("nasdaq 100 etf", "dax 30 etf", "s&p 500 etf", "msci world etf")
keywords_2 = c("etf", "bitcoin", "tagesgeld", "riesterrente")
#set the geographic area: DE = Germany
country=c('DE')
#set the time window
time=("2020-02-01 2020-05-31")
#set channels 
channel='web'

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Analysis ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

ggtrendsMap <- function(keywords, time, save) {
  trends <-
    gtrends(keywords,
            gprop = channel,
            geo = country,
            time = time)
  
  region_trend <- trends$interest_by_region
  
  region_trend <- region_trend %>%
    mutate(location = replace(
      location,
      location == "Baden-Württemberg",
      "Baden-Wurttemberg"
    )) %>%
    mutate(location = paste0(location, ", DE, Germany"))
  
  save(region_trend, file = "region_trend.Rda")
  
  # mapdata <- get_data_from_map(download_map_data("countries/de/de-all"))
  
  hc <- hcmap(
    "countries/de/de-all",
    data = region_trend,
    value = "hits",
    joinBy = c("woe-label", "location"),
    name = "Test",
    dataLabels = list(enabled = TRUE, format = "{point.name}"),
    borderColor = "#FAFAFA",
    borderWidth = 0.1,
    tooltip = list(
      valueDecimals = 2,
      valuePrefix = "",
      valueSuffix = " Hits"
    ) 
  )
  
  hc <- hc %>%
    hc_title(text = paste0("Google-Suchvolumen für '", keywords, "' 2020 bis 2021")) %>%
    hc_subtitle(text = "nach Bundesländern, 100 = Max") %>%
    hc_caption(text = "Datenanalyse u. Visualisierung: jantau.com | Daten: trends.google.com") %>%
    hc_colorAxis(minColor = "#FFFFFF", maxColor = "#0F1C2A")
  
  print(hc)
  
  saveWidget(hc,
             file = paste0(save, ".html"),
             selfcontained = TRUE)
  
}

ggtrendsMap(keywords = "etf", time = "2020-01-01 2021-07-21", save = "etf")
ggtrendsMap(keywords = "msci world", time = "2020-01-01 2021-07-21", save = "msci_world") # hc_colorAxis(minColor = "#FFFFFF", maxColor = "#0F1C2A")
ggtrendsMap(keywords = "gamestop", time = "2020-01-01 2021-07-21", save = "gamestop") # hc_colorAxis(minColor = "#FFFFFF", maxColor = "#DD4433")
ggtrendsMap(keywords = "sparbuch", time = "2020-01-01 2021-07-21", save = "sparbuch") # hc_colorAxis(minColor = "#FFFFFF", maxColor = "#7C7122")


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Loop Google Search Interest----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Anlageklassen Asset Classes----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# define the keywords
keywords = c("etf", "anleihen", "bitcoin", "dividenden", "kapitallebensversicherung", "tagesgeld") #c("festgeld",, "bundesanleihen", "warren buffett", "bitcoin", "etf", "festgeld", "tagesgeld", "riesterrente")
# set the geographic area: DE = Germany
country=c('DE')
# set the time window
# time=("2020-02-01 2020-05-31")
# set channels 
channel='web'

ggtrends <- function(keywords, time, save) {
  datalist = list()
  
  for (i in 1:length(keywords)) {
    trends <-
      gtrends(
        keywords[i],
        gprop = channel,
        geo = country,
        time = time,
        onlyInterest = TRUE
      )
    
    time_trend <- trends$interest_over_time
    
    time_trend <- time_trend %>%
      mutate(hits = as.numeric(gsub("<1", "0", hits, fixed = TRUE)))
    
    datalist[[i]] <- time_trend
  }
  
  time_trends_total <- do.call(rbind, datalist)
  
  time_trends_total <- time_trends_total %>%
    mutate(keyword = factor(keyword, levels = keywords))
  
  save(time_trends_total, file = "time_trends_total.Rda")
  
  pal <- got(3, option = "Daenerys", direction = 1)
  
  plot <-
    ggplot(data = time_trends_total, aes(x = date, y = hits)) + # , col=keyword
    geom_line(color = pal[2], size = 0.3) +
    geom_area(fill = pal[2], alpha = 0.5) + # fill = "blue"
    labs(title = "Anlageklassen und Google Trends 2004 bis 2021",
         subtitle = "Volumen von Google-Suchen für verschiedene Anlageklassen (Suchen in DE, 100 = Max, \nY-Achsen zeigen jeweiligen Höhepunkt des Suchbegriffs und sind nicht vergleichbar)",
         caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: trends.google.com") +
    theme_jantau +
    theme(
      legend.position = "none",
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      plot.subtitle = element_text(
        size = 8,
        hjust = 0,
        color = "darkgrey"
      ),
      strip.background = element_rect(fill = "white"),
      panel.grid.major.y = element_line(colour = "grey", size = 0.1)
    ) +
    facet_wrap(~ keyword)
  
  print(plot)
  
  ggsave(paste0(save, ".png"), scale = .75)
  
}


assetklassen <- c("Aktien", "Anleihen", "Bitcoin", "Immobilien", "Rohstoffe", "Tagesgeld")
assetklassen <- c("Anleihen", "Bitcoin", "Gold", "ETF", "Immobilienfonds", "Tagesgeld")
assetklassen <- c("Anleihen", "Bitcoin", "Gold", "ETF", "Immobilien", "Tagesgeld")

ggtrends(keywords = assetklassen, time = "all", save = "assetklassen")





#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# FANG+M----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



ggtrends <- function(keywords, time, save) {
  datalist = list()
  
  for (i in 1:length(keywords)) {
    trends <-
      gtrends(
        keywords[i],
        gprop = channel,
        geo = country,
        time = time,
        onlyInterest = TRUE
      )
    
    time_trend <- trends$interest_over_time
    
    time_trend <- time_trend %>%
      mutate(hits = as.numeric(gsub("<1", "0", hits, fixed = TRUE)))
    
    datalist[[i]] <- time_trend
  }
  
  time_trends_total <- do.call(rbind, datalist)
  
  time_trends_total <- time_trends_total %>%
    mutate(keyword = factor(keyword, levels = keywords))
  
  save(time_trends_total, file = "time_trends_total.Rda")
  
  fang_colors <-
    c("#4267B2",
      "#FF9900",
      "#000000",
      "#E50914",
      "#4285F4",
      "#F25022") # https://usbrandcolors.com/amazon-colors/
  
  plot <-
    ggplot(data = time_trends_total, aes(
      x = date,
      y = hits,
      color = keyword,
      fill = keyword
    )) + # , col=keyword
    geom_line(size = 0.3) +
    geom_area(alpha = 0.5) + # fill = "blue"
    scale_color_manual(values = fang_colors) +
    scale_fill_manual(values = fang_colors) +
    labs(title = "FAANG+M-Unternehmen in Google Trends 2004 bis 2021",
         subtitle = "Volumen von Google-Suchen für FAANG+M-Unternehmen (Suchen in DE, 100 = Max, \nY-Achsen zeigen jeweiligen Höhepunkt des Suchbegriffs und sind nicht vergleichbar)",
         caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: trends.google.com") +
    theme_jantau +
    theme(
      legend.position = "none",
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      plot.subtitle = element_text(
        size = 8,
        hjust = 0,
        color = "darkgrey"
      ),
      strip.background = element_rect(fill = "white"),
      panel.grid.major.y = element_line(colour = "grey", size = 0.1)
    ) +
    facet_wrap(~ keyword)
  
  print(plot)
  
  ggsave(paste0(save, ".png"), scale = .75)
  
}

fangm <- c("AAPL", "AMZN", "FB", "GOOG", "MSFT", "NFLX")  
fangm <-
  c("facebook", "amazon", "apple", "netflix", "google", "microsoft")  
fangm <- c("facebook aktie", "amazon aktie", "apple aktie", "google aktie", "netflix aktie", "microsoft aktie")  
dax6 <- c("sap aktie", "linde aktie", "volkswagen aktie", "siemens aktie", "deutsche telekom", "merck aktie")  

ggtrends(keywords = fangm, time = "2017-01-01 2017-12-31", save = "FANG+M_2")
ggtrends(keywords = fangm, time = "all", save = "FANG+M_company")
ggtrends(keywords = fangm, time = "all", save = "FANG+M_stock")
ggtrends(keywords = dax6, time = "all", save = "dax6")









ggplot(data = time_trends_total, aes(x = date, xend = date, y = hits, yend = 0)) + # , col=keyword
  geom_line(color = pal[2], size = 0.3) +
  geom_area(fill = pal[2], alpha = 0.5) + # fill = "blue"
  scale_color_gradient(low = pal[1], high = pal[2]) +
#  scale_fill_gradient2(low = "blue", mid = muted("blue"), high = "red", midpoint = median(time_trends_total$hits)) +
  xlab('Time') +
  ylab('Relative Interest') + 
  theme_jantau +
  theme(legend.position = "none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank()) +
  ggtitle("Google Search Volume") +
  facet_wrap(~ keyword)


# DUMP

df$Label <- paste0(df$Label, ":00")
statesMap <- ggplot2::map_data(map = "world")
germany <- getData(country = "Germany", level = 1) 

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# CAGR ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
load("time_trends_total.Rda")
as.numeric(difftime(as.Date("2021-08-01"), as.Date("2004-01-01"), unit="weeks"))/52.25


( Ending value / Beginning value ) ^ ( 1 / Number of years ) - 1

# Gold Google
( ( 83 / 30 ) ^ ( 1 / 17.55844 ) - 1 ) * 100
# CAGR = 5,96 %

# Gold Price
( ( 1535 / 330 ) ^ ( 1 / 17.55844 ) - 1 ) * 100
# CAGR 9,14




#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# End ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


ggplot(data = time_trends_total, aes(x = date, y = hits)) + # , col=keyword
  geom_line(color = pal[2], size = 0.3) +
  geom_area(fill = pal[2], alpha = 0.5) + # fill = "blue"
  labs(title = "Trends von Assetklassen über die Jahre",
       subtitle = "Volumen von Google-Suchen für verschiedene Assetklassen (Suchen in DE, 100 = Max, \nY-Achsen zeigen jeweiligen Höhepunkt des Suchbegriffs und sind nicht vergleichbar)",
       caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: trends.google.com") +
  theme_jantau +
  theme(
    legend.position = "none",
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    plot.subtitle = element_text(
      size = 8,
      hjust = 0,
      color = "darkgrey"
    ),
    strip.background = element_rect(fill="white"),
    panel.grid.major.y = element_line(colour = "grey", size = 0.1)
  ) +
  facet_wrap( ~ keyword)
