#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Data and code for recap nasdaq  ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load R libraries and themes ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cat("\014") # Clear your console
rm(list = ls()) # Clear your environment

# Load in header file
setwd("/Users/jan/blog/jantau/content/post/2021-12-22-recap-nasdaq-100") 

library(crosstalk)
library(htmlwidgets)
library(listviewer)
library(plotly)
library(rjson)
library(tidyquant)
library(tidyverse)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Web scraping of nasdaq data ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

url <- "https://www.ishares.com/de/privatanleger/de/produkte/253741/ishares-nasdaq-100-ucits-etf/1478358465952.ajax?fileType=csv&fileName=SXRV_holdings&dataType=fund"
ishares_nasdaq <- read_csv(url, skip = 2)

ndx_data <- ishares_nasdaq %>%
  filter(Anlageklasse == "Aktien") %>%
  select(1:3, 6) %>%
  rename(Gewichtung = `Gewichtung (%)`) %>%
  mutate(Gewichtung = str_replace_all(Gewichtung, ",", ".")) %>%
  mutate(Gewichtung = as.numeric(Gewichtung)) %>%
  mutate(Sektor = case_when(Sektor == "Gesundheitsversorgung" ~ "Gesundheitvers.",
                            Sektor == "Nichtzyklische Konsumgüter" ~ "Nichtzykl. Konsum.",
                            str_detect(Sektor, "Zyklische Konsumgüter") ~ "Zykl. Konsum.",
                            TRUE ~ Sektor))

ndx_query <- append("^NDX", ndx_data$Emittententicker)
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Import nasdaq data ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

ndx_wk <- tq_get(ndx_query,
                 get  = "stock.prices",
                 from = "2020-12-29",
                 to = Sys.Date()) %>%
  group_by(symbol) %>%
  tq_transmute(select     = adjusted,
               mutate_fun = to.weekly) %>%
  group_by(symbol) %>%
  mutate(adj_perc = round(adjusted/first(adjusted)-1, 3))

save(ndx_wk, file = "ndx_wk.Rdata")
load("ndx_wk.Rdata")

ndx_d_2022 <- tq_get("^NDX",
                 get  = "stock.prices",
                 from = "2021-12-31",
                 to = Sys.Date()) %>%
  mutate(adj_perc = round(adjusted/first(adjusted)-1, 3)) %>%
  select(symbol, date, adjusted, adj_perc) %>%
  drop_na()

ndx_d_2021_22 <- tq_get("^NDX",
                     get  = "stock.prices",
                     from = "2020-12-31",
                     to = Sys.Date()) %>%
  mutate(adj_perc = round(adjusted/first(adjusted)-1, 3)) %>%
  select(symbol, date, adjusted, adj_perc) %>%
  drop_na()

# Dump: Compare asset classes
# assets <- tq_get(c("^NDX", "^GDAXI", "^SP500TR", "BTC-EUR", "^XAU", "^STOXX"),
#               get  = "stock.prices",
#               from = "2020-12-29",
#               to = Sys.Date()) %>%
#   group_by(symbol) %>%
#   tq_transmute(select     = adjusted,
#                mutate_fun = to.weekly) %>%
#   group_by(symbol) %>%
#   mutate(adj_perc = round(adjusted/first(adjusted)-1, 3))
# 
# assets %>%
#   plot_ly() %>%
#   add_lines(x = ~date, y = ~adj_perc, color = ~symbol) %>%
#   layout(legend = list(orientation = "h"))



#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create interactive plotly chart ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Join ishares index data with yahoo price data
ndx_wk_join <- ndx_wk %>% left_join(ndx_data, by = c("symbol" = "Emittententicker"))

# Rank stocks
ndx_wk_rank <- ndx_wk_join %>%
  ungroup() %>%
  filter(date == last(date) & symbol != "^NDX") %>%
  mutate(rank = min_rank(desc(adj_perc))) %>%
 # mutate(rank_quantile = cut(adj_perc, quantile(adj_perc, probs = seq(0, 1, 0.1)), include.lowest=TRUE, labels=FALSE)) %>%
  mutate(rank_quantile = cut(rank, breaks = 10, include.lowest=TRUE, labels=FALSE)) %>%
  select(symbol, rank, rank_quantile)

# Dump: Filter highest and lowest quantile
# filter(adj_perc > quantile(adj_perc, .9) |
#          adj_perc < quantile(adj_perc, .1))

ndx_wk_join_rank <- ndx_wk_join %>%
  left_join(ndx_wk_rank, by = "symbol")

# Weight per Sektor and per Stock
  
test <- ndx_wk_join %>%
  filter(symbol != "^NDX") %>%
  mutate(weight_perc = Gewichtung/100) %>%
  mutate(weight_adj_perc = adj_perc*weight_perc) %>%
  group_by(date, Sektor) %>%
  mutate(weight_sektor = sum(weight_perc, na.rm = TRUE)) %>%
  ungroup() %>%
  group_by(date, Sektor, weight_sektor) %>%
  summarise(weight_adj_perc = sum(weight_adj_perc, na.rm = TRUE))


%>%
  group_by(date, Sektor, weight_sektor) %>%
  summarise(weight_adj_perc = sum(weight_adj_perc, na.rm = TRUE))

sum(test$weight_sektor, na.rm = TRUE)

ndx_wk_join_all <- ndx_wk_join %>% filter(symbol != "^NDX") %>% SharedData$new(~symbol)
ndx_wk_join_ndx <- ndx_wk_join %>% filter(symbol == "^NDX") #%>% SharedData$new(~symbol)

fig_ndx <- plot_ly(data = ndx_wk_join_ndx, y = ~date, x = ~adj_perc, type = 'scatter', mode = 'line') %>%
  layout(title = "Nasdaq 100 im Jahr 2021",
         xaxis = list(side ="top", title = "", tickformat = ",.0%"),
         yaxis = list(title = FALSE, tickformat="%b\n%Y", autorange = "reversed")) %>%
  config(displayModeBar = FALSE)

partial_bundle(fig_ndx) %>% saveWidget("fig_ndx.html", selfcontained = FALSE, libdir = "lib")

fig_ndx_2022 <- plot_ly(data = ndx_d_2022, y = ~date, x = ~adj_perc, type = 'scatter', mode = 'line') %>%
  layout(title = "Nasdaq 100 im Jahr 2022",
         xaxis = list(side ="top", title = "", tickformat = ",.0%"),
         yaxis = list(title = FALSE, tickformat="%d.%b\n%Y", autorange = "reversed")) %>%
  config(displayModeBar = FALSE)

partial_bundle(fig_ndx_2022) %>% saveWidget("fig_ndx_2022.html", selfcontained = FALSE, libdir = "lib")


fig_ndx_2021_22 <- plot_ly(data = ndx_d_2021_22, y = ~date, x = ~adj_perc, fill = 'tozerox', type = 'scatter', mode = 'line') %>%
  layout(title = "Nasdaq 100 im Jahr 2022",
         xaxis = list(side ="top", title = "", tickformat = ",.0%"),
         yaxis = list(title = FALSE, dtick = "M1", tickformat="%b\n%Y", autorange = "reversed")) %>%
  config(displayModeBar = FALSE)

fig_ndx_2021_22 <- fig_ndx_2021_22 %>%
  layout(
    shapes = list(
      list(
        type = "rect",
        fillcolor = "gray",
        line = list(color = "blue"),
        opacity = 0.2,
        x0 = min(ndx_d_2021_22$adj_perc),
        x1 = max(ndx_d_2021_22$adj_perc),
        xref = "x",
        y0 = "2021-01-01",
        y1 = "2022-01-01",
        yref = "y"
      )
    ),
    annotations = list(
      x = 0.1,
      y = "2021-04-01",
      text = "2021",
      xref = "x",
      yref = "y",
      showarrow = FALSE,
      font = list(color = '#264E86',
                  size = 50)
    )
  )


partial_bundle(fig_ndx_2021_22) %>% saveWidget("fig_ndx_2021_22.html", selfcontained = FALSE, libdir = "lib")



fig <- plot_ly() %>% 
  
  add_lines(data = ndx_wk_join_all, x = ~date, y = ~adj_perc, ids = ~symbol, color = ~Sektor, opacity = 0.8,
            line = list(width = 0.5),
            hoverinfo = "text",
            text = ~paste("<b>", Name, "</b>",
                          "<br> Sektor: ", Sektor,
                          "<br> Performance: ", adj_perc*100, "%",
                          "<br> Kurs: ", round(adjusted, 1),
                          "<br> Gewichtung: ", Gewichtung, "%",
                          "<br> Datum: ", date
            )) %>% #, showlegend = FALSE
  
  add_lines(data = ndx_wk_join_ndx, x = ~date, y = ~adj_perc, ids = ~symbol,
            name = "Nasdaq 100", line = list(color = "grey95", width = 4, dash = 'dot'),
            hoverinfo = "text",
            text = ~paste("<b> NASDAQ 100</b>",
                          "<br> Performance: ", adj_perc*100, "%",
                          "<br> Kurs: ", round(adjusted, 1),
                          "<br> Datum: ", date
            )) %>%
  
  layout(title = "NASDAQ 100 in 2021",
         xaxis = list(
           title = list(visible = FALSE),
           range =
             c(as.numeric(as.POSIXct("2021-01-01", format="%Y-%m-%d"))*1000,
               as.numeric(as.POSIXct("2022-01-01", format="%Y-%m-%d"))*1000),
           type = "date"),
         yaxis = list(title = "Performance",
                      tickformat = ",.0%"),
         showlegend = TRUE, 
         legend = list(orientation = "v", #x = 0.2, y = 0.9
                       title = list(text = "<b> Sektoren </b>"),
                       #bgcolor = "rgba(255, 255, 255, 0.4)",
                       bordercolor = "#FFFFFF",
                       borderwidth = 1)
  ) %>% 
  
  highlight(on = "plotly_hover", off = "plotly_doubleclick", selected = attrs_selected(showlegend = FALSE))

fig 

fig_json <- plotly_json(fig, FALSE)
jsonData <- toJSON(fig_json)
write(jsonData,'test.json')
write(fig_json,'test.json')


partial_bundle(fig) %>% saveWidget("fig.html", selfcontained = FALSE, libdir = "lib")






# Dump: For animated chart split and accumulate data (see Datacamp Course Intermediate Interactive Data Visualization with plotly in R)
# Data is too big for animation
ndx_wk_acc <- ndx_wk %>%
  group_by(symbol) %>%
  split(.$date) %>%
  accumulate( ~ bind_rows(.x, .y)) %>%
  # set_names(1960:2018) %>%
  bind_rows(.id = "frame") %>%
  filter(frame != "2020-12-30")

ndx_wk_acc_join <- ndx_wk_acc %>% left_join(ndx_data, by = c("symbol" = "Emittententicker"))

ndx_wk_acc_join_all <- ndx_wk_acc_join %>% filter(symbol != "^NDX") %>% SharedData$new(~symbol)
ndx_wk_acc_join_ndx <- ndx_wk_acc_join %>% filter(symbol == "^NDX") #%>% SharedData$new(~symbol)


fig <- plot_ly() %>% 
  
  
  add_lines(data = ndx_wk_acc_join_all, x = ~date, y = ~adj_perc, frame = ~frame, ids = ~symbol, color = ~Sektor, opacity = 0.4,
            line = list(width = 3),
            hoverinfo = "text",
            text = ~paste("<b>", Name, "</b>",
                          "<br> Sektor: ", Sektor,
                          "<br> Performance: ", adj_perc*100, "%",
                          "<br> Kurs: ", round(adjusted, 1),
                          "<br> Gewichtung: ", Gewichtung, "%",
                          "<br> Datum: ", date
            )) %>% #, showlegend = FALSE
  
  add_lines(data = ndx_wk_acc_join_ndx, x = ~date, y = ~adj_perc, frame = ~frame, ids = ~symbol,
            name = "Nasdaq 100", line = list(color = "grey35", width = 4, dash = 'dot'),
            hoverinfo = "text",
            text = ~paste("<b> NASDAQ 100</b>",
                          "<br> Performance: ", adj_perc*100, "%",
                          "<br> Kurs: ", round(adjusted, 1),
                          "<br> Datum: ", date
            )) %>%
  
  layout(title = "NASDAQ 100 in 2021",
         xaxis = list(
           title = list(visible = FALSE),
           range = 
             c(as.numeric(as.POSIXct("2021-01-01", format="%Y-%m-%d"))*1000,
               as.numeric(as.POSIXct("2021-12-31", format="%Y-%m-%d"))*1000),
           type = "date"),
         yaxis = list(title = "Performance",
                      tickformat = ",.0%"),
         showlegend = TRUE, 
         legend = list(x = 0.1, y = 0.9,
                       title = list(text = "<b> Sektoren </b>"),
                       bgcolor = "rgba(255, 255, 255, 0.4)",
                       bordercolor = "#FFFFFF",
                       borderwidth = 1)
  ) %>% 
  
  animation_opts(
    frame = 100, 
    transition = 50, 
    easing = "elastic"
  ) %>%
  animation_slider(
    tickcolor = "white",
    font = list(color = "white"),
    currentvalue = list(
      prefix = NULL, 
      font = list(color = "gray")
    )
    ) %>%
  
  highlight(on = "plotly_hover", off = "plotly_doubleclick", selected = attrs_selected(showlegend = FALSE), selectize = TRUE)


fig 


fig_json <- plotly_json(fig, FALSE)
jsonData <- toJSON(fig_json)
write(jsonData,'test.json')
write(fig_json,'test.json')


partial_bundle(fig) %>% saveWidget("fig.html", selfcontained = FALSE, libdir = "lib")




# Set date axis range
# https://stackoverflow.com/questions/38919395/plotly-r-cant-make-custom-xaxis-date-ranges-to-work
# Hide slider labels
# https://stackoverflow.com/questions/51835657/how-to-hide-remove-slider-ticks-steps-and-their-labels-in-plotly-js
# Axis labels as percent
# https://stackoverflow.com/questions/42043633/format-y-axis-as-percent-in-plot-ly
# Plotly to Wowchemy via shortcode
# https://wowchemy.com/docs/content/writing-markdown-latex/
# Problem with files size when github push: git config --global http.postBuffer 157286400
# https://stackoverflow.com/questions/15843937/git-push-hangs-after-total-line




#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# End ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++