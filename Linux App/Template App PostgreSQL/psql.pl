#!/usr/bin/perl -w
#Template: Template App Postgresql
#Config:   conf.nix/psql.conf
#Place:    /usr/lib/zabbix/agentscripts
#Depends:  aptitude install zabbix-sender       
#	   zsender.pl 0.3.7
#fork from pg_modz v 2.0.1 http://pg-monz.github.io/pg_monz/index-en.html

require "/usr/lib/zabbix/psqlconf.pm";
require "/usr/lib/zabbix/zsender.pl";

my $VERSION = "0.0.2";
my $MODE	= shift || "run";
my $BIN		= shift || "psql";
my $PGSLOW	= shift || 10;

my %PARAM = (DEBUG => 0, NOSEND => 0);
my $PRESTR = "script.psql.";
my @DATA = ();

sub execsql {
	my $DATABASE 	= shift;
	my $SQL 	= shift;

	my $CLIPARAM	= "";

	if( defined $psqlconf::PGHOST) { $CLIPARAM = $CLIPARAM." -h $psqlconf::PGHOST";}
	if( defined $psqlconf::PGPORT) { $CLIPARAM = $CLIPARAM." -p $psqlconf::PGPORT";}
	if( defined $psqlconf::PGROLE) { $CLIPARAM = $CLIPARAM." -U $psqlconf::PGROLE";}

	return zs_system("$BIN $CLIPARAM -d $DATABASE -t -c \"$SQL\"",{%PARAM});
}

sub getdb {
	my $RESULT = execsql($psqlconf::PGDATABASE,"select datname from pg_database where datistemplate = 'f';");
	$RESULT =~ s/^\s+//gm;
	my @DBNAME = split /\n/,$RESULT;

	return @DBNAME;
}

sub gettbl {

	my @TBL = ();

	my @DBNAMES = getdb();

	foreach $DBNAME (@DBNAMES){
		my $RESULT = execsql($DBNAME,"select schemaname,tablename from pg_tables where schemaname not in ('pg_catalog','information_schema');");

		foreach $LINE (split /\n/,$RESULT) {
			if($LINE =~ m/\s([\w\d_]+)\s+\|\s+([\w\d_]+)/mg){
				push @TBL,[$DBNAME,$1,$2];
			}
		}
	}

	return @TBL;
}

sub m_send3600 {

	my @DBNAMES = getdb();

	push @DATA,[ "version", $VERSION ];

	#Inserted from DB Name list Discovery
	foreach $DBNAME (getdb){
		my $RESULT = execsql($DBNAME,"	SELECT \\
						tup_updated,xact_rollback,xact_commit,temp_bytes,tup_returned,tup_inserted,tup_fetched,\\
						tup_deleted,deadlocks,numbackends \\
						FROM pg_stat_database WHERE datname = '$DBNAME';");
		$RESULT =~ s/ //g;
		my @RESDATA = split /\|/,$RESULT;
		push @DATA,["db_updated[$DBNAME]",		$RESDATA[0]];
		push @DATA,["db_tx_rolledback[$DBNAME]",	$RESDATA[1]];
		push @DATA,["db_tx_commited[$DBNAME]",		$RESDATA[2]];
		push @DATA,["db_temp_bytes[$DBNAME]",		$RESDATA[3]];
		push @DATA,["db_returned[$DBNAME]",		$RESDATA[4]];
		push @DATA,["db_inserted[$DBNAME]",		$RESDATA[5]];
		push @DATA,["db_fetched[$DBNAME]",		$RESDATA[6]];
		push @DATA,["db_deleted[$DBNAME]",		$RESDATA[7]];
		push @DATA,["db_deadlocks[$DBNAME]",		$RESDATA[8]];
		push @DATA,["db_connections[$DBNAME]",		$RESDATA[9]];
		push @DATA,["cachehit_ratio[$DBNAME]",		execsql($DBNAME,"SELECT round(blks_hit*100/(blks_hit+blks_read), 2) AS cache_hit_ratio FROM pg_stat_database WHERE datname = '$DBNAME' and blks_read > 0 union all select 0.00 AS cache_hit_ratio order by cache_hit_ratio desc limit 1;")];
		push @DATA,["db_size[$DBNAME]",                 execsql($DBNAME,"SELECT pg_database_size('$DBNAME');")];
		push @DATA,["db_garbage_ratio[$DBNAME]",	execsql($DBNAME,"SELECT round(100*sum( \\
							CASE (a.n_live_tup+a.n_dead_tup) WHEN 0 THEN 0 \\
							ELSE c.relpages*(a.n_dead_tup/(a.n_live_tup+a.n_dead_tup)::numeric) \\
							END \\
							)/ sum(c.relpages),2) \\
							FROM \\
							pg_class as c join pg_stat_all_tables as a on(c.oid = a.relid) where relpages > 0;")];
	}

	print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

sub m_send {
	my $RESULT = execsql($psqlconf::PGDATABASE,"SELECT \\
	buffers_alloc,buffers_backend,buffers_backend_fsync,buffers_checkpoint,buffers_clean,checkpoints_req,checkpoints_timed,maxwritten_clean \\
	FROM pg_stat_bgwriter;");

	$RESULT =~ s/ //g;
	my @RESDATA = split /\|/,$RESULT;
        push @DATA,["buffers_alloc",    	$RESDATA[0]];
	push @DATA,["buffers_backend",		$RESDATA[1]];
	push @DATA,["buffers_backend_fsync",    $RESDATA[2]];
	push @DATA,["buffers_checkpoint",	$RESDATA[3]];
	push @DATA,["buffers_clean",            $RESDATA[4]];
	push @DATA,["checkpoints_req",          $RESDATA[5]];
	push @DATA,["checkpoints_timed",        $RESDATA[6]];
	push @DATA,["maxwritten_clean",         $RESDATA[7]];

	push @DATA,["tx_commited", 	   execsql($psqlconf::PGDATABASE,"SELECT sum(xact_commit) FROM pg_stat_database;")];
	push @DATA,["tx_rolledback",       execsql($psqlconf::PGDATABASE,"SELECT sum(xact_rollback) FROM pg_stat_database;")];
	push @DATA,["active_connections",  execsql($psqlconf::PGDATABASE,"SELECT count(*) FROM pg_stat_activity WHERE state = 'active';")];
	push @DATA,["server_connections",  execsql($psqlconf::PGDATABASE,"SELECT count(*) FROM pg_stat_activity;")];
	push @DATA,["idle_connections",    execsql($psqlconf::PGDATABASE,"SELECT count(*) FROM pg_stat_activity WHERE state = 'idle';")];
	push @DATA,["idle_tx_connections", execsql($psqlconf::PGDATABASE,"SELECT count(*) FROM pg_stat_activity WHERE state = 'idle in transaction';")];
	push @DATA,["locks_waiting",       execsql($psqlconf::PGDATABASE,"SELECT count(*) FROM pg_stat_activity WHERE waiting = 'true';")];
	push @DATA,["server_maxcon",       execsql($psqlconf::PGDATABASE,"SELECT setting::int FROM pg_settings WHERE name = 'max_connections';")];

	push @DATA,["slow_dml_queries",    execsql($psqlconf::PGDATABASE,"SELECT count(*) from pg_stat_activity where state = 'active' and now() - query_start > '$PGSLOW sec'::interval and query ~* '^(insert|update|delete)';")];
	push @DATA,["slow_queries",        execsql($psqlconf::PGDATABASE,"SELECT count(*) from pg_stat_activity where state = 'active' and now() - query_start > '$PGSLOW sec'::interval;")];
	push @DATA,["slow_select_queries", execsql($psqlconf::PGDATABASE,"SELECT count(*) from pg_stat_activity where state = 'active' and now() - query_start > '$PGSLOW sec'::interval and query ilike 'select%';")];

	push @DATA,["primary_server",	   execsql($psqlconf::PGDATABASE,"select (NOT(pg_is_in_recovery()))::int;")];

	push @DATA,["proc.num",zs_system("ps  -C postgres |tail -n +2 |wc -l",{%PARAM})];

	print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

sub m_dbdiscovery {
	
	my @DBNAME = getdb();
	print zs_discovery_arr("DBNAME",\@DBNAME,{%PARAM});
}

sub m_tbldiscovery {
	my @VARNAME     = ("DBNAME","SCHEMANAME","TABLENAME");

	my @TBL = gettbl();
	print zs_discovery_2darr(\@VARNAME,\@TBL,{%PARAM});

}

####################### MAIN ##############################

zs_debug("Variables:",2,{%PARAM});
zs_debug("\tMODE:\t\t$MODE",2,{%PARAM});
zs_debug("\tBIN:\t\t$BIN",2,{%PARAM});
if(defined $psqlconf::PGHOST){
	zs_debug("\tPGHOST:\t\t$psqlconf::PGHOST",2,{%PARAM});
}else{	zs_debug("\tPGHOST:\t\tundef",2,{%PARAM});}
if(defined $psqlconf::PGPORT){
	zs_debug("\tPGPORT:\t\t$psqlconf::PGPORT",2,{%PARAM});
}else{	zs_debug("\tPGPORT:\t\tundef",2,{%PARAM});}
if(defined $psqlconf::PGROLE){
	zs_debug("\tPGROLE:\t\t$psqlconf::PGROLE",2,{%PARAM});
}else{	zs_debug("\tPGROLE:\t\tundef",2,{%PARAM});}
if(defined $psqlconf::PGDATABASE){
	zs_debug("\tPGDATABASE:\t$psqlconf::PGDATABASE",2,{%PARAM});
}else{	zs_debug("\tPGDATABASE:\tundef",2,{%PARAM});}

if ($MODE eq 'dbdiscovery'){
	m_dbdiscovery();
}elsif($MODE eq 'tbldiscovery'){
	m_tbldiscovery();
}elsif($MODE eq 'run3600'){
	m_send3600();
}else{
	m_send();
}
