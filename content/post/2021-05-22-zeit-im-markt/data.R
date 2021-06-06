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

setwd("/Users/jan/blog/jantau/content/post/2021-05-22-zeit-im-markt") 

#----------------------------------------------------------------------------
# Load data
#----------------------------------------------------------------------------

index <- read_csv("/Users/jan/blog/jantau/content/post/2021-05-07-der-beste-zeitpunkt/index.csv")

#----------------------------------------------------------------------------
# Manipulate data and create savings plan
#----------------------------------------------------------------------------

dax <- index %>%
  filter(symbol == "^GDAXI") %>%
  filter(date >= "1991-01-01") %>%
  select(1, 2, 8) %>%
  drop_na()

savings_rate <- 1000

dax_saving <- dax %>%
  mutate(yearmon = floor_date(date, unit = "month"), .after = date) %>%
  group_by(yearmon) %>%
  mutate(saving = case_when(row_number(yearmon) == 1 ~  savings_rate,
                            TRUE ~ 0)) %>%
  mutate(saving = as.integer(saving)) %>%
  ungroup() %>%
  mutate(saving_total = cumsum(saving))

#----------------------------------------------------------------------------
# looping
#----------------------------------------------------------------------------

dax_saving[1, "shares"] <- dax_saving[1, "saving"] / dax_saving[1, "adjusted"]
dax_saving[1, "portfolio"] <- dax_saving[1, "shares"] * dax_saving[1, "adjusted"] 

for(i in 2:nrow(dax_saving)) {
  
  dax_saving[i, "shares"] <- dax_saving[i - 1, "shares"] + (dax_saving[i, "saving"] / dax_saving[i, "adjusted"])
  
  dax_saving[i, "portfolio"] <- dax_saving[i, "shares"] * dax_saving[i, "adjusted"]
  
}    

#----------------------------------------------------------------------------
# 5 years period grouping
#----------------------------------------------------------------------------

dax_saving <- dax_saving %>%
  mutate(period = case_when(date <= "1995-12-31" ~ "1991-1995",
                            date > "1995-12-31" & date <= "2000-12-31" ~ "1996-2000",
                            date > "2000-12-31" & date <= "2005-12-31" ~ "2001-2005",
                            date > "2005-12-31" & date <= "2010-12-31" ~ "2006-2010",
                            date > "2010-12-31" & date <= "2015-12-31" ~ "2011-2015",
                            date > "2015-12-31" & date <= "2020-12-31" ~ "2016-2020",
  ))

dax_saving_join <- dax_saving %>%
  group_by(period) %>%
  summarise(max_shares = max(shares)) %>%
  ungroup() %>%
  mutate(shares_period = max_shares - lag(max_shares)) %>%
  mutate(shares_period = replace_na(shares_period, first(max_shares))) %>%
  select(1, 3)

dax_saving <- inner_join(dax_saving, dax_saving_join)

dax_saving <- dax_saving %>%
  mutate(p1991_1995 = ifelse(date <= "1995-12-31", shares, dax_saving_join$shares_period[1]),
         p1996_2000 = ifelse(date <= "1995-12-31", 0, ifelse(date > "1995-12-31" & date <= "2000-12-31", shares - p1991_1995, dax_saving_join$shares_period[2])),
         p2001_2005 = ifelse(date <= "2000-12-31", 0, ifelse(date > "2000-12-31" & date <= "2005-12-31", shares - p1991_1995 - p1996_2000, dax_saving_join$shares_period[3])),
         p2006_2010 = ifelse(date <= "2005-12-31", 0, ifelse(date > "2005-12-31" & date <= "2010-12-31", shares - p1991_1995 - p1996_2000 - p2001_2005, dax_saving_join$shares_period[4])),
         p2011_2015 = ifelse(date <= "2010-12-31", 0, ifelse(date > "2010-12-31" & date <= "2015-12-31", shares - p1991_1995 - p1996_2000 - p2001_2005 - p2006_2010, dax_saving_join$shares_period[5])),
         p2016_2020 = ifelse(date <= "2015-12-31", 0, ifelse(date > "2015-12-31" & date <= "2020-12-31", shares - p1991_1995 - p1996_2000 - p2001_2005 - p2006_2010 - p2011_2015, dax_saving_join$shares_period[6]))
         )

dax_period <- dax_saving %>%
  select(2, 4, 11, 12, 13, 14, 15, 16)

dax_period <- dax_period %>%
  pivot_longer(cols = starts_with("p"), names_to = "period", values_to = "shares") %>%
  mutate(portfolio = ifelse(shares == 0, 0, adjusted * shares)) %>%
  mutate(period = substr(period, 2, 13)) %>%
  mutate(period = str_replace(period, "_", "-")) %>%
  mutate(period = factor(period, levels = c("2016-2020", "2011-2015", "2006-2010", "2001-2005", "1996-2000", "1991-1995")))

dax_period %>%
  ggplot(aes(x = date, y = portfolio, fill = period)) +
  geom_area(alpha = 1, size = 0.01, colour = "white") +
  scale_fill_got_d(option = "Daenerys", direction = -1) +
  theme_jantau +
  labs(title = "Titel",
       subtitle = "Untertitel",
       caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com")


#----------------------------------------------------------------------------
# Compute percentage
#----------------------------------------------------------------------------

dax_period_percentage <- dax_period  %>%
  group_by(date, period) %>%
  summarise(n = sum(portfolio)) %>%
  mutate(percentage = n / sum(n)) 

#----------------------------------------------------------------------------
# Create plot
#----------------------------------------------------------------------------

dax_period_percentage %>%
  mutate(percentage = percentage * 100) %>%
  ggplot(aes(x = date, y = percentage, fill = period)) +
  geom_area(size = .5,
            colour = "white") +
  scale_fill_got_d(option = "Daenerys", direction = -1) +
  theme_jantau +
  labs(
    title = "Zeit im Markt",
    subtitle = "Zinseszins- und Durchschnittskosteneffekt beim Investieren in den Dax 30",
    caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com",
    fill = "Wann Gekauft?"
  ) +
  theme(
    legend.position = c(0.2, 0.4),
    legend.background = element_rect(fill = pal[1]),
    legend.title = element_text(color = "white", size = 10),
    legend.text = element_text(color = "white"),
    axis.title.y = element_blank(),
    axis.title.x = element_blank()
  ) +
  scale_y_continuous(
    sec.axis = sec_axis( ~ ., labels = dollar_format(suffix = " %",
                                                     prefix = "")),
    labels = dollar_format(suffix = " %",
                           prefix = "")
  ) +
  scale_x_date(breaks = as.Date(
    c(
      "1991-01-01",
      "1995-12-31",
      "2000-12-31",
      "2005-12-31",
      "2010-12-31",
      "2015-12-31",
      "2020-12-31"
    )
  ),
  labels = date_format("%Y")) +
  
  annotate(
    geom = "curve",
    x = as.Date("2018-12-01"),
    y = 25,
    xend = as.Date("2020-12-01"),
    yend = 25,
    curvature = .1,
    arrow = arrow(length = unit(2, "mm")),
    col = "white"
  ) +
  annotate(
    geom = "label",
    x = as.Date("2018-10-01"),
    y = 25,
    label = "40 % der Anteile\nwurden in der ersten\nAnsparphase zwischen\n1991 und 1995 gekauft.",
    hjust = "right",
    col = "white",
    fill = pal[1],
    alpha = 0.8,
    size = 3.5
  ) +
  
  annotate(
    geom = "curve",
    x = as.Date("2018-12-01"),
    y = 90,
    xend = as.Date("2020-12-01"),
    yend = 98,
    curvature = -.1,
    arrow = arrow(length = unit(2, "mm")),
    col = "white"
  ) +
  annotate(
    geom = "label",
    x = as.Date("2018-10-01"),
    y = 80,
    label = "6 % der Anteile\nwurden in der letzten\nAnsparphase zwischen\n2016 und 2020 gekauft.",
    hjust = "right",
    col = "white",
    fill = pal[3],
    alpha = 0.8,
    size = 3.5
  )
 
ggsave("zeit-im-markt.png", scale = .75) 

# Tipps for area chart
# https://www.r-graph-gallery.com/136-stacked-area-chart.html

#----------------------------------------------------------------------------
# Visualisation of last day
#----------------------------------------------------------------------------


dax_period_percentage %>%
  filter(date == "2020-12-30") %>%
  mutate(percentage = percentage * 100) %>%
  ggplot(aes(x = period, y = percentage)) +
  geom_col(fill = got(6, option = "Daenerys", direction = -1)) +
  theme_jantau +
  labs(title = "Endwerte",
       subtitle = "nach 5-Jahres-Perioden",
       caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com") +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank()) +
  
  scale_y_continuous(
    sec.axis = sec_axis(~ ., labels = dollar_format(suffix = " %",
                                                    prefix = "")),
    labels = dollar_format(suffix = " %",
                           prefix = "")
  ) +
  
  geom_hline(yintercept = 16.666667,
             linetype = "dashed",
             color = "dimgrey") +
  
  scale_x_discrete(limits=rev) +
  geom_label(aes(
    x = period,
    y = percentage,
    label = paste0(round(percentage, 1), " %")
  ),
  color = "black",
  size = 3) +
  
  annotate(
    geom = "curve",
    x = 5,
    y = 25,
    xend = 5.9,
    yend = 16.666667,
    curvature = -.2,
    arrow = arrow(length = unit(2, "mm")),
    col = "dimgrey"
  ) +
  annotate(
    geom = "label",
    x = 4.9,
    y = 25,
    label = "In jeder 5-Jahres-Periode wurde\ndieselbe Summe investiert, was jeweils\n16,7 % der Gesamtinvestition entspricht.",
    hjust = "right",
    vjust = "bottom",
    col = "dimgrey",
    fill = "dimgrey",
    alpha = 0.1,
    size = 3.5
  )

ggsave("endwerte.png", scale = .75) 
  


#----------------------------------------------------------------------------
# Calculate CAGRs # https://www.investopedia.com/terms/c/cagr.asp
#----------------------------------------------------------------------------

dax_period_cagr <- dax_saving %>%
  group_by(period) %>%
  summarise(cagr = (last(adjusted) / first(adjusted)) ^ (1 / 5) - 1)

dax_period_cagr %>%
  mutate(cagr = cagr * 100) %>%
  ggplot(aes(x = period, y = cagr)) +
  geom_col(fill = got(6, option = "Daenerys", direction = 1)) + # fill = ifelse(dax_period_cagr$cagr >= 0, pal[2], pal[1])

  theme_jantau +
  labs(title = "CAGR (Compound Annual Growth Rate)",
       subtitle = "nach 5-Jahres-Perioden",
       caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com") +
  theme(axis.title.x = element_blank()) +
  
  scale_y_continuous(
    sec.axis = sec_axis( ~ ., labels = dollar_format(suffix = " %",
                                                     prefix = "")),
    labels = dollar_format(suffix = " %",
                           prefix = "")
  ) +
  
  geom_label(aes(
    x = period,
    y = cagr,
    label = paste0(round(cagr, 1), " %")
  ),
  color = "black",
  size = 3) +
  
  annotate(
    geom = "curve",
    x = 2.5,
    y = 17,
    xend = 2.1,
    yend = 15,
    curvature = .2,
    arrow = arrow(length = unit(2, "mm")),
    col = "black"
  ) +
  annotate(
    geom = "label",
    x = 2.6,
    y = 17,
    label = "Im Zeitraum 1996 bis 2000 betrug\ndie jährliche Wachstumsrate 22,8 %.",
    hjust = "left",
    col = "black",
    fill = pal[5],
    alpha = 0.6,
    size = 3.5
  )
  
ggsave("period_cagr.png", scale = .75)   


# CAGR Dax 1991 bis 2020
# (13718/1359)^(1/30)-1 = 0.08011263

# CAGR Dax 1991 bis-1995
# (2260.69/1359)^(1/5)-1 = 0.1071445

#----------------------------------------------------------------------------
# END 
#----------------------------------------------------------------------------
