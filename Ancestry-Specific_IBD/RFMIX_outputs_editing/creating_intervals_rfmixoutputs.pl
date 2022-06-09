#!usr/bin/perl


use Getopt::Long;
use Data::Dumper;

GetOptions (
	"bim=s"=>\$bim,
	"index=s"=>\$index,
	"output=s"=>\$output,
	"help!"=>\$help,
)or die(showhelp());

if($bim eq "" or $index eq "" or $output eq ""){	
	showhelp();
}



open (IF1,"$bim") or die ("We cannot find the $bim file\n");
open (IF2,"$index")or die ("We cannot find the $index file\n");
open (OT, ">","$output");

@bimcoords=<IF1>;
@fbindex=<IF2>;
chomp(@bimcoords,@fbindex);

foreach $i(0..$#bimcoords){
	@line_bim=split("\t",@bimcoords[$i]);
	$hash_P{$i}=@line_bim[3];
	$hash_G{$i}=@line_bim[2];
}

print OT "#Subpopulation order/codes: AFR=0	EAS=1	EUR=2	NAT=3 \n#chm\tspos\tepos\tsgpos\tegpos\n";

foreach $j(0..$#fbindex){
	if ($j eq $#fbindex){
	@line_fb=split("\t",@fbindex[$j]);
	$end=$#bimcoords;
	print $end;
	print OT "@line_fb[0]\t@line_fb[1]\t$hash_P{$end}\t@line_fb[2]\t$hash_G{$end}\n";

	}else{
	@line_fb=split("\t",@fbindex[$j]);
	$end=@line_fb[3]+4;
	print OT "@line_fb[0]\t@line_fb[1]\t$hash_P{$end}\t@line_fb[2]\t$hash_G{$end}\n";
	}

}

sub showhelp(){

  print "\n";
  print "=================================================================================\n";
  print "**										**\n";
  print "**										**\n";
  print "** Options:									**\n";
  print "**										**\n";
  print "**	-bim		bim file with physical positions 			**\n";
  print "**	-index		fours columns of fb file with the snp index		**\n";
  print "**	-output					output name			**\n";
  print "**	-h					show help			**\n";
  print "**										**\n";
  print "=================================================================================\n";
  die("\n");
} 

