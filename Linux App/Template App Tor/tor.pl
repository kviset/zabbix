#!/usr/bin/perl -w
#Template: Template App tor
#Config:   conf.nix/tor.conf
#Place:    /usr/lib/zabbix/agentscripts
#Depends:  
#          zsender.pl 0.3.3

#use Data::Dump qw(dump);
use IO::Socket;

require "/usr/lib/zabbix/zsender.pl";

my $VERSION		= "0.0.0";

my %PARAM = (DEBUG => 0,NOSEND => 0);
my $PRESTR = "script.tor";
my @DATA = ();

sub linecount {
	my $TXT = shift;

	$TXT =~ s/^\n//g;
        my $COUNT = $TXT =~ tr/\n//;
	$COUNT++ if (length $TXT > 0);

	return $COUNT;
}

sub extract_msg {
	my $FULL= shift;
	my $VAR	= shift;

	if($FULL=~m/250\+$VAR=\n(.*?)\n\.\n250 OK/ms){
		return $1;
	}elsif($FULL=~m/250-$VAR=(.*?)\n250 OK/ms){
		return $1;
	}else{ 
		zs_debug("INFO: Result of '$VAR' not found",0,{%PARAM});
		return; 
	}
}

sub calculate_status {
        my $VALUE  = $_[0];
        my @STATUS = @{$_[1]};
	my @RESULT = ();

	for(my $I =0; $I <= $#STATUS; $I++){
		my $COUNT = () = $VALUE =~ /\s($STATUS[$I])\s/g;
		push @RESULT,$COUNT;
	}
	
	return @RESULT;
}

#Read password
my $PASSWORD ='';
open FILE, "/usr/lib/zabbix/.torpass" or die "ERROR: Can not open file '/usr/lib/zabbix/.torpass'. $!\n";
$PASSWORD = <FILE>; chop $PASSWORD;
close FILE;

my $SCRIPT = <<'EOF';
GETINFO circuit-status
GETINFO stream-status
GETINFO orconn-status
GETINFO network-status
GETINFO entry-guards
GETINFO dir/status/*
GETINFO traffic/read
GETINFO traffic/written
QUIT
EOF

$SCRIPT = "AUTHENTICATE \"$PASSWORD\"\n".$SCRIPT;

push @DATA,["version",$VERSION];

my $tor = IO::Socket::UNIX->new(
	Type => SOCK_STREAM(),
	Peer => "/var/run/tor/control"
) or die "ERROR: Can not open unixsock '/var/run/tor/control'. $!\n";

my $RESULT;

print $tor $SCRIPT;
while(my $line = <$tor>){$RESULT = "$RESULT$line";}
$RESULT =~ s/\r\n/\n/g;

#Auth ERROR
if ($RESULT =~ m/515 Authentication failed:(.+)\n/m){die "ERROR: Authentication failed: $1\n";}

#DEBUG print return value
zs_debug("--------------[RETURN]--------------",1,{%PARAM});
zs_debug($RESULT,1,{%PARAM});
zs_debug("------------------------------------",1,{%PARAM});

#Calculate circuit-status
my $CIRCUIT = extract_msg($RESULT,"circuit-status");
if ( defined $CIRCUIT) {
	my @STATUS   = (
		"LAUNCHED",
		"BUILT",
		"EXTENDED",
		"FAILED",
		"CLOSED"
	);

	my @CALC = calculate_status ($CIRCUIT,\@STATUS);

	my $TOTAL    = linecount($CIRCUIT);
	push @DATA,["circuit.total",$TOTAL];

	my $SUM = 0;
	for(my $I=0;$I <= $#STATUS;$I++){
		$SUM += $CALC[$I];
		push @DATA,["circuit.$STATUS[$I]",$CALC[$I]];
	}

	unless ($TOTAL == $SUM){
		zs_debug("WARNING: Unknown CircStatus. msg: '$CIRCUIT'",0,{%PARAM});
	}
}

#Calculate stream-status
my $STREAM = extract_msg($RESULT,"stream-status");
if ( defined $STREAM) {
	my @STATUS = (
		"NEW",
		"NEWRESOLVE",
		"REMAP",
		"SENTCONNECT",
		"SENTRESOLVE",
		"SUCCEEDED",
		"FAILED",
		"CLOSED",
		"DETACHED"
	);

	my @CALC = calculate_status ($STREAM,\@STATUS);

	my $TOTAL = linecount($STREAM);
        push @DATA,["stream.total",$TOTAL];

        my $SUM = 0;
        for(my $I=0;$I <= $#STATUS;$I++){
                $SUM += $CALC[$I];
                push @DATA,["stream.$STATUS[$I]",$CALC[$I]];
        }

        unless ($TOTAL == $SUM){
                zs_debug("WARNING: Unknown StreamStatus. msg: '$STREAM'",0,{%PARAM});
        }
}


#Calculate orconn-status
my $ORCONN = extract_msg($RESULT,"orconn-status");
if ( defined $ORCONN) {
	my @STATUS = (
		"NEW",
		"LAUNCHED",
		"CONNECTED",
		"FAILED",
		"CLOSED"
	);
	
	my @CALC = calculate_status ($ORCONN."\n",\@STATUS);

	my $TOTAL = linecount($ORCONN);
        push @DATA,["orconn.total",$TOTAL];

        my $SUM = 0;
        for(my $I=0;$I <= $#STATUS;$I++){
                $SUM += $CALC[$I];
                push @DATA,["orconn.$STATUS[$I]",$CALC[$I]];
        }

        unless ($TOTAL == $SUM){
                zs_debug("WARNING: Unknown ORStatus. msg: '$ORCONN'",0,{%PARAM});
        }
}

#Calculate entry-guards
my $ENTRY = extract_msg($RESULT,"entry-guards");
if ( defined $ENTRY) {
        my @STATUS = (
                "up",
                "never-connected",
                "down",
                "unusable",
                "unlisted"
        );

        my @CALC = calculate_status ($ENTRY."\n",\@STATUS);

        my $TOTAL = linecount($ENTRY);
        push @DATA,["entry.total",$TOTAL];

        my $SUM = 0;
        for(my $I=0;$I <= $#STATUS;$I++){
                $SUM += $CALC[$I];
		$STATUS[$I] =~ s/-/_/g;
                push @DATA,["entry.$STATUS[$I]",$CALC[$I]];
        }

        unless ($TOTAL == $SUM){
                zs_debug("WARNING: Unknown entry-guards status. msg: '$ENTRY'",0,{%PARAM});
        }
}



#Calculate network-status
my $NETWORK = extract_msg($RESULT,"network-status");
if ( defined $NETWORK) {

        my $TOTAL = linecount($NETWORK);
        push @DATA,["network.total",$TOTAL];

	zs_debug("INFO: network-status not empty. msg: '$NETWORK'",0,{%PARAM}) if ($TOTAL>0);
}

#Calculate dir/status/*
my $DIR = extract_msg($RESULT,"dir\\/status\\/\\*");
if ( defined $DIR) {

        my $TOTAL = linecount($DIR);
        push @DATA,["dir.total",$TOTAL];

        zs_debug("INFO: dir/status/* not empty. msg: '$DIR'",0,{%PARAM}) if ($TOTAL>0);
}


#Extract traffic/read
my $READ = extract_msg($RESULT,"traffic/read");
if ( defined $READ){ 
	push @DATA,["traffic.read",$READ];
}

#Extract traffic/written
my $WRITTEN = extract_msg($RESULT,"traffic/written");
if ( defined $WRITTEN){  
        push @DATA,["traffic.written",$WRITTEN];
}

print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});

