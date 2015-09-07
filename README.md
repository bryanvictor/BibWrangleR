##About the package

The BibWrangleR package was designed for conducting bibliometric research on scholarly articles.  The primary purpose of the package is to take raw text files of bibliometric data obtained from database search aggregators such as ProQuest and transform these files into an analyzable data frame.      

BibWrangleR is in beta form and is currently only compatible for use with the EBSCOhost and ProQuest database aggregators.  Within EBSCOhost, BibWrangleR has only been tested with the following three databases:

+ PsycINFO
+ Social Science Abstracts
+ Social Work Abstracts

Given variations in attribute coding by database, it is not recommended that BibWrangleR be used with EBSCOhost for results obtained from databases other than the three listed here.

##How to use BibWrangleR

The first step in using BibWrangleR is to obtain the raw text files from a database aggregator following a search with your desired specifications.  Since BibWrangleR has only been tested on search queries limited to journal articles, searches should be limited to scholarly journals.  These files then need to be exported from either EBSCOhost or ProQuest and stored in a location where R can access and read them.  Here are brief instructions for exporting your search results.

###ProQuest

   1.  Following your search, select the articles whose data you would like to export.
   2.  Once all desired articles have been selected, click on the option titled "More".  This can    
       be located on the right hand side of the screen, above the article results, and next to the 
       "print" option.
   3.  Once the scroll down menu appears, select the "Text only" option. _Note:_ This is the only
       format that is compatible with BibWrangleR.
   4.  When the "Export/Save" window appears configure the settings as follows:
       +  Output to:  **"Text only"**
       +  Content: "Citation, abstract, indexing"
       +  Bibliography: unchecked
       +  Include:  all four options should be unchecked
   5. Then click "continue" and the text file will be downloaded automatically.
   6. Place the text file in a folder that contains only the text files you want to "wrangle" 
      using the BibWrangler function.  _Note:_ Only other ProQuest text file exports can be 
      wrangled at the same time.  Exports from EbscoHost must be processed separately.  

###EbscoHost

   1. Following your search, click the "Share" button.  This can be located on the right hand side 
      of the screen, above the first article result and next to the "Page Options" button.
   2. Scroll down and select "E-mail a link to download exported results".
   3. Once the "Export Manager" screen loads, switch the selected format under "E-mail a link to a 
      file with citations in:" to **"Generic bibliographic management format"**.  This is the only 
      format that is compatible with BibWrangleR.
   4. Then enter your e-mail address in the field labeled "E-mail to:", and enter a subject line  
      if you choose, although this is optional.
   5. Within 15 minutes an e-mail from EBSCOhost should appear in your inbox.  Open the e-mail, 
      click on the embedded link and a zip folder containing the text file will be downloaded 
      automatically.
   6. Place the text file in a folder that contains only the text files you want to "wrangle" using
      the BibWrangler function.  _Note:_ Only other EBSCOhost text file exports can be wrangled at 
      the same time.  Exports from ProQuest must be processed separately.

###Loading BibWrangleR in R

Once you've exported the text file(s) from a database aggregator, you need to install BibWrangleR in R, and then load the package.  This requires that you first install the "devtools" package.  If you need to install the devtools package, enter the following into the R console:

    install.packages("devtools")


Then run the following code to install and load the BibWrangleR package:

    devtools::install_github("bryanvictor/BibWrangleR")
    library(BibWrangleR)

Once the package has been loaded you can use the wrangle functions to transform your stored text files into an analyzable data frame.

For EBSCOhost:  

    ebscoBWR.f(path)

    #Example: ebscoBWR.f(path="C:/Users/JaneDoe/Desktop/EBSCOhost_Files")
    
For ProQuest:

    proQuestBWR.f(path)
   
    #Example: proQuestBWR.f(path="C:/Users/JohnDoe/Desktop/ProQuest_Files")

###Additional function features

Both ebscoBWR.f and proQuest.f have additional options that can be specified when calling the function.

   + csv: This will write and save a .csv file to your working directory once the "wrangle" is 
          complete.  To turn this feature on include csv=TRUE in the function call.

   + rmDuplicates:  This feature eliminates duplicate article records from the final data frame 
                    and is turned on as a default.  If you want to turn this off include 
                    rmDuplicates=FALSE in the function call.

ebscoBWR.f contains a unique option given the way article record attributes are coded by the aggregator.  

   + firstAbstractOnly: This feature retains just one abstract field per article record.  This 
                        was designed because copyright information was often contained in 
                        subsequent abstract fields within a record.  If you would like to disable 
                        this feature and retain all available abstract fields include 
                        firstAbstractOnly = FALSE in the function call.


##Caution

The duplicate eliminator will retain the first article and delete subsequent matches.  Therefore if you want to privilege one dataset over another, be sure to number your text files so that articles from your preferred database are read into R first. Say for example you prefer PsycINFO over Social Work Abstracts.  Search and export results from each database seperately and then name your text files along the following lines:

   1_PsycINFO.txt
   
   2_SWA.txt

This will ensure that articles from PsycINFO are read in first and then retained.  This can be beneficial if you're interested in a certain article attribute such as location which is contained in PsycINFO article records but not those from Social Work Abstracts.
   
##Citing BibWrangleR

Suggested citation:

Victor, B.G. & Perron, B.E. (2015).  BibWrangleR: Software tool for converting bibliographic text files to an analyzable data frame.  GitHub Repository:  http://github.com/bryanvictor/bibwrangler .  DOI: 
   
##License

This package is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License, version 3, as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but without any warranty; without even the implied warranty of merchantability or fitness for a particular purpose. See the GNU General Public License for more details.

A copy of the GNU General Public License, version 3, is available at http://www.r-project.org/Licenses/GPL-3