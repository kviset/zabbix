#!/usr/bin/perl -w
#Template:      Template App redmine
#Config:        conf.nix/redmine.conf
#Place:         /usr/lib/zabbix/agentscipts
#               zsender.pl version 0.2.2 or high
#Version:       0.0.0

#use Data::Dump qw(dump);
use Sys::Syslog;
require "/usr/lib/zabbix/zsender.pl";

#defaults
my $MODE	= shift || "run";
my $PROJPATH    = shift || "/var/www/redmine";
my $LOG		= shift || undef;

my $HOME	= "/usr/lib/zabbix";
my $VERSION	= "0.0.2";
my %PARAM = (
	DEBUG	=> 0, 
	NOSEND	=> 0,
	LOGNAME	=> undef);
my $PRESTR = "script.redmine.";
my @DATA = ();

sub up_to_date {
	my $PATH = shift;

	my $BRANCH = "";
	my $CURREV = "";
	my $REMREV = "";

	if($PATH =~ m/\/redmine_ckeditor/){
		$CURREV = zs_system("cd $PATH && git describe --tags",{%PARAM});	chop $CURREV;
		$REMREV = zs_system("cd $PATH && git tag -l | tail -n1",{%PARAM});	chop $REMREV;
	}else{
		$BRANCH = zs_system("cd $PATH && git symbolic-ref --short HEAD",{%PARAM}); 	chop $BRANCH;
		$CURREV = zs_system("cd $PATH && git rev-parse $BRANCH",{%PARAM});		chop $CURREV;
		$REMREV = zs_system("cd $PATH && git rev-parse origin/$BRANCH",{%PARAM});	chop $REMREV;
	}

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

	opendir(my $dh, "$PROJPATH/plugins") or die "ERROR: can't opendir $PROJPATH/plugins: $!\n";
	zs_system("cd $PROJPATH/plugins/$_ && git remote update",{%PARAM}) foreach grep {-d "$PROJPATH/plugins/$_" && ! /^\.{1,2}$/} readdir($dh);
	closedir $dh;
}

sub m_discovery {
        #Collect subdirs on $PROJPATH/extensions
        opendir(my $dh, "$PROJPATH/plugins") or die "ERROR: can't opendir $PROJPATH/plugins: $!\n";
        my @EXTS = grep {-d "$PROJPATH/plugins/$_" && ! /^\.{1,2}$/} readdir($dh);
        closedir $dh;

	unless($#EXTS<0){
		print zs_discovery_arr("NAME",\@EXTS,{%PARAM});
	}
}

sub m_send {
        push @DATA,["version",$VERSION];
	push @DATA,["cksum[config]",zs_system("find $PROJPATH/config -type f -exec cat {} \\; | cksum | awk '{ print \$1 }'")];

	push @DATA,["needupdate[redmine]",up_to_date($PROJPATH)];

	#Collect subdirs on $PROJPATH/extensions
	opendir(my $dh, "$PROJPATH/plugins") or die "ERROR: can't opendir $PROJPATH/plugins: $!\n";
	push @DATA,["needupdate[$_]",up_to_date("$PROJPATH/plugins/$_")] foreach grep {-d "$PROJPATH/plugins/$_" && ! /^\.{1,2}$/} readdir($dh);
	closedir $dh;

	#collect user info 
	push @DATA,["user.count",zs_system("HOME=$HOME mysql -D redmine -Bse \"select count(login) from users;\"",{%PARAM})];
	push @DATA,["admin.count",zs_system("HOME=$HOME mysql -D redmine -Bse \"select count(login) from users where admin=1;\"",{%PARAM})];

        print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

################ MAIN ################

if (defined $LOG) { $PARAM{LOGNAME} = "redmine.pl"; }

if ($MODE eq "discovery"){
        m_discovery();
}elsif( $MODE eq "update"){
	m_update();
}else{
        m_send();
}

