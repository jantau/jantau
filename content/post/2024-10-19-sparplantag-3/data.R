#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Data and code for best day to invest 3 ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load R libraries and themes ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cat("\014") # Clear your console
rm(list = ls()) # Clear your environment

# Load in header file
source("./content/post/header.R")
setwd("./content/post/2024-10-19-sparplantag-3") 


# EUNL.DE MSCI World ETF
# SXRV.DE Nasdaq 100 ETF
# EXS1.DE DAX ETF
# ^GDAXI DAX Index
# ^NDX Nasdaq 100 Index

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load data ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

df <- tq_get(c("^NDX"),
             get  = "stock.prices",
             from = "1988-01-01", #2012-01-01
             to = "2024-09-30") %>%
  tq_transmute(select = open, mutate_fun = to.daily)

df_1 <- df %>%
  mutate(day = substr(date, start = 9, stop = 10),
         day = as.numeric(day),
         intra_day = lead(adjusted)/adjusted-1)


df_1 <- df %>%
  mutate(day = substr(date, start = 9, stop = 10),
         day = as.numeric(day),
         intra_day = lead(open)/open-1)

df_group <- df_1 %>%
  group_by(day) %>%
  summarise(intra_day = mean(intra_day, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(rank = rank(-intra_day)) %>%
  mutate(rank = case_when(rank <= 5 ~ "top5",
                          rank >= 27 ~ "bottom5",
                          TRUE ~ "rest"))

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
pal <- c( "#792427", "#D9D9D9", "#2B818E")

ggplot(df_group, aes(x = day, y = intra_day, fill = rank)) +
  geom_col() +
  labs(title = "Durchschnittliche Tagesrendite",
       x = "Tag",
       y = "Durchschnittliche Tagesrendite") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 0, hjust = 1)) +
  # Show every label on x axis
  scale_x_continuous(breaks = seq(1, 31, 1)) +
  scale_fill_manual(values = pal)
  


# Sparplan

df_2 <- df_1 %>%
   mutate(yearmon = floor_date(date, unit = "month")) %>%
   group_by(yearmon) %>%
  complete(day = 1:31) %>%
  ungroup() %>%
  # Complete missing open values with values that come later
  fill(open, .direction = "updown") %>%
  mutate(shares = 1/open)

df_group_2 <- df_2 %>%
  group_by(day) %>%
  summarise(shares = sum(shares)) %>%
  ungroup() %>%
  mutate(value = shares*last(df$open)) %>%
  mutate(perc = (value/(nrow(df_2)/31)-1)*100)


2/0.5



df_group_2 <- df_group_2 %>%
  mutate(percents = shares/max(shares))

df_group_2 <- df_group_2 %>%
  mutate(add_shares = shares-min(shares)) %>%
  mutate(add_shares = add_shares*last(df$open))

df_group_2 <- df_group_2 %>%
  mutate(add_shares = shares*last(df$open))

df_group_2 <- df_group_2 %>%
  mutate(rank = rank(-shares)) %>%
  mutate(rank = case_when(rank <= 5 ~ "top5",
                          rank >= 27 ~ "bottom5",
                          TRUE ~ "rest"))
  
ggplot(df_group_2, aes(x = day, y = perc, fill = rank)) +
  geom_col() +
  labs(title = "Anzahl der Aktien im Sparplan",
       x = "Tag",
       y = "Anzahl der Aktien") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 0, hjust = 1)) +
  # y axis in percent
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  # Y lim 200000 bis 250000
  coord_cartesian(ylim = c(2240, NA)) +
 # scale_y_continuous(limits = c(2000000, NA)) +
  # Show every label on x axis
  scale_x_continuous(breaks = seq(1, 31, 1)) +
  scale_fill_manual(values = pal)

  
  
  
  #complete(yearmon, day, open, fill = list(NA))
  