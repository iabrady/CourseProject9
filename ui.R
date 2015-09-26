library(shiny)
library(leaflet)

library(markdown)

shinyUI(
      navbarPage(" Developing Data Products: Course Project",
                 tabPanel("Main Panel",
                          sidebarLayout(
                                sidebarPanel(
                                      h3('Control Panel'),
                                      selectInput('city', 'City', c('Reus', 'Paris', 'London')),
                                      selectInput('element', 'Element', c('Temperature', 'Pressure', 'Humidity')),
                                      checkboxInput('regression', 'Regression'),
                                      h3('City location'),
                                      leafletOutput("mymap")
                                      
                                ),
                                
                                
                                mainPanel(
                                      h3('5 day Forecast'),
                                      plotOutput('newFigure'),
                                      HTML("<br><br><h4>Warning</h4><p>This figure obtains its data (in XML format) from the <a href='http://openweathermap.org/forecast5'>OpenWeatherMap web</a> thus it depends on its proper functioning. Please, feel free to use the Help page on top of the page for more information.</p>")                                

                                )                            )),
                          
                 tabPanel("HELP !",
                          includeHTML("include.html")
                          )
      )
)