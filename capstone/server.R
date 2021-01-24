#
#
#    Capstone Project
#

library(shiny)
library("tm")
library(SnowballC)
library(RWeka)
library(ggplot2)
library(stringr)

shinyServer(function(input, output) {

    findOurSent<- function(file, sentence) {
        con <- file(file, "r")
        sentences = c()
        counter = 0
        while ( TRUE ) {
            
            line = readLines(con, n = 1, skipNul=T,warn=FALSE)
            if ( length(line) == 0 ) {
                break
            }else{

                if(grepl( sentence, line, fixed = TRUE)) {
                    counter = counter+1
                    loc<-str_locate(line, sentence)
                    lastWord2<-str_locate(substr(line,loc[1,2]+1,nchar(line))," ")#find next space
                    sentences[counter] = substr(line,loc[1,1],(loc[1,2]+lastWord2[1,1]))
                    if(counter>200) {
                        break
                    }
                }
            }
        }
        print(sentences)
        close(con)
        sentences
    }

    letsRun<- reactive({
        text1<-input$text1
        ngrams<-as.numeric(input$ngrams)
        
        List <- strsplit(text1, " ")
        text1<-paste(List[[1]][(length(List[[1]])-(ngrams-2)):(length(List[[1]]))], collapse = ' ')
        if(!(endsWith(text1,' '))) {
            text1<-str_c(text1,' ')    
        }
        
        print('sentence is:')
        print(text1)
        if(nchar(text1)>1 && ngrams>1) {
            newsfinds<-findOurSent("en_US_small/en_US.news.txt",text1)
            blogsfinds<-findOurSent("en_US_small/en_US.blogs.txt",text1)
            twitterfinds<-findOurSent("en_US_small/en_US.twitter.txt",text1)
            
            all_data = c(newsfinds,blogsfinds,twitterfinds)
            all_data[which(is.na(all_data))] <- "NULLVALUEENTERED"
            
            twitter.Corpus <- VCorpus(VectorSource(all_data))
            
            NthgramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min=input$ngrams, max=input$ngrams))
            dtm <- DocumentTermMatrix(twitter.Corpus, control = list(tokenize=NthgramTokenizer))
            
            frequencyPerWord <- sort(colSums(as.matrix(dtm)), decreasing=TRUE)
            frequencyPerWord <- data.frame(
                word = names(frequencyPerWord),
                frequency = frequencyPerWord
            )
            frequencyPerWord
        }
    })


    output$distPlot <- renderPlot({
        frequencyPerWord<-letsRun()
        
        if(length(frequencyPerWord)>0) {
            print("frequency per word data found")
            print(length(frequencyPerWord))
            
            ggplot(subset(frequencyPerWord[1:5,]), aes(x=reorder(word, -frequency), y=frequency)) +
            geom_bar(stat="identity") +
            theme(axis.text.x = element_text(angle = 90))
            
        }

        
    })
    output$textMessage<-renderText({
        frequencyPerWord<-letsRun()
        if(length(frequencyPerWord)>0) {
            List <- strsplit(frequencyPerWord[1,]$word, " ")
            lastWord<-List[[1]][(length(List[[1]]))]
        }
    })
    
    

})
