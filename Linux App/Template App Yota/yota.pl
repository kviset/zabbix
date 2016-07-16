#!/usr/bin/perl -w
#Template: Template App yota
#Config:   conf.nix/yota.conf
#Place:    /usr/lib/zabbix/agentscripts
#Depends:  aptitude install zabbix-sender       
#	   zsender.pl 0.3.5

#use Data::Dump qw(dump);

require "/usr/lib/zabbix/zsender.pl";

my $VERSION		= "0.0.4";
my $INTERFACE		= shift || undef;
my $ZABBIX_HOSTNAME     = shift || undef;

my %PARAM = (DEBUG => 0, NOSEND => 0);
my $PRESTR = "script.yota";
my @DATA = ();

my @VALUES = (
"InterfaceType",
"3GPP.IMSI",
"3GPP.UICC-ID",
"3GPP.IMEI",
"3GPP.IMEISV",
"DeviceName",
"RfVersion",
"AsicVersion",
"FirmwareVersion",
"State",
"3GPP.SINR",
"3GPP.RSSI",
"3GPP.RSRP",
"3GPP.RSRQ",
"3GPP.CGI",
"3GPP.CenterFreq",
"3GPP.TxPWR",
"3GPP.SPN",
"3GPP.IsIdle",
"ConnectedTime",
"SentBytes",
"ReceivedBytes",
"TotalHandoversCount",
"SucceededHandoversCount"
);

if (defined $ZABBIX_HOSTNAME) { $PARAM{'ZABBIX_HOSTNAME'}=$ZABBIX_HOSTNAME;}

push @DATA,["version",$VERSION];

#GET values from yota modem
my $RESULT = zs_curl('http://10.0.0.1/cgi-bin/sysconf.cgi?page=ajax.asp&action=get_status',{%PARAM});
if(defined $RESULT){
	foreach $VALUE (@VALUES){

		my ($GET) = ($RESULT =~ /$VALUE=(.*?)\n/);

		if (($GET =~ m/\s/) or ($GET eq '')){$GET = "\"$GET\"";}

		push @DATA,["$VALUE",$GET];
	}
}

#GET ping
my $CMD = "/usr/bin/fping -C 1";
if (defined $INTERFACE) { $CMD = $CMD." -I $INTERFACE"}
$RESULT = zs_system("sudo $CMD 10.0.0.1 2>&1|tail -n1",{%PARAM});
my $TIME = 0;
if($RESULT =~ /.*: ([0-9|\.]+)\n/m){$TIME = $1/1000;};

push @DATA,["ping[10.0.0.1]",$TIME];

print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});

