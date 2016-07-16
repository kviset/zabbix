#!/usr/bin/perl -w
#Template: Template App pacemaker
#Config:   conf.nix/pacemaker.conf
#Place:    /usr/lib/zabbix/agentscripts
#Depends:  aptitude install zabbix-sender       
#	   zsender.pl 0.3.3

#use Data::Dump qw(dump);

require "/usr/lib/zabbix/zsender.pl";

my $VERSION		= "0.0.2";

my $MODE		= shift || "run";
my $ZABBIX_HOSTNAME 	= shift || undef;

my %PARAM = (DEBUG => 0, NOSEND => 0);
my $PRESTR = "script.pacemaker";

sub m_send{
	my @DATA = ();

	push @DATA,["version",$VERSION];

	my $RESULT = zs_system("sudo crm_mon --one-shot --as-xml 2>/dev/null | xml2",{%PARAM});

	#Get nodes_ configured
	push @DATA,["nodes_configured",($RESULT =~ /\/crm_mon\/summary\/nodes_configured\/\@number=(\d+)/)];

	#Get resources_configured
	push @DATA,["resources_configured",($RESULT =~ /\/crm_mon\/summary\/resources_configured\/\@number=(\d+)/)];

	#Get n_res_running
	my @NODES = ($RESULT =~ /\/crm_mon\/nodes\/node\/\@name=(\S+)/mg);
	my @RESRUN = ($RESULT =~ /\/crm_mon\/nodes\/node\/\@resources_running=(\d+)/mg);
	
	if ($#NODES != $#RESRUN) {
		print "ERROR: Count nodes not equal count run resurces\n"
	}else{
		for (my $I = 0; $I <= $#NODES; $I++){
			push @DATA,["n_res_running[".$NODES[$I]."]",$RESRUN[$I]]
		}
	}

	#Get failure count
	my $VALUE = () = $RESULT =~ /\/crm_mon\/failures\/failure\/\@op_key=/mg;
	push @DATA,["faults.count",$VALUE ];

	#Get nodes online
	$VALUE = () = $RESULT =~ /\/crm_mon\/nodes\/node\/\@online=true/mg;
	push @DATA,["nodes.online",$VALUE];

	#GET nodes offline
	$VALUE = () = $RESULT =~ /\/crm_mon\/nodes\/node\/\@online=false/mg;
	push @DATA,["nodes.offline",$VALUE];

	#GET nodes standby
	$VALUE = () = $RESULT =~ /\/crm_mon\/nodes\/node\/\@standby=true/mg;
	push @DATA,["nodes.standby",$VALUE];

        #GET nodes standby_onfail
        $VALUE = () = $RESULT =~ /\/crm_mon\/nodes\/node\/\@standby_onfail=true/mg;
        push @DATA,["nodes.standby_onfail",$VALUE];

        #GET nodes maintenance
        $VALUE = () = $RESULT =~ /\/crm_mon\/nodes\/node\/\@maintenance=true/mg;
        push @DATA,["nodes.maintenance",$VALUE];

        #GET nodes pending
        $VALUE = () = $RESULT =~ /\/crm_mon\/nodes\/node\/\@pending=true/mg;
        push @DATA,["nodes.pending",$VALUE];

        #GET nodes unclean
        $VALUE = () = $RESULT =~ /\/crm_mon\/nodes\/node\/\@unclean=true/mg;
        push @DATA,["nodes.unclean",$VALUE];

        #GET nodes shutdown
        $VALUE = () = $RESULT =~ /\/crm_mon\/nodes\/node\/\@shutdown=true/mg;
        push @DATA,["nodes.shutdown",$VALUE];

	print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});

	exit 0;
}

sub m_discovery{
	my @DATA = ();
	
	my $RESULT = zs_system("sudo crm_mon --one-shot --as-xml 2>/dev/null | xml2",{%PARAM});

	my @NODES = $RESULT =~ /\/crm_mon\/nodes\/node\/\@name=(\S+)/mg;

	print zs_discovery_arr("NODE",\@NODES,{%PARAM});

	exit 0;
}

if (defined $ZABBIX_HOSTNAME) { $PARAM{'ZABBIX_HOSTNAME'}=$ZABBIX_HOSTNAME;}

if ($MODE eq "discovery"){
	m_discovery();
}else{
	m_send();
}

