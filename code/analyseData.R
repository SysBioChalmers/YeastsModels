#!/usr/bin/env Rscript
# Functions for loading and minor formatting of all different datasets used in this study
# Ivan Domenzain
library(ggplot2)
library(dplyr)
library(ggrepel)
setwd('/Users/ivand/Documents/GitHub/YeastsModels/code')
source('plotResults.R')
dataset <- read.csv(file = '../results/results_table.txt', sep = '\t', header = TRUE, stringsAsFactors = FALSE)
for (i in 1:ncol(dataset)){
  dataset[,i] <- gsub('#VALUE!',NaN,dataset[,i])
  dataset[is.na(dataset[,i]),i] <- NaN
}
#File availability plot
setwd('../results/plots')
column <- which(colnames(dataset)=='Available_file')
plotTitle <- 'file_availability.png'
png(plotTitle,width = 600, height = 600)
p <- getPieChart(dataset,column,12,c('red','blue'),'',0.5)
dev.off()

#Models per organism
column  <- which(colnames(dataset)=='Organism')
output  <- getClassCounts(dataset,column)
plotTitle <- 'models_organisms.png'
png(plotTitle,width = 600, height = 600)
colorsOrg <- c('red','orange','grey','purple','pink','blue','cyan','black','green','brown')
barPlot_counts(output,'Organism','# of Models',12,colorsOrg,0.6,TRUE)
dev.off()

#Version control plot
column <- which(colnames(dataset)=='version_control')
plotTitle <- 'version_control.png'
png(plotTitle,width = 600, height = 600)
p <- getPieChart(dataset,column,12,c('red','blue'),'',0.5)
dev.off()

#Growth plot
column <- which(colnames(dataset)=='growth')
plotTitle <- 'growth.png'
png(plotTitle,width = 600, height = 600)
p <- getPieChart(dataset,column,12,c('red','blue','grey'),'',0.5)
dev.off()

#Import/Export plot
column <- which(colnames(dataset)=='Import.Export')
plotTitle <- 'import_export.png'
png(plotTitle,width = 600, height = 600)
p <- getPieChart(dataset,column,12,c('red','blue'),'',0.5)
dev.off()

#External DB plot
column <- which(colnames(dataset)=='external')
plotTitle <- 'externalDB.png'
png(plotTitle,width = 600, height = 600)
p <- getPieChart(dataset,column,10,c('grey','blue','black','green','red','purple','orange'),'',0.5,TRUE)
dev.off()

#Memote plot
column <- which(colnames(dataset)=='MEMOTE')
plotTitle <- 'MEMOTE.png'
png(plotTitle,width = 600, height = 600)
p <- getPieChart(dataset,column,12,c('black','red','blue'),'',0.5)
dev.off()

#Formats plot
column  <- which(colnames(dataset)=='Primary_Format')
output  <- getClassCounts(dataset,column)
plotTitle <- 'model_formats.png'
png(plotTitle,width = 600, height = 600)
colors <- c('red','grey','blue','green','orange','black')
barPlot_counts(output,'Format','Frequency',12,colors,0.6)
dev.off()

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
colors <- c('red','orange','grey','purple','pink','blue','cyan','black','green','brown')
scatterPlot(dataset,column,12,xLabel,yLabel,colors,1)
dev.off()
