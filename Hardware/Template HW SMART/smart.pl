#!/usr/bin/perl -w
#Template: Template App SMART
#Config:   conf.nix/smart.conf
#Place:    /usr/lib/zabbix/agentscripts
#Depends:  aptitude install smartmontools
#          zsender.pl 0.3.3

use Data::Dump qw(dump);

require "/usr/lib/zabbix/zsender.pl";

my $VERSION		= "1.0.0";
my $MODE     		= shift || "run";

my %PARAM = (DEBUG => 0,NOSEND => 0);
my $PRESTR = "script.smart";
my @DATA = ();

my @INFO = (
	"Model Family",
	"Device Model",
	"Serial Number",
	"Firmware Version",
	"User Capacity",
	"Sector Size",
	"Rotation Rate"
	);

my @ATTRID = ( 1,3,4,5,7,9,10,11,12,192,193,194,196,197,198,199,200 );

sub get_disk {
        opendir(my $dh, "/dev") or die "ERROR: can't opendir '/dev': $!\n";
        my @DISK = grep {-b "/dev/$_" && /^([hs]d[a-z])$/} readdir($dh);
        closedir $dh;

	return @DISK;
}

sub run {

	push @DATA,["version", $VERSION];

	my @DISKS = get_disk();

	foreach $DISK (@DISKS){
	
		my $RESULT = zs_system("sudo smartctl -A -H -i  /dev/$DISK",{%PARAM});

		my ($gINFO)  = $RESULT =~ /=== START OF INFORMATION SECTION ===\n(.*?)\n\n/s;
		my ($gHEALTH)= $RESULT =~ /=== START OF READ SMART DATA SECTION ===\n(.*?)\n\n/s;
		my ($gATTR)  = $RESULT =~ /ID#.*?\n(.*?)\n\n/s;

		#Parse smart.info
		foreach $aINFO (@INFO){
			if($gINFO =~ m/$aINFO\w?:\s+(.*)\n?/){
				my $VALUE = $1;
				$aINFO =~ s/ /_/g; $aINFO =~ s/([A-Z])/\L$1/g;
				push @DATA,["info[$DISK,$aINFO]",$VALUE];
			}
		}

		#Parse smart.health
		if($gHEALTH =~ m/SMART overall-health self-assessment test result:\s+(.*)\n?/){
			push @DATA,["attr[$DISK,test_result]",$1];
		}

		#Parse smart.attr
		foreach $ID (@ATTRID){
			#ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
			#  1 Raw_Read_Error_Rate     0x002f   115   100   006    Pre-fail  Always       -       98764784
			if ($gATTR =~ m/\s{0,3}$ID\s+\w+\s+0x[0-9|a-f]{4}\s+0{0,2}(\d{1,3})\s+0{0,2}(\d{1,3})\s+0{0,2}(\d{1,3})\s+.+?(\d+)/){
				push @DATA,["attr[$DISK,$ID,value]",$1];
				push @DATA,["attr[$DISK,$ID,worst]",$2];
				push @DATA,["attr[$DISK,$ID,thresh]",$3];
				push @DATA,["attr[$DISK,$ID,raw_value]",$4];
			}
		}
	}

	#Send data
	return zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

sub discovery {

        #Collect disk file
        my @DISK = get_disk();

        return zs_discovery_arr("DEVNAME",\@DISK,{%PARAM});
}

###################### MAIN #######################

if ($MODE eq "discovery"){
	$RESULT = discovery();
}else{
	$RESULT = run();
}

print $RESULT;
