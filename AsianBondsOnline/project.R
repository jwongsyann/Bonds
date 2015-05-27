source("C:/Users/iComputer/Desktop/Bonds/AsianBondsOnline/downloadABO.R")

lcybond<-"http://asianbondsonline.adb.org/spreadsheets/RG-LCY_Bond_Market_USD.xls"
fcybond<-"http://asianbondsonline.adb.org/spreadsheets/RG-FCY_Bonds_Outstanding.xls"
issuanceLCY<-"http://asianbondsonline.adb.org/spreadsheets/RG-Issuance_Volume_USD.xls"
issuanceG3<-"http://asianbondsonline.adb.org/spreadsheets/RG-G3_Currency_Bond_Issuance.xls"
foreignHoldingsofGovtLCY<-"http://asianbondsonline.adb.org/spreadsheets/RG-Foreign_Holdings.xls"
bondturnover<-"http://asianbondsonline.adb.org/spreadsheets/RG-Bond_turn_ratio.xls"
tradingVolume<-"http://asianbondsonline.adb.org/spreadsheets/RG-Trading_Volume.xls"

# LCY_Bond_Market
lcybond<-downloadABO(lcybond)
lcybond<-cleanABO(lcybond)
lcybond<-reshapeABO(lcybond)
library(reshape2)
lcybond<-dcast(lcybond,Date+Market+Currency~Entity)
names(lcybond)<-c("Date","Market","Currency","BOND001F001","BOND001F002","BOND001F003")

# FCY_Bonds_Outstanding
fcybond<-downloadABO(fcybond)
fcybond<-cleanABO(fcybond)
fcybond<-reshapeABO(fcybond)
library(reshape2)
fcybond<-dcast(fcybond,Date+Market+Currency~Entity)
names(fcybond)<-c("Date","Market","Currency","BOND002F001","BOND002F002","BOND002F003","BOND002F004")

# Issuance_Volume_LCY
issuanceLCY<-downloadABO(issuanceLCY)
issuanceLCY<-cleanABO(issuanceLCY)
issuanceLCY<-reshapeABO(issuanceLCY)
library(reshape2)
issuanceLCY<-dcast(issuanceLCY,Date+Market+Currency~Entity)
names(issuanceLCY)<-c("Date","Market","Currency","BOND003F001","BOND003F002","BOND003F003")

# G3_Currency_Bond_Issuance
# Do not need to reshape as there are no factors in this dataset
issuanceG3<-downloadABO(issuanceG3)
issuanceG3<-cleanABO(issuanceG3)
issuanceG3<-reshapeABO(issuanceG3)
library(reshape2)
issuanceG3<-dcast(issuanceG3,Date+Market+Currency~Entity)
names(issuanceG3)<-c("Date","Market","Currency","BOND004F001")

# Bond_turn_ratio
bondturnover<-downloadABO(bondturnover)
bondturnover<-cleanABO(bondturnover)
library(reshape2)
temp<-melt(bondturnover,id.vars=c("Date","Market"),variable.name="column")
# Initializes the Currency Column 
temp$Currency<-rep("USD",nrow(bondturnover))
# Finds the data reported by LCY and updates the currency column
temp$Currency[grep("LCY",bondturnover$Entity)]<-"LCY"
bondturnover<-cbind(bondturnover,temp$Currency)
bondturnover<-bondturnover[,c(1,2,9,3,4,5,6,7,8)]
names(bondturnover)<-c("Date","Market","Currency","BOND006F001","BOND006F002","BOND006F003","BOND006F004","BOND006F005","BOND006F006")

# Trading_Volume
tradingVolume<-downloadABO(tradingVolume)
tradingVolume<-cleanABO(tradingVolume)
tradingVolume<-reshapeABO(tradingVolume)
library(reshape2)
tradingVolume<-dcast(tradingVolume,Date+Market+Currency~Entity)
names(tradingVolume)<-c("Date","Market","Currency","BOND007F001","BOND007F002","BOND007F003")

# foreignHoldingsofGovtLCY
foreignHoldingsofGovtLCY<-downloadABO(foreignHoldingsofGovtLCY)
foreignHoldingsofGovtLCY<-cleanABO(foreignHoldingsofGovtLCY)
library(reshape2)
temp<-melt(foreignHoldingsofGovtLCY,id.vars=c("Date","Market"),variable.name="column")
# Initializes the Currency Column 
temp$Currency<-rep("USD",nrow(foreignHoldingsofGovtLCY))
# Finds the data reported by LCY and updates the currency column
temp$Currency[grep("LCY",temp$column)]<-"LCY"
foreignHoldingsofGovtLCY<-cbind(foreignHoldingsofGovtLCY,temp$Currency)
foreignHoldingsofGovtLCY<-foreignHoldingsofGovtLCY[,c(1,2,6,3,4,5)]
names(foreignHoldingsofGovtLCY)<-c("Date","Market","Currency","BOND008F001","BOND008F002","BOND008F003")

#url8<-"https://www.bis.org/statistics/credtopriv/credtopriv.xlsx"
#download.file(url8,destfile="credtopriv.xlsx",mode="wb")
#dat8<-read.xlsx("credtopriv.xlsx",sheetIndex=3,startRow=3)
mdat<-Reduce(function(x,y){merge(x,y,all=TRUE)},list(lcybond,fcybond,issuanceLCY,issuanceG3,bondturnover,tradingVolume,foreignHoldingsofGovtLCY))
