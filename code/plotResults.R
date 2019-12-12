getPieChart <- function(dataset,column,fontSize,colors,titleStr,alphaVal,noUpper,legendStr){
  nargin  <- length(as.list(match.call())) -1
  if (nargin<4){colors   <- factor(classes)}
  if (nargin<5){titleStr <- ''}
  if (nargin<6){alphaVal <- 1}
  if (nargin<7){
    classes <- unique(toupper(dataset[,column]))
    dataset[,column] <- toupper(dataset[,column])
  } else{classes <- unique((dataset[,column]))}
  if (nargin<8){legendStr <- ''}
  N_elements <- c()
  prop       <- c()
  for (element in classes){
    entries    <- length(which(dataset[,column]==element))
    N_elements <- c(N_elements,entries)
    percentage <- entries*100/nrow(dataset)
    prop       <- c(prop,percentage)
  }
  prop <- round(prop, digits = 2)
  df   <- data.frame(classes,N_elements,prop,stringsAsFactors = FALSE)
  # Add label position
  df <- df %>%arrange(desc(classes))%>%mutate(lab.ypos = cumsum(prop) - 0.5*prop)
  
  #Create plot object
  p <- ggplot(df, aes(x = 2, y = prop, fill = classes)) +
    geom_bar(stat = "identity", color = "white",width=0.2) +
    geom_text_repel(aes(y=lab.ypos,label = prop), color = "black",size=fontSize)+
    scale_fill_manual(values = alpha((colors),alphaVal)) + coord_polar('y',start=0) +
    xlim(1.6, 2.2) 
  if (nchar(titleStr)>=1){
    p <- p + ggtitle(titleStr) 
  }
  if (nchar(legendStr)>=1){
    p <- p + theme_void(base_size = 2*fontSize,legend.title = legendStr) + theme(legend.position = c(0.5,0.5),legend.title = element_blank())
  }else{
    p <- p + theme_void(base_size = 2*fontSize) + theme(legend.position = c(0.5,0.5),legend.title = element_blank())
  }
  plot(p)
}

##barPlot_counts
barPlot_counts <- function(dat1,xLabel,yLabel,fontSize,colors,alphaVal,legendFlag){
  nargin <- length(as.list(match.call())) -1
  if (nargin<7){
    legendFlag <- FALSE
    if (nargin<6){
      alphaVal <- 1
      if (nargin<5){
        colors <- factor(dat1$categories)
      }
    }
  }
  p <- ggplot(data=dat1, aes(x=categories,y=counts,fill=categories)) + geom_bar(stat='identity')+ 
    scale_fill_manual(values = alpha(colors,alphaVal)) + theme_bw(base_size = 2*fontSize) + xlab(xLabel) +
    ylab(yLabel)
  if (legendFlag==FALSE){
    p <- p+ theme(legend.position = "none")
  }else{p <- p + theme(axis.title.x=element_blank(),
                       axis.text.x=element_blank(),
                       axis.ticks.x=element_blank())}
  
  plot(p)
} 

##scatterPlot
scatterPlot <- function(df,yCol,fontSize,xLabel,yLabel,colors,alphaVal){
  nargin <- length(as.list(match.call())) -1
  #if (nargin<6){
  #  colors   <-  as.factor(df$Organism)
  #  alphaVal <- 1
  #}
  df$Elapsed_time <- gsub('NaN',NA,df$Elapsed_time)
  df$Elapsed_time <- as.numeric(df$Elapsed_time)
  df[,yCol]       <- gsub('NaN',NA,df[,yCol])
  df[,yCol]       <- as.numeric(df[,yCol])
  df$Organism     <- as.factor(df$Organism)
  
  p <- ggplot(df, aes(x=Elapsed_time, y=df[,yCol], shape=growth)) +
       geom_point(size=5,aes(colour=Organism))+ scale_colour_manual(values = colors) + 
       theme_bw(base_size = 2*fontSize) + xlab(xLabel) +  ylab(yLabel)
  plot(p)
} 

#Function that takes a dataset and list of classes for generating a list of distributions of values for each 
#unique class. The class comparison is done in the column provided as input.
getClassCounts <- function(dataset,column){
  categories <- c()
  for (i in 1:nrow(dataset)){
    row <- dataset[i,column]
    entries <- strsplit((row),'/',fixed=TRUE)
    for (element in entries){
      categories <- c(categories,element) 
    }
  }
  categories <- unique(categories)
  counts <- c()
  for (class in categories){
    counts <- c(counts,length(grep(class,dataset[,column],fixed=TRUE)))
  }
  df <- data.frame(categories,counts,stringsAsFactors = FALSE)
  return(df)
} 
