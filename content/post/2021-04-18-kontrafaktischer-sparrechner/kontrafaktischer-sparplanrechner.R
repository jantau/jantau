#----------------------------------------------------------------------------
# Data and code for Kontrafaktischer Sparplanrechner (counter factual savings plan calculator)
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Load R libraries and themes
#----------------------------------------------------------------------------
cat("\014") # Clear your console
rm(list = ls()) # Clear your environment

# Load in header file
source("/Users/jan/blog/jantau/content/post/header.R")


#----------------------------------------------------------------------------
# Load and transform ticker lists
#----------------------------------------------------------------------------

library(TTR)
tickersList <- stockSymbols()

tickersList <- tickersList %>%
  filter(Exchange %in% c("NASDAQ", "NYSE")) %>%
  select(1, 2, 8)

YahooTickersList <- read_excel("~/blog/Yahoo Ticker Symbols - September 2017.xlsx", 
                         sheet = "Stock", col_names = TRUE, skip = 2)

YahooTickersList <- YahooTickersList %>%
  select(1, 2, 3, 5) %>%
  group_by(Country) %>%
  filter(Country == "Germany") %>%
  distinct(Name, .keep_all = TRUE) %>%
  slice(1:200) %>%
  ungroup()

YahooTickersList <- YahooTickersList %>%
  rename(Symbol = Ticker) %>%
  select(1, 2, 3)


tickersList <- rbind(tickersList, YahooTickersList)

crypto <- data.frame(
  Symbol = c("BTC-USD", "ETH-USD", "LTC-USD"),
  Name = c("Bitcoin USD", "Ethereum USD", "Litecoin USD"),
  Exchange = rep("Crypto")
)

tickersList <- rbind(tickersList, crypto)

write.csv(tickersList,"shiny_apps/kontrafaktischer-sparplanrechner/data/tickersList.csv", row.names = FALSE)


#----------------------------------------------------------------------------
# test2 stock data manipulation for shiny app
#----------------------------------------------------------------------------

stock <- tq_get("BTC-USD",
                get  = "stock.prices",
                from = "2005-01-15",
                to = "2021-04-01")

stock <- tq_get("AAPL",
                get  = "stock.prices",
                from = "2005-01-15",
                to = "2021-04-01")


stock <- stock %>%
  select(1, 2, 8)

savings_rate <- 100

test <- stock %>%
  mutate(yearmon = floor_date(date, unit = "month"), .after = date) %>%
  group_by(yearmon) %>%
  mutate(saving = case_when(row_number(yearmon) == 1 ~  savings_rate, 
                            TRUE ~ 0)) %>%
  mutate(saving = as.integer(saving)) %>%
  ungroup() %>%
  mutate(saving_total = cumsum(saving))

test1 <- test
test2 <- test
test3 <- test

#----------------------------------------------------------------------------
# test for in loop performances
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# if () else
#----------------------------------------------------------------------------

system.time({

for(i in 1:nrow(test1)) {
  
  if (i == 1) {
    test1[i, "shares"] <- test1[i, "saving"] / test1[i, "adjusted"]
  } else{
    test1[i, "shares"] <-
      test1[(i - 1), "shares"] + (test1[i, "saving"] / test1[i, "adjusted"])
  }
  test1[i, "portfolio"] <- test1[i, "shares"] * test1[i, "adjusted"]
}
})

test1 <- test1 %>%
  mutate(performance = ((portfolio/saving_total)-1)*100)

#----------------------------------------------------------------------------
# loop without if
#----------------------------------------------------------------------------

system.time({

test2[1, "shares"] <- test2[1, "saving"] / test2[1, "adjusted"]
test2[1, "portfolio"] <- test2[1, "shares"] * test2[1, "adjusted"] 

for(i in 2:nrow(test2)) {
  
  test2[i, "shares"] <- test2[i - 1, "shares"] + (test2[i, "saving"] / test2[i, "adjusted"])
                                
  test2[i, "portfolio"] <- test2[i, "shares"] * test2[i, "adjusted"]
  
  }    
})    



#----------------------------------------------------------------------------
# loop ifelse()
#----------------------------------------------------------------------------

system.time({

for(i in 1:nrow(test3)) {

  test3[i, "shares"] <- ifelse(i == 1, test3[i, "saving"] / test3[i, "adjusted"], 
                               test3[i - 1, "shares"] + (test3[i, "saving"] / test3[i, "adjusted"]))
                               
  test3[i, "portfolio"] <- test3[i, "shares"] * test3[i, "adjusted"]
}

})  

#----------------------------------------------------------------------------
# test if identical
#----------------------------------------------------------------------------

identical(test1, test2)


#----------------------------------------------------------------------------
# System time test shows that the loop without if function is fastest
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Add CAGR to dataframe https://www.investopedia.com/terms/c/cagr.asp
#----------------------------------------------------------------------------

test2 <- test2 %>%
  mutate(diffyears = as.numeric(difftime(date, first(date), unit = "weeks"))/52.25) %>%
  mutate(cagr = ((portfolio/saving_total)^(1/diffyears) - 1) * 100)



#----------------------------------------------------------------------------
# Create highchart for shiny app
#----------------------------------------------------------------------------

highchart() %>%
  hc_add_series(
    test1,
    type = "line",
    hcaes(x = date, y = portfolio),
    name = "Apple",
    tooltip = list(pointFormat = "Kursstand {point.symbol}: <b>{point.adjusted:.1f}</b><br>Wert des Porfolios: <b>{point.portfolio:.0f}</b><br>")
  ) %>%
  hc_add_series(
    test1,
    type = "line",
    hcaes(x = date, y = saving_total),
    name = "Ansparen",
    tooltip = list(pointFormat = "Ansparsumme: <b>{point.saving_total}</b><br>Performance: <b>{point.performance:.0f} %</b>")
  ) %>%
  hc_xAxis(
    title = list(text = NULL),
    type = 'datetime') %>%
  #    hc_yAxis(type =  if_else(input$log  == TRUE, "logarithmic", "linear")) # faster
  #    hc_yAxis(type = if (input$log == TRUE) { "logarithmic" } else { "linear" }) # slower
  hc_yAxis(
    title = list(text = "Wert des Portfolios u. Ansparsumme")) %>%
  hc_tooltip(crosshairs = TRUE,
             shared = TRUE)
