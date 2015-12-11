###########################################################
# examples of web-scraping using rvest and selectorgadget #
###########################################################

library(rvest)
library(dplyr)
library(ggplot2)

# rvest blog page:
# http://blog.rstudio.org/2014/11/24/rvest-easy-web-scraping-with-r/

# get selectorgadget here:
# http://selectorgadget.com/

# SelectorGadget vignette: 
# file:///Library/Frameworks/R.framework/Versions/3.1/Resources/library/rvest/doc/selectorgadget.html

# tutorials in the rvest package are similar to the examples below

url <- "http://www.zillow.com/homes/for_sale/Bozeman-MT/fsba,fsbo,fore,cmsn_lt/house_type/44281_rid/46.118941,-108.897858,45.001709,-111.781769_rect/8_zm/0_mmm/"

# read html code from Bozeman Zillow page
address <- read_html(url) %>% 
  # selcect the addresses
  html_nodes(".routable") %>%
  # grab the right attribute
  html_attr("href") %>%
  # split the string 
  strsplit("/") %>% 
  # grab the third element and force it to be a character
  pluck(i = 3, type = character(1)) %>%
  # only keep unique addresses - when I did this there were two for each
  unique()

# get the prices
price <- read_html(url) %>%
  # grab the selector
  html_nodes(".zsg-h2") %>%
  # get the prices
  html_text()

# clean them up a bit..one extra $-, and remove $ and ,
price <- price[-26]
price <- gsub("[[:punct:]]", "", price) %>% 
  as.numeric()

# combine to make sure we have the same lengths
# also check with the webpage to make sure addresses and listing prices 
# match
cbind(address,price)

# bedrooms, baths and square footage
details <- read_html(url) %>% 
  html_nodes(".beds-baths-sqft") %>%
  html_text()

# get rid of dots
details <- gsub("[[:punct:]]", "", details) %>%
  strsplit(" ")

# grab what you want...
details <- matrix(unlist(details), ncol = 8, byrow = T)
head(details)
beds <- as.numeric(details[,1])
baths <- as.numeric(details[,4])
sqft <- as.numeric(details[,7])

# make a data frame
houses <- data_frame(address, price, beds, baths, sqft)

# make a plot
ggplot(houses, aes(y = price, x = sqft, colour = beds)) + 
  geom_point(size = 5) + theme_bw()


# Socks on steep and cheap..The same selectors will work with any 
# of the categories!
url_sc <- "http://www.steepandcheap.com/gear-cache/stock-up-and-save-on-socks"

brand <- read_html(url_sc) %>%
  html_nodes(".brand-name") %>%
  html_text()

price <- read_html(url_sc) %>%
  html_nodes(".product-price") %>% 
  html_text()

price <- as.numeric(gsub("[[:punct:]]", "", price))/100

product <- read_html(url_sc) %>% 
  html_nodes(".product-name-text") %>% 
  html_text()

discount <- read_html(url_sc) %>% 
  html_nodes(".product-discount") %>% 
  html_text() 

discount <- gsub("[[:punct:]]", "", discount) %>% 
  strsplit(" ") 

discount <- unlist(discount) 
discount <- matrix(discount, ncol = 2, byrow = T)

discount <- as.numeric(discount[,1])/100

socks <- data_frame(brand, product, price, discount)

with(socks, table(brand))
# with(socks, table(product))

with(socks, table(brand, discount))

smartwool <- socks %>% filter(brand == "SmartWool")

plot(price~discount, data = socks, col = factor(brand), pch = 20)
legend("topright", legend = levels(factor(socks$brand)), pch = 20, col = factor(brand))

GGally::ggpairs(socks[,c(1,3,4)])

