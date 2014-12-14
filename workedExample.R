rm(list=ls())
library(stringi)
library(stringr)
library(dplyr)

#Load the function
source("/Users/beperron/Git/DataWranglers/ebscoParser.R")

#Read original data that is saved as *.txt file
ebsco.file <- readLines("/Users/beperron/Git/DataWranglers/RSWP-ebsco/ebsco.txt")

#Parse the ebsco data
ebscoParser.f(ebsco.file)

#Parse the wos data
source("/Users/beperron/Git/DataWranglers/wosParser.R")
wosParser.f()

#Find matches using partial matching function
source("/Users/beperron/Git/DataWranglers/pmatch.R")

#Create a matched and merged data file
a.matching <- pmatch.f(ebsco.titles, wos.titles)
b.matching <- pmatch.f(wos.titles, ebsco.titles)
ebsco.match <- ebsco.titles[b.matching[[3]]]
wos.match <- wos.titles[a.matching[[3]]]

ebsco.match <- ebsco.match[order(ebsco.match)]
wos.match <- wos.match[order(wos.match)]




