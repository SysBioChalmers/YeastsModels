#!/usr/bin/env Rscript
# Ivan Domenzain
library(ggplot2)
library(dplyr)
library(ggrepel)
library(viridis)

setwd('/Users/ivand/Documents/GitHub/YeastsModels/code')
source('plotResults.R')
dataset    <- read.csv(file = '../data/models_table.txt', sep = '\t', header = TRUE, stringsAsFactors = FALSE)
#Duplicate dataset for plotting MEMOTE results for S. cerevisiae models
dataMEMOTE <- dataset
for (i in 1:ncol(dataset)){
  dataset[,i]     <- gsub('#VALUE!',NaN,dataset[,i])
  dataMEMOTE[,i]  <- gsub('#VALUE!',NaN,dataset[,i])
  dataset[is.na(dataset[,i]),i] <- NaN
}
colorsOrg <- c('grey','cyan','pink','orange','purple','brown','blue','black','green','red','dark green')

#File availability plot
setwd('../results/plots')
column <- which(colnames(dataset)=='Available_file')
plotTitle <- 'file_availability.png'
png(plotTitle,width = 600, height = 600)
p <- getPieChart(dataset,column,12,c('red','blue'),'',0.5)
dev.off()

#source SBML plot
column <- which(colnames(dataset)=='source_SBML')
plotTitle <- 'source_SBML.png'
png(plotTitle,width = 600, height = 600)
p <- getPieChart(dataset,column,12,c('red','blue'),'',0.5)
dev.off()

#Models per organism
column  <- which(colnames(dataset)=='Organism')
output  <- getClassCounts(dataset,column)
plotTitle <- 'models_organisms.png'
png(plotTitle,width = 700, height = 600)
barPlot_counts(output,'Organism','# of Models',12,colorsOrg,0.9,TRUE)
dev.off()

#Version control plot
column <- which(colnames(dataset)=='version_control')
data <- dataset[which(dataset[,column]!='NaN'),]
plotTitle <- 'version_control.png'
png(plotTitle,width = 600, height = 600)
p <- getPieChart(data,column,12,c('red','blue'),'',0.5)
dev.off()

#Growth plot
column <- which(colnames(dataset)=='growth')
data <- dataset[which(dataset[,column]!='NaN'),]
plotTitle <- 'growth.png'
png(plotTitle,width = 600, height = 600)
p <- getPieChart(data,column,12,c('red','blue'),'',0.5)
dev.off()

#Objective function plot
column <- which(colnames(dataset)=='Objective')
data <- dataset[which(dataset[,column]!='NaN'),]
plotTitle <- 'objective_function.png'
png(plotTitle,width = 600, height = 600)
p <- getPieChart(data,column,12,c('red','blue'),'',0.5)
dev.off()

#biomass rxn  plot
column <- which(colnames(dataset)=='biomassRxn')
data <- dataset[which(dataset[,column]!='NaN'),]
plotTitle <- 'biomassRxn.png'
png(plotTitle,width = 600, height = 600)
p <- getPieChart(data,column,12,c('red','blue'),'',0.5)
dev.off()

#Import/Export plot
column <- which(colnames(dataset)=='Import.Export')
data <- dataset[which(dataset[,column]!='NaN'),]
plotTitle <- 'import_export.png'
png(plotTitle,width = 600, height = 600)
p <- getPieChart(data,column,12,c('red','blue'),'',0.5)
dev.off()

#External DB plot
column <- which(colnames(dataset)=='external_DB')
plotTitle <- 'externalDB.png'
png(plotTitle,width = 600, height = 600)
p <- getPieChart(dataset,column,12,c('grey','blue','black','green','red','purple','orange'),'',0.5,TRUE)
dev.off()

#Memote plot
column <- which(colnames(dataset)=='MEMOTE_test')
data <- dataset[which(dataset[,column]!='NaN'),]
plotTitle <- 'MEMOTE.png'
png(plotTitle,width = 600, height = 600)
p <- getPieChart(data,column,12,c('blue','red'),'',0.5)
dev.off()

#Formats plot
column  <- which(colnames(dataset)=='Primary_Format')
output  <- getClassCounts(dataset,column)
plotTitle <- 'model_formats.png'
png(plotTitle,width = 600, height = 600)
colors <- c('cyan','orange','black','blue','green','red','brown')
barPlot_counts(output,'Format','Frequency',12,colors,0.9)
dev.off()

#S. cerevisiae MEMOTE metrics evolution
df_MEM <- dataMEMOTE[(dataMEMOTE$Organism=='S. cerevisiae' & !is.na(dataMEMOTE$MEMOTE_score)),]
df_MEM <- df_MEM[which(grepl('yeast',df_MEM$Model_ID)),]
df_MEM <- data.frame(df_MEM$Model_ID,
                     as.double(df_MEM$annotation_met_score),
                     as.double(df_MEM$annotation_rxn_score),
                     as.double(df_MEM$annotation_SBO_score),
                     as.double(df_MEM$MEMOTE_score))
colnames(df_MEM) <- c('models','mets','rxns','SBO','MEMOTE')
new_dfMEM <- data.frame(stringsAsFactors = FALSE)
for (i in 2:ncol(df_MEM)){
  temp <- data.frame(df_MEM$models,df_MEM[,i],rep(colnames(df_MEM)[i],nrow(df_MEM)))
  new_dfMEM <- rbind(new_dfMEM,temp)
}
colnames(new_dfMEM) <- c('models','score','class')
new_dfMEM$models <- factor(new_dfMEM$models,levels = unique(new_dfMEM$models))
png('MEMOTEscores_sce_consensus.png',width = 1000, height = 600)
p <- ggplot(new_dfMEM, aes(x=class, y=score,fill=models)) + 
     geom_bar(position="dodge", stat='identity',aes(fill=models)) +
     scale_fill_viridis(discrete = T, option = "E")+ 
     theme_bw(base_size = 25) + xlab('') +  ylab('Scores')
plot(p)
dev.off() #colorsSce <- c('grey','cyan','pink','orange','purple','brown','blue','black','green','yellow','red','dark green','black')

#Citations scatter plot
column    <- which(colnames(dataset)=='citations_google')
plotTitle <- 'TotalCitations_scatter.png'
png(plotTitle,width = 600, height = 600)
xLabel <- 'Elapsed time since publication [years]'
yLabel <- 'Total citations (Google Scholar)'
scatterPlot(dataset,column,12,xLabel,yLabel,colorsOrg,1)
dev.off()

#Anual average citation scatter plot
column    <- which(colnames(dataset)=='Annual_average')
plotTitle <- 'AnualAvgCitations_scatter.png'
png(plotTitle,width = 600, height = 600)
xLabel <- 'Elapsed time since publication [years]'
yLabel <- 'Anual average citations'
scatterPlot(dataset,column,12,xLabel,yLabel,colorsOrg,1)
dev.off()
