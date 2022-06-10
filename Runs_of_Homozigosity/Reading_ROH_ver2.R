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

