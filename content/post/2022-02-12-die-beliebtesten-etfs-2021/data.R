#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Data and code for analysis of xetra data ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load R libraries and themes ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cat("\014") # Clear your console
rm(list = ls()) # Clear your environment

# Load in header file
source("/Users/jan/blog/jantau/content/post/header.R")
setwd("/Users/jan/blog/jantau/content/post/2022-02-12-die-beliebtesten-etfs-2021") 

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

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Webscraping of xetra etf statistics ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Get url from xetra etf statistics website
xetra_page <- "https://www.deutsche-boerse-cash-market.com/dbcm-de/instrumente-statistiken/statistiken/etf-etp-statistiken/2112!search?state=H4sIAAAAAAAAADWOsQoCMRAFf0W2TqFtarGyCCj24fKigTXB3Q1yHPfvBiHdG2aKt1GKhou0N_namd2f721SjgtMyW_72EXUrjCDTP0qpgES4hPkT0dHpS7cE27FoDNqldeQMvkcWeHo0yEreSJHAu1sj4LvjLWJDafnceOQoAvtP8CH51ukAAAA&hitsPerPage=25"

# Get links to xlsx from xetra etf statistics website
xetra_links <- xetra_page %>%
  read_html() %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  str_extract("^/resource/.+2021\\d{4}.+") %>%
  discard(is.na)

# Download all xlsx files from xetra etf statistics website
for (i in seq(xetra_links)) {
  
  url <- paste0("https://www.deutsche-boerse-cash-market.com", xetra_links[i])
  destfile <- paste0("X-", str_extract(xetra_links[i], "2021\\d{4}"), ".xlsx")
  curl::curl_download(url, destfile)
  #destfile_name <- paste0("X-", str_extract(xetra[i], "2021\\d{4}"))
  #assign(destfile_name, read_excel(destfile, col_names = FALSE, skip = 4, sheet = which(str_detect(excel_sheets(destfile), ".*Exchange Traded Funds"))))
  
}

# Harmonize and combine etf xles files

create_df <- function(){

files <- dir(pattern = ".*2021\\d{4}.xlsx")

datalist_xetra = list()

for (i in seq(files)) { 
  
  if (str_detect(files[i], "20211[12]3[01]", negate = TRUE)){
    xetra_xlsx <- read_excel(files[i], col_names = FALSE, skip = 6, sheet = which(str_detect(excel_sheets(files[i]), ".*Exchange Traded Funds"))) %>%
      select(c(1:6, 10)) %>%
      rename("etf_name" = 1,
             "isin" = 2,
             "company" = 3,
             "replication" = 4,
             "income_treatment" = 5,
             "xetra_turnover" = 6,
             "aum" = 7) %>%
      filter(str_detect(isin, "^[A-Z0-9]{12}$")) %>%
      mutate(xetra_turnover = as.numeric(xetra_turnover)) %>%
      mutate(aum = na_if(aum, "n.a.")) %>%
      mutate(aum = as.numeric(aum)) %>%
      mutate(month = ymd(str_extract(files[i], "\\d{8}")), .before = "etf_name") %>%
      mutate(etf_type = NA, .after = "company") %>%
      distinct(isin, .keep_all = TRUE)
    
    datalist_xetra[[i]] <- xetra_xlsx
    
  } else if (str_detect(files[i], "20211130")){
    
    xetra_xlsx <- read_excel(files[i], col_names = FALSE, skip = 6, sheet = which(str_detect(excel_sheets(files[i]), ".*Exchange Traded Funds"))) %>%
      select(c(1:2, 4:7, 11)) %>%
      # select(-c(7, 8, 9, 11)) %>%
      rename("etf_name" = 1,
             "isin" = 2,
             "company" = 3,
             "replication" = 4,
             "income_treatment" = 5,
             "xetra_turnover" = 6,
             "aum" = 7) %>%
      filter(str_detect(isin, "^[A-Z0-9]{12}$")) %>%
      mutate(xetra_turnover = as.numeric(xetra_turnover)) %>%
      mutate(aum = na_if(aum, "n.a.")) %>%
      mutate(aum = as.numeric(aum)) %>%
      mutate(month = ymd(str_extract(files[i], "\\d{8}")), .before = "etf_name") %>%
      mutate(etf_type = NA, .after = "company") %>%
      distinct(isin, .keep_all = TRUE)
    
    datalist_xetra[[i]] <- xetra_xlsx
    
  } else{
    xetra_xlsx <- read_excel(files[i], col_names = FALSE, skip = 7, sheet = which(str_detect(excel_sheets(files[i]), ".*Exchange Traded Funds"))) %>%
      select(-c(1, 10, 12)) %>%
      rename("etf_name" = 1,
             "isin" = 2,
             "xetra_ticker" = 3,
             "company" = 4,
             "etf_type" = 5,
             "replication" = 6,
             "income_treatment" = 7,
             "xetra_turnover" = 8,
             "aum" = 9) %>%
      filter(str_detect(isin, "^[A-Z0-9]{12}$")) %>%
      mutate(xetra_turnover = as.numeric(xetra_turnover)) %>%
      mutate(aum = na_if(aum, "n.a.")) %>%
      mutate(aum = as.numeric(aum)) %>%
      mutate(month = ymd(str_extract(files[i], "\\d{8}")), .before = "etf_name") %>%
      distinct(isin, .keep_all = TRUE)
    
    datalist_xetra[[i]] <- xetra_xlsx
    
  }
}

# Create df from list and fill missing values
xetra_df <- bind_rows(datalist_xetra) %>%
  group_by(isin) %>%
  # Fill df with new columns from December 2021
  fill(c(etf_type, xetra_ticker), .direction = "up") %>%
  ungroup()

}

xetra_df <- create_df()

save(xetra_df, file = "xetra_df.Rdata")


# Analyse der daten von Xetra
# https://www.xetra.com/resource/blob/2925932/0f9f5bfba3d0973b628e22307631b3d3/data/Factsheet-Zahlen-und-Fakten-2021_de.pdf

# "In Europa hatte der Xetra-Handel im Gesamtjahr 2021 einen Marktanteil am börslich gehandelten ETF-Volumen von 32 Prozent."

test_2 <- xetra_df %>%
  group_by(isin) %>%
  summarise(xetra_turnover_year = sum(xetra_turnover)) %>%
  arrange(desc(xetra_turnover_year)) %>%
  left_join(xetra_df, by = "isin") %>%
  arrange(desc(month)) %>%
  distinct(isin, .keep_all = TRUE) %>%
  ungroup()

test_2 %>% filter(month == "2021-12-31") %>% summarise(sum = sum(xetra_turnover, na.rm = TRUE))

xetra_df %>%
  group_by(month) %>%
  summarise(sum_turnover = sum(xetra_turnover, na.rm = TRUE)) %>%
  plot_ly(x = ~month, y = ~sum_turnover) %>%
  add_bars()

test_3 <- test_2 %>%
  group_by(company) %>%
  summarise(sum = sum(xetra_turnover_year, na.rm = TRUE), n = n(), aum_sum = sum(aum, na.rm = TRUE)) %>%
  arrange(desc(sum))

test_3 <- xetra_df %>%
  group_by(replication) %>%
  summarise(sum = sum(xetra_turnover_year, na.rm = TRUE), n = n(), aum_sum = sum(aum, na.rm = TRUE)) %>%
  arrange(desc(sum))

test_3 <- xetra_df %>%
  group_by(income_treatment) %>%
  summarise(sum = sum(xetra_turnover_year, na.rm = TRUE), n = n(), aum_sum = sum(aum, na.rm = TRUE)) %>%
  arrange(desc(sum))

test_3 <- xetra_df %>%
  group_by(month) %>%
  summarise(sum = sum(xetra_turnover_year, na.rm = TRUE), n = n(), aum_sum = sum(aum, na.rm = TRUE)) %>%
  arrange(desc(sum))

test_3 <- xetra_df %>%
  summarise(sum = sum(xetra_turnover_year, na.rm = TRUE), n = n(), aum_sum = sum(aum, na.rm = TRUE)) %>%
  arrange(desc(sum))

# Problem: What are Active ETFs? Actively managed etfs? Yup, propably etf_type

ticker <- test_2 %>% slice_head(n = 10) %>% pull(xetra_ticker) %>% paste0(".DE") %>% c("6AQQ.DE")


fav_etfs_rate <- tq_get(ticker,
                        get  = "stock.prices",
                        from = "2020-12-29",
                        to = "2021-12-31") %>%
  group_by(symbol) %>%
  tq_transmute(select     = adjusted,
               mutate_fun = to.weekly) %>%
  group_by(symbol) %>%
  mutate(adj_perc = round(adjusted/first(adjusted)-1, 3))

etf_data <- fav_etfs_rate %>% 
  ungroup() %>%
  mutate(symbol = str_extract(symbol, "^[A-Z0-9]{4}")) %>%
  left_join(test_2, by = c("symbol" = "xetra_ticker")) %>%
  mutate(xetra_turnover_year_normalized = xetra_turnover_year/max(xetra_turnover_year)*10) %>%
  mutate(etf_name = str_remove(etf_name, ".UCITS.*$")) %>%
  mutate(etf_name = fct_reorder(etf_name, xetra_turnover_year, .desc = TRUE))

# factorize etf_name 

library(viridis)

pal <- got(10)

text <- c("Jan\n2021", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dez") %>% as.list()
vals <-  seq(ymd('2021-01-15'), ymd('2021-12-15'), by = 'months') %>% as.list()

margin <- list(autoexpand = FALSE,
               r = 100)

textcolor_label <- etf_data %>% group_by(symbol) %>% filter(date == "2021-12-30")
textcolor <- etf_data %>% group_by(symbol) %>% filter(date == "2021-12-30") %>%
  ungroup() %>%
  mutate(color = viridis(length(unique(etf_data$etf_name)), direction = -1, option = "D")) %>% pull(color, name = etf_name)

textcolor <- etf_data %>% group_by(symbol) %>% filter(date == "2021-12-30") %>%
  ungroup() %>%
  mutate(color = viridis(length(unique(etf_data$etf_name)), direction = -1, option = "D")) %>%
  select(isin, color)

etf_data <- etf_data %>% left_join(textcolor, by = "isin")


color_map <- c(Pass="yellow", High="red", Low= "cyan",
               Sigma= "magenta", Mean='limegreen', Fail="blue", Median="violet")

list(color_map[label])

label <- list(
  xref = 'paper',
  yref = 'y',
  x = 1,
  y = ~etf_data %>% group_by(symbol) %>% filter(date == "2021-12-30") %>% pull(adj_perc),
  xanchor = 'left',
  yanchor = 'middle',
  bgcolor = ~viridis(length(unique(etf_data$etf_name)), direction = -1, option = "D"), #~etf_data %>% group_by(symbol) %>% filter(date == "2021-12-30") %>% pull(color), # "#FFFFFFBF",
  text = ~paste(etf_data %>% group_by(symbol) %>% filter(date == "2021-12-30") %>% pull(adj_perc) * 100, '%'),
  font = list(size = 12,
              color = "#ffffff"),
  showarrow = FALSE)

top_etf_volume <- etf_data %>%
plot_ly(x = ~date, y = ~adj_perc, color = ~etf_name, colors = viridis(length(unique(etf_data$etf_name)), direction = -1, option = "D"), line = list(width = ~xetra_turnover_year_normalized)) %>%
  add_lines() %>%
  layout(xaxis = list(title = FALSE, ticktext = text, tickvals = vals, showgrid = FALSE), #if_else(~date <= "2019-12-31", "%b\n%Y", "%b")
         yaxis = list(title = FALSE, tickformat = ".0%", showgrid = FALSE),
         legend = list(orientation = "h", x = 0.1, y = .99, bgcolor = "#FFFFFFBF", font = list(size = 8)),
         annotations = label,
         margin = margin) %>% # 
  config(displayModeBar = FALSE)

# dtick = "M1", tickformat = "%b\n%Y", ticklabelmode = "period",
# ticktext = text, tickvals = vals
top_etf_volume
partial_bundle(top_etf_volume) %>% saveWidget("top_etf_volume.html", selfcontained = FALSE, libdir = "lib")

hovertext <-
  c(
    "<b>{etf_name}</b>
          Performance 2021 = {adj_perc*100} %
          Handelsvolumen = {round(xetra_turnover_year, 0)} Mio. €
          AUM = {round(aum, 0)} Mio. €"
  )

top_etf_volume_bar <- etf_data %>%
  group_by(symbol) %>%
  filter(date == last(date)) %>%
  ungroup() %>%
  mutate(etf_name = fct_reorder(etf_name, adj_perc, min)) %>%
  plot_ly(y = ~etf_name, x = ~adj_perc, text = ~paste0(adj_perc*100, " %"), textfont = list(size = 12), textposition = "outside", color = ~etf_name, colors = viridis(length(unique(etf_data$etf_name)), direction = 1, option = "D"),
          hoverinfo = "text",
          hovertext = ~ str_glue(hovertext)) %>%
  add_bars(width = ~xetra_turnover_year_normalized/10) %>%
  hide_legend() %>%
  layout(title = list(text = "Performance der Top-10 XETRA-ETFs im Jahr 2021 <br>(nach Handelsvolumen)"),
         xaxis = list(title = FALSE, tickformat = ".0%", zeroline = FALSE, range = list(-0.35, 0.55)),
         yaxis = list(title = FALSE),
         uniformtext = list(minsize = 12, mode = "show"),
         margin = list(t = 50)) %>%
  config(displayModeBar = FALSE)
 
top_etf_volume_bar 
partial_bundle(top_etf_volume_bar ) %>% saveWidget("top_etf_volume_bar.html", selfcontained = FALSE, libdir = "lib")



# Dumbell chart AUM Jan vs AUM dec

top_isin <- xetra_df %>%
  filter(month == "2021-12-31") %>%
  slice_max(order_by = aum, n = 10) %>%
  pull(isin)

top_etf_aum_dumbbell <- xetra_df %>%
  filter(month == "2021-01-31" | month == "2021-12-31") %>%
  filter(isin %in% top_isin) %>%
  mutate(aum = aum * 1000000) %>%
  ungroup() %>%
  mutate(etf_name = fct_reorder2(etf_name, month, desc(aum)))

top_etf_aum_dumbbell %>%  
  plot_ly() %>%
  add_markers(x = ~aum[top_etf_aum_dumbbell$month == "2021-01-31"], y = ~etf_name[top_etf_aum_dumbbell$month == "2021-01-31"], color = I(viridis(2)[2]), name = "Jan 2021") %>%
  add_markers(x = ~aum[top_etf_aum_dumbbell$month == "2021-12-31"], y = ~etf_name[top_etf_aum_dumbbell$month == "2021-12-31"], color = I(viridis(2)[1]), name = "Dez 2021") %>%
  layout(xaxis = list(range = list(0,60000000000), zeroline = FALSE))

top_etf_aum_dumbbell

df <- data.frame(A = sample(1:100, 10),
                 B = sample(1:10, 10))

colnames <- c("A", "B")
var <- c("A", "B")

val <- if (all(colnames == c("F", "A", "I", "R"))) {
  "FAIR"
} else if (all(colnames == c("F", "A", "I"))) {
  "FAI"
} else if (all(colnames == c("F", "A"))) {
  "FA"
} else if (all(colnames == c("F"))) {
  
colnames <- c("A")

var <- glue::glue_collapse(colnames, sep = "")

identical(colnames, var)

names(df)

eval(parse(colnames[1]))
eval(as.symbol(colnames[1]))

df %>%
  mutate(C = (eval(as.symbol("A"))+B)/2)

library(tidyverse)
library(plotly)

set.seed(42)

df <-
  data.frame(date = seq(ymd('2021-01-01'), ymd('2021-12-12'), by = 'weeks'),
             value = cumsum(sample(-10:20, length(seq(ymd('2021-01-01'), ymd('2021-12-12'), by = 'weeks')), replace = TRUE)))

df %>% 
  plot_ly(x = ~date, y = ~value) %>%
  add_lines() %>%
  layout(xaxis = list(dtick = "M1", tickformat = ~ifelse(df$date == "2021-01-31" , "%B\n%Y", "%B"))) #18628

# if(df$date == "2021-01-31"){"%B\n%Y"}else{"%B"}
# ~ifelse(df$date == "2021-01-31" , "%B\n%Y", "%B")

df %>% 
  plot_ly(x = ~date, y = ~value) %>%
  add_lines() %>%
  layout(xaxis = list(ticktext = text,
                      tickvals = vals))

#list(dtick = "M1", tickformat = "%b\n%Y")


Value = c(50124,  9994,  9822, 13580,  5906,  7414, 16847,    59, 80550,  6824,  3111, 16756,  7702, 23034, 38058,  6729,  6951,     2,   408,
          37360, 20517, 18714,   352,     3, 42922, 30850,    21,  4667, 12220,  8762,   445,  1875,   719,   188,    26,   124,   996,    10,
          27,   304,    55, 34980,    67,     3,    25,  1012,  3588,    77,   847,    47,  1057,   924,   233,    40,     2,  2362,     3,
          1866,    16,     0,     0,     0)

Type = c("A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A",
         "A", "A", "A", "A", "A", "A", "A", "A", "A", "A",  "A", 
         "B",  "B",  "B",  "B",  "B",  "B",  "B",  "B",  "B",  "B",  "B", 
         "B",  "B",  "B",  "B",  "B", "B", "B",  "B",  "B",  "B",  "B", 
         "B",  "B",  "B",  "B",  "B",  "B",  "B")

df = data.frame(Type, Value)


color <- c('rgb(0,255,255)', 'rgb(255,127,80)')

df %>% plot_ly(colors = color) %>%
  add_trace(
    labels = ~ Type,
    values = ~ Value,
    #colors = pal
     marker = list(colors = color),
    hole = 0.6,
    type = "pie"
  ) %>%
  layout(
    title = "Title",
    showlegend = T,
    xaxis = list(
      showgrid = FALSE,
      zeroline = FALSE,
      showticklabels = T
    ),
    yaxis = list(
      showgrid = FALSE,
      zeroline = FALSE,
      showticklabels = T
    )
  )

fig


plot_ly(df, labels = ~Type, values = ~Value, type = 'pie',
        textposition = 'inside',
        textinfo = 'label+percent',
        insidetextfont = list(color = '#FFFFFF'),
        hoverinfo = 'text',
        text = ~paste('$', Value, ' billions'),
        marker = list(colors = pal[1:2],
                      line = list(color = '#FFFFFF', width = 1)),
        #The 'pull' attribute can also be used to create space between the sectors
        showlegend = FALSE)
fig <- fig %>% layout(title = 'United States Personal Expenditures by Categories in 1960',
                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Dump ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Alternative approach to download xlsx files from web

library(httr)
destfile <- "https://www.deutsche-boerse-cash-market.com/resource/blob/2840580/6e593f815716dfc4d78dcd48eef5c257/data/20211031-ETF-ETP-Statistic.xlsx"

GET(destfile, write_disk("iris.xlsx", overwrite=TRUE))
test <- read_excel("iris.xlsx", col_names = FALSE, skip = 4, sheet = which(excel_sheets("iris.xlsx"), str_detect(".*Exchange Traded Fund.*")))


# Get sheet names from als xlsx files in folder
map(files, excel_sheets)

# Alternative approach to harmonize and combine  xlsx files with map

files <- dir(pattern = ".*2021\\d{4}.xlsx")

test <- map(files, ~ read_excel(., col_names = FALSE, skip = 4, sheet = which(str_detect(excel_sheets(.), ".*Exchange Traded Funds")))) %>%
  setNames(files)

# Make list from all xetra xlsx objects
xetra_list <- mget(ls(pattern = "^X-2021\\d{4}$"))

# Colnames are in two row; hence some cleanup is necessary
xetra_list_names <- map(xetra_list, ~paste(.[1,], .[2,], sep = "_"))

xetra_list_names_clean <- map(xetra_list_names, str_remove, "\\d.+")

xetra_list_coln <- map2(xetra_list, xetra_list_names_clean, ~ .x %>% 
                          set_names(.y))

xetra_list_clean <- map(xetra_list_coln, slice, c(-1,-2))

# Create df from all xetra xlsx objects
xetra_df <- bind_rows(xetra_list_clean, .id = "Month") %>%
  drop_na(`Product Family_NA`)




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
# month <- seq(as.Date("2020-11-01"), as.Date("2021-11-01"), by="months") - 1 
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
  layout(legend = list(orientation = "v"), 
         title = "Beliebteste ETFs in Deutschland 2021",
         annotations = a)





#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# End ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++