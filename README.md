##About the package

The BibWrangleR package was designed with bibliometric research in mind.  The primary purpose of the package to take raw text files of bibliometric data obtained from database search aggregators such as ProQUest and transform these files into an analyzable data frame.    

BibWrangleR is in beta form and currently it is only compatible for use with the EbscoHost and ProQuest database aggregators.  Within EbscoHost, BibWrangler has only been tested with the following three databases:

+ PsycINFO
+ Social Science Abstracts
+ Social Work Abstracts

Given variations in attribute coding by database, it is not recommended that those with limited coding background use BibWrangleR with EbscoHost-hosted databases other than the three listed here.

##How to use BibWrangleR

The first step in using BibWrangler is to obtain the raw text files from a database aggregator following a query with your desired search specifications. These files need to be exported from either EbscoHost or ProQuest and then stored in a location where R can access and read them.  Here are brief instructions for exporting your search results.

###ProQuest

   1.  Following your search, select the articles whose data you would like to export.
   2.  Once all desired articles have been selected, click on the option titled "More".  This can    
       be located on the right hand side of the screen, above the article results, and next to the 
       "print" option.
   3.  Once the scroll down menu appears, select the "Text only" option. _Note:_ This is the only
       format that is compatible with BibWrangleR.
   4.  When the "Export/Save" window appears configure the settings as follows:
       +  Output to:  "Text only"
       +  Content: "Citation, abstract, indexing"
       +  Bibliography: unchecked
       +  Include:  all four options should be unchecked
   5. Then click "continue" and the text file will be downloaded automatically.
   6. Place the text file in a folder that only contains the text files you want to "wrangle" using
      BibWrangler function.  _Note:_ Only other ProQuest text file exports can be wrangled at the
      same time.  Exports from EbscoHost must be processed separately.  

###EbscoHost


##License

This package is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License, version 3, as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but without any warranty; without even the implied warranty of merchantability or fitness for a particular purpose. See the GNU General Public License for more details.

A copy of the GNU General Public License, version 3, is available at http://www.r-project.org/Licenses/GPL-3