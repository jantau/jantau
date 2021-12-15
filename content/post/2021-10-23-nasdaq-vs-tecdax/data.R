#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Data and code for comparing nasdaq and tecdax ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load R libraries and themes ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cat("\014") # Clear your console
rm(list = ls()) # Clear your environment

# Load in header file
source("/Users/jan/blog/jantau/content/post/header.R")
setwd("/Users/jan/blog/jantau/content/post/2021-10-23-nasdaq-vs-tecdax") 

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Web scraping ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Tutorial
# https://towardsdatascience.com/tidy-web-scraping-in-r-tutorial-and-resources-ac9f72b4fe47?gi=bbadd5a4567f

library(rvest)
library(xml2)


tecdax_fundamental_page <- "https://www.finanzen.net/index/tecdax/fundamental"
tecdax_fundamental <- read_html(tecdax_fundamental_page)

str(tecdax_fundamental)

body_nodes <- tecdax_fundamental%>% 
  html_node("body") %>% 
  html_children()
body_nodes

body_nodes %>% 
  html_children()

rank <- tecdax_fundamental %>% 
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//span[contains(@table, '')]") %>% 
  rvest::html_text()

rank <- tecdax_fundamental %>% 
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all('//*[@id="IndexShareListValues"]') %>% 
  rvest::html_text()



hot100page <- "https://www.billboard.com/charts/hot-100"
hot100 <- read_html(hot100page)

rank <- hot100 %>% 
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//span[contains(@class, 'chart-element__rank__number')]") %>% 
  rvest::html_text()

artist <- hot100 %>% 
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//span[contains(@class, 'chart-element__information__artist')]") %>% 
  rvest::html_text()

title <- hot100 %>% 
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//span[contains(@class, 'chart-element__information__song')]") %>% 
  rvest::html_text()

chart <- data.frame(rank, artist, title)

table <- tecdax_fundamental_page %>%
  html() %>%
  html_nodes(xpath = '//*[@id="IndexShareListValues"]') %>%
  html_table()

rank <- tecdax_fundamental %>% 
  rvest::html_nodes('table') %>% 
  xml2::xml_find_all('//*[@id="IndexShareListValues"]/div/table') %>% 
  rvest::html_text()

rank %>% html_element("body") %>%html_table()


chart <- data.frame(rank)


tecdax <- tecdax_fundamental_page %>% 
  read_html() %>% 
  html_element(css = "#IndexShareListValues > div > table") %>%
  html_table()

sp500_fundamental_page <- "https://www.finanzen.net/index/s&p_500/fundamental"

sp500 <- sp500_fundamental_page %>% 
  read_html() %>% 
  html_element(css = "#IndexShareListValues > div > table") %>%
  html_table()

datalist = list()

for (i in 1:11) {
  
  sp500_fundamental_page <- paste0("https://www.finanzen.net/index/s&p_500/fundamental?p=", i)
  
  sp500 <- sp500_fundamental_page %>% 
    read_html() %>% 
    html_element(css = "#IndexShareListValues > div > table") %>%
    html_table()
  
  datalist[[i]] <- sp500
}

sp500_complete <- bind_rows(datalist)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Data cleaning ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sp500_complete <- sp500_complete %>%
  select(-6, -7) %>%
  mutate(across(!Name, ~ str_replace(., " .*", ""))) %>%
  mutate(across(!Name, ~ str_replace(., ",", "."))) %>%
  mutate(across(!Name, ~ as.numeric(.))) %>%
  mutate(across(c(3, 5), ~ replace_na(., 0)))

mean(sp500_complete$KGV, na.rm = TRUE)
  
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Get data from ishares etfs ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

url <- "https://www.ishares.com/de/privatanleger/de/produkte/253741/ishares-nasdaq-100-ucits-etf/1478358465952.ajax?fileType=csv&fileName=SXRV_holdings&dataType=fund"
ishares_nasdaq <- read_csv(url, skip = 2)

# bei ishares sind auf kgvs für indizes angegeben. Vergleichen mit eigener Berechnung?
