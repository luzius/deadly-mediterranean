#essentials
library(shiny)
library(leaflet)
library(magrittr)

#load data
#pf.dasa <- "D:/Eigene Dokumente/weiterbildung/CAS Data Science Applications/visualisierung/praktikum/visproj/shiny app"
#inc.agg3 <- readRDS(file.path(pf.dasa, "inc3.agg.rds"))
#inc2 <- readRDS(file.path(pf.dasa,"inc2.rds"))
inc.agg3 <- readRDS( "inc3.agg.rds")
inc2 <- readRDS("inc2.rds")



#hilfsvars
dform1 <- "%Y-%m-%d"
causes <- sort(unique(inc2$cause))

# Define UI for miles per gallon application
shinyUI(fluidPage(
  
  # Application title

  fluidRow(column(12, 
                  div(style="height: 30px;",
                  h1("number of deceased migrants on their way to europe")))),
  fluidRow(column(12, hr())),
  fluidRow(column(2,h3("filters:")),
           column(3,
                  div(style="height: 90px;",
                  sliderInput('zeit', 
                    label = h4('time (filters all plots)'),
                    min = min(inc2$dat), max = max(inc2$dat),
                    value = c(min(inc2$dat), max(inc2$dat)),
                    step=1, timeFormat="%Y %b"))),
           column(6, offset = 1, 
                  div(style="height: 90px;",
                  checkboxGroupInput("causes", 
                    label = h4("death cause (filters only map)"), 
                    choices = causes,
                    selected = causes,
                    inline = T)))),
  fluidRow(column(12, hr())),
  fluidRow(column(4, 
                  h4("total number of dead by month"),
                  plotOutput("myplot", height = "200px"),
                  h4("number of dead by death cause"),
                  plotOutput("myplot2", height = "200px")         
                    ),
           column(8,
                  h4("place of incident (darker color indicates higher loss)"),
                  leafletOutput("mymap", height ="400px")
                    )
           ),
  fluidRow(column(12, hr())),
  fluidRow(column(12, strong(p("thanks to the migrant files journalist consortium for their dedication and important work!"), 
                  p("data source: http://www.themigrantsfiles.com/"))))
))
