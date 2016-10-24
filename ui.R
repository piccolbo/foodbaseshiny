
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

#food_data loaded in global.R
## @knitr sodium_slider
sodium_quantiles = quantile(food_data$sodium, na.rm = TRUE)
sodium_energy_quantiles =
  quantile(food_data$sodium/(food_data$energy + 0.01), na.rm = TRUE)
sodium_protein_quantiles =
  quantile(food_data$sodium/(food_data$protein + 0.01), na.rm = TRUE)

sodium_slider_input =
  function(inputId, label, quantiles)
    sliderInput(
      inputId,
      label,
      round(quantiles[["0%"]], 2),
      round(quantiles[["75%"]], 2),
      round(quantiles[["25%"]], 2))

## @knitr textinput_advanced
ti =
  function(name, placeholder)
    textInput(name, name, "", "100%", placeholder)

## @knitr ui
shinyUI(
  fluidPage(
    titlePanel("Nutritional Food Search"),
    p(a(href="http://www.ars.usda.gov/Services/docs.htm?docid=25700", "Dataset"),
      "from USDA"),
## @knitr  sidebar
    sidebarLayout(
      sidebarPanel(
        selectInput("search_type", "Search type", c("Low Sodium", "Advanced")),
## @knitr conditionalPanel_sodium
        conditionalPanel(
          'input.search_type == "Low Sodium"',
          p("Simple search for low sodium foods. Minimize your sodium intake per amount of food, energy or protein"),
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
            sodium_protein_quantiles)),
## @knitr conditionalPanel_advanced
        conditionalPanel(
          'input.search_type == "Advanced"',
          p("Advanced food search with dplyr-like syntax"),
          ti("mutate",  "e.g. 'ratio = sodium/energy, sodium/protein'"),
          ti("filter",   "e.g. 'energy < 100'"),
          ti("arrange", "e.g. 'desc(energy/sodium)'"),
          ti("select", "e.g. 'food_desc, energy'"))),
      mainPanel(DT::dataTableOutput("food_data")))))
