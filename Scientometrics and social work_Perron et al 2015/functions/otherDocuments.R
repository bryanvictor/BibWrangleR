#Identify records that were incorrectly captured in the wrangle
#using regular expressions

otherDocuments.f <- function(){
titles <- filter(full.df, attributes == "article")

insert.1<-"[B|b]ook [R|r]eview[.:]|^[F|f]orum.+|[F|f]orum$|[C|c]ommentary|Comment.+"
insert.2<-"^[I|i]ndex\\s[T|t]o|[I|i]ntroduction:|[I|i]ntroduction [T|t]o|\\([B|b]ook\\)"
insert.3<-"[H|h]andbook|Volume|volumes|newsletters|[L|l]etter from"
insert.4<-"[P|p]reface|\\([0-9]{4}-[0-9]{4}\\):|: [A|a] [R|r]esponse [T|t]o [B-Z]"
insert.5<-"[S|s]pecial\\s[I|i]ssue|[T|t]able\\s[O|o]f\\s[C|c]ontent|\\([U|u]ndetermined"
insert.6<-"^Book.+ | ^COMMENTARY.+ | Call\\s.+ | Contents.+ | Editor.+ | Errat.+"
insert.7<-"^FROM\\THE.+ | ^From\\sthe\\ed.+ | Health\\s[&]\\sS.+ | ^LETTER.+ |
             ^Letter\\sfrom.+ | ^News\\and.+ | ^Response\\sto\\s[A-Z] | Vol\\.\\s[0-9] |
            ^Volume.+ | ^\\[|Retraction|Endpage"


insert<-paste(insert.1,insert.2,insert.3,insert.4,insert.5, insert.6,
              insert.7, sep="|")

badRecords<-subset(titles, grepl(insert, record))
badRecords.ID<-badRecords$articleID

full.df <<- full.df[!(full.df$articleID %in% badRecords.ID), ]

abstracts<-filter(full.df, attributes=="abstract")
insert<-"special\\sissue\\s|special\\sissue[[:punct:]]|this\\scommentary|endpage"
badRecords<-subset(abstracts, grepl(insert, record, ignore.case=TRUE))
badRecords<-subset(badRecords, !grepl("Part of a special issue", record, ignore.case=TRUE))
badRecords.ID<-badRecords$articleID

full.df <<- full.df[!(full.df$articleID %in% badRecords.ID), ]
}
