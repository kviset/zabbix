#!/usr/bin/perl -w
#Template: Template App ejabber
#Place:    /usr/lib/zabbix/agentscripts

require "/usr/lib/zabbix/zsender.pl";

my $MODE = shift || "run";

my $VERSION = "0.0.0";
my %PARAM = (DEBUG => 1, NOSEND => 0);
my $PRESTR = "script.ejabber.";
my @DATA = ();

push @DATA,[ "version", $VERSION ];

# Get list configured vhost and calculate all registered user
my @VHOSTS = split /\n/, zs_system("sudo ejabberdctl registered_vhosts",{%PARAM});
my $CLIENTCOUNT = 0;
foreach my $VHOST(@VHOSTS){
	$CLIENTCOUNT += zs_system("sudo ejabberdctl registered_users $VHOST | wc -l",{%PARAM});
}
push @DATA,["globaluser",$CLIENTCOUNT];

push @DATA,["onlineuser", zs_system("sudo ejabberdctl connected_users_number",{%PARAM})];

push @DATA,["outgoing_s2s_number", zs_system("sudo ejabberdctl outgoing_s2s_number",{%PARAM})];

push @DATA,["incoming_s2s_number", zs_system("sudo ejabberdctl incoming_s2s_number",{%PARAM})];

my $RESULT = zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
print $RESULT;

