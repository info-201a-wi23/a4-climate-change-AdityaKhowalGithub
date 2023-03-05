
library("ggplot2")
library("plotly")
library("dplyr")
library("scales")
library("rworldmap")

#im not using read.csv to use less memory
#  df <- data.table::fread("https://raw.githubusercontent.com/owid/co2-data/master/owid-co2-data.csv", stringsAsFactors = FALSE)

df <- read.csv("https://raw.githubusercontent.com/owid/co2-data/master/owid-co2-data.csv", stringsAsFactors = FALSE) 

world_map <- getMap(resolution = "low")

world_shape <- fortify(world_map)

  #map_data("world")

#detach(package:maps)# in hopes to use less memory

subset_df <- df %>%
  filter(year > 2009) %>%
  group_by(country) %>%
  select(country, consumption_co2, co2, year)

  #Rename United States to USA - for mapping purposes
  subset_df$country[which(subset_df$country == "United States")] <-  "United States of America"

df_map <- left_join(world_shape, subset_df, by = c("id" = "country"))
# df_map <- df_map00 %>%
#   filter(year > 1999)
#remove(df_map)
rm(world_shape)
rm(df)
rm(world_map)

calculate_summary_table <- function(yearIn) {
  num <- subset_df %>%
    filter(year == yearIn) %>%
    group_by(year) %>%
    summarize(avg_co2 = mean(co2, na.rm = TRUE),
              avg_consumption_co2 = mean(consumption_co2, na.rm = TRUE))
}



calculate_co2_byYear <- function(yearIn, bool){
  df <- subset_df %>%
    filter(year == yearIn) %>%
    group_by(year)
  
  if (bool) {
    country <- df %>%
      filter(country != "World" & country != "Non-OECD (GCP)" & country != "High-income countries") %>%
      filter(co2 == max(co2, na.rm = TRUE)) %>%
      pull(country) 
  } else {
    country <- df %>%
      filter(co2 == min(co2, na.rm = TRUE)) %>%
      pull(country) %>%
      first()
  }
  
}

a <- calculate_summary_table(2000)$avg_co2

b <- calculate_summary_table(2020)$avg_co2

change <- round((b-a),2)
plot_colors <- c("#1a9850", "#66bd63", "#a6d96a", "#d9ef8b", "#ffffbf", "#fee08b", "#fdae61", "#f46d43", "#d73027", "#a50026")
server <- function(input, output) {
  
 df_map_unique <- reactive({
   df_map %>%
   filter(year == input$year)
 })

  output$summaryInfo <- renderUI({

    max_co2 <- calculate_co2_byYear(input$yearCalc, TRUE)

    min_co2 <- calculate_co2_byYear(input$yearCalc, FALSE) 

    avg_co2_round <- round(mean(calculate_summary_table(input$yearCalc)$avg_co2, na.rm = T) , 2)

    avg_consumption <- round(mean(calculate_summary_table(input$yearCalc)$avg_consumption_co2, na.rm = T) , 2)

    year <- input$yearCalc

    HTML(paste0("For the year selected, <u>", year, "</u>, the average CO2 is: <b>", avg_co2_round, "</b> and ",
                "The average Consumption based CO2 is <b>", avg_consumption,
                "</b> <br> The country with max co2 in the year <u>", year, "</u> is <b>", max_co2,
                "</b> <br> The country with least co2 in the year <u>", year, "</u> is <b>", min_co2,
                "</b> <br> The amount of CO2 emissions has changed by <b>", change, "</b> from <u>2000 to 2021.</u>"))
  })
  
  

  output$map <- renderPlotly({

    if(input$co2Selection == "co2"){
      fill_type <- df_map_unique()$co2
      title_type <- "Emissions of Carbon Dioxide by Region"
      hover_text <- paste0(round(df_map_unique()$co2, 2), " million tons")
      yearVar <- input$year
    }else{
      fill_type <- df_map_unique()$consumption_co2
      title_type <- "Consumption based emissions of carbon dioxide by Region"
      hover_text <- paste0(round(df_map_unique()$consumption_co2, 2), " million tons")
      yearVar <- input$year
    }

    

    p <- ggplot(df_map_unique()) +
      geom_polygon(aes(x = long, y = lat, group = group,
                       fill = fill_type, text = hover_text)) +
      scale_fill_gradientn(colors = plot_colors, labels = waiver()) +
      labs(title = title_type, subtitle = paste0("measured in million tonnes \nYear ", input$year),  fill = "Million Tons of CO2") +
      theme(axis.text = element_text(size = 12), axis.title = element_text(size = 14))

    return(
      ggplotly(p, tooltip="text")%>%
        layout(title = list(text = paste0(title_type,
                                          '<br>',
                                          '<sup>',
                                          "measured in million tonnes",
                                          '<br>',
                                          paste0("Year: ", yearVar),
                                          '</sup>')))
      )
  })
}


