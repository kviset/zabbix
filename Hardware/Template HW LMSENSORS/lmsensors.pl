#!/usr/bin/perl -w
#Template:	Template HW LMSENSORS
#Config:	conf.nix/lmsensos.conf
#Place:		/usr/lib/zabbix/agentscipts
#Depends: 	aptitude install lm-sensors

require "/usr/lib/zabbix/zsender.pl";
#use Data::Dump qw(dump);

my $VERSION	= "1.0.2";
my $MODE	= shift || "run";

my %PARAM = (DEBUG => 0, NOSEND => 0);
my $PRESTR = "script.lmsensors";

sub m_send{

	my @DATA = ();

	push @DATA,["version",$VERSION];

	my $RESULT = zs_system("sensors -A -u",{%PARAM});
	my @BUS  = split /\n\n/, $RESULT;

	foreach $SENSOR  (@BUS){
                my ($NAME) = $SENSOR =~ /^(.*?)$/m;
		my @TEMP = ($SENSOR =~ /\s+(temp\d+_input):/mg);
		my @VALUE = ($SENSOR =~ /\s+temp\d+_input:\s+([0-9|\.]+)/mg);

		for (my $I=0; $I <=$#TEMP; $I++){push @DATA,["temp[$NAME.$TEMP[$I]]",$VALUE[$I]]}
        }

	print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

sub m_discovery{

	my @VARNAME 	= ("NAME","CRIT","WARN");
	my @DATA 	= ();

	my $RESULT = zs_system("sensors -A -u",{%PARAM});
	my @BUS  = split /\n\n/, $RESULT;

#	my @BUS = ("coretemp-isa-0000\nCore 0:\n  temp2_input: 61.000\n  temp2_max: 85.000\n  temp2_crit: 95.000\n  temp2_crit_alarm: 0.000\nCore 1:\n  temp3_input: 61.000\n  temp3_max: 85.000\n  temp3_crit: 95.000\n  temp3_crit_alarm: 0.000\nCore 9:\n  temp11_input: 62.000\n  temp11_max: 85.000\n  temp11_crit: 95.000\nCore 10:\n  temp12_input: 63.000\n  temp12_max: 85.000\n  temp12_crit: 95.000");

	foreach $SENSOR  (@BUS){
		my ($NAME) = $SENSOR =~ /^(.*?)$/m;
		my @TEMP = ($SENSOR =~ /\s+(temp\d+_input):/mg);
		my @CRIT = ($SENSOR =~ /\s+temp\d+_crit:\s+([0-9|\.]+)/mg);
		my @WARN = ($SENSOR =~ /\s+temp\d+_max:\s+([0-9|\.]+)/mg);
		
		for (my $I=0; $I <=$#TEMP; $I++){
			unless(defined $WARN[$I]){$WARN[$I] = 0;}
			push @DATA,["$NAME.$TEMP[$I]",$CRIT[$I],$WARN[$I]]
		}
	}

	print zs_discovery_2darr(\@VARNAME,\@DATA,{%PARAM});
}

if ($MODE eq "discovery"){
        m_discovery();
}else{
        m_send();
}

