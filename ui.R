
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

        # Application title
        titlePanel("Visibility Data From Roadside Environmental Sensor Stations"),

        # Sidebar with a slider input for number of bins
        sidebarLayout(
                sidebarPanel(
                        h3("2013 Data"),
                        dateRangeInput("dates",
                                "Date Range:",
                                start = "2013-07-16",
                                end = "2013-07-24",
                                min = "2013-01-01",
                                max = "2013-12-31",
                                format = "mm/dd/yyyy"),
                        p("This plot shows visibility data from Environmental Sensor Stations (ESS) on a major freeway in the United States that is often subject to foggy conditions, which reduces visibility and which has contributed  to too many severe accidents.\n"),
                        p("The location of each ESS is denoted by Mile Marker (MM), from 1.2 to 16.9; each station is arranged in order vertically according to its location.\n"),
                        p("When visibility is not impeded, the stations return a value of 6562 ft, which on the plot is the flatline at approx. 1.2 mi."),
                        p("Data from the 2013 calendar year was made available for analysis. Each point is a reading taken at 10 minute intervals."),
                        width = 3
                ),

                # Show a plot of the generated distribution
                mainPanel(
                        #textOutput("t1"),
                        #textOutput("t2"),
                        plotOutput("timeseries")
                )
        )
))