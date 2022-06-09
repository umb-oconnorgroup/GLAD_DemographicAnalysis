GAfIS use the Forward-Backward probability files (FB.tsv file) to identify ancestry segments with an specific level of probability. However, it
requires the start and end of the segment in order to determine its IBD relationship. RFMIX ver 2 outputs have some issues about it. Its FB.tsv
output does not contain the start and end information and the MSP.tsv file contains a different number of lines. In order to obtain a MSP file
with the start and end information for the CRF points of the FB file, you can run the following commands:

For chromosome 1:

for i in 1; do awk '{print $1"\t"\$2"\t"\$3"\t"\$4}' FILE_chr${i}.fb.tsv  | sed 1,2d >  fb_chr${i}.txt ; done

for i in 1; do perl creating_intervals_rfmixoutputs.pl -bim genmap_chr\$\{i\}.map -index fb_chr${i}.txt -out Intervals_chr${i}.txt ; done

