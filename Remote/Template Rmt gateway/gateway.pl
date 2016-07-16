#!/usr/bin/perl -w
#Template: Template App Router 
#	   Template App Router node
#Config:   conf.nix/linux.conf
#Place:    /usr/lib/zabbix/agentscripts
#Depends:  aptitude install zabbix-sender       
#	   zsender.pl 0.3.3

require "/usr/lib/zabbix/zsender.pl";

my $MODE	= shift || "run";
my $INT		= shift || "eth0";	#gw interface
my $GWIP	= shift; 		#default GW IP for mode run

my $VERSION = "0.1.0";
my %PARAM = (DEBUG => 0, NOSEND => 0, EXEC_TIMEOUT => 10);

sub run {
	my $PRESTR = "script.gateway.";
	my @DATA = ();

	push @DATA,[ "version", $VERSION ];
	my $PUBLICIP = zs_curl("http://ipinfo.io/ip",{%PARAM});
	if($PUBLICIP =~ m/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/){
		push @DATA,[ "publicip", $PUBLICIP];
	}else{
		push @DATA,[ "publicip", "WARNING"];
	}
	push @DATA,[ "turnstate", zs_system("sudo ip link show dev $INT | grep DOWN| wc -l",{%PARAM})];

	if(defined $GWIP){
		my $MAC = zs_system("arp $GWIP | tail -n 1",{%PARAM});
		$MAC =~ s/.*\s+([\da-fA-F:]{17})\s+.*/$1/;
		push @DATA,["gwmac",$MAC];
	}

	return zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

sub turn {
	my $STATE = $_[0];

	if (defined $STATE){
		zs_debug("turn: \$STATE = $STATE",1,{%PARAM});
		if (($STATE == 0)){
			zs_debug("INFO: Gateway turn internet on",0,{%PARAM});
			zs_system("sudo ip link set dev $INT up",{%PARAM}) if ($PARAM{NOSEND} == 0);
		}else{
			zs_debug("INFO: Gateway turn internet off",0,{%PARAM});
			zs_system("sudo ip link set dev $INT down",{%PARAM}) if ($PARAM{NOSEND} == 0);
		}
	}else{
		zs_debug("turn: \$STATE = undef",1,{%PARAM});

		$STATE = zs_system("sudo ip link show dev $INT | grep DOWN| wc -l",{%PARAM});
		zs_debug("INFO: Current interface turn state: $STATE",0,{%PARAM});
		return turn($STATE == 0);		
	}
	
	return;
}

if ($MODE eq "run") {
	print run();
}elsif($MODE eq "turn"){
	print turn();
}

