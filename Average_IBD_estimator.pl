#!usr/bin/perl
use Getopt::Long;
use Data::Dumper;

GetOptions (
	"ibd=s"=>\$ibd,
	"output=s"=>\$output,
	"help!"=>\$help,
)or die(showhelp());

if($ibd eq "" or $output eq ""){
	showhelp();						
}

open (IF,"$ibd") or die ("We cannot find the ibd file\n");

$totalpairs=0;

undef(@ordenhap1);
undef(@ordenhap2);

while(<IF>){
	$line=$_;
	$line=~ s/\n//gi;
	$line=~ s/\r//gi;
	@line_ibd=split(/\s+/,$line);
	if(exists($hash_ID{@line_ibd[0]}{@line_ibd[2]})){
	
		##Total IBD
		$cM=$hash_ID{@line_ibd[0]}{@line_ibd[2]};
		$BP=@line_ibd[6]-@line_ibd[5];			##sizeIBD
		$BPinterval=@line_ibd[9]-@line_ibd[8];		##sizetarget
		$cMnext=@line_ibd[7]*($BPinterval/$BP);
		$hash_ID{@line_ibd[0]}{@line_ibd[2]}=$cM+$cMnext;
		## Ancestry Specific IBD
		if(@line_ibd[10] eq "AFR"){
			$hash_AFR{@line_ibd[0]}{@line_ibd[2]}=$cMnext+$hash_AFR{@line_ibd[0]}{@line_ibd[2]};
		}elsif(@line_ibd[10] eq "EUR"){
			$hash_EUR{@line_ibd[0]}{@line_ibd[2]}=$cMnext+$hash_EUR{@line_ibd[0]}{@line_ibd[2]};	
		}elsif(@line_ibd[10] eq "NAT"){
			$hash_NAT{@line_ibd[0]}{@line_ibd[2]}=$cMnext+$hash_NAT{@line_ibd[0]}{@line_ibd[2]};	
		}elsif(@line_ibd[10] eq "EAS"){
			$hash_EAS{@line_ibd[0]}{@line_ibd[2]}=$cMnext+$hash_EAS{@line_ibd[0]}{@line_ibd[2]};	
		}		
	}else{
		$totalpairs++;		
		##Total IBD
		$BP1=@line_ibd[6]-@line_ibd[5];			##sizeIBD
		$BPinterval1=@line_ibd[9]-@line_ibd[8];		##sizetarget
		$cM1=@line_ibd[7]*($BPinterval1/$BP1);
		$hash_ID{@line_ibd[0]}{@line_ibd[2]}=$cM1;

		## order pairs
		push @ordenhap1, @line_ibd[0];			## Saving order hap1
		push @ordenhap2, @line_ibd[2];			## Saving order hap2

		## Ancestry Specific IBD
		if(@line_ibd[10] eq "AFR"){
			$hash_AFR{@line_ibd[0]}{@line_ibd[2]}=$cM1;
		}elsif(@line_ibd[10] eq "EUR"){
			$hash_EUR{@line_ibd[0]}{@line_ibd[2]}=$cM1;	
		}elsif(@line_ibd[10] eq "NAT"){
			$hash_NAT{@line_ibd[0]}{@line_ibd[2]}=$cM1;	
		}elsif(@line_ibd[10] eq "EAS"){
			$hash_EAS{@line_ibd[0]}{@line_ibd[2]}=$cM1;	
		}		
			
	}

}

open (OT, ">","$output.TotalIBDlength.txt");

print OT "IND1\tIND2\tTOTALIBD\tIBD_AFR\tIBD_EUR\tIBD_NAT\tIBD_EAS\n";

foreach $i(0..$#ordenhap1){		## loop to create coordinates of the target samples to mask
	$TOT=$hash_ID{@ordenhap1[$i]}{@ordenhap2[$i]};
	$AFR=$hash_AFR{@ordenhap1[$i]}{@ordenhap2[$i]}+0;
	$EUR=$hash_EUR{@ordenhap1[$i]}{@ordenhap2[$i]}+0;
	$NAT=$hash_NAT{@ordenhap1[$i]}{@ordenhap2[$i]}+0;
	$EAS=$hash_EAS{@ordenhap1[$i]}{@ordenhap2[$i]}+0;
	print OT "@ordenhap1[$i]\t@ordenhap2[$i]\t$TOT\t$AFR\t$EUR\t$NAT\t$EAS\n";
	
}

print "Total number of pairs: $totalpairs\n";

