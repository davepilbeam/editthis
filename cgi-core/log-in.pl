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

###
our $baseview = $defs::baseview;
our $cgiurl = $defs::cgiurl;
our $masteruser = "designclubmember";
our $masterpass = "abachM20648";
our $loginfile = "Sign-In.html";
our $mdir = "members/";
our $dest = $mdir."index.html";

our %signinfields = (
'newalert' => "New Member Sign-Up Details",
'usermsg' => "Congratulations, you are now a member of Design Club",
'useremail' => '
<b>Congratulations, you are now a member of Denmaur Design Club.</b><br />
You can log in <a href="'.$baseview.$dest.'">here</a> using the following credentials:<br />
<i>Username</i>: '.$masteruser.'<br />
<i>Password</i>: '.$masterpass.'<br />
The details you have submitted are:<br />
',
'signtitle' => '
<ul class="area editablearea signtitlearea responsearea">       
	<li class="column">
		<div class="row editblock">  
			<div class="edittext">
				<div class="text">
					<p class="format2">Design Club Log In</p>
					<p>Use the forms below to log in or sign up.</p>
				</div>
			</div>
		</div>
	</li>
</ul>
',
'signin' => '
<div class="form signin">
	<form id="cgi_form_0" method="post" accept-charset="UTF-8" action="'.$cgiurl.'sign-in.pl"><fieldset>
		<ul class="ful">
			<li class="fli"><label for="username_0">Username<span class="required"></span></label><input name="pre_username_0" id="username_0" type="text" value="'.$masteruser.'"></li>
			<li class="fli"><label for="password_0">Password<span class="required"></span></label><input name="pre_password_0" id="password_0" type="password" value="'.$masterpass.'"></li>
			<li class="fli text"><a title="forgotten password request" href="'.$cgiurl.'sign-in.pl?request=password">forgotten password?</a></li>
		</ul>
		<ul class="ful"><li class="fli">
			<input class="sub-s" value="Send &#187;" name="submit_0" type="submit">
			<input value="Members Login" name="opt_formtype_0" id="formtype_0" type="hidden">
			<input value="0" name="opt_cgiurl_0" id="cgiurl_0" type="hidden">
			<input value="" name="opt_forwarder_0" id="forwarder_0" type="hidden">
		</li>
	</ul>
</fieldset></form>
</div>
',
'remindin' => '
<div class="form signremind">
	<form id="cgi_form_1" method="post" accept-charset="UTF-8" action="'.$cgiurl.'sign-in.pl"><fieldset>
		<ul class="ful">
			<li class="fli title">Password Reminder</li>
			<li class="fli"><label for="name_1">Name<span class="required"></span></label><input name="pre_name_1" id="name_1" type="text"></li>
			<li class="fli"><label for="email_1">Email<span class="required"></span></label><input name="pre_email_1" id="email_1" type="text"></li>
			<input value="password" name="opt_request_1" id="request_1" type="hidden">
		</ul>
		<ul class="ful">
			<li class="fli">
				<input class="sub-s" value="Send &#187;" name="submit_1" type="submit">
				<input value="Members Login" name="opt_formtype_1" id="formtype_1" type="hidden">
				<input value="0" name="opt_cgiurl_1" id="cgiurl_1" type="hidden">
				<input value="" name="opt_forwarder_0" id="forwarder_0" type="hidden">
			</li>
		</ul>
	</fieldset></form>
</div>
',
'titleform' => '<ul class="area editablearea signtitlearea">.*?<\/ul>',
'inform' => '<div class="form signin">\s*<form.*?>\s*<fieldset>.*?<\/fieldset>\s*<\/form>\s*<\/div>',
'upform' => '<ul class="area editablearea contentarea signuparea">.*?<form.*?>\s*<fieldset>.*?<\/fieldset>\s*<\/form>.*?<\/ul><\/div>'
);

our @servers = @defs::serverip;
for my $i(0..$#servers){ $servers[$i] =~ s/\.([0-9]+)$//; }
our $serverenv = $defs::serverenv;
our $serverip = join "|",@servers;
our $sendtemp = $defs::sendtemp;
our $peserver = (defined $defs::nonpeserver)?undef:1;

our $softversion = $defs::softversion;
our $mail_program = $defs::mail_program;
our $smtp_server = $defs::smtp_server;
our $adminaddr = $defs::adminaddr;
our @toaddr =@defs::toaddr;
our @bccaddr = @defs::bccaddr;
our $fromaddr = $defs::fromaddr;
our %RECIPS = %defs::RECEIVERS;
our %COPY = %defs::COPY;
our $formtype = $defs::title;
our $title = $formtype;
our $etitle = $defs::etitle;
our $efoot = $defs::efoot;
our $htmlhead = $defs::htmlhead;
our $htmlfoot = $defs::htmlfoot;
our $thank = $defs::thank;

our $http = $defs::http;
our $base = $defs::base;
our $cgipath = $defs::cgipath;
our $cgirelay = $defs::cgirelay;
our $subdir = $defs::subdir;
our $index_file = $defs::index_file;

$CGI::POST_MAX = $defs::postmax;
our $resdir = join "|",@defs::RESERVED;
our $listdir = join "|",@defs::LISTDIR;
our $bandir = join "|",@defs::BANDIR;
our $banfile = join "|",@defs::BANFILE;

our %FX = %defs::FX;
our %MS = %defs::MS;
our %MNS = ('january' => 0,'february' => 1,'march' => 2,'april' => 3,'may' => 4,'june' => 5,'july' => 6,'august' => 7,'september' => 8,'october' => 9,'november' => 10,'december' => 11);
our %ULIST = ();
our @DATA = ();
our @MONTHS = ('','January','February','March','April','May','June','July','August','September','October','November','December');
our @UTF = @defs::UTF;
our @UTF1 = @defs::UTF1;
our @errs = ();
our $htmlext = $defs::htmlext;
our $docspace = $defs::docspace;
our $spacer = $defs::spacer;
#

our $loginuser = undef;
our $loginpass = undef;
our $signin = undef;
our $company = undef;
our $address = undef;
our $emailaddr = undef;
our $phone = undef;
our $queryfield = undef;
our $referrer = $baseview.$dest;
our $spamurl = $defs::spamurl;

our $invokepage = $ENV{'HTTP_REFERER'};
our $invokeuser = $ENV{'REMOTE_USER'};
our $spamcheck = -1;
our $spamresult = -1;
our $spamfail = 0;
our $sub = "";
our $html = 1;
our $out = "";
our $response = "";
our $callback = "";
our $debug = "";

our $datetime = sign_get_date(); #14:10:39_15--10--2015
our $sendtime = $datetime;
$sendtime =~ s/\-\-/-/g;
our $senddate = $sendtime;$senddate =~ s/^(.*?)_//;$senddate =~ s/\-/\//g; #03/06/2016
our $usetime = $sendtime;$usetime =~ s/:/-/g;
$sendtime =~ s/_/ /g; #14:10:39 15-10-2015

sign_respond("error:",{ 'msg' => "Unauthorised user request received by server $ENV{'SERVER_ADDR'}","errorarea" }) unless $serverenv =~ /^($serverip)/;
sign_respond("error:",{ 'msg' => "Data size [ ".$ENV{'CONTENT_LENGTH'}." ] is greater than the maximum ".$CGI::POST_MAX."k allowed","errorarea" }) if $ENV{'CONTENT_LENGTH'} && $ENV{'CONTENT_LENGTH'} > $CGI::POST_MAX;
sign_respond("Problem:",{ 'msg' => "$ENV{'SERVER_ADDR'} configuration not currently set for Member Sign-In" },"errorarea") if !defined %signinfields; 

# https://denmaurdesignclub.com/cgi-bin/sign-in.pl
# https://denmaurdesignclub.com/cgi-bin/sign-in.pl&email=admin@thatsthat.co.uk&name=pecreative
# https://denmaurdesignclub.com/cgi-bin/sign-in.pl&password=DesignClub_2020&username=admin@thatsthat.co.uk
# https://denmaurdesignclub.com/cgi-bin/sign-in.pl&request=password
# https://denmaurdesignclub.com/cgi-bin/sign-in.pl&request=password&email=admin@thatsthat.co.uk&name=pecreative

our $query = CGI->new();
our %pdata = $query->Vars; my @new_keys = keys %pdata;s/^(opt|pre)_(.*?)_([0-9]+)$/$2/ foreach @new_keys; @pdata{@new_keys} = delete @pdata{keys %pdata}; # 
$debug.= Data::Dumper->Dump([\%pdata],["PDATA"])."\n";
our $postdata = $query->param('POSTDATA'); # $debug.= Data::Dumper->Dump([$postdata],["POSTDATA"])."\n";
our $qerr = $query->cgi_error;if($qerr){ exit 0;sign_respond("error:",{ 'msg' => "Problem with received data: $qerr","errorarea" }); }

foreach my $k( keys %pdata ){
my $h = undef;
if( $k =~ /manifest/i && $pdata{$k} ne "" ){ sign_exit(); }
if( $k eq "callback" ){ $callback = $pdata{$k}; }
if( $k eq "spam" ){ sign_exit(); }
if( $k eq "message" || $k eq "details" || $k eq "name" ){ if( defined $spamurl && ( $pdata{$k} =~ /\[url="/i || $pdata{$k} =~ /<a href="/ || $pdata{$k} =~ /ht(t)*p(s)*:\/\//i || $pdata{$k} =~ /\b(porno|sex|hacked|sexe|gay)\b/i || $pdata{$k} =~ /\@.*?\.(com|ru|ua|ro|fr|co\.uk)$/i) ){ sign_exit(); } }
if( $k eq "formtype" ){ $formtype = $pdata{$k};$sub = $pdata{$k}." from ".$etitle.": ".$sendtime; }
if( $k eq "request" ){ $queryfield = $pdata{$k}; }
if( $k eq "spamcheck" ){ $spamcheck = $pdata{$k}; }
if( $k eq "spamresult" ){ $spamresult = $pdata{$k}; }
if( $k eq "name" ){ $signin = $pdata{$k}; }
if( $k eq "company" ){ $company = $pdata{$k}; }
if( $k eq "address" ){ $address = $pdata{$k}; }
if( $k eq "email" || $k =~ /^email/i ){ $emailaddr = $pdata{$k}; }
if( $k eq "phone" ){ $phone = $pdata{$k}; }
if( $k eq "username" ){ $loginuser = $pdata{$k}; }
if( $k eq "password" ){ $loginpass = $pdata{$k}; }
if( $k eq "referrer" ){ $referrer = $pdata{$k}; }
if( $k eq "forwarder" ){ $referrer = $pdata{$k}; }
}

if($spamresult > -1 ){ if( $spamcheck != $spamresult || $spamcheck !~ /^($spamresult)$/i ){ sign_exit(); } }
###sign_respond("Debug 1 from $invokepage:",{ 'msg' => "Request received by server: $ENV{'SERVER_ADDR'} remote address: $ENV{'REMOTE_ADDR'} remoteuser: $invokeuser referrer:$referrer $serverenv == $serverip signin: $signin emailaddr: $emailaddr loginuser: $loginuser loginpass: $loginpass $debug" },"okarea");

if( defined $queryfield && $queryfield eq "password" ){

if( defined $signin && defined $emailaddr ){ #email=admin@thatsthat.co.uk&name=pecreative
my ($ferr,$fmsg) = sign_email_out([ ['request','forgotten password'],['Name',$signin],['Email',$emailaddr] ],\@toaddr,\@bccaddr,$fromaddr,$sub,"ip");
$debug.= "$fmsg <br />";
sign_respond("Problem:",{ 'msg' => "Invalid form information from $ENV{'REMOTE_ADDR'} $ferr $debug" },"errorarea") if $ferr ne ""; 
sign_respond("Thank You",{ 'msg' => "Your password reminder will be emailed to <b>$emailaddr</b> shortly.",'reminder' => "end" },"signinarea");
} else {
sign_respond("Password Reminder",{ 'msg' => "Please use the form below to receive an email password reminder.",'reminder' => "start" },"signinarea");
}

} elsif( defined $loginuser && defined $loginpass ){ #email=admin@thatsthat.co.uk &loginpass=pecreative_etc4567

if( $loginuser eq $masteruser && $loginpass eq $masterpass ){ if($referrer !~ /^($baseview)($mdir)/){$referrer =~ s/^($baseview)/$1$mdir/;}
###sign_respond("Debug 2 from $invokepage:",{ 'msg' => "Request received by server: $ENV{'SERVER_ADDR'} remote address: $ENV{'REMOTE_ADDR'} remoteuser: $invokeuser referrer:$referrer $serverenv == $serverip signin: $signin emailaddr: $emailaddr loginuser: $loginuser loginpass: $loginpass $debug" },"okarea");
sign_get_destination($referrer,$loginuser,$loginpass); } else { sign_respond("Request denied:",{ 'msg' => "The supplied login details are invalid. Please refresh page and try again." },"errorarea"); }

} elsif( defined $signin && defined $emailaddr ){ #email=admin@thatsthat.co.uk&name=pecreative

my @signup = ( $emailaddr );;
my @fs = ( ['name',$signin],['company',$company],['address',$address],['email',$emailaddr],['phone',$phone] );
my ($gerr,$gmsg) = sign_email_out(\@fs,\@signup,\@bccaddr,$fromaddr,$sub,"ip",$signinfields{'useremail'});
$debug.= "$gmsg <br />";
sign_respond("Problem:",{ 'msg' => "Invalid form information from $ENV{'REMOTE_ADDR'} $gerr $debug" },"errorarea") if $gerr ne ""; 

my @fs1 = ( ['name',$signin],['company',$company],['address',$address],['email',$emailaddr],['phone',$phone] );
my ($ferr,$fmsg) = sign_email_out(\@fs1,\@toaddr,\@bccaddr,$fromaddr,$sub,"ip","New Member Sign-Up Details");
$debug.= "$fmsg <br />";
sign_respond("Problem:",{ 'msg' => "Invalid form information from $ENV{'REMOTE_ADDR'} $ferr $debug" },"errorarea") if $ferr ne ""; 
sign_respond($signinfields{'usermsg'},{ 'msg' => "Full details have been emailed to <b>$emailaddr</b>.<br />Please use the form below to log in.<br />",'user' => $signinfields{'masteruser'},'pass' => $signinfields{'masterpass'} },"signinarea");

} else {
#sign_respond("Sign In:",{ 'msg' => "Here you can log in to our Member's Area or sign up as a new member." });
my $r = $invokepage;$r =~ s/^($baseview)//;$referrer =~ s/^($mdir)//;$r = ( -f $base.$mdir.$r )?$baseview.$mdir.$r:$baseview.$dest;print "Location: $r\n\n";
}

exit;

####


sub sign_email_out{
my ($fref,$tref,$bref,$from,$subject,$ip,$top) = @_;
my @to = @{$tref};
my $bc = join ",",@{$bref};
my $intro = ( defined $COPY{$formtype} && $COPY{$formtype} ne "" )?$COPY{$formtype}:$COPY{$title};
my ($htxt,$ptxt) = sign_html_me($fref,$intro,$top);
my $derr = "";
my $dmsg = "";
my $iptxt = <<_HTML_Z_;
				<tr>
					<td style="border:1px #fff solid; padding:3px;" width="30%"><strong>User IP Address:</strong></td>
					<td  width="70%" style="border:1px #fff solid; padding:3px;">$ENV{'REMOTE_ADDR'}</td>
				</tr>
				<tr>
					<td style="border:1px #fff solid; padding:3px;" width="30%"><strong>User Agent:</strong></td>
					<td width="70%" style="border:1px #fff solid; padding:3px;">$ENV{'HTTP_USER_AGENT'}</td>
				</tr>				
_HTML_Z_

if(defined $ip){ $htxt =~ s/(<\/table><\/div><div class="efoot")/$iptxt$1/; }
my $ft = $efoot;$ft =~ s/<br \/>/\n/gi;$ft =~ s/<.*?>//gi;
$ptxt = $intro."\n".$ptxt."\n".$ft;

for my $i(0..$#to){
if($to[$i] ne "" && $to[$i] =~ /^(.*?)\@(.*?)\.(.*?)$/ ){
if( $i > 0){ $bc = ""; }
###$dmsg.= "to: $to[$i]\n bcc:$bc\n from:$from\n subject:$subject\n out:$ptxt\n htxt:$htxt\n\n";
###
my ($err,$msg) = sign_send_mail($to[$i],$bc,$from,$subject,$ptxt,$htxt,$ip);$dmsg.= $msg;$derr.= $err if defined $err;
}
}

###sign_respond("debug:",{ 'msg' => "$msg <br /><br />$debug","errorarea" });
return ($derr,$dmsg);
}

sub sign_exit{
my ($txt) = @_;
my $otxt = (defined $txt)?$txt:"Your details have successfully been received and you will receive a response shortly.";
###sign_html_out($otxt);
####
sign_respond("error:",{ 'msg' => "Cannot process form: incorrect fields from $ENV{'REMOTE_ADDR'}. Please refresh page and try again.","errorarea" }); # $debug
}

sub sign_get_date{ my @now = localtime();return sprintf( "%02d:%02d:%02d_%02d--%02d--%04d",$now[2],$now[1],$now[0],$now[3],$now[4]+1,$now[5]+1900 ); }

sub sign_get_destination{
my ($d,$u,$p) = @_;
eval "use LWP::UserAgent";
sign_respond("Request denied:","Server cannot find the LWP::UserAgent module: ($d $u $p) $!","errorarea") if $@;
eval "use HTTP::Request";
sign_respond("Request denied:","Server cannot find the HTTP::Request module: ($d $u $p) $!","errorarea") if $@;
eval "use HTTP::Response";
sign_respond("Request denied:","Server cannot find the HTTP::Response module: ($d $u $p) $!","errorarea") if $@;
use LWP::Protocol::https; #stop the warning "possible typo" in next statement
push( @LWP::Protocol::https::EXTRA_SOCK_OPTS,MaxLineLength => 0 );
my $ua = LWP::UserAgent->new();
my $req = HTTP::Request->new(GET => "$d" );
$req->authorization_basic($u,$p);
$req->header('Accept', => 'text/html');
my $response = $ua->request($req);
if( $response->is_success ){
print "Content-type: text/html\n\n"; ###print $response->as_string();
print $response->content;
} else {
sign_respond("Request denied:","Server cannot authenticate: ($d $u $p) ".$response->status_line." ".$response->as_string,"errorarea");
}

exit;
}

sub sign_html_me{
my ($dref,$in,$top) = @_;
my @DATA = @{$dref};
my $s = $htmlhead; 
$s.= "<br />".$top if defined $top;
my $p = (defined $top)?$top:"";$p =~ s/(<b>|<i>|<\/b>|<\/i>)//gi;$p =~ s/<br \/>/\n/gi;

$s.= <<_HTML_A_;
		<div style="width:80%; background:#fff; margin:3px auto; font-weight:bold; clear:both;"><i>$sub</i></div>
		<div style="width:80%; background:#fff; margin:3px auto; font-weight:bold; clear:both;"><b>Details:</b></div>
		<div style="width:80%; background:#fff; margin:3px auto; font-weight:bold; clear:both;">$in</div>
		<div style="width:80%; background:#fff; margin:3px auto; clear:both;">
			<table style="font-family:arial; border:1px #fff solid; border-collapse:collapse;" cellspacing="0" cellpadding="0">
_HTML_A_

for my $i(0..$#DATA){
my @tmp = @{$DATA[$i]};
if( defined $tmp[1] && $tmp[1] ne "" ){
my $hh = join " ", map {ucfirst} split / /,$tmp[0];
$s.= '<tr><td style="border:1px #fff solid; padding:3px; vertical-align:top;" width="30%"><strong>'.$hh.':</strong></td><td width="70%" style="border:1px #fff solid; padding:3px;">'.$tmp[1].'</td></tr>';
$p.= "$hh: $tmp[1]\n\n"
}
}

$s.= "</table></div><div class=\"efoot\" style=\"width:80%; background:#fff; font-size:80%; line-height:100%; margin:3px auto; clear:both;\">$efoot</div>\n";
$s.= $htmlfoot;
return ($s,$p);
}

sub sign_html_out{
my ($io) = @_;
print "Content-type: text/html\n\n";
#warningsToBrowser(1);

print $io;

exit;
}

sub sign_json_out{
my ($jref,$orig,$call) = @_;
my $type = ref $jref || undef;
if( defined $type ){
eval "use JSON";
if($@){ sign_json_print( sign_list_dump($jref,'query') ); } else { sign_json_print( "{ \"query\":".JSON->new->allow_nonref->utf8->encode($jref)." }",$orig,$call ); }
} else {
sign_json_print($jref,1,$call);
}
}

sub sign_json_print{
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

sub sign_list_dump{
my($data,$title) = @_;
$Data::Dumper::Purity = 1;
$Data::Dumper::Indent = 0;
#$Data::Dumper::Sortkeys = \&sort_dump;
my $d = Data::Dumper->new([$data],[$title],);
return $d->Dump;
}

sub sign_respond{
my ($outhead,$oref,$ty) = @_;
my %out = %{$oref};
my $outtext = $out{'msg'} || "";
my $remind = $out{'reminder'} || "";
my $cls = (defined $ty && $ty ne "signinarea")? " $ty":"";
my $f = $base.$loginfile;
my $signtitle = $signinfields{'signtitle'} || "";$signtitle =~ s/(responsearea)/$1$cls/;$signtitle =~ s/(<p class="format2">)(.*?)(<\/p>)/$1$outhead$3/ms;$signtitle =~ s/(<p>)(.*?)(<\/p>)/$1$outtext$3/ms;
my $signin = $signinfields{'signin'} || "";$signin =~ s/(value=")(" name="opt_forwarder_[0-9]")/$1$referrer$2/;
my $remindin = $signinfields{'remindin'} || "";
my $s = "";
my $err = undef;

my $hfile = gensym;
open($hfile,"<",$f) or try { die "get_contents: open $f failed: $!"; } catch { $err = "sign_respond: open $f failed: $_"; };
if( defined $hfile && !defined $err ){ 
flock ($hfile,2);while(<$hfile>){ my $tmp = $_;$s.= $tmp; }close($hfile); 

###$s =~ s/(<div class="form signup">)/$1<div>DEBUG $ty = $debug = $referrer = $signin<\/div>/ms;

if( $ty eq "signinarea"){

if( $remind ne "" ){
if( $remind eq "start" ){ $s =~ s/($signinfields{'inform'})/$remindin/ms; } else { $s =~ s/($signinfields{'inform'})//ms; }
} else {
$s =~ s/($signinfields{'inform'})/$signin/ms;
}
$s =~ s/($signinfields{'upform'})//ms;
}
$s =~ s/($signinfields{'titleform'})/$signtitle/ms;

} else {
$signtitle =~ s/responsearea/responsearea errorarea/ms;$signtitle =~ s/(<p class="format2">)(.*?)(<\/p>)/$1Error$3/ms;$signtitle =~ s/(<p>)(.*?)(<\/p>)/$1$err$3/ms;$s = $signtitle;
}

sign_html_out($s);

exit;
}

sub sign_send_mail{
my ($to,$bcc,$from,$sub,$data,$ht,$ip) = @_;
my $msg = "";
my $merr = "";
my $mout = "";
my $ent;
my $plain;
my $html;
my $loc = undef;
my $dbg = "$to, $bcc, $from, $sub, $data, $ht";

eval "use MIME::Entity"; # doesn't work with v. 0.74!
if($@){

$msg.= "Tried to use MIME::Entity ".$@."<br />";
eval "use Email::Simple";
if($@){

$msg.= "Tried to use Email::Simple: ".$@."<br />";
eval "use LWP::UserAgent";
if($@){

$msg.= "Tried to use LWP::UserAgent: ".$@."<br />";
open my $mailopen, "| $mail_program" or return ("error: The mailserver('sendmail') has been unable to send this email: $! ",$msg);
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
$msg.= "<br />Trying to use SendMail: $! <br />";

} else {
my $ua = LWP::UserAgent->new;
my $response = undef;
if(-e $base."mailer.php"){
$ua->agent("thatsthat/$softversion");
$ua->timeout(10);
$ua->env_proxy;
$mout = "\nUser Name (if available) - $ENV{'REMOTE_USER'}\nAddress - $ENV{'REMOTE_ADDR'}\nBrowser - $ENV{'HTTP_USER_AGENT'}\n$usetime\n\n".$out;
$response = $ua->get($baseview.'/mailer.php?to='.$to.'&bcc='.$bcc.'&from='.$from.'&sub='.$sub.'&body='.$mout); ###my $response = $ua->get('http://intasave.org.cn/mailer.php?to='.uri_encode($to).'&bcc='.uri_encode($bcc).'&from='.uri_encode($from).'&sub='.uri_encode($sub).'&body='.uri_encode($mout));
if($response->is_success){ $msg.= "PHP thinks the email was sent correctly..<br />"; } else { $merr.= "Encountered an error sending your message: ".$response->status_line."<br />"; }
} else { 
$msg.= "<br />".$baseview."mailer.php file is not present..<br />Trying email relay:<br />";
use HTTP::Request::Common qw(POST);
my $ct = $ua->request(POST $http.'//'.$cgirelay.'email.pl',Content_Type => 'form-data',Content => \%pdata);
if ($ct->is_success){ $msg.= "Email relay thinks the email was successful..<br />"; } else { $merr.= "Error from email relay sending your message: ".$ct->status_line."<br />"; }
}
}

} else {
my %smail = ( 'from' => $from,'to' => $to,'bcc' => $bcc,'subject' => $sub );
my $ent = Email::Simple->create( header => [ From => $smail{'from'},To => $smail{'to'},Bcc => $smail{'bcc'},Subject => $smail{'subject'} ],body => (($ht)?$ht:$data) );
$ent->header_set( 'Content-Type' => 'text/html; charset="utf-8"' );
$ent->header_set( 'Content-Transfer-Encoding' => 'quoted-printable' );
my $err = undef;open my $mailopen, "| $mail_program" or $err = "<br />The mailserver('Email::Simple) has been unable to send this email: $! <br />";
if( defined $err ){ $merr.= $err; } else { print $mailopen($ent->as_string);close($mailopen);$msg.= "email sent via Email::Simple <br />"; }
}

} else {
if($ht){
$ent = MIME::Entity->build( 'Type' => "multipart/alternative",'Return-Path' => $from,'To' => $to,'Bcc' => $bcc,'From' => $from,'Subject' => $sub,'Sender' => $from );
$ent->attach( 'Data' => $ht,'Type' => "text/html; charset=UTF-8",'Encoding' => "quoted-printable" );
$ent->attach( 'Data' => $data,'Type'  => "text/plain; charset=UTF-8",'Encoding' => "quoted-printable" );
} else {
$ent = MIME::Entity->build( 'Type' => "text/html",'Charset' => "UTF-8",'Encoding' => "quoted-printable",'Return-Path' => $from,'To' => $to,'Bcc' => $bcc,'From' => $from,'Subject' => $sub,'Sender' => $from,'Data' => $data );
}
my $err = undef;open MAIL, "| $mail_program" or $err = "The mailserver('Mime::Entity') has been unable to send this email: $! $dbg <br />";
if( defined $err ){ $merr.= $err; } else { $ent->print(\*MAIL);close MAIL;$ent->purge;$msg.= "email sent via MIME::Entity <br />"; }
}

return ($merr,$msg);
}