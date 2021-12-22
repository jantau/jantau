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

library(listviewer)
library(plotly)
library(rjson)
library(tidyquant)
library(tidyverse)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Import nasdaq data ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

ndx <- tq_get(c("^NDX"),
              get  = "stock.prices",
              from = "2021-01-01",
              to = Sys.Date()) %>%
  group_by(symbol) %>%
  tq_transmute(select     = adjusted,
               mutate_fun = periodReturn,
               period     = "weekly")


ndx_perf <- tq_get(c("^NDX"),
              get  = "stock.prices",
              from = "2021-01-01",
              to = Sys.Date()) %>%
  select(symbol, date, adjusted) %>%
  mutate(adj_perc = adjusted/first(adjusted)-1)
               
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create interactive plotly chart ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

ndx_acc <- ndx %>%
  split(.$date) %>%
  accumulate( ~ bind_rows(.x, .y)) %>%
  # set_names(1960:2018) %>%
  bind_rows(.id = "frame") %>%
  mutate(date = as.character(date))
  
  
fig3 <- ndx_acc %>% 
  plot_ly(x = ~date, y = ~weekly.returns) %>% 
  add_bars(frame = ~frame, showlegend = FALSE) %>%
  layout(xaxis = list(range = 
      c(as.numeric(as.POSIXct("2021-01-01", format="%Y-%m-%d"))*1000,
        as.numeric(as.POSIXct("2021-12-31", format="%Y-%m-%d"))*1000),
    type = "date"))

ndx_perf_acc <- ndx_perf %>%
  split(.$date) %>%
  accumulate( ~ bind_rows(.x, .y)) %>%
  # set_names(1960:2018) %>%
  bind_rows(.id = "frame") 


fig2 <- ndx_perf %>%
  plot_ly(x = ~date, y = ~adj_perc) %>%
  add_lines()


fig1 <- ndx_perf_acc %>% 
  plot_ly(x = ~date, y = ~adj_perc) %>% 
  add_lines(frame = ~frame, showlegend = FALSE) %>%
  layout(xaxis = list(
    title = list(visible = FALSE),
    range = 
      c(as.numeric(as.POSIXct("2021-01-01", format="%Y-%m-%d"))*1000,
        as.numeric(as.POSIXct("2021-12-31", format="%Y-%m-%d"))*1000),
    type = "date"),
    yaxis = list(title = "Performance",
                 tickformat = ",.0%")
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
  )

fig <- plotly_json(fig1, FALSE)

jsonData <- toJSON(fig)
write(jsonData,'test.json')

write(fig,'test.json')

fig2 <- plotly_json(fig2, FALSE)
write(fig2,'test2.json')


fig_out <- plotly_json(fig3, FALSE)
write(fig_out,'test.json')

jsonData <- toJSON(fig_out)
write(jsonData,'test.json')


partial_bundle(fig1) %>% saveWidget( "test.html", selfcontained = FALSE, libdir = "lib")

library(htmlwidgets)





# Set date axis range
# https://stackoverflow.com/questions/38919395/plotly-r-cant-make-custom-xaxis-date-ranges-to-work
# Hide slider labels
# https://stackoverflow.com/questions/51835657/how-to-hide-remove-slider-ticks-steps-and-their-labels-in-plotly-js
# Axis labe as percent
# https://stackoverflow.com/questions/42043633/format-y-axis-as-percent-in-plot-ly
# Plotly to Wowchemy via shortcode
# https://wowchemy.com/docs/content/writing-markdown-latex/
# Problem with files size when github push: git config --global http.postBuffer 157286400
# https://stackoverflow.com/questions/15843937/git-push-hangs-after-total-line


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# End ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++