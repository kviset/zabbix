#!/usr/bin/perl -w
#Template: Template App redis
#Config:   conf.nix/redis.conf
#Place:    /usr/lib/zabbix/agentscripts
#Depends:  aptitude install zabbix-sender libredis-perl
#	   zsender.pl 0.3.7
#based on zbx_redis_template (https://github.com/blacked/zbx_redis_template)

use Redis;
use Time::HiRes qw(time);
#use Data::Dump qw(dump);


require "/usr/lib/zabbix/zsender.pl";

my $VERSION 	= "0.0.0";
my $MODE	= shift || "run";
my $URI		= shift || "redis://localhost:6379";
#			   "unix://path/to/sock" for use unix sock

my %PARAM = (DEBUG => 0, NOSEND => 0);
my $PRESTR = "script.redis.";
my @DATA = ();

my @PROPERTYS = (
	"aof_enabled",
	"aof_rewrite_in_progress",
	"aof_rewrite_scheduled",
	"blocked_clients",
	"client_biggest_input_buf",
	"client_longest_output_list",
	"connected_clients",
	"connected_slaves",
	"evicted_keys",
	"expired_keys",
	"instantaneous_ops_per_sec",
	"keyspace_hits",
	"keyspace_misses",
	"latest_fork_usec",
	"loading",
	"lru_clock",
	"mem_fragmentation_ratio",
	"pubsub_channels",
	"rdb_bgsave_in_progress",
	"rdb_changes_since_last_save",
	"redis_git_dirty",
	"rejected_connections",
	"total_commands_processed",
	"total_connections_received",
	"uptime_in_seconds",
	"used_cpu_sys",
	"used_cpu_sys_children",
	"used_cpu_user",
	"used_cpu_user_children",
	"used_memory",
	"used_memory_peak",
	"used_memory_rss"
);

my @PROPERTYS3600 = (
	"arch_bits",
	"gcc_version",
	"multiplexing_api",
	"redis_git_sha1",
	"redis_mode",
	"redis_version",
	"role"
);

my $redis;

sub m_discovery{

	my $REDIS_INFO = $redis->info;

        my @db = grep /^db\d+/,keys %{$REDIS_INFO};

        print zs_discovery_arr("DBNAME",\@db,{%PARAM});
}


sub m_run{

	my $TICK = time;
	$redis->ping || die "ERROR: Could not connect to the server '$URI'\n";
	push @DATA,["ping",(time - $TICK)];

	my $REDIS_INFO = $redis->info;

	foreach $PROPERTY (@PROPERTYS){
		if( defined ${$REDIS_INFO}{$PROPERTY} ){push @DATA,["$PROPERTY",${$REDIS_INFO}{$PROPERTY}];}
		else{ zs_debug("WARNING: Keys '$PROPERTY' not found",0,{%PARAM});}
	}

	push @DATA,["rdb_last_save_time",int(time - ${$REDIS_INFO}{'rdb_last_save_time'})];
	push @DATA,["proc.num",zs_system("ps h -C redis-server | wc -l",{%PARAM})];

	foreach $db (grep /^db\d+/,keys %{$REDIS_INFO}){
		if(${$REDIS_INFO}{$db} =~ m/keys=(\d+),expires=(\d+),avg_ttl=(\d+)/){
			push @DATA,["db[$db,key_space_db_keys]",$1];
			push @DATA,["db[$db,key_space_db_expires]",$2];
			push @DATA,["db[$db,key_space_db_avg_ttl]",$3];
		}else{
			zs_debug("WARNING: Failed get data for db '$db'",0,{%PARAM});
		}
	}

	print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

sub m_run3600{

	my $REDIS_INFO = $redis->info;

	push @DATA,["version",$VERSION];

        foreach $PROPERTY (@PROPERTYS3600){
                if( defined ${$REDIS_INFO}{$PROPERTY} ){push @DATA,["$PROPERTY",${$REDIS_INFO}{$PROPERTY}];}
                else{ zs_debug("WARNING: Keys '$PROPERTY' not found",0,{%PARAM});}
        }

	print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

###################### MAIN #####################

$URI =~ m/^(\w+):\/\/(.*)/;

if ( $1 eq 'unix'){
        $redis = Redis->new(
                sock => "/$2",
        	encoding => undef
	);
}elsif ($1 eq 'redis'){
        $redis = Redis->new(
                server => $2,
        	encoding => undef
	);
}else{
	zs_debug ("ERROR: Wrong redis server connection string",0,{%PARAM});
	exit(1);
}


if ($MODE eq 'discovery'){
	m_discovery();
}elsif($MODE eq 'run3600'){
	m_run3600();
}else{
	m_run();
}

$redis->quit;
