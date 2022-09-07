#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Data and code for best day to invest ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load R libraries and themes ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cat("\014") # Clear your console
rm(list = ls()) # Clear your environment

# Load in header file
source("./content/post/header.R")
setwd("./content/post/2022-07-31-sparplantag-2") 

# Define variable savings rate
savings_rate = 1000
load("xetra_df.Rdata")

xetra_aum <- xetra_df %>%
  filter(income_treatment == "Accumulating") %>%
  filter(month == "2022-07-31") %>%
  arrange(-aum) %>%
  head(n = 100) %>%
  mutate(xetra_ticker = paste0(xetra_ticker, ".DE"))


# Find oldest ETFs
etf_data <- tq_get(xetra_aum$xetra_ticker,
                   get  = "stock.prices",
                   from = "2012-07-01",
                   to = "2012-07-30") %>%
  select(symbol, date, adjusted)

etf_oldest <- etf_data %>% distinct(symbol, .keep_all = TRUE) %>% head(15)

etf_old <- etf_oldest %>% select(symbol) %>%
  left_join(xetra_aum, by = c("symbol" = "xetra_ticker"))

# Vector with ten biggest, accumulating XETRA ETFs with fund age > 10
etfs <- etf_old %>% head(10) %>% pull(symbol)


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Loops for best day to invest ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Create lists for results
datalist <- list()
datalist_final <- list()

# 1. loop to query vector of ETF ticker symbols
for(x in etfs) {
  etf_data <- tq_get(x,
                     get  = "stock.prices",
                     from = "2012-09-01", 
                     to = "2022-09-01") %>% 
    select(symbol, date, adjusted)
  
# 2. loop to prepare data
  for (y in seq(31)) {
    data <- etf_data %>%
      mutate(yearmon = floor_date(date, unit = "month"),
             .after = date) %>%
      mutate(day = substr(date, start = 9, stop = 10)) %>%
      mutate(day = as.numeric(day)) %>%
      complete(symbol, yearmon, day, fill = list(NA)) %>%
      fill(adjusted, .direction = "updown") %>%
      filter(day == y) %>% # | row_number() == n()
      mutate(savings = row_number() * savings_rate) %>%
      mutate(
        shares = ifelse(row_number() == 1, savings_rate / adjusted, NA)
      )
    
# 3. loop to simulate saving plans    
    for (z in 2:nrow(data)) {
      data[z, "shares"] <-
        data[z - 1, "shares"] + (savings_rate / data[z, "adjusted"])
    }
    
    etf_data_last <- etf_data %>%
      filter(row_number() == n())
    
    data <- bind_rows(data, etf_data_last) %>%
      fill(savings, shares, .direction = "down") %>%
      mutate(portfolio = adjusted * shares,
             day = y) %>%
      tail(1)
    
    datalist[[y]] <- data
    
  }

data <- bind_rows(datalist)
  
datalist_final[[x]] <- data  

}

data <- bind_rows(datalist_final)

data_result <- data %>%
  select(-yearmon) %>%
  group_by(symbol) %>%
  mutate(day_type = case_when(portfolio == max(portfolio) ~ "best_day",
                              portfolio == min(portfolio) ~ "worst_day")) %>%
  ungroup()

data_result <- data_result %>%
  group_by(symbol) %>%
  mutate(abs_perf = portfolio - savings) %>%
  mutate(perc_perf = max(abs_perf)/min(abs_perf)-1) %>%
  mutate(perc_perf_total = (portfolio / savings - 1) * 100) %>%
  ungroup()
  
data_result <- data_result %>%
  group_by(symbol) %>%
  mutate(rank = dense_rank(-portfolio)) %>%
  ungroup() %>%
  arrange(symbol, rank, decreasing = TRUE) %>%
  mutate(symbol = fct_reorder(symbol, -perc_perf_total))

data_ranked <- data_result %>%
  group_by(day) %>%
  summarise(mean_rank = mean(rank)) %>%
  ungroup() %>%
  mutate(rank = dense_rank(mean_rank)) %>%
  mutate(color = case_when(rank <= 5 ~ "A",
                           rank >= 27 ~ "C",
                           TRUE ~ "B"))


data_ranked_symbol <- data_result %>%
  group_by(symbol, day, perc_perf_total) %>%
  summarise(mean_rank = mean(rank)) %>%
  ungroup() %>%
  mutate(rank = dense_rank(mean_rank)) %>%
  mutate(color = case_when(rank <= 5 ~ "A",
                           rank >= 27 ~ "C",
                           TRUE ~ "B")) 

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Table with ETFs for blog post ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

etf_table <- data_result %>%
  filter(rank == 1) %>%
  mutate(savings = savings/savings_rate) %>%
  select(symbol, savings, perc_perf_total) %>%
  left_join(xetra_aum %>% select(etf_name, xetra_ticker, aum), by = c("symbol" = "xetra_ticker")) %>%
  mutate(etf_name = str_remove(etf_name, " UCITS.*$")) %>%
  mutate(perc_perf_total = round(perc_perf_total, 1),
         aum = round(aum, 1)) %>%
  arrange(-aum) %>%
  select(ETF = etf_name, Ticker = symbol, `Größe ETF.<br>(in Mio. EUR)` = aum, `Sparplandauer<br>(in Monaten)` = savings, `Rendite<br>(in %)<sup>1` = perc_perf_total)
  

save(etf_table, file = "etf_table.Rdata")

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Charts for blog post ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

label_1 <- c("Die besten 5 Tage\nfür die langfristige Investition\nin einen monatlichen ETF-Sparplan")
label_2 <- c("Die schlechtesten 5 Tage\nfür die langfristige Investition\nin einen monatlichen ETF-Sparplan")

pal <- got(3, option = "Daenerys", direction = 1)

data_ranked %>%
  ggplot(aes(x = day, y = rank, label = rank, fill = color)) +
  geom_col() +
  geom_text(size = 2.5, vjust = 1.2, colour = "white") +
  annotate("label", fill = "white", label.size = NA, x = 10, y = 20, label = label_1, size = 3, color = pal[2]) +
  geom_curve(x = 5,
             y = 20,
             xend = 3,
             yend = 4,
             curvature = 0.6,
             angle = 60,
             ncp = 20,
             arrow = arrow(length = unit(0.2,"cm"), type = "closed"),
             color = pal[2],
             size = 0.5,
             linetype = 1) +
  annotate("label", fill = "white", label.size = NA, x = 15, y = 28, label = label_2, size = 3, color = pal[1]) +
  geom_curve(x = 20,
             y = 28,
             xend = 29,
             yend = 29.6,
             curvature = -0.6,
             angle = 50,
             ncp = 40,
             arrow = arrow(length = unit(0.2,"cm"), type = "closed"),
             color = pal[1],
             size = 0.5,
             linetype = 1) +
  scale_x_continuous(
    breaks= c(1:31),
    labels = c("1\nTag im Monat", as.character(2:31))) +
  scale_y_continuous(
    breaks= c(1:31),
    labels = c("Rang 1", as.character(2:31))) +
  scale_fill_manual(values = pal[c(2,3,1)]) +
  theme_jantau +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.grid.major.y = element_line(color = "grey",
                                          size = 0.2,
                                          linetype = 3),
        legend.position = "none",
        plot.title = element_markdown(size = 13,
                                      face = "plain",
                                      hjust = 0,
                                      margin = ggplot2::margin(0, 0, 10, 0)),
        plot.subtitle = element_markdown(size = 8,
                                      face = "plain",
                                      hjust = 0,
                                      margin = ggplot2::margin(0, 0, 10, 0)),
        plot.caption = element_markdown(size = 6,
                                         face = "plain",
                                         hjust = 0)) +
  labs(title = "Die <span style='color:#2B818E;'>besten</span> und die <span style='color:#792427;'>schlechtesten</span> Tage<br>für die langfristige Investition in einen monatlichen ETF-Sparplan",
       subtitle = "Durchschnittswert der 10 größten, thesaurierenden, XETRA-gehandelten ETFs mit einem Fondsalter > 10 Jahre<br>
       Sparplansimulation von 09/2012 bis 08/2022 mit monatlich konstanter Einlage",
       caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com")

ggsave("barchart_ranking_sparplantag.png", scale = 1)


data_ranked_symbol_join <- data_ranked_symbol %>%
  left_join(xetra_aum %>% select(etf_name, xetra_ticker), by = c("symbol" = "xetra_ticker")) %>%
  mutate(etf_name = fct_reorder(etf_name, symbol)) %>%
  mutate(etf_name = str_remove(etf_name, " UCITS.*$")) %>%
  group_by(symbol) %>%
  mutate(etf_name = paste0(etf_name, ", ", round(max(perc_perf_total)), "%")) %>%
  ungroup() %>%
  mutate(etf_name = fct_reorder(etf_name, -perc_perf_total))

data_ranked_symbol_join %>%
  ggplot(aes(x = day, y = rank, label = rank, fill = color)) +
  geom_col() +
  facet_wrap(~ etf_name, ncol = 2) +
  scale_x_continuous(
    breaks= seq(1, 31, 2),
    labels = c("1\nTag", as.character(seq(3, 31, 2)))) +
  scale_y_continuous(
    breaks= seq(1, 31, 2),
    labels = c("Rang 1", as.character(seq(3, 31, 2)))) +
  scale_fill_manual(values = pal[c(2,3,1)]) +
  theme_jantau +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text = element_text(size = 7),
        panel.grid.major.y = element_line(color = "grey",
                                          size = 0.2,
                                          linetype = 3),
        legend.position = "none",
        plot.title = element_markdown(size = 14,
                                      face = "plain",
                                      hjust = 0,
                                      margin = ggplot2::margin(0, 0, 10, 0)),
        plot.subtitle = element_markdown(size = 9,
                                         face = "plain",
                                         hjust = 0,
                                         margin = ggplot2::margin(0, 0, 10, 0)),
        plot.caption = element_markdown(size = 7,
                                        face = "plain",
                                        hjust = 0)) +
  labs(title = "Die <span style='color:#2B818E;'>besten</span> und die <span style='color:#792427;'>schlechtesten</span> Tage<br>für die langfristige Investition in einen monatlichen ETF-Sparplan",
       subtitle = "Einzeldarstellung der 10 größten, thesaurierenden, XETRA-gehandelten ETFs mit einem Fondsalter > 10 Jahre<br>
       Sparplansimulation von 09/2012 bis 08/2022 mit monatlich konstanter Einlage<br>
       ETFs sortiert nach Höhe der Rendite eines monatlichen Sparplans über 10 Jahre (2012-2022)",
       caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com")

ggsave("barchart_ranking_sparplantag_all.png", scale = 1, width = 7, height = 10, units = "in")


data_ranked_symbol_join_perc <- data_ranked_symbol_join %>%
  group_by(symbol) %>%
  mutate(perc_perf_norm = (perc_perf_total - max(perc_perf_total)) / 100)

data_ranked_symbol_join_perc %>%
  ggplot(aes(x = day, y = perc_perf_norm, label = rank, fill = color)) +
  geom_col() +
  facet_wrap(~ etf_name, ncol = 2) +
  scale_x_continuous(
    breaks= seq(1, 31, 2),
    labels = c("1\nTag", as.character(seq(3, 31, 2)))) +
   scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = pal[c(2,3,1)]) +
  theme_jantau +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text = element_text(size = 7),
        panel.grid.major.y = element_line(color = "grey",
                                          size = 0.2,
                                          linetype = 3),
        legend.position = "none",
        plot.title = element_markdown(size = 14,
                                      face = "plain",
                                      hjust = 0,
                                      margin = ggplot2::margin(0, 0, 10, 0)),
        plot.subtitle = element_markdown(size = 9,
                                         face = "plain",
                                         hjust = 0,
                                         margin = ggplot2::margin(0, 0, 10, 0)),
        plot.caption = element_markdown(size = 7,
                                        face = "plain",
                                        hjust = 0)) +
  labs(title = "Renditeunterschiede der <span style='color:#2B818E;'>besten</span> und der <span style='color:#792427;'>schlechtesten</span> Tage<br>
       bei der langfristigen Investition in einen monatlichen ETF-Sparplan",
       subtitle = "Einzeldarstellung der 10 größten, thesaurierenden, XETRA-gehandelten ETFs mit einem Fondsalter > 10 Jahre<br>
       Sparplansimulation von 09/2012 bis 08/2022 mit monatlich konstanter Einlage<br>
       ETFs sortiert nach Höhe der Rendite eines monatlichen Sparplans über 10 Jahre (2012-2022)",
       caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com")


ggsave("barchart_ranking_sparplantag_all_perc.png", scale = 1, width = 7, height = 10, units = "in")

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Dump: Scatter charts  ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


data_result %>%
  ggplot(aes(day, rank, color = symbol)) + 
  geom_jitter(alpha = 0.5) + 
  stat_smooth(method = "lm", col = "grey", se = FALSE) +
  scale_x_continuous(
    breaks= c(1:31),
    labels = c("Tag\n1", as.character(2:31))) +
  scale_y_continuous(
    breaks= c(1:31),
    labels = c("Rang\n1", as.character(2:31))) +
  theme(panel.grid.major = element_blank()) 
theme_jantau

data_result %>%
  ggplot(aes(day, rank, color = symbol)) + geom_point() + stat_smooth(method = "loess", col = "grey", se = FALSE) + facet_wrap(~symbol) + 
  scale_x_continuous(
    breaks= c(1:31),
    labels = c("Tag\n1", as.character(2:31))) +
  scale_y_continuous(
    breaks= c(1:31),
    labels = c("Rang\n1", as.character(2:31))) +
  theme(panel.grid.major = element_blank()) 

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Dump: Dumbbell charts  ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

test_bell <- data_result %>%
  filter(day_type %in% c("best_day", "worst_day")) %>%
  left_join(xetra_aum %>% select(etf_name, xetra_ticker), by = c("symbol" = "xetra_ticker")) %>%
  mutate(etf_name = fct_reorder(etf_name, -perc_perf_total))

test_bell %>%
  plot_ly(x = ~ perc_perf_total,
          y = ~ etf_name,
          showlegend = FALSE) %>%
  add_markers(marker = list(opacity = 0.8,
                            color = ~if_else(day_type == "best_day", "green", "red"))) %>%
  # add_text(data = test_bell %>% filter(as.integer(etf_name) == 1 & day_type == "best_day"), text = ~ paste0(day, ". = bester Tag"), textposition = "top right") %>% 
  add_text(data = test_bell %>% filter(day_type == "best_day"), text = ~ day, textposition = "top right") %>% #as.integer(symbol) == 1 & 
  #  add_text(data = test_bell %>% filter(as.integer(etf_name) == 1 & day_type == "worst_day"), text = ~ paste0(day, ". = schlechtester Tag"), textposition = "bottom right") %>% 
  add_text(data = test_bell %>% filter(day_type == "worst_day"), text = ~ day, textposition = "top left") %>%
  layout(xaxis = list(), #type = "log" range = c(0, 13000)
         yaxis = list(autorange = "reversed"))

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# End ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

