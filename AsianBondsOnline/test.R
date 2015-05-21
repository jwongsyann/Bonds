library(XML)
library(xlsx)
library(reshape2)
library(RCurl)
library(curl)
library(downloader)
setwd("../Desktop/Data Automation")

ctycode<-read.csv("https://raw.github.com/datasets/country-list/master/data.csv")

# LCY_Bond_Market
url<-"http://asianbondsonline.adb.org/spreadsheets/RG-LCY_Bond_Market_USD.xls"
download.file(url,destfile="temp.xls")
dat<-readHTMLTable("temp.xls")
dat<-data.frame(dat)
file.remove("temp.xls")
names(dat)<-c("Date","Market","BOND001F001","BOND001F002","BOND001F003","BOND001F004","BOND001F005","BOND001F006")

# FCY_Bonds_Outstanding
url2<-"http://asianbondsonline.adb.org/spreadsheets/RG-FCY_Bonds_Outstanding.xls"
download.file(url2,destfile="temp.xls")
dat2<-readHTMLTable("temp.xls")
dat2<-data.frame(dat2)
file.remove("temp.xls")
names(dat2)<-c("Date","Market","BOND002F001","BOND002F002","BOND002F003","BOND002F004")

# Issuance_Volume
url3<-"http://asianbondsonline.adb.org/spreadsheets/RG-Issuance_Volume_USD.xls"
download.file(url3,destfile="temp.xls")
dat3<-readHTMLTable("temp.xls")
dat3<-data.frame(dat3)
file.remove("temp.xls")
names(dat3)<-c("Date","Market","BOND003F001","BOND003F002","BOND003F003")

# G3_Currency_Bond_Issuance
url4<-"http://asianbondsonline.adb.org/spreadsheets/RG-G3_Currency_Bond_Issuance.xls"
download.file(url4,destfile="temp.xls")
dat4<-readHTMLTable("temp.xls")
dat4<-data.frame(dat4)
file.remove("temp.xls")
names(dat4)<-c("Date","Market","BOND004F001")

# Bond_turn_ratio
url6<-"http://asianbondsonline.adb.org/spreadsheets/RG-Bond_turn_ratio.xls"
download.file(url6,destfile="temp.xls")
dat6<-readHTMLTable("temp.xls")
dat6<-data.frame(dat6)
file.remove("temp.xls")
names(dat6)<-c("Date","Market","BOND006F001","BOND006F002","BOND006F003","BOND006F004","BOND006F005","BOND006F006")

# Trading_Volume
url7<-"http://asianbondsonline.adb.org/spreadsheets/RG-Trading_Volume.xls"
download.file(url7,destfile="temp.xls")
dat7<-readHTMLTable("temp.xls")
dat7<-data.frame(dat7)
file.remove("temp.xls")
names(dat7)<-c("Date","Market","BOND007F001","BOND007F002","BOND007F003")

#url8<-"https://www.bis.org/statistics/credtopriv/credtopriv.xlsx"
#download.file(url8,destfile="credtopriv.xlsx",mode="wb")
#dat8<-read.xlsx("credtopriv.xlsx",sheetIndex=3,startRow=3)
mdat<-Reduce(function(x,y){merge(x,y,by=c("Date","Market"),all=TRUE)},list(dat,dat2,dat3,dat4,dat6,dat7))
