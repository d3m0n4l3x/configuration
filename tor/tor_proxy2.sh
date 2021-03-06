#!/usr/bin/perl -w
#A network hidden script through Tor and Privoxy. Written by demonalex.
$|=1;

if( -e '/etc/init.d/tor'){
	print "Tor: Installed!\n";
}else{
	die "Tor: Not installed! Please install Tor through \'apt-get update\; apt-get install tor\'!\n";
}

print "Starting Tor...\n";
system('/etc/init.d/tor start 2>/dev/null');

sleep(2);

print "Check Tor\'s status...";
$output=sprintf(`netstat -anteup|grep tor|grep \'127.0.0.1:9050\'|wc -l`);
chop($output);
if($output==1){
	print "ok!\n";
}else{
	die "failed!\n";
}

if ( -e '/etc/init.d/privoxy'){
	print "Privoxy: Installed!\n";
}else{
	die "Privoxy: Not installed! Please install Privoxy through \'apt-get update\; apt-get install privoxy\'!\n";
}

print "Checking Privoxy\'s configuration...\n";
$output=sprintf(`cat /etc/privoxy/config|grep forward-socks5|grep -v \'#\'|wc -l`);
chop($output);
if($output==0){
	die "forward-socks5 has not been tweaked yet!\n";
}
$output=sprintf(`cat /etc/privoxy/config|grep \'\\[::1\\]:8118\'|grep -v \'#\'|wc -l`);
chop($output);
if($output!=0){
	die "listen-address IPv6 has not been disabled yet!\n";
}
print "Complete!\n";

print "Starting Privoxy...\n";
system('/etc/init.d/privoxy start 2>/dev/null');

sleep(2);

print "Check Privoxy\'s status...";
$output=sprintf(`netstat -anteup|grep \'127.0.0.1:8118\'|wc -l`);
chop($output);
if($output==1){
	print "ok!\n";
}else{
	die "failed!\n";
}

print "Check ProxyChains's status...";
if(!( -e '/etc/proxychains.conf')){
	print "ProxyChains does not exist!\n";
}else{
	$output=`cat /etc/proxychains.conf |grep sock | grep -v \'\#\'|grep \'127.0.0.1\' | grep 9050|wc -l`;
	chop($output);
	if($output>=1){
		print "okay!\n";
		$proxychains=1;
	}else{
		print "Tor proxy has not been added yet!\n";
	}
}

print <<EndOutput;

HTTP/S Proxy: 127.0.0.1:8118
Socks5 Proxy: 127.0.0.1:9050
EndOutput

if($proxychains==1){
	print 'ProxyChains: #proxychains COMMAND'."\n";
	print "Such as: #proxychains curl ipv4.icanhazip.com"."\n\n";
}else{
	print "\n\n";
}

exit(0);
