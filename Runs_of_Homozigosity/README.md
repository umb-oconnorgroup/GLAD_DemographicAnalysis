
**RUNS OF HOMOZIGOSITY ANALYSIS**  
  
After running GARLIC, we identify the individual amount of ROH segments using the R script Reading_ROH_ver2.R.  
This script requires R version 3 (required libraries are not available for R version 4) and the **stringr** and **rtracklayer** packages
You can install this packages in R using the following commands

install.packages("stringr")  
BiocManager::install("rtracklayer")  
  
The script runs with the following command line:  
  
  for pop in Brazil_Bahia ; do R < Reading_ROH_ver2.R <GARLIC OUTPUT> <OUTPUT PREFIX> ${pop} --no-save ; done  
  
 






