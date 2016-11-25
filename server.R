#------------------------------------------
#essentials

library(shiny)
library(leaflet)
library(magrittr)
library(dygraphs)
library(ggplot2)
library(zoo)

#------------------------------------------
#load data
#pf.dasa <- "D:/Eigene Dokumente/weiterbildung/CAS Data Science Applications/visualisierung/praktikum/visproj/shiny app"
#inc.agg3 <- readRDS(file.path(pf.dasa, "inc3.agg.rds"))
#inc2 <- readRDS(file.path(pf.dasa,"inc2.rds"))
inc.agg3 <- readRDS( "inc3.agg.rds")
inc2 <- readRDS("inc2.rds")


#------------------------------------------
#hilfsvars
dform1 <- "%Y-%m-%d"
pal1 <- colorNumeric(palette = c('#FFFF66','#FF4500'),
                     domain = c(min(inc2$col), max(inc2$col)))

#------------------------------------------
# Define server logic required to plot various variables against mpg
shinyServer(function(input, output) {
  
  filtdat <- reactive({
    md <- as.Date(input$zeit,format = dform1)
    inc2[inc2$dat >= md[1] & inc2$dat <= md[2] & inc2$cause %in% input$causes,]
  })
  
  filtdat2 <- reactive({
    md <- as.Date(input$zeit,format = dform1)
    temp <- inc.agg3[inc.agg3$month2 >= md[1] & inc.agg3$month2 <= md[2] & inc.agg3$cause == "all",]
    temp
  })
  
  filtdat3 <- reactive({
    md <- as.Date(input$zeit,format = dform1)
    temp <- inc.agg3[inc.agg3$month2 >= md[1] & inc.agg3$month2 <= md[2] & inc.agg3$cause != "all",]
    temp2 <- aggregate(temp$ndeaths, by=list(temp$cause), FUN=sum)
    names(temp2) <- c("cause","ndeaths")
    temp2
  })
  
  output$mymap <- renderLeaflet({
    leaflet(inc2) %>% 
      setView(lng=16, lat=43, zoom=4) %>% 
      addProviderTiles("CartoDB.Positron")
  
  })
  
  observe({
    leafletProxy("mymap", data = filtdat()) %>%
      clearMarkers() %>%
      addCircleMarkers(lng= ~lon, lat= ~lat,fillColor = ~pal1(col),radius=5,
                       stroke=F,fillOpacity = 0.5, 
                       popup = ~paste(sep= "<br/>" , 
                                      paste0("<b>date: ",dat,"</b>"),
                                      description,"",
                                      paste0("number of dead: ",dead_and_missing)))
  })
  
  output$myplot <- renderPlot({
    
    ggplot(data = filtdat2(),
           aes(x=month2, y=ndeaths, fill=ndeaths)) + 
      geom_bar(stat="identity") +
      scale_x_date(date_breaks = "1 year", date_labels = "%Y")  +
      xlab("") + ylab("") +
      scale_fill_gradient( low = '#FFFF66', high = '#FF4500', guide = F) +
     theme_classic()+ 
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
    
    })
  
  output$myplot2 <- renderPlot({ 
    ggplot(data=filtdat3(),aes(x=cause, y=ndeaths, fill=ndeaths)) + 
      scale_fill_gradient( low = '#FFFF66', high = '#FF4500', guide = F) +
      geom_bar(stat="identity") +
      guides(fill=F)+
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      coord_flip()+ 
      xlab("") + ylab('') +
      theme_classic()+
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
    
  })
  
})


