#!/usr/bin/python
# runMemoteTests
#
# Last edited: Ivan Domenzain 2019-07-12

import os
import glob
import pandas as pd

path         = os.getcwd()
results_path = "../results/MEMOTE_tests"
#Create directory for output reports
try:
	os.mkdir(results_path)
except:
	print ("Output directory already exists")
#Get model files relative paths
modelFiles = [f for f in glob.glob('../models/*.xml')]
##Run a snapshot memote test for each model with an .xml file
for file in modelFiles:
	modelName  =file[10:]
	outputFile = results_path + '/' + modelName[:len(modelName)-4] + '_test.html'
	cmdString  = 'memote report snapshot --filename \"'+outputFile+'\" '+file+ '> /dev/null'
	print ('Running test for model: ' +modelName[:-4])
	os.system(cmdString)


##Run memote Diff test for multiple models of a given organism
orgs_multi = ['S. cerevisiae']#'Y. lipolytica','P. pastoris']
shortNames = ['sce']#,'yli,' 'ppa']

#read file with relations between org name and model IDs
tableFile  = '../models/orgs_model_IDs_table.txt'
IDs_df     = pd.read_csv(tableFile,sep='\t',header=(0))
for i in range(0,len(orgs_multi)):
	org  	   = orgs_multi[i]
	short 	   = shortNames[i]
	print(orgs_multi[i])
	#Get all model IDs for the queried organism with an sbml file
	IDs = IDs_df.model_id[(IDs_df["org"] == org) & (IDs_df["format"] == 'SBML')]
	IDs        = '../models/'+IDs+ '.xml'
	#merge all model paths into a single string
	IDs        = ' '.join(IDs)
	outputFile = results_path + '/' + short + '_modelsComparison.html'
	cmdString  = 'memote report diff --filename '+outputFile+' '+IDs
	print ('Running comparative models test for: '+org)
	os.system(cmdString)