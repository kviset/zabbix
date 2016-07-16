#!/usr/bin/perl -w
#Template:      Host Active Directory
#Config:        ---
#Place:         /usr/lib/zabbix/externalscripts 
#Depends:       aptitude install zabbix-sender winbind libstring-crc32-perl

use String::CRC32;

require "/usr/lib/zabbix/zsender.pl";

my $VERSION	= "1.0.2";

my $HOSTNAME 	= shift;

my %PARAM  = (DEBUG => 0,NOSEND => 0);
my $PRESTR = "script.ad";
my @DATA   = ();

#GET version of script ad_discovery and ad_run
push @DATA, ["ad_run.version",$VERSION];
push @DATA, ["ad_discovery.version",zs_system("grep \"#Version:\" /usr/lib/zabbix/externalscripts/ad_discovery.pl",{%PARAM} ) =~ /.*:\s+([0-9|\.]+)/];

#Get user counts
push @DATA, ["user.count",zs_system("wbinfo -u|wc -l",{%PARAM})];

#Get group 
my @GLIST =split /\n/, zs_system("wbinfo -g",{%PARAM});
push @DATA, ["group.count",$#GLIST+1];

foreach $grp (@GLIST){
	my $member = zs_system("getent group '$grp'",{%PARAM}); chop $member;
	my $IDNAME = $grp; $IDNAME =~ s/\s/_/g;
	push @DATA, ["group.members.cksum[$IDNAME]",crc32($member)];
}

#Get polycies
my $POLICIES = zs_system("sudo net ads gpo listall -P",{%PARAM});
$POLICIES =~ s/^\t(.*)\n//mg;
my @PNLIST = ( $POLICIES =~ /^name:\s+{(.*)}/mg );

push @DATA, ["polycies.count",$#PNLIST+1];

foreach $PNAME (@PNLIST){
	my @PVERSION = ($POLICIES =~ /^name:\s+{$PNAME}\ndisplayname:.*\nversion:\s+(\d+)/mg);
	push @DATA,["polycies.version[$PNAME]",$PVERSION[0]];
}

#Send data
if ( defined $HOSTNAME){$PARAM{ZABBIX_HOSTNAME} = $HOSTNAME;}
my $RESULT = zs_zsender_arr($PRESTR,\@DATA,{%PARAM});

print $RESULT;

