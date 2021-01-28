
library(shiny)

shinyUI(fluidPage(

    titlePanel("Predict next word"),
    sidebarLayout(
        
        sidebarPanel(
            textInput("text1", "Enter phrase from first 2000 lines"),
            #selectInput("ngrams", "N-Grams:",c(1:4)),
            submitButton("Submit")
        ),

        # Show a plot of the generated distribution
        mainPanel(
            h3("next word Options"),
            plotOutput("distPlot"),
            h3("next word would be"),
            textOutput("textMessage")
        )
    )
))
