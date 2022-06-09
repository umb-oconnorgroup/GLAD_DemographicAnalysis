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

open (IF2,"$ibd") or die ("We cannot find the ibd file\n");

open (OT, ">","$output.same_ancestry_filtered.txt");

$unknown=0;

while(<IF2>){
	$line=$_;
	$line=~ s/\n//gi;
        $line=~ s/\r//gi;
	@line_ibd=split(/\s+/,$line);
	if(@line_ibd[10] eq @line_ibd[11]){
		print OT "@line_ibd[0]\t@line_ibd[1]\t@line_ibd[2]\t@line_ibd[3]\t@line_ibd[4]\t@line_ibd[5]\t@line_ibd[6]\t@line_ibd[7]\t@line_ibd[8]\t@line_ibd[9]\t@line_ibd[10]\t@line_ibd[11]\n";
		
	}else{
		$unknown++;			
	}

}

print "$unknown\n";

