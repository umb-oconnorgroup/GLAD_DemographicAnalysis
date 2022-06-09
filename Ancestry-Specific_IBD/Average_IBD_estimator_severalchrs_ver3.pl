#!usr/bin/perl
use Getopt::Long;
use Data::Dumper;

GetOptions (
	"listibd=s"=>\$listibd,
	"output=s"=>\$output,
	"help!"=>\$help,
)or die(showhelp());

if($listibd eq "" or $output eq ""){
	showhelp();						
}


$totalpairs=0;
undef(@ordenind1);
undef(@ordenind2);

open (IF,"$listibd") or die ("We cannot find the List of IBD files.txt\n");

@List_IBD=<IF>;

chomp(@List_IBD);

print "@List_IBD[0]\n";
$F1pairs=0;

open (IF1,"@List_IBD[0]") or die ("We cannot find the first total IBD file \n");


$dummy=<IF1>;   #First line is read here (HEADER)

#### Saving the pairs of the first file
while(<IF1>){
	$line=$_;
	$line=~ s/\n//gi;
	$line=~ s/\r//gi;
	@line_ibd=split(/\s+/,$line);

	$hash_total{@line_ibd[0]}{@line_ibd[1]}=@line_ibd[2];
	$F1pairs++;
	
	## order pairs
	push @ordenind1, @line_ibd[0];			## Saving order ind1
	push @ordenind2, @line_ibd[1];			## Saving order ind2

	## Ancestry Specific IBD
	$hash_AFR{@line_ibd[0]}{@line_ibd[1]}=@line_ibd[3];
	$hash_EUR{@line_ibd[0]}{@line_ibd[1]}=@line_ibd[4];	
	$hash_NAT{@line_ibd[0]}{@line_ibd[1]}=@line_ibd[5];	
	$hash_EAS{@line_ibd[0]}{@line_ibd[1]}=@line_ibd[6];	
}

print "$F1pairs\n";


foreach $i(1..$#List_IBD){
	print "$List_IBD[$i]\n";
	open (IF2,"@List_IBD[$i]") or die ("We cannot find the total IBD file 2\n");
	$dummy2=<IF2>;   #First line is read here (HEADER)

	while(<IF2>){
		$line2=$_;
		$line2=~ s/\n//gi;
		$line2=~ s/\r//gi;
		@line_ibd2=split(/\s+/,$line2);
		if(exists($hash_total{@line_ibd2[0]}{@line_ibd2[1]}  )){
		
			##Total IBD
			$cM=$hash_total{@line_ibd2[0]}{@line_ibd2[1]};
			$cMnext=@line_ibd2[2];
			$hash_total{@line_ibd2[0]}{@line_ibd2[1]}=$cM+$cMnext;

			## Ancestry Specific IBD
			$AFR=$hash_AFR{@line_ibd2[0]}{@line_ibd2[1]};
			$AFRnext=@line_ibd2[3];
			$hash_AFR{@line_ibd2[0]}{@line_ibd2[1]}=$AFR+$AFRnext;

			$EUR=$hash_EUR{@line_ibd2[0]}{@line_ibd2[1]};
			$EURnext=@line_ibd2[4];
			$hash_EUR{@line_ibd2[0]}{@line_ibd2[1]}=$EUR+$EURnext;

			$NAT=$hash_NAT{@line_ibd2[0]}{@line_ibd2[1]};
			$NATnext=@line_ibd2[5];
			$hash_NAT{@line_ibd2[0]}{@line_ibd2[1]}=$NAT+$NATnext;

			$EAS=$hash_EAS{@line_ibd2[0]}{@line_ibd2[1]};
			$EASnext=@line_ibd2[6];
			$hash_EAS{@line_ibd2[0]}{@line_ibd2[1]}=$EAS+$EASnext;

		}elsif(exists($hash_total{@line_ibd2[1]}{@line_ibd2[0]}  )){
			
				##Total IBD
			$cM=$hash_total{@line_ibd2[1]}{@line_ibd2[0]};
			$cMnext=@line_ibd2[2];
			$hash_total{@line_ibd2[1]}{@line_ibd2[0]}=$cM+$cMnext;

			## Ancestry Specific IBD
			$AFR=$hash_AFR{@line_ibd2[1]}{@line_ibd2[0]};
			$AFRnext=@line_ibd2[3];
			$hash_AFR{@line_ibd2[1]}{@line_ibd2[0]}=$AFR+$AFRnext;

			$EUR=$hash_EUR{@line_ibd2[1]}{@line_ibd2[0]};
			$EURnext=@line_ibd2[4];
			$hash_EUR{@line_ibd2[0]}{@line_ibd2[1]}=$EUR+$EURnext;

			$NAT=$hash_NAT{@line_ibd2[1]}{@line_ibd2[0]};
			$NATnext=@line_ibd2[5];
			$hash_NAT{@line_ibd2[1]}{@line_ibd2[0]}=$NAT+$NATnext;

			$EAS=$hash_EAS{@line_ibd2[1]}{@line_ibd2[0]};
			$EASnext=@line_ibd2[6];
			$hash_EAS{@line_ibd2[1]}{@line_ibd2[0]}=$EAS+$EASnext;		
		
		
		
		}else{
		
			$hash_total{@line_ibd2[0]}{@line_ibd2[1]}=@line_ibd2[2];

			## order pairs
			push @ordenind1, @line_ibd2[0];			## Saving order ind1
			push @ordenind2, @line_ibd2[1];			## Saving order ind2

			## Ancestry Specific IBD
			$hash_AFR{@line_ibd2[0]}{@line_ibd2[1]}=@line_ibd2[3];
			$hash_EUR{@line_ibd2[0]}{@line_ibd2[1]}=@line_ibd2[4];	
			$hash_NAT{@line_ibd2[0]}{@line_ibd2[1]}=@line_ibd2[5];	
			$hash_EAS{@line_ibd2[0]}{@line_ibd2[1]}=@line_ibd2[6];	

					
		}

	}
}

open (OT, ">","$output.TotalIBDlength_severalchrs.txt");

print OT "IND1\tIND2\tTOTALIBD\tIBD_AFR\tIBD_EUR\tIBD_NAT\tIBD_EAS\n";

foreach $j(0..$#ordenind1){		## loop to create coordinates of the target samples to mask
	$TOTf=$hash_total{@ordenind1[$j]}{@ordenind2[$j]};
	$AFRf=$hash_AFR{@ordenind1[$j]}{@ordenind2[$j]}+0;
	$EURf=$hash_EUR{@ordenind1[$j]}{@ordenind2[$j]}+0;
	$NATf=$hash_NAT{@ordenind1[$j]}{@ordenind2[$j]}+0;
	$EASf=$hash_EAS{@ordenind1[$j]}{@ordenind2[$j]}+0;
	print OT "@ordenind1[$j]\t@ordenind2[$j]\t$TOTf\t$AFRf\t$EURf\t$NATf\t$EASf\n";
	
}

#print "Total number of pairs: $totalpairs\n";

