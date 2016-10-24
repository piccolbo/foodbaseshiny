library(purrr)

#from http://www.ars.usda.gov/Services/docs.htm?docid=25700
food_data = read.table("sr28abbr/ABBREV.txt", sep = "^", quote = "~")
names(food_data) =
  c("food_code", "food_desc", "water", "energy", "protein", "fat", "ash", "carbohydrate_plus_fiber", "fiber", "sugar", "calcium", "iron", "magnesium", "phosphorus", "potassium", "sodium", "zinc", "copper", "manganese", "selenium", "vitamin_c", "thiamin", "riboflavin", "niacin", "pantothenic_acid", "vitamin_b6", "folate_total", "folic_acid", "food_folate", "folate", "choline", "vitamin_b12", "vitamin_a", "vitamin_a_retinol", "retinol", "alpha_carotene", "beta_carotene", "beta_cryptoxanthin", "lycopene", "lutein", "vitamin_e", "vitamin_d", "vitamin_d_iu", "vitamin_k", "saturated_fatty_acids", "monounsaturated_fatty_acids", "polyunsaturated_fatty_acids", "cholesterol", "first_household_weight", "description_household_weight_1", "second_household_weight", "description_household_weight_2", "refuse")

food_data$food_desc =
  paste0(
    "<a href=\"http://google.com/search?q=",
    map(as.character(food_data$food_desc), URLencode), "\">",
    food_data$food_desc,
    "</a>")

food_data %>%
  map(function(x) if(is.integer(x)) as.numeric(x) else x) %>%
  data.frame -> food_data
