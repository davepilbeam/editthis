#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5

#editthis version:8.2.0

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

our $docuser = $defs::docuser;
our $docpass = $defs::docpass;
our %RECIPS = %defs::RECEIVERS;
our %COPY = %defs::COPY;

our $sitebase = $base;
our $the_time = localtime();

our $spamcheck = -1;
our $spamresult = -1;
our $spamfail = 0;
our $datetime = hi_get_date(); #14:10:39_15--10--2015
our $sendtime = $datetime;
$sendtime =~ s/\-\-/-/g;
our $senddate = $sendtime;$senddate =~ s/^(.*?)_//;$senddate =~ s/\-/\//g; #03/06/2016
our $usetime = $sendtime;$usetime =~ s/:/-/g;
$sendtime =~ s/_/ /g; #14:10:39 15-10-2015

#####

our $scoredir = "UPLOADS/SCORES/";
our $highfile = "-highscore.txt";
our $highdelimit = ",";
our $highlength = 10;
our @HM = ();
our @recipients = ();
our $to = "";
our $sub = "";
our $html;
our $reclist = "";
our $emailaddr = "";
our $copyto = "";
our $intro = "";
our $addscore = 3;
our $locate = "";
our $callback = "";
our $gameid;
our $gamename;
our $gamescore;
our $highname = "no-one";
our $highscore = 0;
our $noscript = 1;
our $formno = "";
our $method = '';
our $invoker = $ENV{'HTTP_REFERER'};
our $endout = "";
our $out = "";
our $resp = "";
our $response = "";
our $info = "";
our $sent = 0;
our $title = $formtype;
our $debug = "";

hi_respond("error:","Unauthorised user request received by server $ENV{'SERVER_ADDR'}") unless $serverenv =~ /^($serverip)/; # == $serverip / $debug
hi_respond("error:","Data size [ ".$ENV{'CONTENT_LENGTH'}." ] is greater than the maximum ".$CGI::POST_MAX."k allowed ") if $ENV{'CONTENT_LENGTH'} && $ENV{'CONTENT_LENGTH'} > $CGI::POST_MAX;

# highscore.pl?callback=Request.JSONP.request_map.request_3&game-id_0=dicethrow&addscore_0=0
# highscore.pl?callback=Request.JSONP.request_map.request_3&game-listonly=&game-id_0=dicethrow&game-score_0=1&pre_name_0=dave%20pilbeam&pre_email_0=davepilbeam%40duntmatter.com

our $query = CGI->new();
our %pdata = $query->Vars; my @new_keys = keys %pdata;s/^(opt|pre)_(.*?)_([0-9]+)$/$2/ foreach @new_keys; @pdata{@new_keys} = delete @pdata{keys %pdata}; # 
$debug.= Data::Dumper->Dump([\%pdata],["PDATA"])."\n";
our $postdata = $query->param('POSTDATA'); # $debug.= Data::Dumper->Dump([$postdata],["POSTDATA"])."\n";
our $qerr = $query->cgi_error;if($qerr){ exit 0;hi_respond("error:","Problem with received data: $qerr "); }

foreach my $k( keys %pdata ){
my $h = undef;
if( $k =~ /manifest/i && $pdata{$k} ne "" ){ hi_exit(); }
if( $k eq "spam" ){ hi_exit(); }
if( $k eq "message" || $k eq "details" || $k eq "name" ){ if( defined $spamurl && ($pdata{$k} =~ /ht(t)*p(s)*:\/\//i || $pdata{$k} =~ /\@.*?\.(com|ru|ua|ro|fr|co\.uk)$/i) ){ hi_exit(); } }

if( $k eq "addscore" ){ $addscore = $pdata{$k}; } # [enable send+scoring,enable scoring only,enable send only,none] 
if( $k eq "name" ){ $gamename = $pdata{$k}; }
if( $k eq "callback" ){ $callback = $pdata{$k}; }
if( $k eq "recipients" ){ $reclist = $pdata{$k}; }
if( $k eq "locate" ){ $locate = $pdata{$k}; }
if( $k eq "spamcheck" ){ $spamcheck = $pdata{$k}; }
if( $k eq "spamresult" ){ $spamresult = $pdata{$k}; }
if( $k eq "email" || $k =~ /^email/i ){ $emailaddr = $pdata{$k}; }
if( $k eq "formtype" ){ $formtype = $pdata{$k};$sub = $pdata{$k}." from ".$etitle.": ".$usetime; }
if( $k eq "copytype" ){ $copyto = $pdata{$k}; }
if( $k eq "html" ){ $html = undef; }
if( $k eq "js" ){ $noscript = ""; }
if( $k eq "game-id" ){ $gameid = $pdata{$k};$highfile = $scoredir.$gameid.$highfile; }
if ($k eq "game-score" ){ $gamescore = $pdata{$k}; }
if( $k eq "info" ){ $info = $pdata{$k}; }

if( $pdata{$k} =~ /\[url="/i || $pdata{$k} =~ /<a href="/ || $pdata{$k} =~ /http:\/\// ){ $spamfail = 1; }
if( $k ne "js" && $k ne "spam" && $k !~ /^(formtype|recipients|html|locate|spamcheck|spamresult|cgiurl|cgireturn|copytype|submit)$/i ){
my @ar = ($k,$pdata{$k});$out.= "$k = $pdata{$k}\n\n"; #$debug.= " $k = @ar<br />";
push @HM,[@ar];
}
}

###hi_json_out({ 'check 1' => "debug:$debug \n\naddscore:$addscore \ngameid:$gameid \nhighfile:$highfile \nrecipients:[ @recipients ] \nbcc:[ @bcc ] \n fromaddr:$fromaddr \n sub:$sub \n out:$out \n html:$html" });
my $ls = undef;
if(defined $gameid && $gameid ne ""){

$formtype = "game score submission";$sub = $formtype." from ".$etitle.": ".$sendtime;
if(defined $gamename && defined $gamescore && $gamescore ne "" && $emailaddr ne ""){ $ls = hi_highscore_in($gamescore,$gamename,$emailaddr);($endout,$resp) = hi_new_mail({ 'name' => $gamename,'score' => $gamescore,'email' => $emailaddr,'info' => $info },\@HM,\%RECIPS,\@bcc); } else { $ls = hi_highscore_in(); }
hi_json_print("$callback( {\"query\":[ $ls ]} );");

} else {

if( scalar @HM < 1 ){ 
hi_json_print("$callback( {\"query':[ [\"no data available\"] ] } );");
} else { 
($endout,$resp) = hi_new_mail({},\@HM,\%RECIPS,\@bcc); 
if($locate ne ""){
hi_respond("forwarding page to: ".$locate);
} else {
hi_html_out($endout);
}
}

}

exit;

####
sub hi_exit{
my ($txt) = @_;
my $otxt = (defined $txt)?$txt:"Incorrect request received";
hi_json_print("$callback( {\"query':[ [\"$otxt\"] ] } );")
#hi_respond("Alert:","Cannot process form: incorrect spam question field from $ENV{'REMOTE_ADDR'}. Please refresh page and try again.");
###print "Location: https://www.spamcop.net/\n\n"; 
}

sub hi_new_mail{
my ($dref,$href,$rref,$bref,$nsub,$nfrom) = @_;
my %data = (defined $dref)?%{$dref}:();
my %RECIPS = (defined $rref)?%{$rref}:();
my @NHM = (defined $href)?@{$href}:();
my @bcc = (defined $bref)?@{$bref}:();
my $end = "";
my $out = "";
my $intro = "";
my $eresp = "";
my $debug = "";

if( defined $COPY{$formtype} && $COPY{$formtype} ne "" ){
$intro = $COPY{$formtype};
} else {
$intro = $COPY{$title};
}

foreach my $k( sort keys %data){
my @ar = ($k,$data{$k});$out.= "$k = $data{$k}\n\n"; #$debug.= " $k = @ar<br />";
push @NHM,[@ar];
}

my $ftt = $efoot;
$ftt =~ s/<br \/>/\n/gi;
$ftt =~ s/<.*?>//gi;
$out = $intro."\n\n".$out."\n\n".$ftt;

$debug.= "\n\nreclist = ".$reclist."\n";
if($reclist ne ""){ #recipients = bcc reclist
if($reclist =~ /,/){
my @ls = split(/,/,$reclist);
for my $i(0..$#ls){$debug.= "RECIPS{$ls[$i]} = ".$RECIPS{$ls[$i]}."\n";
if( $RECIPS{$ls[$i]} ){ push @bcc,$RECIPS{$ls[$i]}; }
}
} else {
push @bcc,$RECIPS{$reclist};$debug.= "push = ".$RECIPS{$reclist}."\n";
}
}

if($spamresult > -1 ){ if( $spamcheck != $spamresult || $spamcheck !~ /^($spamresult)$/i ){ $spamfail = 1; } }

$end = hi_clean_xml($intro);

if($spamfail > 0){
hi_exit();
} else {

if($copyto ne ""){ # send to $emailaddr / bcc to @toaddr+@bcc
push @recipients,$emailaddr;
for my $i(0..$#toaddr){ push @bcc,$toaddr[$i]; }
} else {
for my $i(0..$#toaddr){ push @recipients,$toaddr[$i]; } #send to @toaddr / bcc to @bcc
}

###hi_json_out({ 'check 2' => "$debug = @recipients, @bcc, $fromaddr, $nsub, $out, $html" });

my $htm = hi_html_me($nsub,$intro,\@NHM);

if( defined $peserver ){

my $bc = join ",",@bcc;
for my $i(0..$#recipients){
if($recipients[$i] ne "" && $recipients[$i] =~ /^(.*?)\@(.*?)\.(.*?)$/ ){
if( $i > 0){ $bc = ""; }
$eresp = hi_send_mail($recipients[$i],$bc,$fromaddr,$nsub,$out.$debug,$htm); 
###hi_json_out("{ 'check 3' => "$debug = $eresp, $recipients[$i], $bc, $fromaddr, $nsub, $out, $html" });
}
}

} elsif( defined $authuser && defined $authpass ){
eval "use Net::SMTP";
if($@){

$debug.= "Tried to use Net::SMTP: ".$@."<br />";
my $bc = join ",",@bcc;
for my $i(0..$#recipients){
if($recipients[$i] ne "" && $recipients[$i] =~ /^(.*?)\@(.*?)\.(.*?)$/ ){
if( $i > 0){ $bc = ""; }
$eresp = hi_send_mail($recipients[$i],$bc,$fromaddr,$nsub,$out.$debug,$htm); 
###hi_json_out({ 'check 4' => "$debug = $eresp, $recipients[$i], $bc, $fromaddr, $nsub, $out, $html" });
}
}

} else {

my $mes = "";
my $ent = Net::SMTP->new($smtp_server,port=>$authport,Debug=>1) or $mes.= "$smtp_server Net::SMTP failed to create object ($!; $@)<br />";
$debug.= "mail server domain = ".$ent->domain."<br />host = ".$ent->host."<br />banner = ".$ent->banner."<br />";
if($mes ne ""){ hi_json_out({ 'error' => "$mes<br />The mailserver ($smtp_server) has been unable to send this email: $! $mes $debug" }); }
if( defined $authsmtp ){ $ent->auth($authuser,$authpass) or $mes.= "Can't authenticate into ".$ent->host." : $debug = ".$ent->message()."<br />"; }
my @goodto = ();
my @goodbcc = ();
if($mes eq ""){ 
$ent->mail($fromaddr);
@goodto = $ent->to(@recipients,{ SkipBad => 1 });
@goodbcc = $ent->bcc(@bcc,{ SkipBad => 1 });
$ent->data();
$ent->datasend("Subject: $nsub\n");
$ent->datasend("From: $fromaddr\n");
$ent->datasend("MIME-Version: 1.0\n");
$ent->datasend("Content-type: text/html; charset=UTF-8\n");
$ent->datasend("Content-Transfer-Encoding: 8bit\n");
$ent->datasend("\n");
if($html){ $ent->datasend("\n$htm\n"); } else { $ent->datasend("\n$out\n$debug\n"); }
$ent->dataend();
$debug.= "successful to: @goodto <br />successful bcc: @goodbcc <br /";
$ent->quit or hi_json_out({ 'error' => "$mes<br />email failed at quit: $mes <br /> $debug" });
}

}
}

###hi_json_out({ 'check 5' => "email sent: $debug \n\nfromaddr:$fromaddr \nsub:$nsub \nout:$out \nhtml:$html \neresp:$eresp" });
}

return ($end,$eresp);
}

sub hi_html_me{
my ($sub,$intro,$href) = @_;
my @M = (defined $href)?@{$href}:();
my $s = $htmlhead; 
$s.= <<_HTML_A_;
		<div style="width:550px; background:#fff; margin:5px; auto; font-weight:bold; clear:both;"><i>$sub</i></div>
		<div style="width:550px; background:#fff; margin:5px; auto; font-weight:bold; clear:both;"><b>Details:</b></div>
		<div style="width:550px; background:#fff; margin:5px; auto; font-weight:bold; clear:both;">$intro</div>
		<div style="width:550px; background:#fff; margin:5px; auto; clear:both;">
			<table style="border:1px #000 solid; border-collapse:collapse;" cellspacing="0" cellpadding="0">
_HTML_A_

for my $i(0..$#M){
if($M[$i][1] ne ""){
$s.= <<_HTML_B_;
				<tr>
					<td style="border:1px #000 solid; padding:4px;" width="30%"><strong>$M[$i][0]:</strong></td>
					<td colspan="2" width="70%" style="border:1px #000 solid; padding:4px;">$M[$i][1]</td>
				</tr>
_HTML_B_

}
}

$s.= <<_HTML_Z_;
				<tr>
					<td style="border:1px #000 solid; padding:4px;" width="30%"><strong>User IP Address:</strong></td>
					<td colspan="2" width="70%" style="border:1px #000 solid; padding:4px;">$ENV{'REMOTE_ADDR'}</td>
				</tr>
				<tr>
					<td style="border:1px #000 solid; padding:4px;" width="30%"><strong>User Agent:</strong></td>
					<td colspan="2" width="70%" style="border:1px #000 solid; padding:4px;">$ENV{'HTTP_USER_AGENT'}</td>
				</tr>				
			</table>
		</div >
		<div style="width:550px; background:#fff; font-size:80%; line-height:100%; margin:10px; auto; clear:both;">$efoot</div>		
_HTML_Z_

$s.= $htmlfoot;
return $s;
}

sub hi_respond{
my ($outhead,$outtext) = @_;
my $s = "";
my $w = <<_OUTPUT_;
<span class="email0">$outhead</span><br />
<br />
<ul class="email2"><li>$outtext</li></ul>
_OUTPUT_

if($noscript == "" && $method eq "get"){
if($outhead =~ /^forwarding page to:/){$s = $outhead;} else {$s = $w;}hi_html_out($s);

} elsif($outhead =~ /^forwarding page to:/){
$locate =~ s/_blank$//;
print "Location: $locate\n\n";

} else {
if( $invoker =~ /\/$/){$invoker.= $index_file;}
$invoker =~ s/($baseview)/$base/;
open(my $vlist, "<$invoker") or hi_html_out($w);
flock ($vlist, 2);
my @vlines = <$vlist>;
$s = join "",@vlines;
close($vlist);

$s =~ s/(<form id="cgi\_form\_$formno".*?<\/form>)/$w/ms;
hi_html_out($s);
}

exit;
}

sub hi_clean_html{
my ($s) = @_;
$s =~ s/[\t\r\f\n]//g;
$s =~ s/\&#3(6|8);$//g;
$s =~ s/\&amp;/\&#38;/g;
$s =~ s/([^a-zA-Z0-9\-\_\+\@\%\&\#<>'"=\/\.\$£\|,:;\(\)\{\}\?\!\[\]©®¬«»¦\~\s])//gmsi;
return $s;
}

sub hi_clean_xml{
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

sub hi_get_date{ my @now = localtime();return sprintf( "%02d:%02d:%02d_%02d--%02d--%04d",$now[2],$now[1],$now[0],$now[3],$now[4]+1,$now[5]+1900 ); }

sub hi_get_files{
my ($nb) = @_;
my @out;
find(sub { /$bandir/ and $File::Find::prune = 1;push @out,$File::Find::name if /\.($fxfile)$/i },$nb);
return @out;
}

sub hi_get_folders{
my ($nb) = @_;
my @out;
find(sub { /$bandir/ and $File::Find::prune = 1;push @out,$File::Find::name if -d },$nb); ##/^(.*?)($spacer)(Site)$/i 
return @out;
}

sub hi_get_html{
my ($nb) = @_;
my @out;
find(sub { /$bandir/ and $File::Find::prune = 1;push @out,$File::Find::name if /\.($htmlext|css)$/ },$nb);
return @out;
}

sub hi_html_out{
my ($io) = @_;
print "Content-type: text/html\n\n";
#warningsToBrowser(1);

print $io;

exit;
}

sub hi_json_out{
my ($jref) = @_;
my $type = ref $jref || undef;
if( defined $type ){
eval "use JSON";
if($@){ hi_json_print( hi_list_dump($jref,'query') ); } else { hi_json_print( "{ \"query\":".JSON->new->allow_nonref->utf8->encode($jref)." }" ); }
} else {
hi_json_print($jref,1);
}
}

sub hi_json_print{
my ($jtxt,$q) = @_;
print "Content-type: application/json; charset=UTF-8\n\n";
if( defined $q ){ 
print "{ \"query\":[ \"$jtxt\" ] }";
} else {
print $jtxt;
}
exit;
}

sub hi_list_dump{
my($data,$title) = @_;
$Data::Dumper::Purity = 1;
$Data::Dumper::Indent = 0;
#$Data::Dumper::Sortkeys = \&sort_dump;
my $d = Data::Dumper->new([$data],[$title],);
return $d->Dump;
}

sub hi_highscore_in{
my ($newscore,$newname,$newemail) = @_;
my %SCORE = ();
my $infile = $base.$highfile;
my @txt = ();
my $err = "";
my $addnew;
my $hfile;

return "[ 'the scoreboard is not currently online ($infile) $! ']" unless -f $infile;
my $op = (defined $newname && defined $newemail)?"+>>":"<";
open($hfile,$op,$infile) or return "[ '$infile: read error: $! ']";
flock ($hfile,2);
seek $hfile,0,0;

while(<$hfile>){
my ($line) = $_;
chomp($line);
my $dd = $line;
my @bits = split(/$highdelimit/,$dd); 
#$score,$name,$ip,$date,$email
#1,Dave Pilbeam,http://www.thatsthat.co.uk/Game.html,Fri Aug  2 17:28:28 2013,davepilbeam@duntmatter.com
$SCORE{$bits[1]}[0] = $bits[0];
$SCORE{$bits[1]}[1] = $bits[1];
$SCORE{$bits[1]}[2] = $bits[2];
$SCORE{$bits[1]}[3] = $bits[3];
$SCORE{$bits[1]}[4] = $bits[4];
}

if(defined $newname && defined $newscore){
if( $SCORE{$newname} && $SCORE{$newname}[4] eq $newemail && $SCORE{$newname}[0] > $newscore ){
#nowt
} else {
$SCORE{$newname}[0] = $newscore;
$SCORE{$newname}[1] = $newname;
$SCORE{$newname}[2] = $ENV{'REMOTE_ADDR'};
$SCORE{$newname}[3] = $the_time;
$SCORE{$newname}[4] = $newemail;
$addnew = 1;
truncate $hfile,0;
}
}

my $c = 1;
for my $name( sort { $SCORE{$b}[0] <=> $SCORE{$a}[0] || $SCORE{$b}[3] <=> $SCORE{$a}[3] || $SCORE{$a}[1] cmp $SCORE{$b}[1] } keys %SCORE ){
if($SCORE{$name}[0] ne ""){
if($c == 1){ $highscore = $SCORE{$name}[0];$highname = $name; }
if(defined $addnew){ print $hfile "$SCORE{$name}[0],$name,$SCORE{$name}[2],$SCORE{$name}[3],$SCORE{$name}[4]\n"; }
if($c < $highlength+1){ push @txt,"[ $c,$SCORE{$name}[0],\"$SCORE{$name}[1]\",\"$SCORE{$name}[3]\" ]"; }
$c++;
}
}

close($hfile);

if( !defined $txt[0] ){ $txt[0] = "1,$highscore,\"$highname\",\"$ENV{'REMOTE_ADDR'}\""; }
return ($err ne "")?"[ '$err' ]":(join ",",@txt);
}


sub hi_send_mail{
my ($to,$bcc,$from,$sub,$data,$ht) = @_;
my $mes = "";
my $mout = "";
my $ent;
my $plain;
my $html;
my $loc = undef;
my $dbg = "$to, $bcc, $from, $sub, $data, $ht";

eval "use MIME::Entity"; # doesn't work with v. 0.74!
if($@){

$mes.= "Tried to use MIME::Entity ".$@."<br />";
eval "use Email::Simple";
if($@){

$mes.= "Tried to use Email::Simple: ".$@."<br />";
eval "use LWP::UserAgent";
if($@){

$mes.= "Tried to use LWP::UserAgent: ".$@."<br />";
open my $mailopen, "| $mail_program" or return "error: $mes<br />The mailserver('sendmail') has been unable to send this email: $! ";
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
hi_html_out($mes."<br />Trying to use SendMail: $!.");

} else {
my $ua = LWP::UserAgent->new;
my $response = undef;
if(-e $base."mailer.php"){
$ua->agent("thatsthat/$softversion");
$ua->timeout(10);
$ua->env_proxy;
$mout = "\nUser Name (if available) - $ENV{'REMOTE_USER'}\nAddress - $ENV{'REMOTE_ADDR'}\nBrowser - $ENV{'HTTP_USER_AGENT'}\n$usetime\n\n".$out;
$response = $ua->get($baseview.'/mailer.php?to='.$to.'&bcc='.$bcc.'&from='.$from.'&sub='.$sub.'&body='.$mout); ###my $response = $ua->get('http://intasave.org.cn/mailer.php?to='.uri_encode($to).'&bcc='.uri_encode($bcc).'&from='.uri_encode($from).'&sub='.uri_encode($sub).'&body='.uri_encode($mout));
if($response->is_success){ $mes.= "PHP thinks the email was sent correctly..<br />"; } else { hi_json_out({ 'error' => "Encountered an error sending your message: ".$response->status_line }); }
} else { 
$mes.= "<br />Mailer.php file is not present..<br />Trying email relay:<br />";
use HTTP::Request::Common qw(POST);
my $ct = $ua->request(POST $http.'//'.$cgirelay.'email.pl',Content_Type => 'form-data',Content => \%pdata);
if ($ct->is_success){ $mes.= "Email relay thinks the email was successful..<br />"; } else { $mes.= "Error from email relay sending your message: ".$ct->status_line; }
}
}

} else {
my %smail = ( 'from' => $from,'to' => $to,'bcc' => $bcc,'subject' => $sub );
my $ent = Email::Simple->create( header => [ From => $smail{'from'},To => $smail{'to'},Bcc => $smail{'bcc'},Subject => $smail{'subject'} ],body => (($ht)?$ht:$data) );
$ent->header_set( 'Content-Type' => 'text/html; charset="utf-8"' );
$ent->header_set( 'Content-Transfer-Encoding' => 'quoted-printable' );
open my $mailopen, "| $mail_program" or hi_json_out({ 'error' => "$mes<br />The mailserver('Email::Simple) has been unable to send this email: $! " });
print $mailopen($ent->as_string);
close($mailopen);
}

} else {
if($ht){
$ent = MIME::Entity->build( 'Type' => "multipart/alternative",'Return-Path' => $from,'To' => $to,'Bcc' => $bcc,'From' => $from,'Subject' => $sub,'Sender' => $from );
$ent->attach( 'Data' => $ht,'Type' => "text/html; charset=UTF-8",'Encoding' => "quoted-printable" );
$ent->attach( 'Data' => $data,'Type'  => "text/plain; charset=UTF-8",'Encoding' => "quoted-printable" );
} else {
$ent = MIME::Entity->build( 'Type' => "text/html",'Charset' => "UTF-8",'Encoding' => "quoted-printable",'Return-Path' => $from,'To' => $to,'Bcc' => $bcc,'From' => $from,'Subject' => $sub,'Sender' => $from,'Data' => $data );
}
#$ent->smtpsend or hi_html_out("The mailserver('Mime::Entity') has been unable to send this email: $! $dbg");
#or
#
open MAIL, "| $mail_program" or hi_json_out({ 'error' => "The mailserver('Mime::Entity') has been unable to send this email: $! $dbg" });$ent->print(\*MAIL);close MAIL;
$ent->purge;
}

return $mes;
}
