#!/usr/bin/perl -w
#Template:      Template App Apache2
#Config:        conf.nix/apache.conf
#Place:         /usr/lib/zabbix/agentscipts
#Depends:       aptitude install curl
#               zsender.pl version 0.1.2 or high

require "/usr/lib/zabbix/zsender.pl";

#defaults
my $VERSION	= "1.0.5";
my $URL		= shift || "http://127.0.0.1/server-status"; $URL = "$URL?auto";
my $EXEC_TIMEOUT= 2;

my %PARAM = (DEBUG => 0);
my $PRESTR = "script.apache.";
my @DATA = ();

my @METRICKS = (
	"accesses",
	"kbytes",
	"cpuload",
	"uptime",
	"reqpersec",
	"bytesperreq",
	"bytespersec",
	"busyworkers",
	"idleworkers"
	);

push @DATA, ["version", $VERSION];

my $RESULT = zs_curl("$URL",{%PARAM});

if(defined $RESULT){
	foreach $METRICK (@METRICKS){
		my ($VALUE) = ($RESULT =~ /$METRICK:(.*)$/im);
		if (defined $VALUE){
			$VALUE =~ s/\s+//g;
			push @DATA,[$METRICK,$VALUE];	
		}
	}

	my ($VALUE) = ($RESULT =~ /Scoreboard:(.*)$/im);
	$VALUE =~ s/\s+//g;
	push @DATA,["totalslots",length $VALUE];
}else{
	print "[ERROR] Could not get '$URL'\n";
}

#Get number of apache2 process
push @DATA,["proc.num",zs_system("ps  -C apache2 |tail -n +2 |wc -l",{%PARAM})];

#Get file size
push @DATA,["log.error.size",-s "/var/log/apache2/error.log"];
push @DATA,["log.access.size",-s "/var/log/apache2/access.log"];

$RESULT = zs_zsender_arr($PRESTR,\@DATA,{%PARAM});

print "$RESULT\n";

