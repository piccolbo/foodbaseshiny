
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(dplyr)
library(purrr)


#food_data loaded in global.R
#
default =
  function(x, value, condition = is.null)
    if(condition(x)) value else x



parse_field =
  function(field) {
    as.list(
      parse(text = paste0("list(", field, ")"))[[1]][-1])}


shinyServer(function(input, output) {

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
