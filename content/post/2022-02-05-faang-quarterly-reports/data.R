#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Data and code for analysis of faang quarterly reports ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load R libraries and themes ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cat("\014") # Clear your console
rm(list = ls()) # Clear your environment

# Load in header file
source("/Users/jan/blog/jantau/content/post/header.R")
setwd("/Users/jan/blog/jantau/content/post/2022-02-05-faang-quarterly-reports") 

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Web scraping ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Tutorial
# https://towardsdatascience.com/tidy-web-scraping-in-r-tutorial-and-resources-ac9f72b4fe47?gi=bbadd5a4567f

library(tidyverse)
library(lubridate)

library(rvest)
library(xml2)

library(tidyquant)

library(plotly)
library(htmlwidgets)

# 1. open website with google chrome
# 2. inspect
# 3. find <table class...>
# 4. copy selector

# Attention: incorrect earnings dates
# faang_earnings = data.frame()
# for (i in seq(faang)) {
#   
#   earnings_table <- paste0("https://www.marketbeat.com/stocks/NASDAQ/", faang[i], "/earnings/") %>% 
#     read_html() %>% 
#     html_element(css = "#earnings-history") %>%
#     html_table() %>%
#     mutate(symbol = faang[i])
#   
#   faang_earnings <- rbind(faang_earnings, earnings_table)
#   
# }

faang <- c("FB", "AAPL", "AMZN", "NFLX", "GOOG")

datalist_stock = list()
datalist_faang = list()

for (f in seq(faang)) {
  ycharts_page <-
    paste0("https://ycharts.com/companies/", faang[f], "/events/")
  
  for (i in 1:5) {
    ycharts_data <- paste0(ycharts_page, i) %>%
      read_html() %>%
      html_element(css = "#eventsSubTabs > div > div > table") %>%
      html_table() %>%
      mutate(symbol = faang[f])
    
    datalist_stock[[i]] <- ycharts_data
  }
  datalist_faang[[f]] <- bind_rows(datalist_stock)
}  
  
faang_earnings <- bind_rows(datalist_faang)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Data cleaning ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

faang_earnings_clean <- faang_earnings %>%
  select(date = X1, time = X2, symbol) %>%
  filter(!str_detect(date, "^.*[A-Za-z].*$")) %>%
  mutate(date = lubridate::mdy(date)) %>%
  filter(date >= "2012-06-30" & date <= "2022-03-30") %>%
  arrange(desc(date), symbol, desc(time)) %>%
  group_by(symbol) %>%
  distinct(date, .keep_all = TRUE) %>%
  ungroup() %>%
  mutate(year = year(date)) %>%
  mutate(quarter = quarter(date) - 1) %>%
  mutate(quarter = case_when(quarter == 0 ~ 4,
                             TRUE ~ quarter)) %>%
  mutate(year = case_when(quarter == 4 ~ year - 1,
                          TRUE ~ year)) %>%
  complete(year, quarter, symbol) %>%
  filter(year != 2012 | quarter != 1) %>%
  mutate(date = date + 1) %>%
  mutate(quarter_year_order = paste0(year, "—Q", quarter)) %>%
  mutate(quarter_year = paste0("Q", quarter, "—`", year-2000)) %>%
  mutate(quarter_year = fct_reorder(quarter_year, quarter_year_order, min)) 

  
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Get stock data ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  

faang_stock <- tq_get(faang,
                     get  = "stock.prices",
                     from = "2008-01-01",
                     to = Sys.Date()) 

faang_stock_daily_perc <- faang_stock %>%
  group_by(symbol) %>%
  select(symbol, date, open, high, close) %>%
  mutate(perc = round(open/lag(close) - 1, 3)) %>%
  mutate(perc_intra = round(close/open - 1, 3))

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Combine data ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

faang_data <- faang_earnings_clean %>%
  left_join(faang_stock_daily_perc, by = c("date", "symbol")) %>%
  mutate(symbol = factor(symbol, levels = faang)) %>% 
  mutate(perc = round(perc, 4)) %>%
  group_by(quarter_year) %>%
  mutate(min = min(perc, na.rm = TRUE), max = max(perc, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(perc = replace_na(perc, 0)) %>%
  mutate(perc_2 = case_when(time %in% c("13:05 EST", "13:30 EST", "14:00 EST") ~ perc_intra,
                            TRUE ~ perc)) %>%
  mutate(axis_labels = case_when(quarter == 4 ~ paste0(year, "—Q", quarter),
                                 TRUE ~ paste0("Q", quarter))) 
  

faang_data_mean <- faang_data %>%
  group_by(quarter_year) %>%
  summarise(mean = mean(perc, na.rm = TRUE), sd = sd(perc))

faang_quarter_mean <- faang_data %>%
  group_by(quarter) %>%
  summarise(mean = round(mean(perc, na.rm = TRUE), 3) * 100, sd = round(sd(perc, na.rm = TRUE), 3) * 100)

faang_symbol_mean <- faang_data %>%
  group_by(symbol) %>%
  summarise(mean = round(mean(perc, na.rm = TRUE), 3) * 100, sd = round(sd(perc), 3) * 100)

faang_earnings_mean <- faang_data %>%
  summarise(mean = mean(perc, na.rm = TRUE) * 100, sd = sd(perc, na.rm = TRUE) * 100)

faang_mean <- faang_stock_daily_perc %>%
  filter(date >= "2012-06-30" & date <= "2022-03-30") %>%
  ungroup() %>%
  summarise(mean = mean(perc, na.rm = TRUE) * 100, sd = sd(perc) * 100)

earnings_days <- faang_data %>% distinct(date) %>% drop_na() %>% pull(date)

faang_mean_wo_earnings <- faang_stock_daily_perc %>%
  filter(date >= "2012-06-30" & date <= "2022-03-30") %>%
  filter(!date %in% earnings_days) %>%
  ungroup() %>%
  summarise(mean = mean(perc, na.rm = TRUE) * 100, sd = sd(perc) * 100)


test <- faang_data %>%
  group_by(quarter_year, symbol) %>%
  summarise(mean = mean(perc, na.rm = TRUE))

faang_data %>%
  group_by(quarter_year, symbol) %>%
  summarise(mean = mean(perc, na.rm = TRUE)) %>%
  group_by(symbol) %>%
  count(good = mean >= 0.05, bad = mean <= -0.05, middle = mean < 0.05 & mean > -0.5 )

test <- faang_data %>%
  group_by(quarter_year, symbol) %>%
  summarise(mean = mean(perc, na.rm = TRUE)) %>%
  group_by(symbol, group = cut(mean, breaks = seq(-0.35, 0.45, 0.1))) %>%
  summarise(n = n())

test_2 <- faang_data %>%
  group_by(quarter_year, symbol) %>%
  summarise(mean = mean(perc, na.rm = TRUE)) %>%
  group_by(symbol, group = cut(mean, breaks = seq(-0.015, 0.015, 0.03))) %>%
  summarise(n = n())

test_2 <- faang_data %>%
  group_by(quarter_year) %>%
  summarise(mean = mean(perc, na.rm = TRUE)) %>%
  group_by(group = cut(mean, breaks = seq(-0.015, 0.015, 0.03))) %>%
  summarise(n = n())

faang_colors <-
  c("#4267B2",
    "#000000",
    "#FF9900",
    "#E50914",
    "#4285F4") %>% # "#F25022"
  setNames(c("FB", "AAPL", "AMZN", "NFLX", "GOOG"))


vline <- function(x = 0, color = "grey") {
  list(
    type = "line",
    y0 = 0.05,
    y1 = 0.95,
    yref = "paper",
    x0 = x,
    x1 = x,
    line = list(color = color, dash="dot")
  )
}


text <- faang_data %>% filter(symbol == "AAPL") %>% arrange(desc(quarter_year)) %>% pull(axis_labels) %>% as.list()
vals <- faang_data %>% filter(symbol == "AAPL") %>% arrange(desc(quarter_year)) %>% pull(quarter_year) %>% as.list()

fig_openings <- plot_ly(colors = faang_colors) %>%
  
  add_segments(
    data = faang_data,
    y = ~ quarter_year,
    yend = ~ quarter_year,
    x = ~ min,
    xend = ~ max,
    line = list(color = "grey", width = 3),
    opacity = 0.3,
    showlegend = FALSE,
    hoverinfo = "skip"
  ) %>%
  
  add_markers(
    data = faang_data,
    y = ~ quarter_year,
    x = ~ perc,
    color = ~ as.factor(symbol),
    #colors = faang_colors, 
    #size = 1,
    #opacity = 0.1, 
    marker = list(size = 12, opacity = 0.8,
                  line = list(color = "#000000", width = 1, opacity = 1)) 
  ) %>%

  add_trace(
    data = faang_data_mean,
    y = ~ quarter_year,
    x = ~ mean,
    type = 'scatter',
    mode = 'line',
    name = "Ø FAANG",
    line = list(color = "black", width = 4)
  ) %>%
  
  layout(title = list(text = "FAANG Openings nach Quartalsberichten"),
         xaxis = list(title = FALSE, side = "top", tickformat = ",.1%", 
                      anchor = "free", position = 0.97, zeroline = FALSE),
         yaxis = list(title = list(text = "Quartal", standoff = 7L),
                      ticktext = text,
                      tickvals = vals),
         legend = list(orientation = 'h', y = 0.02),
         shapes = list(vline(0)),
         hovermode = "y unified") %>%
  config(displayModeBar = FALSE)

fig_openings
partial_bundle(fig_openings) %>% saveWidget("faang_openings.html", selfcontained = FALSE, libdir = "lib")
  

# Density Plot

vline_density <- function(x = 0, color = "black") {
  list(
    type = "line",
    y0 = 0,
    y1 = 0.95,
    yref = "paper",
    x0 = x,
    x1 = x,
    line = list(color = color, width = 1)
  )
}

d.fb <- faang_data %>% filter(symbol == "FB") %>% pull(perc) %>% density(na.rm = TRUE)
d.aapl <- faang_data %>% filter(symbol == "AAPL") %>% pull(perc) %>% density(na.rm = TRUE)
d.amzn <- faang_data %>% filter(symbol == "AMZN") %>% pull(perc) %>% density(na.rm = TRUE)
d.nflx <- faang_data %>% filter(symbol == "NFLX") %>% pull(perc) %>% density(na.rm = TRUE)
d.goog <- faang_data %>% filter(symbol == "GOOG") %>% pull(perc) %>% density(na.rm = TRUE)


fig <- plot_ly(type = 'scatter', mode = 'lines') %>% 
  
  add_trace(x = ~d.goog$x, y = ~d.goog$y, fill = 'tozeroy', name = "GOOG", fillcolor = paste0(faang_colors[5], "40"), line = list(color = faang_colors[5])) %>%
  add_trace(x = ~d.nflx$x, y = ~d.nflx$y, fill = 'tozeroy', name = "NFLX", fillcolor = paste0(faang_colors[4], "40"), line = list(color = faang_colors[4])) %>%
  add_trace(x = ~d.amzn$x, y = ~d.amzn$y, fill = 'tozeroy', name = "AMZN", fillcolor = paste0(faang_colors[3], "40"), line = list(color = faang_colors[3])) %>%
  add_trace(x = ~d.aapl$x, y = ~d.aapl$y, fill = 'tozeroy', name = "AAPL", fillcolor = paste0(faang_colors[2], "40"), line = list(color = faang_colors[2])) %>%
  add_trace(x = ~d.fb$x, y = ~d.fb$y, fill = 'tozeroy', name = "FB", fillcolor = paste0(faang_colors[1], "40"), line = list(color = faang_colors[1])) %>% 
  
  layout(title = "FAANG Openings nach Quartalsberichten<br>Q2 2012 — Q4 2021",
         xaxis= list(title = "Opening-Kurs nach Quartalsbericht", tickformat = ",.0%",
                     showgrid = FALSE,
                     zeroline = FALSE),
         yaxis = list(title = "Density",
                      showgrid = FALSE),
         legend = list(x = 0.8, y = 0.95, traceorder = "reversed"),
         shapes = list(vline_density(0)),
         hovermode = "x unified") %>%
  config(displayModeBar = FALSE)

fig

partial_bundle(fig) %>% saveWidget("faang_density.html", selfcontained = FALSE, libdir = "lib")


write_csv(faang_quarter_mean, file = "test.csv")

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Dump ggplots ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

ggplot(faang_data) +
  geom_point(aes(x = quarter_year, y = perc, color = symbol)) +
  geom_segment(aes(
    x = quarter_year,
    xend = quarter_year,
    y = 0,
    yend = perc
  ), color = "grey") +
  geom_line(data = faang_data_mean, aes(x = quarter_year, y = mean, group = 1))

ggplot(faang_data_mean, aes(x = quarter_year, y = mean, group = 1)) +
  geom_point() +
  geom_line()


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# End ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
