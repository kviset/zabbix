#!/usr/bin/perl -w
#Template: Template App nginx
#Config:   conf.nix/nginx.conf
#Place:    /usr/lib/zabbix/agentscripts
#Depends:  aptitude install zabbix-sender       
#	   zsender.pl 0.3.7

require "/usr/lib/zabbix/zsender.pl";

my $VERSION = "0.0.0";
my $URL         = shift || "https://127.0.0.1/nginx-stats";
my $BIN		= shift || "nginx";

my %PARAM = (DEBUG => 0, NOSEND => 0);
my $PRESTR = "script.nginx.";
my @DATA = ();

push @DATA,[ "version", $VERSION ];

my $RESULT = zs_curl("$URL",{%PARAM});

$RESULT =~ /Active connections: (\d+) 
server accepts handled requests
 (\d+) (\d+) (\d+) 
Reading: (\d+) Writing: (\d+) Waiting: (\d+)/;

push @DATA,["active",$1];
push @DATA,["accepts",$2];
push @DATA,["handled",$3];
push @DATA,["requests",$4];
push @DATA,["reading",$5];
push @DATA,["writing",$6];
push @DATA,["waiting",$7];

#Get number of nginx process
push @DATA,["proc.num",zs_system("ps  -C nginx |tail -n +2 |wc -l",{%PARAM})];


print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});

