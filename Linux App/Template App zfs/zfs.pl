k#!/usr/bin/perl -w
#Template:      Template App zfs
#Config:        zfs.conf
#Place:         /usr/lib/zabbix/agentscipts
#Depends:       zsender.pl version 0.3.8 or high

require "/usr/lib/zabbix/zsender.pl";

my $MODE	= shift || "run";

#defaults
my $VERSION	= "0.0.0";


my %PARAM = (DEBUG => 0, NOSEND => 0);
my $PRESTR = "script.zfs.";
my @DATA = ();

my @ARCSTATS 	= (
		"hits",
		"data_size",
		"mru_hits",
		"mru_size",
		"size",
		"metadata_size",
		"mfu_hits",
		"mfu_size",
		"misses"
		);

my @FILESETPARAMS=(
		"refer",
		"used",
		"usedds",
		"usedsnap",
		"available"
		);

sub get_pool {
	my $RESULT = zs_system("sudo /sbin/zpool list -H -o name",{%PARAM});

	my @POOL = split /\n/, $RESULT;

	return @POOL;
}

sub get_fileset {
	my $RESULT = zs_system("sudo /sbin/zfs list -H -o name",{%PARAM});

	my @FILESET = split /\n/, $RESULT;

	return @FILESET;
}

sub m_run {
	push @DATA, ["version", $VERSION];

	#Calculate arcstats
	my $RESULT = zs_system("cat /proc/spl/kstat/zfs/arcstats",{%PARAM});
	foreach $ARCSTAT (@ARCSTATS){
		if ($RESULT =~ m/$ARCSTAT\s+\d\s+(\d+)/){
			push @DATA,["arcstats[$ARCSTAT]",$1];
		}
	}
	
	#Calculate total memory usage
	push @DATA,["memory.used",zs_system("echo \$(( `cat /proc/spl/kmem/slab | tail -n +3 | awk '{ print \$3 }' | tr \"\n\" \"+\" | sed 's/\$/0/'` ))",{%PARAM})];

	#Calculate dataset parameter
	my @FILESETS = get_fileset();
	foreach $FILESET (@FILESETS){
		foreach $FILESETPARAM (@FILESETPARAMS){
			push @DATA,["get.fsinfo[$FILESET,$FILESETPARAM]",
				zs_system("sudo /sbin/zfs get -o value -Hp $FILESETPARAM $FILESET",{%PARAM})];
		}
	}

	#Calculate pool parameter
	my @POOLS = get_pool();
        foreach $POOL (@POOLS){
		push @DATA,["zpool.health[$POOL]",zs_system("sudo /sbin/zpool list -H -o health $POOL",{%PARAM})];
        }


	print $RESULT = zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

sub m_dsr_pool {
	
	my @POOL = get_pool();

	print zs_discovery_arr("POOLNAME",\@POOL,{%PARAM});
}

sub m_dsr_fileset {

	my @FILESET = get_fileset();

	print zs_discovery_arr("FILESETNAME",\@FILESET,{%PARAM});
}

################# MAIN #################

if ($MODE eq "dsr_pool"){
	m_dsr_pool();
}elsif ($MODE eq "dsr_fileset"){
	m_dsr_fileset();
}else{
	m_run();
}

