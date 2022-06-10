**RUNNING LOCAL ANCESTRY IBD ANALYSIS**  

From the multi-way admixed origin of Latin American populations, IBD and Local ancestry methods provide an opportunity to test the relationships of European,
African, and Indigenous American related IBD segments along the Americas.
We implemented a python algorithm called GAfIS ( that stands for “Getting Ancestry For IBD Segments” ) that uses RFMIX outputs to identify local ancestry labels for an IBD segment shared by a pair of individuals under a certain probability threshold.
As a probability threshold for local ancestry inferences in GAfIS, we set 90% for a genomic region being of the K ancestry. Moreover, if an IBD segment contained several ancestries, we split the segment into pieces corresponding to independent ancestries for each pair of individuals.

GAfIS runs per chromosome like this:

python3.8 ./GetAncestryforIBDSegments.py -d $parfile -f $indir -c 0.9 -r True

INPUTS  
* parfile: Text file with the following format:

        #Name	FB	msp	IBD  
        OUTPUTNAME	FILE.fb.tsv	FILE.msp.tsv	COMPRESSED_IBDFILE  
    
    * FB.tsv and MSP.tsv correspond to probabilities and ancestry designation files, respectively. This GAfIS works fine with XGMIX or GNOMIX outputs. If you are using RFMIX ver2 outputs the MSP file requires some manipulation (please check the [RFMIX_outputs_editing](https://github.com/umb-oconnorgroup/GLAD_DemographicAnalysis/tree/Ancestry-Specific_IBD/Ancestry-Specific_IBD/RFMIX_outputs_editing) FOLDER)  
    * COMPRESSED_IBDFILE corresponds to output of [hap-ibd](https://github.com/browning-lab/hap-ibd). hap-ibd output need to be compressed with gzip.  
* indir: path + name of the output folder
* c : Probability threshold for Local ancestry inference
* r : Default mode is False. If True, GAfIS will print the individuals that included in IBD files no in Local Ancestry outputs  


After ancestry identification of the IBD segments, we filter out ancestry specific-IBD segments based on the following criteria:  

1.One of the ancestry labels was unknown for having a local ancestry probability lower than 90%. (REQUIRED)  
2.Keeping indivuals with demographic information.  
3.Removing segments in which both ancestry labels of the IBD segment shared by a pair of individuals were different.  (REQUIRED)
4.Summing the segments lenght per individual.  
5.Getting the total amount per population.  

**Step 1**  
  
        perl RemovingUnknown.pl -input <prefix>_out -output <output1>  
  
\<prefix\> : Correspond to the OUTPUTNAME from GAfIS followed by "_out"

**Step 2**  
  
        perl Matchingind_demoibd.pl -demo <demographic file>  -ibd <output1>.Unknownremoved.txt -output <output1>  
          
 demo file: Demographic file or list of individuals to include. The script will considered just the first column
 
**Step 3**  
  
        perl Extract_same_ancestryibd.pl -ibd <output1>.Demofiltered.txt -output <output1>  
**Step 4**  
  
        perl Average_IBD_estimator.pl -ibd <output1>.same_ancestry_filtered.txt -output <output1>  

Generating a list of outputs for each chromosome of the later script and merging all chrs  
  
        ls <Folder name for each chromosome>*/*TotalIBDlength.txt > list2merge  
  
        perl Average_IBD_estimator_severalchrs_ver2.pl -listibd list2merge -output <output2>  
          
 **Step 5**  
   
        perl Weigthed_IBD_estimator_ver2.pl -demo <demographic file> -ibd <output2>.TotalIBDlength_severalchrs.txt -output <output3>  
        
        
After getting the IBD amount per pair of populations, the R script ASIBD_EstimationAndPlotting.R determine the ASIBD values and generates maps


