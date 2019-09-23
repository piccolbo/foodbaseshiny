library(purrr)
library(dplyr)
library(tidyr)
#from http://www.ars.usda.gov/Services/docs.htm?docid=25700
#

## @knitr read_data
##

options(shiny.fullstacktrace = TRUE)

#This join is done before deployment, when necessary
# products  =
#   read.csv(
#     "../food_data/BFPD_csv_07132018/Products.csv",
#     stringsAsFactors = FALSE)
# nutrients =
#   pivot_wider(
#     read.csv(
#       "../food_data/BFPD_csv_07132018/Nutrients.csv",
#       stringsAsFactors = FALSE),
#     id_cols = "NDB_No",
#     names_from = "Nutrient_name",
#     values_from = "Output_value",
#     values_fn = list(Output_value = mean))
# food_data =
#   select(
#     inner_join(
#       products,
#       nutrients,
#       c("NDB_Number" = "NDB_No")),
#     long_name,
#     manufacturer ,
#     `Sodium, Na`,
#     Energy,
#     Protein,
#     `Sugars, total`,
#     `Carbohydrate, by difference`,
#     `Iron, Fe`,
#     `Total lipid (fat)`,
#     `Fiber, total dietary`,
#     `Fatty acids, total saturated`,
#     `Calcium, Ca`,
#     `Vitamin C, total ascorbic acid`,
#     `Vitamin A, IU`,
#     `Cholesterol`,
#     `Fatty acids, total polyunsaturated`,
#     `Fatty acids, total monounsaturated`,
#     `Potassium, K`)
# save(food_data, file = "food_data")

load("food_data")

food_data$long_name =
  paste0(
    "<a href=\"http://google.com/search?q=",
    map(paste(food_data$long_name, food_data$manufacturer), URLencode,  reserved=TRUE), "\">",
    food_data$long_name,
    "</a>")

orig_names = names(food_data)
food_data %>%
  map(function(x) if(is.integer(x)) as.numeric(x) else x) %>%
  data.frame -> food_data
names(food_data) = orig_names
