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
  select(country, consumption_co2, year)
#Rename United States to USA - for mapping purposes
subset_df$country[which(subset_df$country == "United States")] <- "USA"
# Join aggregated world_shape with subset_df
df_map_unique <- left_join(world_shape, subset_df, by = c("region" = "country"))
p <- ggplot(df_map_unique) +
  geom_polygon(aes(x = long, y = lat, group = group,
                   fill = consumption_co2)) +
  scale_fill_gradient(low = "white", high = "red") +
  theme_void()

ggplotly(p)

# Create a summary table
summary_table <- df %>%
  filter(year> 1990) %>%
  group_by(year) %>%
  summarize(avg_co2 = mean(co2, na.rm = TRUE),
            max_co2 = max(co2, na.rm = TRUE),
            min_co2 = min(co2, na.rm = TRUE),
            avg_consumption_co2 = mean(consumption_co2, na.rm = TRUE),
            max_consumption_co2 = max(consumption_co2, na.rm = TRUE),
            min_consumption_co2 = min(consumption_co2, na.rm = TRUE))


server <- function(input, output) {
  
  df <- read.csv("https://raw.githubusercontent.com/owid/co2-data/master/owid-co2-data.csv", stringsAsFactors = FALSE)
  
  world_shape <- map_data("world")
  
  subset_df <- df %>%
    group_by(country) %>%
    select(country, co2, consumption_co2, year) %>%
    mutate(country = ifelse(country == "United States", "USA", country))
  # Create a summary table
  summary_table <- df %>%
    filter(year> 1989) %>%
    group_by(year) %>%
    summarize(avg_co2 = mean(co2, na.rm = TRUE),
              max_co2 = max(co2, na.rm = TRUE),
              min_co2 = min(co2, na.rm = TRUE),
              avg_consumption_co2 = mean(consumption_co2, na.rm = TRUE),
              max_consumption_co2 = max(consumption_co2, na.rm = TRUE),
              min_consumption_co2 = min(consumption_co2, na.rm = TRUE))


#  avg_co2_byYear <- summary_table %>%
#    filter(year == input$yearCalc) %>%
#    select(avg_co2)
  # Render the summary table
  output$summary_table <- renderTable({
    return(summary_table)
  })
  
  avg_co2_byYear <- reactive({
    summary_table %>%
      filter(year == input$yearCalc) %>%
      select(avg_co2, max_co2, min_co2)
  })
  max_co2_byYear <- reactive({
    df %>%
      filter(year == input$yearCalc) %>%
      filter(co2 == max(co2)) %>%
      pull(country)
  })

    
a <- summary_table %>%
    filter(year == 1990) %>%
    pull(avg_co2)
b <- summary_table %>%
  filter(year == 2021) %>%
  pull(avg_co2)
  
change <- round((b-a),2)



  
  output$summaryInfo <- renderText({
    avg_co2_round <- round(avg_co2_byYear()$avg_co2 , 2)
    year <- input$yearCalc
    paste0("For the year selected, ", year, ", the average CO2 is: ", avg_co2_round, 
           "\n The country with max co2 in the year ", year, " is ", max_co2_byYear()
           ,"The amount of CO2 emmissions has changed by ", change , " from 1990 to 2021")
  })
  
  
  output$map <- renderPlotly({
    # Join aggregated world_shape with subset_df
    df_map <- left_join(world_shape, subset_df, by = c("region" = "country"))
    
    df_map_unique <- df_map %>%
      filter(year == input$year) 
    
    if(input$co2Selection == "co2"){
      fill_type <- df_map_unique$co2
      title_type <- "Emissions of Carbon Dioxide by Region"
      yearVar <- input$year
    }else{
      fill_type <- df_map_unique$consumption_co2
      title_type <- "Consumption based emissions of carbon dioxide by Region"
      yearVar <- input$year
    }
    
    plot_colors <- c("#1a9850", "#66bd63", "#a6d96a", "#d9ef8b", "#ffffbf", "#fee08b", "#fdae61", "#f46d43", "#d73027", "#a50026")

    p <- ggplot(df_map_unique) +
      geom_polygon(aes(x = long, y = lat, group = group,
                       fill = fill_type)) +
      scale_fill_gradientn(colors = plot_colors) +
      labs(title = title_type, subtitle = paste0("measured in million tonnes \nYear ", input$year)) +
      theme(axis.text = element_text(size = 12), axis.title = element_text(size = 14))
    
    return(
      ggplotly(p)%>%
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


