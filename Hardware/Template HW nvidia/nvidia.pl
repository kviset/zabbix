#!/usr/bin/perl -w
#Template:	Template HW nvidia
#Config:	conf.nix/nvidia.conf
#Place:		/usr/lib/zabbix/agentscipts
#Depends: 	aptitude install nvidia-smi libxml-simple-perl

require "/usr/lib/zabbix/zsender.pl";
use Data::Dump qw(dump);
use XML::Simple;

my $VERSION	= "0.0.0";
my $MODE	= shift || "run";

my %PARAM = (DEBUG => 0, NOSEND => 0);
my $PRESTR = "script.nvidia";

sub nvidia_get {

	my $RESULT = zs_system("nvidia-smi -q -x",{%PARAM});

	my $XML = new XML::Simple;

	my $data = $XML->XMLin($RESULT);

	return $data;
}

sub m_send3600{
	my @DATA = ();

	push @DATA,["version",$VERSION];

        my $data = nvidia_get();
        foreach my $key (keys %{$data->{gpu}}){
		my $UUID = $data->{gpu}->{$key}->{uuid};

                my ($temp) = $data->{gpu}->{$key}->{bar1_memory_usage}->{total} =~ /(\d+)/;
                push @DATA,["bar1_memory_usage[$UUID,total]",$temp*1024*1024];

                ($temp) = $data->{gpu}->{$key}->{fb_memory_usage}->{total} =~ /(\d+)/;
                push @DATA,["fb_memory_usage[$UUID,total]",$temp*1024*1024];

		#get version
		push @DATA,["ecc_object_version[$UUID]",$data->{gpu}->{$key}->{inforom_version}->{ecc_object}];
		push @DATA,["img_version[$UUID]",$data->{gpu}->{$key}->{inforom_version}->{img_version}];
		push @DATA,["oem_object_version[$UUID]",$data->{gpu}->{$key}->{inforom_version}->{oem_object}];
		push @DATA,["vbios_version[$UUID]",$data->{gpu}->{$key}->{vbios_version}];

		#get serial
		push @DATA,["serial[$UUID]",$data->{gpu}->{$key}->{serial}];

	}

	print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

sub m_send{

	my @DATA = ();

	my $data = nvidia_get();
	foreach my $key (keys %{$data->{gpu}}){
		my $UUID = $data->{gpu}->{$key}->{uuid};

		#get current temperature
		my ($temp) = $data->{gpu}->{$key}->{temperature}->{gpu_temp} =~ /([\d\.]+)/;
		push @DATA,["temperature[$UUID]",$temp];

		#get ecc_errors
		push @DATA,["ecc_errors[$UUID,double_bit,total]",$data->{gpu}->{$key}->{ecc_errors}->{aggregate}->{double_bit}->{total}];
		push @DATA,["ecc_errors[$UUID,single_bit,total]",$data->{gpu}->{$key}->{ecc_errors}->{aggregate}->{single_bit}->{total}];

		#get bar1_memory_usage
		($temp) = $data->{gpu}->{$key}->{bar1_memory_usage}->{free} =~ /(\d+)/;
		push @DATA,["bar1_memory_usage[$UUID,free]",$temp*1024*1024];
		($temp) = $data->{gpu}->{$key}->{bar1_memory_usage}->{used} =~ /(\d+)/;
		push @DATA,["bar1_memory_usage[$UUID,used]",$temp*1024*1024];

		#get fb_memory_usage
                ($temp) = $data->{gpu}->{$key}->{fb_memory_usage}->{free} =~ /(\d+)/;
                push @DATA,["fb_memory_usage[$UUID,free]",$temp*1024*1024];
                ($temp) = $data->{gpu}->{$key}->{fb_memory_usage}->{used} =~ /(\d+)/;
                push @DATA,["fb_memory_usage[$UUID,used]",$temp*1024*1024];

		#get power
		($temp) = $data->{gpu}->{$key}->{power_readings}->{power_draw} =~ /(\d+)/;
		push @DATA,["power[$UUID]",$temp];

		#get utilization
		($temp) = $data->{gpu}->{$key}->{utilization}->{decoder_util} =~ /\d+/;
		push @DATA,["utilization[$UUID,decoder_util]",$temp];
                ($temp) = $data->{gpu}->{$key}->{utilization}->{encoder_util} =~ /\d+/;
                push @DATA,["utilization[$UUID,encoder_util]",$temp];
                ($temp) = $data->{gpu}->{$key}->{utilization}->{gpu_util} =~ /\d+/;
                push @DATA,["utilization[$UUID,gpu_util]",$temp];
                ($temp) = $data->{gpu}->{$key}->{utilization}->{memory_util} =~ /\d+/;
                push @DATA,["utilization[$UUID,memory_util]",$temp];
	}

	print zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
}

sub m_discovery{

	my @VARNAME 	= ("NAME","UUID","TCRIT");
	my @DATA 	= ();

	my $data = nvidia_get();

	my $count = 0;
	foreach my $key (keys %{$data->{gpu}}){
		my $NAME = ($data->{gpu}->{$key}->{product_name})."(".($count++).")";
		my $UUID = $data->{gpu}->{$key}->{uuid};
		my ($TCRIT)= $data->{gpu}->{$key}->{temperature}->{gpu_temp_max_threshold} =~ /(\d+)/;

		zs_debug ("NAME:\t'$NAME'",1,{%PARAM});
		zs_debug ("UUID:\t'$UUID'",1,{%PARAM});
		zs_debug ("TCRIT:\t'$TCRIT'",1,{%PARAM});

		push @DATA,[$NAME, $UUID, $TCRIT];
	}

	print zs_discovery_2darr(\@VARNAME,\@DATA,{%PARAM});
}

if ($MODE eq "discovery"){
        m_discovery();
}elsif($MODE eq "run3600"){
	m_send3600();
}else{
        m_send();
}

