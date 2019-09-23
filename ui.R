
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinyWidgets)

#food_data loaded in global.R
## @knitr sodium_slider
q099 = partial(quantile, na.rm = TRUE, probs = seq(0,1, .001))
sodium_quantiles = q099(food_data["Sodium, Na"])
sodium_energy_quantiles =
  q099(food_data["Sodium, Na"]/(food_data$Energy + 1))
sodium_protein_quantiles =
  q099(food_data["Sodium, Na"]/(food_data$Protein + 1))

sodium_slider_input =
  function(inputId, label, quantiles)
      sliderTextInput(
        inputId,
        label,
        choices = quantiles,
        selected = quantiles[["99.0%"]]
      )

## @knitr textinput_advanced
ti =
  function(name, placeholder)
    textInput(name, name, "", "100.0%", placeholder)

## @knitr ui
shinyUI(
  fluidPage(
    titlePanel("Nutritional Food Search"),
    p(a(href="https://www.ars.usda.gov/ARSUserFiles/80400525/Data/BFPDB/BFPD_csv_07132018.zip", "Dataset"),
      "from USDA. Please verify nutritional information before ingesting anything as the data contains errors."),
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
          ti("new column",  "e.g. 'ratio = `Sodium, Na`/Energy, `Sodium, Na`/Protein'"),
          ti("filter foods",   "e.g. 'Energy < 1000'"),
          ti("order (default ascending)", "e.g. 'desc(Energy/`Sodium, Na`)'"),
          ti("select columns", "e.g. 'long_name, Energy'"))),
## @knitr mainPanel
      mainPanel(DT::dataTableOutput("food_data")))))
