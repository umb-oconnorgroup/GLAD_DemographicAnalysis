**RUNNING LOCAL ANCESTRY IBD ANALYSIS**  

From the multi-way admixed origin of Latin American populations, IBD and Local ancestry methods provide an opportunity to test the relationships of European,
African, and Indigenous American related IBD segments along the Americas.
We implemented a python algorithm called GAfIS ( that stands for “Getting Ancestry For IBD Segments” ) that uses RFMIX outputs to identify local ancestry labels for an IBD segment shared by a pair of individuals under a certain probability threshold.
As a probability threshold for local ancestry inferences in GAfIS, we set 90% for a genomic region being of the K ancestry. Moreover, if an IBD segment contained several ancestries, we split the segment into pieces corresponding to independent ancestries for each pair of individuals.

GAfIS runs like this:

python3.8 ./GetAncestryforIBDSegments.py -d $parfile -f $indir -c 0.9 -r True

INPUTS  
* parfile: Text file with the following format:

    #Name	FB	msp	IBD  
    OUTPUTNAME	FILE.fb.tsv	FILE.msp.tsv	COMPRESSED_IBDFILE  
    
    * FB.tsv and MSP.tsv correspond to probabilities and ancestry designation files. This GAfIS works fine with XGMIX or GNOMIX outputs. If you are using RFMIX ver2 outputs the MSP file requires some manipulation (please check the <a href=https://github.com/umb-oconnorgroup/GLAD_DemographicAnalysis/tree/Ancestry-Specific_IBD/Ancestry-Specific_IBD/RFMIX_outputs_editing">RFMIX_outputs_editing</a> FOLDER)














After ancestry identification of the IBD segments, we filter out ancestry specific-IBD segments based on the following criteria:
-One of the ancestry labels was unknown for having a local ancestry probability lower than 90%
-Both ancestry labels of the IBD segment shared by a pair of individuals were different.

After those filters, we kept individuals with demographic information and we calculated an ancestry specific IBD score (asIBD score) within and across the 45 Latin American groups. Our asIBD score is defined in following equations


## par files

#Name	FB	msp	IBD
Chr22_20220420_HAPIBD_Greater21cM	/local/chib/oconnor_genomes/GLAD/F1_merged_data/imputed_above0.9/Local_ancestry_202108/Outputs_Phased_202201_rfmix_8G/GLAD_F1_Phased_rfmix_G8_202201_chr22.fb.tsv	/local/chib/oconnor_genomes/GLAD/F1_merged_data/imputed_above0.9/Local_ancestry_202108/Outputs_Phased_202201_rfmix_8G/Intervals_chr22.txt	/local/chib/oconnor_genomes/GLAD/F1_merged_data/imputed_above0.9/Local_ancestry_202108/LA_IBD/IBD_files_58K/interval_Greater21cM/22.split1.decoded.ibd.Greater21cM.gz

for i in $(seq 1 21); do sed -e "s/Chr22/Chr${i}/g" -e "s/chr22/chr${i}/g" -e "s/22.split/${i}.split/g" input_202204_21cM_rfmix_chr22.txt > input_202204_21cM_rfmix_chr${i}.txt ; done

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
