# Set working directory to the location of this file

# Clear workspace
rm(list=ls())

library(BibWrangleR)
#library(dplyr)

# Wrangle the data files
proQuestBWR.df <- proQuestBWR.f(csv=FALSE, path='./Data/proQuest')
ebscoBWR.df <- ebscoBWR.f(csv=FALSE, path='./Data/ebscoFULL')


# Load additional functions for cleaning
sapply(list.files(pattern="[.]R$", path="./functions", full.names=TRUE), source)

# Apply cleaning functions
library(dplyr)
combineData.f()
cleaningJournals.f()
shortArticles.f()
titleMatching.f()
otherDocuments.f()
requireAuthorJournalTitleYear.f()

# Save historical database as R file
save(full.df, file = "./Data/HistoricalDatabase.RData")

#save(ebscoBWR.df, file = "EbscoDatabase.RData")
#save(proQuest.df, file = "ProQuest.RData")
