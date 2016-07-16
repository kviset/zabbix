#!/usr/bin/perl -w
#Template:      Template App Suricata
#Config:        conf.nix/suricata.conf
#Place:         /usr/lib/zabbix/agentscipts
#Depends:       aptitude install zabbix-sender


require "/usr/lib/zabbix/zsender.pl";

my $SURICATA_STATS      = shift || "/var/log/suricata/stats.log";

my $VERSION = "1.0.1";
my %PARAM = (DEBUG => 0, NOSEND => 0);
my $PRESTR = "script.suricata";
my @DATA = ();


push @DATA,["version",$VERSION];

my $RESULT = zs_system("tail -n 61  $SURICATA_STATS && echo > $SURICATA_STATS",{%PARAM});

if (defined $RESULT ){
	foreach $str (split /\n/,$RESULT){
	        my @CELL = split /\|/, $str;
	        for (@CELL){ s/\s+//g; }
		push @DATA,[$CELL[0],$CELL[2]];
	}
}

push @DATA,["barnyard2.proc",zs_system("ps -C barnyard2 --no-headers |wc -l",{%PARAM})];
push @DATA,["suricata.proc",zs_system("ps -C Suricata-Main --no-headers |wc -l",{%PARAM})];

print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
