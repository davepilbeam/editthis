#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5
###use cPanelUserConfig;
#editthis version:8.2.3 EDGE

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
###email_respond("test:","cgix: $cgix = envpath: $envpath = incerr: $incerr = serverenv: $defs::serverenv");

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

our $docuser = $defs::docuser;
our $docpass = $defs::docpass;
our %RECIPS = %defs::RECEIVERS;
our %COPY = %defs::COPY;

our $sitebase = $base;
our $the_time = localtime();

our @HM = ();
our @RRM = ();
our @SHOP = ();
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
our $NFout = "";
our $RRout = "";
our $rout = "";
our $response = "";
our @returnlist = ();
our $returnmail = undef;
our $title = $formtype;
our $shoptotal;
our %fullbirthdate = ( day => "",month => "",year => "" );
our $birthstartswitch = undef;
our %fullstartdate = ( day => "",month => "",year => "",time => "" );
our $datestartswitch = undef;
our %fullenddate = ( day => "",month => "",year => "",time => "" );
our $dateendswitch = undef;
our %fullname = ( title => "",first => "",last =>"" );
our $nameswitch = undef;
our $allfields = undef;
our @NOFILL = ();
my $nozip = undef;
our $ask = undef;
our $callback = "";
our $endout = "";
our $eresp = "";
our $debug = "";

our $datetime = email_get_date(); #14:10:39_15--10--2015
our $sendtime = $datetime;
$sendtime =~ s/\-\-/-/g;
our $senddate = $sendtime;$senddate =~ s/^(.*?)_//;$senddate =~ s/\-/\//g; #03/06/2016
our $usetime = $sendtime;$usetime =~ s/:/-/g;
$sendtime =~ s/_/ /g; #14:10:39 15-10-2015

$CGI::POST_MAX = $defs::postmax;

email_respond("error:","Unauthorised user request received by server $ENV{'SERVER_ADDR'}") unless $serverenv =~ /^($serverip)/; # == $serverip / $debug
our $xx = ( $xxurl ne "" && $ENV{'REMOTE_ADDR'} =~ /^($xxurl)/ )?1:( $xurl ne "" && $ENV{'REMOTE_ADDR'} =~ /($xurl)/ )?1:0;if($xx > 0){ email_exit(); }

email_respond("error:","Data size [ $ENV{'CONTENT_LENGTH'} ] is greater than the maximum  $defs::postmax k allowed ") if $ENV{'CONTENT_LENGTH'} && $ENV{'CONTENT_LENGTH'} > $CGI::POST_MAX;

our $query = CGI->new();
our %pdata = $query->Vars; my @new_keys = keys %pdata;s/^(opt|pre)_(.*?)_([0-9]+)$/$2/ foreach @new_keys; @pdata{@new_keys} = delete @pdata{keys %pdata}; # $debug.= Data::Dumper->Dump([\%pdata],["PDATA"])."\n";
our $postdata = $query->param('POSTDATA'); # $debug.= Data::Dumper->Dump([$postdata],["POSTDATA"])."\n";
our $qerr = $query->cgi_error;if($qerr){ exit 0;email_respond("error:","Problem with received data: $qerr "); }

if( $formtype =~ /Library/i && !defined $pdata{'library'} ){ email_exit(); }

foreach my $k( keys %pdata ){
my $h = undef;
if( $k =~ /manifest/i && $pdata{$k} ne "" ){ email_exit(); }
if( $k eq "callback" ){ $callback = $pdata{$k}; }
if( $k eq "spam" ){ email_exit(); }
if( defined $spamurl ){
if( $k eq "message" || $k eq "details" || $k eq "name" ){ 
if( $pdata{$k} =~ /\@/ ){ email_exit(); }
if( $pdata{$k} =~ /ht(t)*p(s)*:\/\//i || $pdata{$k} =~ /\b(porno|hotmail|sex|hacked|sexe|gay)\b/i || $pdata{$k} =~ /\@.*?\.(com|ru|ua|ro|fr|co\.uk)$/i ){ email_exit(); } 
}
}
if( $k eq "recipients" ){ $reclist = $pdata{$k}; }
if( $k eq "locate" ){ $locate = $pdata{$k}; }
if( $k eq "spamcheck" ){ $spamcheck = $pdata{$k}; }
if( $k eq "spamresult" ){ $spamresult = $pdata{$k}; }
if( $k eq "formtype" ){ $formtype = $pdata{$k};$sub = $pdata{$k}." from ".$etitle.": ".$usetime; }
if( $k eq "copytype" ){ $copyto = $pdata{$k}; }
if( $k eq "email" || $k =~ /^email/i ){ $emailaddr = $pdata{$k}; }
if( $k eq "library" ){ @libraryfiles = split /\|\|/,$pdata{$k}; } #Digital/Case-Studies/RSM-Case-Study-1.pdf||Digital/Case-Studies/RSM-Case-Study-3.pdf||Digital/Data-Sheets/zRSM-Realtime-Data-Sheet.pdf\
if( $k eq "html" ){ $html = undef; }
if( $k eq "js" ){ $noscript = ""; }
if( $k eq 'zip' ){ $nozip = 'ok'; }
if( $k eq 'ask' ){ $ask = "ok";push @recipients,'admin@thatsthat.co.uk'; }

if($k=~ /^allfields/i){if($pdata{$k} ne ""){$allfields = 1;}$h = 1;}

if( $k=~ /^birthday/i ){ if($pdata{$k} ne ""){ $fullbirthdate{'day'} = $pdata{$k}.email_date_ext($pdata{$k});$birthstartswitch = "birthyear"; }$h = 1; }
if( $k=~ /^birthmonth/i ){ if($pdata{$k} ne ""){ $fullbirthdate{'month'} = $pdata{$k};$birthstartswitch = "birthyear"; }$h = 1; }
if( $k=~ /^birthyear/i ){ if($pdata{$k} ne ""){ $fullbirthdate{'year'} = $pdata{$k};$birthstartswitch = "birthyear"; } }

if( $k=~ /^datestartday/i ){ if($pdata{$k} ne ""){ $fullstartdate{'day'} = $pdata{$k}.email_date_ext($pdata{$k});$datestartswitch = "datestarttime"; }$h = 1; }
if( $k=~ /^datestartmonth/i ){ if($pdata{$k} ne ""){ $fullstartdate{'month'} = $pdata{$k};$datestartswitch = "datestarttime"; }$h = 1; }
if( $k=~ /^datestartyear/i ){ if($pdata{$k} ne ""){ $fullstartdate{'year'} = $pdata{$k};$datestartswitch = "datestarttime"; }$h = 1; }
if( $k=~ /^datestarttime/i ){ if($pdata{$k} eq ""){ $pdata{$k} = "(time not specified)"; }$fullstartdate{'time'} = $pdata{$k};$datestartswitch = "datestarttime"; }

if( $k=~ /^dateendday/i ){ if($pdata{$k} ne ""){ $fullenddate{'day'} = $pdata{$k}.email_date_ext($pdata{$k});$dateendswitch = "dateendtime"; }$h = 1; }
if( $k=~ /^dateendmonth/i ){ if($pdata{$k} ne ""){ $fullenddate{'month'} = ucfirst $pdata{$k};$dateendswitch = "dateendtime"; }$h = 1; }
if( $k=~ /^dateendyear/i ){ if($pdata{$k} ne ""){ $fullenddate{'year'} = $pdata{$k};$dateendswitch = "dateendtime"; }$h = 1; }
if( $k=~ /^dateendtime/i ){ if($pdata{$k} eq ""){ $pdata{$k} = "(time not specified)"; }$fullenddate{'time'} = $pdata{$k};$dateendswitch = "dateendtime"; }

if( $k=~ /^nametitle/i ){ if($pdata{$k} ne ""){ $fullname{'title'} = $pdata{$k};$nameswitch = "namelastname"; }$h = 1; }
if( $k=~ /^namefirstname/i ){ if($pdata{$k} ne ""){ $fullname{'first'} = ucfirst $pdata{$k};$nameswitch = "namelastname"; }$h = 1; }
if( $k=~ /^namelastname/i ){ if($pdata{$k} ne ""){ $fullname{'last'} = $pdata{$k};$nameswitch = "namelastname"; } }

if($k eq "returncopy_X"){if($pdata{$k} ne ''){$returnmail = $pdata{$k};}$h = 1;}
if($k eq "returnlist_X"){if($pdata{$k} ne ''){ @returnlist = split(/\|/,$pdata{$k});for my $i( 0..$#returnlist ){ $returnlist[$i] =~ s/^(pre|opt)_(.*?)_([0-9]+)$/$2/; } }$h = 1;}
if($k=~ /^shoporder-([0-9]+)/i){ push @SHOP,$pdata{$k};$h = 1; }
if($k=~ /^shoptotal/i){ $shoptotal = $pdata{$k};$h = 1; }

if( $pdata{$k} =~ /\[url="/i || $pdata{$k} =~ /<a href="/ || $pdata{$k} =~ /http:\/\// ){ $spamfail = 1; }
##if($pdata{$k} ne ""){ 
if( $k ne "js" && $k ne "ask" && $k ne "spam" && $k !~ /manifest/i && !email_process($k,$pdata{$k}) && !defined $h && $k !~ /^(formtype|recipients|html|locate|spamcheck|spamresult|cgiurl|cgireturn|copytype|zip|submit)$/i ){
my @ar = ();
if( defined $MAP{$k} ){ 
@ar = ($MAP{$k},$pdata{$k});$out.= "$MAP{$k} = $pdata{$k}\n\n"; 
} elsif($k eq "namelastname"){ 
@ar = ( "name",$fullname{'title'}." ".$fullname{'first'}." ".$fullname{'last'}."" ); 
} elsif($k eq "datestarttime"){ 
@ar = ("arrival",$fullstartdate{'day'}." ".$fullstartdate{'month'}." ".$fullstartdate{'year'}." at ".$fullstartdate{'time'} ); 
} elsif($k eq "dateendtime"){ 
@ar = ("departure",$fullenddate{'day'}." ".$fullenddate{'month'}." ".$fullenddate{'year'}." at ".$fullenddate{'time'}); 
} elsif($k =~ /birthyear$/){ 
@ar = ("date of birth",$fullbirthdate{'day'}." ".$fullbirthdate{'month'}." ".$fullbirthdate{'year'} );
} else { 


if( $k eq "library" && ( scalar @libraryfiles > 0 ) && !defined $nozip ){ 	
		
#Digital/Digital/Arctic-Snow-Digital	
#Digital/Coated/Arctic-Matt	
my %lfiles = ();	
my $t = "";	
for my $i(0..$#libraryfiles){ 	
$libraryfiles[$i] =~ s/^($resourcefolder)(.+)\.(jpg|png|gif)$/$2/i;	
$libraryfiles[$i] =~ s/^(.*?)\/(.*?)-$1$/$2/i;	
$libraryfiles[$i] =~ s/^.+\///i;	
$lfiles{$libraryfiles[$i]} = $libraryfiles[$i];	
}	
$out.= "$k = ";	
for my $key (sort keys %lfiles){ $t.= $key."<br />";$out.= " $key \n "; }	
@ar = ($k,$t);$out.= "\n\n"; 	
		
} else { 	
@ar = ($k,$pdata{$k});$out.= "$k = $pdata{$k}\n\n"; 	
}

}
#$debug.= " $k = @ar<br />";
push @HM,[@ar];
}
##} else { push @NOFILL,[@ar];$NFout.= $k." = ".$pdata{$k}."\n\n"; }
}

if( scalar @returnlist > 0){
for my $i( 0..$#HM ){
my @hi = @{$HM[$i]};
if( $hi[0] eq "name" && $nameswitch eq "namelastname" ){ 
push @RRM,[@hi];$RRout.= $hi[0]." = ".$hi[1]."\n\n"; 
} elsif( $hi[0] eq "arrival" && $datestartswitch eq "datestarttime" ){ 
push @RRM,[@hi];$RRout.= $hi[0]." = ".$hi[1]."\n\n";
} elsif( $hi[0] eq "departure" && $dateendswitch eq "dateendtime" ){ 
push @RRM,[@hi];$RRout.= $hi[0]." = ".$hi[1]."\n\n"; 
} elsif( $hi[0] eq "date of birth" && $birthstartswitch eq "birthyear" ){ 
push @RRM,[@hi];$RRout.= $hi[0]." = ".$hi[1]."\n\n"; 
} elsif( grep { $_ eq $hi[0] } @returnlist ){ 
push @RRM,[@hi];$RRout.= $hi[0]." = ".$hi[1]."\n\n"; 
} else {
#
}
}
}


##if( defined $allfields ){ push @HM,@NOFILL; }
#$debug.= "allfields: $allfields = ".(  Data::Dumper->Dump([\@HM,'HM']) )." ".(  Data::Dumper->Dump([\@libraryfiles],'libraryfiles') )."== \n\n@NOFILL\n";

email_respond("error:","Warning: no Form data was received: $debug") unless scalar @HM > 0;

if( defined $COPY{$formtype} && $COPY{$formtype} ne "" ){
$intro = $COPY{$formtype};
} else {
$intro = $COPY{$title};
}

my $ftt = $efoot;
$ftt =~ s/<br \/>/\n/gi;
$ftt =~ s/<.*?>//gi;
$out = $intro."\n\n".$out.( (defined $allfields)?$NFout:"" )."\n\n".$ftt;
$rout = $intro."\n\n".$returnmail."\n\n".$RRout."\n\n".$ftt;

$debug.= "\n\nreclist = ".$reclist."\n";
if($reclist ne "" && !defined $ask){#recipients = bcc reclist
if($reclist =~ /,/){
my @ls = split(/,/,$reclist);
for my $i(0..$#ls){$debug.= "RECIPS{$ls[$i]} = ".$RECIPS{$ls[$i]}."\n";
if( $RECIPS{$ls[$i]} ){ push @bcc,$RECIPS{$ls[$i]}; }
}
} else {
push @bcc,$RECIPS{$reclist};$debug.= "push = ".$RECIPS{$reclist}."\n";
}
}

if( !defined $ask ){
if($spamresult > -1 ){ if( $spamcheck != $spamresult || $spamcheck !~ /^($spamresult)$/i ){ $spamfail = 1; } }
if( scalar @HM < 1 ){ $spamfail = 1; }
} else {
$sub = "PETE is online at  ".$pdata{'site'}."/".$pdata{'page'}.": ".$usetime;
}
$endout = email_clean_xml($intro);

if($spamfail > 0){
email_exit(); 
} else {

if( !defined $ask ){
if($copyto ne ""){ # send to $emailaddr / bcc to @toaddr+@bcc
push @recipients,$emailaddr;
for my $i(0..$#toaddr){ push @bcc,$toaddr[$i]; }
} else {
for my $i(0..$#toaddr){ push @recipients,$toaddr[$i]; } #send to @toaddr / bcc to @bcc
}
}

###email_json_out("{ \"check 2\":\"$debug = @recipients, @bcc, $fromaddr, $sub, $out, $html \" }");

if($html){ $html = email_html_me(\@HM); }

my $bc = join ",",@bcc;
for my $i(0..$#recipients){
if($recipients[$i] ne "" && $recipients[$i] =~ /^(.*?)\@(.*?)\.(.*?)$/ ){
if( $i > 0){ $bc = ""; }
$eresp = email_send_mail($recipients[$i],$bc,$fromaddr,$sub,$out.$debug,$html); 
###email_json_out("{ \"check 3\":\"$debug = $recipients[$i], $bc, $fromaddr, $sub, $out, $html \" }");
}
}
###email_json_out("{ \"check 5\":\"email sent: $debug = $fromaddr, $sub, $out, $html \" }");

###email_respond("check 6: $returnmail = $emailaddr = $fromaddr, $sub, $out.$debug, $html");
if( defined $returnmail && $emailaddr ne "" && $emailaddr =~ /^(.*?)\@(.*?)\.(.*?)$/ ){
if($html){$html = email_html_me(\@RRM);}
$html = "\n\n".$returnmail."\n\n".$html;
$eresp = email_send_mail($emailaddr,"",$fromaddr,$sub,$rout,$html); 
}

}

if( defined $ask){
email_json_out({ 'response' => "email sucessfully sent to @recipients" },undef,$callback);

} elsif( scalar @libraryfiles > 0 ){
###email_json_out({ 'check 7' => "libraryfiles: \n@libraryfiles \nnozip: $nozip \n\n $debug" });	
if( defined $nozip){	
email_html_out( $endout );	
} else {	
for my $i(0..$#libraryfiles){ $libraryfiles[$i] = $base.$docview.$libraryfiles[$i]; }
###email_json_out({ 'check 7' => "libraryfiles: \n@libraryfiles \n\n $debug" });
$endout = email_zip_out(\@libraryfiles,$base.$backupbase.$resourcefolder.$usetime.".zip",undef);
email_html_out( $endout );
}

} else {

if($locate ne ""){
email_respond("forwarding page to: ".$locate);
} elsif( defined $shoptotal && scalar @SHOP > 0 ){
print "Content-type: application/json; charset=UTF-8\n\n";
print "{ \"query\":{ \"response\":\"$endout\" } }";
exit;
} else {

###SMTP check = email_html_out( $endout."\n".$eresp );
email_html_out( $endout ); #email_respond( $thank,email_clean_xml($COPY{$formtype}) );
}

}

exit;

####

sub email_zip_file{
my ($u,$zip) = @_;
my $nz = $u;$nz =~ s/^.+\///;
my $msg ="";
$zip->addFile($u,$nz);$msg.= "[file > file] add $nz \n";
return $msg;
}

sub email_zip_dir{
my ($u,$zip) = @_;
my $msg ="";
my $nz = $u;$nz =~ s/^($base)//;$nz =~ s/^\///;
$zip->addDirectory($u,$nz);$msg.= "[dir > dir] add $nz \n";
return $msg;
}

sub email_zip_out{
# u:  '/var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/documents'
# fref: [ '/var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/documents/Site Pages','/var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/documents/Canvas' ]
# fref: [ '/var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/documents/Images/logos/customers','/var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/TESTreviewlogo.jpg' ]
# dir: documents
# nwzip:  '/var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/admin/BACKUP/documents16-01-17.zip'
my ($fref,$nwzip,$save) = @_;
my @f = @{ $fref };
my $utitle = $nwzip;$utitle =~ s/^($base)//;
my $ztitle = $utitle;$ztitle =~ s/^($backupbase)//;
my $msg = "";
my $size = 0;
my $stxt = "";
my $adj = undef;
my $data = undef;
my $dbug = "";
###email_json_out({ 'check zip_out' => "nf: @f \nnwzip: $nwzip \n save: $save \n\n$debug'" });

eval "use Archive::Zip qw( :ERROR_CODES :CONSTANTS )";
if( $@ ){
$msg = "Unfortunately this server can't use Archive::Zip: $@ ";
} else {

eval "use File::Temp qw(:seekable tempfile tempdir)";
if( $@ ){
$msg = "Unfortunately this server can't use File::Temp: $@ ";
} else {

my $zip = Archive::Zip->new();
foreach my $fz( @f ){
if( -f $fz ){ $dbug.= email_zip_file($fz,$zip); }
if( -d $fz ){ $dbug.= email_zip_dir($fz,$zip); }
}

###email_json_out({ 'check zip_out 1' => "dbug:\n$dbug\n\n \nf:@f \nnwzip:$nwzip \nsave:$save \n\n \n\n$debug'" });

my $status = $zip->writeToFileNamed($nwzip);
if( $status == "AZ_OK" ){

###email_json_out({ 'check zip_out 2' => "@f \n\nnwzip: $nwzip \n save: $save \n\n dbg = $dbug \n\n$debug" });
$size = -s "$nwzip";
$stxt = email_get_size($nwzip);
if( $size > $CGI::POST_MAX ){ $CGI::POST_MAX = $size+1000;$adj = 1; }
###email_json_out({ 'check zip_out 3' => "adj: $adj\nutitle: $utitle \nztitle: $ztitle \nnwzip: $nwzip \n size: $size <>  ${CGI::POST_MAX} \nstxt: $stxt \nsave: $save \n\n dbg = $dbug \n\nf: \n@f \n\n$debug" });

if( defined $save ){
$msg = "<a href=\"$utitle\" title=\"link to download zip\">Download $ztitle Zip ( $stxt )</a>";
} else {

print "Content-Type:x-download\n";
print "Content-Disposition: attachment;filename=\"$ztitle\"\n\n";
my $hfile = gensym;
open($hfile,$nwzip);
binmode $hfile;
print <$hfile>;
close $hfile;
unlink $nwzip or $msg.= "download error: delete file [ $nwzip ] failed: $!";

}
if( defined $adj ){ $CGI::POST_MAX = $defs::postmax; }

} else {
$msg = "Download Zip: the server cannot write zip [ $nwzip ]: $!";
}

}
}
return $msg;
}

sub email_clean_xml{
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

sub email_date_ext{ my ($d) = @_;my $m = "";if($d =~ /^([2-9.]+)*1$/){$m = "st";} elsif( $d =~ /^([2-9.]+)*2$/){$m = "nd";} elsif( $d =~ /^([2-9.]+)*3$/){$m = "rd";} else {$m = "th";}return $m; }

sub email_exit{
my ($txt) = @_;
my $otxt = (defined $txt)?$txt:"Your details have successfully been received and you will receive a response shortly.";
email_html_out($otxt);
#email_respond("Alert:","Cannot process form: incorrect spam question field from $ENV{'REMOTE_ADDR'}. Please refresh page and try again.");
###print "Location: https://www.spamcop.net/\n\n"; 
}

sub email_get_date{ my @now = localtime();return sprintf( "%02d:%02d:%02d_%02d--%02d--%04d",$now[2],$now[1],$now[0],$now[3],$now[4]+1,$now[5]+1900 ); }

sub email_get_remote{
my ($dest,$data,$relay) = @_;
my $err = undef;
my $ct = undef;
my $req = undef;
my $ret = undef;

eval "use LWP::UserAgent";
if($@){
$err = "Unfortunately this server can\'t use LWP::UserAgent to open $dest:<br />Reason: $@";
} else {

my $ua = LWP::UserAgent->new;
$ua->agent("thatsthat/$softversion");
$ua->timeout(30);

if($relay && $data){
use HTTP::Request::Common qw(POST);
$ct = $ua->request(POST $dest,Content_Type => 'form-data',Content => $data); #return ("remote: sending $dest = $data = $relay","$dest = $data = $relay ".$ct->status_line);
} elsif($data){
$req = HTTP::Request->new(POST => $dest);
$req->content_type("application/x-www-form-urlencoded");
$req->content($data);
$ct = $ua->request($req);
} else {
$ct = $ua->get("$dest");
}

if ($ct->is_success){
$ret = $ct->content; 
} else {
$err.= "Unfortunately the page $dest isn\'t responding: ".$ct->status_line;
}

}

return ($ret,$err);
}

sub email_get_size{ my ($i) = @_;my $ftps = -s $i;$ftps = $ftps/1000;my $s = int( $ftps + .5 * ($ftps <=> 0) );if($s < 1){$s = 1;}return $s."k"; }

sub email_html_me{
my ($dref,$ip) = @_;
my @DATA = @{$dref};
my $s = $htmlhead; 

if($spamfail > 0){
$s.= "<div style=\"width:80%; background:#fff; margin:3px auto; font-weight:bold; clear:both;\"><b style=\"color:#c00;\">SPAM TEST FAIL</b></div>";
}

$s.= <<_HTML_A_;
		<div style="width:80%; background:#fff; margin:3px auto; font-weight:bold; clear:both;"><i>$sub</i></div>
		<div style="width:80%; background:#fff; margin:3px auto; font-weight:bold; clear:both;"><b>Details:</b></div>
		<div style="width:80%; background:#fff; margin:3px auto; font-weight:bold; clear:both;">$intro</div>
		<div style="width:80%; background:#fff; margin:3px auto; clear:both;">
			<table style="font-family:arial; border:1px #000 solid; border-collapse:collapse;" cellspacing="0" cellpadding="0">
_HTML_A_

my %fields = ();
for my $i(0..$#DATA){
if( defined $allfields || $DATA[$i][1] ne "" ){
my $ff = ($DATA[$i][1] eq "")?" color:#888; background-color:#efefef;":"";
my $hh = join " ", map {ucfirst} split / /,$DATA[$i][0];
$fields{ (lc $hh) } = '<tr><td style="border:1px #000 solid; padding:3px; vertical-align:top;'.$ff.'" width="30%"><strong>'.$hh.':</strong></td><td width="70%" style="border:1px #000 solid; padding:3px;'.$ff.'">'.$DATA[$i][1].'</td></tr>';
}
}

if( @emailorder && scalar @emailorder > 0 ){
for my $i(0..$#emailorder){ if( defined $fields{$emailorder[$i]} ){ $s.= $fields{$emailorder[$i]};delete $fields{$emailorder[$i]}; } }
} else {
foreach my $k( sort keys %fields){ $s.= $fields{$k}; };
}

for my $i(0..$#SHOP){
if($SHOP[$i] ne ""){ #Main Era: 20 Other Lists Inc 28mm, Size: 20mm, Period: Colonial, Quality: Excellent, Detail: Infantry, Photo: 39475, Unit Number: 3, Reference: 24 Zulus, Pieces: 24, Price/piece £: 2, Total £: 48, Amount: 1, Subtotal: 48)
$SHOP[$i] =~ s/:/:<\/b>/g;
$SHOP[$i] =~ s/(Unit Number:<\/b>)(.*?),/$1<b style="color:\#006400;">$2<\/b>,/ig;
#$SHOP[$i] =~ s/, /, <br \/><b>/g;
my $u = 1+$i;
$s.= <<_HTML_S_;
				<tr>
					<td style="border:1px #000 solid; padding:3px; vertical-align:top;" width="30%"><strong>Shop Order $u:</strong></td>
					<td width="70%" style="border:1px #000 solid; padding:3px;"><b>$SHOP[$i]</td>
				</tr>
_HTML_S_

}
}

if( defined $shoptotal ){
$s.= <<_HTML_T_;
				<tr>
					<td style="border:1px #000 solid; padding:3px;" width="30%"><strong>Shop Total:</strong></td>
					<td width="70%" style="border:1px #000 solid; padding:3px;"><b>$shoptotal</b></td>
				</tr>
_HTML_T_
if( $emailaddr ne "" ){
$s.= <<_HTML_A_;
				<tr>
					<td style="border:1px #000 solid; padding:3px;" width="30%"><strong>Order Email:</strong></td>
					<td width="70%" style="border:1px #000 solid; padding:3px;"><b><a style="color:red;" href="mailto:$emailaddr" target="_blank">$emailaddr</a></b></td>
				</tr>
_HTML_A_
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

#\s*<tr>\s*<td.*?><strong>(.*?) details:<\/strong><\/td>\s*<td.*?>(.*?)<\/td>\s*<\/tr>    #<tr>\s*<td.*?><strong>\2 details:<\/strong><\/td>\s*<td.*?>(.*?)<\/td>\s*<\/tr>  #$1$2$3<br \/>$5$4/gism;

#my $c = 0;
#my %SS = ();
#while( $s =~ /<tr>\s*<td.*?><strong>(.*?:)<\/strong><\/td>\s*<td.*?>(.*?)<\/td>\s*<\/tr>/gism ){ 
#$SS{$1} = $2;
#$c++;
#}

#foreach my $k(keys %SS){ if( $k =~ /details:/i){ my $t = $k;$t =~ s/\s*details:$/:/i;if( defined $SS{$t} ){ $SS{$t}.= "<br />".$t;
#$s =~s /(<tr>\s*<td.*?><strong>$k<\/strong><\/td>\s*<td.*?>)$SS{$k}(<\/td>\s*<\/tr>)//i;
#$s =~s /(<tr>\s*<td.*?><strong>$t<\/strong><\/td>\s*<td.*?>)(.*?)(<\/td>\s*<\/tr>)/$1$SS{$t}$2/i;
# } } }

#$debug.= "found:".Data::Dumper->Dump([\%SS],["SS"])."\n\n";

$s.= "</table></div><div style=\"width:80%; background:#fff; font-size:80%; line-height:100%; margin:3px auto; clear:both;\">$efoot</div>\n";
$s.= $htmlfoot;
return $s;
}

sub email_html_out{
my ($io) = @_;
print "Content-type: text/html\n\n";
#warningsToBrowser(1);

print $io;

exit;
}

sub email_json_out{
my ($jref,$orig,$call) = @_;
my $type = ref $jref || undef;
if( defined $type ){
eval "use JSON";
if($@){ email_json_print( sub_list_dump($jref,'query') ); } else { email_json_print( "{ \"query\":".JSON->new->allow_nonref->utf8->encode($jref)." }",$orig,$call ); }
} else {
email_json_print($jref,1,$call);
}
}

sub email_json_print{
my ($jtxt,$q,$cback) = @_;
if( defined $cback && $cback ne "" ){
print "Content-type: application/javascript; charset=UTF-8\n\n";
print "$cback( $jtxt )";
} elsif( defined $q ){ 
print "Content-type: application/javascript; charset=UTF-8\n\n";
print "{ \"query\":[ \"$jtxt\" ] }";
} else {
print "Content-type: application/json; charset=UTF-8\n\n";
print $jtxt;
}
exit;
}

sub email_list_dump{
my($data,$title) = @_;
$Data::Dumper::Purity = 1;
$Data::Dumper::Indent = 0;
#$Data::Dumper::Sortkeys = \&sort_dump;
my $d = Data::Dumper->new([$data],[$title],);
return $d->Dump;
}

sub email_process{
my ($n,$v) = @_;
my $ok = undef;
for my $k(keys %checkgroup){
my @ca = @{ $checkgroup{$k} }; #@{ $checkgroup{'DatePurchased'} } = ('/','Day','Month','Year');
for my $i(1..$#ca){ if( $n eq $k.$ca[$i] ){ @{ $checkgroup{$k} }[$i] = $v;$ok = 1; } }
}
return $ok;
}

sub email_respond{
my ($outhead,$outtext) = @_;
my $s = "";
my $w = <<_OUTPUT_;
<span class="email0">$outhead</span><br />
<br />
<ul class="email2"><li>$outtext</li></ul>
_OUTPUT_

if($noscript == "" && $method eq "get"){
if($outhead =~ /^forwarding page to:/){$s = $outhead;} else {$s = $w;}email_html_out($s);

} elsif($outhead =~ /^forwarding page to:/){
print "Location: $locate\n\n";

} else {
if( $invoker =~ /\/$/){$invoker.= $index_file;}
$invoker =~ s/($baseview)/$base/;
open(my $vlist, "<$invoker") or email_html_out($w);
flock ($vlist, 2);
my @vlines = <$vlist>;
$s = join "",@vlines;
close($vlist);

$s =~ s/(<form id="cgi\_form\_$formno".*?<\/form>)/$w/ms;
email_html_out($s);
}

exit;
}

sub email_send_mail{
my ($to,$bcc,$from,$sub,$data,$debug,$ht) = @_;
my $mes = "";
my $dbg = "$to, $bcc, $from, $sub, $data, $ht";
###email_json_out("{ \"check send_mail 1\":\"$dbg = $mes $debug\" }");

eval "use MIME::Entity";
if($@){

$dbg.= "Trying to use MIME::Entity: ".$@."<br />";

} else {

our $ent = MIME::Entity->build( 'Encoding' => "base64",
'Return-Path' => $from,
'To' => $to,
#'Cc' => $bcc,
'From' => $from,
'Subject' => $sub,
'Sender' => $from,
'Data' => $data
);

$mes = "Mime Entity mail ok $dbg";
$ent->smtpsend or $mes = "The mailserver('Mime::Entity') has been unable to send this email: $! $dbg $debug";
$ent->purge;

}

###email_json_out("{ \"check send_mail 2\":\"$dbg = $mes = $debug \" }");
return $mes;
	
#if($ht){
#$ent = MIME::Entity->build( 'Type' => "multipart/alternative",'Return-Path' => $from,'To' => $to,'Bcc' => $bcc,'From' => $from,'Subject' => $sub,'Sender' => $from );
#$ent->attach( 'Data' => $ht,'Type' => "text/html; charset=UTF-8",'Encoding' => "quoted-printable" );
#$ent->attach( 'Data' => $data,'Type'  => "text/plain; charset=UTF-8",'Encoding' => "quoted-printable" );
#} else {
#$ent = MIME::Entity->build( 'Type' => "text/html",'Charset' => "UTF-8",'Encoding' => "quoted-printable",'Return-Path' => $from,'To' => $to,'Bcc' => $bcc,'From' => $from,'Subject' => $sub,'Sender' => $from,'Data' => $data );
#}
#$ent->smtpsend or $mes = "The mailserver('Mime::Entity') has been unable to send this email: $! $dbg";
#$ent->purge;
#}

}