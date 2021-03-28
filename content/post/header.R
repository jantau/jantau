# Set options  
# This option is used to prevent strings from being imported as factors
options(stringsAsFactors = FALSE)


# Load libraries

library(directlabels)
library(DT)
library(gameofthrones) # farbpaletten
library(ggrepel) # avoid overlapping labels 
# https://blog.revolutionanalytics.com/2016/01/avoid-overlapping-labels-in-ggplot2-charts.html
library(gt)
library(lubridate)
library(readxl)
library(scales)
library(stringr)
library(tidyquant)
library(tidyverse)
library(xts)

#library(plotly)
#library(highcharter)
#library(data.table)

require(ggplot2)

# Make a theme that matches the jantau blog
theme_jantau <- theme(
  plot.title       = element_text(
    size = 14,
    face = "bold",
    hjust = 0.5,
    margin = ggplot2::margin(0, 0, 10, 0)
  ),
  plot.subtitle       = element_text(
    size = 10,
    face = "bold",
    hjust = 0.5,
    margin = ggplot2::margin(0, 0, 10, 0)
  ),
  axis.title.y     = element_text(
    face = "bold",
    size = 10,
    margin = ggplot2::margin(0, 10, 0, 0)
  ),
  axis.text.y      = element_text(color = "black"),
  axis.ticks.y     = element_line(color = "black"),
  axis.text.x      = element_text(color = "black"),
  axis.ticks.x     = element_line(color = "black"),
  axis.title.x     = element_text(
    face = "bold",
    size = 10,
    margin = ggplot2::margin(10, 0, 0, 0)
  ),
  axis.line.x      = element_line(color = "black"),
  axis.line.y      = element_line(color = "black"),
  legend.key       = element_blank(),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  panel.border     = element_blank(),
  panel.background = element_blank(),
  plot.caption     = element_text(hjust = 0,
                                  size = 8)
)
