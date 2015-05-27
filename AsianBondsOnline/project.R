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
lcybond<-data.frame(lcybond,Variable=rep("Size of LCY Bond Market",nrow(lcybond)))
lcybond<-lcybond[,c("Date","Market","Entity","Currency","Variable","value")]

# FCY_Bonds_Outstanding
fcybond<-downloadABO(fcybond)
fcybond<-cleanABO(fcybond)
fcybond<-reshapeABO(fcybond)
fcybond<-data.frame(fcybond,Variable=rep("Size of FCY Bond Market",nrow(fcybond)))
fcybond<-fcybond[,c("Date","Market","Entity","Currency","Variable","value")]

# Issuance_Volume_LCY
issuanceLCY<-downloadABO(issuanceLCY)
issuanceLCY<-cleanABO(issuanceLCY)
issuanceLCY<-reshapeABO(issuanceLCY)
issuanceLCY<-data.frame(issuanceLCY,Variable=rep("Issuance Volume of LCY Bond Market",nrow(issuanceLCY)))
issuanceLCY<-issuanceLCY[,c("Date","Market","Entity","Currency","Variable","value")]


# G3_Currency_Bond_Issuance
# Do not need to reshape as there are no factors in this dataset
issuanceG3<-downloadABO(issuanceG3)
issuanceG3<-cleanABO(issuanceG3)
issuanceG3<-reshapeABO(issuanceG3)
issuanceG3<-data.frame(issuanceG3,Variable=rep("Issuance Volume of G3 Currency Bond Market",nrow(issuanceG3)))
issuanceG3<-issuanceG3[,c("Date","Market","Entity","Currency","Variable","value")]

# Bond_turn_ratio
bondturnover<-downloadABO(bondturnover)
bondturnover<-cleanABO(bondturnover)
library(reshape2)
bondturnover<-melt(bondturnover,id.vars=c("Date","Market"),variable.name="Variable")
# Initializes the Currency Column 
bondturnover$Currency<-rep("USD",nrow(bondturnover))
# Finds the data reported by LCY and updates the currency column
bondturnover$Currency[grep("LCY",bondturnover$Entity)]<-"LCY"
# Changes the Entity Class into Character from factor.
bondturnover$Variable<-as.character(bondturnover$Variable)
bondturnover$Entity<-as.character(bondturnover$Variable)
# Replaces the Entity with the cleaned up names.
bondturnover$Entity[grep("Gov",bondturnover$Entity)]<-"Government"
bondturnover$Entity[grep("Banks",bondturnover$Entity)]<-"BanksAndFinancialInstituitions"
bondturnover$Entity[grep("Corp",bondturnover$Entity)]<-"NonFinancialCorporates"
bondturnover$Entity[grep("Total",bondturnover$Entity)]<-"Total"
bondturnover$Entity[grep("Foreign",bondturnover$Entity)]<-"ForeignHoldings"
# Replaces the Variable with the cleaned up names.
bondturnover$Variable[grep("Ratio",bondturnover$Variable)]<-"Bond Turnover Ratio"
bondturnover$Variable[grep("Ave",bondturnover$Variable)]<-"Average Bonds Outstanding"
bondturnover$Variable[grep("Turnover..in",bondturnover$Variable)]<-"Bond Turnover"
bondturnover<-bondturnover[,c("Date","Market","Entity","Currency","Variable","value")]

# Trading_Volume
tradingVolume<-downloadABO(tradingVolume)
tradingVolume<-cleanABO(tradingVolume)
tradingVolume<-reshapeABO(tradingVolume)
tradingVolume<-data.frame(tradingVolume,Variable=rep("Trading Volume",nrow(tradingVolume)))
tradingVolume<-tradingVolume[,c("Date","Market","Entity","Currency","Variable","value")]

# foreignHoldingsofGovtLCY
foreignHoldingsofGovtLCY<-downloadABO(foreignHoldingsofGovtLCY)
foreignHoldingsofGovtLCY<-cleanABO(foreignHoldingsofGovtLCY)
library(reshape2)
foreignHoldingsofGovtLCY<-melt(foreignHoldingsofGovtLCY,id.vars=c("Date","Market"),variable.name="Variable")
# Initializes the Currency Column 
foreignHoldingsofGovtLCY$Currency<-rep(NA,nrow(foreignHoldingsofGovtLCY))
# Finds the data reported by LCY and updates the currency column
foreignHoldingsofGovtLCY$Currency[grep("LCY",foreignHoldingsofGovtLCY$Variable)]<-"LCY"
# Changes the Entity Class into Character from factor.
foreignHoldingsofGovtLCY$Variable<-as.character(foreignHoldingsofGovtLCY$Variable)
foreignHoldingsofGovtLCY$Entity<-as.character(foreignHoldingsofGovtLCY$Variable)
# Replaces the Entity with the cleaned up names.
foreignHoldingsofGovtLCY$Entity<-"Total"
# Replaces the Variable with the cleaned up names.
foreignHoldingsofGovtLCY$Variable[grep("Foreign",foreignHoldingsofGovtLCY$Variable)]<-"Foreign Holdings of LCY Govt Bonds Outstanding"
foreignHoldingsofGovtLCY$Variable[grep("of.Total",foreignHoldingsofGovtLCY$Variable)]<-"Foreign Holdings of LCY Govt Bonds Outstanding, Percent"
foreignHoldingsofGovtLCY$Variable[grep("Total",foreignHoldingsofGovtLCY$Variable)]<-"Total LCY Govt Bonds Outstanding"
foreignHoldingsofGovtLCY<-foreignHoldingsofGovtLCY[,c("Date","Market","Entity","Currency","Variable","value")]

datABO<-rbind(lcybond,fcybond,issuanceLCY,issuanceG3,bondturnover,tradingVolume,foreignHoldingsofGovtLCY)
datABO<-dcast(datABO,Date+Market+Entity+Currency~Variable)

#url8<-"https://www.bis.org/statistics/credtopriv/credtopriv.xlsx"
#download.file(url8,destfile="credtopriv.xlsx",mode="wb")
#dat8<-read.xlsx("credtopriv.xlsx",sheetIndex=3,startRow=3)
# mdat<-Reduce(function(x,y){merge(x,y,all=TRUE)},list(lcybond,fcybond,issuanceLCY,issuanceG3,bondturnover,tradingVolume,foreignHoldingsofGovtLCY))
