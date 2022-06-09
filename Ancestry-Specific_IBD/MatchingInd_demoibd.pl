#!usr/bin/perl
use Getopt::Long;
use Data::Dumper;

GetOptions (
	"demo=s"=>\$demo,
	"ibd=s"=>\$ibd,
	"output=s"=>\$output,
	"help!"=>\$help,
)or die(showhelp());

if($demo eq "" or $ibd eq "" or $output eq ""){
	showhelp();						
}

open (IF1,"$demo") or die ("We cannot find the demo file\n");
@demograph=<IF1>;
chomp(@demograph);

$unknown=0;

foreach $i(0..$#demograph){
	@line_demo=split(/\s+/,$demograph[$i]);
	$hash_ID{$line_demo[0]}=$i;
}

open (IF2,"$ibd") or die ("We cannot find the ibd file\n");

open (OT, ">","$output.Demofiltered.txt");

while(<IF2>){
	$line=$_;
	$line=~ s/\n//gi;
	$line=~ s/\r//gi;
	@line_ibd=split(/\s+/,$line);

	if(exists($hash_ID{@line_ibd[0]}) && exists($hash_ID{@line_ibd[2]})){
		#print "@line_ibd\n";			
		print OT "@line_ibd[0]\t@line_ibd[1]\t@line_ibd[2]\t@line_ibd[3]\t@line_ibd[4]\t@line_ibd[5]\t@line_ibd[6]\t@line_ibd[7]\t@line_ibd[8]\t@line_ibd[9]\t@line_ibd[10]\t@line_ibd[11]\t@line_ibd[12]\n";
	}else{
		$unknown++;			
	}
}

print "$unknown\n";
