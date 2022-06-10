#####################################################################################
#####################################################################################
#####################################################################################
### This script requieres
### 1. OUTPUT ibd from Weigthed_IBD_estimator_ver2.pl
### 2. Admixture proportions for each region (or country)
### 3. File of coordinates (long and lat)


##inputs
path<-"/home/victor/UMB/GLAD_Project/LocalAncestry_IBD/Results_rfmix_2022_March/"
prefix<-"20220428_ibd_HAPIBD_allchrs."
size<-"Greater21cM"

WeightedIBD<-paste0(path,prefix,size,".WeigthedIBDlength.txt")

AdmixbyGroups<-"/home/victor/UMB/GLAD_Project/Population_Structure/20220428_TargetAndParental_admixture_proportions_clusters.AverageBygroups.txt"
List_countries<-"/home/victor/UMB/GLAD_Project/LocalAncestry_IBD/20220428_Pop_List_ordered_4"
WIBD<- read.table(WeightedIBD, head=TRUE)
Admixture<-read.table(AdmixbyGroups, head=TRUE)
countries<-read.table(List_countries, head=TRUE)

col.names.wibd<-c("Pop1","Pop2","IBD_Sharing","AFR_IBD_Sharing","EUR_IBD_Sharing","NAT_IBD_Sharing","EAS_IBD_Sharing",
                  "AVG_AFR","AVG_EUR","AVG_NAT","AVG_EAS","alpha","shape")
weighted.sharing <- read.table(text = "",col.names = col.names.wibd)

MaximumCallableIBD<-2807
MinimunCount<-0

#####################################################################################
### ESTIMATION OF Ancestry Specific IBD

for (i in 1:nrow(WIBD)){
  country1values<-Admixture[which(Admixture$GROUP==as.character(WIBD[i,1])),c(1:6)]
  country2values<-Admixture[which(Admixture$GROUP==as.character(WIBD[i,2])),c(1:6)]
  country1values$TOTALINDs<-as.numeric(country1values$TOTALINDs)
  weighted.sharing[i,1]=as.character(WIBD$Country1[i])
  weighted.sharing[i,2]=as.character(WIBD$Country2[i])
  
  if(as.character(WIBD[i,1]) == as.character(WIBD[i,2])){
    
    Nsame<-country1values$TOTALINDs*(country2values$TOTALINDs-1)/2
   
     ### For Total IBD Sharing
    weighted.sharing[i,"IBD_Sharing"]=WIBD[i,"TOTALIBD"]/Nsame
    
    ancestries<-c("AFR","EUR","NAT","EAS")
    
    for (anc in ancestries){
      counting<-paste0(anc,"Count")
      column1<-paste0("IBD_",anc)
      column2<-paste0(anc,"_IBD_Sharing")
      column3<-paste0("AVG_",anc)
      if(WIBD[i,counting] >= MinimunCount){  
        AncK1xAncK2<-country1values[anc]*country2values[anc]
        weighted.sharing[i,column2]=WIBD[i,column1]/(Nsame*AncK1xAncK2*MaximumCallableIBD)
        weighted.sharing[i,column3]<-country1values[anc]
      }else{
        weighted.sharing[i,column2]=0
        weighted.sharing[i,column3]<-0
      }
    }
    
    weighted.sharing[i,"alpha"]<-0.4
    weighted.sharing[i,"shape"]<-17
    
  }else{
    
    N1xN2<-country1values$TOTALINDs*country2values$TOTALINDs
    ### For Total IBD Sharing
    weighted.sharing[i,"IBD_Sharing"]=WIBD[i,"TOTALIBD"]/N1xN2
    
    ancestries<-c("AFR","EUR","NAT","EAS")
    
    for (anc in ancestries){
      counting<-paste0(anc,"Count")
      column1<-paste0("IBD_",anc)
      column2<-paste0(anc,"_IBD_Sharing")
      column3<-paste0("AVG_",anc)
      if(WIBD[i,counting] >= MinimunCount){  
        AncK1xAncK2<-country1values[anc]*country2values[anc]
        weighted.sharing[i,column2]=WIBD[i,column1]/(Nsame*AncK1xAncK2*MaximumCallableIBD)
        weighted.sharing[i,column3]<-country1values[anc]
      }else{
        weighted.sharing[i,column2]=0
        weighted.sharing[i,column3]<-0
      }
    }
    weighted.sharing[i,11]<-0.9
    weighted.sharing[i,12]<-16
  }

}

#####################################################################################



removingparentals<-c("Peru_Chopccas","Italy_Toscana","UK","UK_GBR","Italy","Spain_IBS","Finlandia_FIN","Peru_Ashaninkas","Peru_Chachapoyas",
                     "Peru_Qeros","Peru_Tallanes","Gambia_GWD","Sierra_Leona_MSL","Nigeria_ESN","Kenya_Webuye","Nigeria_YRI",
                     "Peru_Aimaras","Peru_Quechuas","Peru_Awajun","Peru_Lamas","Peru_Shipibo","Peru_Matsiguenka","Peru_Uros","Peru_Candoshi")
removingcountries<-c("Italy","India_Gujarati", "Argentina","USA_Missing","USA","Brazil","USA_or_PuertoRico","Peru_Ucayali","Peru_Junin","USA_Nevada",                   "HAPMAP_USA_California","USA_New_Mexico","USA_Delaware","Peru_Ucayali_Nahua","Peru_Jacarus","Peru_Moche","Peru",removingparentals)

weighted.sharing<-weighted.sharing[!(weighted.sharing$Pop1 %in% removingcountries),]
weighted.sharing<-weighted.sharing[!(weighted.sharing$Pop2 %in% removingcountries),]


#####################################################################################
### PLOTTING OF Ancestry Specific IBD

library(dplyr)

toplot<-weighted.sharing

write.table(toplot,"20220428_ASIBD_Score.txt",sep="\t", na="NA",row.names = FALSE, quote = F,col.names = TRUE)

library(tidyr)
library(reshape2)
require(gtools)
library(tidyverse)


toplot <- toplot %>% mutate(Pop1 = gsub("_NA", "", Pop1))
toplot <- toplot %>% mutate(Pop2 = gsub("_NA", "", Pop2))


library("maps")
library('geosphere')

for (Ancestry in c("NAT","AFR","EUR")){
  
  outfolder<-"MAPS_05/"
  col.0 <- adjustcolor("lightyellow", alpha=1)
  col.1 <- adjustcolor("lightyellow2", alpha=1)
  col.2 <- adjustcolor("yellow", alpha=1)
  col.3 <- adjustcolor("orange", alpha=1)
  col.4 <- adjustcolor("orange4", alpha=1)
  col.5 <- adjustcolor("red", alpha=1)
  col.6 <- adjustcolor("red4", alpha=1)
  col.7 <- adjustcolor("purple", alpha=1)
  edge.pal <- colorRampPalette(c(col.0,col.1, col.2,col.3,col.4,col.5,col.6,col.7), alpha = TRUE)
  edge.col <- edge.pal(160)          ## all values
  #edge.col <- edge.pal(176)           ## No Hawai Moquegua Ica
  #edge.col <- edge.pal(10)           ## INTERNAL
  
  coorfile<-"countries_coordenadas_2022_May.txt"
  countries_coor<-read.table(coorfile, head=TRUE)
  
  pdf(paste0(outfolder,"/Map_HAPIBD_May_",size,"_",Ancestry,".pdf"))
  anc_column<-paste0(Ancestry,"_IBD_Sharing")
  
  maps::map(database = "world",ylim=c(-60,60), xlim=c(-160,-30), col="lightskyblue4",
            fill=TRUE, lwd=0.01,bg="lightskyblue1",border="lightskyblue3",mar=rep(0,4))
  points(x=countries_coor$LON, y=countries_coor$LAT, pch=19,  cex=0.5, col="black",lwd=1)
  toplot<-toplot[order(toplot[anc_column]),]
  for(i in 1:nrow(toplot))  {
    if(toplot[i,1] == toplot[i,2]){
      node1 <- countries_coor[countries_coor$Country == as.character(toplot[i,]$Pop1),]
      node2 <- countries_coor[countries_coor$Country == as.character(toplot[i,]$Pop2),]
      
      arc <- gcIntermediate(as.numeric(c(node1[1,]$LON, node1[1,]$LAT)), 
                            as.numeric(c(node2[1,]$LON, node2[1,]$LAT)), 
                            n=30, addStartEnd=TRUE )
      #edge.ind <- round(1000*toplot[i,anc_column])
      edge.ind <- round(10000*toplot[i,anc_column])
      lines(arc, col=edge.col[edge.ind], lwd=20)
      
    }else{
      node1 <- countries_coor[countries_coor$Country == as.character(toplot[i,]$Pop1),]
      node2 <- countries_coor[countries_coor$Country == as.character(toplot[i,]$Pop2),]
      arc <- gcIntermediate(as.numeric(c(node1[1,]$LON, node1[1,]$LAT)), as.numeric(c(node2[1,]$LON, node2[1,]$LAT)), 
                            n=30, addStartEnd=TRUE )
      #edge.ind <- round(10000*toplot[i,anc_column])
      edge.ind <- round(10000*toplot[i,anc_column])
      #edge.ind <- round(1000*toplot[i,anc_column])
      lines(arc, col=edge.col[edge.ind],lwd=edge.ind/50)
      #lines(arc, col=edge.col[edge.ind],lwd=edge.ind/100)
    }
    
  }

  dev.off()

}


#######################################################################################
#######################################################################################
#######################################################################################

############# PLOTTING IBD

library("maps")
library('geosphere')

outfolder<-"/home/victor/UMB/GLAD_Project/LocalAncestry_IBD/Results_rfmix_2022_March/MAPS_05/"
col.0 <- adjustcolor("lightyellow", alpha=1)
col.1 <- adjustcolor("lightyellow2", alpha=1)
col.2 <- adjustcolor("yellow", alpha=1)
col.3 <- adjustcolor("orange", alpha=1)
col.4 <- adjustcolor("orange4", alpha=1)
col.5 <- adjustcolor("red", alpha=1)
col.6 <- adjustcolor("red4", alpha=1)
col.7 <- adjustcolor("purple", alpha=1)
edge.pal <- colorRampPalette(c(col.0,col.1, col.2,col.3,col.4,col.5,col.6,col.7), alpha = TRUE)
#edge.col <- edge.pal(170)
#edge.col <- edge.pal(280) ## No intra greater than 21
#edge.col <- edge.pal(78) ## All but Ica
edge.col <- edge.pal(68) ## All but internal

coorfile<-"countries_coordenadas_2022_May.txt"
countries_coor<-read.table(coorfile, head=TRUE)
pdf(paste0(outfolder,"/Map_Shared_HAPIBD_IBD_JUN_nonInternal_",size,".pdf"))


anc_column<-"IBD_Sharing"

maps::map(database = "world",ylim=c(-60,60), xlim=c(-160,-30), col="lightskyblue4",
          fill=TRUE, lwd=0.01,bg="lightskyblue1",border="lightskyblue3",mar=rep(0,4))
points(x=countries_coor$LON, y=countries_coor$LAT, pch=19,  cex=0.5, col="black",lwd=1)
toplot<-toplot[order(toplot[anc_column]),]
for(i in 1:nrow(toplot))  {
  if(toplot[i,1] == toplot[i,2]){
    node1 <- countries_coor[countries_coor$Country == as.character(toplot[i,]$Pop1),]
    node2 <- countries_coor[countries_coor$Country == as.character(toplot[i,]$Pop2),]
    
    arc <- gcIntermediate(as.numeric(c(node1[1,]$LON, node1[1,]$LAT)), 
                          as.numeric(c(node2[1,]$LON, node2[1,]$LAT)), 
                          n=40, addStartEnd=TRUE )
    edge.ind <- round(1000*toplot[i,anc_column])
    lines(arc, col=edge.col[edge.ind], lwd=15)
    
  }else{
    node1 <- countries_coor[countries_coor$Country == as.character(toplot[i,]$Pop1),]
    node2 <- countries_coor[countries_coor$Country == as.character(toplot[i,]$Pop2),]
    arc <- gcIntermediate(as.numeric(c(node1[1,]$LON, node1[1,]$LAT)), as.numeric(c(node2[1,]$LON, node2[1,]$LAT)), 
                          n=40, addStartEnd=TRUE )
    edge.ind <- round(1000*toplot[i,anc_column])    
    lines(arc, col=edge.col[edge.ind],lwd=edge.ind/20)
  }
  
}

dev.off()

pdf(paste0(outfolder,"/Legend.pdf"))
z=matrix(1:78,nrow=1)
x=1
y=seq(min(toplot$IBD_Sharing)*100,max(toplot$IBD_Sharing)*100,len=78) # supposing 3 and 2345 are the range of your data
image(x,y,z,col=edge.pal(78),axes=FALSE,xlab="",ylab="")
axis(2)

dev.off()

