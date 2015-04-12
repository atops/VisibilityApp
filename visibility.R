#  install.packages(c("dplyr", "tidyr", "ggplot2"))
library(dplyr)
library(tidyr)
library(ggplot2)

setwd("c:/users/alan.toppen/code/i-77")

# Already saved as csv from Excel. 
# Read csv into a data.frame, df
df <- read.csv("2013 Visibility Data.csv", 
	       colClasses=c("character", rep("numeric",17)), 
	       na.strings="#N/A")

# Use dplyr and tidyr packages to tidy the data and prepare for plotting.
#  Remove fields we don't need.
#  Convert to date/time data type.
#  "unpivot" (gather) MM.X.X columns into "Visibility" column
# Save as new data.frame in case want to go back to original csv
df2 <- df %>% 
	select(-(Month:Serial..)) %>%
	filter(Date...Time!="") %>% 
	mutate(Date...Time = as.POSIXct(Date...Time, format="%m/%d/%Y %H:%M")) %>%
	gather(MileMarker, Visibility, MM.1.2:MM.16.9) %>%
	mutate(Visibility_mi = Visibility/5280)

# Subset by time period and facet by MileMarker
t1 <- "2013-07-16" # inclusive
t2 <- "2013-07-24" # excluded
df3 <- df2 %>% 
	filter (Date...Time >= t1 & Date...Time < t2)
timeseries <- qplot(data=df3, 
	x=Date...Time, 
	y=Visibility_mi, 
	facets=MileMarker ~ ., 
	geom="line", 
	main="Visibility Over Time - One Week View\n(Ten Minute Observations)\n",
	ylab="Visibility (mi)",
	xlab="Date and Time") +
	theme(axis.text.x = element_text(size=8)) +
	theme(axis.text.y = element_text(size=8))
#pdf("visibility_timeseries.pdf", width=17, height=11)
print(timeseries)
#dev.off()

# Histogram faceted for each ESS and month
#  removed values that appear most often and which mask the trend
#  (6562 = maximum visibility, 0 = missing or suspect data)
df4 <- df2 %>% 
	filter(Visibility != 6562 & Visibility != 0) %>%
	mutate(month = strftime(Date...Time, "%m %B"))
histo <- qplot(data=df4, 
	x=Visibility_mi, 
	facets=MileMarker ~ month, 
	main="Visibility Histogram - all of 2013\n(Zero and Max Visibility Observations Removed)",
	xlab="Visibility (mi)",
	ylab="Number of Observations") +
	theme(axis.text.x = element_text(size=8)) +
	theme(axis.text.y = element_text(size=8))
pdf("visibility_histogram.pdf", width=17, height=11)
print(histo)
dev.off()