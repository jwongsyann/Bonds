
downloadABO<-function(url) {
        # Loads the necessary packages
        library(XML)
        
        # Reads the data from the url
        dat<-readHTMLTable(url)
        dat<-as.data.frame(dat)
        
        # Unload packages
        detach(package:XML)
        
        # Return Data
        return(dat)
}


cleanABO <- function(dat) {
        
        # Loads the necessary packages
        library(zoo)
        
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
        try(dat$Date<-as.Date(as.yearmon(dat$Date)),silent=TRUE)
        try(dat$Year<-as.Date(as.yearmon(dat$Year)),silent=TRUE)
        
        namelist<-names(dat)
        
        if (namelist[1]!="Date") {
                names(dat)<-c("Date",namelist[2:length(namelist)])
        }
        
        # Unload packages
        detach(package:zoo)
        
}

reshapeABO <- function (dat) {
        
        # Loads the necessary packages
        library(reshape2)
        
        # Melts the Corporate and Government Data down in the Entity Column
        dat<-melt(dat,id.vars=c("Date","Market"),variable.name="Entity")
        
        # Initializes the Currency Column 
        dat$Currency<-rep("USD",nrow(dat))
        
        # Finds the data reported by LCY and updates the currency column
        dat$Currency[grep("LCY",dat$Entity)]<-"LCY"
        
        # Changes the Entity Class into Character from factor.
        dat$Entity<-as.character(dat$Entity)
        
        # Replaces the Entity with the cleaned up names.
        dat$Entity[grep("Gov",dat$Entity)]<-"Government"
        
        dat$Entity[grep("Banks",dat$Entity)]<-"BanksAndFinancialInstituitions"
        
        dat$Entity[grep("Corp",dat$Entity)]<-"OtherCorporates"
        
        dat$Entity[grep("Total",dat$Entity)]<-"Total"
        
        # Unloads packages
        detach(package:reshape2)
        
        return(dat)
        
}

