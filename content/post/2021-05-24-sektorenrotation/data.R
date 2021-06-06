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

setwd("/Users/jan/blog/jantau/content/post/2021-05-24-sektorenrotation") 


#----------------------------------------------------------------------------
# Find ticker symbols for sector etfs and create dataframe
#----------------------------------------------------------------------------

# US sectors
# FENY Fidelity MSCI Energy Index ETF
# FMAT	Fidelity MSCI Materials Index ETF
# FIDU	Fidelity MSCI Industrials Index ETF
# FDIS	Fidelity MSCI Consumer Discretionary Index ETF
# FSTA	Fidelity MSCI Consumer Staples Index ETF
# FHLC	Fidelity MSCI Health Care Index ETF
# FNCL	Fidelity MSCI Financials Index ETF
# FTEC	Fidelity MSCI Information Technology Index ETF
# FCOM	Fidelity MSCI Communication Services Index ETF
# FUTY	Fidelity MSCI Utilities Index ETF
# FREL	Fidelity MSCI Real Estate Index ETF
# https://app2.msci.com/eqb/ussector/indexperf/dailyperf.html
# https://app2.msci.com/eqb/ussector/performance/74775.40.all.html

sector_etfs <- data.frame(
  ticker = c("FENY", "FMAT", "FIDU", "FDIS", "FSTA", "FHLC", "FNCL", "FTEC", "FCOM", "FUTY", "FREL"),
  name = c(
    "Fidelity MSCI Energy Index ETF",
    "Fidelity MSCI Materials Index ETF",
    "Fidelity MSCI Industrials Index ETF",
    "Fidelity MSCI Consumer Discretionary Index ETF",
    "Fidelity MSCI Consumer Staples Index ETF",
    "Fidelity MSCI Health Care Index ETF",
    "Fidelity MSCI Financials Index ETF",
    "Fidelity MSCI Information Technology Index ETF",
    "Fidelity MSCI Communication Services Index ETF",
    "Fidelity MSCI Utilities Index ETF",
    "Fidelity MSCI Real Estate Index ETF"
  )
)

#----------------------------------------------------------------------------
# Load data from finance.yahoo.com
#----------------------------------------------------------------------------

sector_etfs_data <- tq_get(sector_etfs$ticker,
                           get  = "stock.prices",
                           from = "2020-01-01",
                           to = "2021-05-25")

sector_etfs_data_join <- sector_etfs_data %>%
  select(1, 2, 7, 8) %>%
  inner_join(sector_etfs, by = c("symbol" = "ticker")) %>%
  relocate(name, .after = symbol) %>%
  mutate(name_short = gsub("^.*MSCI\\s*|\\s*Index.*$", "", name), .after = name)
  
sector_etfs_data_join %>%
  ggplot(aes(x = date, y = adjusted, color = name)) +
 # geom_line() +
  geom_smooth(method = lm) +
  theme_jantau

sector_etfs_monthly_returns <-
  sector_etfs_data_join %>% group_by(symbol) %>%
  tq_transmute(select     = adjusted,
               mutate_fun = periodReturn,
               period     = "monthly") %>%
  ungroup() %>%
  inner_join(sector_etfs, by = c("symbol" = "ticker")) %>%
  relocate(name, .after = symbol) %>%
  mutate(name_short = gsub("^.*MSCI\\s*|\\s*Index.*$", "", name), .after = name)

sector_etfs_monthly_returns %>%
  filter(date >= "2021-01-01") %>%
 # filter(symbol %in% c("FENY", "FTEC", "FNCL")) %>%
  ggplot(aes(x = date, y = monthly.returns, fill = name_short)) +
  geom_col(position = "dodge")

sector_etfs_data_join %>%
  mutate(weekday = weekdays(date))
  
  
sector_etfs_data_join %>%
  group_by(symbol) %>%
  filter(date < "2021-01-01") %>%
 # filter(date >= "2021-01-01" & date <= "2021-04-30") %>%
  mutate(weekday = weekdays(date)) %>%
  filter(weekday == "Wednesday") %>%
  mutate(perc = adjusted/first(adjusted)-1) %>%
  mutate(label = if_else(date == max(date), as.character(name_short), NA_character_)) %>%
  ggplot(aes(x = date, y= perc, color = name_short)) +
  geom_line() +
 # geom_line(aes(x = date, y=rollmean(perc, 7, na.pad=TRUE), color = name_short))
 # geom_smooth(aes(x = date, y= perc, color = name_short), method = "lm", se = FALSE) +
  theme_jantau +
  theme(legend.position = "none") +
  geom_text_repel(aes(x = date + 2, label = label),
                  #     vjust = 1,
                   #    hjust = 1),
                  # force = 1, point.padding=unit(1,'lines'),
                 #  nudge_x = 1,
                #   direction = 'y',
                   na.rm = TRUE,
                  force        = 0.5,
                  nudge_x      = 0,
                  direction    = "y",
                  hjust        = 0,
                  segment.size = 0.2) +
 # coord_cartesian(clip = 'off') +
#  scale_x_date(date_labels = "%b '%y", limits = c(as.Date("2021-01-01"), as.Date("2021-05-30"))) +
  scale_x_date(date_labels = "%b '%y", limits = c(as.Date("2020-01-01"), as.Date("2021-03-29")))
  
  
  
  scale_x_date(expand = expansion(mult = 0.5))

sector_etfs_data_join %>%
  group_by(symbol) %>%
  # filter(date < "2021-01-01") %>%
  filter(date >= "2021-01-01" & date <= "2021-04-30") %>%
  mutate(weekday = weekdays(date)) %>%
  filter(weekday == "Wednesday") %>%
  mutate(perc = adjusted/first(adjusted)-1) %>%
  mutate(label = if_else(date == max(date), as.character(name_short), NA_character_)) %>%
  ggplot(aes(x = date, y= perc, color = name_short)) +
  geom_line() +
  # geom_line(aes(x = date, y=rollmean(perc, 7, na.pad=TRUE), color = name_short))
  # geom_smooth(aes(x = date, y= perc, color = name_short), method = "lm", se = FALSE) +
  theme_jantau +
  theme(legend.position = "none") +
  directlabels::geom_dl(aes(label = name_short), method = list("last.points", cex = 0.8)) +
  scale_x_date(expand=c(0, 20))

#----------------------------------------------------------------------------
# Europe vs USA
#----------------------------------------------------------------------------

# https://etfdb.com/index/msci-europe-index/


#----------------------------------------------------------------------------
# END 
#----------------------------------------------------------------------------


# Neues Thema: Börsenweisheiten. Go away in May, January, Monday ...