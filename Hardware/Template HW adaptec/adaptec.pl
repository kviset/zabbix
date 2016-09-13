#!/usr/bin/perl -w
#Template:	Template HW adaptec
#Config:	conf.nix/adaptec.conf
#Place:		/usr/lib/zabbix/agentscipts
#Depends: 	aptitude install

require "/usr/lib/zabbix/zsender.pl";
use Data::Dump qw(dump);

my $VERSION	= "0.0.0";
my $MODE	= shift || "run";

my %PARAM = (DEBUG => 0, NOSEND => 0);
my $PRESTR = "script.adaptec";

sub get_controllers{

        my $RESULT = zs_system("sudo /sbin/arcconf LIST",{%PARAM});
        my ($INFO) = $RESULT =~ /\n-+\nController information\n-+\n.*?\n-+\n(.*)\n\n/ms;
        my @CTRLS = $INFO =~ /\s+(Controller \d+):\s+/mg;

	return @CTRLS;
}

sub m_send{

	my @DATA = ();

	push @DATA,["version", $VERSION];

	my @CTRLS = get_controllers();
	for(my $I = 0; $I <= $#CTRLS; $I++){
		my $CONTROLLER = $I+1;
                my $RESULT = zs_system("sudo /sbin/arcconf GETCONFIG $CONTROLLER",{%PARAM});
		
		my ($INFO) = $RESULT =~ /\n-+\nController information\n-+\n(.*?)\n\n/ms;
		
		my ($temp) = $INFO =~ /^\s+Controller Status\s+:\s+(\w+)\n/;
		push @DATA,["status[$CONTROLLER]",$temp];
		
                ($temp) = $INFO =~ /\n\s+Controller Model\s+:\s+([\w\s]+)\n/;
                push @DATA,["model[$CONTROLLER]",$temp];

                ($temp) = $INFO =~ /\n\s+Controller Serial Number\s+:\s+([\d\w]+)\n/;
                push @DATA,["serial[$CONTROLLER]",$temp];

                ($temp) = $INFO =~ /\n\s+Temperature\s+:\s+(\d+) C/;
                push @DATA,["temperature[$CONTROLLER]",$temp];

                ($temp) = $INFO =~ /\n\s+Defunct disk drive count\s+:\s+(\d+)\n/;
                push @DATA,["defunctdisk[$CONTROLLER]",$temp];

                my ($logicd,$failedd,$degraded) = $INFO =~ /\n\s+Logical devices\/Failed\/Degraded\s+:\s+(\d+)\/(\d+)\/(\d+)\n/;
                push @DATA,["logicdrive[$CONTROLLER]",$logicd];
		push @DATA,["logicfailed[$CONTROLLER]",$failedd];
		push @DATA,["logicdegrad[$CONTROLLER]",$degraded];

		($temp) = $INFO =~ /\n\s+BIOS\s+:\s+(.+)\n/;
		push @DATA,["biosversion[$CONTROLLER]",$temp];

                ($temp) = $INFO =~ /\n\s+Firmware\s+:\s+(.+)\n/;
                push @DATA,["firmwareversion[$CONTROLLER]",$temp];

                ($temp) = $INFO =~ /\n\s+Driver\s+:\s+(.+)\n/;
                push @DATA,["driverversion[$CONTROLLER]",$temp];

                ($temp) = $INFO =~ /\n\s+Boot Flash\s+:\s+(.+)\n/;
                push @DATA,["bootversion[$CONTROLLER]",$temp];

                ($temp) = $INFO =~ /\n\s+Status\s+:\s+(.+)\n?/;
                push @DATA,["battarystatus[$CONTROLLER]",$temp];

        }


	print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

sub m_discovery{

	my @VARNAME 	= ("NAME","ID");
	my @DATA 	= ();

	my @CTRLS = get_controllers();

	for(my $I = 0; $I <= $#CTRLS; $I++){
		push @DATA,[$CTRLS[$I],($I+1)];
	}

	print zs_discovery_2darr(\@VARNAME,\@DATA,{%PARAM});
}

if ($MODE eq "discovery"){
        m_discovery();
}else{
        m_send();
}

