#!/usr/bin/perl -w
#Template:      Template App Snort
#Config:        conf.nix/snort.conf
#Place:         /usr/lib/zabbix/agentscipts
#Depends:       aptitude install zabbix-sender

use Time::HiRes qw(time);
use Sys::Syslog;
require "/usr/lib/zabbix/snortconf.pm";
require "/usr/lib/zabbix/zsender.pl";

my $VERSION = "1.4.0";
my $MODE    = shift || "run";
my $LOG     = shift || undef;

my %PARAM = (DEBUG => 0, NOSEND => 0);
my $PRESTR = "script.snort";
my @DATA = ();

my %NAMES = (
	"pkt_drop_percent"		=> 1,
        "wire_mbits_per_sec.realtime"	=> 2,
        "alerts_per_second"		=> 3,
	"kpackets_wire_per_sec.realtime"=> 4,
        "avg_bytes_per_wire_packet"	=> 5,
        "patmatch_percent"		=> 6,
        "syns_per_second"		=> 7,
        "synacks_per_second"		=> 8,
        "new_sessions_per_second"	=> 9,
        "deleted_sessions_per_second"	=> 10,
        "total_sessions"		=> 11,
        "max_sessions"			=> 12,
	"pkt_stats.pkts_recv"		=> 45,
	"pkt_stats.pkts_drop"		=> 46,
	"total_blocked_verdicts"	=> 47
	);


sub m_send {

	push @DATA,["version",$VERSION];
	push @DATA,["barnyard2.proc",zs_system("ps -C barnyard2 --no-headers |wc -l",{%PARAM})];
	push @DATA,["snort.proc",zs_system("ps -C snort --no-headers |wc -l",{%PARAM})];
	push @DATA,["instance",($#snortconf::INSTNAME+1)];

	my @VALUES = (0) x 131;

	no warnings 'once';
	foreach $FILE (@snortconf::STATS){
		my $RESULT = zs_system("tail -n 1 $FILE && echo > $FILE",{%PARAM});

		if ((defined $RESULT)){
			my @TMP = split /,/,$RESULT;
			if($#TMP > 0){
				$PARAM{POLLING_TIME} = $TMP[0];
				@VALUES = map {$VALUES[$_] + $TMP[$_]} 0 .. $#VALUES;
			}
		}
	}

	while( my ($key,$value) = each %NAMES) {push @DATA,["$key",$VALUES[$value]];}

	print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

sub m_update {
	my $TIME = time;
	#Update config
	no warnings 'once';
	for(my $I = 0; $I <= $#snortconf::INSTNAME; $I++){
		zs_debug("INFO: Update '$snortconf::INSTNAME[$I]' configuration",0,{%PARAM});
		foreach $FILE (@snortconf::UPDATEFILES){
			no warnings 'once';
			zs_debug("INFO: Load '$snortconf::UPDATESRC[$I]/$FILE' => '$snortconf::UPDATEDST[$I]/$FILE'",2,{%PARAM});
			zs_system("wget $snortconf::UPDATESRC[$I]/$FILE -O $snortconf::UPDATEDST[$I]$FILE",{%PARAM})
		}

		zs_debug("INFO: Update '$snortconf::INSTNAME[$I]' rules",0,{%PARAM});
		my $RESULT = zs_system("$snortconf::UPDATERULE[$I]",{%PARAM});
		if ($RESULT =~ m/\tNew:\-+(\d+)/m)           {push @DATA,["rules.new[$snortconf::INSTNAME[$I]]",$1];}
		if ($RESULT =~ m/\tDeleted:\-+(\d+)/m)       {push @DATA,["rules.deleted[$snortconf::INSTNAME[$I]]",$1];}
		if ($RESULT =~ m/\tEnabled Rules:\-+(\d+)/m) {push @DATA,["rules.enabled[$snortconf::INSTNAME[$I]]",$1];}
		if ($RESULT =~ m/\tDropped Rules:\-+(\d+)/m) {push @DATA,["rules.dropped[$snortconf::INSTNAME[$I]]",$1];}
		if ($RESULT =~ m/\tDisabled Rules:\-+(\d+)/m){push @DATA,["rules.disabled[$snortconf::INSTNAME[$I]]",$1];}
		if ($RESULT =~ m/\tTotal Rules:\-+(\d+)/m)   {push @DATA,["rules.total[$snortconf::INSTNAME[$I]]",$1];}
	}

	push @DATA,["updatetime",(time - $TIME)];

	$TIME = time;
	for(my $I = 0; $I <= $#snortconf::INSTNAME; $I++){
		zs_debug("INFO: Restart '$snortconf::INSTNAME[$I]'",0,{%PARAM});
		zs_system("$snortconf::RESTART[$I]",{%PARAM});
	}
	
	push @DATA,["restarttime",(time - $TIME)];

	print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

sub m_discovery {
	no warnings 'once';
	print zs_discovery_arr("INSTANCE",\@snortconf::INSTNAME,{%PARAM});
}

################ MAIN ################

if (defined $LOG) { $PARAM{LOGNAME} = "snort.pl"; }

if( $MODE eq "update" ){
        m_update();
}elsif( $MODE eq "discovery" ){
	m_discovery();
}else{
        m_send();
}

