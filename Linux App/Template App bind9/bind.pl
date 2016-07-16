#!/usr/bin/perl -w
#Template: Template App bind9
#Config:   conf.nix/bind9.conf
#Place:    /usr/lib/zabbix/agentscripts
#Depends:  aptitude install xml2 curl
#          zsender.pl 0.3.3

#use Data::Dump qw(dump);
use Time::Local; 

require "/usr/lib/zabbix/zsender.pl";

my $VERSION		= "0.0.2";

my $ZABBIX_HOSTNAME 	= shift || undef;

my %PARAM = (DEBUG => 0, NOSEND => 0);
my $PRESTR = "script.bind";
my @DATA = ();

my @QUERIES = ("A","AAAA","ANY","CNAME","MX","NS","PTR","SOA","SPF","TXT","SRV");
my @STATS   = ("AuthAns","Dropped","Duplicate","Failure","FORMERR","NoauthAns","NXDOMAIN","Nxrrset","Recursion","Referral","SERVFAIL","Success");

sub preparer{
	my %HASH = %{shift()};
	my @FILTER = @{shift()};
	my $STR    = shift;

	my $SUM = 0;
	while ( my ($key, $value) = each(%HASH) ) {
        	$SUM += $value;
	    }
	push @DATA,["$STR\[total\]",$SUM];

	foreach $QUERIE (@FILTER){
	        if (defined $HASH{$QUERIE}){
        	        push @DATA,["$STR\[$QUERIE\]",$HASH{$QUERIE}];
                	$HASH{$QUERIE} = 0;
	        }else{
        	        push @DATA,["$STR\[$QUERIE\]",0];
	        }
	}

	$SUM = 0;
	while ( my ($key, $value) = each(%HASH) ) {
        	$SUM += $value;
	}
	push @DATA,["$STR\[other\]",$SUM];
}

############# MAIN #############

if (defined $ZABBIX_HOSTNAME) { $PARAM{'ZABBIX_HOSTNAME'}=$ZABBIX_HOSTNAME;}

push @DATA,["version",$VERSION];

my $STATS = zs_system("curl -s http://localhost:8053/ 2>/dev/null| xml2",{%PARAM});

#Parse in queries
my @INQUERIE = $STATS =~ /\/isc\/bind\/statistics\/server\/queries-in\/rdtype\/name=(.*)\n\/isc\/bind\/statistics\/server\/queries-in\/rdtype\/counter=(\d+)\n/mg;
my %INQUERIEHASH = @INQUERIE;

preparer (\%INQUERIEHASH,\@QUERIES,"queries.in");


#Parse out queries
my @OUTQUERIE = $STATS =~ /\/isc\/bind\/statistics\/views\/view\/rdtype\/name=(.*)\n\/isc\/bind\/statistics\/views\/view\/rdtype\/counter=(\d+)\n/mg;
my %OUTQUERIEHASH = @OUTQUERIE;

preparer (\%OUTQUERIEHASH,\@QUERIES,"queries.out");

#Parse cache queries
my @CACHEQUERIE = $STATS =~ /\/isc\/bind\/statistics\/views\/view\/cache\/rrset\/name=(.*)\n\/isc\/bind\/statistics\/views\/view\/cache\/rrset\/counter=(\d+)\n/mg;
my %CACHEQUERIEHASH = @CACHEQUERIE;

my $SUM = 0;
while ( my ($key, $value) = each(%CACHEQUERIEHASH) ) { $SUM += $value; }
push @DATA,["queries.cache[total]",$SUM];

#Parse states
my @STATES = $STATS =~ /\/isc\/bind\/statistics\/server\/nsstat\/name=(.*)\n\/isc\/bind\/statistics\/server\/nsstat\/counter=(\d+)\n/mg;
my %STATESHASH = @STATES;

while ( my ($key, $value) = each(%STATESHASH) ) {
	push @DATA,["stats.query[$key]",$value];
}

#Uptime
my @LOADTIME = $STATS =~/\/isc\/bind\/statistics\/server\/boot-time=(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z/mg;

push @DATA,["uptime",(time - timelocal($LOADTIME[5],$LOADTIME[4],$LOADTIME[3],$LOADTIME[2],$LOADTIME[1]-1,$LOADTIME[0]))];

push @DATA,["net.udp",zs_system("sudo netstat -nua | grep \":53\\s\" | wc -l",{%PARAM})];
push @DATA,["net.tcp",zs_system("netstat -nta | grep \":53\\s\" | wc -l",{%PARAM})];

#Get named proc num
push @DATA,["proc.num",zs_system("ps  -C named |tail -n +2 |wc -l",{%PARAM})];

#Send data
my $RESULT = zs_zsender_arr($PRESTR,\@DATA,{%PARAM});

print $RESULT;

