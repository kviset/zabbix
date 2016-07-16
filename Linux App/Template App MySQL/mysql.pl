#!/usr/bin/perl -w
#Template:      Template App MySQL
#Config:        conf.nix/mysql.conf
#Place:         /usr/lib/zabbix/agentscipts
#Depends:	aptitude install zabbix-sender
#		zsender.pl version 0.3.2 or high

require "/usr/lib/zabbix/zsender.pl";
#use Data::Dump qw(dump);

#defaults
my $VERSION	= "1.1.3";
my $INT		= shift || 60;
my $HOME 	= shift || "/usr/lib/zabbix";

my %PARAM = (DEBUG => 0, NOSEND=>0);
my $PRESTR = "script.mysql.";
my @DATA = ();

my %SENDSTAT	=(
		Uptime			=> 0,
		Bytes_sent		=> 0,
		Bytes_received		=> 0,
		Com_begin		=> 0,
		Com_commit		=> 0,
		Com_delete		=> 0,
		Com_insert		=> 0,
		Questions		=> 0,
		Com_rollback		=> 0,
		Com_select		=> 0,
		Slow_queries		=> 0,
		Com_update		=> 0,
		Aborted_connects	=> 0,
		Com_replace		=> 0,
		Com_create_user		=> 0,
		Com_create_db		=> 0,
		Com_create_event	=> 0,
		Com_create_function	=> 0,
		Com_create_index	=> 0,
		Com_create_procedure	=> 0,
		Com_create_server	=> 0,
		Com_create_table	=> 0,
		Com_create_trigger	=> 0,
		Com_create_udf		=> 0,
		Com_create_view		=> 0,
		Com_grant		=> 0,
		Connections		=> 0,
		Created_tmp_disk_tables	=> 0,
		Created_tmp_files	=> 0,
		Created_tmp_tables	=> 0,
		Key_reads		=> 0,
		Key_read_requests	=> 0,
		Key_write_requests	=> 0,
		Key_writes		=> 0,
		Max_used_connections	=> 0,
		Qcache_free_memory	=> 0,
		Qcache_hits		=> 0,
		Qcache_inserts		=> 0,
		Qcache_lowmem_prunes	=> 0,
		Qcache_not_cached	=> 0,
		Qcache_queries_in_cache	=> 0,
		Queries			=> 0,
		Threads_cached		=> 0,
		Threads_connected	=> 0,
		Threads_created		=> 0,
		Threads_running		=> 0,
		Key_blocks_unused	=> 0,
		Sort_scan		=> 0,
		Sort_range		=> 0,
		Sort_merge_passes	=> 0,
		Select_range_check	=> 0,
		Select_full_join	=> 0,
		Open_tables		=> 0,
		Opened_tables		=> 0,
		Open_files		=> 0,
		Table_locks_immediate	=> 0,
		Table_locks_waited	=> 0,
		Innodb_log_waits	=> 0
	);

my %SENDVAR =	(
	query_cache_size	=> 0,
	have_innodb		=> 0,
	have_isam		=> 0,
	have_bdb		=> 0,
	read_buffer_size	=> 0,
	read_rnd_buffer_size	=> 0,
	sort_buffer_size	=> 0,
	thread_stack		=> 0,
	join_buffer_size	=> 0,
	max_connections		=> 0,
	tmp_table_size		=> 0,
	max_heap_table_size	=> 0,
	key_buffer_size		=> 0,
	innodb_buffer_pool_size => 0,
	innodb_additional_mem_pool_size => 0,
	innodb_log_buffer_size	=> 0,
	innodb_log_file_size	=> 0,
	innodb_log_size_pct	=> 0,
	query_cache_size	=> 0,
	key_cache_block_size	=> 0,
	open_files_limit	=> 0,
	innodb_log_size_pct	=> 0,
	log_slow_queries	=> 0,
	query_cache_type	=> 0,
	thread_cache_size	=> 0,
	concurrent_insert	=> 0
);

sub interval60 {

	#MySQL ping
	push @DATA,["ping", zs_system("HOME=$HOME mysqladmin ping | grep -c alive",{%PARAM})];

	#Get number of mysql process
	push @DATA,["proc.num",zs_system("ps  -C mysqld |tail -n +2 |wc -l",{%PARAM})];

	#Extract status
	my $RESULT = zs_system("HOME=$HOME mysqladmin extended-status",{%PARAM});

	$RESULT =~ s/\+-+\+-+\+\n//mg;
	$RESULT =~ s/\|\s+Variable_name\s+\|\s+Value\s+\|\n//mg;
	$RESULT =~ s/\|//mg;
	foreach my $line (split /\n/,$RESULT){
		my @tmpval = split /\s+/,$line;
		if (defined $SENDSTAT{$tmpval[1]}){$SENDSTAT{$tmpval[1]} =$tmpval[2];}
	}
	while( my( $key, $value ) = each %SENDSTAT ){ push @DATA,["$key",$value];}
}

sub interval3600 {
	push @DATA,["version",$VERSION];

	my $RESULT = zs_system("HOME=$HOME mysql -Bse \"SELECT VERSION();\"",{%PARAM});
	push @DATA,["bin.version",$RESULT];

	$RESULT = zs_system("cksum /usr/sbin/mysqld | awk '{ print \$1 }'",{%PARAM});
	push @DATA,["bin.cksum",$RESULT];

	$RESULT = zs_system("sudo find /etc/mysql/ -type f -exec cat {} \\; | cksum | awk '{ print \$1 }'",{%PARAM});
	push @DATA,["conf",$RESULT];

	$RESULT = zs_system("HOME=$HOME mysql -Bse \"SELECT COUNT(user) FROM mysql.user;\"",{%PARAM});
	push @DATA,["user_count",$RESULT];

	$RESULT = zs_system("HOME=$HOME mysql -Bse \"SELECT COUNT(user) FROM mysql.user WHERE password = '' OR password IS NULL;\"",{%PARAM});
        push @DATA,["user_wopass_count",$RESULT];

	$RESULT = zs_system("HOME=$HOME mysql -Bse \"SELECT IFNULL(SUM(INDEX_LENGTH),0) FROM information_schema.TABLES WHERE TABLE_SCHEMA NOT IN ('information_schema') AND ENGINE = 'MyISAM';\"",{%PARAM});
	push @DATA,["total_myisam_indexes",$RESULT];

        my %ENGINEDEFAULT = (
                ARCHIVE         => 0,
                BLACKHOLE       => 0,
                CSV             => 0,
                FEDERATED       => 0,
                InnoDB          => 0,
                MRG_MYISAM      => 0,
		BerkeleyDB	=> 0,
		ISAM		=> 0
        );

	my %ENGINESTAT = %ENGINEDEFAULT;
        my %ENGINESIZE = %ENGINEDEFAULT;
        my %ENGINETABLES = %ENGINEDEFAULT;


	#Get Engine
	$RESULT = zs_system("HOME=$HOME mysql -Bse \"SELECT ENGINE,SUPPORT FROM information_schema.ENGINES WHERE ENGINE NOT IN ('performance_schema','MyISAM','MERGE','MEMORY') ORDER BY ENGINE ASC\"",{%PARAM});
	foreach my $line (split /\n/,$RESULT) {
		my ($engine,$engineenabled) = $line =~ /([a-zA-Z_]*)\s+([a-zA-Z]+)/;
		$ENGINESTAT{$engine} = ($engineenabled eq "YES" || $engineenabled eq "DEFAULT") ? 1 : 0;
	}
	while( my( $key, $value ) = each %ENGINESTAT ){ push @DATA,["engine.$key",$value];}

	$RESULT = zs_system("HOME=$HOME mysql -Bse \"SELECT ENGINE,SUM(DATA_LENGTH),COUNT(ENGINE) FROM information_schema.TABLES WHERE TABLE_SCHEMA NOT IN ('information_schema','mysql','performance_schema') AND ENGINE IS NOT NULL GROUP BY ENGINE ORDER BY ENGINE ASC;\"",{%PARAM});
	
	foreach my $line (split /\n/,$RESULT) {
        	my ($engine,$size,$count);
                ($engine,$size,$count) = $line =~ /([a-zA-Z_]*)\s+(\d+)\s+(\d+)/;
                if (!defined($size)) { next; }
                if (defined($ENGINESIZE{$engine})) {
                        $ENGINESIZE{$engine} = $size;
                        $ENGINETABLES{$engine} = $count;
                }
	}
	while( my( $key, $value ) = each %ENGINESIZE ){ push @DATA,["engine.$key.size",$value];}
	while( my( $key, $value ) = each %ENGINETABLES ){ push @DATA,["engine.$key.tables",$value];}

        $RESULT = zs_system("HOME=$HOME mysql -Bse \"SELECT COUNT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA NOT IN ('information_schema','mysql') AND Data_free > 0 AND NOT ENGINE='MEMORY';\"",{%PARAM});

	push @DATA,["fragtables",$RESULT];

	#Extract variables
	$RESULT = zs_system("HOME=$HOME mysqladmin variables",{%PARAM});

	$RESULT =~ s/\+-+\+-+\+\n//mg;
	$RESULT =~ s/\|\s+Variable_name\s+\|\s+Value\s+\|\n//mg;
	$RESULT =~ s/\|//mg;
	foreach my $line (split /\n/,$RESULT){
        	my @tmpval = split /\s+/,$line;

	        if (defined $SENDVAR{$tmpval[1]}){
			if(($tmpval[1] eq "have_innodb") or ($tmpval[1] eq "have_bdb") or ($tmpval[1] eq "have_isam")){
				$SENDVAR{$tmpval[1]} = ($tmpval[2] eq "YES") ? 1 : 0;
			}elsif(($tmpval[1] eq "query_cache_type")or($tmpval[1] eq "log_slow_queries")or($tmpval[1] eq "concurrent_insert")){
				$SENDVAR{$tmpval[1]} = ($tmpval[2] eq "OFF") ? 0 : 1;
			}else{
        	        	$SENDVAR{$tmpval[1]} =$tmpval[2];
			}
	        }
	}

	$SENDVAR{per_thread_buffers} =
			$SENDVAR{read_buffer_size} + 
			$SENDVAR{read_rnd_buffer_size} + 
			$SENDVAR{sort_buffer_size} + 
			$SENDVAR{thread_stack} + 
			$SENDVAR{join_buffer_size};
	delete $SENDVAR{read_buffer_size};
	delete $SENDVAR{read_rnd_buffer_size};
	delete $SENDVAR{sort_buffer_size};
	delete $SENDVAR{thread_stack};
	delete $SENDVAR{join_buffer_size};

	$SENDVAR{'total_per_thread_buffers'} = $SENDVAR{'per_thread_buffers'} * $SENDVAR{'max_connections'};

        # Server-wide memory
        $SENDVAR{'max_tmp_table_size'} = ($SENDVAR{'tmp_table_size'} > $SENDVAR{'max_heap_table_size'}) ? $SENDVAR{'max_heap_table_size'} : $SENDVAR{'tmp_table_size'} ;
	delete $SENDVAR{'tmp_table_size'};
	delete $SENDVAR{'max_heap_table_size'};
        $SENDVAR{'server_buffers'} = 
			$SENDVAR{'key_buffer_size'} + 
			$SENDVAR{'max_tmp_table_size'} +
        	 	$SENDVAR{'innodb_buffer_pool_size'} +
        		$SENDVAR{'innodb_additional_mem_pool_size'} +
        		$SENDVAR{'innodb_log_buffer_size'} +
        		$SENDVAR{'query_cache_size'};

        delete $SENDVAR{'innodb_additional_mem_pool_size'};
        delete $SENDVAR{'innodb_log_buffer_size'};
        delete $SENDVAR{'query_cache_size'};

	if($SENDVAR{'have_innodb'} == 1) {
		$SENDVAR{'innodb_log_size_pct'} = 100 * ($SENDVAR{'innodb_log_file_size'} / $SENDVAR{'innodb_buffer_pool_size'});
	}
	delete $SENDVAR{'innodb_log_file_size'};

	while( my( $key, $value ) = each %SENDVAR ){ push @DATA,["$key",$value];}

}

if( $INT < 300){
	interval60();
}else{
	interval3600();
}


$RESULT = zs_zsender_arr($PRESTR,\@DATA,{%PARAM});

print $RESULT;

