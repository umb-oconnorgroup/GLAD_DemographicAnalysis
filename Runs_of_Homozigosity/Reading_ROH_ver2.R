##############################################################
################## Counting ROH segments #####################
##############################################################

#BiocManager::install("rtracklayer")
library(rtracklayer)
library("stringr")

temp=commandArgs()

ROHfile=as.character(temp[2])
output.filename=as.character(temp[3])
Population=as.character(temp[4])

col.names2 = c("ID","Pop", "ROH_sizeA", "ROH_sizeB", "ROH_sizeC", "ROH_sizeTotal")
df2 <- read.table(text = "",col.names = col.names2)

bedroh<-import(ROHfile, format="bed")


for (ind in 1:length(bedroh)){
  indROH<-as.data.frame(bedroh[ind])
  id<-str_split(unique(indROH$group_name)," ")
  Pop<-str_split(id[[1]][3],":")
  
  ##Summing
  df2[ind,1]<-id[[1]][2]
  df2[ind,2]<-Population
  
  df2[ind,3]<-sum(indROH[indROH$name=="A",6])/1000000
  df2[ind,4]<-sum(indROH[indROH$name=="B",6])/1000000
  df2[ind,5]<-sum(indROH[indROH$name=="C",6])/1000000
  df2[ind,6]<-sum(indROH$score)
}

write.table(df2,output.filename, col.names=T,row.names=F,quote =F)

###################################
###################################
###################################
## Organizing Brazil Minas gerais
path<-"/home/victor/UMB/GLAD_Project/ROH/Outputs_GLAD_March2022/"
Minas <- read.table(file=paste0(path,"SIZEROH_Brazil_Minas_Gerais.txt"),header=TRUE)

Brazil_MG_pops<-read.table(file="/home/victor/UMB/GLAD_Project/ROH/Outputs_TPBWT/Brazil_MG_pops",header=FALSE)
colnames(Brazil_MG_pops)[2]<-"Region"
colnames(Brazil_MG_pops)[1]<-"ID"

Minas_ids<-merge(Minas,Brazil_MG_pops,by.x="ID",by.y = "ID")
braz.pops<-unique(Brazil_MG_pops$Region)

Minas_ids<-merge(Minas,Brazil_MG_pops,by.x="ID",by.y = "ID")

for (i in braz.pops){
  output.bras<-paste0(path,"SIZEROH_",i,".txt")
  braz.pop1<-Minas_ids[Minas_ids$Region %in% i,]
  braz.pop2<-subset(braz.pop1,select=c(1:6))
  braz.pop2$Pop<-i
  write.table(braz.pop2,output.bras, col.names=T,row.names=F,quote =F)
}


demo<-"/home/victor/UMB/GLAD_Project/ROH/Outputs_TPBWT/Demographics_December2021_filtergraphpop_countries_and_parentals+HawaiiNAT.txt"
demo2<-"/home/victor/UMB/GLAD_Project/ROH/Outputs_TPBWT/Demographics_March2022_filtergraphpop_countries_and_parentals+HawaiiNAT.txt"
demographics<-read.table(demo,header=FALSE)

regions<-c()
for (i in 1:nrow(demographics)) {
    ind<-demographics[i,1]
    pos<-as.numeric(grep(ind,Brazil_MG_pops$ID))
  if(length(pos)>0){
    pos<-as.numeric(grep(ind,Brazil_MG_pops$ID))
    regionBRA<-Brazil_MG_pops$Region[pos]
    regions<-c(regions,regionBRA)
  }else{
    regions<-c(regions,demographics[i,5])
  }
}
demographics$V5<-regions

write.table(demographics,demo2, col.names=F,row.names=F,quote =F)


###################################
###################################
###################################
###################################
## Organizing New York
path<-"/home/victor/UMB/GLAD_Project/ROH/Outputs_GLAD_March2022/"
NY <- read.table(file=paste0(path,"SIZEROH_USA_New_York.txt"),header=TRUE)

NY_pops<-read.table(file="/home/victor/UMB/GLAD_Project/Demographics/ID_Region_New_York",header=FALSE)
colnames(NY_pops)[2]<-"Region"
colnames(NY_pops)[1]<-"ID"

NY_ids<-merge(NY,NY_pops,by.x="ID",by.y = "ID")
NY.pops<-unique(NY_pops$Region)

for (i in NY.pops){
  output.bras<-paste0(path,"SIZEROH_",i,".txt")
  braz.pop1<-NY_ids[NY_ids$Region %in% i,]
  braz.pop2<-subset(braz.pop1,select=c(1:6))
  braz.pop2$Pop<-i
  write.table(braz.pop2,output.bras, col.names=T,row.names=F,quote =F)
}


write.table(NY,paste0(path,"SIZEROH_USA_New_York.txt"), col.names=T,row.names=F,quote =F)

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

color.file<-"/home/victor/UMB/GLAD_Project/ROH/Outputs_GLAD_March2022/order_countries_2022"
colors.countries<- read.table(color.file, head=TRUE)
final.countries<-unique(ROH.final$Pop)

colors.ordered<-colors.countries[colors.countries$Country %in% final.countries,]

ROH.final$Pop<-as.factor(ROH.final$Pop)

pops<-colors.ordered$Country
color.region<-colors.ordered$Color
#demo.colors<-merge(demo.ordered,order.filtered,by.x="region",by.y="Country",all.x=TRUE)
ROH.final.toplot<-ROH.final[ROH.final$Pop %in% pops,]



library(ggpubr)
library(ggplot2)

jpeg(filename = paste0(path,"ROH_GARLIC_GLAD_ver3.jpg"),width = 19, height = 19, units = "cm", pointsize =12,  res = 600) 
#jpeg(filename = paste0(path,"ROH_GARLIC_GLAD_sizeC.jpg"),width = 19, height = 19, units = "cm", pointsize =12,  res = 600) 
#jpeg(filename = "/home/victor/UMB/GLAD_Project/ROH/Outputs_TPBWT/ROH_TPBWT_GLAD_violin.jpg",width = 19, height = 15, units = "cm", pointsize =12,  res = 600) 

# jpeg(filename = "//home/victor/UMB/Women_Cancer/Somatic_mutations/error_bars_dips_exclusive_above20M_SD.jpg",width = 19, height = 15, units = "cm", pointsize =12,  res = 600) 
ggplot(ROH.final.toplot, aes(x=factor(Pop,levels = pops), y=ROH_sizeTotal)) + 
  #  ggplot(demo.colors, aes(x=factor(region,levels = pops), y=ROH)) + 
  geom_boxplot(fill=color.region,lwd=0.6,outlier.size=0.5) +  ylim(c(250, 1200))+
  #geom_point(lwd=0.4)+
  #  geom_violin(fill=demo.colors$Color) +  ylim(c(0, 100))+
  #geom_violin() +  ylim(c(0, 30))+
  #   geom_text(data = cw_summary,
  #             aes(Diplotype, Inf, label = n), vjust = 1) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),legend.position="none")+
  theme(axis.text.y = element_text(angle = 90, vjust = 0.5, hjust=1),legend.position="none")+
  xlab("REGIONS")
dev.off() 

library(stringr)


admixture<-read.table("/home/victor/UMB/GLAD_Project/Population_Structure/20220428_TargetAndParental_admixture_proportions_clusters.AverageBygroups.txt",header = T)
#admixture7<-read.table("/home/victor/UMB/GLAD_Project/ROH/Inputs_Peruvians/ADMIXTURE_proportions_5.clusters",header = FALSE)

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

################# array data
admixture7<-read.table("/home/victor/UMB/GLAD_Project/ROH/Inputs_Peruvians/ADMIXTURE_proportions_5.clusters",header = FALSE)
colnames(admixture7)<-c("ID","Andean","Asian","Amazon","European","African")
admixture7$ID<-paste0("full_PGP_LDGH_",admixture7$ID)
Peru.ROH<-merge(ROH.final.toplot,admixture7,by.x = "ID",by.y = "ID",all.y = TRUE)
Peru.ROH<-na.omit(Peru.ROH) 

col.names.med = c("Pop", "median","Andean","Amazon","European","African","NAT")
dfPer <- read.table(text = "",col.names = col.names.med)
for (i in 1:length(Peruvians_NPA)){
  dfPer[i,1]<-Peruvians_NPA[i]
  ROH.final.Per<-Peru.ROH[Peru.ROH$Pop %in% Peruvians_NPA[i],]  
  dfPer[i,2]<-median(ROH.final.Per$ROH_sizeTotal)
  #dfPer[i,3]<-mean(Peru.ROH[Peru.ROH$Pop==Peruvians_NPA[i],"Andean"])
  dfPer[i,3]<-mean(Peru.ROH[Peru.ROH$Pop==Peruvians_NPA[i],"Andean"])
  dfPer[i,4]<-mean(Peru.ROH[Peru.ROH$Pop==Peruvians_NPA[i],"Amazon"])
  dfPer[i,5]<-mean(Peru.ROH[Peru.ROH$Pop==Peruvians_NPA[i],"European"])
  dfPer[i,6]<-mean(Peru.ROH[Peru.ROH$Pop==Peruvians_NPA[i],"African"])
  dfPer[i,7]<-mean(Peru.ROH[Peru.ROH$Pop==Peruvians_NPA[i],"Andean"]) + mean(Peru.ROH[Peru.ROH$Pop==Peruvians_NPA[i],"Amazon"])
  
}

cor(dfPer$median,dfPer$Andean)
cor(dfPer$median,dfPer$Amazon)
cor(dfPer$median,dfPer$African)
cor(dfPer$median,dfPer$European)
cor(dfPer$median,dfPer$NAT)



library("ggplot2")

colors_Peru<-c("lightskyblue","lightskyblue","lightsalmon4","lightskyblue","lightskyblue","lightskyblue","lightskyblue","lightskyblue",
          "lightsalmon4","lightsalmon4","lightsalmon4","lightsalmon4","mediumseagreen")

colors_glad1<-c("purple","lightskyblue","mediumseagreen","mediumseagreen","mediumseagreen","mediumseagreen",
                "mediumseagreen","mediumseagreen","mediumseagreen","lightsalmon4")

colors_glad2<-c("purple","lightskyblue","lightskyblue","lightskyblue","lightskyblue","lightskyblue",
                "lightskyblue","lightskyblue","lightskyblue","lightskyblue","lightskyblue",
                "mediumseagreen","lightsalmon4")

#glad1<-c("ASW","ACB","Pernambuco","Bambui","Montes_Claros","BeloHorizonte","Rio_de_Janeiro","Ribeirao","Pelotas","Luo_Peru_Lima")
glad2<-c("Australia", "California",  "Hawaii", "Illinois", "Minnesota", "New_York", "North_Carolina",
         "Ohio", "Tennessee", "Texas", "Wisconsin", "CostaRica","Colombia_Antioquia")

#Peru<-c("Tumbes","Lambayeque","Ancash","Trujillo","Lima","Afro_des","Moquegua","Tacna","Arequipa","Ayacucho","Cusco","Puno","Iquitos")

df_size$Pop <- factor(df_size$Pop,levels = glad2,ordered = TRUE)
p <- ggplot(df_size, aes(x=Pop, y=ROH_sizeTotal,fill=Pop)) + 
  geom_violin() + theme(legend.position="none") +
  
  #scale_fill_manual(values=colors) +
  scale_fill_manual(values=colors_glad2) +
  scale_x_discrete(name= "Populations", breaks=glad2,
                   #labels=c("ASW","ACB","Pernambuco","Bambui","Montes_Claros","BeloHorizonte","Rio_de_Janeiro",
                   #          "Ribeirao","Pelotas","Luo_Peru_Lima")) +
                   labels=c("Australia", "California",  "Hawaii", "Illinois", "Minnesota", "New_York", "North_Carolina", "Ohio",
                            "Tennessee", "Texas", "Wisconsin", "CostaRica","Colombia_Antioquia"))
#  ylim(0, 2000)

p<- p+ ylim(0, 1500)
#p< p+geom_jitter(shape=16, position=position_jitter(0.3))

ggsave("/home/victor/UMB/GLAD_Project/ROH/ROH_Total_GLAD_Nov5_group345_sizeTotal.jpg",scale = 2.5, width = 15, height = 5, units = "cm",dpi = 300)

