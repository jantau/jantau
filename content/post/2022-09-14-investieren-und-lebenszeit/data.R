#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Investing and lifetime ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load R libraries and themes ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cat("\014") # Clear your console
rm(list = ls()) # Clear your environment

# Load in header file
source("./content/post/header.R")
setwd("./content/post/2022-09-14-investieren-und-lebenszeit") 


# https://www.gastonsanchez.com/intro2cwd/savings.html
# https://www.kapiert.de/mathematik/klasse-9-10/funktionen/der-logarithmus/exponentialgleichungen-loesen/
annuity <- function(contrib = 100, rate = 0.05, years = 1) {
  result <- contrib * (((1 + rate / 12)^(years*12) - 1) / (rate / 12))
  return(result)
}

annuity()

100 * (((1 + 0.05 / 12)^(1*12) - 1) / (0.05))

annuity <- function(contrib = 100, rate = 0.05, years = 1) {
  result <- contrib * (((1 + rate)^years - 1) / rate)
  return(result)
}

annuity_years <- function(contrib = 100, rate = 0.05, end_amount = 500000) {
  years <- log(end_amount / contrib * rate / 12 + 1) / log(1 + rate / 12)
  savings <- contrib * years
  result <- c(Jahre = years/12, Ansparen = savings, Ansparrate = contrib)
  return(result)
}

annuity_years(contrib = 10, rate = 0.07, end_amount = 500000)




future_vales <- function(amount = 100, rate = 0.05, years = 1) {
  result <- amount * (1 + rate)^years
  return(result)
}

future_vales()

future_values_years <- function(amount = 100, rate = 0.05, end_amount = 200) {
  result <- log(end_amount/amount) / log(1 + rate)
  return(result)
}

future_values_years(end_amount = 1000)

100 * (1 + 0.05)^14.2

100 * (1 + 0.05)^x = 200

log(200/100) / log(1 + 0.05)


log(2187)/log(3)

200 * (((1 + 0.05)^10 - 1 ) / 0.05) = 2515

log(2515.579/200*0.05+1) / log(1 + 0.05)