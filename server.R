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
      select(avg_co2, max_co2, min_co2, avg_consumption_co2)
  })
  
co2_byYear <- reactive({
    df %>%
      filter(year == input$yearCalc) %>%
      select(co2, country)
  })



    
a <- summary_table %>%
    filter(year == 1990) %>%
    pull(avg_co2)
b <- summary_table %>%
  filter(year == 2021) %>%
  pull(avg_co2)
  
change <- round((b-a),2)



  
  output$summaryInfo <- renderUI({
    
    max_co2 <- co2_byYear() %>%
      filter(country != "World" & country != "Non-OECD (GCP)" & country != "High-income countries") %>%
      filter(co2 == max(co2, na.rm = T)) %>%
      pull(country)
    
    min_co2 <- co2_byYear() %>%
      filter(co2 == min(co2, na.rm = T)) %>%
      pull(country) %>%
      first()

    avg_co2_round <- round(avg_co2_byYear()$avg_co2 , 2)
    
    avg_consumption <- round(avg_co2_byYear()$avg_consumption_co2 , 2)
    
    year <- input$yearCalc
    HTML(paste0("For the year selected, <u>", year, "</u>, the average CO2 is: <b>", avg_co2_round, "</b> and ",
                "The average Consumption based CO2 is <b>", avg_consumption,
                "</b> <br> The country with max co2 in the year <u>", year, "</u> is <b>", max_co2,
                "</b> <br> The country with least co2 in the year <u>", year, "</u> is <b>", min_co2,
                "</b> <br> The amount of CO2 emissions has changed by <b>", change, "</b> from <u>1990 to 2021.</u>"))
  })
  
  
  output$map <- renderPlotly({
    # Join aggregated world_shape with subset_df
    df_map <- left_join(world_shape, subset_df, by = c("region" = "country"))
    
    df_map_unique <- df_map %>%
      filter(year == input$year) 

    if(input$co2Selection == "co2"){
      fill_type <- df_map_unique$co2
      title_type <- "Emissions of Carbon Dioxide by Region"
      hover_text <- paste0(round(df_map_unique$co2, 2), " million tons")
      yearVar <- input$year
    }else{
      fill_type <- df_map_unique$consumption_co2
      title_type <- "Consumption based emissions of carbon dioxide by Region"
      hover_text <- paste0(round(df_map_unique$consumption_co2, 2), " million tons")
      yearVar <- input$year
    }
    
    plot_colors <- c("#1a9850", "#66bd63", "#a6d96a", "#d9ef8b", "#ffffbf", "#fee08b", "#fdae61", "#f46d43", "#d73027", "#a50026")

    p <- ggplot(df_map_unique) +
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


