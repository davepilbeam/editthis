#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5

#editthis version:8.2.2 EDGE

use strict;
#use warnings;

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

my $envpath = File::Spec->rel2abs( __FILE__ );
$envpath =~ s/(\/cgi\-bin|\/cgi)(.+)\/.*?$/$1$2/;
our $incerr = "";
for my $incfile("$envpath/defs.pm","$envpath/subs.pm"){
my $increturn = undef;
unless ($increturn = do $incfile){
$incerr.= "couldn't parse $incfile: $@\n" if $@;
$incerr.= "couldn't do $incfile: $!\n" unless defined $increturn;
$incerr.= "couldn't run $incfile\n" unless $increturn;
}
}

our @servers = ( "127.0.0.1","141.0.165.133","86.15.164.221","81.168.114.213","94.197.127.29","46.32.235.70","10.168.1.117" );
if( defined @defs::serverip ){ push @servers,@defs::serverip; }
for my $i(0..$#servers){ $servers[$i] =~ s/\.([0-9]+)$//; }

our $adminbase = $defs::adminbase;
our $sitepage = undef;

our $serverenv = $ENV{'SERVER_ADDR'};
our $softversion = "8.2.2";
our $serverip = join "|",@servers;
our $sendtemp = $defs::sendtemp;

our $authuser = $defs::authuser;
our $authpass = $defs::authpass;

our $softversion = $defs::softversion;
our $mail_program = $defs::mail_program;
our $smtp_server = $defs::smtp_server;
our $adminaddr = $defs::adminaddr;
our $fromaddr = $defs::fromaddr;
our $cgipath = $defs::cgipath;
our $cgirelay = $defs::cgirelay;

our $base = $defs::base;
our $baseview = $defs::baseview;
our $nwurl = $defs::nwurl;
our $nwbase = $defs::nwbase;
our $obase = $defs::obase;
our $otitle = $defs::otitle;
our $remlister = $defs::remlister;
our $libview = $defs::libview;
our $docview = $defs::docview;
our $index_file = $defs::index_file;

our $versionbase = $defs::versionbase;
our $live_site = $defs::live_site;

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
our $spacer = $defs::spacer;
our $fxfile = (join "|",keys %FX)."|".(join "|",values %IMS);
#

our $mod_email = $defs::mod_email;
our $xurl =  join "|",@defs::XLIST;
our $xxurl =  join "|",@defs::XXLIST;

our $formtype = $defs::title;
our @toaddr = @defs::toaddr;
our @bcc = @defs::bccaddr;
our $efoot = $defs::efoot;
our $htmlhead = $defs::htmlhead;
our $htmlfoot = $defs::htmlfoot;
our $etitle = $defs::etitle;
our $thank = $defs::thank;

our $docuser = $defs::docuser;
our $docpass = $defs::docpass;
our %RECIPS = %defs::RECEIVERS;
our %COPY = %defs::COPY;

our $auxfiles = $defs::auxfiles;
our $body_regx = $defs::body_regx;
our $cssview = $defs::cssview;
our %defheaders = %defs::defheaders;
our $defrestore = $defs::defrestore;
our $defsep = $defs::defsep;
our $delete_limit = $defs::delete_limit;
our $delim = $defs::delim;
our %defsort = %defs::defsort;
our %editareas = %defs::editareas;
our $ftpbase = $nwbase;$ftpbase =~ s/^.+\/($defs::ftpbase)/$1/;
our $ftppass = $defs::ftppass;
our $ftpcheck = $defs::ftpcheck;
our %headers = %defs::headers;
our $homeurl = $defs::homeurl;
our $http = $defs::http;
our $imagefolder = $defs::imagefolder;
our $imagerelay = (defined $ftppass)?$defs::imagerelay:'localhost';
our $imageview = $docview.$imagefolder."/";
our $liblister = $defs::liblister;
our $mobpic = $defs::mobpic;
our %perms = %defs::perms;
our $repdash = $defs::repdash;
our $resourcefolder = $defs::resourcefolder;
our $restorefolder = $defs::restorefolder;
our $restorebase = $restorefolder."/";
our $site_file = $defs::site_file;
our $subdir = $defs::subdir;
our $templatefolder = $defs::templatefolder;
our $templateview = $docview.$templatefolder."/";
our $taglister = $defs::taglister;
our @titlesep = @defs::titlesep;
our $uncache = $defs::uncache;
our $version_limit = $defs::version_limit;
our $webbase = $defs::webbase;

our $sitebase = $base;
our $the_time = localtime();

our %config = ();
our @HM = ();
our @recipients = ();
our $type = undef;
our $to = "";
our $sub = "Debug Response";
our $html = 1;
our $reclist = "";
our $emailaddr = "";
our $copyto = "";
our $intro = "";
our $locate = "";
our $noscript = 1;
our $formno = "";
our $method = '';
our $invoker = $ENV{'HTTP_REFERER'};
our $out = "";
our $response = "";
our @returnlist = ();
our $returnmail = undef;
our $title = $formtype;
our $endout = "";
our $debug = "";

our $callback = "";
our $the_date = debug_show_time(time,2);

$CGI::POST_MAX = $defs::postmax;

debug_respond("alert: server configuration problem:\n\n $incerr \n\ncgipath:$cgipath \nenvpath:$envpath \nip:$ENV{'REMOTE_ADDR'}") if $incerr ne "";
debug_respond("alert: unauthorised user request received by server $serverenv from $ENV{'REMOTE_ADDR'}") unless $serverenv =~ /^($serverip)/; # == $serverip / $debug
debug_respond("data size [ ".$ENV{'CONTENT_LENGTH'}." ] is greater than the maximum ".$CGI::POST_MAX."k allowed") if $ENV{'CONTENT_LENGTH'} && $ENV{'CONTENT_LENGTH'} > $CGI::POST_MAX;

local *sub_get_contents = \&subs::sub_get_contents;

#/cgi-bin/debug.pl
#/cgi-bin/debug.pl&ref=1&page=Contact-Us.html
#/cgi-bin/debug.pl&ref=1&type=track

our $input = "";if($ENV{'REQUEST_METHOD'} eq "POST"){ $method = 'post';read(STDIN, $input, $ENV{'CONTENT_LENGTH'}); } else { $method = 'get';$input = $ENV{'QUERY_STRING'}; }
our @in = split (/&/, $input);
foreach(@in){
s/\+/ /g;
our ($name, $value) = split(/=/,$_);
$name = unescape($name);
$name=~ s/^(pre_)|(opt_)//;
$value = unescape($value);
$value =~ s/\n\r//g;
$value =~ s/\r\n//g;
$value =~ s/[^a-zA-Z0-9\-\_\+\@\%\&\#<>'"\+=\/\.£\|,:;\(\)\{\}\?\!\[\]\s]//g;
if($name !~ /^submit_[0-9]+$/){
if($name eq "callback"){ $callback = $value; } #Request.JSONP.request_map.request_0
my $hname = $name;$hname=~ s/(_[0-9]+)$//;
my @ar = ($hname,$value);
if($name eq "page"){ $sitepage = $value; }
if($name eq "ref"){ $value = $ENV{'REMOTE_ADDR'}."_".$value;$sub.= " from $value"; }
if($name eq "type"){ $type = $value; } else { if($value ne ""){ push @HM,[@ar];$out.= $name." = ".$value."\n\n"; } }
}
}

%config = ( 
'adminbase' => $adminbase,
'attri' => "",
'auxfiles' => $auxfiles,
'bandir' => $bandir,
'banfile' => $banfile,
'base' => $base,
'baseview' => $baseview,
'body_regx' => $body_regx,
'callback' => $callback,
'cgipath' => $cgipath,
'clsdata' => undef,
'cssview' => $cssview,
'debug' => $debug,
'defheaders' => \%defheaders,
'defrestore' => $defrestore,
'defsep' => $defsep,
'defsort' => \%defsort,
'delete_limit' => $delete_limit,
'delim' => $delim,
'dlevel' => 99,
'docspace' => $docspace,
'docview' => $docview,
'editareas' => \%editareas,
'extdoc' => $extdoc,
'format' => undef,
'ftpbase' => $ftpbase,
'ftpcheck' => $ftpcheck,
'ftppass' => $ftppass,
'fullmenu' => undef,
'fxfile' => $fxfile, #HTML|TXT|XLSX|PPTX|DOCX|HTM|LISTING|DOC|PDF|PPS|PPT|XLS|PNG|SWF|JPEG|JPG|GIF|ZIP
'headers' => \%headers,
'homeurl' => $homeurl,
'htmlext' => $htmlext,
'http' => $http,
'id' => undef,
'index_file' => $index_file,
'imagefolder' => $imagefolder,
'imagerelay' => $imagerelay,
'imageview' => $imageview,
'js' => undef,
'keeplinks' => 'on',
'liblister' => $liblister,
'mobpic' => $mobpic,
'nwbase' => $nwbase,
'nwurl' => $nwurl,
'obase' => $obase,
'otitle' => $otitle,
'origin' => undef,
'pagefull' => 0,
'pagesort' => 'rank',
'pagewrap' =>undef,
'perms' => \%perms,
'pl' => "",
'repdash' => $repdash,
'resourcefolder' => $resourcefolder,
'restorebase' => $restorebase,
'sharelist' => {},
'site_file' => $site_file,
'sitepage' => $sitepage,
'subdir' => $subdir,
'templateview' => $templateview,
'titlesep' => \@titlesep,
'taglister' => $taglister,
'uncache' => $uncache,
'user' => undef,
'UTF' => \@UTF,
'UTF1' => \@UTF1,
'versionbase' => $versionbase,
'version_limit' => $version_limit,
'webbase' => $webbase
);

if( defined $type && $type eq "track"){

my $ftt = $efoot;
$ftt =~ s/<br \/>/\n/gi;
$ftt =~ s/<.*?>//gi;
$out = $etitle."\n\n".$out."\n\n".$ftt;
$endout = debug_clean_xml($intro);
if($copyto ne ""){ # send to $emailaddr / bcc to @toaddr+@bcc
push @recipients,$emailaddr;
for my $i(0..$#toaddr){ push @bcc,$toaddr[$i]; }
} else {
for my $i(0..$#toaddr){ push @recipients,$toaddr[$i]; } #send to @toaddr / bcc to @bcc
}
if($html){$html = debug_html_me(\@HM);}
my $bc = join ",",@bcc;
my $rr = join "|",@toaddr;
for my $i(0..$#recipients){
if($recipients[$i] ne "" && $recipients[$i] =~ /^(.*?)\@(.*?)\.(.*?)$/ ){
###
debug_send_mail($recipients[$i],$bc,$fromaddr,$sub,$out.$debug,$html); 
###debug_respond("Debug 02: $debug = $recipients[$i], $bc, $fromaddr, $sub, $out.$debug, $html");
}
}
debug_json_out("{'result':'ok'}");

} else {

$sitepage = $site_file unless -f $base.$sitepage;
my $txt = debug_html_in($base.$sitepage);
my $cs = '<link rel="stylesheet" type="text/css" href="admin/console.css" />';
$txt =~ s/(<link rel="stylesheet" type="text\/css" href="desktop.css"\s*\/>)/$1$cs/m;
my $js = 'var E = { debugme:1 };';
$txt =~ s/(var loadDeferredStyles = function)/$js$1/m;
print "Content-type: text/html\n\n"; #$debug.= "\n\n".$txt;print $debug;
print $txt;

}

exit;

####
sub debug_html_in{
my ($f) = @_;
my $t = "";
my ($ierr,$otxt) = sub_get_contents($f,\%config);
debug_respond("debug: \n$ierr \n $f \n $otxt \n $debug",$callback) if defined $ierr;
$t = $otxt;
$t =~ s/(<base href=")(.*?)(" \/>)/$1$baseview$3/;
return $t;
}

sub debug_html_me{
my ($dref,$ip) = @_;
my @DATA = @{$dref};
my $s = $htmlhead; 

$s.= <<_HTML_A_;
		<div style="width:80%; background:#fff; margin:3px auto; font-weight:bold; clear:both;"><i>$sub</i></div>
		<div style="width:80%; background:#fff; margin:3px auto; font-weight:bold; clear:both;"><b>Details:</b></div>
		<div style="width:80%; background:#fff; margin:3px auto; font-weight:bold; clear:both;">$intro</div>
		<div style="width:80%; background:#fff; margin:3px auto; clear:both;">
			<table style="font-family:arial; border:1px #000 solid; border-collapse:collapse;" cellspacing="0" cellpadding="0">
_HTML_A_

for my $i(0..$#DATA){
if( $DATA[$i][1] ne "" ){
my $ff = ($DATA[$i][1] eq "")?" color:#888; background-color:#efefef;":"";
my $hh = join " ", map {ucfirst} split / /,$DATA[$i][0];
$s.= <<_HTML_B_;
				<tr>
					<td style="border:1px #000 solid; padding:3px; vertical-align:top;$ff" width="30%"><strong>$hh:</strong></td>
					<td width="70%" style="border:1px #000 solid; padding:3px;$ff">$DATA[$i][1]</td>
				</tr>
_HTML_B_

}
}

if(defined $ip){
$s.= <<_HTML_Z_;
				<tr>
					<td style="border:1px #000 solid; padding:3px;" width="30%"><strong>User IP Address:</strong></td>
					<td  width="70%" style="border:1px #000 solid; padding:3px;">$ENV{'REMOTE_ADDR'}</td>
				</tr>
				<tr>
					<td style="border:1px #000 solid; padding:3px;" width="30%"><strong>User Agent:</strong></td>
					<td width="70%" style="border:1px #000 solid; padding:3px;">$ENV{'HTTP_USER_AGENT'}</td>
				</tr>				
_HTML_Z_

}

$s.= "</table></div><div style=\"width:80%; background:#fff; font-size:80%; line-height:100%; margin:3px auto; clear:both;\">$efoot</div>\n";
$s.= $htmlfoot;
return $s;
}

sub debug_json_out{
my ($txt,$r) = @_;
$txt =~ s/'/\\'/g;
print "Content-type: application/javascript; charset=UTF-8\n\n";
if(defined $r){
print "$txt";
} else {
print "$callback({ \"query\":[ \"$txt\" ] })";
}
exit;
}

sub debug_respond{
my ($outhead,$outtext) = @_;
my $s = "";
my $w = <<_OUTPUT_;
<span class="email0">$outhead</span><br />
<br />
<ul class="email2"><li>$outtext</li></ul>
_OUTPUT_

if($noscript == "" && $method eq "get"){
if($outhead =~ /^forwarding page to:/){$s = $outhead;} else {$s = $w;}debug_html_out($s);

} elsif($outhead =~ /^forwarding page to:/){
$locate =~ s/_blank$//;
print "Location: $locate\n\n";

} else {
if( $invoker =~ /\/$/){$invoker.= $index_file;}
$invoker =~ s/($baseview)/$base/;
open(my $vlist, "<$invoker") or debug_html_out($w);
flock ($vlist, 2);
my @vlines = <$vlist>;
$s = join "",@vlines;
close($vlist);
$s =~ s/(<form id="cgi\_form\_$formno".*?<\/form>)/$w/ms;
debug_html_out($s);
}

exit;
}

sub debug_clean_xml{
my ($s,$w) = @_;
for my $i(0..$#UTF){ $s =~ s/($UTF[$i][0])|($UTF[$i][1])/$UTF[$i][2]/gmsi; }
for my $i(0..$#UTF1){ $s =~ s/$UTF1[$i][0]/$UTF1[$i][1]/gmsi; }
$s =~ s/([^a-zA-Z0-9\-\_\+\@\%\&\#<>'"=\/\.\$£\|,:;\(\)\{\}\?\!\[\]\~\s])//gmsi;
$s =~ s/ \& / &#38; /gi;
$s =~ s/\t//gi;
$s =~ s/(\n+)/\n/img;
if($w){$s =~ s/\n//img;}
$s =~ s/^(<).*?(DOCTYPE html )/$1!$2/; #&#8482;
$s =~ s/(<\/html>)(.*?)$/$1/i; #&#36;
$s =~ s/(<\/body>)\&#36;/$1/i; 
return $s;
}

sub debug_date_ext{ my ($d) = @_;my $m = "";if($d =~ /^([2-9.]+)*1$/){$m = "st";} elsif( $d =~ /^([2-9.]+)*2$/){$m = "nd";} elsif( $d =~ /^([2-9.]+)*3$/){$m = "rd";} else {$m = "th";}return $m; }

sub debug_html_out{
my ($io) = @_;
print "Content-type: text/html\n\n";
#warningsToBrowser(1);

print $io;

exit;
}

sub debug_send_mail{
my ($to,$bcc,$from,$sub,$data,$ht) = @_;
my $mes = "";
my $mout = "";
my $ent;
my $plain;
my $html;
my $dbg = "$to, $bcc, $from, $sub, $data, $ht";

if( defined $authuser && defined $authpass ){
eval "use Net::SMTP";
if($@){
$mes.= "Tried to use Net::SMTP: ".$@."<br />";
} else {
my $mail_headers = "From: $from\n".
"To: $to\n".
"Subject: ".encode('MIME-Header',$sub)."\n".
"MIME-Version: 1.0\n".
"Content-type: text/html; charset=UTF-8\n".
"Content-Transfer-Encoding: base64\n\n";
$ent = Net::SMTP->new($smtp_server,Debug=>1) or $mes.= "Net::SMTP failed to create object ($!; $@)<br />";
$ent->auth($authuser,$authpass) or $mes.= "Can't authenticate into $ent->host $ent->message().<br />";
$ent->mail($from);
$ent->recipient($to);
$ent->bcc($bcc);
$ent->data();
$ent->datasend($mail_headers);
if($ht){ $ent->datasend(encode_base64(encode('utf8',$ht))); } else { $ent->datasend ("\n$data\n"); }
$ent->dataend;
$ent->quit;
}

} else {

eval "use MIME::Entity"; # doesn't work with v. 0.74!
if($@){

$mes.= "Tried to use MIME::Entity ".$@."<br />";
eval "use Mail::Sendmail"; # doesn't work with v. 0.74!
if($@){

$mes.= "Tried to use Mail::Sendmail: ".$@."<br />";
eval "use LWP::UserAgent";
if($@){

$mes.= "Tried to use LWP::UserAgent: ".$@."<br />";
eval "use OLE";
if($@){

$mes.= "<br />Tried to use OLE JMail: ".$@."<br />";
open my $mailopen, "| $mail_program" or debug_html_out("The mailserver('sendmail') has been unable to send this email: $!");
if( $ht =~ /[a-zA-Z0-9]+/ ){ print $mailopen "Content-Type: text/html\n\n"; }
print $mailopen "To: $to\n";
print $mailopen "Bcc: $bcc\n";
print $mailopen "From: $from\n";
print $mailopen "Subject: $sub\n";
print $mailopen "User Name (if available) - $ENV{'REMOTE_USER'}\n";
print $mailopen "User Address - $ENV{'REMOTE_ADDR'}\n";
print $mailopen "User Browser - $ENV{'HTTP_USER_AGENT'}\n\n";
if( $ht =~ /[a-zA-Z0-9]+/ ){ print $mailopen "$ht"; } else { print $mailopen $data; }
close($mailopen);
debug_html_out($mes."<br />Trying to use SendMail: $!.");

} else {

my $jmail = CreateObject OLE "JMail.SMTPMail";
if(defined $jmail){
$jmail->{ServerAddress} = $smtp_server;
$jmail->{Sender} = $from;
$jmail->{Subject} = $sub;
$jmail->AddRecipient ($to);
if( $ht =~ /[a-zA-Z0-9]+/ ){ $jmail->{ContentType} = "text/html";$jmail->{Body} = $ht; } else { $jmail->{Body} = $data; }
$jmail->{Priority} = 3;
$jmail->AddHeader ("User Address - $ENV{'REMOTE_ADDR'} (sent using JMail)");
$jmail->Execute or debug_html_out($mes."<br />The mailserver('JMail') has been unable to send this email: $!");
} else {
debug_html_out("Tried to send mail via OLE: JMail is not defined.");
}

}

} else {

my $ua = LWP::UserAgent->new;
my $response;
if(-e $base."mailer.php"){
$ua->timeout(10);
$ua->env_proxy;
$mout = "\nUser Name (if available) - $ENV{'REMOTE_USER'}\nAddress - $ENV{'REMOTE_ADDR'}\nBrowser - $ENV{'HTTP_USER_AGENT'}\n$the_time\n\n".$out;
$response = $ua->get($baseview.'/mailer.php?to='.$to.'&bcc='.$bcc.'&from='.$from.'&sub='.$sub.'&body='.$mout); ###my $response = $ua->get('http://intasave.org.cn/mailer.php?to='.uri_encode($to).'&bcc='.uri_encode($bcc).'&from='.uri_encode($from).'&sub='.uri_encode($sub).'&body='.uri_encode($mout));
if($response->is_success){ $mes.= "PHP thinks the email was sent correctly..<br />"; } else { debug_html_out("Encountered an error sending your message: ".$response->status_line); }
} else { 
#http://www.domain.co.uk/cgi/email.pl?js=1&pre_message_0=test%203&pre_name_0=test&pre_address_0=&pre_debug_0=test%40here.com&pre_spamcheck_0=11&opt_formtype_0=Contact%20Enquiry&opt_recipients_0=&opt_locate_0=&opt_copytype_0=&opt_spamresult_0=11&opt_html_0=1
$mes.= "<br />Mailer.php file is not present..<br />Trying email relay:<br />";
$response = $ua->get('http://'.$cgirelay.'email.pl?'.$input);
if($response->is_success){ $mes.= "Email relay thinks the email was successful..<br />"; } else { $mes.= "Error from email relay sending your message: ".$response->status_line."<br />$cgirelay.email.pl?".$input."<br />"; }
}

}

} else {

my %mail = ( 'from' => $from,'to' => $to,'bcc' => $bcc,'subject' => $sub );
if($ht){
my $bnd = "====".time()."====";
$mail{'content-type'} = "multipart/alternative; boundary=\"$bnd\"";
$bnd = '--'.$bnd;
$mail{'body'} = <<END_OF_BODY;
$bnd
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

$data

$bnd
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

$ht
$bnd--
END_OF_BODY

} else {
$mail{'content-type'} = 'text/html; charset="iso-8859-1"';$mail{'body'} = $data;
}

sendmail(%mail) or debug_html_out($mes."<br />The mailserver('Mail::Sendmail') has been unable to send this email: $!");

}

} else {

if($ht){
$ent = MIME::Entity->build( 'Type' => "multipart/alternative",'Return-Path' => $from,'To' => $to,'Bcc' => $bcc,'From' => $from,'Subject' => $sub,'Sender' => $from );
$plain = $ent->attach( 'Type' => "text/plain",'Data' => $data );
$html = $ent->attach( 'Type' => 'multipart/related' );
$html->attach( 'Type' => 'text/html','Data' => $ht );
} else {
$ent = MIME::Entity->build( 'Encoding' => "base64",'Return-Path' => $from,'To' => $to,'Bcc' => $bcc,'From' => $from,'Subject' => $sub,'Sender' => $from,'Data' => $data );
}

#$ent->smtpsend or debug_html_out("The mailserver('Mime::Entity') has been unable to send this email: $! $dbg");
open MAIL, "| $mail_program"or debug_html_out("The mailserver('Mime::Entity') has been unable to send this email: $! $dbg");
$ent->print(\*MAIL);
close MAIL;

$ent->purge;
}


}
$debug.= $mes."<br />";
}

sub debug_show_time{
my ($t,$s) = @_;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);
my ($mex,$fyear);

if($s){

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($t);
$mon++;
$fyear = 1900+$year;
$year = substr($year,1);
if($mday < 10){$mday = "0".$mday;}
if($mon < 10){$mon = "0".$mon;}
if($hour < 10){$hour = "0".$hour;}
if($min < 10){$min = "0".$min;}
if($sec < 10){$sec = "0".$sec;}
if($s == 1){
return "$mday-$mon-$year ($hour:$min:$sec)";
} elsif($s == 2){
return $mday."/".$mon."/".$year;
} elsif($s == 3){
return $fyear;
} elsif($s == 4){
if($mday =~ /^([2-9.]+)*1$/){$mex = "st";} elsif( $mday =~ /^([2-9.]+)*2$/){$mex = "nd";} elsif( $mday =~ /^([2-9.]+)*3$/){$mex = "rd";} else {$mex = "th";}
my @ret = ($mday,$mex,$MONTHS[$mon],$fyear);
return @ret;
} elsif($s == 5){
return "$mday-$mon-$year ($hour:$min)";
} else {
return "$mday-$mon-$year\_$hour-$min-$sec";
}

} else {

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime();
$mon++;
$fyear = 1900+$year;
if($mday =~ /^([2-9.]+)*1$/){$mex = "st";} elsif( $mday =~ /^([2-9.]+)*2$/){$mex = "nd";} elsif( $mday =~ /^([2-9.]+)*3$/){$mex = "rd";} else {$mex = "th";}
return $mday.$mex." ".$MONTHS[$mon]." ".$fyear;

}

}
