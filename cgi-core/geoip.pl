#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5

#editthis version:8.2.2 EDGE

use strict;
#use warnings;

use CGI;
use CGI qw/escape unescape/;
use CGI::Carp qw(fatalsToBrowser);
use File::Basename;
use File::Spec;
use Scalar::Util 'blessed';
use Time::Local;
use Data::Dumper;

my $envpath = "";
our $cgix = "";
our $incerr = "";

our $geourl = "http://api.ipstack.com/";
our $geoip = "";
our $geokey = "?access_key=3c5eca3a6247c67eb916be0c35d1e717&output=json&fields=ip,country_code,country_name";
our $http = "http";

our @servers = ( "127.0.0.1","141.0.165.133","86.15.164.221","81.168.114.213","94.197.127.29","46.32.235.70","10.168.1.117" );
our $serverenv = $ENV{'SERVER_ADDR'};

our @refs = ();
if( defined $ENV{'HTTP_HOST'} && $ENV{'HTTP_HOST'} =~  /thatsthat\.uk/ ){ 
@refs = ( "thatsthat.uk" );
our $referers = join "|",@refs;
geo_url_out("error: Unauthorised user request from $ENV{'HTTP_REFERER'} ") unless $ENV{'HTTP_REFERER'} =~ /($referers)/;
} else {

$envpath = File::Spec->rel2abs( __FILE__ );
$envpath =~ s/(\/cgi\-bin|\/cgi)(.+)\/.*?$/$1$2/;
$cgix = $1.$2."/";
for my $incfile("$envpath/defs.pm"){
my $increturn = undef;
unless ($increturn = do $incfile){
$incerr.= "couldn't parse $incfile: $@
" if $@;
$incerr.= "couldn't do $incfile: $!
" unless defined $increturn;
$incerr.= "couldn't run $incfile
" unless $increturn;
}
}

push @servers,@defs::serverip;
$serverenv = $defs::serverenv;
}

for my $i(0..$#servers){ $servers[$i] =~ s/\.([0-9]+)$//; }
our $serverip = join "|",@servers;
our $softversion = "8.1.0";

our $input = "";
our $out = "";
our $callback = "";
our $debug.= "";

geo_url_out({ 'error' => "alert: server configuration problem:\n $incerr \ncgix:$cgix \nenvpath:$envpath \nip:$ENV{'REMOTE_ADDR'}" }) if $incerr ne "";
geo_url_out("(error: Unauthorised user request from $serverenv )") unless $serverenv =~ /($serverip)/;

if($ENV{'REQUEST_METHOD'} eq "POST"){read(STDIN, $input, $ENV{'CONTENT_LENGTH'});} else {$input = $ENV{'QUERY_STRING'};}
our @in = split (/&/,$input);
foreach(@in){
s/\+/ /g;
our ($name, $value) = split(/=/,$_);
$name = unescape($name);
$name=~ s/^(pre_)|(opt_)//;
$value = unescape($value);
$value =~ s/
\r//g;
$value =~ s/\r
//g;
$value =~ s/[^a-zA-Z0-9\-\_\+\@\%\&\#<>'"\+=\/\.£\|,:;\(\)\{\}\?\!\[\]\s]//g;
if($name eq "type" && $value ne ""){ $geoip = $ENV{REMOTE_ADDR}; }
if($name eq "callback"){ $callback = $value; }
}

# { "country_code":"US",'country_name':"united states" }

our $dest = $geourl.$geoip.$geokey;
our $msg = undef;
our $out = "";
our ($req,$request,$res,$err);

geo_url_out("(error: the server for $geourl appears to be unavailable = callback:$callback ip:$geoip)") unless $geoip ne "";

eval "use LWP::UserAgent";
if($@){
$err = "Unfortunately this server can\'t use LWP::UserAgent to open $dest:<br />Reason: $@";
} else {
use HTTP::Request::Common;
if( $http eq "https" ){
use LWP::Protocol::https; #stop the warning "possible typo" in next statement
push( @LWP::Protocol::https::EXTRA_SOCK_OPTS,MaxLineLength => 0 );
} else {
use LWP::Protocol::http;
push( @LWP::Protocol::http::EXTRA_SOCK_OPTS,MaxLineLength => 0 );
}
my $ua = LWP::UserAgent->new;
$ua->agent("thatsthat/8.1.0 (Centos 7)");
$res = $ua->request(GET $dest);
if ($res->is_success){ $msg = $res->decoded_content; } else { $err = "Sorry, the server for [ $dest ] appears to be unavailable: ".$res->status_line." = ".$res->as_string; } #$res->content
}

if( defined $err){
$out = '"'.$err.'"'; # JSON->new->allow_nonref->encode($err);
} else {

eval "use JSON";
if($@){
$out = geo_list_dump($msg,'query');
} else {
$out = $msg; #JSON->new->allow_nonref->encode($msg);
}

}

geo_json_print( "$callback( { \"query\":[ ".$out." ] } )" );

exit;

##

sub geo_json_print{
my ($arr,$text) = @_;
print "Content-type: application/javascript\n\n";
#warningsToBrowser(1);
if($text){
print <<_JS_PAGE2;
$arr( $text );
_JS_PAGE2

} else {
print <<_JS_PAGE3;
$arr
_JS_PAGE3

}
exit;
}

sub geo_url_out{
my ($io) = @_;
print "Content-type: text/html\n\n";
print $io;
exit;
}

sub geo_list_dump{
my($data,$title) = @_;
$Data::Dumper::Purity = 1;
$Data::Dumper::Indent = 0;
#$Data::Dumper::Sortkeys = \&sort_dump;
my $d = Data::Dumper->new([$data],[$title],);
return $d->Dump;
}