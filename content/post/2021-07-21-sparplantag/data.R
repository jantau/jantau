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
setwd("/Users/jan/blog/jantau/content/post/2021-07-21-sparplantag") 

# etf_data <- tq_get("IWDA.L",
#                            get  = "stock.prices",
#                            from = "2010-01-01",
#                            to = "2021-06-30")
# 
# save(etf_data, file = "etf_data.Rda")
load("etf_data.Rda")


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Manipulate data and create savings plan ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

data_1 <- etf_data %>%
  select(1:3)

savings_rate <- 1000

data_2 <- data_1 %>%
  mutate(yearmon = floor_date(date, unit = "month"), .after = date) %>%
  mutate(day = substr(date, start = 9, stop = 10)) %>%
  mutate(day = as.numeric(day)) %>%
  group_by(yearmon) %>%
  filter(day >= 5) %>%
  slice(1L) %>% # workaround for picking first value that is equal/greater 5
  mutate(saving = savings_rate) %>%
  ungroup() %>%
  full_join(data_1, by = c("symbol", "date", "open")) %>%
  arrange(date) %>%
  select(-yearmon, -day) %>%
  mutate(saving = replace_na(saving, 0)) %>%
  mutate(saving_total = cumsum(saving)) %>%
  drop_na()

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Savings plan looping ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

data_2[1, "shares"] <- data_2[1, "saving"] / data_2[1, "open"]
data_2[1, "portfolio"] <- data_2[1, "shares"] * data_2[1, "open"] 

for(i in 2:nrow(data_2)) {
  
  data_2[i, "shares"] <- data_2[i - 1, "shares"] + (data_2[i, "saving"] / data_2[i, "open"])
  
  data_2[i, "portfolio"] <- data_2[i, "shares"] * data_2[i, "open"]
  
}  

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Second savings plan ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

data_3 <- data_1 %>%
  mutate(yearmon = floor_date(date, unit = "month"), .after = date) %>%
  mutate(day = substr(date, start = 9, stop = 10)) %>%
  mutate(day = as.numeric(day)) %>%
  group_by(yearmon) %>%
  filter(day >= 20) %>%
  slice(1L) %>% # workaround for picking first value that is equal/greater 5
  mutate(saving = savings_rate) %>%
  ungroup() %>%
  full_join(data_1, by = c("symbol", "date", "open")) %>%
  arrange(date) %>%
  select(-yearmon, -day) %>%
  mutate(saving = replace_na(saving, 0)) %>%
  mutate(saving_total = cumsum(saving)) %>%
  drop_na()

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Savings plan looping ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

data_3[1, "shares"] <- data_3[1, "saving"] / data_3[1, "open"]
data_3[1, "portfolio"] <- data_3[1, "shares"] * data_3[1, "open"] 

for(i in 2:nrow(data_3)) {
  
  data_3[i, "shares"] <- data_3[i - 1, "shares"] + (data_3[i, "saving"] / data_3[i, "open"])
  
  data_3[i, "portfolio"] <- data_3[i, "shares"] * data_3[i, "open"]
  
}  


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Plot ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

pal <- got(2, option = "Daenerys", direction = -1)

ggplot() +
  geom_line(data = data_3, aes(x = date, y = portfolio, color = "monatl. Ausführungstag = 20."), alpha = 0.8) + #color = pal[1],
  geom_line(data = data_2, aes(x = date, y = portfolio, color = "monatl. Ausführungstag = 05."),  alpha = 0.8) + #color = pal[2],
#  geom_line(data = data_2, aes(x = date, y = saving_total)) +
  geom_ribbon(data = data_2,
              aes(
    x = date,
    ymin = 0,
    ymax = saving_total,
    fill = "Ansparen"
  ),
  alpha = .5) +
  theme_jantau +
  scale_x_date(
    date_breaks = "years",
    date_labels = "%Y",
    limits = c(as.Date("2010-01-01"), as.Date("2021-10-01"))
  ) +
  scale_y_continuous(labels = dollar_format(
    big.mark = " ",
    decimal.mark = ",",
    suffix = " €",
    prefix = ""
  )) +
  scale_color_manual(values = pal, name = element_blank()) +
  scale_fill_manual(values = "grey", name = element_blank()) +
  theme(legend.position = "top",
# c(0.3, 0.7)
legend.direction = "horizontal") +
  labs(
    title = "Sparplanwert bei unterschiedl. Ausführungstagen",
    subtitle = "bei einem monatl. Sparplan von 1000 € auf den MSCI World",
    caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com",
    y = "Sparplanwert") +
  theme(axis.title.x = element_blank()) +
  geom_label(
    data = data_3 %>% filter(portfolio == last(portfolio)),
    aes(x = date-800, y = portfolio-12000, label = paste0("Endwert ", round(portfolio), " €")),
    alpha = 0.8,
    show.legend = FALSE,
    color = pal[2]
  ) +
  geom_label(
    data = data_2 %>% filter(portfolio == last(portfolio)),
    aes(x = date-800, y = portfolio+12000, label = paste0("Endwert ", round(portfolio), " €")),
    alpha = 0.8,
    show.legend = FALSE,
    color = pal[1]
  ) 

ggsave("linechart_anlagetag.png", scale = .75)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Looping ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

data_4 <- setNames(data.frame(matrix(NA, nrow = 23, ncol = 2)), c("day", "portfolio"))

data_5 <- setNames(data.frame(matrix(NA, nrow = 2897, ncol = 24)), c(1:23, "date"))
data_5[ , "date"] <- data_3$date



for(x in 1:23) {

data_3 <- data_1 %>%
  mutate(yearmon = floor_date(date, unit = "month"), .after = date) %>%
  mutate(day = substr(date, start = 9, stop = 10)) %>%
  mutate(day = as.numeric(day)) %>%
  group_by(yearmon) %>%
  filter(day >= x) %>%
  slice(1L) %>% # workaround for picking first value that is equal/greater 5
  mutate(saving = savings_rate) %>%
  ungroup() %>%
  full_join(data_1, by = c("symbol", "date", "open")) %>%
  arrange(date) %>%
  select(-yearmon, -day) %>%
  mutate(saving = replace_na(saving, 0)) %>%
  mutate(saving_total = cumsum(saving)) %>%
  drop_na()

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Savings plan looping ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

data_3[1, "shares"] <- data_3[1, "saving"] / data_3[1, "open"]
data_3[1, "portfolio"] <- data_3[1, "shares"] * data_3[1, "open"] 

for(i in 2:nrow(data_3)) {
  
  data_3[i, "shares"] <- data_3[i - 1, "shares"] + (data_3[i, "saving"] / data_3[i, "open"])
  
  data_3[i, "portfolio"] <- data_3[i, "shares"] * data_3[i, "open"]
  
}  

data_4[x, "day"] <- x
data_4[x, "portfolio"] <- last(data_3$portfolio)

data_5[ , x] <- data_3$portfolio

}  

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Analysis ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

data_6 <- data_4 %>%
  arrange(-portfolio) %>%
  mutate(absolute =  portfolio - first(portfolio)) %>%
  mutate(perc = (1-first(portfolio)/portfolio) * 100) %>%
  mutate(saving = 138000) %>%
  mutate(performance_perc = (portfolio / saving - 1) * 100) %>%
  mutate(performance_loss = performance_perc - first(performance_perc))

pal <- got(1, option = "Daenerys", direction = 1)

ggplot(data_6, aes(x = day, y = performance_loss)) +
  geom_col(fill = pal) +
  theme_jantau +
  scale_x_continuous(breaks = c(1:23)) +
  scale_y_continuous(labels = dollar_format(
    big.mark = " ",
    decimal.mark = ",",
    suffix = " %",
    prefix = ""
  )) +
  labs(title = "Performanceverlust unterschiedl. Ausführungstage",
       subtitle = "bei einem monatl. Aktiensparplan auf den MSCI World (2010-2021)",
       caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com",
       x = "Ausführungstagtag",
       y = "Performanceverlust (in %)") +
  geom_label(aes(x = day, y = performance_loss, label = paste0(round(performance_loss, 2), " %")), 
             size = 3, alpha = 0.8)

ggsave("barchart_anlagetag_performance_verlust.png", scale = .75)

ggplot(data_6, aes(x = day, y = absolute)) +
  geom_col() +
  theme_jantau


data_7 <- data_5 %>%
  pivot_longer(cols = c(1:23), names_to = "day", values_to = "portfolio") %>%
  mutate(yearmon = floor_date(date, unit = "month"), .after = date) %>%
  group_by(date) %>%
  mutate(absolute = portfolio - portfolio[day == 1]) %>%
  mutate(perc = (1 - portfolio[day == 1] / portfolio) * 100)

data_7 %>%
  filter(date >= "2010-01-01") %>%
  group_by(yearmon) %>%
  filter(date == last(date)) %>%
  filter(day %in% c(1, 5, 10, 15, 20, 23)) %>%
  ggplot(aes(x = date, y = absolute, color = day)) +
  geom_line() +
  theme_jantau +
  theme(legend.position = "none",
        axis.title.x = element_blank()) +
  scale_x_date(
    date_breaks = "years",
    date_labels = "%Y",
    limits = c(as.Date("2010-01-01"), as.Date("2021-10-01"))
  ) +
  scale_y_continuous(labels = dollar_format(
    big.mark = " ",
    decimal.mark = ",",
    suffix = " €",
    prefix = ""
  )) +
  scale_color_got_d(option = "Daenerys", direction = 1) +
  labs(caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com",
       title = "Performanceverlust unterschiedl. Ausführungstage",
       subtitle = "bei einem monatl. Aktiensparplan auf den MSCI World",
       y = "Performanceverlust (in €)" ) +
  geom_label_repel(data =
                     data_7 %>%
                     ungroup() %>%
                     filter(day %in% c(1, 5, 10, 15, 20, 23)) %>%
                     filter(date == last(date)),
                   aes(label = day))

ggsave("linechart_20_Jahre_anlagetag.png", scale = .75)

data_7 %>%
  filter(date >= "2013-01-01") %>%
  group_by(yearmon) %>%
  filter(date == last(date)) %>%
  filter(day %in% c(1, 5, 10, 15, 20, 23)) %>%
  ggplot(aes(x = date, y = perc, color = day)) +
  geom_line() 

ggsave("linechart_20_Jahre_anlagetag_procent.png", scale = .75)

# Möglicherweise profitieren Banken davon, wenn das Geld der Anleger länger auf dem Depotkonto liegt. In Zeiten von negativen Zinsen und Verwahrgebühren kann ich mir jedoch nicht vorstellen, dass die Banken viel Interesse an den geparkten Geldern haben.
# Vielleicht kommt die Investition später im Monat auch denjenigen zugute, die ihr Budget nicht immer gut planen können und erst zum Ende des Monats abschätzen können, ob sie Geld zum Investieren über haben. Möglicherweise gibt es auch den psychologischen Effekt, dass Leute ihr erarbeitetes Geld noch eine Weile auf dem Konto sehen möchten, bevor es im Depot verschwindet (kein wirklich gutes Argument).
# Ich kann mir vorstellen, dass der 1. Tag eines Monats nicht der beste Zeitpunkt ist, da noch nicht alle Anleger ihr Gehalt bekommen haben beziehungsweise noch ein, zwei Tage benötigen, um es auf ihr Depotkonto weiterzuleiten. Für viele sollte jedoch ein Tag um den 5.  des Monats ein guter Anlagetag sein. 
