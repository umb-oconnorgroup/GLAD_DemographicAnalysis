GAfIS use the Forward-Backward probability files (FB.tsv file) to identify ancestry segments with an specific level of probability. However, it
requires the start and end of the segment in order to determine its IBD relationship. RFMIX ver 2 outputs have some issues about it. Its FB.tsv
output does not contain the start and end information and the MSP.tsv file contains a different number of lines. In order to obtain a MSP file
with the start and end information for the CRF points of the FB file, you can run the following commands:

For chromosome 1\:

for i in 1\; do awk \'\{print $\\$1\$"\t\"$\\$2\$"\t\"$\\$3\$"\t\"$\\$4\$}\' FILE_chr$\\$\{i\}\$.fb.tsv  \| sed 1,2d >  fb_chr\$\{i\}\.txt ; done

for i in 1\; do perl creating_intervals_rfmixoutputs.pl \-bim genmap_chr$\\$i\$.map \-index  fb_chr$\\$i\$.txt \-out Intervals_chr$\\$i\$.txt ; done

After that you will have an output with the following format:

                                                #Subpopulation order/codes: AFR=0	EAS=1	EUR=2	NAT=3 
                                                #chm	spos	epos	sgpos	egpos
                                                chr16	310888	1463573	0.33401	3.4850538
                                                chr16	1464324	1477086	3.48577	3.526887
                                                chr16	1477272	1480359	3.52768	3.5387049
                                                chr16	1480391	1480839	3.53881	3.5403451
                                                chr16	1480848	1481300	3.54038	3.5419204


