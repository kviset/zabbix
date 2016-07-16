#!/usr/bin/perl -w
#Template:      Template App mediawiki
#Config:        conf.nix/mediawiki.conf
#Place:         /usr/lib/zabbix/agentscipts
#               zsender.pl version 0.2.2 or high
#Version:       0.0.0

#use Data::Dump qw(dump);
use Sys::Syslog;
require "/usr/lib/zabbix/zsender.pl";

#defaults
my $MODE	= shift || "run";
my $WIKIPATH    = shift || "/var/www/wiki";
my $LOG		= shift || undef;

my %PARAM = (
	DEBUG	=> 0, 
	NOSEND	=> 0,
	LOGNAME	=> undef);
my $PRESTR = "script.mediawiki.";
my @DATA = ();

sub up_to_date {
	my $PATH = shift;

	my $BRANCH = zs_system("cd $PATH && git symbolic-ref --short HEAD",{%PARAM}); 	chop $BRANCH;
	my $CURREV = zs_system("cd $PATH && git rev-parse $BRANCH",{%PARAM});		chop $CURREV;
	my $REMREV = zs_system("cd $PATH && git rev-parse origin/$BRANCH",{%PARAM});	chop $REMREV;

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

	zs_system("cd $WIKIPATH && git remote update",{%PARAM});

	opendir(my $dh, "$WIKIPATH/extensions") or die "ERROR: can't opendir $WIKIPATH/extensions: $!\n";
	zs_system("cd $WIKIPATH/extensions/$_ && git remote update",{%PARAM}) foreach grep {-d "$WIKIPATH/extensions/$_" && ! /^\.{1,2}$/} readdir($dh);
	closedir $dh;
}

sub m_discovery {
        #Collect subdirs on $WIKIPATH/extensions
        opendir(my $dh, "$WIKIPATH/extensions") or die "ERROR: can't opendir $WIKIPATH/extensions: $!\n";
        my @EXTS = grep {-d "$WIKIPATH/extensions/$_" && ! /^\.{1,2}$/} readdir($dh);
        closedir $dh;

	print zs_discovery_arr("NAME",\@EXTS,{%PARAM});
}

sub m_send {
	push @DATA,["cksum[LocalSettings.php]",zs_system("cksum $WIKIPATH/LocalSettings.php | cut -d' ' -f1")];

	push @DATA,["needupdate[mediawiki]",up_to_date($WIKIPATH)];

	#Collect subdirs on $WIKIPATH/extensions
	opendir(my $dh, "$WIKIPATH/extensions") or die "ERROR: can't opendir $WIKIPATH/extensions: $!\n";
	push @DATA,["needupdate[$_]",up_to_date("$WIKIPATH/extensions/$_")] foreach grep {-d "$WIKIPATH/extensions/$_" && ! /^\.{1,2}$/} readdir($dh);
	closedir $dh;

	#get current mediawiki version
	push @DATA,["version",zs_system("grep -Po \"wgVersion = '\\K[^']+\" $WIKIPATH/includes/DefaultSettings.php")];

        print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

################ MAIN ################

if (defined $LOG) { $PARAM{LOGNAME} = "mediawiki.pl"; }

if ($MODE eq "discovery"){
        m_discovery();
}elsif( $MODE eq "update"){
	m_update();
}else{
        m_send();
}

