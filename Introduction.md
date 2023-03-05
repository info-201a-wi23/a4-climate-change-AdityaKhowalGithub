# Introduction

In this small project, I will analyze the features of CO2 emissions and consumption-based CO2 emissions by region and year. I believe that it is important to see the trends of not just CO2 emissions by region but also consumption based CO2 as that is a more tangible statistic. Going beyond the extent of my project, by tracking "consumption emissions", researchers can, to some extent, find and target consumption activities that can be more sustainable. This is a perspective that should be considered for both the environmental and human welfare application, as it is important if I are to build a future that is both sustainable and provides high standards of living for everyone.

The data set I am analyzing is the [OWID CO2 data](https://github.com/owid/co2-data), which contains annual CO2 emissions data for countries and regions from 1751 to 2021. For this project, I am choosing to target the period from 1990 - 2021 as this is more relevant to our consumption and co2 practices now.

The data was collected by Our World in Data (OWID) and is based on multiple sources including:

-   Statistical review of world energy (BP)

-   International energy data (EIA)

-   Global Carbon Project

-   Other academic and government institutions

The data was also processed in multiple steps, and goes way more in depth on the actual dataset's documentation.

The data was collected to provide a comprehensive view of global CO2 emissions over time. There are currently 75 different variables to analyze in the dataset. With more data incoming, and more variables to analyze we can compare and find trends in the data to apply to our real life CO2 emissions issue. Climate change is a big problem in our present and will be worse in our future and collecting data will help us find the most efficient solution.

One possible limitation of this data is that it only includes CO2 emissions and does not account for other greenhouse gases. Additionally, there are a lot of null values where data was not documented or lost, this provides holes out our map. For example it is hard to show years before 1960 or even some countries in 2021, as there is no data or not enough data to analyze.

Another huge problem is the naming conventions of countries in DF. Country names such as "world", "Non-OECD", "OECD", "GCP", and more threw my calculations off. I accounted for these extrenious names when I could but this means that there are slight differences in my map to my calculated summary data below. For example Europe(gcp) doesnt exist on the world map polygon file, so it is unable to be displayed on the map.

**Calculated Values by selected year:**
