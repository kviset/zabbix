#!/usr/bin/perl -w
#Description:	Script for backup mediawiki upload directory.
#Depends:	aptitude install zabbix-sender
#		zsender.pl version 0.3.2 or high

#use Data::Dump qw(dump);
use Time::HiRes qw(time);
use Sys::Syslog;
require "/usr/lib/zabbix/zsender.pl";

#defaults
my $VERSION	= "0.0.0";
my $HOME 	= shift || "/var/backups/remote/";
my $PATH	= shift || "wiki";
my $WIKIPATH	= shift || "/var/www/wiki";
my $LOG		= shift || "backup.mediawiki";
my $HOSTNAME	= `hostname`; chop $HOSTNAME;
my $BACKUPSERVER= "BACKUP.SERVER.NAME";

my %PARAM = (
	DEBUG 	=> 1,
	NOSEND	=> 0,
	LOGNAME	=> $LOG
	);

my $PRESTR = "script.mediawiki.backup.";
my @DATA = ();
my @BACKUPPATH = (
	"images",
	"upload"
	);
########### MAIN ########### 
my $SUCCESS = 1;
push @DATA,["version",$VERSION];

#Backup start time
my $TIME = time;
push @DATA,["starttime",int $TIME];
zs_debug ("mediqwiki Backup start time: $TIME",1,{%PARAM});

#Mount backup share
zs_debug ("Mount backup share '//$BACKUPSERVER/$HOSTNAME' to '$HOME'",3,{%PARAM});
my $RESULT = zs_system ("mount.cifs //$BACKUPSERVER/$HOSTNAME $HOME -o uid=0,gid=0,rw,credentials=/etc/cifspasswd",{%PARAM});
zs_debug ("Execute 'mount.cifs'. Return: '$RESULT'",1,{%PARAM});

#check remote backup mounted.
$RESULT = zs_system("mount | grep /var/backups/remote | wc -l",{%PARAM});
if ($RESULT == 0){
	zs_debug ("ERROR:Remote backup share unmount.",0,{%PARAM});
	$SUCCESS = 0;
	goto END;	
}

#Check backup folder exesting
unless(-d "$HOME/$PATH"){
	zs_debug ("Backup directory '$HOME/$PATH' do not exists. Creating it.",1,{%PARAM});
	mkdir "$HOME/$PATH";
}

#Make backup
zs_debug ("Backup LocalSettings.php to '$HOME/$PATH'",1,{%PARAM});
$RESULT = zs_system("cp $WIKIPATH/LocalSettings.php $HOME/$PATH",{%PARAM});
unless(defined $RESULT){ $SUCCESS = 0; }

foreach $BACKUP(@BACKUPPATH){
	if (-d "$WIKIPATH/$BACKUP"){
		zs_debug ("Backuping '$WIKIPATH/$BACKUP' to '$HOME/$PATH'",1,{%PARAM});
		$RESULT = zs_system("rsync -rlptD --stats $WIKIPATH/$BACKUP $HOME/$PATH",{%PARAM});
		if(defined $RESULT){ zs_debug ("Backup log: $RESULT",1,{%PARAM}); }else{ $SUCCESS = 0; }
	}
}


#Calculate backup size
push @DATA,["size", zs_system ("du -c $HOME/$PATH |grep total |awk '{print \$1}'",{%PARAM})];

#Unmount backup share
zs_debug ("Unmount Backup share '$HOME'",3,{%PARAM});
zs_system ("umount $HOME",{%PARAM});

#Calculate execution time
push @DATA,["duration",time-$TIME];

END:
#Commit success status
push @DATA,["success",$SUCCESS];

$RESULT = zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
zs_debug ($RESULT,0,{%PARAM});
