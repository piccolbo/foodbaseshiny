library(readr)
library(dplyr)
library(tidyr)

#This join is done before deployment, when necessary
food = read_csv("food_data_dir/food_data_central/food.csv")
nutrient = read_csv("food_data_dir/food_data_central/nutrient.csv")


food_nutrient_colspec = spec_csv("food_data_dir/food_data_central/food_nutrient.csv", guess_max = 100000 )
food_nutrient = read_csv("food_data_dir/food_data_central/food_nutrient.csv", col_types = food_nutrient_colspec)

select(food_nutrient, fdc_id, nutrient_id, amount) %>%
  inner_join(
    select(nutrient,id,name,unit_name) %>%
      filter(
        name %in%
          c(
            "Sodium, Na",
            "Energy",
            "Protein",
            "Sugars, total including NLEA",
            "Carbohydrate, by difference",
            "Carbohydrate, by summation",
            "Iron, Fe",
            "Total lipid (fat)",
            "Fiber, total dietary",
            "Fatty acids, total saturated",
            "Cholesterol",
            "Fatty acids, total polyunsaturated",
            "Fatty acids, total monounsaturated",
            "Fatty acids, total trans",
            "Potassium, K")),
    c("nutrient_id" = "id")) %>%
  pivot_wider(
    id_cols = "fdc_id",
    names_from = "name",
    values_from = "amount",
    values_fn = list(amount = mean)) %>%
  inner_join(
    select(food, fdc_id, data_type, description),
    "fdc_id") -> food_data

food_data = food_data[names(sort(sapply(food_data, function(x) sum(is.na(x)))))]
save(food_data, file = "food_data")

