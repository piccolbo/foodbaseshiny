
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)


shinyUI(
  fluidPage(
    titlePanel("Nutritional Food Search"),
    p(a(href="http://www.ars.usda.gov/Services/docs.htm?docid=25700", "Dataset"),
      "from USDA"),
    conditionalPanel(
      'input.search_type == "Low Sodium"',
      p("Simple search for low sodium foods. Minimize your sodium intake per amount of food, energy or protein")),
    conditionalPanel(
      'input.search_type == "Advanced"',
      p("Advanced food search with dplyr-like syntax")),
    sidebarLayout(
      sidebarPanel(
        selectInput("search_type", "Search type", c("Low Sodium", "Advanced")),
        uiOutput("search_params")),
      mainPanel(DT::dataTableOutput("food_data")))))
