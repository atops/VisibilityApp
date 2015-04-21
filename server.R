
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
df <- df %>% 
        # Remove fields we don't need.
        select(-(Month:Serial..)) %>%
        # blank dates = bad data
        filter(Date...Time!="") %>% 
        # Convert to date/time data type.
        mutate(Date...Time = as.POSIXct(Date...Time, format="%m/%d/%Y %H:%M")) %>%
        # "unpivot" (gather) MM.X.X columns into "Visibility" column
        gather(MileMarker, Visibility, MM.1.2:MM.16.9) %>%
        # convert feet to miles
        mutate(Visibility_mi = Visibility/5280)

milemarkers <- levels(df$MileMarker)

shinyServer(function(input, output, session) {
        
        # Allow the user to select the ESS they want.
        observe({
                updateCheckboxGroupInput(session, "stations",
                          choices = milemarkers,
                          selected = milemarkers)
        })

        output$timeseries <- renderPlot({

                # Subset by time period and facet by MileMarker
                t1 <- strftime(input$dates[1], "%Y-%m-%d") # from 12:00 am
                t2 <- strftime(input$dates[2] + days(1), "%Y-%m-%d") # until 12:00 am next day
                
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

        }, height=800) # height defaults to 400; can't seem to make it fill the screen automatically

})
