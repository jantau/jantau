#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Data and code for buying apple stock with each apple product ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load R libraries and themes ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cat("\014") # Clear your console
rm(list = ls()) # Clear your environment

# Load in header file
source("/Users/jan/blog/jantau/content/post/header.R")
setwd("/Users/jan/blog/jantau/content/post/2021-09-25-konsum-und-investieren") 


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load apple stock data ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

# apple_data <- tq_get("AAPL",
#                    get  = "stock.prices",
#                    from = "2005-01-01",
#                    to = "2021-10-05")
# 
# save(apple_data, file = "apple_data.Rda")
load("apple_data.Rda")

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load buying data ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

my_apple <- read_excel("my_apple_products.xlsx") %>%
  mutate(date = as.Date(date))

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Simulation of portfolio ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 


apple_data_1 <- apple_data %>%
  select(1, 2, 8) %>%
  mutate(yearmon = floor_date(date, unit = "month"), .after = date) %>%
  mutate(day = substr(date, start = 9, stop = 10)) %>%
  mutate(day = as.numeric(day)) %>%
  group_by(yearmon) %>%
  filter(day >= 1) %>%
  slice(1L) %>%
  ungroup() %>%
  left_join(my_apple, by = c("yearmon" = "date")) %>% # workaround for picking first value that is equal/greater 5
  mutate(price = replace_na(price, 0)) %>%
  mutate(price_total = cumsum(price))


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Savings plan looping ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

apple_data_1[1, "shares"] <- apple_data_1[1, "price"] / apple_data_1[1, "adjusted"]
apple_data_1[1, "portfolio"] <- apple_data_1[1, "shares"] * apple_data_1[1, "adjusted"] 

for(i in 2:nrow(apple_data_1)) {
  
  apple_data_1[i, "shares"] <- apple_data_1[i - 1, "shares"] + (apple_data_1[i, "price"] / apple_data_1[i, "adjusted"])
  
  apple_data_1[i, "portfolio"] <- apple_data_1[i, "shares"] * apple_data_1[i, "adjusted"]
  
} 

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Chart ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library(ggrepel)

ggplot(apple_data_1) +
  geom_line(aes(x = date, y = portfolio), color = "green") +
  geom_step(aes(x = date, y = price_total)) +
#  geom_point(data = apple_data_1 %>% filter(price >= 1), aes(x = date, y = price_total)) +
  geom_point(data = apple_data_1 %>% filter(price >= 1), aes(x = date, y = portfolio)) +
  geom_label_repel(
    data = apple_data_1 %>% filter(price >= 1),
    aes(x = date, y = portfolio, label = product),
    alpha = 0.7,
    size = 2.5,
    min.segment.length = unit(0, 'lines')
  ) +
  labs(title = "Apple-Portfolio",
       subtitle = "...",
       caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com",
       y = "Wert Apple-Portfolio") +
  theme_jantau +
  theme(axis.title.x = element_blank()) +
  scale_y_continuous(labels = dollar_format(
    big.mark = " ",
    decimal.mark = ",",
    suffix = " €",
    prefix = ""
  )) 

ggsave("apple.png", scale = .75)

library(ggimage)
# https://www.generacodice.com/en/articolo/560462/How-to-use-an-image-as-a-point-in-ggplot
# https://themockup.blog/posts/2020-10-11-embedding-images-in-ggplot/

apple_data_2 <- apple_data_1 %>%
  mutate(image = "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/404px-Apple_logo_black.svg.png")

pal <- got(3, option = "Daenerys", direction = 1)

ggplot(apple_data_2) +
  geom_line(aes(x = date, y = portfolio, color = pal[2])) +
  
  geom_step(aes(x = date, y = price_total, color = "black")) +
  
  scale_color_identity(name = "Model fit",
                       labels = c("AAPL-Portfolio", "insg. investiert"),
                       guide = "legend") +
  
  #  geom_point(data = apple_data_1 %>% filter(price >= 1), aes(x = date, y = price_total)) +
  geom_image(data = apple_data_2 %>% filter(price >= 1), aes(x = date, y = portfolio, image = image), size = 0.02, by = "width", asp = 1.3) +
  geom_label_repel(
    data = apple_data_2 %>% filter(price >= 1),
    aes(x = date, y = portfolio, label = product),
    alpha = 0.7,
    size = 2.5,
    min.segment.length = unit(0, 'lines')
  ) +
  labs(title = "Apple - Stock where you Shop",
       subtitle = "Was wäre, wenn ich bei jedem Kauf eines Apple-Produkts \nin AAPL investiert hätte?",
       caption = "Datenanalyse u. Visualisierung: jantau.com | Daten: finance.yahoo.com",
       y = "AAPL-Portfolio") +
  theme_jantau +
  theme(axis.title.x = element_blank(),
        legend.title = element_blank(),
        legend.position = c(0.5, 0.98), legend.direction="horizontal") +
  scale_x_date(date_labels = "'%y", date_breaks = "2 years") +
  scale_y_continuous(labels = dollar_format(
    big.mark = " ",
    decimal.mark = ",",
    suffix = " €",
    prefix = ""
  )) 

ggsave("apple_logo.png", scale = .75, dpi = "retina")

                
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Table ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   

apple_data_table <- apple_data_1 %>%
  filter(!is.na(product)) %>%
  select(
    Datum = yearmon,
    `Apple-Produkt` = product,
    `Preis in €` = price,
    `Preis AAPL-Aktie (adjusted price)` = adjusted,
    `insg. Anzahl AAPL-Aktien` = shares,
    `Wert AAPL-Portfolio` = portfolio,
    `insg. investiert` = price_total
  ) %>%
  mutate(`Anzahl AAPL-Aktien` = c(`insg. Anzahl AAPL-Aktien`[1], diff(`insg. Anzahl AAPL-Aktien`)), .after = `Preis AAPL-Aktie (adjusted price)`) %>%
  mutate(`Preis AAPL-Aktie (adjusted price)` = round(`Preis AAPL-Aktie (adjusted price)`, 1)) %>%
  mutate(`Anzahl AAPL-Aktien` = round(`Anzahl AAPL-Aktien`, 1)) %>%
  mutate(`insg. Anzahl AAPL-Aktien` = round(`insg. Anzahl AAPL-Aktien`, 1)) %>%
  mutate(`Wert AAPL-Portfolio` = round(`Wert AAPL-Portfolio`, 2))

library("writexl")
write_xlsx(apple_data_table,"apple_data_table.xlsx")


