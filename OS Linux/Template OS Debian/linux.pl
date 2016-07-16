#!/usr/bin/perl -w
#Template: Template OS Debian
#Place:    /usr/lib/zabbix/agentscripts

require "/usr/lib/zabbix/zsender.pl";

my $VERSION = "1.1.4";
my %PARAM = (DEBUG => 0, NOSEND => 0);
my $PRESTR = "script.linux.";
my @DATA = ();

my @FILES = (
	"/proc/net/if_inet6",
	"/etc/krb5.conf",
	"/etc/nsswitch.conf",
	"/etc/pam.d/common-account",
	"/etc/pam.d/common-auth",
	"/etc/pam.d/common-session",
	"/etc/samba/smb.conf",
	"/etc/resolv.conf",
	"/etc/network/interfaces",
	"/etc/iptables.rule.up",
	"/etc/ntp.conf",
	"/etc/ssh/sshd_config");

my @FILESUDO = (
	"/etc/shadow",
	"/etc/sudoers",
	"/etc/sssd/sssd.conf",
	"/etc/iptables/rules.v4",
        "/etc/iptables/rules.v6");

my @FILEBIN = (
	"/usr/sbin/sshd",
	"/usr/lib/x86_64-linux-gnu/sssd/sssd_be",
	"/usr/sbin/ntpd");

push @DATA,[ "version", $VERSION ];
push @DATA,[ "zsender.version", zs_version() ];

foreach $FILE (@FILES){
	$FILENAME = ( split m{/}, $FILE )[-1];
	push @DATA,[ "cksum.$FILENAME" , zs_system("cat $FILE | grep -v \"^#\" | grep -v \"^\\s*\$\" | cksum | cut -d' ' -f1",{%PARAM}) ] if -f $FILE;
}

foreach $FILE (@FILESUDO){
        $FILENAME = ( split m{/}, $FILE )[-1];
	push @DATA,[ "cksum.$FILENAME" , zs_system("sudo cat $FILE | grep -v \"^#\" | grep -v \"^\\s*\$\" | cksum | cut -d' ' -f1",{%PARAM}) ] if -f $FILE;
}

foreach $FILE (@FILEBIN){
	$FILENAME = ( split m{/}, $FILE )[-1];
	push @DATA,["cksum.$FILENAME", zs_system("cksum $FILE | cut -d' ' -f1",{%PARAM})] if -f $FILE;
}

#Вычисление cksum всех ключей ssh
push @DATA,["cksum.ssh.key",zs_system("sudo cat /etc/ssh/*key* | cksum | cut -d' ' -f1",{%PARAM})];

push @DATA,["iptables.firewall",zs_system("sudo iptables -L -n |cksum | cut -d' ' -f1",{%PARAM})];
push @DATA,["iptables.mangle",zs_system("sudo iptables -L -n -t mangle |cksum  | cut -d' ' -f1",{%PARAM})];
push @DATA,["iptables.nat",zs_system("sudo iptables -L -n -t nat |cksum | cut -d' ' -f1",{%PARAM})];
push @DATA,["iptables.all",zs_system("{ sudo iptables -L -n -t nat; sudo iptables -L -n -t mangle; sudo iptables -L -n; }| cksum | cut -d' ' -f1",{%PARAM})];

#Мониторинг правил IPv6
push @DATA,["ip6tables.firewall",zs_system("sudo ip6tables -L -n |cksum | cut -d' ' -f1",{%PARAM})];
push @DATA,["ip6tables.mangle",zs_system("sudo ip6tables -L -n -t mangle |cksum  | cut -d' ' -f1",{%PARAM})];
push @DATA,["ip6tables.nat",zs_system("sudo ip6tables -L -n -t nat |cksum | cut -d' ' -f1",{%PARAM})];
push @DATA,["ip6tables.all",zs_system("{ sudo ip6tables -L -n -t nat; sudo ip6tables -L -n -t mangle; sudo ip6tables -L -n; }| cksum | cut -d' ' -f1",{%PARAM})];

#Получаем количество не установленных апдейтов
push @DATA,["numupdates", zs_system("aptitude search '~U' | grep -v \"^ih\" | wc -l",{%PARAM})];

#Проверяем необходимость перезагрузки
push @DATA,["reboot",( -f "/var/run/reboot-required" || 0)];

#Check exim paniclog
push @DATA,["exim4.paniclog",( -f "/var/log/exim4/paniclog" || 0)];

my $RESULT = zs_zsender_arr($PRESTR,\@DATA,{%PARAM});
print $RESULT;

