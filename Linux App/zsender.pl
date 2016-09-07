#Includ for all perl zabbix-sender based monitoring scripts.
#Place:		/usr/lob/zabbix
#Depends:	aptitude install zabbix-sender

my $VERSION		= "0.3.9";

#ZABBIX SERVER PARAMETERS
my $ZABBIX_AGENTD_CONF  = '/etc/zabbix/zabbix_agentd.conf';
my $ZABBIX_HOSTNAME     = `/usr/sbin/zabbix_agentd -t agent.hostname`; $ZABBIX_HOSTNAME =~ s/.*\|//; $ZABBIX_HOSTNAME =~ s/]$//; chop $ZABBIX_HOSTNAME;
my $ZABBIX_TEMPFILE	= "/tmp/zabbix.".time.".".$$;

sub zs_version { return $VERSION; }

sub zs_debug {
	my $MSG		= $_[0];
	my $LVL		= $_[1];
	my %PARAM	= (
		DEBUG	=> 0,
		LOGNAME	=> undef
	);
	if (defined $_[2]){ @PARAM{keys %{$_[2]}} = values %{$_[2]}; };

	if (defined $PARAM{LOGNAME} and $PARAM{DEBUG} == 0){ $PARAM{DEBUG} = 1;}

	$MSG =~ s/\n/\\n/gm;

	openlog("$PARAM{LOGNAME}", "ndelay,pid", "local0") if defined $PARAM{LOGNAME};

	if ( $PARAM{DEBUG} >= $LVL){
		print "$MSG\n";
		syslog(LOG_INFO,"$MSG") if defined $PARAM{LOGNAME};
	}

	closelog () if defined $PARAM{LOGNAME};
}

sub zs_system {
	my $CMD		= $_[0];
	my %PARAM	= (
		DEBUG		=> 0
	);
	if (defined $_[1]){ @PARAM{keys %{$_[1]}} = values %{$_[1]}; };

	zs_debug ("zs_system execute: '$CMD'",5,{%PARAM});
	my $RESULT = `$CMD 2>&1`;

	unless ($? == 0){ 
		zs_debug ("WARNING: Execution '$CMD' failed.\nmsg: '$!'.\nReturn: $RESULT",0,{%PARAM});
		return;
	}

	zs_debug ("zs_system result: '$RESULT'",5,{%PARAM});
	return $RESULT;
}

sub zs_curl {
	my $URL		= $_[0];
	my %PARAM	= (
		DEBUG		=> 0,
		EXEC_TIMEOUT	=> 2,
		FOLLOW_REDIR	=> 1
	);
	if (defined $_[1]){ @PARAM{keys %{$_[1]}} = values %{$_[1]}; };

	zs_debug ("zs_curl get URL: '$URL'",5,{%PARAM});
	my $RESULT = zs_system("curl -isS --insecure --max-time $PARAM{EXEC_TIMEOUT} '$URL'");
	if (defined $RESULT){
		my ($HEAD)	= $RESULT =~ /(.*)\r\n\r\n/ms;
		my ($RETCODE)   = $HEAD =~ /HTTP\/[0-9|\.]+\s(\d{3})\s/m;
		$RESULT =~ s/(.*)\r\n\r\n//ms;

		zs_debug ("zs_curl RETCODE: '$RETCODE'",1,{%PARAM});
		zs_debug ("zs_curl FOLLOW_REDIR: '$PARAM{FOLLOW_REDIR}'",1,{%PARAM});
		zs_debug ("zs_curl HEAD: '$HEAD'",1,{%PARAM});

		unless ($RETCODE == 200){
			if ((($RETCODE == 301) or ($RETCODE == 302))and($PARAM{FOLLOW_REDIR} > 0)){
				$PARAM{FOLLOW_REDIR} = $PARAM{FOLLOW_REDIR} - 1;
				($URL) = $HEAD =~ /Location:\s(.*)\r\n/m;
				$RESULT = zs_curl($URL,{%PARAM});
			}else{
				zs_debug ("ERROR: HTTP request return code do not equal 200. Return code: $RETCODE.\n$RESULT\n",0,{%PARAM});
				die "ERROR: HTTP request return code do not equal 200. Return code: $RETCODE.\n$RESULT\n";
			}
		}
	}

	return $RESULT;
}


sub zs_discovery_arr {
        my $VARNAME     = $_[0];
        my @VALUES      = @{$_[1]};
        my %PARAM       = (
                DEBUG   => 0
        );
        if (defined $_[2]){ @PARAM{keys %{$_[2]}} = values %{$_[2]}; };

	my @VARNAME2D	= ($VARNAME);
	my @VALUES2D;
	foreach $tmp (@VALUES){ push @VALUES2D,[$tmp];}

	return zs_discovery_2darr(\@VARNAME2D,\@VALUES2D,{%PARAM});
}

sub zs_discovery_2darr {
	my @VARNAME	= @{$_[0]};
	my @VALUES	= @{$_[1]};
	my %PARAM	= (
		DEBUG	=> 0
	);
	if (defined $_[2]){ @PARAM{keys %{$_[2]}} = values %{$_[2]}; };

	unless ($#VARNAME == $#{$VALUES[0]}){
		zs_debug ("ERROR: Dimension VARNAME not equal VALUES",0,{%PARAM});
		die "ERROR: Dimension VARNAME not equal VALUES\n";
	}

	my $colfirst = 1;

	my $RESULT = "{\"data\":[";

	for(my $I=0;$I<=$#VALUES;$I++){
		$RESULT = $RESULT."," if not $colfirst;
		$colfirst = 0;
		$RESULT = $RESULT."{";
		
		my $rowfirst = 1;
		for(my $N=0;$N<=$#VARNAME;$N++){
			$RESULT = $RESULT."," if not $rowfirst;
			$rowfirst = 0;
                        if (defined $VALUES[$I][$N]){
                                $RESULT = $RESULT."\"{#$VARNAME[$N]}\":\"$VALUES[$I][$N]\"";
                        }else{
                                $RESULT = $RESULT."\"{#$VARNAME[$N]}\":\"0\"";
                        }
		}
		
		$RESULT = $RESULT."}";
	}

	$RESULT = $RESULT."]}\n";

	return $RESULT;
}

sub zs_zsender_arr {
	my $PRESTR 	= $_[0];
	my @DATA 	= @{$_[1]};
	my %PARAM	= (
		ZABBIX_AGENTD_CONF => $ZABBIX_AGENTD_CONF,
		ZABBIX_HOSTNAME => $ZABBIX_HOSTNAME,
		ZABBIX_TEMPFILE => $ZABBIX_TEMPFILE,
		POLLING_TIME	=> int time,
		DEBUG		=> 0,
		NOSEND		=> 0
	);
	if (defined $_[2]){ @PARAM{keys %{$_[2]}} = values %{$_[2]}; };
	unless(($PRESTR =~ m/(^$|\.$)/)){ $PRESTR = $PRESTR."."; }

	zs_debug ("File $PARAM{ZABBIX_TEMPFILE}:",1,{%PARAM});
	open OUT,">$PARAM{ZABBIX_TEMPFILE}" or die "ERROR: Can not create file $PARAM{ZABBIX_TEMPFILE}. $!";
	for(my $I = 0;$I <= $#DATA; $I++){
		if ( defined $DATA[$I][1]){
			my $HOSTNAME = $PARAM{ZABBIX_HOSTNAME};
			$DATA[$I][0] =~ s/\n//gm;
			$DATA[$I][1] =~ s/\n//gm;
			if( defined $DATA[$I][2]){
				$DATA[$I][2] =~ s/\n//gm;
				$HOSTNAME = $DATA[$I][2];
			}
			print OUT "\"$HOSTNAME\" $PRESTR$DATA[$I][0] $PARAM{POLLING_TIME} $DATA[$I][1]\n";
			zs_debug ("\"$HOSTNAME\" $PRESTR$DATA[$I][0] $PARAM{POLLING_TIME} $DATA[$I][1]",1,{%PARAM});
		}else{
			zs_debug ("WARNING: Value for key '$DATA[$I][0]' do not defined.",0,{%PARAM});
		}
	}
	close OUT;

	if ($PARAM{NOSEND} > 0){

		return "WARNING: Flag NOSEND=$PARAM{NOSEND}. Data do not send to zabbix server.\n";

	}else{

                my $RESULT = `zabbix_sender -v -T -c $PARAM{'ZABBIX_AGENTD_CONF'} -i $PARAM{'ZABBIX_TEMPFILE'} 2>&1; rm $PARAM{'ZABBIX_TEMPFILE'}`;

                return $RESULT
	}
}

