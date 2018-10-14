#!/usr/bin/perl
use Spreadsheet::ParseExcel;
use File::Path;
use File::Copy;
use Sys::Hostname;
use Cwd;
sub readvCenterDetails($);

readvCenterDetails('Asset_Report.xls');

################################################################################
# Reading Excel file here and get data from each tab
################################################################################

####### Reading the Excel file	
sub readvCenterDetails($) {
	$vCenterInputFile = shift;
	
	print "Here : $vCenterInputFile \n";
	
	my $e = new Spreadsheet::ParseExcel;
	my $eBook = $e->Parse(${vCenterInputFile});
	
	my $sheets = $eBook->{SheetCount};
	my ($eSheet, $sheetName);

	foreach my $sheet (0 .. $sheets - 1) {
		$eSheet = $eBook->{Worksheet}[$sheet];
		$sheetName = $eSheet->{Name};
		next if("$sheetName" ne "Virtual Machines");
		print scalar(localtime) . "Processing $sheetName from $vCenterInputFile  :- \n";
		#print "Working on $vCenterName : Worksheet $sheet: $sheetName\n";
		next unless (exists ($eSheet->{MaxRow}) and (exists ($eSheet->{MaxCol})));
		
		foreach my $row ($eSheet->{MinRow} .. $eSheet->{MaxRow}) {
		   foreach my $column ($eSheet->{MinCol} .. $eSheet->{MaxCol}) {
			   next unless (defined $eSheet->{Cells}[$row][$column]);
			   print $eSheet->{Cells}[$row][$column]->Value . ",";
			}
			print "\n";
		}
    }
	#$eBook->close();
			

return;
}