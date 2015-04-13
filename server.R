
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)

df <- read.csv("data/2013 Visibility Data.csv", 
               colClasses=c("character", rep("numeric",17)), 
               na.strings="#N/A")

# Use dplyr and tidyr packages to tidy the data and prepare for plotting.
#  Remove fields we don't need.
#  Convert to date/time data type.
#  "unpivot" (gather) MM.X.X columns into "Visibility" column
# Save as new data.frame in case want to go back to original csv
df <- df %>% 
        select(-(Month:Serial..)) %>%
        filter(Date...Time!="") %>% 
        mutate(Date...Time = as.POSIXct(Date...Time, format="%m/%d/%Y %H:%M")) %>%
        gather(MileMarker, Visibility, MM.1.2:MM.16.9) %>%
        mutate(Visibility_mi = Visibility/5280)

milemarkers <- levels(df$MileMarker)

shinyServer(function(input, output, session) {
        
        observe({
                updateCheckboxGroupInput(session, "stations",
                          choices = milemarkers,
                          selected = milemarkers)
        })

        output$timeseries <- renderPlot({

                # Subset by time period and facet by MileMarker
                t1 <- strftime(input$dates[1], "%Y-%m-%d") # inclusive
                t2 <- strftime(input$dates[2] + days(1), "%Y-%m-%d") # inclusive of 
                
                df2 <- df %>% 
                        filter(Date...Time >= t1 & Date...Time < t2) %>%
                        filter(MileMarker %in% input$stations)
                qplot(data=df2, 
                        x=Date...Time, 
                        y=Visibility_mi, 
                        facets=MileMarker ~ ., 
                        geom="line", 
                        #main="Visibility over Time and Space\n(Ten Minute Observations)\n",
                        ylab="Visibility (mi)",
                        xlab="Date and Time") +
                        theme(axis.text.x = element_text(size=8)) +
                        theme(axis.text.y = element_text(size=8))

        }, height=800)

})
