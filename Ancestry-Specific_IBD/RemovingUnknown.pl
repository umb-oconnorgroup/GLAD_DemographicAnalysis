#!usr/bin/perl
use Getopt::Long;
use Data::Dumper;

GetOptions (
	"input=s"=>\$input,
	"output=s"=>\$output,
	"help!"=>\$help,
)or die(showhelp());

if($input eq "" or $output eq ""){
	showhelp();						
}

open (IF1,"$input") or die ("We cannot find the order file\n");

$unknown=0;

open (OT, ">","$output.Unknownremoved.txt");

while(<IF1>){
	$line=$_;
	$line=~ s/\n//gi;
	$line=~ s/\r//gi;

	if($line =~ /\t-/){
		$unknown++;
	
	}else{
	
		print OT "$line\n";
	}
}
print "$unknown\n";

