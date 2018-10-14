#!/usr/bin/perl
use Spreadsheet::ParseXLSX;
use File::Path;
use File::Copy;
use Sys::Hostname;
use Cwd;
sub readvCenterDetails($);
sub trimString($);

%Data = ();
@Apps = ('ART', 'PQR');
readvCenterDetails('Asset_Report.xlsx');

## printing values
###Go through Sys IDs list and print respective values
foreach $SYSID (@Apps) {
	print "Working on Sys-ID = $SYSID \n";
	$ProdServerCount = $QAServerCount = $ProdOSValues = $QAOSValues = 0;
	$envValue = "Prod";
	$ProdServerCount = $Data{"${SYSID}#${envValue}#Count"} if(defined($Data{"${SYSID}#${envValue}#Count"}));
	$ProdOSValues = $Data{"${SYSID}#${envValue}#OSValues"} if (defined($Data{"${SYSID}#${envValue}#OSValues"}));
	
	
	
	$envValue = "QA";
	$QAServerCount = $Data{"${SYSID}#${envValue}#Count"} if(defined($Data{"${SYSID}#${envValue}#Count"}));
	$QAOSValues = $Data{"${SYSID}#${envValue}#OSValues"} if (defined($Data{"${SYSID}#${envValue}#OSValues"}));
	
	print "Total Production Servers : $ProdServerCount \n";
	print "Production Servers OS's : $ProdOSValues \n";
	@ProdOSVals = split(/#/, $ProdOSValues);
	@POSVals = do { my %seen; grep { !$seen{$_}++ } @ProdOSVals };
	foreach $POsValue (@POSVals) {
		$ver = $Data{"${SYSID}#Prod#${POsValue}#Versions"};
		print "$POsValue   --> $ver \n";
		@array = split(/#/, $ver);
		my ( $temp, $count ) = ( "@array", 0 );
		( $count = $temp =~ s/($_)//g ) and printf "\t\t%s \(%d\)\n", $_ ,$count for @array;
	}
	

	print "Total QA Servers : $QAServerCount \n";
	print "QA Servers OS's : $QAOSValues \n";
	@QAOSVals = split(/#/, $QAOSValues);
	@QOSVals = do { my %seen; grep { !$seen{$_}++ } @QAOSVals };
	foreach $QOsValue (@QOSVals) {
		$ver = $Data{"${SYSID}#QA#${QOsValue}#Versions"};
		print "$QOsValue --> $ver \n";
		@array = split(/#/, $ver);
		my ( $temp, $count ) = ( "@array", 0 );
		( $count = $temp =~ s/($_)//g ) and printf "\t\t%s \(%d\)\n", $_ ,$count for @array;
	}
	print "\n -------------------- \n";
}

################################################################################
# Reading Excel file here and get data from each tab
################################################################################

####### Reading the Excel file	
sub readvCenterDetails($) {
	$vCenterInputFile = shift;
	
	my $parser = Spreadsheet::ParseXLSX->new;
	my $workbook = $parser->parse(${vCenterInputFile});
	
	if ( !defined $workbook ) {
		die $parser->error(), ".\n";
	}
	
	my $sheets = $workbook->{SheetCount};
	my ($eSheet, $sheetName);

	foreach my $sheet (0 .. $sheets - 1) {
		$eSheet = $workbook->{Worksheet}[$sheet];
		$sheetName = $eSheet->{Name};
		next if("$sheetName" ne "Raw Data");
		
		print scalar(localtime) . "Working on Worksheet $sheet: $sheetName\n";
		next unless (exists ($eSheet->{MaxRow}) and (exists ($eSheet->{MaxCol})));
		
		### Reading Header Columns Now
		$headerRow = $eSheet->{MinRow};
		$sysIDCol = $serverCol = $envCol = $OSCol = $OSVerCol = $mdwCol = $mdwVerCol = -1;
		foreach my $column ($eSheet->{MinCol} .. $eSheet->{MaxCol}) {
		   next unless (defined $eSheet->{Cells}[$headerRow][$column]);
		   $value = $eSheet->{Cells}[$headerRow][$column]->Value;
		   $value = trimString($value);
		   $sysIDCol = $column if ($value eq "application");
		   $serverCol = $column if ($value eq "component");
		   $envCol = $column if ($value eq "environment");
		   $OSCol = $column if ($value eq "serveroperatingsystem");
		   $OSVerCol = $column if ($value eq "serverosversion");
		   $mdwCol = $column if ($value eq "numbercpus");
		   $mdwVerCol = $column if ($value eq "#ethernetports");
		}
		
		if ($sysIDCol == -1 or  $serverCol == -1 or $envCol == -1 or $OSCol == -1 or $OSVerCol == -1 or $mdwCol == -1 or $mdwVerCol == -1) {
			print "Error : Not all fields are in the table. Check for proper Header Names \n";
		}
		print "Header Fields are  : $sysIDCol = $serverCol = $envCol = $OSCol = $OSVerCol = $mdwCol = $mdwVerCol  \n";
		
		### Reading Each record Now and assigning the hash map
		foreach my $row ($eSheet->{MinRow}+1 .. $eSheet->{MaxRow}) {
			$sysIDValue = $serverValue = $envValue = $OSValue = $OSVerValue = $mdwValue = $mdwVerValue = $newOSValue = $newmdwValue = "XXXX";
			
			$sysIDValue = $eSheet->{Cells}[$row][$sysIDCol]->Value if (defined $eSheet->{Cells}[$row][$sysIDCol]);
			$serverValue = $eSheet->{Cells}[$row][$serverCol]->Value if (defined $eSheet->{Cells}[$row][$serverCol]);
			$envValue = $eSheet->{Cells}[$row][$envCol]->Value if (defined $eSheet->{Cells}[$row][$envCol]);
			$OSValue = $eSheet->{Cells}[$row][$OSCol]->Value if (defined $eSheet->{Cells}[$row][$OSCol]);
			$OSVerValue = $eSheet->{Cells}[$row][$OSVerCol]->Value if (defined $eSheet->{Cells}[$row][$OSVerCol]);
			$mdwValue = $eSheet->{Cells}[$row][$mdwCol]->Value if (defined $eSheet->{Cells}[$row][$mdwCol]);
			$mdwVerValue = $eSheet->{Cells}[$row][$mdwVerCol]->Value if (defined $eSheet->{Cells}[$row][$mdwVerCol]);
			
			$sysIDValue = uc $sysIDValue;
			$envValue = "Prod" if ($envValue =~ /prod/i);
			$envValue = "QA" if ($envValue =~ /QA/i);
			
			$newOSValue = "Win" if ($OSValue =~ /Win/i);
			$newOSValue = "Lin" if (($OSValue =~ /Lin/i) || ($OSValue =~ /Suse/i) || ($OSValue =~ /Ubuntu/i));
			$newOSValue = "Win-2012" if ($OSValue =~ /2012/);
			$newOSValue = "Win-2008" if ($OSValue =~ /2008/);
			$newOSValue = "Win-7" if ($OSValue =~ /7/);
			$newOSValue = "Win-2016" if ($OSValue =~ /2016/);
			$newOSValue = "Win-Other" if ($OSValue =~ /Other/i);
			
			$newOSValue = "Lin-6" if ($OSValue =~ /6/);
			$newOSValue = "Lin-5" if ($OSValue =~ /5/);
			$newOSValue = "Lin-7" if ($OSValue =~ /7/);
			$newOSValue = "Lin-10" if ($OSValue =~ /10/);
			$newOSValue = "Lin-11" if ($OSValue =~ /11/);
			
			print " --- $OSValue  --- $newOSValue\n";

			$Data{"${sysIDValue}#${envValue}#Count"} += 1;
			
			if (defined($Data{"${sysIDValue}#${envValue}#OSValues"})) {
				$Data{"${sysIDValue}#${envValue}#OSValues"} = $Data{"${sysIDValue}#${envValue}#OSValues"} . "#" . $newOSValue;
			} else {
				$Data{"${sysIDValue}#${envValue}#OSValues"} = $newOSValue;
			}
			if (defined($Data{"${sysIDValue}#${envValue}#${newOSValue}#Versions"})) {
				$Data{"${sysIDValue}#${envValue}#${newOSValue}#Versions"} = $Data{"${sysIDValue}#${envValue}#${newOSValue}#Versions"} . "#" . $OSVerValue;
			} else {
				$Data{"${sysIDValue}#${envValue}#${newOSValue}#Versions"} = $OSVerValue;
			}
			
			if (defined($Data{"${sysIDValue}#${envValue}#${newmdwValue}"})) {
				$Data{"${sysIDValue}#${envValue}#${newmdwValue}"} = $Data{"${sysIDValue}#${envValue}#${newmdwValue}"} . "#" . $mdwVerValue;
			} else {
				$Data{"${sysIDValue}#${envValue}#${newmdwValue}"} = $mdwVerValue;
			}
			

		   # foreach my $column ($eSheet->{MinCol} .. $eSheet->{MaxCol}) {
			   # next unless (defined $eSheet->{Cells}[$row][$column]);
			   # print $eSheet->{Cells}[$row][$column]->Value . ",";
			# }
			#print "\n";
		}
    }
	#$workbook->close();
	
	# while (my ($key,$value)=each %Data){
		# if ($key =~ /ART#/) {
			
		# print "$k $v\n"
		# }
	# }
	

return;
}


###############################################################################
# trimString function to trim unnecessary spaces and characters in a string 
###############################################################################
sub trimString($)
{
    $string = shift;
    return "" if (!defined($string));
    $string =~ s/\[Null\]//g;
    $string =~ s/\s+//g;
    $string =~ s/\"//g;
    $string =~ s/\,//g;
    $string = lc $string;
    return $string
}

