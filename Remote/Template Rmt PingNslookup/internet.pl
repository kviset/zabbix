#!/usr/bin/perl -w
#Template: Template App internet
#Config:   conf.nix/internet.conf
#Place:    /usr/lib/zabbix/agentscripts
#Depends:  aptitude install fping libnet-nslookup-perl
#          zsender.pl 0.3.3

#use Data::Dump qw(dump);
use Time::HiRes qw(time);
use Net::Nslookup;

require "/usr/lib/zabbix/zsender.pl";

my $VERSION		= "0.2.1";
my $ZABBIX_HOSTNAME     = shift ;
my $PINGLST  		= shift || "8.8.8.8_98.137.236.150_213.180.204.3";
my $NSLKPLST 		= shift || "google.com_yahoo.com_ya.ru";
my $MODE     		= shift || "run";
my $SIZE		= shift || undef;

my %PARAM = (DEBUG => 0,NOSEND => 0);
my $PRESTR = "script.internet";
my @DATA = ();

sub run {
	my @PING  = @{$_[0]};
	my @NSLKP = @{$_[1]};

	push @DATA,["version",$VERSION];

	foreach $SERVER (@PING){
		my $CMD = "/usr/bin/fping -C 1 $SERVER";
		if ( defined $SIZE) { $CMD=$CMD." -b $SIZE"; }
		my $RESULT = zs_system("sudo $CMD 2>&1|tail -n1",{%PARAM});
		my $TIME = 0;
	        if($RESULT =~ /.*: ([0-9|\.]+)\n/m){
			$TIME = $1/1000;
		};

		push @DATA,["ping[$SERVER]",$TIME];
	}
	foreach $SERVER (@NSLKP){
		my $TICK = time;
		my $RESULT = nslookup $SERVER;
		$TICK = (time - $TICK);
		
		if( defined $RESULT ){
			push @DATA,["nslookup[$SERVER]",$TICK];
		}else{
			push @DATA,["nslookup[$SERVER]",0];
		}
	}

	#Send data
	return zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

sub discovery {
	my @ADDR = @{shift()};

	return zs_discovery_arr("ADDR",\@ADDR,{%PARAM});
}

###################### MAIN #######################

if (defined $ZABBIX_HOSTNAME) { $PARAM{'ZABBIX_HOSTNAME'}=$ZABBIX_HOSTNAME;}

my @PING = split /_/,$PINGLST;
my @NSLKP = split /_/,$NSLKPLST;

my $RESULT = "WARNING: Nothing return\n";

if ($MODE eq "dsr_ping"){
	$RESULT = discovery(\@PING);
}elsif($MODE eq "dsr_nslookup"){
	$RESULT = discovery(\@NSLKP);
}else{
	$RESULT = run(\@PING,\@NSLKP);
}

print $RESULT;


