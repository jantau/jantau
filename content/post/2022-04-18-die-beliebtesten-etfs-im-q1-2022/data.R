#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Data and code for analysis of xetra data q1 2022----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load R libraries and themes ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cat("\014") # Clear your console
rm(list = ls()) # Clear your environment

# Load in header file
source("./content/post/header.R")
setwd("./content/post/2022-04-18-die-beliebtesten-etfs-im-q1-2022") 

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Favorite ETFs in Germany in 2022  ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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
  str_extract("^/resource/.+2022\\d{4}.+") %>%
  discard(is.na)

# Download all xlsx files from xetra etf statistics website
for (i in seq(xetra_links)) {
  url <- paste0("https://www.deutsche-boerse-cash-market.com", xetra_links[i])
  destfile <- paste0("X-", str_extract(xetra_links[i], "2022\\d{4}"), ".xlsx")
  curl::curl_download(url, destfile)
  #destfile_name <- paste0("X-", str_extract(xetra[i], "2021\\d{4}"))
  #assign(destfile_name, read_excel(destfile, col_names = FALSE, skip = 4, sheet = which(str_detect(excel_sheets(destfile), ".*Exchange Traded Funds"))))
}

# Harmonize and combine etf xles files

create_df <- function(){
  
  files <- dir(pattern = ".*2022\\d{4}.xlsx")
  
  datalist_xetra = list()
  
  for (i in seq(files)) { 
    
      xetra_xlsx <- read_excel(files[i], col_names = FALSE, skip = 7, sheet = which(str_detect(excel_sheets(files[i]), ".*Exchange Traded Funds"))) %>%
        select(-c(1, 9, 11, 13)) %>%
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
  
  # Create df from list and fill missing values
  xetra_df <- bind_rows(datalist_xetra) %>%
    group_by(isin) %>%
    # Fill df with new columns from December 2021
    fill(c(etf_type, xetra_ticker), .direction = "up") %>%
    ungroup()
  
}

xetra_df <- create_df()

save(xetra_df, file = "xetra_df.Rdata")

load("xetra_df.Rdata")

xetra_turnover <- xetra_df %>%
  group_by(etf_name, xetra_ticker) %>%
  summarise(turnover_sum = sum(xetra_turnover))

xetra_aum <- xetra_df %>%
  filter(month == "2022-06-30") %>%
  select(etf_name, xetra_ticker, aum) %>%
  arrange(-aum) %>%
  head(n = 10) %>%
  mutate(xetra_ticker = paste0(xetra_ticker, ".DE"))


