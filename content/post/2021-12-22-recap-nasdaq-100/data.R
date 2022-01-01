#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Data and code for recap nasdaq  ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load R libraries and themes ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cat("\014") # Clear your console
rm(list = ls()) # Clear your environment

# Load in header file
setwd("/Users/jan/blog/jantau/content/post/2021-12-22-recap-nasdaq-100") 

library(crosstalk)
library(htmlwidgets)
library(listviewer)
library(plotly)
library(rjson)
library(tidyquant)
library(tidyverse)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Web scraping of nasdaq data ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

url <- "https://www.ishares.com/de/privatanleger/de/produkte/253741/ishares-nasdaq-100-ucits-etf/1478358465952.ajax?fileType=csv&fileName=SXRV_holdings&dataType=fund"
ishares_nasdaq <- read_csv(url, skip = 2)

ndx_data <- ishares_nasdaq %>%
  filter(Anlageklasse == "Aktien") %>%
  select(1:3, 6) %>%
  rename(Gewichtung = `Gewichtung (%)`) %>%
  mutate(Gewichtung = str_replace_all(Gewichtung, ",", ".")) %>%
  mutate(Gewichtung = as.numeric(Gewichtung))

ndx_query <- append("^NDX", ndx_data$Emittententicker)
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Import nasdaq data ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

ndx_wk <- tq_get(ndx_query,
                 get  = "stock.prices",
                 from = "2020-12-29",
                 to = Sys.Date()) %>%
  group_by(symbol) %>%
  tq_transmute(select     = adjusted,
               mutate_fun = to.weekly) %>%
  group_by(symbol) %>%
  mutate(adj_perc = round(adjusted/first(adjusted)-1, 3))

save(ndx_wk, file = "ndx_wk.Rdata")
load("ndx_wk.Rdata")

# Dump: Compare asset classes
# assets <- tq_get(c("^NDX", "^GDAXI", "^SP500TR", "BTC-EUR", "^XAU", "^STOXX"),
#               get  = "stock.prices",
#               from = "2020-12-29",
#               to = Sys.Date()) %>%
#   group_by(symbol) %>%
#   tq_transmute(select     = adjusted,
#                mutate_fun = to.weekly) %>%
#   group_by(symbol) %>%
#   mutate(adj_perc = round(adjusted/first(adjusted)-1, 3))
# 
# assets %>%
#   plot_ly() %>%
#   add_lines(x = ~date, y = ~adj_perc, color = ~symbol) %>%
#   layout(legend = list(orientation = "h"))



#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create interactive plotly chart ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Join ishares index data with yahoo price data
ndx_wk_join <- ndx_wk %>% left_join(ndx_data, by = c("symbol" = "Emittententicker"))

ndx_wk_join_all <- ndx_wk_join %>% filter(symbol != "^NDX") %>% SharedData$new(~symbol)
ndx_wk_join_ndx <- ndx_wk_join %>% filter(symbol == "^NDX") #%>% SharedData$new(~symbol)

fig <- plot_ly() %>% 
  
  
  add_lines(data = ndx_wk_join_all, x = ~date, y = ~adj_perc, ids = ~symbol, color = ~Sektor, opacity = 0.8,
            line = list(width = 0.5),
            hoverinfo = "text",
            text = ~paste("<b>", Name, "</b>",
                          "<br> Sektor: ", Sektor,
                          "<br> Performance: ", adj_perc*100, "%",
                          "<br> Kurs: ", round(adjusted, 1),
                          "<br> Gewichtung: ", Gewichtung, "%",
                          "<br> Datum: ", date
            )) %>% #, showlegend = FALSE
  
  add_lines(data = ndx_wk_join_ndx, x = ~date, y = ~adj_perc, ids = ~symbol,
            name = "Nasdaq 100", line = list(color = "grey95", width = 4, dash = 'dot'),
            hoverinfo = "text",
            text = ~paste("<b> NASDAQ 100</b>",
                          "<br> Performance: ", adj_perc*100, "%",
                          "<br> Kurs: ", round(adjusted, 1),
                          "<br> Datum: ", date
            )) %>%
  
  layout(title = "NASDAQ 100 in 2021",
         xaxis = list(
           title = list(visible = FALSE),
           range = 
             c(as.numeric(as.POSIXct("2021-01-01", format="%Y-%m-%d"))*1000,
               as.numeric(as.POSIXct("2022-01-01", format="%Y-%m-%d"))*1000),
           type = "date"),
         yaxis = list(title = "Performance",
                      tickformat = ",.0%"),
         showlegend = TRUE, 
         legend = list(x = 0.2, y = 0.9,
                       title = list(text = "<b> Sektoren </b>"),
                       bgcolor = "rgba(255, 255, 255, 0.4)",
                       bordercolor = "#FFFFFF",
                       borderwidth = 1)
  ) %>% 
  
  highlight(on = "plotly_hover", off = "plotly_doubleclick", selected = attrs_selected(showlegend = FALSE))

fig 

fig_json <- plotly_json(fig, FALSE)
jsonData <- toJSON(fig_json)
write(jsonData,'test.json')
write(fig_json,'test.json')


partial_bundle(fig) %>% saveWidget("fig.html", selfcontained = FALSE, libdir = "lib")






# Dump: For animated chart split and accumulate data (see Datacamp Course Intermediate Interactive Data Visualization with plotly in R)
# Data is too big for animation
ndx_wk_acc <- ndx_wk %>%
  group_by(symbol) %>%
  split(.$date) %>%
  accumulate( ~ bind_rows(.x, .y)) %>%
  # set_names(1960:2018) %>%
  bind_rows(.id = "frame") %>%
  filter(frame != "2020-12-30")

ndx_wk_acc_join <- ndx_wk_acc %>% left_join(ndx_data, by = c("symbol" = "Emittententicker"))

ndx_wk_acc_join_all <- ndx_wk_acc_join %>% filter(symbol != "^NDX") %>% SharedData$new(~symbol)
ndx_wk_acc_join_ndx <- ndx_wk_acc_join %>% filter(symbol == "^NDX") #%>% SharedData$new(~symbol)


fig <- plot_ly() %>% 
  
  
  add_lines(data = ndx_wk_acc_join_all, x = ~date, y = ~adj_perc, frame = ~frame, ids = ~symbol, color = ~Sektor, opacity = 0.4,
            line = list(width = 3),
            hoverinfo = "text",
            text = ~paste("<b>", Name, "</b>",
                          "<br> Sektor: ", Sektor,
                          "<br> Performance: ", adj_perc*100, "%",
                          "<br> Kurs: ", round(adjusted, 1),
                          "<br> Gewichtung: ", Gewichtung, "%",
                          "<br> Datum: ", date
            )) %>% #, showlegend = FALSE
  
  add_lines(data = ndx_wk_acc_join_ndx, x = ~date, y = ~adj_perc, frame = ~frame, ids = ~symbol,
            name = "Nasdaq 100", line = list(color = "grey35", width = 4, dash = 'dot'),
            hoverinfo = "text",
            text = ~paste("<b> NASDAQ 100</b>",
                          "<br> Performance: ", adj_perc*100, "%",
                          "<br> Kurs: ", round(adjusted, 1),
                          "<br> Datum: ", date
            )) %>%
  
  layout(title = "NASDAQ 100 in 2021",
         xaxis = list(
           title = list(visible = FALSE),
           range = 
             c(as.numeric(as.POSIXct("2021-01-01", format="%Y-%m-%d"))*1000,
               as.numeric(as.POSIXct("2021-12-31", format="%Y-%m-%d"))*1000),
           type = "date"),
         yaxis = list(title = "Performance",
                      tickformat = ",.0%"),
         showlegend = TRUE, 
         legend = list(x = 0.1, y = 0.9,
                       title = list(text = "<b> Sektoren </b>"),
                       bgcolor = "rgba(255, 255, 255, 0.4)",
                       bordercolor = "#FFFFFF",
                       borderwidth = 1)
  ) %>% 
  
  animation_opts(
    frame = 100, 
    transition = 50, 
    easing = "elastic"
  ) %>%
  animation_slider(
    tickcolor = "white",
    font = list(color = "white"),
    currentvalue = list(
      prefix = NULL, 
      font = list(color = "gray")
    )
    ) %>%
  
  highlight(on = "plotly_hover", off = "plotly_doubleclick", selected = attrs_selected(showlegend = FALSE), selectize = TRUE)


fig 


fig_json <- plotly_json(fig, FALSE)
jsonData <- toJSON(fig_json)
write(jsonData,'test.json')
write(fig_json,'test.json')


partial_bundle(fig) %>% saveWidget("fig.html", selfcontained = FALSE, libdir = "lib")




# Set date axis range
# https://stackoverflow.com/questions/38919395/plotly-r-cant-make-custom-xaxis-date-ranges-to-work
# Hide slider labels
# https://stackoverflow.com/questions/51835657/how-to-hide-remove-slider-ticks-steps-and-their-labels-in-plotly-js
# Axis labe as percent
# https://stackoverflow.com/questions/42043633/format-y-axis-as-percent-in-plot-ly
# Plotly to Wowchemy via shortcode
# https://wowchemy.com/docs/content/writing-markdown-latex/
# Problem with files size when github push: git config --global http.postBuffer 157286400
# https://stackoverflow.com/questions/15843937/git-push-hangs-after-total-line



#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Favorite ETFs in Germany in 2021  ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Die beliebtesten ETFs in Deutschland
# nach Finanzfluss-Video
#
# Handelsvolumen nach XETRA (Daten verfügbar)
# MSCI World
# Dax
# Euro Stoxx 50
# Nasdaq 100
# Stoxx Europe 600
# S&P Global Clean Energy
# S&P 500
# MSCI EM
# FTSE ALL World
# MSCI EM IMI
#
# Asset under Management (Fondsvolumenzuwachs)
# MSCI World
# S&p 500
#  MSCI EM
# Nasdaq 100
# FTSE all World
# MSCI World SRI
# EUro Stoxx 50
# Global Clean Energy
# Stoxx Europe 600
# MSCI EM IMI
# Dax
# 
# https://www.youtube.com/watch?v=nOhH0vPrlvI
# deutsche-boerse-cash-market.com
# https://www.deutsche-boerse-cash-market.com/dbcm-de/instrumente-statistiken/statistiken/etf-etp-statistiken
# https://www.msci.com/our-solutions/esg-investing/esg-ratings/esg-ratings-corporate-search-tool/issuer/apple-inc/IID000000002157615


library(readxl)
library(rvest)
library(xml2)

# Get url from xetra etf statistics website
xetra_page <- "https://www.deutsche-boerse-cash-market.com/dbcm-de/instrumente-statistiken/statistiken/etf-etp-statistiken/2112!search?state=H4sIAAAAAAAAADWOsQoCMRAFf0W2TqFtarGyCCj24fKigTXB3Q1yHPfvBiHdG2aKt1GKhou0N_namd2f721SjgtMyW_72EXUrjCDTP0qpgES4hPkT0dHpS7cE27FoDNqldeQMvkcWeHo0yEreSJHAu1sj4LvjLWJDafnceOQoAvtP8CH51ukAAAA&hitsPerPage=25"

# Get links to xlsx from xetra etf statistics website
xetra <- xetra_page %>%
  read_html() %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  str_extract("^/resource/.+2021\\d{4}.+") %>%
  discard(is.na)

# Download all xlsx files from xetra etf statistics website
for (i in seq(xetra)) {
  
  url <- paste0("https://www.deutsche-boerse-cash-market.com", xetra[i])
  destfile <- paste0("X-", str_extract(xetra[i], "2021\\d{4}"), ".xlsx")
  curl::curl_download(url, destfile)
  destfile_name <- paste0("X-", str_extract(xetra[i], "2021\\d{4}"))
  
  assign(destfile_name, read_excel(destfile, col_names = FALSE, skip = 4, sheet = "XTF Exchange Traded Funds"))
 # assign(destfile, read_excel(destfile, col_names = FALSE, skip = 4, sheet = "XTF Exchange Traded Funds"))
}

# Make list from all xetra xlsx objects
xetra_list <- mget(ls(pattern = "^X-2021\\d{4}$"))

# Colnames are in two row; hence some cleanup is necessary
xetra_list_names <- map(xetra_list, ~paste(.[1,], .[2,], sep = "_"))

xetra_list_names_clean <- map(xetra_list_names, str_remove, "\\d.+")

xetra_list_coln <- map2(xetra_list, xetra_list_names_clean, ~ .x %>% 
                set_names(.y))

xetra_list_clean <- map(xetra_list_coln, slice, c(-1,-2))

# Dump: xetra_list_2 <- map(xetra_list, row_to_names, row_number = 1)
# Dump: xetra_list_3 <- map2(xetra_list_2, names(xetra_list_2), ~cbind(.x, Monat = .y))

# Create df from all xetra xlsx objects
xetra_df <- bind_rows(xetra_list_clean, .id = "Month") %>%
  drop_na(`Product Family_NA`)

# Clean df

xetra_df <- xetra_df %>%
  select(month = Month,
         etf_name = 2,
         isin = ISIN_NA,
         product_family = `Product Family_NA`,
         replication = Replication_NA,
         income_treatment = 6,
         turnover_in_meur = `Xetra Order Book Turnover in MEUR_`,
         aum_in_meur = `AuM_in MEUR`) %>%
  filter(isin != "ISIN") %>%
  mutate(turnover_in_meur = as.numeric(turnover_in_meur),
         aum_in_meur = as.numeric(aum_in_meur)) 
  

xetra_df_sum <-xetra_df %>%
  group_by(etf_name) %>% #, isin
  summarize(turnover_in_meur = sum(turnover_in_meur)) %>%
  arrange(-turnover_in_meur)

# Dump: Alternative approach to get colnames from two rows
# for (i in 1:ncol(etf)) {
#   if (is.na(etf[1, i])) {
#     colnames(etf)[i] <- etf[2, i]
#   } else {
#     colnames(etf)[i] <- etf[1, i]
#   }
# }
# 
# etf <- etf %>%
#   filter(!row_number() %in% c(1, 2)) 

# Dump: Alternative approach to load all xlsx from folder
# tbl <-
#   list.files(pattern = "*.xlsx") %>% 
#   map_df(~read_excel(., col_names = FALSE, skip = 4, sheet = "XTF Exchange Traded Funds"))

# Dump: Alternative approach to download all files from certain date
# month <- seq(as.Date("2021-11-01"), as.Date("2021-11-01"), by="months") - 1 
# month <- month %>% as.character() %>% str_replace_all("-", "")




fav_name <- c("iShares Core DAX UCITS ETF (DE)", "iShares Core MSCI World UCITS ETF USD (Acc)", "iShares Global Clean Energy UCITS ETF", "iShares STOXX Europe 600 UCITS ETF (DE)", "iShares Core EURO STOXX 50 UCITS ETF", "iShares Core S&P 500 UCITS ETF","iShares NASDAQ 100 UCITS ETF"   )
fav_levels <- fav_name

fav_etfs <- c("EXS1.DE", "EUNL.DE", "IQQH.DE", "EXSA.DE", "SXRT.DE", "SXR8.DE", "SXRV.DE")  

fav_vol <- c(8, 6, 4.8, 4, 3, 2.1, 1.7 )

favs <- data.frame(fav_name, fav_etfs, fav_vol) %>%
  mutate(fav_name = factor(fav_name, levels = fav_levels))

fav_etfs_rate <- tq_get(fav_etfs,
                        get  = "stock.prices",
                        from = "2020-12-29",
                        to = Sys.Date()) %>%
  group_by(symbol) %>%
  tq_transmute(select     = adjusted,
               mutate_fun = to.weekly) %>%
  group_by(symbol) %>%
  mutate(adj_perc = round(adjusted/first(adjusted)-1, 3))

fav_etfs_rate <- favs %>% left_join(fav_etfs_rate, by = c("fav_etfs" = "symbol"))

# font style
f <- list(
  family = "Arial",
  size = 16,
  color = "black")

# annotations
a <- list(
  text = "nach Handelsvolumnen im XETRA-Handel",
  #font = f,
  xref = "paper",
  yref = "paper",
  yanchor = "bottom",
  xanchor = "center",
  align = "center",
  x = 0.5,
  y = 0.95,
  showarrow = FALSE
)

fav_etfs_rate %>%
  plot_ly() %>%
  add_lines(x = ~date, y = ~adj_perc, color = ~fav_name, line = list(width = ~fav_vol), opacity = 0.8) %>%
  layout(legend = list(orientation = "h"),
         title = "Beliebteste ETFs in Deutschland 2021",
         annotations = a)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# End ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++