#!/usr/bin/perl -w
#Template: Template App MD RAID
#Place:    /usr/lib/zabbix/agentscripts
use Data::Dump qw(dump);
require "/usr/lib/zabbix/zsender.pl";

my $MODE        = shift || "run";

my $VERSION 	= "0.0.0";
my %PARAM = (DEBUG => 0, NOSEND => 0);
my $PRESTR = "script.md.";
my @DATA = ();

sub get_mddev {
        my $RETURN = zs_system("find /sys/block -name \"md*\" -printf \"%f;\"",{%PARAM});

        my @MDDEV = split/;/,$RETURN;

	return @MDDEV;
}


sub m_discovery {
	my @MDDEV = get_mddev;

	print zs_discovery_arr("MDNAME",\@MDDEV,{%PARAM});
}

sub m_run {
	my @MDDEV = get_mddev;

	push @DATA,["version",$VERSION];

	foreach my $md (@MDDEV){
		push @DATA,["sync_action[$md]",zs_system("cat /sys/block/$md/md/sync_action",{%PARAM})];
		push @DATA,["raid_disks[$md]",zs_system("cat /sys/block/$md/md/raid_disks",{%PARAM})];
		push @DATA,["degraded[$md]",zs_system("cat /sys/block/$md/md/degraded",{%PARAM})]
	}

	my $RESULT = zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
	print $RESULT;
}

if( $MODE eq "discovery"){
	m_discovery();
}else{
	m_run();
}

