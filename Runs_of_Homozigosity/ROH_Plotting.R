
###################################
####### Extracting ROH info #######
###################################

path<-"/home/victor/UMB/GLAD_Project/ROH/Outputs_GLAD_March2022/"
col.names = c("ID","Pop", "ROH_sizeA", "ROH_sizeB", "ROH_sizeC", "ROH_sizeTotal")
ROH.final <- read.table(text = "",col.names = col.names)
order.file<-paste0(path,"list_pops_ROH_2022.txt")
order<- read.table(order.file, head=FALSE)

for (i in order$V1) {
  
  pop.results <- read.table(file=paste0(path,"SIZEROH_",i,".txt"),header=TRUE)

  ROH.final<-rbind(ROH.final,pop.results)
  
}

ROH.final[,"Pop"]<-gsub("Nigeria_","",ROH.final[,"Pop"])              ## YRI and ESN
ROH.final[,"Pop"]<-gsub("Gambia_","",ROH.final[,"Pop"])
ROH.final[,"Pop"]<-gsub("Sierra_Leona_","",ROH.final[,"Pop"])
ROH.final[,"Pop"]<-gsub("Kenya_Webuye","LWK",ROH.final[,"Pop"])
ROH.final[,"Pop"]<-gsub("Italy_Toscana","TSI",ROH.final[,"Pop"])
ROH.final[,"Pop"]<-gsub("Finlandia_","",ROH.final[,"Pop"])
ROH.final[,"Pop"]<-gsub("UK_","",ROH.final[,"Pop"])
ROH.final[,"Pop"]<-gsub("Spain_","",ROH.final[,"Pop"])
ROH.final[,"Pop"]<-gsub("USA_Utah","CEU",ROH.final[,"Pop"])
ROH.final[,"Pop"]<-gsub("Bangladesh","BEB",ROH.final[,"Pop"])
ROH.final[,"Pop"]<-gsub("Pakistan_Lahore","PJL",ROH.final[,"Pop"])
ROH.final[,"Pop"]<-gsub("Vietnam_Ho_Chi_Minh","KHV",ROH.final[,"Pop"])
ROH.final[,"Pop"]<-gsub("Japan_Tokyo","JPT",ROH.final[,"Pop"])
ROH.final[,"Pop"]<-gsub("China","CDX",ROH.final[,"Pop"])
ROH.final[,"Pop"]<-gsub("_NA","",ROH.final[,"Pop"])

library(dplyr)

color.file<-"order_countries_2022"
colors.countries<- read.table(color.file, head=TRUE)
final.countries<-unique(ROH.final$Pop)

colors.ordered<-colors.countries[colors.countries$Country %in% final.countries,]

ROH.final$Pop<-as.factor(ROH.final$Pop)

pops<-colors.ordered$Country
color.region<-colors.ordered$Color
ROH.final.toplot<-ROH.final[ROH.final$Pop %in% pops,]



library(ggpubr)
library(ggplot2)

jpeg(filename = paste0(path,"ROH_GARLIC_GLAD_ver3.jpg"),width = 19, height = 19, units = "cm", pointsize =12,  res = 600) 

ggplot(ROH.final.toplot, aes(x=factor(Pop,levels = pops), y=ROH_sizeTotal)) + 
  geom_boxplot(fill=color.region,lwd=0.6,outlier.size=0.5) +  ylim(c(250, 1200))+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),legend.position="none")+
  theme(axis.text.y = element_text(angle = 90, vjust = 0.5, hjust=1),legend.position="none")+
  xlab("REGIONS")
dev.off() 

library(stringr)


admixture<-read.table("20220428_TargetAndParental_admixture_proportions_clusters.AverageBygroups.txt",header = T)

colnames(admixture7)<-c("ID","Andean","Asian","Amazon","European","African")

col.names.med = c("Pop", "median","AFR","EUR","NAT")
dfBra <- read.table(text = "",col.names = col.names.med)
Brazilian<-str_subset(pops, "Brazil", negate = FALSE)
Peruvians<-c("Peru_Tumbes", "Peru_Lambayaque", "Peru_La_Libertad", "Peru_Amazonas",
             "Peru_San_Martin", "Peru_Loreto", "Peru_Ancash", "Peru_Lima", "Peru_Ica",
            "Peru_Arequipa", "Peru_Ayacucho", "Peru_Cusco", "Peru_Moquegua", "Peru_Puno", "Peru_Tacna")
Peruvians_NPA<-c("Peru_Tumbes", "Peru_Lambayaque", "Peru_La_Libertad",
                 "Peru_Loreto", "Peru_Ancash", "Peru_Lima",
                 "Peru_Arequipa", "Peru_Ayacucho", "Peru_Cusco", "Peru_Moquegua", "Peru_Tacna")

for (i in 1:length(Brazilian)){
  dfBra[i,1]<-Brazilian[i]
  ROH.final.Bras<-ROH.final.toplot[ROH.final.toplot$Pop %in% Brazilian[i],]  
  dfBra[i,2]<-median(ROH.final.Bras$ROH_sizeTotal)
  dfBra[i,3]<-admixture[admixture$GROUP==Brazilian[i],"AFR"]
  dfBra[i,4]<-admixture[admixture$GROUP==Brazilian[i],"EUR"]
  dfBra[i,5]<-admixture[admixture$GROUP==Brazilian[i],"NAT"]
}




cor.test(dfBra$median,dfBra$AFR)
cor.test(dfBra$median,dfBra$EUR)
cor(dfBra$median,dfBra$NAT)

dfPer <- read.table(text = "",col.names = col.names.med)
for (i in 1:length(Peruvians_NPA)){
  dfPer[i,1]<-Peruvians_NPA[i]
  ROH.final.Per<-ROH.final.toplot[ROH.final.toplot$Pop %in% Peruvians_NPA[i],]  
  dfPer[i,2]<-median(ROH.final.Per$ROH_sizeTotal)
  dfPer[i,3]<-admixture[admixture$GROUP==Peruvians_NPA[i],"AFR"]
  dfPer[i,4]<-admixture[admixture$GROUP==Peruvians_NPA[i],"EUR"]
  dfPer[i,5]<-admixture[admixture$GROUP==Peruvians_NPA[i],"NAT"]
}

cor(dfPer$median,dfPer$AFR)
cor(dfPer$median,dfPer$EUR)
cor.test(dfPer$median,dfPer$NAT)

