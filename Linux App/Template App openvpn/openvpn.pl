#!/usr/bin/perl -w
# Template: 	Template App OpenVPN server
#		Template App OpenVPN clients
# Depends: aptitude install libtime-parsedate-perl libnet-ldap-perl
#		zsender.pl versin 0.3.8
#use Data::Dump qw(dump);
use strict;
use Time::ParseDate;
use IO::Socket;
use Net::LDAP;

require "/usr/lib/zabbix/zsender.pl";
require "/usr/lib/zabbix/ovpnconf.pm";

my $MODE	= shift || "run";

my $VERSION	= "1.0.0";
my %PARAM 	= (DEBUG => 0, NOSEND => 0);
my $PRESTR 	= "script.openvpn";
my @DATA 	= ();

no warnings 'once';

sub m_run {
	push @DATA,["version",$VERSION];
	#Get data from openvpn managment interface
	my $SOCK = IO::Socket::INET->new(
		PeerAddr	=> $ovpnconf::OVPN_HOST,
		PeerPort	=> $ovpnconf::OVPN_MGMT_PORT,
		Proto		=> "tcp",
		Type		=> SOCK_STREAM
	) or die "ERROR: Can not open sock ''. $!\n";
	#Authentication
	my $RESULT = <$SOCK>;
	print $SOCK "$ovpnconf::OVPN_MGMT_PASSWORD\n";

	#get load-stats
	print $SOCK "load-stats\n";
	$RESULT = <$SOCK>; 
	$RESULT =~ s/\r\n/\n/g;
        zs_debug("--------------[RETURN load-stats]--------------",1,{%PARAM});
        zs_debug($RESULT,1,{%PARAM});
        zs_debug("-----------------------------------------------",1,{%PARAM});
	$RESULT =~ s/SUCCESS:\s//;
	my %STAT = split(/[=,]/,$RESULT);
	foreach my $KEY (keys %STAT) {
		push @DATA,[$KEY,$STAT{$KEY}];
	}

	#get status
	$RESULT="";
	print $SOCK "status\n";
	while(<$SOCK>){
		last if m/^END/gi;
		$RESULT = "$RESULT$_";
	}
	$RESULT =~ s/\r\n/\n/g;
	zs_debug("----------------[RETURN status]----------------",1,{%PARAM});
	zs_debug($RESULT,1,{%PARAM});
	zs_debug("-----------------------------------------------",1,{%PARAM});
	($RESULT) = ($RESULT =~ m/.*?\n.*?\n.*?\n(.*)\nROUTING TABLE/s);

	my @CLIENTS = split /\n/,$RESULT;
	foreach my $str (@CLIENTS){
		my @STATS_CLIENT = split /,/,$str;
		push @DATA,["realaddress",$STATS_CLIENT[1],$STATS_CLIENT[0]];
		push @DATA,["incomming",$STATS_CLIENT[2],$STATS_CLIENT[0]];
		push @DATA,["outbound",$STATS_CLIENT[3],$STATS_CLIENT[0]];
		my $uptime = time - parsedate($STATS_CLIENT[4]);
		push @DATA,["uptime",$uptime,$STATS_CLIENT[0]];
	}

	#Close connections
        print $SOCK "quit\n";
	close $SOCK;

	print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

sub m_discovery {
	my %AUTH;

	open(my $fh,'<',$ovpnconf::OVPN_AUTH_CONF) or die "ERROR: Can't open file '$ovpnconf::OVPN_AUTH_CONF'. $!";

	while( my $row = <$fh>){
		chomp $row;
		if($row =~ m/^(URL|BindDN|Password|BaseDN|SearchFilter)\s+(.*)$/){ $AUTH{$1} = $2; }
	}

	close $fh;

	my $ldap = Net::LDAP->new($AUTH{URL}) or die "ERROR: Can't open ldap sessions. $@";
	my $mesg = $ldap->bind("$AUTH{BindDN}",
				password => "$AUTH{Password}");

	$mesg->code && die "ERROR:", $mesg->error;

	$AUTH{BaseDN} =~ s/\"//g;
	$AUTH{SearchFilter} =~ s/\"//g;
	$AUTH{SearchFilter} =~ s/%u/*/g;

	$mesg = $ldap->search(
				base => "$AUTH{BaseDN}",
				filter => "$AUTH{SearchFilter}"
				);
	$mesg->code && die "ERROR:", $mesg->error;

	my @VPNLOGIN; 
	foreach my $entry ($mesg->entries) { 
		push @VPNLOGIN,$entry->get_value("sAMAccountName");
	}

	$ldap->unbind;

	print zs_discovery_arr("VPNLOGIN",\@VPNLOGIN,{%PARAM});
}

##################### MAIN #####################

if ($MODE eq "discovery") {
	m_discovery();
}else{
	m_run();
}

