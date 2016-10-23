
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(dplyr)
library(purrr)

default =
  function(x, value, condition = is.null)
    if(condition(x)) value else x

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

sodium_quantiles = quantile(food_data$sodium, na.rm = TRUE)
sodium_energy_quantiles =
  quantile(food_data$sodium/food_data$energy, na.rm = TRUE)
sodium_protein_quantiles =
  quantile(food_data$sodium/food_data$protein, na.rm = TRUE)


parse_field =
  function(field) {
    as.list(
      parse(text = paste0("list(", field, ")"))[[1]][-1])}

sodium_slider_input =
  function(inputId, label, quantiles)
    sliderInput(
      inputId,
      label,
      quantiles[["0%"]],
      quantiles[["75%"]],
      quantiles[["25%"]])

shinyServer(function(input, output) {

  ti =
    function(name, placeholder)
      textInput(
        name,
        name,
        "",
        "100%",
        placeholder)

  output$search_params =
    renderUI(
      switch(
        input$search_type,
        Advanced =
          wellPanel(
            ti("mutate",  "e.g. 'ratio = sodium/energy, sodium/protein'"),
            ti("filter",   "e.g. 'energy < 100'"),
            ti("arrange", "e.g. 'desc(energy/sodium)'"),
            ti("select", "e.g. 'food_desc, energy'")),
        `Low Sodium` =
          wellPanel(
            textInput("food_type", "Food type", "", placeholder = "Partial food name, e.g. 'cheese' or empty"),
            sodium_slider_input(
              "sodium",
              "max sodium per weight mg/100 g",
              sodium_quantiles),
            sodium_slider_input(
              "sodium_energy",
              "max sodium per energy mg/kcal",
              sodium_energy_quantiles),
            sodium_slider_input(
              "sodium_protein",
              "max sodium per protein mg/g",
              sodium_protein_quantiles))))

  verb =
    function(data, name, val) {
      get(paste0(name, "_"))(
        data,
        .dots =
          parse_field(default(input[[name]], val, function(x) is.null(x) || x == "")))}

  output$food_data =
    DT::renderDataTable({
      switch(
        input$search_type,
        Advanced = {
          food_data %>%
            verb("mutate", "") %>%
            verb("filter", "TRUE") %>%
            verb("arrange", "food_code") %>%
            verb("select", paste(names(food_data), collapse = ",")) },
        `Low Sodium` = {
          food_data %>%
            filter(
              grepl(
                x = food_desc,
                pattern = default(input$food_type, ""),
                ignore.case = TRUE)) %>%
            filter(sodium <= default(input$sodium, 120)) %>%
            filter(sodium/energy <= default(input$sodium_energy, 0.6)) %>%
            filter(sodium/protein <= default(input$sodium_protein, 19)) %>%
            select_(.dots = c("food_desc", "sodium", colnames(food_data)))})
    },
    escape = FALSE)
})
