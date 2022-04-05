#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5

#editthis version:8.2.2

use strict;
use warnings;

use Config;
use File::Spec;

my $vers = "8.2.2";
my ($lwp,$okLWP,$lagent,$ua,$u,$auth,$capture,$curl,$daemon,$dropbox,$status,$ebay,$resp,$lsimple,$mails,$mime,$esimple,$sender,$sendmail,$esender,$encode,$creator,$transport,$ios,$iostr,$ole,$smtp,$config,$filestat,$filefind,$filepath,$fileglob,$util,$filecopy,$filetmp,$cgi,$cgiescape,$cgicarp,$dumper,$encode2,$uri,$filebase,$filespec,$hreq,$jsn,$scalar,$sobj,$tloc,$face,$twit,$tiny,$mmap,$imager,$jsmin,$csmin,$whtm,$zip);

my $envpath = File::Spec->rel2abs( __FILE__ );
$envpath =~ s/(\/cgi\-bin|\/cgi)\/.*?$/$1/;
our $cgix = $1."/";
our $uaref = "";
our $http = ( $ENV{'HTTPS'} )?"https:":"http:";
###

eval "use LWP";$lwp = $@?0:1;
eval "use LWP::Simple";$lsimple = $@?0:1;
eval "use LWP::UserAgent";$lagent = $@?0:1;
if($lsimple && $lagent){
use HTTP::Request;
$u = $http."//".$ENV{'HTTP_HOST'}."/index.html";
my $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 },timeout => 30);
my $req = HTTP::Request->new( GET => $u);
$resp = $ua->request($req);
$uaref = $ua->agent;
my $rr = $resp->content;
$okLWP = (defined $rr && $rr =~ /ok/i)?'<b style="color:#0a9;">OK ('.$u.')':'<b style="color:#c00;">FAILED: '.$rr.' = '.$resp->code.' ('.$u.')';	
}

eval "use Mail::Sender"; $mails = $@?0:1;
eval "use MIME::Entity"; $mime = $@?0:1;
eval "use Email::Simple"; $esimple = $@?0:1;if( $esimple ){ eval "use Email::Simple::Creator"; $creator = $@?0:1; }
eval "use Email::Sender"; $esender = $@?0:1;
if( $esender ){ eval "use Email::Sender::Simple"; $sender = $@?0:1;eval "use Email::Sender::Transport::SMTP"; $transport = $@?0:1; }
eval "use Net::SMTP"; $smtp = $@?0:1;if( $smtp ){ eval "use Authen::SASL";$auth = $@?0:1; }
eval "use Net::Config"; $config = $@?0:1;
eval "use Mail::Sendmail"; $sendmail = $@?0:1;
eval "use File::stat"; $filestat = $@?0:1;
eval "use File::Find"; $filefind = $@?0:1;
eval "use File::Path"; $filepath = $@?0:1;
eval "use File::Copy"; $filecopy = $@?0:1;
eval "use File::Glob"; $fileglob = $@?0:1;
eval "use CGI"; $cgi = $@?0:1;
eval "use CGI qw/escape unescape/"; $cgiescape = $@?0:1;
eval "use URI::Encode"; $encode = $@?0:1;
eval "use URI::Escape"; $uri = $@?0:1;
eval "use CGI::Carp qw(fatalsToBrowser)"; $cgicarp = $@?0:1;
eval "use Data::Dumper"; $dumper = $@?0:1;
eval "use Encode"; $encode2 = $@?0:1;
eval "use File::Basename"; $filebase = $@?0:1;
eval "use File::Spec"; $filespec = $@?0:1;
eval "use File::Map"; $mmap = $@?0:1;
eval "use HTTP::Request::Common"; $hreq = $@?0:1;
eval "use JSON"; $jsn = $@?0:1;
eval "use List::Util"; $util = $@?0:1;
eval "use Scalar::Util"; $scalar = $@?0:1;
eval "use Time::Local"; $tloc = $@?0:1;
eval "use Try::Tiny"; $tiny = $@?0:1;
eval "use eBay::API::Simple"; $ebay = $@?0:1;
eval "use Facebook::OpenGraph"; $face = $@?0:1;
eval "use Net::Twitter::Lite::WithAPIv1_1"; $twit = $@?0:1;
eval "use Imager"; $imager = $@?0:1;
eval "use XML::SimpleObject"; $sobj = $@?0:1;
eval "use Archive::Zip"; $zip = $@?0:1;
eval "use File::Temp"; $filetmp = $@?0:1;
eval "use HTTP::Daemon::SSL"; $daemon = $@?0:1;
eval "use HTTP::Status"; $status = $@?0:1;
eval "use IO::Socket::SSL"; $ios = $@?0:1;
eval "use WWW::Curl";$curl = $@?0:1;
eval "use JavaScript::Packer";$jsmin = $@?0:1;
eval "use CSS::Minifier";$csmin = $@?0:1; 
eval "use WebService::Dropbox";$dropbox = $@?0:1; 
#eval "use IO::String";$iostr = $@?0:1;
#eval "use Capture::Tiny"; $capture = $@?0:1;
#eval "use WKHTMLTOPDF";$whtm = $@?0:1;
###

my $w = 35; 
my $f = "<b>%" . $w . "s</b> : %s\n"; 
my $f2 = " " x $w . " & %s\n";

print "Content-type: text/html\n\n";

print "<html><body><pre>";

printf $f, "Server","<b>$ENV{'HTTP_HOST'}</b><br />";
printf $f, "protocol",$ENV{'HTTPS'}." = ".$http;
printf $f, "editthis","v$vers";
printf $f, "OS",$Config{osname};
printf $f, "Version",$Config{archname};
printf $f, "Perl", "v$]";
printf $f, "envpath",$envpath;
printf $f, "CGI",$cgix;
printf $f, "Script User",getpwuid( $< );

print "<br />";

printf $f, "Required Modules"," ";
printf $f, "CGI", ($cgi? "v$CGI::VERSION " : "not ")."installed";
printf $f, "CGI::Carp", ($cgicarp? "v$CGI::Carp::VERSION " : "not ")."installed";
printf $f, "Data::Dumper", ($dumper? "v$Data::Dumper::VERSION " : "not ")."installed";
printf $f, "Encode",($encode2? "v$Encode::VERSION " : "not ")."installed";
printf $f, "File::Basename",($filebase? "v$File::Basename::VERSION " : "not ")."installed";
printf $f, "File::Copy", ($filecopy? "v$File::Copy::VERSION " : "not ")."installed";
printf $f, "File::Find", ($filefind? "v$File::Find::VERSION " : "not ")."installed";
#printf $f, "File::Map",($mmap? "v$File::Map::VERSION " : "not ")."installed";
printf $f, "File::Glob", ($fileglob? "v$File::Glob::VERSION " : "not ")."installed";
printf $f, "File::Path", ($filepath? "v$File::Path::VERSION " : "not ")."installed";
printf $f, "File::Spec",($filespec? "v$File::Spec::VERSION " : "not ")."installed";
printf $f, "File::stat", ($filestat? "v$File::stat::VERSION " : "not ")."installed";
printf $f, "HTTP::Request::Common",($hreq? "v$CGI::VERSION " : "not ")."installed";
printf $f, "JSON",($jsn? "v$JSON::VERSION " : "not ")."installed";
printf $f, "List::Util",($util? "v$List::Util::VERSION " : "not ")."installed";
printf $f, "LWP", ($lwp? "v$LWP::VERSION " : "not ")."installed";
printf $f, "LWP::Simple", ($lsimple? "v$LWP::Simple::VERSION " : "not ")."installed".( ( $lsimple )?" - receive test: ".$okLWP."</b>":"" ); 
printf $f, "LWP UA",$uaref;
printf $f, "Scalar::Util",($scalar? "v$Scalar::Util::VERSION " : "not ")."installed";
printf $f, "Time::Local",($tloc? "v$Time::Local::VERSION " : "not ")."installed";
printf $f, "Try::Tiny",($tiny? "v$Try::Tiny::VERSION " : "not ")."installed";
printf $f, "URI::Encode", ($encode? "v$URI::Encode::VERSION " : "not ")."installed";
printf $f, "URI::Escape", ($uri? "v$URI::Escape::VERSION " : "not ")."installed";

print "<br />";

printf $f,"Any One of these Email Modules"," ";
printf $f, "Net::SMTP", ($smtp? "v$Net::SMTP::VERSION " : "not ")."installed";
if( $auth ){ 
printf $f, "Authen::SASL", ($auth? "v$Authen::SASL::VERSION " : "not ")."installed"; 
}
printf $f, "Net::Config", ($config? "v$Net::Config::VERSION " : "not ")."installed";
printf $f, "MIME::Entity", ($mime? "v$MIME::Entity::VERSION " : "not ")."installed";
printf $f, "Mail::Sendmail", ($sendmail? "v$Mail::Sendmail::VERSION " : "not ")."installed";
printf $f, "Email::Simple", ($esimple? "v$Email::Simple::VERSION " : "not ")."installed";
if( $esimple ){ 
printf $f, "Email::Simple::Creator", ($creator? "v$Email::Simple::Creator::VERSION " : "not ")."installed"; 
}

print "<br />";

printf $f,"Possible Other Email Modules"," ";
printf $f, "Mail::Sender", ($mails? "v$Mail::Sender::VERSION " : "not ")."installed";
printf $f, "Email::Sender::Simple", ($esender? "v$Email::Sender::Simple::VERSION " : "not ")."installed";
if( $esender ){
printf $f, "Email::Sender::Transport::SMTP", ($transport? "v$Email::Sender::Transport::SMTP::VERSION " : "not ")."installed";
}

print "<br />";

printf $f,"Optional Functionality Modules","";
printf $f, "Archive::Zip", ($zip? "v$Archive::Zip::VERSION " : "not ")."installed";
printf $f, "Blogger: XML::SimpleObject", ($sobj? "v$XML::SimpleObject::VERSION " : "not ")."installed";
printf $f, "CSS::Minifier", ($csmin? "v$CSS::Minifier::VERSION " : "not ")."installed";
printf $f, "eBay::API::Simple", ($face? "v$eBay::API::Simple::VERSION " : "not ")."installed";
printf $f, "Facebook::OpenGraph", ($face? "v$Facebook::OpenGraph::VERSION " : "not ")."installed";
printf $f, "File::Temp", ($filetmp? "v$File::Temp::VERSION " : "not ")."installed";
printf $f, "Imager", ($imager? "v$Imager::VERSION " : "not ")."installed";
printf $f, "IO::Socket::SSL", ($ios? "v$IO::Socket::SSL::VERSION " : "not ")."installed";
printf $f, "HTTP::Daemon::SSL", ($daemon? "v$HTTP::Daemon::SSL::VERSION " : "not ")."installed";
printf $f, "HTTP::Status", ($daemon? "v$HTTP::Status::VERSION " : "not ")."installed";
printf $f, "JavaScript::Packer", ($jsmin? "v$JavaScript::Packer::VERSION " : "not ")."installed";
printf $f, "Net::Twitter::Lite::WithAPIv1_1", ($twit? "v$Net::Twitter::Lite::WithAPIv1_1::VERSION " : "not ")."installed";
printf $f, "WebService::Dropbox", ($dropbox? "v$WebService::Dropbox::VERSION " : "not ")."installed";
printf $f, "WWW::Curl", ($curl? "v$WWW::Curl::VERSION " : "not ")."installed";
#printf $f, "IO::String", ($iostr? "v$IO::String::VERSION " : "not ")."installed";
#printf $f, "WKHTMLTOPDF", ($whtm? "v$WKHTMLTOPDF::VERSION " : "not ")."installed";
#printf $f, "Capture::Tiny", ($capture? "v$Capture::Tiny::VERSION " : "not ")."installed";

print "<br />";

printf $f,"Library Locations"," ";
#print $f, "CONF{smtp}", (defined $CONF && defined $CONF->{smtp} && defined $CONF->{smtp}->{enabled}? "" : "not " )."enabled";
printf $f, "\@INC", $INC[0]; foreach my $x (1..$#INC){ printf $f2, $INC[$x]; }

#
#my $dir = "/var/www/vhosts/parkhouse-evans.co.uk/httpdocs/sites/thatsthat/LIB/css/";
#opendir my($dh), $dir or print "Couldn't open directory '$dir': $!";
#my @files = grep { !/^\.\.?$/ } readdir $dh;
#closedir $dh;
#print "<br />".(join ",",@files)."<br />";
#

print "<br />";

printf $f,"Environment Variables"," ";
foreach my $y (sort split(",","DOCUMENT_ROOT,PATH_TRANSLATED,SERVER_NAME,SERVER_ADDR,LOCAL_ADDR,PATH_INFO,SCRIPT_FILENAME,REQUEST_FILENAME,HTTP_HOST,HTTP_REFERER,SERVER_SOFTWARE,SERVER_ADMIN")){ 
printf $f, $y, $ENV{$y} if defined $ENV{$y}; 
}

print "<br /></pre></body></html>\n";

exit;