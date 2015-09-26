library(shiny)
library(ggplot2)
require("XML")

Fun2 <-function(city,element){
      dumFun <- function(x){
            xname <- xmlName(x)
            xattrs <- xmlAttrs(x)
            c(sapply(xmlChildren(x), xmlValue), name = xname, xattrs)
      }
      xdata<-paste("http://api.openweathermap.org/data/2.5/forecast?q=",city,"&mode=xml",sep = "")
      dum <- xmlParse(xdata)
      base<-"//*/time" #root node we want. 
      nextnode<- paste(base,element,sep = "/") #the subnode we want
      
      #We read our root node
      DATARAW<-as.data.frame(t(xpathSApply(dum, base, dumFun)), stringsAsFactors = FALSE)
      
      #We take the variables "from" and "to" converting them to proper time data
      DATA1<-data.frame(from=strptime(DATARAW$from, "%Y-%m-%dT%H:%M:%S"),to=strptime(DATARAW$to, "%Y-%m-%dT%H:%M:%S"))
      #DATA1$from <- strptime(DATARAW$from, "%Y-%m-%dT%H:%M:%S") #converting to proper time data
      #DATA1$to <- strptime(DATA1$to, "%Y-%m-%dT%H:%M:%S")  #converting to proper time data
      #DATA1<-data.frame(DATA1, idcol = seq_len(nrow(DATA1)))
      
      #We take all the variables from the subnode
      DATA2<-as.data.frame(t(xpathSApply(dum, nextnode, dumFun)), stringsAsFactors = FALSE)
      #DATA2<-data.frame(DATA2, idcol = seq_len(nrow(DATA2)))
      #merge(DATA1,DATA2,by="idcol")
      data.frame(DATA1,DATA2)
}


library(leaflet)
m <- leaflet()
m <- addTiles(m)
m <- addMarkers(m, lat=41.1548179, lng=1.1086760, popup="Reus")
m <- addMarkers(m, lat=48.8566667, lng=2.3509871, popup="Paris")
m <- addMarkers(m, lat=51.50013, lng=-0.126305, popup="London")
m = m %>% setView(lat=41.1548179, lng=1.1086760, zoom = 5)



shinyServer(
      function(input, output, session) {
            output$mymap <- renderLeaflet({

                  if (input$city=="Reus") 
                        m = m %>% setView(lat=41.1548179, lng=1.1086760, zoom = 6)
                  else if(input$city=="Paris")
                        m = m %>% setView(lat=48.8566667, lng=2.3509871, zoom = 6)
            
                  else if(input$city=="London")
                        m = m %>% setView(lat=51.50013, lng=-0.126305, zoom = 6)
                  
                  m
                  
            })
            output$newFigure <- renderPlot({
                  if (input$city=="Reus") 
                        q<-"Reus,es"
                  else if(input$city=="Paris")
                        q<-"Paris,fr"
                  else if(input$city=="London")
                        q<-"London,gb"

                  element<-tolower(input$element)
                  data<-Fun2(q,element)
                  yunits<-toString(data$unit[1])
                  p <- ggplot(data, aes(y=(as.numeric(value)-273.15), x=from)) + 
                        theme(plot.title = element_text(lineheight=.8, face="bold",vjust=2))+
                        geom_line()+
                        labs(title=paste(input$element, "forecast in",input$city),x="Time",y = paste(input$element,"[",yunits,"]"))
                  if(input$regression)
                        p <-p + geom_smooth(method = "lm")
                  print(p)
            })
      
      }
)