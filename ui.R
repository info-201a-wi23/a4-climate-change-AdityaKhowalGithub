library("plotly")
library("bslib")
library("ggplot2")
library("plotly")
library("dplyr")
library("scales")
library("leaflet")
library("shinythemes")


# Read in data
df <- read.csv("https://raw.githubusercontent.com/owid/co2-data/master/owid-co2-data.csv", stringsAsFactors = FALSE)
world_shape <- map_data("world")
subset_df <- df %>%
  filter(year == 2020) %>%
  group_by(country) %>%
  select(country, consumption_co2, co2)
#Rename United States to USA - for mapping purposes
subset_df$country[which(subset_df$country == "United States")] <- "USA"
#Join layoff data with world shapefile
df_map <- left_join(world_shape, subset_df, by = c("region" = "country"), multiple = "all")
column_names <- data.frame(names(df_map))
filtered_column_names <- column_names %>%
  filter(names.df_map. == "co2" | names.df_map. == "consumption_co2")

  
# Load the introduction markdown
intro_text <- includeMarkdown("Introduction.md")

# Create the UI
ui <- navbarPage(
  
  # Home page title
  "CO2 Emissions Data",
  
  # Introduction tab
  tabPanel(
    "Introduction",
    fluidPage(
      intro_text,
      sliderInput("yearCalc", "Year:", min = 1990, max = 2021, value = 2020, sep = ""),
      #tableOutput("summaryInfo")
      #"For the year selected: ", year, "the average co2 for all the countries was ", avg_co2, " million tons"
      textOutput("summaryInfo")
    )
  ),
  
  # Data viz tab
  tabPanel(
    "Data Visualization",
    sidebarLayout(
      sidebarPanel(
        sliderInput("year", "Year:", min = 1990, max = 2021, value = 2020, sep = ""),
        radioButtons(inputId = "co2Selection", label = "Select CO2 type", 
                     choices = c("CO2 Emissions" = "co2", "Consumption-based CO2 Emissions" = "consumption_co2"))
      ), 
      mainPanel(
        plotlyOutput("map", width = "100%", height = "800px"),
        p("The above plot shows the global CO2 emissions by country. You can adjust the year and CO2 type using the widgets on the left."),
        p("Based on the plot, it can be observed that ")
      )
    )
  ),
  tabPanel(
    "Summary Data",
    fluidPage(
        p("Here lies a summerized table of values that shows some relevant information from our data. ps. This is very summerized as the averages are computed for entire regions!"),
      tableOutput("summary_table")
    )
  )
)