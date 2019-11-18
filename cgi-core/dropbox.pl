#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5

#editthis version:8.2.2 EDGE

use strict;
#use warnings;

use CGI;
use CGI qw / :standard *table /;
use CGI qw/escape unescape/;
use CGI::Carp qw(fatalsToBrowser);
use File::Basename;
use File::Path qw( mkpath rmtree ); #"use File::Path 2.07 qw( make_path remove_tree )";
use File::Spec;
use HTTP::Request::Common;
use MIME::Base64;
use Time::Local;
use Symbol;
use Data::Dumper;

my $envpath = "";
our $cgix = "";
our $incerr = "";

# https://www.dropbox.com/developers/apps/info/ifu1q89jpe3lrzb
# https://metacpan.org/pod/WebService::Dropbox

our $appname = "thatsthat_library";
our $appkey = "ifu1q89jpe3lrzb";
our $appsecret = "13j5yw0v2durnsf";
our $apptoken = "ihUL6HKYp5YAAAAAAAAAvKF7DOy_GTTugQmmX_6PEoUz5Er91Ik1YuKtj3YU7yBW";
our $docfolder = "documents";
our $dropfolder = "Dropbox";
our $thumbfolder = "$docfolder/$dropfolder";
our $thumbext = "_thumb";
our %applinks = (
'Case Studies' => "https://www.dropbox.com/sh/beoewypvo4s6ul4/AAClKphUH1w9N-PTlcUi1Xdja?dl=0",
'Datasheets' => "https://www.dropbox.com/sh/dcvjuniqpd275un/AADSy7OSevI14Z-_yeN7M0Xpa?dl=0"
);
# https://www.dropbox.com/s/26599f2c6bohzqe/RSM-Systems-Engineer.zip?dl=0

our @servers = ( "127.0.0.1","141.0.165.151","86.15.164.221","81.168.114.213","94.197.127.29","46.32.235.70","10.168.1.117" );
our $serverenv = $ENV{'SERVER_ADDR'};

our @refs = ();
if( defined $ENV{'HTTP_HOST'} && $ENV{'HTTP_HOST'} =~  /thatsthat\.co\.uk/ ){ 
@refs = ( "thatsthat.co.uk" );
our $referers = join "|",@refs;
dropbox_json_out({ 'error' => "Unauthorised user request from $ENV{'HTTP_REFERER'} " }) unless $ENV{'HTTP_REFERER'} =~ /($referers)/;
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
our $softversion =$defs::softversion;
our $http = $defs::http;
our $base = $defs::base;
our $baseview = $defs::baseview;
our $cgirelay = $defs::cgirelay;
our $otitle = $defs::otitle;
our $backupbase = $defs::backupbase;
$CGI::POST_MAX = $defs::postmax;

our %config = ( 'delim' => $defs::delim,'docspace' => $defs::docspace,'htmlext' => $defs::htmlext,'repdash' => $defs::repdash );
our %boxinfo = ();

our %RECIPS = %defs::RECEIVERS;
our %COPY = %defs::COPY;
our @UTF = @defs::UTF;
our @UTF1 = @defs::UTF1;
our @emailorder = @defs::emailorder;
our @recipients = ();
our $formtype = $defs::title;
our $mail_program = $defs::mail_program;
our $smtp_server = $defs::smtp_server;
our $authuser = $defs::authuser;
our $authpass = $defs::authpass;
our $authsmtp = $defs::authsmtp;
our $authport = $defs::authport;
our @efields = ();
our $title = $formtype;
our @toaddr = @defs::toaddr;
our @bcc = @defs::bccaddr;
our $fromaddr = $defs::fromaddr;
our $efoot = $defs::efoot;
our $htmlhead = $defs::htmlhead;
our $htmlfoot = $defs::htmlfoot;
our $etitle = $defs::etitle;
our $thank = $defs::thank;
our $spamurl = $defs::spamurl;
our $copyto = "";
our $emailaddr = "";
our $reclist = "";
our $sub = "";
our $eresp = "";
our $out = "";
our $in = "";
our $intro = "";
our $html = 1;
our $spamcheck = -1;
our $spamresult = -1;
our $formname = undef;
our $formemail = undef;
our $spamfail = undef;

our @getitems = ();
our $input = "";
our $callback = "";
our $apppath = undef;
our $save = undef;
our $dropbox = undef;
our $id = undef;
our $showdebug = undef;
our $run = undef;
our $partnername = undef;
our $debug.= "";

dropbox_json_out({ 'error' => "Server configuration problem:\n\n $incerr \n\ncgix:$cgix \nenvpath:$envpath \nip:$ENV{'REMOTE_ADDR'}" }) if $incerr ne "";
dropbox_json_out({ 'error' => "Unauthorised user request from $serverenv" }) unless $serverenv =~ /($serverip)/;

#rsmpartners.com/cgi-bin/dropbox.pl?callback=Request.JSONP.request_map.request_1&appname=thatsthat_library&id=list&debug=1

#opt_formtype_0	Dropbox+Download
#pre_name_0	test
#pre_spamcheck_0	11
#opt_spamresult_0	11
#pre_address-manifest_0	
#pre_email_0	admin@thatsthat.co.uk
#
#pre_id_0 download
#opt_cgiurl_0	2
#pre_library_0	documents/Dropbox/Case-Studies/RSM-Systems-Engineer.zip||documents/Dropbox/Datasheets/test-document.zip
#pre_appname_0	thatsthat_library

our $datetime = dropbox_get_date(time,undef,'zip'); #14:10:39_15--10--2015
our $sendtime = $datetime;$sendtime =~ s/\-\-/-/g; #14:10:39_15-10-2015
our $ziptime = $sendtime;$ziptime =~ s/:/-/g; #14-10-39_15-10-2015
our $senddate = $ziptime;$senddate =~ s/^(.*?)_//;$senddate =~ s/\-/\//g; #03/06/2016
$sendtime =~ s/_/ /g; #14:10:39 15-10-2015

dropbox_json_out({ 'error' => "Data size [ ".$ENV{'CONTENT_LENGTH'}." ] is greater than the maximum ".$CGI::POST_MAX."k allowed " }) if $ENV{'CONTENT_LENGTH'} && $ENV{'CONTENT_LENGTH'} > $CGI::POST_MAX;

our $query = CGI->new();
our %pdata = $query->Vars; my @new_keys = keys %pdata;s/^(opt|pre)_(.*?)_([0-9]+)$/$2/ foreach @new_keys; @pdata{@new_keys} = delete @pdata{keys %pdata}; # $debug.= Data::Dumper->Dump([\%pdata],["PDATA"])."\n";
our $postdata = $query->param('POSTDATA'); # $debug.= Data::Dumper->Dump([$postdata],["POSTDATA"])."\n";
our $qerr = $query->cgi_error;if($qerr){ exit 0;dropbox_json_out({ 'error' => "Problem with received data: $qerr " }); }

foreach my $k( keys %pdata ){
if( $k =~ /manifest/i && $pdata{k} ne "" ){ dropbox_exit(); }
if($k eq "spam"){ dropbox_exit(); }
#
my $j = undef;
if($k eq "callback"){ $callback = $pdata{$k}; }
if($k eq "copytype"){ $copyto = $pdata{$k}; }
if($k eq "email" || $k =~ /^email/i){ $formemail = $pdata{$k};$j = 1; } #admin@thatsthat.co.uk
if($k eq "formtype"){ $formtype = $pdata{$k};$sub = $pdata{$k}." from ".$etitle.": ".$sendtime;$j = 1; } #Dropbox+Download
if($k eq "html"){ $html = undef; }
if($k eq "name"){ $formname = $pdata{$k};$j = 1; } #test
if($k eq "recipients"){ $reclist = $pdata{$k};$j = 1; } #admin@thatsthat.co.uk
if($k eq "spamcheck"){ $spamcheck = $pdata{$k}; } #11
if($k eq "spamresult"){ $spamresult = $pdata{$k}; } #11
#
if($k eq "appname" && $pdata{$k} ne ""){ $apppath = $pdata{$k};$j = 1; } #thatsthat_library
if($k eq "partnername" && $pdata{$k} ne ""){ $partnername = $pdata{$k};$j = 1; } #PE Creative
if($k eq "id" && $pdata{$k} ne ""){ $id = $pdata{$k};$j = 1; } #list | download
if($k eq "library" && $pdata{$k} ne ""){ @getitems = split /\|\|/,$pdata{$k};$j = 1; } #
if($k eq "save"){ $save = $pdata{$k}; } #save
if($k eq "debug"){ $showdebug = $pdata{$k}; } #1
#
if( defined $j ){ my @ar = ($k,$pdata{$k});push @efields,[@ar]; }
}

dropbox_json_out({ 'error' => "the server appears to be unavailable =  id:$id apppath:$apppath = appname:$appname = otitle:$otitle" }) unless defined $id && $apppath eq $appname;
$run = (defined $partnername)?$partnername:(defined $formname && $formname ne "" && defined $formemail && $formemail ne "")?1:undef;

if( defined $run ){

$intro = ( defined $COPY{$formtype} && $COPY{$formtype} ne "" )?$COPY{$formtype}:$COPY{$title};
my $ftt = $efoot;$ftt =~ s/<br \/>/\n/gi;$ftt =~ s/<.*?>//gi;
$out = $intro."\n\n".$ftt;
$debug.= "\n\nreclist = ".$reclist."\n";
if($reclist ne ""){ #recipients = bcc reclist
if($reclist =~ /,/){
my @ls = split(/,/,$reclist);for my $i(0..$#ls){ if( $RECIPS{$ls[$i]} ){ push @bcc,$RECIPS{$ls[$i]}; }$debug.= "RECIPS{$ls[$i]} = ".$RECIPS{$ls[$i]}."\n"; }
} else {
push @bcc,$RECIPS{$reclist};$debug.= "push = ".$RECIPS{$reclist}."\n";
}
}

if($spamresult > -1 ){ if( $spamcheck != $spamresult || $spamcheck !~ /^($spamresult)$/i ){ dropbox_exit(); } }
my $endout = dropbox_clean_xml($intro);
if($copyto ne ""){ # send to $formemail / bcc to @toaddr+@bcc
push @recipients,$formemail;for my $i(0..$#toaddr){ push @bcc,$toaddr[$i]; }
} else {
for my $i(0..$#toaddr){ push @recipients,$toaddr[$i]; } #send to @toaddr / bcc to @bcc
}
###dropbox_json_out({ 'check email' => "$debug = @recipients, @bcc, $fromaddr, $sub, $out, $html" });
if($html){ $html = dropbox_html_me(\@efields); }

my $bc = join ",",@bcc;
for my $i(0..$#recipients){
if($recipients[$i] ne "" && $recipients[$i] =~ /^(.*?)\@(.*?)\.(.*?)$/ ){
if( $i > 0){ $bc = ""; }
$eresp = dropbox_send_mail($recipients[$i],$bc,$fromaddr,$sub,$out.$debug,$html); 
###dropbox_json_out({ 'check mail 2' => "$debug = $recipients[$i], $bc, $fromaddr, $sub, $out, $html " });
}
}
###dropbox_json_out({ 'result' => "email sucessfully sent to @recipients $eresp" });

}

eval "use WebService::Dropbox";
if($@){

dropbox_json_out({ 'error' => "The Dropbox module 'WebService::Dropbox' is currently unavailable on this server.." });

} else {

$dropbox = WebService::Dropbox->new({ 'key' => $appkey,'secret' => $appsecret,'access_token' => $apptoken });
my $info = $dropbox->get_current_account or { 'error' => $dropbox->error };
%boxinfo = %{ $info };
dropbox_json_out({ 'account error' => "".Data::Dumper->Dump([\%boxinfo],["boxinfo"])." \n\n $debug" }) if !defined $boxinfo{'account_id'};

# $boxinfo = {
# 'profile_photo_url' => 'https://dl-web.dropbox.com/account_photo/get/dbaphid%3AAAAOpc0QPTmSLAW5Phmb7jH3NzB6XxE14L8?size=128x128&vers=1457437788935',
# 'country' => 'GB',
# 'disabled' => bless( do{\\(my $o = 0)},'JSON::PP::Boolean' ),
# 'name' => {'abbreviated_name' => 'AT','display_name' => 'admin thatsthat.co.uk','familiar_name' => 'admin','surname' => 'thatsthat.co.uk','given_name' => 'admin'},
# 'locale' => 'en',
# 'email_verified' => bless( do{\\(my $o = 1)},'JSON::PP::Boolean' ),
# 'account_id' => 'dbid:AACmjy0a6IGD7_73BlYB30Z4GSCmqiNxv1s',
# 'referral_link' => 'https://db.tt/jcuK5aX8Xq',
# 'email' => 'admin@thatsthat.co.uk',
# 'is_paired' => $boxinfo->{'disabled'},
# 'root_info' => {'home_namespace_id' => '137370624','.tag' => 'user','root_namespace_id' => '137370624' },
# 'account_type' => {'.tag' => 'basic'}
# }

my %data = ();
if( $id eq "download"){

my $res =  dropbox_zip_out(\@getitems,$base.$backupbase.'Dropbox'.$ziptime.".zip",$save);
###dropbox_jsonp_out("download \n\nres: $res \n\n".Data::Dumper->Dump([\@getitems],["getitems"])." \n\n $debug",'query');
dropbox_jsonp_out("$res",'query');


} else {

my $result = $dropbox->list_folder("",{'recursive' => \1}) || { 'error' => $dropbox->error };
my %list = %{ $result };
# $list = {
#  'cursor' => 'AAHQBkHBK2k7OSqish44bzLT6Wvcu2pEF3PmS0tHMPnF79ArgZnuLP7t7SYpAJaJP6mM-anyUqi1KLxOVOh7la_rH2AOGOFn8MgQCIPcydlmw_XZkxpZOO7Hiq4LrbaE4Hv05Srnf0vHIvM5kHwn-91u',
# 'entries' => [{
# 'content_hash' => '106f36137d62f416d5104a21fce9ce09ca681d42009398646e53f0416078dbd0',
# '.tag' => 'file',
# 'name' => 'Test-Image.gif',
# 'path_display' => '/EPS/Test-Image.gif',
# 'size' => 163840,
# 'server_modified' => '2018-09-21T13:46:25Z',
# 'path_lower' => '/eps/test-image.gif',
# 'rev' => '2ee0fa2b0',
# 'id' => 'id:mzVZOT-nvCkAAAAAAAAIqg',
# 'client_modified' => '2018-09-21T13:46:25Z'
# }]
dropbox_json_out({ 'debug 1' => " ".Data::Dumper->Dump([\%list],["list"])." \n\n $debug" }) if defined $showdebug && $showdebug > 1;
my @entries = @{ $list{'entries'} };
my %thumbs = ();
my @err = ();

for my $i( 0..$#entries){
if( defined $entries[$i]{'path_display'} ){ 
my $ent = $entries[$i]{'path_display'};
my $ioerr = undef;

if( $ent =~ /($thumbext\.)(jpg|png|gif)$/i ){ 
my $ext = $1.$2; 
my @entpath = split /\//,$ent;$entpath[0] = $thumbfolder; # "documents/Dropbox","Case-Studies","Img_thumb.jpg"
if( !-f $base.$thumbfolder.$ent ){
my $pp = "";for my $j(0..$#entpath){ $pp.= $entpath[$j]."/";if( $j != $#entpath && !-d $base.$pp ){ my $cerr = dropbox_folder_create($base.$pp); push @err,"error creating $base$pp for $ent: ".$cerr if defined $cerr; } }
my $fh = IO::File->new($base.$thumbfolder.$ent, '>');
$dropbox->download($ent,$fh) or $ioerr = $dropbox->error; #$dropbox->get_thumbnail($ent,$fh) or $ioerr = $dropbox->error;
push @err,"thumbnail error: $ent ".$ioerr if defined $ioerr;
}
$ent =~ s/($ext)$//i;$thumbs{$ent} = $entries[$i]{'path_display'};
}

}
}

dropbox_json_out({ 'check dropbox 1' => " ".( join "",@err )." \n\n $debug" }) if scalar @err > 0;
%data = dropbox_library_format(\@entries,\%thumbs);
dropbox_jsonp_out(\%data,'query');
}


}

dropbox_json_out({ 'check dropbox 2' => "id:$id \n\n".Data::Dumper->Dump([\%boxinfo],["boxinfo"])." \n\n $debug" });

exit;

###

sub dropbox_clean_xml{
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

sub dropbox_get_file{
my ($dest) = @_;
my @lines = ();
my $rt = undef;
my $err = "";

if(-f $dest){
open(my $rlist1,"<$dest") or $err = "error: unable to read from $dest: $!";
if($err eq ""){
flock ($rlist1,2);
@lines = ();while(<$rlist1>){ my $tmp = $_;if( defined $tmp && $tmp =~ /[0-9a-z]+/i){push @lines,$tmp;} }
close($rlist1);
$rt = dropbox_json_convert( join "",@lines );
}
} else {
$err = "error: unable to open from $dest: $!";
}

return ($err,$rt);
}

sub dropbox_iso_from_epoch{
my ($ep) = @_; 
my $t = "";
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($ep);
$year += 1900;
$mon += 1;
return $year."-".( dropbox_numberpad($mon) )."-".( dropbox_numberpad($mday) )."T".( dropbox_numberpad($hour) ).":".( dropbox_numberpad($min) ).":".( dropbox_numberpad($sec) ).".000Z"; # 2004-08-04T19:09:02.768Z
}

sub dropbox_iso_to_epoch{
my ($iso) = @_; #2004-08-04T19:09:02.768Z
my ($edate,$etime) = split /T/ => $iso;
my ($year,$mon,$mday) = split /-/ => $edate;
$year -= 1900;
$mon--;
my ($hour,$min,$sec) = split /:/ => $etime;
$sec =~ s/Z//;
return timegm($sec,$min,$hour,$mday,$mon,$year);
}

sub dropbox_json_convert{
my ($sref) = @_;
eval "use JSON";
if($@){
return dropbox_list_dump($sref,'query');
} else {
return JSON->new->utf8->allow_nonref->decode($sref);
}
}

sub dropbox_exit{
my ($txt) = @_;
my $otxt = (defined $txt)?$txt:"Your details have been received and you will receive our response shortly.";
dropbox_json_out({ 'result' => $otxt });
}

sub dropbox_html_me{
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

my %fields = ();
for my $i(0..$#DATA){
if( $DATA[$i][1] ne "" ){
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


sub dropbox_html_out{
my ($io) = @_;
print "Content-type: text/html\n\n";
print $io;
exit;
}

sub dropbox_json_out{
my ($sref) = @_;
my @u = ();
eval "use JSON";
if($@){
return dropbox_list_dump($sref,'query');
} else {
push @u,JSON->new->allow_nonref->encode($sref);
}
dropbox_json_print( "$callback( { \"query\":[ ".( join ",",@u )." ] } )" );
}

sub dropbox_jsonp_out{
my ($text,$q) = @_;
my $qe = $q || "error";
print "Content-type: application/json\n\n";
print "$callback( { \"$qe\":{ \"data\":[ ".JSON->new->allow_nonref->encode($text)." ] } } );";
exit;
}

sub dropbox_json_print{
my ($arr,$text) = @_;
print "Content-type: application/json\n\n";
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

sub dropbox_library_format{
# { "Datasheets": { "Mainframe-Services": {

# "Managed-Services.pdf": {
# "author": [ "Andrew Downie" ],
# "menuname": [ "Managed-Services.pdf" ],
# "size": [ "443k" ],
# "href": [ "https://rsmpartners.com/documents/Digital/Datasheets/Mainframe-Services/Managed-Services.pdf" ],
# "url": [ "documents/Digital/Datasheets/Mainframe-Services/Managed-Services.pdf" ],
# "parent": [ "documents/Digital/Datasheets/Mainframe-Services" ],
# "epoch": [ 1479081600 ],
# "path": [ "documents","Digital","Datasheets","Mainframe-Services","Managed-Services.pdf" ],
# "image": [ "documents/Digital/Datasheets/Mainframe-Services/Managed-Services_thumb.jpg" ],
# "published": [ "14/11/2016" ],
# "title": [ "Mainframe Optimisation: Capacity Cost Reduction" ]
# },
# "Managed-Services_thumb.jpg": {
# "parent": [ "documents/Digital/Datasheets/Mainframe-Services" ],
# "epoch": [ 1509027879 ],
# "imagedata": [ "base64" ],
# "path": [ "documents","Digital","Datasheets","Mainframe-Services","Managed-Services_thumb.jpg" ],
# "menuname": [ "Managed-Services_thumb.jpg" ],
# "size": [ "6k" ],
# "published": [ "26/10/2017" ],
# "href": [ "https://rsmpartners.com/documents/Digital/Datasheets/Mainframe-Services/Managed-Services_thumb.jpg" ],
# "url": [ "documents/Digital/Datasheets/Mainframe-Services/Managed-Services_thumb.jpg" ],
# "title": [ "thumb.jpg" ]

# } } }
my ($ls,$tref) = @_;
my @entries = sort { $a->{'path_lower'} cmp $b->{'path_lower'} } @{$ls};
my %thumbs = %{$tref};
my %data = ();
my %items = ();
my %folders = ();

for my $i( 0..$#entries){
my %doc = %{ $entries[$i] };
if( defined $doc{'name'} && defined $doc{'path_display'} ){ # '/EPS/Test-Image.gif',

#my @path = split "/",$doc{'path_display'};
my @tmp = split "/",$doc{'path_display'};
my @path = ($docfolder,$dropfolder);for my $j(0..$#tmp){ if( $tmp[$j] ne "" ){ push @path,$tmp[$j]; } }

my @parent = @path;pop @parent;
#my @url = @path;shift @url;
my $epoch = (defined $doc{'client_modified'})?dropbox_iso_to_epoch($doc{'client_modified'}):(defined $doc{'server_modified'})?dropbox_iso_to_epoch($doc{'server_modified'}):time;

my $type = (defined $doc{'.tag'} && $doc{'.tag'} eq 'file')?'file':'folder';

if( $type eq "file"){
$items{ $doc{'name'} } = {
'name' => [ $doc{'name'} ],
'menuname' => [ $doc{'name'} ],
'path' => \@path,
'parent' => [ join "/",@parent ],
'published' => [ dropbox_get_date($epoch) ],
'epoch' => [ $epoch ],
'size' => [ dropbox_get_size($doc{'size'}) ],
'href' => [ (join "/",@path) ],
#'id' => [ $doc{'id'} ],
'title' => [ dropbox_title_out($doc{'name'},\%config) ],
'url' => [ $doc{'path_display'} ]
};

#if( $items{ $doc{'name'} }{'path'}->[0] eq "" ){ $items{ $doc{'name'} }{'path'}->[0] = $thumbfolder; }
#if( $doc{'name'} =~ /\.(jpg|png|gif)$/i ){ 
#if( $doc{'name'} =~ /($thumbext)/i ){ $items{ $doc{'name'} }{'path'}->[0] = $thumbfolder; }
#if( defined $doc{'image_data'} ){ @{ $items{ $doc{'name'} }{'imagedata'} } = ( encode_base64($doc{'image_data'}) ); }
#} else {
my $ipath = $doc{'path_display'};$ipath =~ s/\.(.*?)$//i;foreach my $ki(keys %thumbs){ if( $ipath =~ /^($ki)/ ){ @{ $items{ $doc{'name'} }{'image'} } = ( $thumbfolder.$thumbs{$ki} ); } } 
#}
my $href = \%data;for my $j(2..$#path){ if( $#path == $j ){ $href->{ $doc{'name'} } = $items{ $doc{'name'} }; } else { if( !defined $href->{ $path[$j] } ){ $href->{$path[$j]} = { 'is_group' => $path[$j] }; }$href = $href->{ $path[$j] }; } } }

}
}

#dropbox_json_out({ 'check library_format' => " ".Data::Dumper->Dump([\%items],["items"])." \n\n".Data::Dumper->Dump([\%thumbs],["thumbs"])." \n\n $debug" });
#dropbox_json_out({ 'check library_format' => " ".Data::Dumper->Dump([\%data],["data"])." \n\n $debug" });
return %data;
}

sub dropbox_list_dump{
my($data,$title) = @_;
$Data::Dumper::Purity = 1;
$Data::Dumper::Indent = 0;
#$Data::Dumper::Sortkeys = \&sort_dump;
my $d = Data::Dumper->new([$data],[$title],);
return $d->Dump;
}

sub dropbox_folder_create{
my ($nf) = @_;
my $err = undef;
mkpath("$nf",{mode => 0775,result => \my $list,error => \my $ierr});if(@$ierr){ $err = "";for my $diag (@$ierr){my ($fi,$ms) = %$diag;if($fi eq ''){ $err.= "general error: $ms\n"; } else { $err.= "error creating [ $fi ]: $ms\n"; }} }
if( defined $err ){
return "error: create folder $nf failed: $err \n";
} else {
chmod (0775,$nf) or try { die "folder_create: chmod $nf failed: $! "; } catch { return "folder_create: chmod $nf failed: $_ \n"; };
}
return undef;
}

sub dropbox_numberpad{ my ($n) = @_;if( $n < 10 && $n !~ /^0/ ){ $n = '0'.$n; }return $n; }

sub dropbox_get_date{ my ($ep,$sep,$vers) = @_;if(!defined $ep){$ep = time;}my ($s,$min,$h,$md,$m,$y,$wd,$yd,$is) = gmtime($ep);$m++;$md = ($md < 10)?"0".$md:$md;$m = ($m < 10)?"0".$m:$m;$y = 1900+$y;if( defined $vers ){ if(defined $sep){if($vers =~ /version/){$sep = "-";}return $h.":".$min.":".$s." ".$md.$sep.$m.$sep.$y;} else {return sprintf("%02d:%02d:%02d_%02d--%02d--%04d",$h,$min,$s,$md,$m,$y);} } else { my $gap = (defined $sep)?$sep:"/";return $md.$gap.$m.$gap.$y; } }

sub dropbox_get_size{ my ($i) = @_;my $ftps = -s $i;$ftps = $ftps/1000;my $s = int( $ftps + .5 * ($ftps <=> 0) );if($s < 1){$s = 1;}return $s."k"; }

sub dropbox_send_mail{
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
dropbox_json_out({ 'error' => "$mes <br />Trying to use SendMail: $!" });

} else {
my $ua = undef;
my $response = undef;
eval "use Net::SSL";
if($@){
$ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0}, );
} else {
$ua = LWP::UserAgent->new;
}
if(-e $base."mailer.php"){
$ua->agent("thatsthat/$softversion");
$ua->timeout(10);
$ua->env_proxy;
$mout = "\nUser Name (if available) - $ENV{'REMOTE_USER'}\nAddress - $ENV{'REMOTE_ADDR'}\nBrowser - $ENV{'HTTP_USER_AGENT'}\n$sendtime\n\n".$out;
$response = $ua->get($baseview.'/mailer.php?to='.$to.'&bcc='.$bcc.'&from='.$from.'&sub='.$sub.'&body='.$mout); ###my $response = $ua->get('http://intasave.org.cn/mailer.php?to='.uri_encode($to).'&bcc='.uri_encode($bcc).'&from='.uri_encode($from).'&sub='.uri_encode($sub).'&body='.uri_encode($mout));
if($response->is_success){ $mes.= "PHP thinks the email was sent correctly..<br />"; } else { email_json_out({ 'error' => "Encountered an error sending your message: ".$response->status_line }); }
} else { 
$mes.= "<br />".$baseview."Mailer.php file is not present..<br />Trying email relay:<br />";
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
open my $mailopen, "| $mail_program" or email_json_out({ 'error' => "$mes<br />The mailserver('Email::Simple) has been unable to send this email: $! " });
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
#$ent->smtpsend or dropbox_json_out({ 'error' => "The mailserver('Mime::Entity') has been unable to send this email: $! $dbg" });
#or
#
open MAIL, "| $mail_program" or email_json_out({ 'error' => "The mailserver('Mime::Entity') has been unable to send this email: $! $dbg " });$ent->print(\*MAIL);close MAIL;
$ent->purge;
}

return $mes;
}

sub dropbox_title_out{
my ($h,$cref) = @_;
my $n = $h;
my %c = %{$cref};
$n =~ s/^(.+\/)//i;
$n =~ s/^(.+$c{'delim'})//i;
$n =~ s/\.($c{'htmlext'})$//;
$n =~ s/($c{'docspace'})($c{'docspace'})/====/g;
$n =~ s/($c{'docspace'})/ /g;
$n =~ s/====/$c{'docspace'}/g;
$n =~ s/($c{'repdash'})($c{'repdash'})/\+\+/g;
$n =~ s/$c{'repdash'}/\//g;
$n =~ s/\+\+/$c{'repdash'}/g;
$n =~ s/#/?/g;
$n =~ s/;/:/g;
$n =~ s/\^/'/g; #'
$n =~ s/\&/&#38;/g;
return $n;
}

sub dropbox_zip_file{
my ($u,$zip) = @_;
my $nz = $u;$nz =~ s/^.+\///;
my $msg ="";
$zip->addFile($u,$nz);$msg.= "[file > file] add $nz \n";
return $msg;
}

sub dropbox_zip_dir{
my ($u,$zip) = @_;
my $msg ="";
my $nz = $u;$nz =~ s/^($base)//;$nz =~ s/^\///;
$zip->addDirectory($u,$nz);$msg.= "[dir > dir] add $nz \n";
return $msg;
}

sub dropbox_zip_tree{
my ($u,$zip) = @_;
my $msg ="";
my $nz = $u;$nz =~ s/^(.+)\///;
$zip->addTree($u,$nz);$msg.= "[dir > tree] add $nz \n";
return $msg;
}

sub dropbox_zip_out{
# fref: [ documents/Dropbox/Case-Studies/RSM-Systems-Engineer.zip documents/Dropbox/Datasheets/test-document.zip ]
# nwzip:  '/var/www/vhosts/pecreative.co.uk/rsmpartners.com/admin/BACKUP/documents16-01-17.zip'
my ($fref,$nwzip,$save) = @_;
my @getitems= (defined $fref)?@{ $fref }:();
my $utitle = $nwzip;$utitle =~ s/^($base)//;
my $ztitle = $utitle;$ztitle =~ s/^($backupbase)//;
my $dropbase = $backupbase."Dropbox";
my $msg = "";
my $adj = undef;
my $dbug = "";
###dropbox_json_out({ 'check zip_out' => "ngetitems: @getitems \nnwzip: $nwzip \n save: $save \n\n$debug'" });

eval "use Archive::Zip qw( :ERROR_CODES :CONSTANTS )";
if( $@ ){
$msg = "Unfortunately this server can't use Archive::Zip: $@ ";
} else {

eval "use File::Temp qw(:seekable tempfile tempdir)";
if( $@ ){
$msg = "Unfortunately this server can't use File::Temp: $@ ";
} else {

for my $i(0..$#getitems){ 
$getitems[$i] =~ s/^($thumbfolder)//; # /Case-Studies/test_1.pdf
my @entpath = split /\//,$getitems[$i];$entpath[0] = $dropbase; # "Dropbox","Case-Studies","test_1.pdf"
my $err = undef;
if( !-f $base.$dropbase.$getitems[$i] ){
my $pp = "";for my $j(0..$#entpath){ $pp.= $entpath[$j]."/";if( $j != $#entpath && !-d $base.$pp ){ my $cerr = dropbox_folder_create($base.$pp); $err = "error creating $base$pp for $getitems[$i]: ".$cerr if defined $cerr; } }
if( !defined $err ){
my $fh = IO::File->new($base.$dropbase.$getitems[$i], '>');
my $ioerr = undef;
$dropbox->download($getitems[$i],$fh) or $ioerr = $dropbox->error; #$dropbox->get_thumbnail($getitems[$i],$fh) or $ioerr = $dropbox->error;
$err = "thumbnail error: $getitems[$i] ".$ioerr if defined $ioerr;
}
$msg.= $err if defined $err;
}
}

if( -d $base.$dropbase ){

my $zip = Archive::Zip->new();
$dbug.= dropbox_zip_tree($base.$dropbase,$zip);
###dropbox_json_out({ 'check zip_out 1' => "dbug:\n$dbug\n\n getitems:[ @getitems ] \nnwzip:$nwzip \nsave:$save \n\n \n\n$debug'" });
my $status = $zip->writeToFileNamed($nwzip);
if( $status == "AZ_OK" ){
###dropbox_json_out({ 'check zip_out 2' => "getitems $i::$getitems[$i] \n\nnwzip: $nwzip \n save: $save \n\n dbg = $dbug \n\n$debug" });
my $size = -s "$nwzip";
my $stxt = dropbox_get_size($nwzip);
if( $size > $CGI::POST_MAX ){ $CGI::POST_MAX = $size+1000;$adj = 1; }
###dropbox_json_out({ 'check zip_out 3' => "adj: $adj\nutitle: $utitle \nztitle: $ztitle \nnwzip: $nwzip \n size: $size <>  ${CGI::POST_MAX} \nstxt: $stxt \nsave: $save \n\n dbg = $dbug \n\nf: \n@f \n\n$debug" });
if( defined $save ){
$msg = "<a href=\"$utitle\" title=\"link to download zip\">Download $ztitle Zip ( $stxt )</a>";
} else {
print "Content-Type:application/x-download\n";
print "Content-Disposition: attachment; filename=\"$ztitle\"\n\n";

my $hfile = gensym; #my $hfile = undef;
my $oerr = undef;
open($hfile,"< ",$nwzip) or $oerr = "Zip error: can't open $nwzip: $!";
if( defined $oerr ){
$msg.= $oerr."\n";
} else {
binmode $hfile;
local $/ = \10240;
while (<$hfile>){print $_;}
close $hfile;
unlink $nwzip or $msg.= "Download error: delete file [ $nwzip ] failed: $!";
}

rmtree($base.$dropbase,{ error => \my $ierr });if( @$ierr ){ for my $diag (@$ierr){my ($fi,$ms) = %$diag;if ($fi eq ''){ $msg.= "Zip cleanup: general error: $ms\n"; } else { $msg.= "Zip cleanup: problem deleting folder [ $fi ]: $ms\n"; }} }
}
if( defined $adj ){ $CGI::POST_MAX = $defs::postmax; }
} else {
$msg.= "Download Zip: the server cannot write zip [ $nwzip ]: $! = $dbug";
}

} else {
$msg.= "Download error: unable to retrieve ".$base.$dropbase.": $!";
}

}
}
return $msg;
}