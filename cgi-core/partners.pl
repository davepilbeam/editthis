#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5

#editthis version:8.2.2 EDGE

use strict;
#use warnings;
#use cPanelUserConfig;

use CGI;
use CGI qw/escape unescape/;
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
use Encode;
use File::Copy;
use File::Find;
use File::Path;
use File::Spec;
use File::stat;
use MIME::Base64;
use Symbol;

my $envpath = File::Spec->rel2abs( __FILE__ );
$envpath =~ s/(\/cgi-bin|\/cgi)\/.*?$/$1/;
our $cgix = $1.$2;
our $incerr = "";
for my $incfile("$envpath/defs.pm"){
my $increturn = undef;
unless ($increturn = do $incfile){
$incerr.= "couldn't parse $incfile: $@\n" if $@;
$incerr.= "couldn't do $incfile: $!\n" unless defined $increturn;
$incerr.= "couldn't run $incfile\n" unless $increturn;
}
}

our %MAP = (); #'IP_location' => 'CountryRegistered'
our %checkgroup = ();
#@{ $checkgroup{'DatePurchased'} } = ('/','Day','Month','Year');

our @servers = @defs::serverip;
for my $i(0..$#servers){ $servers[$i] =~ s/\.([0-9]+)$//; }
our $serverenv = $defs::serverenv;
our $serverip = join "|",@servers;
our $sendtemp = $defs::sendtemp;
our $peserver = (defined $defs::nonpeserver)?undef:1;

our $authuser = $defs::authuser;
our $authpass = $defs::authpass;
our $authsmtp = $defs::authsmtp;
our $authport = $defs::authport;

our $softversion = $defs::softversion;
our $mail_program = $defs::mail_program;
our $smtp_server = $defs::smtp_server;
our $adminaddr = $defs::adminaddr;
our $fromaddr = $defs::fromaddr;
our $cgipath = $defs::cgipath;
our $cgirelay = $defs::cgirelay;

our $http = $defs::http;
our $base = $defs::base;
our $baseview = $defs::baseview;
our $cgipath = $defs::cgipath;
our $subdir = $defs::subdir;
our $obase = $defs::obase;
our $otitle = $defs::otitle;

our $adminbase = $defs::adminbase;
our $backupbase = $defs::backupbase;
our $versionbase = $defs::versionbase;

our $remlister = $defs::remlister;
our $index_file = $defs::index_file;
our $docview = $defs::docview;
our $imagefolder = $defs::imagefolder;
our $imageview = $docview.$imagefolder."/";
our $templatefolder = $defs::templatefolder;
our $templateview = $docview.$templatefolder."/";
our $resourcefolder = $defs::resourcefolder;
our $pdffolder = $defs::pdffolder;
our $cssview = $defs::cssview;


$CGI::POST_MAX = $defs::postmax;
our $resdir = join "|",@defs::RESERVED;
our $listdir = join "|",@defs::LISTDIR;
our $bandir = join "|",@defs::BANDIR;
our $banfile = join "|",@defs::BANFILE;
our $extimg = join "|",values %defs::EXT_IMGS;
our $extdoc = join "|",values %defs::EXT_FILES;
our $extset = $extimg."|".$extdoc;

our %IMS = %defs::EXT_IMGS;
our %FX = %defs::FX;
our %MS = %defs::MS;
our %MNS = ('january' => 0,'february' => 1,'march' => 2,'april' => 3,'may' => 4,'june' => 5,'july' => 6,'august' => 7,'september' => 8,'october' => 9,'november' => 10,'december' => 11);
our %ULIST = ();
our @DATA = ();
our @MONTHS = ('','January','February','March','April','May','June','July','August','September','October','November','December');
our @UTF = @defs::UTF;
our @UTF1 = @defs::UTF1;
our @css_files = @defs::css_files;
our @errs = ();
our $htmlext = $defs::htmlext;
our $docspace = $defs::docspace;
our $spamurl = $defs::spamurl;
our $spacer = $defs::spacer;
our $fxfile = (join "|",keys %FX)."|".(join "|",values %IMS);
#

our $xurl =  join "|",@defs::XLIST;
our $xxurl =  join "|",@defs::XXLIST;

our @emailorder = @defs::emailorder;
our $formtype = $defs::title;
our @toaddr = @defs::toaddr;
our @bcc = @defs::bccaddr;
our $efoot = $defs::efoot;
our $htmlhead = $defs::htmlhead;
our $htmlfoot = $defs::htmlfoot;
our $etitle = $defs::etitle;
our $thank = $defs::thank;

our $loginuser = $defs::loginuser || "admin";
our $loginsalt = $defs::loginsalt || "etc";
our $docuser = $defs::docuser;
our $docpass = $defs::docpass;

our $sitebase = $base;
our $the_time = localtime();

our @HM = ();
our @libraryfiles = ();
our @recipients = ();
our $to = "";
our $sub = "";
our $html = 1;
our $reclist = "";
our $emailaddr = "";
our $copyto = "";
our $intro = "";
our $locate = "";
our $noscript = 1;
our $spamcheck = -1;
our $spamresult = -1;
our $spamfail = 0;
our $formno = "";
our $method = '';
our $invoker = $ENV{'HTTP_REFERER'};
our $out = "";
our $rout = "";
our $response = "";
our @returnlist = ();
our $returnmail = undef;
our $title = $formtype;

our $loginpass = undef;
our $callback = "";
our $endout = "";
our $eresp = "";
our $debug = "";

our $datetime = partners_get_date(); #14:10:39_15--10--2015
our $sendtime = $datetime;
$sendtime =~ s/\-\-/-/g;
our $senddate = $sendtime;$senddate =~ s/^(.*?)_//;$senddate =~ s/\-/\//g; #03/06/2016
our $usetime = $sendtime;$usetime =~ s/:/-/g;
$sendtime =~ s/_/ /g; #14:10:39 15-10-2015


partners_respond("error:","Unauthorised user request received by server $ENV{'SERVER_ADDR'}") unless $serverenv =~ /^($serverip)/; # == $serverip / $debug
our $xx = ( $xxurl ne "" && $ENV{'REMOTE_ADDR'} =~ /^($xxurl)/ )?1:( $xurl ne "" && $ENV{'REMOTE_ADDR'} =~ /($xurl)/ )?1:0;if($xx > 0){ partners_exit(); }

partners_respond("error:","Data size [ ".$ENV{'CONTENT_LENGTH'}." ] is greater than the maximum ".$CGI::POST_MAX."k allowed ") if $ENV{'CONTENT_LENGTH'} && $ENV{'CONTENT_LENGTH'} > $CGI::POST_MAX;

our $query = CGI->new();
our %pdata = $query->Vars; my @new_keys = keys %pdata;s/^(opt|pre)_(.*?)_([0-9]+)$/$2/ foreach @new_keys; @pdata{@new_keys} = delete @pdata{keys %pdata}; # $debug.= Data::Dumper->Dump([\%pdata],["PDATA"])."\n";
our $postdata = $query->param('POSTDATA'); # $debug.= Data::Dumper->Dump([$postdata],["POSTDATA"])."\n";
our $qerr = $query->cgi_error;if($qerr){ exit 0;partners_respond("error:","Problem with received data: $qerr "); }

foreach my $k( keys %pdata ){
my $h = undef;
if( $k =~ /manifest/i && $pdata{$k} ne "" ){ partners_exit(); }
if( $k eq "callback" ){ $callback = $pdata{$k}; }
if( $k eq "spam" ){ partners_exit(); }
if( $k eq "message" || $k eq "details" || $k eq "name" ){ if( defined $spamurl && ($pdata{$k} =~ /ht(t)*p(s)*:\/\//i || $pdata{$k} =~ /\b(porno|sex|hacked|sexe|gay)\b/i || $pdata{$k} =~ /\@.*?\.(com|ru|ua|ro|fr|co\.uk)$/i) ){ partners_exit(); } }

if( $k eq "recipients" ){ $reclist = $pdata{$k}; }
if( $k eq "locate" ){ $locate = $pdata{$k}; }
if( $k eq "spamcheck" ){ $spamcheck = $pdata{$k}; }
if( $k eq "spamresult" ){ $spamresult = $pdata{$k}; }
if( $k eq "formtype" ){ $formtype = $pdata{$k};$sub = $pdata{$k}." from ".$etitle.": ".$usetime; }
if( $k eq "copytype" ){ $copyto = $pdata{$k}; }
if( $k eq "email" || $k =~ /^email/i ){ $emailaddr = $pdata{$k}; }
if( $k eq "library" ){ @libraryfiles = split /\|\|/,$pdata{$k}; } #Digital/Case-Studies/RSM-Case-Study-1.pdf||Digital/Case-Studies/RSM-Case-Study-3.pdf||Digital/Data-Sheets/zRSM-Realtime-Data-Sheet.pdf\
if( $k eq "html" ){ $html = undef; }
if( $k eq "password" ){ $loginpass = $pdata{$k}; }

if( $pdata{$k} =~ /\[url="/i || $pdata{$k} =~ /<a href="/ || $pdata{$k} =~ /http:\/\// ){ $spamfail = 1; }

if( $k ne "spam" && !defined $h && $k !~ /^(formtype|recipients|html|locate|spamcheck|spamresult|cgiurl|cgireturn|copytype|submit)$/i ){
my @ar = ($k,$pdata{$k});$out.= "$k = $pdata{$k}\n\n"; 
#$debug.= " $k = @ar<br />";
push @HM,[@ar];
}

}

print "Location: $ENV{HTTP_REFERER}\n\n" unless scalar @HM > 0;
if($spamresult > -1 ){ if( $spamcheck != $spamresult || $spamcheck !~ /^($spamresult)$/i ){ $spamfail = 1; } }
partners_exit() if $spamfail > 0;

###partners_json_out("{ \"check 2\":\"$debug formtype:$formtype email:$emailaddr loginpass:$loginpass envpath:$envpath = @recipients, @bcc, $fromaddr, $sub, $out, $html \" }");

if( defined $loginpass ){ # email:admin@thatsthat.co.uk  loginpass:pecreative_etc4567

eval "use LWP::UserAgent";
print "Location: $ENV{HTTP_REFERER}\n\n" if $@;
eval "use HTTP::Request";
print "Location: $ENV{HTTP_REFERER}\n\n" if $@;
eval "use HTTP::Response";
print "Location: $ENV{HTTP_REFERER}\n\n" if $@;
my $ps = $loginpass;$ps =~ s/(_.+)$//;
if( $loginpass =~ /^(.*?)_($loginsalt)([0-9]+)$/ ){
my $ua = LWP::UserAgent->new();
my $req = HTTP::Request->new(GET => "$baseview/partners/$ps/" );
$req->authorization_basic($loginuser,$loginpass);
$req->header('Accept', => 'text/html');
my $response = $ua->request($req);
print "Content-type: text/html\n\n"; ###print $response->as_string();
print $response->content;
} else {
partners_respond("The password supplied is not correct.");
}
exit;
}

exit;

####


sub partners_exit{
my ($txt) = @_;
my $otxt = (defined $txt)?$txt:"Your details have successfully been received and you will receive a response shortly.";
partners_html_out($otxt);
#partners_respond("Alert:","Cannot process form: incorrect spam question field from $ENV{'REMOTE_ADDR'}. Please refresh page and try again.");
###print "Location: https://www.spamcop.net/\n\n"; 
}

sub partners_get_date{ my @now = localtime();return sprintf( "%02d:%02d:%02d_%02d--%02d--%04d",$now[2],$now[1],$now[0],$now[3],$now[4]+1,$now[5]+1900 ); }

sub partners_html_out{
my ($io) = @_;
print "Content-type: text/html\n\n";
#warningsToBrowser(1);

print $io;

exit;
}

sub partners_json_out{
my ($jref,$orig,$call) = @_;
my $type = ref $jref || undef;
if( defined $type ){
eval "use JSON";
if($@){ partners_json_print( sub_list_dump($jref,'query') ); } else { partners_json_print( "{ \"query\":".JSON->new->allow_nonref->utf8->encode($jref)." }",$orig,$call ); }
} else {
partners_json_print($jref,1,$call);
}
}

sub partners_json_print{
my ($jtxt,$q,$cback) = @_;
print "Content-type: application/json; charset=UTF-8\n\n";
if( defined $cback && $cback ne "" ){
print "$cback( $jtxt )";
} elsif( defined $q ){ 
print "{ \"query\":[ \"$jtxt\" ] }";
} else {
print $jtxt;
}
exit;
}

sub partners_list_dump{
my($data,$title) = @_;
$Data::Dumper::Purity = 1;
$Data::Dumper::Indent = 0;
#$Data::Dumper::Sortkeys = \&sort_dump;
my $d = Data::Dumper->new([$data],[$title],);
return $d->Dump;
}

sub partners_respond{
my ($outhead,$outtext) = @_;
my $s = "";
my $w = <<_OUTPUT_;
<span class="email0">$outhead</span><br />
<br />
<ul class="email2"><li>$outtext</li></ul>
_OUTPUT_

if($noscript == "" && $method eq "get"){
if($outhead =~ /^forwarding page to:/){$s = $outhead;} else {$s = $w;}partners_html_out($s);

} elsif($outhead =~ /^forwarding page to:/){
$locate =~ s/_blank$//;
print "Location: $locate\n\n";

} else {
if( $invoker =~ /\/$/){$invoker.= $index_file;}
$invoker =~ s/($baseview)/$base/;
open(my $vlist, "<$invoker") or partners_html_out($w);
flock ($vlist, 2);
my @vlines = <$vlist>;
$s = join "",@vlines;
close($vlist);

$s =~ s/(<form id="cgi\_form\_$formno".*?<\/form>)/$w/ms;
partners_html_out($s);
}

exit;
}
