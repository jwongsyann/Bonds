

downloadABO <- function(url) {
        
        # Reads the data from the url
        dat<-readHTMLTable(url)
        dat<-as.data.frame(dat)
        
        # Removes the prefix from the column names.
        names(dat)<-gsub("NULL.","",names(dat))
        
        # Changes the columns into the desired classes. The Date and Market
        # columns are left as character classes. The rest are numeric.
        for (i in 3:ncol(dat)) {
                dat[,i]<-as.character(dat[,i])
                dat[,i]<-as.numeric(dat[,i])
        }
        
        # Converts the Date column to date format. Needs to be read using
        # as.yearmon because only the month and year is provided.
        dat$Date<-as.Date(as.yearmon(dat$Date))
        
        # Melts the Corporate and Government Data down in the Entity Column
        dat<-melt(dat,id.vars=c("Date","Market"),variable.name="Entity")
        
        # Initializes the Currency Column 
        dat$Currency<-rep("USD",nrow(dat))
        
        # Finds the data reported by LCY and updates the currency column
        dat$Currency[grep("LCY",dat$Entity)]<-"LCY"
        
        # Changes the Entity Class into Character from factor.
        dat$Entity<-as.character(dat$Entity)
        
        # Replaces the Entity with the cleaned up names.
        dat$Entity[grep("Government",dat$Entity)]<-"Government"
        
        dat$Entity[grep("Corporate",dat$Entity)]<-"Corporate"
        
        dat$Entity[grep("Total",dat$Entity)]<-"Total"
        
}