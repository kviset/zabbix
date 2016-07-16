#!/usr/bin/perl -w
#Template: Template App snorby
#Config:   conf.nix/snorby.conf
#Place:    /usr/lib/zabbix/agentscripts
#Depends:  aptitude install zabbix-sender       
#          zsender.pl 0.3.7

#use Data::Dump qw(dump);
use Sys::Syslog;
require "/usr/lib/zabbix/zsender.pl";

#defaults
my $MODE	= shift || "run";
my $PROJPATH    = shift || "/var/www/snorby";
my $LOG		= shift || undef;

my $VERSION	= "0.0.0";
my %PARAM = (
	DEBUG	=> 0, 
	NOSEND	=> 0,
	LOGNAME	=> undef);
my $PRESTR = "script.snorby.";
my @DATA = ();

sub up_to_date {
	my $PATH = shift;

	my $BRANCH = "";
	my $CURREV = "";
	my $REMREV = "";

	$BRANCH = zs_system("cd $PATH && git symbolic-ref --short HEAD",{%PARAM}); 	chop $BRANCH;
	$CURREV = zs_system("cd $PATH && git rev-parse $BRANCH",{%PARAM});		chop $CURREV;
	$REMREV = zs_system("cd $PATH && git rev-parse origin/$BRANCH",{%PARAM});	chop $REMREV;

        zs_debug ("PATH = '$PATH'",1,{%PARAM});
        zs_debug ("BRANCH = '$BRANCH'",1,{%PARAM});
        zs_debug ("CURREV = '$CURREV'",1,{%PARAM});
        zs_debug ("REMREV = '$REMREV'",1,{%PARAM});
        zs_debug ("",1,{%PARAM});


	if ($CURREV eq $REMREV){
		return 0;
	}else{
		return 1;
	}
}

sub m_update {

	zs_debug("INFO: Execute 'git remote update'",0,{%PARAM});
	zs_system("cd $PROJPATH && git remote update",{%PARAM});

	zs_debug("INFO: Download snort rules",0,{%PARAM});

	zs_system("wget -q -O /var/www/snort/snortrules-snapshot-2982.tar.gz  http://www.snort.org/pub-bin/oinkmaster.cgi/<OINKCODE>/snortrules-snapshot-2982.tar.gz",{%PARAM});

}

sub m_send {
        push @DATA,["version",$VERSION];
	push @DATA,["cksum[config]",zs_system("find $PROJPATH/config -type f -exec cat {} \\; | cksum | awk '{ print \$1 }'")];
	push @DATA,["cksum[snortrules]",zs_system("cksum /var/www/snort/snortrules-snapshot-2982.tar.gz |awk '{ print \$1 }'")];

	push @DATA,["needupdate",up_to_date($PROJPATH)];

	print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

################ MAIN ################

if (defined $LOG) { $PARAM{LOGNAME} = "snorby.pl"; }

if( $MODE eq "update"){
	m_update();
}else{
        m_send();
}

