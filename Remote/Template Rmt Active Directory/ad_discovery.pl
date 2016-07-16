#!/usr/bin/perl -w
#Template:      Host Active Directory
#Config:        ---
#Place:         /usr/lib/zabbix/externalscripts
#Depends:       aptitude install zabbix-sender winbind
#Version:       1.0.1

require "/usr/lib/zabbix/zsender.pl";

my $MODE	= shift || "group";

my %PARAM = (DEBUG => 0);

sub ad_group_discovery{
	my @VARNAME	= ("GNAME","SID","IDNAME");	
	my @GLIST;

	foreach $tmp (split /\n/,zs_system("wbinfo -g",{%PARAM})){
		my $SID = zs_system("wbinfo -n \"$tmp\"|awk '{print \$1}'",{%PARAM}); chop $SID;
		my $IDNAME = $tmp; $IDNAME =~ s/\s/_/g;
		push @GLIST,([$tmp,$SID,$IDNAME]);
	}
	return zs_discovery_2darr(\@VARNAME,\@GLIST,{%PARAM});
}

sub ad_polycies_discovery{
	my @VARNAME	= ("PNAME","PDNAME");

	my $POLICIES = zs_system("sudo net ads gpo listall -P",{%PARAM});

        $POLICIES =~ s/^\t(.*)\n//mg;

        my @PNLIST  = ($POLICIES =~ /^name:\s+{(.*)}/mg );
        my @PDNLIST = ($POLICIES =~ /^displayname:\s+(.*)/mg );	
	my @DATA; 

	for (my $I=0; $I <=$#PNLIST; $I++){push @DATA,[$PNLIST[$I],$PDNLIST[$I]]}

	return zs_discovery_2darr(\@VARNAME,\@DATA,{%PARAM});
}

#MAIN
my $RESULT = "ERROR: Something wrong.";

if ($MODE eq "group"){
	$RESULT = ad_group_discovery();
}elsif($MODE eq "polycies"){
	$RESULT = ad_polycies_discovery();
}

print $RESULT;

