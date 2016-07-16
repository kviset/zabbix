#!/usr/bin/perl -w
#Description:	Script for backup MySQL DB and notify zabbix server.
#Depends:	aptitude install zabbix-sender
#		zsender.pl version 0.3.2 or high

#use Data::Dump qw(dump);
use Time::HiRes qw(time);
use Sys::Syslog;
require "/usr/lib/zabbix/zsender.pl";

#defaults
my $VERSION	= "0.0.6";
my $HOME 	= shift || "/var/backups/remote/";
my $PATH	= shift || "mysql";
my $LOG		= shift || "backup.mysql";
my $HOSTNAME	= `hostname`; chop $HOSTNAME;
my $BACKUPSERVER= "<BACKUP.SERVER.NAME>";

my %PARAM = (
	DEBUG 	=> 1,
	NOSEND	=> 0,
	LOGNAME	=> $LOG
	);

my $PRESTR = "script.mysql.backup.";
my @DATA = ();

########### MAIN ########### 
my $SUCCESS = 1;
push @DATA,["version",$VERSION];

#Backup start time
my $TIME = time;
push @DATA,["starttime",int $TIME];
zs_debug ("MySQL Backup start time: $TIME",1,{%PARAM});

#Mount backup share
zs_debug ("Mount backup share '//$BACKUPSERVER/$HOSTNAME' to '$HOME'",3,{%PARAM});
my $RESULT = zs_system ("mount.cifs //$BACKUPSERVER/$HOSTNAME $HOME -o uid=0,gid=0,rw,credentials=/etc/cifspasswd",{%PARAM});
zs_debug ("Execute 'mount.cifs'. Return: '$RESULT'",1,{%PARAM});

#check remote backup mounted.
my $MOUNT = zs_system("mount | grep /var/backups/remote | wc -l",{%PARAM});
if ($MOUNT == 0){
	zs_debug ("ERROR:Remote backup share unmount.",0,{%PARAM});
	$SUCCESS = 0;
	goto END;	
}

#Get Date and week days and prepare backup filename
my @DATE = localtime(); $DATE[4] += 1; $DATE[5] += 1900;
zs_debug ("Current date:",5,{%PARAM});
zs_debug ("\tMonth day:\t'$DATE[3]'",5,{%PARAM});
zs_debug ("\tMonth:\t\t'$DATE[4]'",5,{%PARAM});
zs_debug ("\tYear:\t\t'$DATE[5]'",5,{%PARAM});
zs_debug ("\tWeek day:\t'$DATE[6]'",5,{%PARAM});

#Get Filename for backup
my $BACKUPNAME;
if ($DATE[3] == 1){
	$BACKUPNAME = "month-$DATE[3]-$DATE[4]-$DATE[5].sql";
}elsif($DATE[6] == 1){
	$BACKUPNAME = "week-$DATE[3]-$DATE[4]-$DATE[5].sql";
}else{
	$BACKUPNAME = "day-$DATE[3]-$DATE[4]-$DATE[5].sql";
}
zs_debug ("Backup filename: '$BACKUPNAME'",1,{%PARAM});


#Check backup folder exesting
unless(-d "$HOME/$PATH"){
	zs_debug ("Backup directory '$HOME/$PATH' do not exists. Creating it.",1,{%PARAM});
	mkdir "$HOME/$PATH";
}

#Make backup
zs_debug ("Make backup to '$HOME/$PATH/$BACKUPNAME'",3,{%PARAM});
$RESULT = zs_system ("HOME=$HOME mysqldump --ignore-table=mysql.event --all-databases > $HOME/$PATH/$BACKUPNAME",{%PARAM});

if(defined $RESULT){
	#Compress backup
	$RESULT = zs_system ("gzip -f $HOME/$PATH/$BACKUPNAME",{%PARAM});
}else{
	$SUCCESS = 0;
}

#Clear old backup
zs_debug ("Clear old dayly backup",3,{%PARAM});
$RESULT = zs_system ("find $HOME/$PATH -name \"day-*\" -type f -mtime +6 -exec rm -v {} \\;",{%PARAM});
zs_debug ("Remove dayly backup: $RESULT",1,{%PARAM});

zs_debug ("Clear old weekly backup",3,{%PARAM});
$RESULT = zs_system ("find $HOME/$PATH -name \"week-*\" -type f -mtime +29 -exec rm -v {} \\;",{%PARAM});
zs_debug ("Remove weekly backup: $RESULT",1,{%PARAM});

zs_debug ("Clear old monthly backup",3,{%PARAM});
$RESULT = zs_system ("find $HOME/$PATH -name \"month-*\" -type f -mtime +90 -exec rm -v {} \\;",{%PARAM});
zs_debug ("Remove monthly backup: $RESULT",1,{%PARAM});

#Calculate backup size
push @DATA,["size", zs_system ("du -c $HOME/$PATH |grep total |awk '{print \$1}'",{%PARAM})];

#Backup files count
push @DATA,["count",zs_system("ls -l $HOME/$PATH | tail -n +2 | wc -l",{%PARAM})];

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
