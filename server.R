
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(dplyr)
library(purrr)


#food_data loaded in global.R

### @knitr helper_functions
default =
  function(x, value, condition = is.null)
    if(condition(x)) value else x

# parse_field =
#   function(field) {
#     as.list(
#       parse(text = paste0("list(", field, ")"))[[1]][-1])}


## @knitr shinyServer

shinyServer(function(input, output) {

## @knitr verb
  # verb =
  #   function(data, name, val) {
  #     get(paste0(name, "_"))(
  #       data,
  #       .dots =
  #         parse_field(default(input[[name]], val, function(x) is.null(x) || x == "")))}

  verb = function(data, name, val) {
    get(paste0(name, "_"))(
      data,
      .dots = default(input[[name]], val))
  }

## @knitr main_table
  output$food_data =
    DT::renderDataTable({
      switch(
        input$search_type,
## @knitr low_sodium_table
        `Low Sodium` = {
          food_data %>%
            filter(
              grepl(
                x = description,
                pattern = default(input$food_type, ""),
                ignore.case = TRUE)) %>%
            filter(`Sodium, Na` <= default(input$sodium, Inf )) %>%
            filter(`Sodium, Na`/Energy <= default(input$sodium_energy, Inf)) %>%
            filter(`Sodium, Na`/Protein <= default(input$sodium_protein, Inf))},
## @knitr advanced_table
        Advanced = {
          food_data %>%
            verb("mutate", input$`new column`) %>%
            verb("filter", input$`filter foods`) %>%
            verb("arrange", input$`order (default ascending)`) %>%
            verb("select", input$`select columns`)})
    },
    escape = FALSE,
    options = list(autoWidth = TRUE))
})
