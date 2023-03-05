library("ggplot2")
library("plotly")
library("markdown")



  
# Load the introduction markdown
intro_text <- includeMarkdown("Introduction.md")
conc_text <- includeMarkdown("conclusion.md")
detach(package:markdown)
# Create the UI
ui <- navbarPage(
  
  # Home page title
  "CO2 Emissions Data",
  
  # Introduction tab
  tabPanel(
    "Introduction",
    fluidPage(
      intro_text,
      sliderInput("yearCalc", "Year:", min = 2010, max = 2021, value = 2020, sep = ""),
      #tableOutput("summaryInfo")
      #"For the year selected: ", year, "the average co2 for all the countries was ", avg_co2, " million tons"
      uiOutput("summaryInfo"),
      conc_text
      
      
    )
  ),
  
  # Data viz tab
  tabPanel(
    "Data Visualization",
    sidebarLayout(
      sidebarPanel(
        sliderInput("year", "Year:", min = 2010, max = 2021, value = 2020, sep = ""),
        radioButtons(inputId = "co2Selection", label = "Select CO2 type", 
                     choices = c("CO2 Emissions" = "co2", "Consumption-based CO2 Emissions" = "consumption_co2"))
      ), 
      mainPanel(
        plotlyOutput("map", width = "100%", height = "800px"),
        p("The above plot shows the global CO2 emissions by country. You can adjust the year and CO2 type using the widgets on the left."),
        p("Based on the plot, it can be observed that throughout the duration of 2010 - 2021  that the US and most of asia emmits the most a
          amount of CO2. There is also a positive correlation between consumption based CO2 and normal CO2 emissions.  I also noticed that the 
          amount that the average consumption based CO2 increases is very close to the increase in average CO2 emissions. When running locally I
          extended this range to 1990 - 2021. When doing this I noticed that our max emissions have more than doubled in that time
          and the scale itself has to change to account for this.")
      )
    )
  )
)
