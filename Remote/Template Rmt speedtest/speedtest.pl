#!/usr/bin/perl -w
#Template: Template Rmt speedtest
#Config:   speedtest.conf
#Place:    /usr/lib/zabbix/agentscripts
#Depends:  aptitude install speedtest-cli       

use Sys::Syslog;
use Time::HiRes qw(time);

require "/usr/lib/zabbix/zsender.pl";

my $MODE	= shift || "run";
my $SRVREX      = shift || "4358_5029_6386";

my $VERSION	= "0.2.0";
my %PARAM 	= (DEBUG => 1, NOSEND => 0, LOGNAME => "speedtest.pl");
my $PRESTR 	= "script.speedtest";
my @DATA 	= ();

my $TICK = time;

my @SRV = split /_/, $SRVREX;

sub m_run {
	zs_debug("Running...",1,{%PARAM});

	push @DATA,["version",$VERSION];

	foreach $SERVER (@SRV){
		my $RESULT = zs_system("speedtest-cli --server $SERVER",{%PARAM});
		if(defined $RESULT){
			zs_debug("$SERVER:".$RESULT,1,{%PARAM});

			if ($RESULT =~ /Hosted by .*: ([0-9|\.]+) ms/m) {push @DATA,["ping[$SERVER]",$1];}
			if ($RESULT =~ /Download: ([0-9|\.]+) Mbits\/s/m){push @DATA,["download[$SERVER]",$1];}
			if ($RESULT =~ /Upload: ([0-9|\.]+) Mbits\/s/m)	{push @DATA,["upload[$SERVER]",$1];}
		}else{
			zs_debug("ERROR:Could not get result from speedtest",0,{%PARAM});
		}
	}

	push @DATA,["measurement", time - $TICK];

	#Send data
	my $RESULT = zs_zsender_arr($PRESTR,\@DATA,{%PARAM});

	zs_debug("zsender.pl: ".$RESULT,1,{%PARAM});
	zs_debug("Finished.",1,{%PARAM});
}

sub m_discovery {
	my @VARNAME = ("ID","NAME");
	my @VALUE;

	$SRVREX =~ s/_/\\)\|\^\\s\*/g;
	$SRVREX =~ s/^/\^\\s\*/;
	$SRVREX =~ s/$/\\)/;

	my $RESULT = zs_system("speedtest-cli --list | grep -E '$SRVREX'",{%PARAM});
	if(defined $RESULT){
		foreach $SRVID (@SRV){
			if ($RESULT =~ m/\s*$SRVID\)\s+(.*)\s+\[/){
				push @VALUE,[$SRVID,$1];
			}
		}
		print zs_discovery_2darr(\@VARNAME,\@VALUE,{%PARAM});
	}else{
		zs_debug("ERROR:Could not get result from speedtest",0,{%PARAM});
	}
}

####################### MAIN #######################

if ( $MODE eq "discovery"){
	m_discovery();
}else{
	m_run();
}

