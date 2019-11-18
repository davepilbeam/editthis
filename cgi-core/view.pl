#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5

#editthis version:8.2.2 EDGE

use strict;
#use warnings;
#use cPanelUserConfig;

use CGI qw/:standard/;
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
use Encode qw(encode decode);


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

our $cgiremote = "cgi-bin/view.pl";
our $pageamount = 0;
our $pagesort = 'rank';
our $pagestart = 1;
our $pagefull = 0;
our $cache = 0;
our $remote = 0;

our @servers = @defs::serverip;
for my $i(0..$#servers){ $servers[$i] =~ s/\.([0-9]+)$//; }
our $serverenv = $defs::serverenv;
our $serverip = join "|",@servers;
our $sendtemp = $defs::sendtemp;

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

our $docview = $defs::docview;
our $imagefolder = $defs::imagefolder;
our $imageview = $docview.$imagefolder."/";
our $templatefolder = $defs::templatefolder;
our $templateview = $docview.$templatefolder."/";
our $restorefolder = $defs::restorefolder;
our $resourcefolder = $defs::resourcefolder;
our $restorebase = $restorefolder."/";
our $pdffolder = $defs::pdffolder;
our $cssview = $defs::cssview;
our $uncache = $defs::uncache;

our $body_regx = $defs::body_regx;
our $homeurl = $defs::homeurl;
our $taglister = $defs::taglister;
our $liblister = $defs::liblister;
our $webbase = $defs::webbase;
our %perms = %defs::perms;
our $softversion = $defs::softversion;
our $mail_program = $defs::mail_program;
our $smtp_server = $defs::smtp_server;
our $adminaddr = $defs::adminaddr;
our $fromaddr = $defs::fromaddr;

our $menu_limit = $defs::menu_limit;
our $version_limit = $defs::version_limit;
our $delete_limit = $defs::delete_limit;
our $defupload = $docview."elements/";
our $index_file = $defs::index_file;

our $site_file = $defs::site_file;
our $mobpic = $defs::mobpic;
our %editable = %defs::editable;
our %editareas = %defs::editareas;
our %defsort = %defs::defsort;
our %headers = %defs::headers;
our %defheaders = %defs::defheaders;
our $htmlhead = $defs::htmlhead;
our $htmlfoot = $defs::htmlfoot;

our $resdir = join "|",@defs::RESERVED;
our $listdir = join "|",@defs::LISTDIR;
our $bandir = join "|",@defs::BANDIR;
our $banfile = join "|",@defs::BANFILE;

our %IMS = %defs::EXT_IMGS;
our %FX = %defs::FX;
our $extimg = join "|",values %IMS;
our $extdoc = join "|",values %defs::EXT_FILES;
our $extset = $extimg."|".$extdoc;
our $auxfiles = $defs::auxfiles;

our $fxfile = (join "|",keys %FX)."|".(join "|",values %IMS);

our @UTF = @defs::UTF;
our @UTF1 = @defs::UTF1;
my %LIB = ( "_data" => {} );
our @css_files = @defs::css_files;
our %editareas = %defs::editareas;
our $edittags = join "|", keys %editareas;

our $nwbase = $defs::nwbase;
our $nwurl = $defs::nwurl;
our $ftpbase = $nwbase;$ftpbase =~ s/^.+\/($defs::ftpbase)/$1/;
our $ftppass = $defs::ftppass;
our $imagerelay = (defined $ftppass)?$defs::imagerelay:'localhost';
our $ftpcheck = $defs::ftpcheck;
our $thumb = $defs::thumb;
our $htmlext = $defs::htmlext;
our $delim = $defs::delim;
our $qqdelim = quotemeta($delim);
our $docspace = $defs::docspace;
our $spacer = $defs::spacer;
our $defsep = $defs::defsep;
our $defrestore = $defs::defrestore;
our @titlesep = @defs::titlesep;
our $repdash = $defs::repdash;

local *sub_clean_name = \&subs::sub_clean_name;
local *sub_get_names = \&subs::sub_get_names;
local *sub_get_remote = \&subs::sub_get_remote;
local *sub_get_target = \&subs::sub_get_target;
local *sub_json_out = \&subs::sub_json_out;
local *sub_json_print = \&subs::sub_json_print;
local *sub_page_return = \&subs::sub_page_return;
local *sub_page_out = \&subs::sub_page_out;

our %config = ();
our @enames = ();
our @evalues = ();
our $url = "";
our $callback = "";
our $attri = "";
our $keeplinks = 'on';
our $submenus = 'off';
our $filtervalue = undef;
our $pagewrap = undef;
our $clsdata = undef;
our $pass = undef;
our $js = undef;
our $id = undef;
our $dlevel = 99;
our $fullmenu = undef;
our $filter = undef;
our $pulledlink = undef;
our $format = undef;
our $exclude = undef;
our $sitepage = undef;
our $origin = undef;
our $position = undef;

our $time = time;
our @DATER = (
$time - 604800, # now - 1 week 
$time - 2629743, # now - 1 month
$time - 15778458, # now - 6 months
$time - 31556926, # now - 1 year
$time - 157784630, # now - 5 years
$time - 946707780 # now - 30 years
);
our $debug = "";

$CGI::POST_MAX = $defs::postmax;

sub_json_out({ 'error' => "alert: server configuration problem:\n\n $incerr \n\ncgipath:$cgipath \nenvpath:$envpath \nip:$ENV{'REMOTE_ADDR'}" }) if $incerr ne "";
sub_json_out({ 'error' => "alert: unauthorised user request received by server $serverenv from $ENV{'REMOTE_ADDR'}" }) unless $serverenv =~ /^($serverip)/; # == $serverip / $debug
sub_json_out({ 'error' => "data size [ ".$ENV{'CONTENT_LENGTH'}." ] is greater than the maximum ".$CGI::POST_MAX."k allowed" }) if $ENV{'CONTENT_LENGTH'} && $ENV{'CONTENT_LENGTH'} > $CGI::POST_MAX;

local our $query = CGI->new();
local our %pdata = $query->Vars; my @new_keys = keys %pdata;s/^(opt|pre)_(.*?)_([0-9]+)$/$2/ foreach @new_keys; @pdata{@new_keys} = delete @pdata{keys %pdata};$debug.= Data::Dumper->Dump([\%pdata],["PDATA"])."\n";
local our $postdata = $query->param('POSTDATA'); # $debug.= Data::Dumper->Dump([$postdata],["POSTDATA"])."\n";
local our $qerr = $query->cgi_error;if($qerr){ exit 0;sub_json_out({'error' => "error: problem with received data: $qerr" }); }

foreach my $k( keys %pdata ){
if($k eq "callback"){ $callback = $pdata{$k}; } # Request.JSONP.request_map.request_0
if($k eq "cache"){ $cache = $pdata{$k}; } # 144222753956534
if($k eq "id"){ $id = $pdata{$k}; } # index | list | menu | images | blocks | paginate | all | cgi | filelist
if($k eq "url"){ $url = sub_clean_name($pdata{$k});$url =~ s/($baseview)//g;$sitepage = $url; } # News.html | Site-Map.html | Solutions_Presentation.html | index.html | documents/Digital/ | /admin
if($k eq 'filter'){ $filter = $pdata{$k}; } #editarchive
if($k eq 'pulled'){ $pulledlink = $pdata{$k}; } #1
if($k eq "format"){ $format = $pdata{$k}; } # stacker | swiper | slideshow | lightbox | updatemenu | fullmenu | library | libraryfolders | php
if($k eq "pass"){ $pass = $pdata{$k};$attri = " data-pass=\"$pdata{$k}\"";if( $pdata{$k} =~ /slide:(.*?)(,|$)/ ){ $clsdata = 'tt_'.$1; } } # rows:2,columns:3 | sign-up
if($k eq "amount"){ $pageamount = $pdata{$k}; } # 3
if($k eq "full"){ if($pdata{$k} == 'on'){ $pagefull = 1; } } # on
if($k eq "wrap"){ if($pdata{$k} ne "none"){ $pagewrap = $pdata{$k}; } } # none | list | pull
if($k eq "sort"){ $pagesort = $pdata{$k}; } # rank | 21 | 12 | az | za
if($k eq "start"){ $pagestart = $pdata{$k}; } # 2 | random
if($k eq 'submenu'){ $submenus = $pdata{$k}; } # on | off
if($k eq "link"){ if( $pdata{$k} ne "on"){$keeplinks = undef;} } # on | off
if( $k eq 'position' ){ $position = $pdata{'position'}; }
if($k eq "names"){ @enames = split /,/,$pdata{$k}; } # editarea,editfocus 
if($k eq "values"){ @evalues = split /,/,$pdata{$k};$filtervalue = 'filter-'.(lc $evalues[0]); } # security,z system
if($k eq "exclude"){ $exclude = $pdata{$k}; } # News2_The-State-of-Mainframe-Security-in-the-Application-Economy.html
if($k eq "js"){ $js = $pdata{$k}; } # null returns page / 1 returns json
if($k eq "origin"){ $origin = $pdata{$k}; } # http://othersite.thatsthat.co.uk/
}

sub_json_out({ 'error' => "main 1: \n\nunauthorised user request received by server $serverenv == $serverip" },$origin,$callback) unless $serverenv =~ /^($serverip)/;
###if( defined $origin ){ sub_json_out({ 'debug' => "main 2: \n\n$debug \norigin: $origin" },$origin,$callback); }
sub_json_out({ 'error' => "main 3: \n\nno data received by server: $debug" },$origin,$callback) unless $url ne "";
###sub_json_out({ 'debug' => "main 4:\n\n$debug \nenvpath = $envpath \ncgipath = $cgipath \ncallback: $callback \nid $id \nurl: $url \namount:$pageamount \nstart:$pagestart \nsitepage:$sitepage \nversionbase: $versionbase \nwebbase: $webbase \nbase:$base \norigin: $origin \nremote: $remote" },$origin,$callback);

if( !defined $js ){ if(!defined $id){$id = "list";}$url = $baseview.$url;$url =~ s/^($obase)//;$exclude = $url; }
if( $sitepage =~ /($site_file)$/ || $format eq "fullmenu" ){ $fullmenu = 1; } else { if( $sitepage =~ /($index_file)$/ ){ $sitepage = $site_file; } }
%config = ( 
'adminbase' => $adminbase,
'attri' => $attri,
'auxfiles' => $auxfiles,
'bandir' => $bandir,
'banfile' => $banfile,
'base' => $base,
'baseview' => $baseview,
'body_regx' => $body_regx,
'callback' => $callback,
'cgipath' => $cgipath,
'clsdata' => $clsdata,
'cssview' => $cssview,
'debug' => $debug,
'defheaders' => \%defheaders,
'defrestore' => $defrestore,
'defsep' => $defsep,
'defsort' => \%defsort,
'deftemp' => undef,
'delete_limit' => $delete_limit,
'delim' => $delim,
'dest' => undef,
'dlevel' => $dlevel,
'docspace' => $docspace,
'documents' => undef,
'docview' => $docview,
'editareas' => \%editareas,
'extdoc' => $extdoc,
'extlib' => "",
'filter' => $filter,
'format' => $format,
'ftpbase' => $ftpbase,
'ftpcheck' => $ftpcheck,
'ftppass' => $ftppass,
'fullmenu' => $fullmenu,
'fxfile' => $fxfile, #HTML|TXT|XLSX|PPTX|DOCX|HTM|LISTING|DOC|PDF|PPS|PPT|XLS|PNG|SWF|JPEG|JPG|GIF|ZIP
'headers' => \%headers,
'homeurl' => $homeurl,
'htmlext' => $htmlext,
'http' => $http,
'id' => $id,
'index_file' => $index_file,
'imagefolder' => $imagefolder,
'imagerelay' => $imagerelay,
'imageview' => $imageview,
'js' => $js,
'keeplinks' => $keeplinks,
'listdir' => $listdir,
'liblister' => $liblister,
'mobpic' => $mobpic,
'nwbase' => $nwbase,
'nwurl' => $nwurl,
'obase' => $obase,
'otitle' => $otitle,
'origin' => $origin,
'pages' => undef,
'pagefull' => $pagefull,
'pagesort' => $pagesort,
'pagewrap' => $pagewrap,
'partnerfolder' => "",
'perms' => \%perms,
'pl' => "",
'position' => $position,
'pulledlink' => $pulledlink,
'qqdelim' => $qqdelim,
'repdash' => $repdash,
'resourcefolder' => $resourcefolder,
'restorebase' => $restorebase,
'sharelist' => {},
'site_file' => $site_file,
'sitepage' => $sitepage,
'subdir' => $subdir,
'submenus' => $submenus,
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
my %fs = ();
my @fo = ();
my @us = ();
my $ud = "";

if( defined $origin ){ #is remote

$remote = 1;
my $rurl = $url;$rurl =~ s/^($obase)/$nwbase/; 
$debug.= "get remote nav: $remote\n : $rurl\n";
###sub_json_out({ 'debug' => "check is_remote: \n\nurl:$url == $debug $ENV{'DOCUMENT_ROOT'} rurl:$rurl \nnwbase:$nwbase \nbase:$base \nbaseview:$baseview \nobase:$obase \norigin:$origin" },$origin,$callback); 
if( $rurl =~ /^(.*?:\/\/.*?)\/.+\/$/i ){ $rurl = $1."/".$cgiremote; }
my ($rerr,$rret) = sub_get_remote($rurl,\%pdata);
sub_json_out({'error' => "main 5:\n\n$rerr $rret"},$origin,$callback) if defined $rerr;
%fs = %{ $rret };
### $fs{'debug'} = $debug;
%{ $fo[0] } = %fs;
sub_json_out(\@fo,$origin,$callback);

} else {

if( defined $id && defined $filter && defined $url ){
if( $url !~ /\.($htmlext)$/ ){ 
# documents/Archive/News/ = Get List of Base Folder and Subfolders from Archive (All Years): id="archive" filter="editarchive"  title="link to News Archive"
# documents/Archive/News/ = Get List of Subfolders from Archive (All Years):  id="archive" filter="editarchive" data-exclude="me" title="link to News Archive"
# documents/Archive/News/2017/ = Get Archive Subfolder Folders List (Specified Year and Months): id="archive" filter="editarchive" title="link to 2017 Archive"
# documents/Archive/News/2017/ = Get filtered Archive Subfolder Pages Paginated List (Specified Month): id="index" filter="editarchive" data-amount="9" data-format="stacker" data-values="May" title="link to May 2017 Archive"
# documents/Archive/News/2017/ = Get Filtered Archive Subfolder Menu (Specified Month): id="menu" filter="editarchive" data-values="June"  title="link to June 2017 News"
# documents/Archive/News/2018/June
$url =~ /^(.+\/)(.*?)$/;$ud = $1;$url = $ud."index.$htmlext";push @evalues,$2;@us = split /\//,$ud;if(scalar @us == 3){$id = "archivebase";} #documents/Archive/Group-News/ documents/Archive/Group-News/2015/ documents/Archive/Group-News/2018/June
} else {
# News.html = Get List of Filters from Pages (All Months): id="menu" filter="editarchive" data-amount="0" title="link to Group News"
# documents/Archive/News/2017/index.html = Get Archive Subfolder Pages Paginated List (All Months): id="index" filter="editarchive" data-amount="9" data-format="stacker" data-position="lower" title="link to 2017 Archive"
# documents/Archive/News/2017/index.html = Get full Archive Subfolder Menu (All Months): id="menu" filter="editarchive" title="view 2017 News" 
@us = split /\//,$url;if($id ne "list" && $id ne "filelist" && scalar @us == 5){$id = "archivelist";}
}
}

my $fullurl = sub_get_target($url,$base,$subdir,$nwurl,$nwbase);
###$debug.= "url: $url fullurl: $fullurl \n";
###sub_json_out({'debug' => "check source:\n\nbase:$base \nnwbase:$nwbase \njs: $js \nus: ".( scalar @us )." \nenames:[ @enames ] \nevalues:[ @evalues ] \nurl:$url \nid:$id \nfilter:$filter \nfullurl:$fullurl \n\n".Data::Dumper->Dump([\%config],["config"])."\n\ndebug: $debug " },$origin,$callback);
sub_json_out({'error' => "main 6: \n\nno useable data retrievable by server: $debug."},$origin,$callback) unless $fullurl ne "";

if( $id eq "cgi"){

#view_cgi_out($url,$format,$pass);

} elsif( -d $fullurl || ( $fullurl =~ /\.($htmlext)$/ && -f $fullurl ) ){

my $cf = $fullurl;$cf =~ s/^($obase|$nwbase)//;
my $ty = ($pagestart eq "random")?$pagestart:undef;
my $start = ($pagestart ne "random")?$pagestart:1;
my ($prerr,$prref) = sub_page_return($id,[$fullurl],\%config,\@enames,\@evalues,$start,$pageamount,$exclude,$ty);
if( defined $prerr ){ 
sub_json_out({ 'error' => "main 7: ".$prerr },$origin,$callback); 
} else { 
if( defined $js ){ sub_json_out($prref,$origin,$callback); } else { sub_page_out($fullurl,$prref->{'result'},$format,$filtervalue,$prref->{'type'},\%config); }
}

} else {
sub_json_out({'error' => "main 8: cannot open $fullurl: $! $debug."},$origin,$callback);
}

}

exit;


sub view_cgi_out{
# $response = bless({
# '_msg' => 'OK',
# '_content' => '<!DOCTYPE html> ',
# '_headers' => bless({
# 'content-base' => 'http://garantier.co.uk/garantiersite/public',
# 'set-cookie' => [ 'XSRF-TOKEN=eyJpdiI6IitSUjJlZ5ZGVmOTg1MSJ9; expires=Mon, 10-Apr-2017 17:17:42 GMT; Max-Age=7200; path=/', 'laravel_session=eyJpdiI6ImMifQ%3D%3D; expires=Mon, 10-Apr-2017 17:17:42 GMT; Max-Age=7200; path=/; httponly' ]
# })
#})
my ($u,$fm,$ps) = @_;
my $f = $u;$f =~ s/^($nwbase|$nwurl)//;
my %jout = ();
my $msg = "";
my $response = undef;
###sub_json_out({'debug' => "check cgi_out: f:$nwbase$f \nfm:$fm \npass:$ps \n baseview:$baseview \n nwurl: $nwurl \nbase:$base \n nwbase:$nwbase \n\n$debug."},$origin,$callback);

eval "use LWP::UserAgent";
if($@){
$msg.= "Tried to use LWP::UserAgent: ".$@."<br />";
} else {

my $ua = LWP::UserAgent->new;
if(-e $nwbase.$f){
$ua->timeout(10);
$ua->env_proxy;
#http://intasave.org.cn/mailer.php?to='.uri_encode($to).'&bcc='.uri_encode($bcc).'&from='.uri_encode($from).'&sub='.uri_encode($sub).'&body='.uri_encode($mout)
#http://intasave.org.cn/cgi/email.pl?js=1&pre_message_0=test%203&pre_name_0=test&pre_address_0=&pre_email_0=test%40here.com&pre_spamcheck_0=11&opt_formtype_0=Contact%20Enquiry&opt_recipients_0=&opt_locate_0=&opt_copytype_0=&opt_spamresult_0=11
$response = $ua->get($nwurl.$f);  
if($response->is_success){ $jout{'result'} = $response->content; } else { $msg.= "Encountered an error for $f: ".$response->status_line."\n"; }
} else { 
$msg.= "$nwbase$f is not present..\n";
}

}
###sub_json_out({'debug' => "check cgi_out 1: fm:$fm \npass:$ps \n\n msg:$msg  \n\n".Data::Dumper->Dump([$response],["response"])."\n\n \n\n$debug."},$origin,$callback);
if( $msg ne "" ){ $jout{'error'} = $msg; }
sub_json_out(\%jout,$origin,$callback); 
}