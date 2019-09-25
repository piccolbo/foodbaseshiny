library(purrr)
library(dplyr)
library(tidyr)
#from http://www.ars.usda.gov/Services/docs.htm?docid=25700
#

## @knitr read_data

options(shiny.fullstacktrace = TRUE)

load("food_data")

food_data$description =
  paste0(
    "<a href=\"http://google.com/search?q=",
    map(food_data$description, URLencode,  reserved=TRUE), "\">",
    food_data$description,
    "</a>")

# orig_names = names(food_data)
# food_data %>%
#   map(function(x) if(is.integer(x)) as.numeric(x) else x) %>%
#   data.frame -> food_data
# names(food_data) = orig_names
