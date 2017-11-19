cleaningJournals.f <- function(){

    full.df$record <- ifelse(full.df$record ==
                                 "The British Journal of Social Work",          # Spelling difference
                             "British Journal of Social Work",
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
                                 "Revista de Asistenta Sociala (Social Work Review)",
                             "Social Work Review",
                             full.df$record)

    full.df$record <- gsub("Arete", "xxx", full.df$record)
    full.df$record <- gsub("Aret.{1,3}", "Arete", full.df$record)
    full.df$record <- gsub("xxx", "Arete", full.df$record)
    #Replaces special character
    #in Arete and preserves other formatting

    full.df$record <- ifelse(full.df$record ==
                                 "Journal of Gay and Lesbian Social Services",     #Spelling difference
                             "Journal of Gay & Lesbian Social Services",
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
                                 "Canadian Social Work Review/Revue canadienne de service social",
                             "Canadian Social Work Review",
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
                                 "INDIAN JOURNAL OF SOCIAL WORK",                    #Spelling difference
                             "Indian Journal of Social Work",
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
                                 "The Indian Journal of Social Work",              #Spelling difference
                             "Indian Journal of Social Work",
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
                                 "Asia Pacific Journal of Social Work",              #Spelling difference
                             "Asia Pacific Journal of Social Work and Development",
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
                                 "Social Work & Society",                           #Spelling difference
                             "Social Work and Society",
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
                                 "Journal of Social Work in Disability & Rehabilitation",
                             "Journal of Social Work in Disability and Rehabilitation",
                             full.df$record)           #Spelling difference

    full.df$record <- ifelse(full.df$record ==
                                 "Hong Kong Journal of Social Work",
                             "The Hong Kong Journal of Social Work",
                             full.df$record)           #Spelling difference

    full.df$record <- ifelse(full.df$record ==
                                 "The Journal of Baccalaureate Social Work",
                             "Journal of Baccalaureate Social Work",
                             full.df$record)           #Spelling difference

    full.df$record <- ifelse(full.df$record ==
                                 "Journal of Practice Teaching in Health and Social Work",
                             "Journal of Practice Teaching in Social Work and Health",
                             full.df$record)           #Spelling difference

    full.df$record <- ifelse(full.df$record ==
                                 "Professional Development: The International Journal of Continuing Social Work Education",
                             "Professional Development",
                             full.df$record)           #Spelling difference

    full.df$record <- ifelse(full.df$record ==
                                 "Social Work with Groups",
                             "Social Work With Groups",
                             full.df$record)
    full.df$record <- ifelse(full.df$record ==
                                 "Maatskaplike Werk/Social Work" | full.df$record == "Social Work/Maatskaplike Werk",
                             "Maatskaplike Werk",
                             full.df$record)



    full.df$record <- ifelse(full.df$record ==
                                 "Social Work & Social Sciences Review",     # Spelling difference
                             "Social Work and Social Sciences Review",
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
                                 "Social Work with Groups",                  # Spelling difference
                             "Social Work With Groups",
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
                                 "Journal of Sociology & Social Welfare",    # Spelling difference
                             "Journal of Sociology and Social Welfare",
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
                                 "The British Journal Social Work",          # Spelling difference
                             "British Journal of Social Work",
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
                               "Social Work Research & Abstracts",          # Spelling difference
                             "Social Work Research",
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
                               "Journal of Multicultural Social Work",          # Spelling difference
                             "Journal of Ethnic & Cultural Diversity in Social Work",
                             full.df$record)



    #shortens Professional Development
    full.df$record <- ifelse(full.df$attributes == "journal",
                             gsub(":.+", "", full.df$record),
                             full.df$record)

    #shortens Canadian Social Work review by eliminating foreign title and is
    #automatically combined with other short spelling
    full.df$record <- ifelse(full.df$attributes == "journal",
                             gsub("(/R){1}.+", "", full.df$record),
                             full.df$record)

    # shortens Contemporary Rural Social Work
    full.df$record <- ifelse(full.df$attributes == "journal",
                             gsub("\\s\\(.+", "", full.df$record),
                             full.df$record)

    full.df$record <- ifelse(full.df$attributes == "journal",
                             gsub("and", "&", full.df$record), full.df$record)

    articles.appendData <- length(which(full.df$attributes == "article"))
    journals.appendData <- filter(full.df, attributes == "journal") %>%
        summarise(Unique = n_distinct(record))

    full.df$record <- ifelse(full.df$record ==
                                 "The British Journal of Pyschiatric Social Work" |
                                 full.df$record ==
                                 "The British Journal of Social Work", # Old
                             "British Journal of Social Work",           # New title
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
                                 "Computers in Human Services",              # Old title
                             "Journal of Technology in Human Services",  # New title
                             full.df$record)


    full.df$record <- ifelse(full.df$record ==
                                 "The Family" | full.df$record ==                    # Old title
                                 "Journal of Social Casework" | full.df$record ==    # Old title
                                 "Social Casework",                                  # Old title
                             "Families in Society",                              # New title
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
                                 "Social Work in Education",                 # Old title
                             "Children & Schools",                       # New title
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
                                 "Journal of Independent Social Work" | full.df$record ==    # New title
                                 "Journal of Analytic Social Work",                          # Old title
                             "Psychoanalytic Social Work",                               # Old title
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
                                 "Social work in public health",
                             "Social Work in Public Health",
                             full.df$record)
    full.df$record <- ifelse(full.df$record ==
                                 "Social Thought",
                             "Journal of Religion & Spirituality in Social Work",
                             full.df$record)

    full.df$record <- ifelse(full.df$record ==
              "Journal of Practice Teaching in Social Work and Practice" |
                full.df$record == "Journal of Practice Teaching in Social Work & Practice" |
                full.df$record == "Journal of Practice Teaching in Social Work and Health", #Old title
               "Journal of Practice Teaching in Social Work & Health",   #New title
                full.df$record)

    full.df$record <- ifelse(full.df$record==
                               "Human Services in the Rural Environment",
                               "Contemporary Rural Social Work",
                                full.df$record)

    full.df$record <- ifelse(full.df$record ==
                               "The Social Worker/Le Travailleur social",          # Title Change
                             "The Social Worker",
                             full.df$record)


    # Journals were originally merged after suffixes were eliminated (after the
    # colon).  Thus, Practice: Social Work in Action  (new title) was shortened to
    # Practice (old title).  This section resolves two of these issues to be
    # consistent in the comparison with Hodge.

    practice.temp <- grep("^Practice$", full.df$record)
    full.df$record[practice.temp] <- "Practice: Social Work in Action"

    practice.temp <- grep("^Reflections$", full.df$record)
    full.df$record[practice.temp] <- "Reflections: Narratives of Professional Helping"

    exclusions.1 <- c(
        "American Journal of Preventive Medicine",
        "Behavior Modification",
        "Brain and Cognition",
        "Brain & Cognition",
        "Canadian Journal of Community Mental Health",
        "Canadian Journal on Aging",
        "Critical Social Work", # Problematic record in database - not formally indexed
        "Early Child Development and Care",
        "Early Child Development & Care",
        "Early Education and Development",
        "Early Education & Development",
        "Employee Assistance Quarterly",
        "Evaluation and Program Planning",
        "Evaluation & Program Planning",
        "General Hospital Psychiatry",
        "International Review of Social Research",
        "Issues in Social Work Education", #Problematic record in database - not formally indexed
        "Iowa Journal of School Social Work", #Problematic record in database - not formally indexed
        "Journal of Applied Behavioral Science",
        "Journal of Applied Rehabilitation Counseling",
        "Journal of Community & Applied Social Psychology",
        "Journal of Health & Human Services Administration",
        "Journal of Nonverbal Behavior",
        "Journal of Psychosomatic Research",
        "Learning Disabilities Research & Practice",
        "Prevention in Human Services",
        "Professional Development in Education",
        "PROFILE Issues in Teachers' Professional Development",
        "Psychotherapy",
        "Social Development",
        "Systems Research and Behavioral Science",
        "Systems Research & Behavioral Science",
        "Teaching & Teacher Education",
        "Teaching and Teacher Education",
        "The Scientific Review of Mental Health Practice",
        "The Clinical Supervisor",
        "Arete: Revista de Filosofia",
        "Arete Revista de Filosofia",
        "Profile")


    ebsco.remove <- full.df[full.df$record %in% exclusions.1, ]
    ebsco.remove <- ebsco.remove[, "articleID"]

    full.df <- full.df[!(full.df$articleID %in% ebsco.remove),]
    full.df <<- full.df

    #article.count.journalsCleaned <<- filter(full.df, attributes == "article")
    journal.count <- filter(full.df, attributes == "journal")
    #journal.count.journalsCleaned <<- length(unique(journal.count$record))

}
