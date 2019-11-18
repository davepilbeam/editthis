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

our $twitterkey = "IVuw7nu1oO0rMKjjqLcHg";
our $twittersecret = "cGe1pYh9O0ROvlrTu5DS0iyPXHYjRCgVBJP7fXHBcE";
our $authtoken = "370010532-M1qWCWIWbHpVQpAmhXYg3gJYt1ukORogzSADbvBk";
our $authsecret = "vIu6MggBClhglwAatfmK9BkXHRtU81Qqg8dN7lO9Xs";

our @servers = ( "127.0.0.1","141.0.165.133","141.0.165.151","86.15.164.221","81.168.114.213","94.197.127.29","46.32.235.70","10.168.1.117" );
our $serverenv = $ENV{'SERVER_ADDR'};

our @refs = ();
if( defined $ENV{'HTTP_HOST'} && $ENV{'HTTP_HOST'} =~  /thatsthat\.uk/ ){ 
@refs = ( "thatsthat.uk","spoiledrottenpets.co.uk" );
our $referers = join "|",@refs;
twit_url_out("error: Unauthorised user request from $ENV{'HTTP_REFERER'} ") unless $ENV{'HTTP_REFERER'} =~ /($referers)/;
} else {

$envpath = File::Spec->rel2abs( __FILE__ );
$envpath =~ s/(\/cgi\-bin|\/cgi)(.+)\/.*?$/$1$2/;
$cgix = $1.$2."/";
for my $incfile("$envpath/defs.pm"){
my $increturn = undef;
unless ($increturn = do $incfile){
$incerr.= "couldn't parse $incfile: $@\n" if $@;
$incerr.= "couldn't do $incfile: $!\n" unless defined $increturn;
$incerr.= "couldn't run $incfile\n" unless $increturn;
}
}

push @servers,@defs::serverip;
$serverenv = $defs::serverenv;
}

for my $i(0..$#servers){ $servers[$i] =~ s/\.([0-9]+)$//; }
our $serverip = join "|",@servers;
our $softversion = "8.5.0";

our $input = "";
our $out = "";
our $callback = "";
our $sname = "";
our $count = 20;
our $totalcount = 20;
our $iconsrc = "";
our $iconw = 0;
our $iconh = 0;
our $tw = "https://twitter.com/";
our $link = "http://twitter.com";
our $debug.= "";

twit_url_out({ 'error' => "alert: server configuration problem:\n\n $incerr \n\ncgix:$cgix \nenvpath:$envpath \nip:$ENV{'REMOTE_ADDR'}" }) if $incerr ne "";
twit_url_out("(error: Unauthorised user request from $serverenv )") unless $serverenv =~ /($serverip)/;

if($ENV{'REQUEST_METHOD'} eq "POST"){read(STDIN, $input, $ENV{'CONTENT_LENGTH'});} else {$input = $ENV{'QUERY_STRING'};}
our @in = split (/&/,$input);
foreach(@in){
s/\+/ /g;
our ($name, $value) = split(/=/,$_);
$name = unescape($name);
$name=~ s/^(pre_)|(opt_)//;
$value = unescape($value);
$value =~ s/\n\r//g;
$value =~ s/\r\n//g;
$value =~ s/[^a-zA-Z0-9\-\_\+\@\%\&\#<>'"\+=\/\.£\|,:;\(\)\{\}\?\!\[\]\s]//g;
if($name eq "type" && $value ne ""){ $sname = $value; }
if($name eq "callback"){ $callback = $value; }
if($name eq "count"){ $count = $value; }
if($name eq "iconsrc"){ $iconsrc = $value; }
if($name eq "iconw"){ $iconw = $value; }
if($name eq "iconh"){ $iconh = $value; }
}

twit_url_out("(error: the server for $tw appears to be unavailable = callback: $callback sname: $sname)") unless $sname ne "";

our @s = ();
our @u = ();
our $c = 0;
our @statuses = ();
our $statusref = \@statuses;

#twit_json_print("$callback( ".$defs::twittername.":".$licence::twitterkey." );");

#https://dev.twitter.com/docs/api/1.1/get/statuses/home_timeline
#https://api.twitter.com/1.1/statuses/home_timeline.json

eval "use Net::Twitter::Lite::WithAPIv1_1";
if($@){
#twit_url_out("the Twitter module is currently unavailable on this server");
push @s,"The Twitter module 'Net::Twitter::Lite' is currently unavailable on this server..";

} else {
our $nt = Net::Twitter::Lite::WithAPIv1_1 -> new( ssl => 1,consumer_key => $twitterkey,consumer_secret => $twittersecret,access_token => $authtoken,access_token_secret => $authsecret );
eval { $statusref = $nt->user_timeline({ screen_name => $sname,count => $totalcount,exclude_replies => 'true'}); };

if ( my $err = $@ ){

die $@ unless blessed $err && $err->isa('Net::Twitter::Lite::Error');
$out.= "HTTP Response Code: ".$err->code."<br />HTTP Message: ".$err->message."<br />Twitter error: ".$err->error."<br />";
twit_json_print("$callback( { $out } );");

} else {

#$status->{user}{profile_image_url}  http://a0.twimg.com/profile_images/730275945/oauth-dancer_normal.jpg
#$status->{text}  Hello @miila24 from Prague! We visited there last year, so beautiful! http://t.co/dv5yqNmIb3
#$status->{text}  RT \@PublicSectorCo: Delighted to announce that we have newly confirmed speakers at the Troubled Families conference ...... http://t.co/H4az\x{2026}
#$status->{retweeted_text}{text}  Delighted to announce that we have newly confirmed speakers at the Troubled Families conference ...... http://t.co/H4azs3r0Qw #families2014
#$status->{location}  San Francisco, CA
#$status->{created_at}  Tue Aug 13 19:17:14 +0000 2013
#$status->{user}{screen_name}  firefox

for my $status( @{$statusref} ){ 
my $t = $status->{'text'};
if($t =~ /^RT \@(.*?): /){ $t = $status->{'retweeted_status'}{'text'} } #retweet
my $p = (defined $status->{'location'})?$status->{'location'}:"";
my $sn = (defined $status->{'user'}{'screen_name'})?$status->{'user'}{'screen_name'}:"";
$t =~ s/(htt)(p|ps)(:\/\/.*?)(\s|$)/<a href="$1$2$3">$1$2$3<\/a> /g;
$t.= "<br /><span class=\"twitterby\">by <a href=\"$link/$sname\" title=\"link to Twitter\">$sn</a></span> $p"; # $status->{'created_at'}
my $icon = ( $iconsrc =~ /\.(gif|jpg|png)$/i )?"<img class=\"rssprofile\" width=\"$iconw\" height=\"$iconh\" alt=\"Profile Pic\" src=\"$iconsrc\" />":( $iconsrc ne "" && defined $status->{'user'}{'profile_image_url'} )?"<img class=\"rssprofile\" width=\"$iconw\" height=\"$iconh\" alt=\"Profile Pic\" src=\"$status->{'user'}{'profile_image_url'}\" />":"";
if($c < $count ){ push @s,$icon."<div class=\"twitterinner\">".$t."</div>"; }
$c++;
}

}

}

eval "use JSON";
if($@){
return twit_list_dump(\@s,'query');
} else {
for my $i(0..($count-1)){ push @u,JSON->new->allow_nonref->encode($s[$i]); }
}

twit_json_print( "$callback( { \"query\":[ ".( join ",",@u )." ] } )" );

exit;

##

sub twit_json_print{
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

sub twit_url_out{
my ($io) = @_;
print "Content-type: text/html\n\n";
print $io;
exit;
}

sub twit_list_dump{
my($data,$title) = @_;
$Data::Dumper::Purity = 1;
$Data::Dumper::Indent = 0;
#$Data::Dumper::Sortkeys = \&sort_dump;
my $d = Data::Dumper->new([$data],[$title],);
return $d->Dump;
}