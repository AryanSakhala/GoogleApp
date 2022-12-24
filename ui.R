library(shinydashboard)
library(shiny)
library(shinycssloaders)
library(tidyverse)
library(highcharter) 
library(lubridate)
library(stringr)
library(xts)
library(readr)
library(DT)
library(ggthemes)
options(scipen = 999)
library(scales)
library(argonDash)

library(rsconnect)



ui <- fluidPage(
  
  # App title ----
  titlePanel("Google Play Store"),
  navbarPage("",
             tabPanel("Visualisation",
                      navbarPage("",
                                 tabPanel("Price",
                                          
                                          box(id = "box1",
                                              width = 12,
                                              
                                              tags$br(),
                                              plotOutput("Price_free", height = 250, width = 400) %>% withSpinner(),
                                              title="H2H Comparison",
                                              status = "primary",
                                              solidHeader = TRUE,
                                              collapsible = TRUE,
                                              collapsed = FALSE),
                                          fluidRow(
                                            box(id = "box2",
                                                width = 12,
                                                
                                                tags$br(),
                                                plotOutput("Price_cat_free", height = 300, width = 800) %>% withSpinner(),
                                                title="Top 10 Free Categories",
                                                status = "primary",
                                                solidHeader = TRUE,
                                                collapsible = TRUE,
                                                collapsed = FALSE)),
                                          fluidRow(
                                            box(width = 12,
                                                
                                                tags$br(),
                                                plotOutput("Price_cat_paid", height = 300, width = 800) %>% withSpinner(),
                                                title="Top 10 Paid Categories",
                                                status = "primary",
                                                solidHeader = TRUE,
                                                collapsible = TRUE,
                                                collapsed = FALSE))),
                                 tabPanel("Category",
                                          fluidRow(
                                            box(width = 12,
                                                
                                                tags$br(),
                                                plotOutput("Cat_bar", height = 300, width = 1100) %>% withSpinner(),
                                                title="Count of each category",
                                                status = "primary",
                                                solidHeader = TRUE,
                                                collapsible = TRUE,
                                                collapsed = FALSE)),),
                                 tabPanel("Review",
                                          fluidRow(
                                            box(id = "box2",
                                                width = 12,
                                                
                                                tags$br(),
                                                plotOutput("Rev_Rat", height = 300, width = 800) %>% withSpinner(),
                                                title="Rating Vs Review",
                                                status = "primary",
                                                solidHeader = TRUE,
                                                collapsible = TRUE,
                                                collapsed = FALSE)))
                                 
                      )),
             
             tabPanel("Filtering",
                      sidebarLayout(
                        sidebarPanel(
                          
                          sliderInput("rt", "Rating Range",min = 0, max = 5, value = c(3,4)),
                          sliderInput("rv", "Number of Review Range",min = 0, max = 100000000, value = c(3000000,70000000)),
                          sliderInput("ins", "Number of Install Range",min = 0, max = 500000000, value = c(30000000,400000000)),
                          selectInput("cat","Category","Names")
                          
                        ),
                        mainPanel(
                          DT::dataTableOutput('tbl') %>% withSpinner(),
                          width = 8
                        )
                      ),
             ),
             tabPanel("Prediction")
  )
  
)