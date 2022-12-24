library(shinydashboard)
library(shiny)
library(shinycssloaders)
library(tidyverse)
library(highcharter) 
library(lubridate)
library(stringr)
library(xts)
library(readr)
library(DT)
library(ggthemes)
options(scipen = 999)
library(scales)
library(argonDash)
library(rsconnect)
server <- function(input, output,session) {
  
  AppData <- read_csv("googleplaystore.csv")
  Rating <- AppData[which(AppData$Rating == 19),] <- NA

  AppData$Category = as.factor(AppData$Category)
  AppData$Installs = as.factor(AppData$Installs)
  AppData$Type = as.factor(AppData$Type)

  AppData$`Content Rating` = as.factor(AppData$`Content Rating`)

  AppData$`Last Updated` = as.POSIXct(AppData$`Last Updated`,format = "%B %d, %Y",tz=Sys.timezone())

  AppData$Price = as.numeric(gsub('[$.]', '', AppData$Price))/100
  missing_data = AppData %>%
    map_df(function(x) sum(is.na(x))) %>%
    gather(feature, num_nulls)%>%
    arrange(desc(num_nulls))%>%
    mutate(percent_missing = num_nulls/nrow(AppData)*100)

  

  #### Plotting Price----
  output$Price_free <- renderPlot({


    AppData%>%
      filter(!is.na(Type))%>%
      filter(Type != '0')%>%
      filter(Type != "NaN")%>%
      ggplot(aes(Type,  fill=Type)) +
      geom_bar( width=.3) +
      labs(title = "Apps by Type (Paid/Free)",
           x = "",
           y = "Count")+
      ylim(0,12000)  + theme_classic() -> op
    op


  })
  



  output$Price_cat_free <- renderPlot({
    AppData$Category <- tolower(AppData$Category)
    AppData$Installs <- gsub(",", "", gsub("\\.", "", AppData$Installs))
    AppData$Installs <- as.character(AppData$Installs)
    AppData$Installs = substr(AppData$Installs,1,nchar(AppData$Installs)-1)
    AppData$Installs <- as.numeric(AppData$Installs)

    AppData%>%
      filter(Type == "Free") %>%
      group_by(Category) %>%
      summarise(totalInstalls = sum(Installs)) %>%
      arrange(desc(totalInstalls)) %>%
      head(10) %>%
      ggplot(aes(x = Category, y = totalInstalls)) +
      geom_bar(stat="identity", width=.5,  fill="deepskyblue2") +
      labs(title= "Top10 Free Categories" ) +
      theme(axis.text.x = element_text(angle=65, vjust=0.6))  + theme_minimal()-> op
    op


  })
  


  output$Price_cat_paid <- renderPlot({
    AppData$Category <- tolower(AppData$Category)
    AppData$Installs <- gsub(",", "", gsub("\\.", "", AppData$Installs))
    AppData$Installs <- as.character(AppData$Installs)
    AppData$Installs = substr(AppData$Installs,1,nchar(AppData$Installs)-1)
    AppData$Installs <- as.numeric(AppData$Installs)

    AppData%>%
      filter(Type == "Paid") %>%
      group_by(Category) %>%
      
      summarise(totalInstalls = sum(Installs)) %>%
      arrange(desc(totalInstalls)) %>%
      head(10) %>%
      ggplot(aes(x = Category, y = totalInstalls)) +
      geom_bar(stat="identity", width=.5,  fill="forestgreen") +
      labs(title= "Top10 Paid Categories" ) +
      theme(axis.text.x = element_text(angle=65, vjust=0.6))  + theme_minimal()-> op
    op
  })
  
  
  


  output$Cat_bar <- renderPlot({
   
    
    AppData %>%
      group_by(Category) %>% 
      tally() %>% 
      arrange(desc(n)) %>% head(10) %>% 
      ggplot(aes(x = reorder(Category, -n), y = n, fill = Category)) +
      geom_bar(stat = "identity") +
      xlab("App Category") + ylab("Count") +
      theme(axis.text.x = element_text(angle=65, vjust=0.6))  + theme_minimal()-> op
    op
    
    
  })
  
  output$Rev_Rat <- renderPlot({
    
    AppData <- read_csv("googleplaystore.csv")
    AppData[, c(4)] <- sapply(AppData[, c(4)], as.numeric)
    AppData %>% 
      mutate(Reviews <- as.numeric(Reviews)) %>% 
      ggplot(
        aes(Reviews,Rating,col = `Content Rating`) ) +
      geom_point()+
      scale_x_continuous( breaks = breaks_pretty()) +
      ylim(0,5) +
      xlim(0,2000000) +
      theme_minimal() -> op
    op
    
  })

    ####Filtering ----


    observe({
      updateSelectInput(session,"cat", choices = AppData$Category)
    })
    gendata <- reactive({
      req(input$rt) -> rt ->>RT_SUP
      req(input$rv) -> rv ->>rv_supp
      req(input$ins) -> inst ->>inst_supp
      req(input$cat) -> ct ->> ct_s


      AppData$Category <- tolower(AppData$Category)
      AppData$Installs <- gsub(",", "", gsub("\\.", "", AppData$Installs))
      AppData$Installs <- as.character(AppData$Installs)
      AppData$Installs = substr(AppData$Installs,1,nchar(AppData$Installs)-1)
      AppData$Installs <- as.numeric(AppData$Installs)
      AppData %>%
        filter(Installs>inst_supp[1] & Installs<inst_supp[2] & Rating > RT_SUP[1] & Rating < RT_SUP[2] & Reviews > rv_supp[1] & Reviews<rv_supp[2]) %>%
        filter(Category == tolower(ct) ) %>%
        head(5) %>%  subset(select = (App))-> gendata




    })

  output$tbl <-DT::renderDataTable(
    gendata() ,
    width = "100%", height = "auto"
  )

    
  
}

  