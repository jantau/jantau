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


