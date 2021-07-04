#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Data and code for index visualizations ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load R libraries and themes ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cat("\014") # Clear your console
rm(list = ls()) # Clear your environment

# Load in header file
source("/Users/jan/blog/jantau/content/post/header.R")
setwd("/Users/jan/blog/jantau/content/post/2021-05-24-sektorenrotation") 

# Load in libraries
library(ggtext)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Find ticker symbols for sector etfs and create dataframe ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load data from finance.yahoo.com ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# sector_etfs_data <- tq_get(sector_etfs$ticker,
#                            get  = "stock.prices",
#                            from = "2020-01-01",
#                            to = "2021-06-30")
# 
# save(sector_etfs_data, file = "sector_etfs_data.Rda")
load("sector_etfs_data.Rda")

sector_etfs_data_join <- sector_etfs_data %>%
  select(1, 2, 7, 8) %>%
  inner_join(sector_etfs, by = c("symbol" = "ticker")) %>%
  relocate(name, .after = symbol) %>%
  mutate(name_short = gsub("^.*MSCI\\s*|\\s*Index.*$", "", name), .after = name)
  
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Test Visualization ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# sector_etfs_data_join %>%
#   ggplot(aes(x = date, y = adjusted, color = name)) +
#   geom_line() +
#   geom_smooth(method = lm) +
#   theme_jantau

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Monthly Return ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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
   filter(date >= "2020-06-30") %>%
  filter(name_short %in% c("Information Technology", "Energy")) %>%
  # filter(symbol %in% c("FENY", "FTEC", "FNCL")) %>%
  ggplot(aes(x = date, y = monthly.returns, fill = name_short)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c("#792427", "#2B818E")) +
  theme_jantau +
  theme(legend.position = "none",
        plot.title = element_markdown(),
        axis.title.x = element_blank()) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Sektoren <span style='color:#2B818E;'>Information Tech</span> vs. <span style='color:#792427;'>Energy</span>",
    subtitle = "Januar 2020 bis Juni 2021",
    y = "Performance in %",
    caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com"
  ) 

ggsave("sectors_barplot.png", scale = .75)
  
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Volatility monthly ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# test with https://www.portfoliovisualizer.com/backtest-portfolio#analysisResults

pal <- got(1, option = "Daenerys", direction = -1)

sector_etfs_monthly_returns %>% 
  filter(date >= "2020-07-01") %>%
  group_by(name_short) %>% 
  mutate(monthly.returns = monthly.returns) %>%
  summarize(SD = sd(monthly.returns)) %>% 
  arrange(desc(SD)) %>%
  ggplot(aes(x = reorder(name_short, - SD), y = SD)) +
  geom_col(fill = pal) +
  theme_jantau +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
  labs(title = "Volatilität",
       subtitle = "nach Sektoren vom 1.7.2020 bis 30.6.2021",
       caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com",
       x = "Sektor",
       y = "Monatliche Volatilität") +
  scale_y_continuous(labels = scales::percent)

ggsave("monthly_volatility.png", scale = .75) 

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sector rotation Inf Tech and Energy ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
sector_etfs_data_join %>%
  group_by(symbol) %>%
  filter(name_short %in% c("Information Technology", "Energy")) %>%
  filter(date >= "2020-07-01" & date <= "2020-12-31") %>%
 # filter(date >= "2021-01-01" & date <= "2021-04-30") %>%
#  mutate(weekday = weekdays(date)) %>%
 # filter(weekday == "Wednesday") %>%
  mutate(perc = adjusted/first(adjusted)-1) %>%
  mutate(label = if_else(date == max(date), as.character(name_short), NA_character_)) %>%
  ggplot(aes(x = date, y= perc, color = name_short)) + #
  geom_smooth(span = 0.3, se = F) +
  geom_line() +
  scale_color_manual(values = c("#792427", "#2B818E")) +
  theme_jantau +
  theme(legend.position = "none",
        plot.title = element_markdown(),
        axis.title.x = element_blank()) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Sektor <span style='color:#2B818E;'>Information Technology</span> vs. <span style='color:#792427;'>Energy</span>",
    subtitle = "Juli bis Dezember 2020", 
    x = "",
    y = "Performance in %",
    caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com"
  ) 

ggsave("sectors_2020.png", scale = .75) 


sector_etfs_data_join %>%
  group_by(symbol) %>%
  filter(name_short %in% c("Information Technology", "Energy")) %>%
  # filter(date < "2021-01-01") %>%
  filter(date >= "2021-01-01" & date <= "2021-06-30") %>%
 # filter(date >= "2020-07-01" & date <= "2021-06-30") %>%
#  mutate(weekday = weekdays(date)) %>%
#  filter(weekday == "Wednesday") %>%
  mutate(perc = adjusted/first(adjusted)-1) %>%
  mutate(label = if_else(date == max(date), as.character(name_short), NA_character_)) %>%
  ggplot(aes(x = date, y= perc, color = name_short)) +
  geom_smooth(span = 0.3, se = F) +
  geom_line() +
  scale_color_manual(values = c("#792427", "#2B818E")) +
  theme_jantau +
  theme(legend.position = "none",
        plot.title = element_markdown(),
        axis.title.x = element_blank()) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Sektor <span style='color:#2B818EFF;'>Information Technology</span> vs. <span style='color:#792427FF;'>Energy</span>",
    subtitle = "Januar bis Juni 2021", 
    x = "",
    y = "Performance in %",
    caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com"
  )

ggsave("sectors_2020_2021.png", scale = .75) 


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Europe vs USA
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# https://etfdb.com/index/msci-europe-index/

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Correlation ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library(corrplot)
# https://cran.r-project.org/web/packages/corrplot/vignettes/corrplot-intro.html
# https://www.investopedia.com/terms/c/correlationcoefficient.asp

M <- sector_etfs_data_join %>%
  select(3, 4, 6) %>%
  spread(name_short, adjusted)
M <- cor(M[,-1], use="pairwise.complete.obs", method = "pearson")

corrplot(M, method = "number", order = "AOE", type = "lower")

png(height=700, width=700, pointsize = 16, file="corrp.png") 

corrplot(M, 
         method = "number",
         order = "AOE",
         tl.col="black",
         type = "upper",
         title = "Korrelogramm der Sektoren (Januar 2020 bis Juni 2021)", 
         # https://stackoverflow.com/questions/40509217/how-to-have-r-corrplot-title-position-correct
         mar=c(0,0,1,0))
dev.off()

# https://www.dummies.com/programming/r/how-to-save-graphics-to-an-image-file-in-r/
# https://blog.hasanbul.li/2018/01/14/exporting-correlation-plots/

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Volatility daily ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sector_etfs_daily_returns <-
  sector_etfs_data_join %>% group_by(symbol) %>%
  tq_transmute(select     = adjusted,
               mutate_fun = periodReturn,
               period     = "daily") %>%
  ungroup() %>%
  inner_join(sector_etfs, by = c("symbol" = "ticker")) %>%
  relocate(name, .after = symbol) %>%
  mutate(name_short = gsub("^.*MSCI\\s*|\\s*Index.*$", "", name), .after = name)

sector_etfs_daily_returns %>% 
  group_by(name_short) %>% 
  mutate(daily.returns = daily.returns * 100) %>%
  summarize(SD = sd(daily.returns)) %>% 
  arrange(desc(SD))

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Volatility yearly ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sector_etfs_yearly_returns <-
  sector_etfs_data_join %>% group_by(symbol) %>% filter(date <= "2020-12-31") %>%
  tq_transmute(select     = adjusted,
               mutate_fun = periodReturn,
               period     = "yearly") %>%
  ungroup() %>%
  inner_join(sector_etfs, by = c("symbol" = "ticker")) %>%
  relocate(name, .after = symbol) %>%
  mutate(name_short = gsub("^.*MSCI\\s*|\\s*Index.*$", "", name), .after = name)

sector_etfs_yearly_returns %>% 
  group_by(name_short) %>% 
  mutate(yearly.returns = yearly.returns * 100) %>%
  summarize(SD = sd(yearly.returns)) %>% 
  arrange(desc(SD))

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# END ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++