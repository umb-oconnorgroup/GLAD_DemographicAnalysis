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

STEP 1  
perl \${script1} -input \<prefix\> -output \<output1\>  
STEP 2  
perl \${script2} -demo \<demographic file\>  -ibd \<output1\>.Unknownremoved.txt -output \<output1\>  
STEP 3  
perl \${script3} -ibd \<output1\>.Demofiltered.txt -output \<output1\>  
STEP 4  
perl \${script4} -ibd \<output1\>.same_ancestry_filtered.txt -output \<output1\>  



################################################################
#!/bin/bash
#$ -q all.q
#$ -P toconnor-lab
#$ -o chr22HG.log
#$ -N chr22HG
#$ -cwd
#$ -l mem_free=20G

chr=22
python=/local/chib/toconnor_grp/victor/miniconda3/bin/python3.8 
path=/local/chib/oconnor_genomes/GLAD/F1_merged_data/imputed_above0.9/Local_ancestry_202108/LA_IBD
gaffi=${path}/scripts/GetAncestryforIBDSegments.py
indir=${path}/RFMIX_20220401_HAPIBD_Greater21cM/RFMIX_20220401_HAPIBD_Greater21cM_chr${chr}
demo=${path}/Demographics_April2022_filtergraphpop_countries_and_parentals+HawaiiNAT

parfile=${path}/par_files/rfmix_hapibd_inputs_April/input_202204_21cM_rfmix_chr${chr}.txt
prefix=Chr${chr}_20220420_HAPIBD_Greater21cM_out \
script1=${path}/scripts/RemovingUnknown.pl \
script2=${path}/scripts/Matchingind_demoibd.pl \
script3=${path}/scripts/Extract_same_ancestryibd.pl \
script4=${path}/scripts/Average_IBD_estimator.pl \

${python} ${gaffi} -d ${parfile} -f ${indir} -c 0.9 -r True

perl ${script1} -input ${indir}/${prefix} -output ${indir}/${prefix}
perl ${script2} -demo ${demo}  -ibd ${indir}/${prefix}.Unknownremoved.txt -output ${indir}/${prefix}
perl ${script3} -ibd ${indir}/${prefix}.Demofiltered.txt -output ${indir}/${prefix}
perl ${script4} -ibd ${indir}/${prefix}.same_ancestry_filtered.txt -output ${indir}/${prefix}

for i in $(seq 1 21); do sed -e "s/chr22/chr${i}/g" -e "s/chr=22/chr=${i}/g" Running_G_hapibd_chr22.pbs > Running_G_hapibd_chr${i}.pbs ; done
