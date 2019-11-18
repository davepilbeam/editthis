#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5

#editthis version:8.2.2 EDGE

use strict;
#use warnings;

use Cwd;
use CGI qw/:standard/;
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
use Encode qw(encode decode);
use File::Copy qw(cp mv);
use File::Find;
use File::Spec;
use File::stat;
use HTML::Entities;
use Symbol;
use Time::Local;
use URI::Encode;

my $envpath = File::Spec->rel2abs( __FILE__ );
$envpath =~ s/(admin\/)(.*?)$//;
our $cgix = $1.$2;
our $incerr = "";
for my $incfile("$envpath/defs.pm","$envpath/subs.pm"){
my $increturn = undef;
unless ($increturn = do $incfile){
$incerr.= "couldn't parse $incfile: $@\n" if $@;
$incerr.= "couldn't do $incfile: $!\n" unless defined $increturn;
$incerr.= "couldn't run $incfile\n" unless $increturn;
}
}

my $uri = URI::Encode->new( { encode_reserved => 1 } );

our $time = time;
our ($lsec,$lmin,$lhour,$lmday,$lmon,$lyear,$lwday,$lyday,$lisdst) = gmtime($time);
our $updated = "&#169; thatsthat ".(1900+$lyear);
our $adminuser = $ENV{'REMOTE_USER'}; #rsmadmin rsmeditor

our $sitemapclass = "navtext sitemap";
our $addcss = "<link rel=\"stylesheet\" type=\"text/css\" media=\"screen\" href=\"admin/editthis.css\" />";
our $addxml = "<!DOCTYPE html>\n<html lang=\"en\">\n";
our $jsminline = "//#editthis version";

our $pagesort = 'rank';
our $emptymsg = 'This folder is currently empty.';
our $remlister = "view.pl";
our $site_file = $defs::site_file;

our @required = @defs::required;
our $body_regx = $defs::body_regx;
our $homeurl = $defs::homeurl;
our $taglister = $defs::taglister;
our $liblister = $defs::liblister;
our $webbase = $defs::webbase;$webbase =~ s/\/$//;
our %perms = %defs::perms;
our %defsort = %defs::defsort;
our %headers = %defs::headers;
our %defheaders = %defs::defheaders;
our %defsections = %defs::defsections;
our %imgsizes = %defs::imgsizes;
our %sharelist = %defs::sharelist;
our $mobpic = $defs::mobpic;
our %editusers = %defs::editusers;
our %editareas = %defs::editareas;
our $edittags = join "|", keys %editareas;
our $uncache = $defs::uncache;

our @servers = @defs::serverip;
our $serverenv = $defs::serverenv;
our $serverip = join "|",@servers;
our $sendtemp = $defs::sendtemp;
our $libdeftxt = $defs::libdeftxt;
our $softversion = $defs::softversion;
our $mail_program = $defs::mail_program;
our $smtp_server = $defs::smtp_server;
our $adminaddr = $defs::adminaddr;
our $fromaddr = $defs::fromaddr;

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
our $partnerview = $defs::partnerview || "partners";
our $imagefolder = $defs::imagefolder;
our $imageview = $docview.$imagefolder."/";
our $templatefolder = $defs::templatefolder;
our $templateview = $docview.$templatefolder."/";
our $restorefolder = $defs::restorefolder;
our $restorebase = $restorefolder."/";
our $resourcefolder = $defs::resourcefolder;
our $partnerfolder = $defs::partnerfolder;
our $partnerbase = $partnerfolder."/";
our $trashbase = $defs::trashfolder."/";
our $pdffolder = $defs::pdffolder;
our $cssview = $defs::cssview;

our %LIB = ( "_data" => {} );
our @structure =  ( $base.'FONTS',$base.'hticons',$base.'VERSIONS' );
our @libtags = (defined $defs::libtags)?split /\s/,$defs::libtags." ".$defs::droptags:();
our $host = $http."//".$ENV{'HTTP_HOST'}."/";
our $pl = $host.$cgipath.$cgix."?";
our $configjs = "<script type=\"application\/javascript\" src=\"".$subdir."config.js\" charset=\"utf-8\"></script>\n";
our $addjs = "<script type=\"application\/javascript\" src=\"".$subdir."admin/minsu.js\" charset=\"utf-8\"></script>\n<script type=\"application/javascript\" src=\"".$subdir."admin/su.js\" charset=\"utf-8\"></script>\n<script type=\"application/javascript\" src=\"".$subdir."admin/contenteditable.js\" charset=\"utf-8\"></script>\n";
our $type = 'login';
our $deftemp = 'Default-Page-Template.html';
our @seclist = ($docview.'Archive/',$templateview,$partnerview);

our $menu_limit = $defs::menu_limit;
our $version_limit = $defs::version_limit;
our $delete_limit = $defs::delete_limit;
our $defupload = $docview."elements/";
our $index_file = $defs::index_file;

our $nwbase = $defs::nwbase;
our $nwurl = $defs::nwurl;
our $ftpbase = $nwbase;$ftpbase =~ s/^.+\/($defs::ftpbase)/$1/;
our $ftppass = $defs::ftppass;
our $imagerelay = (defined $ftppass)?$defs::imagerelay:'localhost';
our $ftpcheck = $defs::ftpcheck;
our $para_limit = $defs::paragraph_limit;

our $htmlext = $defs::htmlext;
our $docspace = $defs::docspace;
our $thumb = $defs::thumb;
our $spacer = $defs::spacer;
our $defsep = $defs::defsep;
our $defrestore = $defs::defrestore;
our @titlesep = @defs::titlesep;
our $repdash = $defs::repdash;
our $delim = $defs::delim;
our $qqdelim = quotemeta($delim);
our $htmlhead = $defs::htmlhead;
our $htmlfoot = $defs::htmlfoot;

our %IMS = %defs::EXT_IMGS;
our %FX = %defs::FX;
our $extimg = join "|",values %IMS;
our $extdoc = join "|",values %defs::EXT_FILES;
our $extset = $extimg."|".$extdoc;
our $extlib = $extimg."|".( join "|",values %defs::EXT_LIB );
our $auxfiles = $defs::auxfiles;

our $fxfile = (join "|",keys %FX)."|".(join "|",values %IMS);
our $resdir = join "|",@defs::RESERVED;
our $listdir = join "|",@defs::LISTDIR;
our $bandir = join "|",@defs::BANDIR;
our $banfile = join "|",@defs::BANFILE;
our %inputinfo = %defs::inputinfo;
our @UTF = @defs::UTF;
our @UTF1 = @defs::UTF1;
our %RECEIVERS = %defs::RECEIVERS;
our %SUBJECTS = %defs::COPY;
our %DEFMODS = %defs::defmods;
our $sitemap = (defined $defs::dositemap)?$base.$cgipath."admin/":undef;

our $userdisplay = ' &#160;|&#160; <span><a href="'.$baseview.$cgipath.'admin/testserver.pl" title="view this server\'s settings" target="_blank">Server Info</a></span> &#160;|&#160; '.( ($adminuser =~ /admin$/)?'<b><a href="'.$pl.'type=listmenupages" title="refresh or debug Site Menus">Menu Tools</a></b> &#160; <b><a href="'.$pl.'type=viewconfigpages" title="Site Tools">Site Tools</a></b> &#160; <b><a href="'.$pl.'type=deploysite" title="convert and save as new Site">Export Site</a></b> &#160; <b><a href="'.$pl.'type=distribute" title="push updated elements to all sites">Distribute Site</a></b> &#160; <b><a href="'.$pl.'type=uploadsite" title="upload an exported Site">Import Site</a></b> &#160;|&#160; <span><a href="'.$baseview.'admin/modules.html" title="Modules guide">Modules</a></span> &#160;':'' ).' <span>[ Logged in as: <i>'.$adminuser.'</i> ]</span>';

local *sub_admin_backlevel = \&subs::sub_admin_backlevel;
local *sub_admin_chooser = \&subs::sub_admin_chooser;
local *sub_admin_copy = \&subs::sub_admin_copy;
local *sub_admin_delete = \&subs::sub_admin_delete;
local *sub_admin_dropsub = \&subs::sub_admin_dropsub;
local *sub_admin_fixerror = \&subs::sub_admin_fixerror;
local *sub_admin_getmenu = \&subs::sub_admin_getmenu;
local *sub_admin_new = \&subs::sub_admin_new;
local *sub_admin_save_page = \&subs::sub_admin_save_page;
local *sub_admin_save_write = \&subs::sub_admin_save_write;
local *sub_admin_rankpages = \&subs::sub_admin_rankpages;
local *sub_admin_rename = \&subs::sub_admin_rename;
local *sub_check_name = \&subs::sub_check_name;
local *sub_clean_name = \&subs::sub_clean_name;
local *sub_files_return = \&subs::sub_files_return;
local *sub_folder_create = \&subs::sub_folder_create;
local *sub_folder_copy = \&subs::sub_folder_copy;
local *sub_folder_empty = \&subs::sub_folder_empty;
local *sub_get_aliases = \&subs::sub_get_aliases;
local *sub_get_all = \&subs::sub_get_all;
local *sub_get_changed = \&subs::sub_get_changed;
local *sub_get_contents = \&subs::sub_get_contents;
local *sub_get_date = \&subs::sub_get_date;
local *sub_get_files = \&subs::sub_get_files;
local *sub_get_html = \&subs::sub_get_html;
local *sub_get_parent = \&subs::sub_get_parent;
local *sub_get_restored = \&subs::sub_get_restored;
local *sub_get_subnumber = \&subs::sub_get_subnumber;
local *sub_get_subpages = \&subs::sub_get_subpages;
local *sub_get_target = \&subs::sub_get_target;
local *sub_get_unversion = \&subs::sub_get_unversion;
local *sub_get_usedpages = \&subs::sub_get_usedpages;
local *sub_ftp_out = \&subs::sub_ftp_out;
local *sub_image_used = \&subs::sub_image_used;
local *sub_libraryfile_update = \&subs::sub_libraryfile_update;
local *sub_new_upload = \&subs::sub_new_upload;
local *sub_numberpad = \&subs::sub_numberpad;
local *sub_merge_hash = \&subs::sub_merge_hash;
local *sub_page_findreplace = \&subs::sub_page_findreplace;
local *sub_page_print = \&subs::sub_page_print;
local *sub_page_return = \&subs::sub_page_return;
local *sub_page_rewrite = \&subs::sub_page_rewrite;
local *sub_page_update = \&subs::sub_page_update;
local *sub_parse_tags = \&subs::sub_parse_tags;
local *sub_search_aux = \&subs::sub_search_aux;
local *sub_search_file = \&subs::sub_search_file;
local *sub_title_out = \&subs::sub_title_out;
local *sub_title_undate = \&subs::sub_title_undate;
local *sub_zip_out = \&subs::sub_zip_out;

our %outstr = ();
our %config = ();
our %gsections = ();
our $debug = "";
our $callback = "";
our $attri = "";
our $old = "";
our $new = "";
our $find = "";
our $replace = "";
our $js = 1;
our $id = 0;
our $dlevel = 0;
our @alerts = undef;
our $clsdata = undef;
our $filter = undef;
our $format = undef;
our $fullmenu = undef;
our $sitepage = undef;
our $pagewrap = undef;
our $origin = undef;
our $url = undef;
our $fullurl = undef;
our $prev = undef;
our $dest = undef;
our $pages = undef;
our $position = undef;
our $hidealert = undef;
our $documents = undef;
our $images = undef;
our $regexp = undef;
our $code = undef;
our $usecase = undef;
our $pilbeam = undef;

$CGI::POST_MAX = $defs::postmax; #10240000

admin_json_out({ 'error' => "alert: server configuration problem:\n\n $incerr \n\ncgix:$cgix \ncgipath:$cgipath \nenvpath:$envpath \nip:$ENV{'REMOTE_ADDR'}" }) if $incerr ne "";
admin_json_out({ 'error' => "alert: unauthorised user request received by server $serverenv from $ENV{'REMOTE_ADDR'}" }) unless $serverenv =~ /^($serverip)/; # == $serverip / $debug
admin_json_out({ 'error' => "data size [ ".$ENV{'CONTENT_LENGTH'}." ] is greater than the maximum ".$CGI::POST_MAX."k allowed" }) if $ENV{'CONTENT_LENGTH'} && $ENV{'CONTENT_LENGTH'} > $CGI::POST_MAX;

local our $query = CGI->new();
local our %pdata = $query->Vars; my @new_keys = keys %pdata;s/^(opt|pre)_(.*?)_([0-9]+)$/$2/ foreach @new_keys;@pdata{@new_keys} = delete @pdata{keys %pdata};$debug.= Data::Dumper->Dump([\%pdata],["PDATA"])."\n\n adminuser:".$adminuser."\n\n";
local our $postdata = $query->param('POSTDATA'); ### $debug.= Data::Dumper->Dump([$postdata],["POSTDATA"])."\n";
local our $qerr = $query->cgi_error;if($qerr){ exit 0;admin_json_out({ 'error' => "(error: problem with received data: $qerr)" },$origin,$callback); }

foreach my $k( keys %pdata ){
if( $k eq 'callback' ){ $callback = $pdata{'callback'}; } #Request.JSONP.request_map.request_0
if( $k eq 'case' ){ $usecase = $pdata{'case'};$outstr{'usecase'} = $usecase; } # | grid
if( $k eq 'destination' ){ $dest = Encode::decode('utf8',$pdata{'destination'}); } #update.html
if( $k eq 'debug' && $pdata{'debug'} eq "pilbeam" ){ $pilbeam = 1; } #pilbeam
if( $k eq 'dsort' ){ $pagesort = $pdata{'dsort'};$outstr{'dsort'} = $pagesort; } #az | za | 12 | 21 | rank
if( $k eq 'find' ){ $find = sub_clean_name($pdata{'find'},$htmlext);$find = Encode::decode('utf8',$find);$outstr{'find'} = $find; } #find1+find2
if( $k eq 'filter' ){ $filter = $pdata{$k}; } #editarchive
if( $k eq 'id' ){ $id = Encode::decode('utf8',$pdata{'id'});$outstr{'id'} = $id; } #0+ | update | 1523887523
if( $k eq 'new' ){ $new = $pdata{'new'}; #New-Folder/ | file.jpg | newfilehtml | newcliphtml | newfilecss
if( $new =~ /^<(article|style|div id="tt_alldiv")/ ){ $new =~ s/(\n+)/\n/g;unless ( utf8::decode($new) ){ require Encode;$new = Encode::decode(cp1252 => $new); } } else { $new = sub_clean_name($new,$htmlext);$new = Encode::decode('utf8',$new); }$outstr{'new'} = $new; 
###admin_json_out({ 'check text in' => "url:$url  \n\nnew:$new \n\n$debug" },$origin,$callback);
} 
if( $k eq 'origin' ){ $origin = Encode::decode('utf8',$pdata{'origin'}); } #//www.thatsthat.co.uk/
if( $k eq 'position' ){ $position = $pdata{'position'}; }
if( $k eq 'regexp' ){ $regexp = $pdata{'regexp'};$outstr{'regexp'} = $regexp; }
if( $k eq 'code' ){ $code = $pdata{'code'};$outstr{'code'} = $code; }
if( $k eq 'replace' ){ $replace = sub_clean_name($pdata{'replace'},$htmlext);$replace = Encode::decode('utf8',$replace);$outstr{'replace'} = $replace; } #replace1+replace2
if( $k eq 'type' ){ $type = Encode::decode('utf8',$pdata{'type'});if( $type eq "alertfolders" ){ $hidealert = 1;$type = "viewalert"; } } 
# addfolders addpages alertfolders archivepages changeaddfolders changeaddpages changearchivepages changedeletefiles changedeletefolders changedeletepages changedistribute changedeploysite changedownloadfolders changedupepages changelibrarypages changelockpages changeunlockpages changeimagepages changerenamefiles changerenamefolders changerankpages changerestorepages changesavepages changesearchfolders changesectionpages changesubpages changetitlepages changeuploadfolders changeuploadsite compressfiles deletefiles deletepages deploysite distribute downloadfolders dupepages editblocks editlibrary editpages getfiles getimages getedittextclips getgridclips getsectionclips getguides hidemappages hidefolderpages hidepages  viewconfigpages listmenupages newlinkpages newmenupages renamefiles renamefolders reorderpages restoredelete restoreprotect restoresite searchfolders showpages showmappages uncompressfiles uploadfolders usedfiles viewalert viewall viewfix viewfolders viewpages viewsharefix viewversionpages
if( $k eq 'url' ){ $url = Encode::decode('utf8',$pdata{'url'});$url = sub_clean_name($url,$htmlext);$sitepage = $url; } #documents/Publications/Presentations-and-Brochures/CARIBSAVE-Stakeholder-Workshop-2009/.library.txt
if( $k eq 'old' ){ $old = sub_clean_name($pdata{'old'},$htmlext);$old = Encode::decode('utf8',$old);$outstr{'old'} = $old; } # documents/Templates-and-Guides/Default-Page-Template.html | html | grid_15683655665644
foreach my $j(keys %defsections){ my $n = lc $j;$n =~ s/\s+/-/g;if($k eq $n){ $gsections{$j} = $defsections{$j}->[1];$debug.= "gsection: $k = $n from $j \n"; } }
}

admin_json_out({ 'error' => "main 1: \n\nunauthorised user request received by server $serverenv == $serverip" },$origin,$callback) unless $serverenv =~ /^($serverip)/;
###if( defined $origin ){ admin_json_out({ 'debug' => "main 2: \n\n$debug \norigin: $origin" },$origin,$callback); }

$outstr{'url'} = $url;
$outstr{'destination'} = $dest;
$outstr{'type'} = $type;

if( $type =~ /view(alert|all|fix)$/ || $type eq "login" || $type eq "getimages" || $type eq "getfiles" || $type =~ /pages$/ || ($type =~ /^download/ && !defined $url) ){ $pages = "include"; }
if( $type =~ /view(alert|all|fix)$/ || $type eq "login" || $type eq "getimages" || $type eq "getfiles" || $type =~ /folders$/ || $type =~ /files$/ ){ $documents = "include"; }

# url: /var/www/vhosts/pecreative.co.uk/rsmpartners.com/newest/documents/
# fullurl: /var/www/vhosts/pecreative.co.uk/rsmpartners.com/newest/documents/
# envpath: /var/www/vhosts/pecreative.co.uk/rsmpartners.com/cgi-bin/newest/ 
# cgipath: cgi-bin/newest/
# base: /var/www/vhosts/pecreative.co.uk/rsmpartners.com/newest/ 
# nwbase: /var/www/vhosts/pecreative.co.uk/rsmpartners.com/
# obase: //www.rsmpartners.com/
# subdir: newest/
# baseview: //www.rsmpartners.com/newest/
# dlevel: 0
# type: view
# dest: view.html 
# pages: include 
# tt: 0
#origin:

if( $type !~ /^(changesearch|changerestorepages|changeaddpages|changedupepages|changelibrarypages|changesectionpages|changedeploysite|changedistribute|changeuploadsite|getguides)/ ){
if( $type =~ /view(alert|all|fix)$/ || $type eq "login" || $type eq "getimages" || $type eq "getfiles" ){
$url = "";
} elsif( $type =~ /restore/){
$url = $restorebase.$url;
} elsif( !defined $url ){
$url = ($type =~ /^(addpages|deploy|download|dupepages|reorderpages|search|uploadsite)/)?"":$docview;
if( $type =~ /viewpages/ && $url !~ /\.($htmlext)$/ ){ $url = ""; }
} else {
if( defined $documents && $url !~ /^($docview)/ ){ $url = $docview.$url; }
}
}
if( $url !~ /^http(s)*:\/\// ){$url = $baseview.$url;}

if( !defined $dest ){ $dest = $type.".".$htmlext; }
admin_json_out({ 'error' => "(alert: no data received by server: $debug.)" },$origin,$callback) unless $url ne "";

#/var/www/vhosts/pecreative.co.uk/rsmpartners.com/newest/documents/
$fullurl = sub_get_target($url,$base,$subdir,$nwurl,$nwbase);$debug.= "\n\ntype:$type \n$outstr{'url'} \nbecame \nurl:$url \nfullurl:$fullurl \nenvpath:$envpath \nbase:$base \ndocview:$docview \nbaseview:$baseview \ndocuments:$documents \npages:$pages \ncgipath:$cgipath \ncgix:$cgix \npl:$pl \n";
my $dtmp = $fullurl;if( $type ne "login" && $type ne "viewall" && $type ne "viewalert" && $type ne "viewfix" && $type ne "viewsharefix" ){ if( defined $pages ){ $dtmp =~ s/^($base|$baseview)//;$dtmp =~ s/\.($htmlext)$//;$dlevel = scalar split /$qqdelim/,$dtmp;$dlevel++; } else { $dtmp =~ s/^($base|$baseview)//;$dtmp =~ s/\.(.*?)$//;$dlevel = scalar split /\//,$dtmp; } } ##==pilbeam
###admin_json_out({ 'check urls' => " new:$new \nurl:$url = $outstr{'url'} = $sitepage\nposition: $position \n\nsitemap:$sitemap \nfullurl: $fullurl \ndlevel: $dlevel \ndtmp = $dtmp \n\n$debug" },$origin,$callback);

%config = ( 
'adminbase' => $adminbase,
'attri' => $attri,
'auxfiles' => $auxfiles,
'backupbase' => $backupbase,
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
'deftemp' => $deftemp,
'delete_limit' => $delete_limit,
'delim' => $delim,
'dest' => $dest,
'dlevel' => $dlevel,
'docspace' => $docspace,
'documents' => $documents,
'docview' => $docview,
'editareas' => \%editareas,
'extdoc' => $extdoc,
'extlib' => $extlib,
'filter' => $filter,
'format' => $format,
'ftpbase' => $ftpbase,
'ftpcheck' => $ftpcheck,
'ftppass' => $ftppass,
'fullmenu' => $fullmenu,
'fxfile' => $fxfile, #HTML|TXT|XLSX|PPTX|DOCX|HTM|LISTING|DOC|PDF|PPS|PPT|XLS|PNG|JPEG|JPG|GIF|ZIP
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
'keeplinks' => 'on',
'libtags' => \@libtags,
'listdir' => $listdir,
'liblister' => $liblister,
'menulimit' => $menu_limit,
'mobpic' => $mobpic,
'nwbase' => $nwbase,
'nwurl' => $nwurl,
'obase' => $obase,
'otitle' => $otitle,
'origin' => $origin,
'pages' => $pages,
'pagefull' => undef,
'pagesort' => $pagesort,
'pagewrap' => $pagewrap,
'partnerfolder' => $partnerfolder,
'partnerview' => $partnerview,
'perms' => \%perms,
'pl' => $pl,
'position' => $position,
'pulledlink' => undef,
'qqdelim' => $qqdelim,
'repdash' => $repdash,
'resourcefolder' => $resourcefolder,
'restorebase' => $restorebase,
'sharelist' => \%sharelist,
'site_file' => $site_file,
'sitepage' => $sitepage,
'subdir' => $subdir,
'templateview' => $templateview,
'titlesep' => \@titlesep,
'taglister' => $taglister,
'uncache' => $uncache,
'user' => $adminuser,
'UTF' => \@UTF,
'UTF1' => \@UTF1,
'versionbase' => $versionbase,
'version_limit' => $version_limit,
'webbase' => $webbase
);


if( $type eq "viewsharefix" ){
my $u = $url;$u =~ s/^($baseview)//;
###admin_json_out({ 'check viewsharefix' => "type:$type \nurl:$url \nfullurl:$fullurl \n\n".Data::Dumper->Dump([\%pdata],["PDATA"])." \n\n $debug" },$origin,$callback);
my ($serr,$smsg) = sub_page_rewrite("alter",$fullurl,{'code' => "code"},\%config,[],[ $u ]);
###admin_json_out({ 'check viewsharefix' => "type:$type \nfullurl:$fullurl \nnew:$new \nsf:$sf \n\n".Data::Dumper->Dump([\%pdata],["PDATA"])." \n\n $debug" },$origin,$callback);
my $dtxt = ( defined $serr )?"Warning: share update error $smsg: $serr = $debug":"Updated share links for Page <b>$u<\/b> successfully.";
admin_json_out({ 'result' => '<span class="restoreresult'.( ($dtxt =~ /error/i)?' red':'' ).'">'.$dtxt.'</span>' },$origin,$callback);


} elsif( $type eq "archivepages" ){
admin_display_pagearchive($type,$fullurl);


} elsif( $type =~ /compressfiles$/ ){
my @res = ();
my ($num,$jsref,$cssref) = admin_get_js($base,"pack");
###admin_json_out({ 'result' => "num:$num \n".Data::Dumper->Dump([$jsref],["jsref"])."\n \n".Data::Dumper->Dump([$cssref],["cssref"])."\n\n".$debug },$origin,$callback);
if($num > 0){
if($type eq "uncompressfiles"){

my %atmp = %{ sub_merge_hash( $jsref,$cssref ) };
foreach my $w(sort keys %atmp){
my $n = $w;$n =~ s/\.(css|js)$/-full.$1/; #push @res,"<span class=\"result\">$w = $n</span>";
my $derr = sub_admin_copy('file',$n,$w,\%config,"overwrite");
push @res,( (defined $derr)?"<span class=\"error\">uncompress file: copy $n to $w: $derr </span>":"<span class=\"result\">$w expanded</span>" );
}

} else {

eval "use CSS::Compressor qw( css_compress )";
if($@){
$debug.= "CSS::Compressor is not available on this server";
} else {
my %ctmp = %{$cssref};
foreach my $s(sort keys %ctmp){
my $cs = $ctmp{$s}->{'tmp'};
my $tmp = css_compress( $cs );
###admin_json_out({ 'result' => "s:$s \ntmp:$tmp \n\n".$debug },$origin,$callback);
my $herr = undef;
my $hfile = gensym;
open($hfile,">:utf8",$s) or try { die "open file $s failed: $! "; } catch { $herr = "<span class=\"error\">compress file: open file $s failed: $_ </span> "; };
if( defined $hfile && !defined $herr ){
flock ($hfile,2);
print $hfile $tmp;
}
close($hfile);
if(defined $herr){ push @res,$herr; } else { push @res,"<span class=\"result\">$s created</span>"; }
}
}

eval "use JavaScript::Packer";
if($@){
$debug.= "Javascript::Packer is not available on this server";
} else {
my %jtmp = %{$jsref};
my $packer = JavaScript::Packer->init();
foreach my $w(sort keys %jtmp){
my $top = $jtmp{$w}{'top'};
my $tmp = $packer->minify(\$jtmp{$w}{'tmp'},{compress => 'best'} );
###admin_json_out({ 'result' => "w:$w \ntop:$top \n\ntmp:$tmp \n\n".$debug },$origin,$callback);
my $herr = undef;
my $hfile = gensym;
open($hfile,">:utf8",$w) or try { die "open file $w failed: $! "; } catch { $herr = "<span class=\"error\">compress file: open file $w failed: $_ </span> "; };
if( defined $hfile && !defined $herr ){
flock ($hfile,2);
print $hfile $top.$tmp;
}
close($hfile);
if(defined $herr){ push @res,$herr; } else { push @res,"<span class=\"result\">$w created</span>"; }
}
}

}
}
admin_json_out({ 'result' => (join " ",@res) },$origin,$callback);


} elsif( $type =~ /^view/ ){
#admin/libraryadmin.pl?type=alert
#admin/libraryadmin.pl?type=viewall
#admin/libraryadmin.pl?type=viewfolders
#admin/libraryadmin.pl?type=viewfolders&url=documents%2F
#admin/libraryadmin.pl?type=viewfolders&url=documents%2FImages%2F
#admin/libraryadmin.pl?type=viewfolders&url=documents%2FImages%2Flogos%2F
#admin/libraryadmin.pl?type=viewpages
#admin/libraryadmin.pl?type=viewconfigpages
#admin/libraryadmin.pl?type=viewfix
#admin/libraryadmin.pl?type=viewpages&url=News.html
#admin/libraryadmin.pl?type=viewversionpages&url=News_RSM-Becomes-Member-of-MSPAlliance.html
#admin/libraryadmin.pl?type=viewfolders&url=documents$2FArchive%2F
if( $type eq "viewconfigpages" ){ admin_display_config($type,$fullurl); } else { admin_list($url,$fullurl,$type,$base.$adminbase.$dest); }


} elsif( $type eq "editlibrary" ){
admin_display_library($type,$fullurl);


} elsif( $type eq "login" ){
#admin/libraryadmin.pl
my @old = sub_get_html($base,\%config);
my $respoint = admin_restore("save",\@old);
admin_list($url,$fullurl,"viewall",$base.$adminbase."view.".$htmlext,$respoint);


} elsif( $type =~ /^restore/ ){
#admin/libraryadmin.pl?type=restoresite&url=restore~~15%3A11%3A00-07--11--2017
#admin/libraryadmin.pl?type=restoreprotect&url=restore~~14:53:17-08--11--2017&new=Full-Set-Skills
#admin/libraryadmin.pl?type=restoredelete&url=restore~~15:09:23-08--11--2017
my $durl = undef;if( $type =~ /protect$/){ $durl = $fullurl;$durl =~ s/^(.+)($repdash$repdash.*?)$/$2/;$durl = $base.$restorebase.$new.$durl; }
my $dtxt = admin_restore($type,[ $fullurl,$durl ]);
admin_json_out({ 'result' => '<span class="restoreresult'.( ($dtxt =~ /error/i)?' red':'' ).'">'.$dtxt.'</span>' },$origin,$callback);


} elsif( $type eq "deploysite" || $type eq "distribute" ){
#admin/libraryadmin.pl?type=deploysite
#admin/libraryadmin.pl?type=distribute
###admin_json_out({ 'check deploysite' => "type:$type \nurl:$url \nfullurl:$fullurl \ndest:$dest\n\n".Data::Dumper->Dump([\%pdata],["PDATA"])." \n\n $debug" },$origin,$callback);
my $duptxt = admin_html_in($base.$adminbase.$dest);
my $dtxt = '<div class="text nonmenufolder deploy"><div class="inputline"><label for="new-baseurl_0">New Site URL: <span class="red">*</span></label><input id="new-baseurl_0" class="filterselect" name="pre_new-baseurl_0" tabindex="0" maxlength="50" type="text" value="'.$ENV{'HTTP_HOST'}.'" /></div></div>';
$dtxt.= '<div class="text nonmenufolder deploy"><div class="inputline"><label for="new-baseid_0">New Site Name: <span class="red">*</span></label><input id="new-baseid_0" class="filterselect" name="pre_new-baseid_0" tabindex="0" maxlength="50" type="text" value="'.$otitle.'" /></div></div>';
$dtxt.= '<div class="text nonmenufolder deploy"><div class="inputline"><span class="include">Include Site Pages: </span><input id="addpagesite_0" name="opt_addpagesite_0" value="addpagesite" type="checkbox"><label for="addpagesite_0" class="css-check">&#160;</label></div></div>';
$dtxt.= '<div class="text nonmenufolder deploy"><div class="inputline"><span class="include">Include Site Scripts: </span><input id="addscriptsite_0" name="opt_addscriptsite_0" value="addscriptsite" type="checkbox"><label for="addscriptsite_0" class="css-check">&#160;</label></div></div>';
$dtxt.= '<div class="text nonmenufolder deploy"><div class="inputline"><span class="include">Include LIB folder: </span><input id="addlibsite_0" name="opt_addlibsite_0" value="addlibsite" type="checkbox"><label for="addlibsite_0" class="css-check">&#160;</label></div></div>';
$dtxt.= '<div class="text nonmenufolder deploy"><div class="inputline"><span class="include">Include Documents folder: </span><input id="adddocumentsite_0" name="opt_adddocumentsite_0" value="adddocumentsite" type="checkbox"><label for="adddocumentsite_0" class="css-check">&#160;</label></div></div>';
$dtxt.= '<div class="text nonmenufolder deploy"><div class="inputline"><span class="include">Include Site Structure: </span><input id="addstructuresite_0" name="opt_addstructuresite_0" value="addstructuresite" type="checkbox"><label for="addstructuresite_0" class="css-check">&#160;</label></div></div>';
$dtxt.= '<div class="text nonmenufolder deploy"><div class="inputline"><span class="include">Include CGI Scripts: </span><input id="addcgisite_0" name="opt_addcgisite_0" value="addcgisite" type="checkbox"><label for="addcgisite_0" class="css-check">&#160;</label></div></div>';
$dtxt.= '<div class="text nonmenufolder deploy"><div class="inputline"><span class="include">Include Admin Files: </span><input id="addadminsite_0" name="opt_addadminsite_0" value="addadminsite" type="checkbox"><label for="addadminsite_0" class="css-check">&#160;</label></div></div>';
if( $type eq "distribute" ){ $dtxt.= '<div class="text nonmenufolder deploy purge"><div class="inputline"><span class="include">Purge Old Files: </span><input id="addpurgesite_0" name="opt_addpurgesite_0" value="addpurgesite" type="checkbox"><label for="addpurgesite_0" class="css-check">&nbsp;</label></div></div>'; }
$dtxt.= '<div class="text nonmenufolder pages"><h2><input id="used1_0" name="used1_0" type="checkbox" /><label for="used1_0" class="tt_tabclick navblock nav-edit editseo" tabindex="0" title="edit Page SEO">Edit Page SEO Data</label><span class="dropspacer">&#160;</span>';
foreach my $hr( sort keys %headers ){ if( $hr !~ /^og:image/i ){
$dtxt.= '<span class="inputline unsearch"><label for="new-'.$hr.'_0" tabindex="0">'.( (defined $headers{$hr} && defined $headers{$hr}[3])?$headers{$hr}[3]:$hr ).':</label>';
$dtxt.= ( $hr =~ /^(description|keywords)$/ )?'<textarea  id="new-'.$hr.'_0" name="opt_new-'.$hr.'_0" tabindex="0" maxlength="300">'.( (defined $headers{$hr} && defined $headers{$hr}[2])?$headers{$hr}[2]:"" ).'</textarea>':'<input id="new-'.$hr.'_0" name="opt_new-'.$hr.'_0" tabindex="0" type="text" maxlength="300" value="'.(  (defined $headers{$hr} && defined $headers{$hr}[2])?$headers{$hr}[2]:"" ).'" />';
$dtxt.= '</span>';
} }
$dtxt.= '</h2></div>';
$duptxt =~ s/(<div class="inputline"><\/div>)/$dtxt/;
admin_html_out($duptxt);


} elsif( $type =~ /^get(alter|edittext|grid|section)clips/ ){
#admin/libraryadmin.pl?type=getgridclips&destination=editclipboard.html&id=paste
#admin/libraryadmin.pl?type=getsectionclips&destination=editclipboard.html&id=list
#admin/libraryadmin.pl type=getedittextclips destination=editclipboard.html new=html id=cut
#admin/libraryadmin.pl type=getalterclips cs:alter id:0 old:grid_15683655665644 new:html replace:New Title 
my $cu = $fullurl;
my $cs = $1;if($cs eq "alter"){$cu.= "Clipboard";$id = $cs;$cs = $old;$cs =~s /_([0-9]+)$//i;}
my ($rref,$rtxt) = admin_get_allclips($id,$cu,[$cs],$old,$new,$replace);
my %cd = %{$rref};
###admin_json_out({ 'result' => "type:$type \ncs:$cs \nid:$id \nold:$old \nnew:$new \nreplace:$replace \n\n".Data::Dumper->Dump([\%cd],["cd"])."\n\n $debug" },$origin,$callback);
if( $id =~ /(alter|cut)$/ ){
print "Location: ".$pl."type=viewconfigpages\n\n";
exit;
#} elsif( $id =~ /(list|cut)$/ ){
#my $otxt = admin_html_in($base.$adminbase.$dest);
#$otxt =~ s/(<div class="text clipboarddata"><\/div>)/$rtxt/;
#admin_html_out($otxt);
} else {
my %out = ();foreach my $k(keys %{$cd{$cs}}){ $out{$k} = [ $cd{$cs}{$k}->[0],'<article id="'.$k.'" class="clipboard-'.$cs.'" data-clipname="'.$cd{$cs}{$k}->[0].'">'.$cd{$cs}{$k}->[1].'</article>' ]; }
admin_json_out({ 'result' => \%out },$origin,$callback);
}


} elsif( $type eq "getimages" || $type eq "getfiles" ){
#admin/libraryadmin.pl?type=getimages&url=documents/Images/
#admin/libraryadmin.pl?type=getimages&url=documents/Images/&id=filter
#admin/libraryadmin.pl?type=getfiles&url=all
my @dp = split /\//,$url;
my @unused = ();
my $dpath = undef;
if( $id eq "versions"){
$dpath = sub_folder_empty($base.$versionbase);
} elsif( $id eq "trash"){
$dpath = sub_folder_empty($base.$trashbase);
} else {

my %im = ( 'files' => {} );
my %um = ();
my ($cterr,$ctref) = sub_files_return("viewfiles",$base.$docview,\%config,"all","$htmlext|pdf");
admin_json_out({ 'error' => "alert: no useable data retrievable by server: $cterr $debug" },$origin,$callback) unless defined $ctref && !defined $cterr;
$im{'files'} = $ctref->{'files'};
###admin_json_out({ 'result' => "".Data::Dumper->Dump([\%im],["im"])."\n\n".$debug },$origin,$callback);
my %um = %{ sub_image_used($fullurl,\%config,$im{'files'},undef,"used") }; #,( ($id =~ /^(filter|delete)/)?$im{'pages'}:undef )
###admin_json_out({ 'result' => "".Data::Dumper->Dump([\%um],["um"])."\n\n".$debug },$origin,$callback);

if( $id =~ /^(filter|delete)/ ){
foreach my $k(sort keys %um){ 
if( $k =~ /^($imageview)/ && $k =~ /\.(jpg|png|gif)$/i && $k !~ /($mobpic)\.(jpg|png|gif)$/ ){ 
my $d = $k;$d =~ s/^($docview)//;
if( defined $um{$k}->{'used'} && scalar @{ $um{$k}{'used'} } > 0 ){ 
$debug.= "$k is used in ".@{ $um{$k}->{'used'} }[0]."\n";
} else {

if( $id eq "delete" ){
if( -f $base.$k ){ my $nk = $k;$nk =~ s/^(.+\/)//;my $mer = undef;mv ($base.$k,$base.$trashbase.$nk) or $mer = "Rename error: $k to $trashbase$nk: $! <br />";push @unused,'<a class="restoreresult'.( (defined $mer)?' error">'.$k.': '.$mer:'" href="'.$trashbase.$nk.'" target="_blank">'.$d.': moved to Trash' ).'</a>'; }
} else {
$debug.= "add unused: $k = $d \n";
push @unused,'<a href="'.$k.'" title=""view Image" target="_blank">'.$d.'</a>';if( defined $um{$k}->{'mobile'} ){ my @p = @{$um{$k}->{'path'}};unshift @p;push @p,$um{$k}->{'mobile'};push @unused,( '<a href="'.(join "\/",@{1..$#p}).'" title=""view Image" target="_blank">'.(join "\/",@p).'</a>' ); }; 
}

}
} 
}
$dpath = join '',@unused;
###admin_json_out({ 'result' => "url:$url \nid:$id \ndpath:$dpath \n\n$debug" },$origin,$callback);
} else {
my %uset = ();
foreach my $k(sort keys %um){ 
if( $k =~ /^($docview$imagefolder)/ && $k =~ /\.(jpg|png|gif)$/i && $k !~ /($mobpic)\./ ){
my @path = split /\//,$k;
my @usref = ();if( defined $um{$k}->{'used'} ){ push @usref,scalar @{ $um{$k}->{'used'} }; }
my $kk = ( defined $um{$k}->{'mobile'} )?@{ $um{$k}->{'mobile'} }[0]:"";
if( scalar @path < 1){
if( $k =~ /\.(png|jpg|gif)$/ ){ $uset{$k} = { used => \@usref,'mobile' => $kk }; }
} else {
if( !defined $uset{$path[0]} ){ $uset{$path[0]} = {}; }
my $pathref = $uset{$path[0]};
for my $i(1..$#path-1){ if( !defined $pathref->{ $path[$i] } ){ $pathref->{ $path[$i] } = {}; }$pathref = $pathref->{ $path[$i] }; } 
$pathref->{ $path[$#path] } = { 'used' => \@usref,'mobile' => $kk }; 
}
}
}
$dpath = $uset{'documents'};
for my $i( 1..$#dp ){ if( defined $dpath->{ $dp[$i] } ){ $dpath = $dpath->{ $dp[$i] }; } }
}
###admin_json_out({ 'result' => "url:$url \nid:$id \n\n".Data::Dumper->Dump([\%um],["um"])."\n\n".$debug },$origin,$callback);
}
admin_json_out({ 'result' => $dpath },$origin,$callback);


} elsif( $type eq "getguides" ){
my %gu = ();
#<p class="info"><span class="boldtext">data-amount</span> = '1': [ defines number of results to show and paginate if data-id is 'index' (the default is 0 to show all)  ]</p>
my $gtxt = admin_html_in($fullurl);
if( $gtxt =~ /<p id="$id Module">.*?<\/p>\s*<p><\/p>\s*(.*?)\s*<p><\/p>/ism){ my $fo = $1;while( $fo =~ /<p class="info"><span class="boldtext">data-(.*?)<\/span>\s=\s*(.*?)<\/p>/gism ){ $gu{$1} = $2;$gu{$1} =~ s/(<span class=".*?">|<\/span>)//gi; } }
admin_json_out({ 'result' => \%gu },$origin,$callback);


} elsif( $type eq "addpages" ){
#admin/libraryadmin.pl?type=addpages
#admin/libraryadmin.pl?type=addpages&url=Solutions.html
###admin_json_out({ 'check addpages' => "fullurl:$fullurl url:$url $debug" },$origin,$callback);
admin_display_pageadd($type,$fullurl);


} elsif( $type eq "addfolders" || $type eq "deletefiles" ||$type eq "deletefolders" ||  $type eq "deletepages" || $type eq "downloadfolders" || $type eq "reorderpages" || $type eq "renamefiles" || $type eq "renamefolders" || $type eq "searchfolders" ){
#admin/libraryadmin.pl?type=addfolders&url=documents%2FImages%2Fbackgrounds%2F
#admin/libraryadmin.pl?type=deletefolders&url=documents%2FImages%2Fbackgrounds%2F
#admin/libraryadmin.pl?type=renamefolders&url=documents%2FImages%2FTest-Folder%2F
#admin/libraryadmin.pl?type=downloadfolders
#admin/libraryadmin.pl?type=downloadfolders&url=documents%2FDigital%2F
#admin/libraryadmin.pl?type=reorderpages&url=News.html
#admin/libraryadmin.pl?type=alertfolders
#admin/libraryadmin.pl?type=searchfolders
#admin/libraryadmin.pl?type=deletepages&url=Solutions_New-Page.html
#admin/libraryadmin.pl?type=deletefiles&url=documents%2FImages%2Fbackgrounds%2F&old=documents%2FImages%2Fbackgrounds%2Fheader-solutions.png
#admin/libraryadmin.pl?type=renamefiles&url=documents%2FImages%2Fbackgrounds%2F&old=documents%2FImages%2Fbackgrounds%2Fheader-solutions.png
#admin/libraryadmin.pl?type=deletefiles&url=documents%2FArchive%2FGroup-News%2F2015%2FGroup_News.html%2F&old=documents%2FArchive%2FGroup-News%2F2015%2FGroup_News_Revive-Paper-sponsors-2018-Heist-Awards.html
my $uptxt = admin_html_in($base.$adminbase.$dest);
$url =~ s/(\.$htmlext).*?$/$1/;
my $upf = ($type eq "deletefiles" || $type eq "renamefiles")?$old:$url;$upf =~ s/^($baseview)//;if( $upf =~ /($docview)Archive\//){ $upf =~ s/^(.+\/).*?(\.$htmlext)$/$1index\.$htmlext/;$url = $baseview.$upf;$fullurl = $base.$upf; }
my $nurl = ($type eq "deletefiles" || $type eq "renamefiles")?$old:undef;
my @subs = ();
my @als = ();
my @warn = ();
my %exclude = ( 'unadd' => 1,'unupload' => 1 );
if( $type =~ /pages$/ ){ my ($subref,$smsg) = sub_get_subnumber($upf,\%config);@subs = @{$subref};$debug.= "subs: @subs / ".(scalar @subs)." / $smsg\n\n";my ($alref,$amsg) = sub_get_aliases($upf,\%config);@als = @{$alref};$debug.= "aliases: @als / ".(scalar @als)." / $amsg\n\n"; }
if( $type =~ /^(download|reorder|search)/ ){ $exclude{'undownload'} = 1; }
if( $type =~ /^(delete|rename)/ ){ 
###admin_json_out({ 'check '.$type.'' => "fullurl:$fullurl \nurl:$url \nupf:$upf \nsubs:".(scalar @subs)." \nals:".(scalar @als)." \n\n".Data::Dumper->Dump([\@warn],["warn"])." \n\n $debug" },$origin,$callback);
if( -e $fullurl ){ @warn = sub_get_changed("all","used",$base,\%config,$upf); } else { $warn[0] = ( "Warning:","the server cannot locate file $upf: $!" ); }
###admin_json_out({ 'check '.$type.' 1' => "fullurl:$fullurl \nurl:$url \nsubs:".(scalar @subs)." \nals:".(scalar @als)." \n\n".Data::Dumper->Dump([\@warn],["warn"])." \n\n $debug" },$origin,$callback);
}
admin_display_form($type,$url,$uptxt,"prev",\%exclude,\@warn,((scalar @subs > 1)?(scalar @subs-1):undef),((scalar @als > 0)?scalar @als:undef),$nurl);


} elsif( $type eq "dupepages" ){
#admin/libraryadmin.pl?type=dupepages&url=Solutions.html
###admin_json_out({ 'check dupepages' => "fullurl:$fullurl url:$url $debug" },$origin,$callback);
admin_display_pagedupe($type,$fullurl);


} elsif( $type =~ /^change/ ){ 
#type:changeaddfolders url:documents/Images/logos/customers/, new:latest-stuff
#type:changeaddpages url:Modules.html
#type:changedupepages url:Modules.html
#type:changedeletefolders url:documents/Images/logos/customers/latest-stuff/
#type:changedeletepages url:Modules.html
#type:changedeletefiles url:documents%2FImages%2Fbackgrounds%2Fheader-solutions.png
#type:changedeploysite url: /
#type:changedistribute url: /
#type:changeimagepages url:News_RSM-Becomes-Member-of-MSPAlliance.html
#type:changelibrarypages url:documents/Digital/Datasheets/Mainframe-Services/ new:url:+24-7-Incident-Support-Help-Desk.pdf image:+24-7-Incident-Support-Help-Desk_thumb.jpg 
#type:changesectionpages id:top-bar new:<div id="tt_topbar" class="new"></div>
#type:changerankpages
#type:changelockpages
#type:changeunlockpages
#type:changeimagepages
#type:changerenamefiles url:documents%2FImages%2Fbackgrounds%2Fheader-solutions.png new: documents%2FImages%2Fbackgrounds%2Fheader-new.png
#type:changerestorepages url:VERSIONS/News_RSM-Becomes-Member-of-MSPAlliance~~14:05:10-17--05--2017.html 
#type:changesavepages url:News_RSM-Becomes-Member-of-MSPAlliance.html, new:<div class="alldiv">etc</div>
#type:changesearchfolders url:documents/ find:security+dave, replace:insecurity+ray, new:alter, regexp:/etc/, code:1
my $cc = $url;$cc =~ s/^($baseview|$base)//;
my $oldurl = $baseview;$oldurl =~ s/^htt(p|ps)://;$oldurl =~ s/^\/\///;$oldurl =~ s/\/.*?$//;$oldurl =~ s/^(.+)\/(.*?)$/$2/;
my $uptxt = admin_html_in($base.$adminbase."update.".$htmlext);
my $cht = ($type =~ /(folder|file|page)s/i )?$1:"";
my $uu = $url;
my $uf = undef;
my %exclude = ();
my @cm = ();
my $cho = "";
my $oo = "";
my $pre = undef;
my ($cterr,$ctref,$nferr,$nf,$nn);
#
if( $type =~ /(library|save|section)/ ){
%exclude = ( 'unadd' => 1,'unreorder' => 1,'unupload' => 1,'undownload' => 1 );
my %m = ();
my @find = ();
my @rep = ();
my $pres = "Page";
my @fbase = ( $base );
my $purl = "";
my $dbug = "";
my $msg = undef;
if( $type eq "changelibrarypages" ) {$pres = "Library File";$purl.= $liblister; } else { foreach my $k(keys %gsections){ if($type eq "changesectionpages"){ push @fbase,@seclist;push @find,$gsections{$k};push @rep,$new; } else { if( $new =~ /$gsections{$k}/ism ){ push @find,$gsections{$k};push @rep,$1; } } } }
###admin_json_out({ "check $type" => "type:$type \nid:$id \nfullurl:$fullurl \nfbase:[ @fbase ]\n\n".Data::Dumper->Dump([\%gsections],["gsections"])." \n\nnew:$new \nnf:$nf \n\n $debug" },$origin,$callback);
#
if( $type =~ /^change(save|library)pages$/ ){
($nferr,$nf) = sub_admin_save_page($url.$purl,$fullurl.$purl,$new,\%config);
if( defined $nferr ){ if( !defined $msg ){ $msg = "$url$purl: $nferr $nf \n"; } else { $msg.= "$url$purl: $nferr $nf \n"; } }$dbug.= "$nf \n";
###admin_json_out({ 'check $type' => "pres:$pres \nfullurl:$fullurl$purl \nnew:$new \nmsg:$msg \nnf:$nf \n\n".Data::Dumper->Dump([\%pdata],["PDATA"])." \n\n $debug" },$origin,$callback);
my $upsite = ($type !~ /library/ && defined $sitemap)?( admin_sitemap_update($sitemap) ):"";
$cho = ( defined $nferr )?"Warning: problem with updating $pres $nf: $nferr = $debug":"Updated $pres <b>$nf<\/b> successfully $upsite<br />";
}
#
if( scalar keys %gsections > 0 ){
my %res = ('found' => 0,'updated' => 0);
($cterr,$ctref) = sub_page_return("searchpages",\@fbase,\%config,undef,undef,undef,undef,undef,undef,undef,undef,undef,1);
if( defined $ctref && !defined $cterr ){
###admin_json_out({ 'check gsections 1' => "type:$type \n\n".Data::Dumper->Dump([$ctref],["ctref"])."\n\nfind = [ @find ] \n\nrep = [ @rep ] \n\n$debug" },$origin,$callback);
my @tmp = @{$ctref};
for my $i(0..$#tmp){ 
my $pg = $tmp[$i]->{'url'}[0];$debug.= "searching Page $pg.. \n";
###admin_json_out({ 'check gsections 2' => "type:$type \npg: $pg == $fullurl \n\n".Data::Dumper->Dump([$tmp[$i]],["tmp $i"])."\n\n $debug" },$origin,$callback);
if( $fullurl =~ /$pg/ ){ 
$debug.= "$pg already updated \n";
} else { 
my ($serr,$smsg,$iref) = sub_page_rewrite("alter",$base.$pg,{'code' => "code"},\%config,\@find,\@rep,"regex","allendings");
if( defined $serr ){ if(!defined $msg){$msg = "$pg: $serr $smsg \n";} else {$msg.= "$pg: $serr $smsg \n";} }
$dbug.= "$pg: found:".$iref->{'found'}." updated:".$iref->{'updated'}." \n";if( defined $iref->{'found'} && $iref->{'found'} > 0 ){ $res{'found'}++; }if( defined $iref->{'updated'} && $iref->{'updated'} eq 'ok' ){ $res{'updated'}++; }
}
}
} else { if(!defined $msg){$msg = "$cterr \n";} else {$msg.= "$cterr \n";} }
$cho.= (defined $msg)?"Warning: problem with updating Site Pages: $msg = $debug":"Updated Site Pages successfully: Found:$res{'found'} Updated:$res{'updated'}";
###admin_json_out({ 'check gsections 3' => "type:$type \n\nmsg:$msg \ncho:$cho \n\ndbug:$dbug \n\n$debug" },$origin,$callback);
}

} elsif( $type eq "changearchivepages" ){
my $cc = $url;$cc =~ s/^($base|$baseview)//;
my ($derr,$drep);
if( -d $base.$old && -f $fullurl ){  #documents/Archive/Group-News/2015/  Group_News_Revive-Paper-sponsors-2018-Heist-Awards.html
$derr = sub_admin_copy('Page',$fullurl,$base.$old.$cc,\%config,"overwrite");
if(defined $derr){
$cho = 'Warning: problem with updating Page '.$old.$cc.': '.$derr.' = '.$debug;
} else {
my ($merr,$mmsg,$mtxt) = sub_page_update($base.$old.$cc,undef,{ 'new-url' => $old.$cc,'new-link' => $old.$cc },undef,undef,undef,\%config);
$cho = (defined $merr)?'Warning: problem with updating Page '.$old.$cc.': '.$merr.' = '.$debug:'Archived Page '.$cc.' successfully.';
}
} else {
$cho = "Warning: problem with archiving Page $cc (dir:$base$old file:$fullurl): $! $debug";
}
###admin_json_out({ 'check changearchivepages' => "type:$type \ncc:$cc \nfullurl:$fullurl \ncho:$cho \n\n $debug" },$origin,$callback);
#
} elsif( $type =~ /deploysite/ || $type =~ /distribute/ ){
my %dpp = ();
my @con = ();
my %sites = ();
my @ds = ();
my @dist = ( 'admin','cgi','js','site' );
my $xname = $pdata{'X-File-Name'};
my $purge = undef;
if( defined $xname){
my $xhandle = $query->upload("file"); #raw data
my $xtmpfile = $query->tmpFileName($xhandle);
admin_json_out({ 'error' => "(data size [ $ENV{'CONTENT_LENGTH'} ] is greater than the maximum ${CGI::POST_MAX}k allowed)" },$origin,$callback) unless $ENV{'CONTENT_LENGTH'} < $CGI::POST_MAX;
my ($uerr,$umsg) = sub_new_upload($base,$xname,$xname,$xhandle,$xname,$xtmpfile,$pdata{'X-File-Id'},$pdata{'X-File-Total'},undef,"distribute",\%config);
admin_json_out({ 'error' => "there was an error uploading $xname: $uerr" },$origin,$callback) if defined $uerr;
if( -f $base.$xname ){ push @{$dpp{'additemsite'}},$base.$xname; }
} else {
foreach my $dk( sort keys %pdata ){ delete $pdata{$dk} unless $dk =~ /^new\-/ || $dk eq "destination" || $dk =~ /^add(page|purge|structure|script|admin|cgi|document|lib)site/;if( $pdata{$dk} eq "" || $dk =~ /og:image$/ ){ delete $pdata{$dk}; } }
#$pdata{'new-date'} = sub_get_date($time,\%config,"/");
if( defined $pdata{'addpagesite'} ){ push @con,"pages"; }
if( defined $pdata{'addscriptsite'} ){ push @con,"js"; }
if( defined $pdata{'addlibsite'} ){ push @{$dpp{'addlibsite'}},$base.$cssview;push @con,"lib"; }
if( defined $pdata{'adddocumentsite'} ){ push @{$dpp{'adddocumentsite'}},$base.$docview;push @con,"docs"; }
if( defined $pdata{'addstructuresite'} ){ @{$dpp{'addstructuresite'}} = @structure;push @con,"site"; }
if( defined $pdata{'addcgisite'} ){ push @{$dpp{'addcgisite'}},$base.$cgipath;push @con,"cgi"; }
if( defined $pdata{'addadminsite'} ){ push @{$dpp{'addadminsite'}},$base.$adminbase;push @con,"admin"; }
if( defined $pdata{'addpurgesite'} ){ $purge = 1; }
my @htm = sub_get_html($base,\%config,undef,$auxfiles);
foreach my $hm( @htm){ 
if( -f $hm ){ 
if( $hm =~ /\.(html|htm)$/i ){
if( defined $pdata{'addpagesite'} ){ push @{$dpp{'addpagesite'}},$hm; }
} elsif( $hm =~ /\.(js|php|pl|pm)$/i ){
if( defined $pdata{'addscriptsite'} ){ push @{$dpp{'addscriptsite'}},$hm; }
} else {
if( defined $pdata{'addstructuresite'} ){ push @{$dpp{'addstructuresite'}},$hm; } 
}
} 
}
}
if( defined $pdata{'new-baseurl'} ){ $pdata{'new-baseurl'} =~ s/^htt(p|ps)://;$pdata{'new-baseurl'} =~ s/^\/\///;$pdata{'new-baseurl'} =~ s/\/.*?$//;$pdata{'new-baseurl'} =~ s/^(.+)\/(.*?)$/$2/; }
#
if( $type eq "changedistribute" ){
#
if( defined $pdata{'destination'} && $pdata{'destination'} ne "" ){
$pdata{'destination'} =~ s/(\r\n*)/\n/gim;
my @dz = split /(\n\n)/gim,$pdata{'destination'};
for my $i(0..$#dz){ if( $dz[$i] ne "\n\n" ){ $dz[$i] =~ s/\n/$defsep/g; #$debug.= "$i = ".sub_parse_tags($dz[$i],'',\%config)." \n";
%sites = sub_parse_tags($dz[$i],'',\%config);
} }
###admin_json_out({ 'check changedistributesite' => "fullurl:$fullurl \npurge:$purge \n\n ".Data::Dumper->Dump([\%sites],["sites"])."\n\n ".Data::Dumper->Dump([$ctref],["ctref"])."\n\n ".Data::Dumper->Dump([\%dpp],["dpp"])."\n\n $debug" },$origin,$callback);
$cho = sub_ftp_out(\%sites,\%dpp,$oldurl,\%config,$purge);
$cho = 'Transfer Report</h3><h3 class="result">'.$cho.'</h3>';
if(defined $xname){ admin_json_out({ 'result' => "$cho" },$origin,$callback); }
} else {
$cho = "No Distribution destinations have been added";
}
#
} else {
###admin_json_out({ 'check changedeploysite' => "fullurl:$fullurl \n zipname: $base$backupbase$pdata{'new-baseurl'} \n\n ".Data::Dumper->Dump([\%sites],["sites"])."\n\n ".Data::Dumper->Dump([$ctref],["ctref"])."\n\n ".Data::Dumper->Dump([\%dpp],["dpp"])."\n\n $debug" },$origin,$callback);
$cho = sub_zip_out($fullurl,[],$pdata{'new-baseurl'},$base.$backupbase.$pdata{'new-baseurl'}."-".( sub_get_date($time,\%config,"-") )."-".( join "-",sort @con ).".zip",undef,\%config,$oldurl,\%pdata,\%dpp);
}

} elsif( $type =~ /downloadfolders/ ){
# opt_checkfile0_0 = Site Pages 
# opt_checkfile1_0 = Canvas
# opt_url_0 = "documents/"
my @pd = ();
foreach my $dk( sort keys %pdata ){ if( $dk =~ /^checkfile([0-9]+)/ ){ push @pd,$fullurl.$pdata{$dk}; } }
my $zf = $fullurl;$zf =~ s/\/$//;$zf =~ s/^(.+)\/(.*?)$/$2/;
###admin_json_out({ 'check downloadfolders' => "fullurl:$fullurl zf: $base$backupbase$zf \n\n ".Data::Dumper->Dump([\@pd],["pd"])." \n\n ".Data::Dumper->Dump([\%pdata],["PDATA"])."\nn $debug" },$origin,$callback);
$cho = sub_zip_out($fullurl,\@pd,$zf,$base.$backupbase.$zf.( sub_get_date($time,\%config,"-") ).".zip",undef,\%config,$oldurl);
$pre = "prev";
#
} elsif( $type =~ /uploadfolders/ || $type =~ /uploadsite/ ){
my $outdir = $fullurl;
my $xname = $pdata{'X-File-Name'};
my $upname = sub_check_name($xname,\%config); #Man-and-Lady-300x200.jpg
my $xhandle = $query->upload("file"); #raw data
my $xtmpfile = $query->tmpFileName($xhandle);
my $xno = $pdata{'X-File-Id'}; #0
my $xtotal = $pdata{'X-File-Total'}; #2
my $sized = ( defined $pdata{'sized'} && $pdata{'sized'} ne "" )?$pdata{'sized'}:admin_imagesize($outdir); #Document Thumbnail,_thumb,100,120+Video Screengrab,_video,420,260
my $imported = undef;if( $type =~ /uploadsite/ ){ $outdir = $base.$backupbase;$imported = "import";$sized = undef; }
#my $io_xhandle = $xhandle->handle;
#$xsize = $pdata{'X-File-Size'}; #18393
#'X-File-Resume' => 'false'
#'X-Requested-With' => 'XMLHttpRequest'
admin_json_out({ 'error' => "(data size [ $ENV{'CONTENT_LENGTH'} ] is greater than the maximum ${CGI::POST_MAX}k allowed)" },$origin,$callback) unless $ENV{'CONTENT_LENGTH'} < $CGI::POST_MAX;
###admin_json_out({ 'check changeuploadfolders' => "$ENV{'CONTENT_LENGTH'} pdata: ".Data::Dumper->Dump([\%pdata],["PDATA"])." postdata:".Data::Dumper->Dump([$postdata],["POSTDATA"]) },$origin,$callback );
###admin_json_out({ 'check changeuploadsite' => "outdir: $outdir \nsized:$sized \n\npdata: ".Data::Dumper->Dump([\%pdata],["PDATA"])." \ntype:$type \nupname:$upname \nimported:$imported \n\n $debug" },$origin,$callback );
my ($uerr,$umsg) = sub_new_upload($outdir,$upname,( ($outdir =~ /($new)$/)?undef:$new ),$xhandle,$xname,$xtmpfile,$xno,$xtotal,$sized,$imported,\%config);
admin_json_out({ 'error' => "there was an error uploading $upname: $uerr" },$origin,$callback) if defined $uerr;
admin_json_out({ 'result' => "$umsg" },$origin,$callback);
$pre = "prev";
#
} elsif( $type =~ /(add|dupe)/ ){
%exclude = ( 'unadd' => 1,'unupload' => 1,'undownload' => 1 );
my $isdoc = $fullurl;$isdoc =~ s/^($base)//;
if( $type =~ /dupe/ ){ $pdata{'new-parent'} = $pdata{'old'};$pdata{'old'} = $cc; }
if( $isdoc =~ /^($docview)/ ){ delete $pdata{'new-menuurl'}; } else { if( defined $pdata{'new-menuurl'} ){ if( !defined $pdata{'new-link'} || $pdata{'new-link'} eq "" ){ $pdata{'new-link'} = $pdata{'url'}; } } }
if( defined $pdata{'new-parent'} && $pdata{'new-parent'} =~ /($qqdelim)$/ && defined $usecase ){ $new = "index";$pdata{'new-menu'} = $usecase;$pdata{'changed'}.= "||new-menu";delete $pdata{'case'}; }
delete $pdata{'cache'};delete $pdata{'callback'};
if( !defined $pdata{'speed'} ){ $pdata{'speed'} = "html"; }
###admin_json_out({ 'check changeadddupepages' => "type:$type \nfullurl:$fullurl \nnew:$new \ncase:$usecase \nnf:$nf \n\n".Data::Dumper->Dump([\%pdata],["PDATA"])." \n\n $debug" },$origin,$callback); 
($nferr,$nf) = sub_admin_new($cht,$fullurl,$new,\%pdata,\%config);
if( $isdoc =~ /^($docview)/ && $isdoc ne "" ){ $isdoc =~ s/($nf)$//;$nf = $isdoc.$nf; }
###admin_json_out({ 'check changeadddupepages 1' => "type:$type \nfullurl:$fullurl \nnew:$new \nnf:$nf \n\n".Data::Dumper->Dump([\%pdata],["PDATA"])." \n\n $debug" },$origin,$callback);
if(defined $nferr ){
$cho = "Update Page</h3><h3 class=\"updateinfo\">Warning: problem with adding $cht $nf: $nferr = $debug";
} else {
$cho = "Updated Page</h3><h3 class=\"updateinfo\">".( ucfirst $cht )." <b>$nf<\/b> successfully ".( ($pdata{'url'} ne "")?"updated":"added" ).".";

if($type =~ /pages/){
$| = 1;
my $pid = fork;
sub_log_out({ 'check changeadddupe fork' => "failed to fork: $!\n\n $debug" },$base) unless defined $pid;
if($pid == fork){ #parent end
if($pdata{'speed'} eq "html"){
$uptxt =~ s/(<div class="text nav-box">\s*<a class=".*?">.*?<\/a>\s*<h3>).*?(<\/h3>\s*<\/div>)/$1$cho$2/;
admin_display_form($type,$uu,$uptxt,"prev",\%exclude,undef,undef,undef,$nf);
} else {
admin_json_out({ 'title' => $pdata{$pdata{'changed'}},'field' => $pdata{'changed'},'html' => admin_getpagefield( $pdata{'changed'},$pdata{$pdata{'changed'}},$pdata{'class'} ) },$origin,$callback);
}
} else { #child 
close (STDOUT);
my ($mlref,$cmref) = admin_reset_menus("resetmenupages","resetmenupages",$cc,{},"showall");
###admin_json_out({ 'check changeadddupepages 2' => "type:$type \nid:$id \nurl:$url \nfullurl:$fullurl \nnew:$new \n\ncm:\n\n [ @$cmref ] \n\n $debug" },$origin,$callback);
exit(0);
}
}

}
$pre = "prev";
#
} elsif( $type =~ /delete/ ){
my $cc = $url;$cc =~ s/^($base|$baseview)//;
%exclude = ( 'unadd' => 1,'unupload' => 1,'undownload' => 1 );
###admin_json_out({ 'check changedelete' => "type:$type \ncht: $cht \nfullurl:$fullurl \ndebug: $debug" },$origin,$callback);
$nferr = sub_admin_delete($cht,$fullurl,\%config);
if( !defined $nferr && $fullurl =~ /^(.+)\.($extlib)$/i ){ my $thm = $1."_thumb.jpg";if( -f $thm ){ $nferr = sub_admin_delete($cht,$thm,\%config); } }
($uu,$nf) = sub_admin_backlevel($cc,\%config);
if( defined $nferr ){
$cho = "Delete ".(ucfirst $cht)."</h3><h3 class=\"updateinfo\">Warning: problem with deleting $cht $fullurl: nferr:$nferr = $debug ";
} else {
$cho = "Delete ".(ucfirst $cht)."</h3><h3 class=\"updateinfo\">".( ucfirst $cht )." <b>$cc<\/b> successfully deleted. ";
if( $type =~ /pages/){ my ($mlref,$cmref) = admin_reset_menus("resetmenupages","resetmenupages",$cc,{},"showall","speed"); } else { my ($lerr,$m) = sub_libraryfile_update('editlibrary',$fullurl,\%config,'all');$cho.= $lerr if defined $lerr; }
}
$pre = "prev";
#
} elsif( $type =~ /(unlock|lock)/ ){
my $lok = $1;
$uf = $fullurl;$uf =~ s/^($base)//;
$oo = $uf;$oo =~ s/\.($htmlext)$//;
###admin_json_out({ 'check changelockpages' => "type:$type \nlok:$lok \nfullurl:$fullurl \nuf:$uf \noo:$oo.jpg \n\n $debug" },$origin,$callback);
$nferr = sub_admin_save_write($fullurl,$uf,\%config,undef,$oo,"$lok og");
###admin_json_out({ 'check changelockpages 1' => "nferr:$nferr \n\ntype:$type \nfullurl:$fullurl \nuf:$baseview$uf \noo:$base$oo.jpg \n\n $debug" },$origin,$callback);
$cho = ( defined $nferr )?"<span class=\"navtext failure\">Warning: problem with ".$lok."ing Page Thumbnail for $uf: $nferr = $debug</span>":"<span class=\"navtext success\">Successfully ".$lok."ed Page Thumbnail. </span>";
admin_json_out({ 'result' => "$cho",'restart' => 'yes' },$origin,$callback);
#
} elsif( $type =~ /image/ ){
$uf = $fullurl;$uf =~ s/^($base)//;
$oo = $uf;$oo =~ s/\.($htmlext)$//;
###admin_json_out({ 'check changeimagepages' => "type:$type \nfullurl:$fullurl \nuf:$uf \noo:$oo.jpg \n\n $debug" },$origin,$callback);
$nferr = sub_admin_save_write($fullurl,$uf,\%config,undef,$oo,"update og");
###admin_json_out({ 'check changeimagepages 1' => "nferr:$nferr \n\ntype:$type \nfullurl:$fullurl \nuf:$baseview$uf \noo:$base$oo.jpg \n\n $debug" },$origin,$callback);
$cho = ( defined $nferr )?"<span class=\"navtext failure\">Warning: problem with updating Page Thumbnail for $uf: $nferr = $debug</span>":"<span class=\"navtext success\">Successfully updated Page Thumbnail. </span><a class=\"imgpreview\" style=\"background-image:url($baseview$cssview$oo.jpg);\" href=\"$baseview$cssview$oo.jpg\" title=\"updated Page Thumbnail\" target=\"_blank\">&#160;</a>";
admin_json_out({ 'result' => "$cho",'restart' => 'yes' },$origin,$callback);
#
} elsif( $type =~ /rankpages/ ){
%exclude = ( 'unadd' => 1,'unupload' => 1,'undownload' => 1 );
###admin_json_out({ 'check changerankpages' => "type:$type \nfullurl:$fullurl \nnew:$new \n\n".Data::Dumper->Dump([\%pdata],["PDATA"])." \n\n $debug" },$origin,$callback);
@cm = sub_admin_rankpages($type,$url,$new,\%config);
$cho = "<span class=\"iheader\">Menu Reorder".( ($cm[1] =~ /warning/i)?" problem found.":" successful." )."</span></h3><h3 class=\"dropsub\">".sub_admin_dropsub($cm[1],0,"Info");
#
} elsif( $type =~ /restorepages/ ){
%exclude = ( 'unadd' => 1,'unreorder' => 1,'undownload' => 1 );
$uf = sub_get_unversion($fullurl,\%config);
###admin_json_out({ 'check changerestorepages' => "type:$type \nuf:$uf \nfullurl:$fullurl \nnf:$nf \n\n".Data::Dumper->Dump([\%pdata],["PDATA"])." \n\n $debug" },$origin,$callback);
my $rerr = sub_admin_copy('Page',$fullurl,$base.$uf,\%config,"overwrite");
$cho = ( defined $rerr )?"Warning: problem with restoring Page $uf: $rerr = $debug":"Restored Page <b>".sub_title_out($uf,\%config)."<\/b> successfully.";
#
} elsif( $type =~ /rename/ ){
$nf = sub_check_name($new,\%config);
if( $nf =~ /\.($htmlext)$/){
$nn = $base;$oo = "";if($fullurl eq $nn.$nf){ $cho = "Rename $cht <b>$fullurl</b> to <b>$nn$nf<\/b> not necessary (same name)."; }
} else {
if( $type =~ /files/ ){$fullurl = $base.$old;}$nn = $fullurl;$nn =~ s/\/$//;($nn,$oo) = sub_get_parent($nn);if($oo eq $nf){ $cho = "Rename $cht <b>$oo</b> to <b>$nf<\/b> not necessary (same name)."; } # nn: /var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/documents/Images/  oo: Test-Folder  nf: Test-Folder2
}

###admin_json_out({ 'check change rename' => "type:$type \nrename:$fullurl to $nn$nf \noo:$oo \ncho:$cho \n\n$debug" },$origin,$callback);
if( $cho !~ /[a-z]+/i ){
@cm = sub_admin_rename($cht,$fullurl,$nn,$nf,$oo,$regexp,$usecase,\%config);
###admin_json_out({ 'check changerename 1' => "type:$type \nfullurl:$fullurl \nnew:$new \nfind:$find \nreplace:$replace \nregex:$regexp \ncase:$usecase \n\n".Data::Dumper->Dump([\@cm],["cm"])."\n\n $debug" },$origin,$callback);
$cho = "@cm";
if( $oo =~ /^(.+)\.($extlib)$/i ){ my $too = $1."_thumb.jpg";my $tnf = $nf;$tnf =~ s/\.($extlib)$/_thumb.jpg/i;my @tcm = ();if( -f $nn.$too ){ @tcm = sub_admin_rename($cht,$nn.$too,$nn,$tnf,"",undef,undef,\%config);$debug.= "tcm:@tcm \n" } }
} else {
##admin_json_out({ 'check change rename 2' => "type:$type \nrename:$fullurl to $nn$nf \noo:$oo \ncho:$cho \n\n$debug" },$origin,$callback);
}
###admin_json_out({ 'check change rename 3' => "type:$type \nrename:$fullurl to $nn$nf \noo:$oo \ncho:$cho \n\n$debug" },$origin,$callback);
#
} elsif( $type =~ /search/ ){
%exclude = ( 'unadd' => 1,'unupload' => 1,'undownload' => 1 );
my $alt = ( $new eq "alter" || $replace ne "" )?'alter':undef;
my @flist = ( $fullurl );push @flist,@seclist;
@cm = sub_get_changed("all","search",\@flist,\%config,$find,$replace,$alt,$regexp,$code,$usecase,undef,undef);
###admin_json_out({ 'check changesearchfolders' => "type:$type \nfullurl:$fullurl \nnew:$new \nfind:$find \nreplace:$replace \nregex:$regexp \ncase:$usecase \n\n".Data::Dumper->Dump([\@cm],["cm"])."\n\n $debug" },$origin,$callback);
admin_json_out({ 'result' => "@cm" },$origin,$callback);
#
} elsif( $type =~ /subpages/ ){
%exclude = ( 'unadd' => 1,'unupload' => 1,'undownload' => 1 );
$uf = $fullurl;$uf =~ s/^($base)//;
$oo = $uf;$oo =~ s/\.($htmlext)$//;
$usecase =~ s/\.(00|0)$//;
###admin_json_out({ 'check changesubpages' => "type:$type \nfullurl:$fullurl \nuf:$uf \ncase:$usecase \n\n $debug" },$origin,$callback);
my $aerr = sub_admin_save_write($fullurl,$uf,\%config,undef,".000","update rank");
if( defined $aerr ){
$nferr = $aerr;
} else {
my $nold =  ( -f $base.$templateview.$oo.'-'.$deftemp )?$templateview.$oo.'-'.$deftemp:$templateview.$deftemp;
my $dot = ( $usecase =~ /^[0-9][0-9][0-9]\./ )?"":".";
###admin_json_out({ 'check changesubpages 1' => "cht:$cht \nfullurl:$fullurl \noo:$oo \nold:$nold \ndot:$dot \nuf:$baseview$uf  \n\n $debug" },$origin,$callback);
($nferr,$nf) = sub_admin_new($cht,$fullurl,'index',{ 'changed' => 'new-title||new-date||new-shortname||new-menu||new-linkurl','new-menu' => $usecase.$dot."001.00",'new-parent' => $oo.$delim,'url' => $uf,'new-menuurl' => 'Subpage 1','new-linkurl' => $oo.$delim.'Subpage-1.html','new-shortname' => 'Subpage 1','new-title' => 'Subpage 1','new-date' => sub_get_date($time,\%config,"/"),'old' => $nold,'type' => $type },\%config);
###admin_json_out({ 'check changesubpages 2' => "nferr:$nferr \n\ntype:$type \nfullurl:$fullurl \nuf:$baseview$uf  \n\n $debug" },$origin,$callback);
}
$cho = ( defined $nferr )?'<span class="navtext failure">Warning: problem with updating Page '.$uf.': '.$nferr.' = '.$debug.'</span>':'<span class="navtext success">View Subpages below this Page</span><a class="navblock nav-right" href="'.$pl.'type=viewpages&amp;url='. $uri->encode($uf).'" title="View Subpages below this Page">&#160;</a>';
admin_json_out({ 'result' => "$cho" },$origin,$callback);
#
} else {
#nowt
}

$uptxt =~ s/(<div class="text nav-box">\s*<a class=".*?">.*?<\/a>\s*<h3>).*?(<\/h3>\s*<\/div>)/$1$cho$2/;
admin_display_form($type,$uu,$uptxt,$pre,\%exclude,undef,undef,undef,$nf);

} elsif( $type eq "editblocks" ){
#admin/libraryadmin.pl?type=editblocks&url=Solutions.html&id=1523887523
my $edas = "[ ";foreach my $ar( sort keys %editareas ){ if( $editareas{$ar} > 1 ){ $edas.= "'$ar',"; } }$edas =~ s/,$/ \]/;
admin_get_pageedit($fullurl,$id,$edas,$configjs,$addjs);

} elsif( $type eq "editpages" ){
#admin/libraryadmin.pl?type=editpages&url=Site-Map.html documents%2FTemplates-and-Guides%2FNews-Default-Page-Template.htm
my $tmp = $url;$tmp =~ s/^($base|$baseview)//;
my $eu = $tmp;$tmp =~ s/\.($htmlext)$//;if( $tmp =~ /$qqdelim/ ){ my ($uu,$uf) = sub_admin_backlevel($eu,\%config);$eu = "&amp;url=".( $uri->encode($uu) ); } else { $eu = ""; } ##==pilbeam
my $etxt = admin_html_in($base.$adminbase.$dest);
my ($prerr,$prref) = sub_page_return($type,[$fullurl],\%config);
admin_json_out({ 'error' => "editpages: fullurl: $fullurl \ntype:$type \nprerr: $prerr \n\n".Data::Dumper->Dump([$prref],["prref"])."\n\n $debug" },$origin,$callback) if defined $prerr;
my @etmp = @{$prref};
my $etxt = admin_display_pageedit($url,$fullurl,$etxt,$dlevel,$eu,\%{ $etmp[0]{'data'} });
if( $etxt =~ /header[0-9] hidepage" data-menu=".*?\.(0|00)">/ ){ my $s = ($1 eq "00")?'hidemappage':'hidepage';$etxt =~ s/class="sendable"/class="sendable $s"/; } #"
###admin_json_out({ 'check editpages' => "fullurl: $fullurl \ntype:$type \ner: etxt: $etxt\n\n".Data::Dumper->Dump([\@etmp],["etmp"])."\n\n $debug" },$origin,$callback);
admin_html_out($etxt);

} elsif( $type =~ /^hide(map|folder)*pages$/ || $type =~ /^show(map|folder)*pages$/ ){
#admin/libraryadmin.pl?type=showpages&url=New-Page&new=hidden
#admin/libraryadmin.pl?type=hidepages&url=New-Page&new=shown
#admin/libraryadmin.pl?type=showmappages&url=New-Page&new=hidden
#admin/libraryadmin.pl?type=hidemappages&url=New-Page.html&new=shown
#admin/libraryadmin.pl?type=hidefolderpages&url=New-Page.html&new=shown
#admin/libraryadmin.pl?type=showpages&url=New-Page&new=hidden&id=edit
#admin/libraryadmin.pl?type=hidemappages&url=New-Page.html&new=shown&id=edit
my $upf = $url;$upf =~ s/^($baseview|$base)//;
###admin_json_out({ 'check hideshowpages' => "type:$type \nurl:$url \nfullurl:$fullurl \nnew:$new \n\n $debug" },$origin,$callback);

my $su = "";
if($type eq "showmappages"){
$su = ".0"; # hidden hidden -> site=show/menu=hidden
} elsif($type eq "hidemappages"){
$su = ".00"; # show show -> site=hidden/menu=hidden OR show hidden -> site=hidden/menu=hidden
} elsif($type eq "hidepages" || $type eq "hidefolderpages"){
$su = ".0"; # show show -> site=show/menu=hidden
} else { 
# hidden hidden -> site=show/menu=show OR show hidden = site=show/menu=show
}
###admin_json_out({ 'check hideshowpages 2' => "type:$type \nsu:$su \nid:$id \nurl:$url \nfullurl:$fullurl \nnew:$new \n\ncm:\n\n $debug" },$origin,$callback);

$| = 1;
my $pid = fork;
sub_log_out({ 'check hideshowpages fork' => "failed to fork: $!\n\n $debug" },$base) unless defined $pid;
if ($pid == fork){ #parent end
my $hclass = ( $su =~ /\.(0|00)$/ )?'mhide':'show';
my $mclass = ( $su =~ /\.00$/ )?'mhide':'show';
my $htclass = ($hclass eq "mhide")?'hidden':'shown';
my $mtclass = ($mclass eq "mhide")?'hidden':'shown';
my $hurl = $url;$hurl =~ s/^($baseview)//;
admin_json_out({ 'label' => 'Page is '.( ucfirst($mtclass) ).' in Sitemap and '.( ucfirst($htclass) ).' in Menus','menu' => $su,'html' => ( admin_getpagemap( ($type =~ /folder/)?"folder":"page",$pdata{'speed'},$uri->encode($hurl),($hclass eq "mhide")?'show':'hide',($mclass eq "mhide")?'show':'hide',$htclass,$mtclass,"nowrap") ) },$origin,$callback);
} else { #child 
close (STDOUT);
my ($mlref,$cmref) = admin_reset_menus($type,$type,$upf,{ "$upf" => $su });
###admin_json_out({ 'check hideshowpages 3' => "type:$type \nid:$id \nurl:$url \nfullurl:$fullurl \nnew:$new \n\ncm:\n\n [ @$cmref ] \n\n $debug" },$origin,$callback);
exit(0);
}

} elsif( $type eq "listmenupages"  || $type eq "newlinkpages" || $type eq "newmenupages" || $type eq "newtitlepages" || $type eq "resetmenupages" ){
#admin/libraryadmin.pl?type=listmenupages
#admin/libraryadmin.pl?type=newlinkpages&new=Mainframe-Services_Performance-Assurance.html&old=index.html&url=Mainframe-Services_Performance-Assurance.html
#admin/libraryadmin.pl?type=newmenupages&new=001.001&old=000.0&url=Mainframe-Services_Performance-Assurance.html&id=update
#admin/libraryadmin.pl?type:newtitlepages type	"newtitlepages" url "index.html" old	 "Making mainframes work harder and more securely" new "Helping you make the most of your mainframe environment"
#admin/libraryadmin.pl?type=resetmenupages
admin_menu_tools($type,$fullurl);

} elsif( $type eq "uploadfolders" ){
#admin/libraryadmin.pl?type=uploadfolders&url=documents%2FDigital%2FPosters%2FTest-Poster%2F
my $loadtxt = admin_html_in($base.$adminbase.$dest);
my %exclude = ( 'unadd' => 1,'unupload' => 1 );
admin_display_form($type,$url,$loadtxt,undef,\%exclude);

} elsif( $type eq "uploadsite" ){
#admin/libraryadmin.pl?type=uploadsite&url=
my $loadtxt = admin_html_in($base.$adminbase.$dest);
my %exclude = ( 'unadd' => 1,'unupload' => 1 );
admin_display_form($type,$url,$loadtxt,undef,\%exclude);

} elsif( $type =~ /^used/ ){ 
#admin/libraryadmin.pl?type=usedfiles&url=documents%2FImages%2Fnews%2FRSM__header.jpg
my ($upgs) = sub_get_usedpages($fullurl,'links',\%config);
###admin_json_out({ 'check get_used' => "type:$type \nurl:$url \nfullurl:$fullurl \nupgs:$upgs\n\n $debug" },$origin,$callback);
admin_json_out({ 'result' => $upgs },$origin,$callback);

} else {
admin_json_out({ 'error' => "server received unknown instruction: [ $type ] $debug" },$origin,$callback);
}

admin_json_out({ 'check main 2: default' => "$debug \nid: $id \ntype: $type \nfullurl: $fullurl \nbase:$base \nnwbase:$nwbase \nobase: $obase \nsubdir: $subdir \nbaseview:$baseview \ndest: $dest pages:$pages dlevel:$dlevel \nfxfile:$fxfile \norigin: $origin" },$origin,$callback);
exit;

################


sub admin_imagesize{
my ($f) = @_; #/var/www/vhosts/pecreative.co.uk/revive.pecreative.co.uk/documents/Images/products/uncoated/
my $s = undef;
foreach my $k( sort keys %imgsizes){
my @v = @{ $imgsizes{$k} };
if( defined $v[0] && defined $v[1] && $f =~ /^($base)($v[0])/ ){ $s = $v[1]; } #'Product Image' => ["documents/Images/products/","Product Image,_product,300,300"],
}
return $s;
}

sub admin_display_config{
my ($ty,$fu) = @_;
my $lstxt = admin_html_in($base.$adminbase."updateconfig.".$htmlext);
my $smtxt = admin_html_in($base.$site_file);
my $uf = $fu;$uf =~ s/^($base)//;
my $ntxt = "";
my $ctxt = "";
my $num = 0;
my $jsref = {};
my $cssref = {};
my $dbug = "";
###admin_json_out({ 'check displayconfig' => "ty:$ty \nfu:$fu \nid:$id \n\n".Data::Dumper->Dump([\%pdata],["PDATA"])." \n\n $debug" },$origin,$callback);

if( scalar keys %defsections > 0 ){
my %m = ();
my @find = ();
my @rep = ();
$ntxt.= '<div class="text nonmenufolder pages"><h2><input id="used1_0" name="used1_0" type="checkbox" /><label for="used1_0" class="tt_tabclick navblock nav-edit editsection" tabindex="0" title="edit Site Global Sections">Edit Site Global Sections</label><span class="dropspacer">&#160;</span>';
foreach my $k(keys %defsections){
my $n = lc $k;$n =~ s/\s+/-/g;
my $sm = '';
my $r = @{ $defsections{$k} }[1];if(defined $r && $smtxt =~ /$r/ism ){ $sm = $1; }
$ntxt.= '<span class="inputline unsearch globals"><div class="tt_progress"><span class="bar"></span></div><label for="new-'.$n.'_0" tabindex="0">'.$k.':</label><textarea class="gsection" id="new-'.$n.'_0" name="opt_new-'.$n.'_0" tabindex="0">'.$sm.'</textarea><a id="mlist_'.$n.'_0" class="mlist-submit gsection" title="update Global Section">Update '.$k.'</a><span class="tt_expander">&#8675;</span></span>';
}
$ntxt.= '</h2></div>';
}
my ($rref,$rtxt) = admin_get_allclips('list',$fullurl."Clipboard",['edittext','grid','section']);
###admin_json_out({ 'check displayconfig' => "rtxt:$rtxt \n\n".Data::Dumper->Dump([$rref],["rref"])." \n\n $debug" },$origin,$callback);
$ntxt.= $rtxt;

$lstxt =~ s/(<div class="text gsections"><\/div>)/$ntxt/; #$lstxt =~ s/(<div class="text nav-box">\s*<a class=".*?">.*?<\/a>\s*<h3>).*?(<\/h3>\s*<\/div>)/$1Admin Menu Tools$2$kk$ml/;

($num,$jsref,$cssref) = admin_get_js($base);
###admin_json_out({ 'check displayconfig 1' => "num:$num \n\n".Data::Dumper->Dump([$jsref],["jsref"])." \n\n $debug" },$origin,$callback);
if( $num < 1 ){
$ctxt = '<div class="text nonmenufolder pages"><h2><span class="navblock nav-compress uncompress">&#160;</span><span class="navtext">Compress JS/CSS files</span></h2></div>';
} else {
$ctxt = '<div class="text nonmenufolder pages"><div class="tt_progress"><span class="bar"></span></div><h2><a class="navblock tt_directupdate nav-compress" href="../cgi-bin/admin/libraryadmin.pl?type=compressfiles" title="compress JS and CSS files">&#160;</a><a class="navtext tt_directupdate" href="../cgi-bin/admin/libraryadmin.pl?type=compressfiles" title="compress JS and CSS files">Compress JS/CSS files</a></h2></div>';
$ctxt.= '<div class="text nonmenufolder pages"><div class="tt_progress"><span class="bar"></span></div><h2><a class="navblock tt_directupdate nav-expand" href="../cgi-bin/admin/libraryadmin.pl?type=uncompressfiles" title="uncompress JS and CSS files">&#160;</a><a class="navtext tt_directupdate" href="../cgi-bin/admin/libraryadmin.pl?type=uncompressfiles" title="uncompress JS and CSS files">Uncompress JS/CSS files</a></h2></div>';
}
$lstxt =~ s/(<div class="text compressfiles"><\/div>)/$ctxt/;
admin_html_out($lstxt);
}

sub admin_display_download{
my ($u) = @_;
my $s = "";
my $c = 0;
my $err = undef;
my $fu = ( $u eq $base )?$base.$docview:$u;

my ($cterr,$ctref) = sub_get_all($fu,"viewdownload",\%config); # 'folders' => { 'Digital' => { 'Flyers' => { 'payslip-flyer' => { 'Screen' => {},'Print' => {} } } } }
admin_json_out({ 'error' => "alert: no useable data retrievable by server: $cterr $debug" },$origin,$callback) unless defined $ctref && defined $ctref->{'folders'} && !defined $cterr;
my %ct = %{$ctref->{'folders'}};
my %fct = %{$ctref->{'files'}};

my @keys = sort keys %ct;
if( defined $documents && defined $pages ){ unshift @keys,'Site Pages'; }
for my $i(0..$#keys){
my $fd = 'folders&amp;url='.$uri->encode($docview.$keys[$i]);if( $i < 1 && $keys[$i] eq "Pages" ){ $fd = 'pages'; }
$s.= '<div class="gridrow'.( ($fd eq "pages")?$fd:"" ).'"><div class="text check"><h3 class="checktext"><a href="'.$pl.'type=view'.$fd.'" title="view contents" target="_blank">'.$keys[$i].'</a></h3><input type="checkbox" id="checkfile'.$c.'_0" name="opt_checkfile'.$c.'_0" value="'.$keys[$i].'" checked="checked" /><label for="checkfile'.$c.'_0" class="css-check" tabindex="0">&#160;</label></div></div>';
$c++;
}

my @fkeys = sort keys %fct;
for my $i(0..$#fkeys){
my $fd = 'files&amp;url='.$uri->encode($fkeys[$i]);
my $ou = $fkeys[$i];$ou =~ s/^(.+)\///;
$s.= '<div class="gridrow"><div class="text check"><h3 class="checktext"><a href="'.$pl.'type=view'.$fd.'" title="view '.$ou.'" target="_blank">'.$ou.'</a></h3><input type="checkbox" id="checkfile'.$c.'_0" name="opt_checkfile'.$c.'_0" value="'.$ou.'" checked="checked" /><label for="checkfile'.$c.'_0" class="css-check" tabindex="0">&#160;</label></div></div>';
$c++;
}

###admin_json_out({ 'check downloadlist' => "fu: $fu \nu:$u \ns:$s \n\n ".Data::Dumper->Dump([\%ct],["ct"])." \n\n $debug" },$origin,$callback);
return $s;
}

sub admin_display_form{
my ($ins,$u,$uptxt,$prev,$exref,$wref,$subs,$als,$nurl) = @_;
my @warn = (defined $wref)?@{$wref}:();
my $uph = "";
my $upf = $u;$upf =~ s/^($baseview|$base)//;$upf =~ s/($liblister)$//;
my $ispf = (defined $subs && $subs > 0)?" and its $subs Subpage".(($subs > 1)?'s':''):"";$ispf.= (defined $als && $als > 0)?" and $als Alias".(($als > 1)?'es':''):"";
my $nup = "";my $nfu = undef;if( $ins eq "deletepages" || $ins =~ /change(delete|library|rename)(files|pages)/ ){ $nup = $upf; } elsif( $ins =~ /changedeletefolders/ || (defined $prev && $ispf ne "") ){ ($nup,$nfu) = sub_admin_backlevel($upf,\%config); } elsif( $ins =~ /restore/ ){ $nup = sub_get_unversion($upf,\%config); } elsif( defined $nurl ){ $nup = $nurl; } else { $nup = $upf; }$nup =~ s/^($base)//;
my $archive = undef;if( $u =~ /($docview)archive\//i ){ $archive = 1;$nup =~ s/\/.*?\.($htmlext)$/\//; }
my $upbackurl = $pl."type=".( ($ins eq "changedeletepages" && $ispf eq "")?'view':($ins =~ /change(add|image|save)pages$/)?'edit':'view' );
$upbackurl.= ( (defined $archive)?'folders':($ins =~ /section/)?'configpages':($ins =~ /restore/)?'versionpages':( $upf =~ /\.($htmlext)$/i || $ins =~ /change(add|delete|rank)pages/ || $ins eq "reorderpages" )?'pages':'folders' )."".( ($nup ne "")?'&amp;url='.$uri->encode($nup):'' );

my $ujs = "<script type=\"application\/javascript\">Object.append(E,{ 'cfg':{ 'docfolder':'".$docview."','imgfolder':'".$imagefolder."/','upfolder':'".$upf."' } });</script>\n";
$uptxt =~ s/(<script charset="utf-8" src="admin\/su.js" type="application\/javascript"><\/script>)/$1$ujs/;

if( $uptxt =~ /<div class="area setheaderarea"><\/div>/ ){ $uph = admin_set_headers( $uph,$dlevel,1,$upf,(($ins =~ /pages$/ && $ins !~ /library/) || $ins =~ /^reorder/)?"pages":undef,$exref,undef,undef,undef,$archive);$uptxt =~ s/<div class="area setheaderarea"><\/div>/$uph/; }

if( $ins eq "deletefiles" ){ $upf = $nurl; }
$uptxt =~ s/(<b class="default-folder">).*?(<\/b>)/$1$upf$2$ispf/;
$uptxt =~ s/(name="opt_url_[0-9]+" value=").*?(")/$1$upf$2/;
$uptxt =~ s/(<a class="navblock nav-return"\s*href=").*?(")/$1$upbackurl$2/g;

if( $ins =~ /^rename/ ){ my $nn = ( $ins eq "renamefiles")?$nurl:$upf;$nn =~ s/\/$//;$nn =~ s/^.+\///;$uptxt =~ s/(name="pre_new_[0-9]+" value=").*?(")/$1$nn$2/;if( $ins eq "renamefiles" ){ $uptxt =~ s/(name="opt_old_[0-9]+" value=").*?(")/$1$nurl$2/; } }
if( $ins =~ /^download/ ){ my $dd = admin_display_download($base.$upf);$uptxt =~ s/<div class="text setdownloadarea"><\/div>/$dd/;my $rr = admin_restore("list",[]);$uptxt =~ s/<div class="text setrestorearea">(.*?)<\/div>/$rr/; }
if( $ins =~ /^reorder/ ){ my $dd = admin_display_reorder($base);$uptxt =~ s/<div class="text setreorderarea"><\/div>/$dd/; }

if( $ins ne "uploadsite" && $uptxt =~ /<div class="tt_uploadsizer.*?"><\/div>/ ){
my $sizer = admin_generate_sizes(\%imgsizes,$docview.$imagefolder.$upf);$sizer.= $inputinfo{'sizer'};
$uptxt =~ s/(<div class="tt_uploadsizer.*?">)(<\/div>)/$1$sizer$2/;
if( defined $new && $new =~ /\.($extset)$/i ){ $uptxt =~ s/(name="new_[0-9]+" value=").*?(")/$1$new$2/; }
}

if( scalar @warn > 0 ){ $uptxt =~ s/(<div class="text infotext)(">)(.*?)(<\/div>)/$1 warnings$2<h4>$warn[0]<\/h4><p>$warn[1]<\/p>$4/; }

###admin_json_out({ 'check result_out' => "ins:$ins \nu:$u \nnurl:$nurl \nnup:$nup \nupf:$upf \nupbackurl:$upbackurl \n\nuptxt:$uptxt \ndlevel:$dlevel= $debug" },$origin,$callback);
admin_html_out($uptxt);
}

sub admin_display_library{
my ($ty,$f) = @_;
my $upf = $f;$upf =~ s/^($base)//;
my %im = ();
my $uph = admin_set_headers("",$dlevel,1,$upf,undef,{},undef,undef,undef,'library');
my $upbackurl = $pl."type=viewfolders&url=".$uri->encode($upf);
my $uptxt = admin_html_in($base.$adminbase.'editlibrary.'.$htmlext);
my $ntxt = "";
my $ltxt = "";
my $err = undef;

($err,$ltxt) = sub_libraryfile_update("editlibrary",$f,\%config,'all');
admin_json_out({ 'error' => "displaylibrary: fullurl: $fullurl \nty:$ty \nerr: $err \n $debug" },$origin,$callback) if defined $err;
###admin_json_out({ 'check displaylibrary' => "f: $f \nltxt: $ltxt\n\n err:$err \n$debug" },$origin,$callback);
$ntxt = '<div class="inputline unsearch globals libraryfiles"><div class="tt_progress"><span class="bar"></span></div><textarea class="glibrary" id="new-libraryfile_0" name="opt_new-libraryfile_0" tabindex="0">'.$ltxt.'</textarea><a id="mlist_libraryfile_0" class="mlist-submit glibrary" title="update Library file">Update Library File</a> <a id="refresh_libraryfile_0" class="mlist-submit refresh glibrary" title="refresh Library file">Refresh Library File</a><input id="url_0" name="opt_url_0" value="'.$upf.'" type="hidden" /></div>';

$uptxt =~ s/<div class="area setheaderarea"><\/div>/$uph/;
$uptxt =~ s/(name="opt_url_[0-9]+" value=").*?(")/$1$upf$2/;
$uptxt =~ s/(<a class="navblock nav-return"\s*href=").*?(")/$1$upbackurl$2/g;
$uptxt =~ s/(<div class="text gsections"><\/div>)/$ntxt/;

###admin_json_out({ 'check displaylibrary 1' => "f: $f \nupbackurl: $upbackurl \n uptxt:$uptxt \n\n $debug" },$origin,$callback);
admin_html_out($uptxt);
}

sub admin_display_pageadd{
my ($ty,$u) = @_;
my $uptxt = admin_html_in($base.$adminbase.$dest);
my $uph = "";
my $upf = $u;$upf =~ s/^($base)//;
my $ub = sub_admin_getmenu($u,\%config);
my $pp = "Site";if($upf ne ""){$pp = $upf;$pp =~ s/\.($htmlext)$//;$pp =~ s/($qqdelim).+$//;}
my $upd = ($upf eq "")?"this Site":$upf;$upd =~ s/\.($htmlext)$//;
my $par = $upf;if($par ne ""){ $par =~ s/\.($htmlext)$//;$par.= $delim; }
my $nup = "";my $nfu = undef;if( $upf ne "" ){ ($nup,$nfu) = sub_admin_backlevel($upf,\%config);$nup = "&amp;url=".$uri->encode($nup); }
my $upbackurl = $pl."type=viewpages".$nup;
my $pty = "";
my @ps = ();
my @pt = ();
my @s = ();
my $ntxt = "";
my $ic = "pass";
my $c = 5;

my ($prerr,$prref)= sub_page_return("pagelist",[$base],\%config);
admin_json_out({ 'error' => "pageadd: u: $u \nty:$ty \nprerr: $prerr \n\n".Data::Dumper->Dump([$prref],["prref"])."\n\n $debug" },$origin,$callback) if defined $prerr;
my @ptmp = @{ sub_get_subpages($prref) };
my @temps = sub_get_html($base.$templateview,\%config);
if( -f $base.$templateview.$pp.'-'.$deftemp ){
push @ps,[ '_select_group_','Templates:' ];
push @ps,[ "$pp Default Page Template",$templateview.$pp.'-'.$deftemp ]; 
} else {
push @ps,[ '_select_group_','Templates:' ];
foreach my $t( sort {$a cmp $b} @temps ){ $t =~ s/^($base)//;if( $t =~ /Default-Page-Template\.($htmlext)$/ ){ push @ps,[ sub_title_out($t,\%config),$t ]; } }
}
push @ps,['_select_group_',"$pp Pages:"];
foreach my $ptmp ( sort { $a->{'data'}->{'menu'}[0] <=> $b->{'data'}->{'menu'}[0] } @ptmp ){ 
if( $par eq "" || $ptmp->{'data'}->{'url'}[0] =~ /^($par)/ ){
my $tmp = $ptmp->{'data'}->{'url'}[0];$tmp =~ s/\.($htmlext)$//;
my @c = $tmp =~ /($qqdelim)/g;push @ps,[ ("-&#160;" x scalar @c).$ptmp->{'data'}->{'title'}[0],$ptmp->{'data'}->{'url'}[0] ];
} 
}
###admin_json_out({ 'check pageadd' => "u: $u \nupf: $upf (ibefore)\n \npar:$par (inewurl) \n [ ".$base.$templateview.$pp."-".$deftemp.".".$htmlext." ] \npp: $pp \n\n ".Data::Dumper->Dump([\@ps],["ps"])." \n\n ".Data::Dumper->Dump([\@ptmp],["ptmp"])."\n\n $debug" },$origin,$callback);
@s = sub_admin_chooser($u,\%config,\@ps);

$uph = admin_set_headers( $uph,$dlevel,1,$upf ,"pages",{} );

$ntxt.= '<div class="infoline inputline">An asterisk ( <b class="red">*</b> ) indicates required fields.</div><div class="inputline"><label for="new-title_0"><span class="numeral">1</span> Page Title: <span class="red">*</span></label><textarea id="new-title_0" name="pre_new-title_0" tabindex="0" maxlength="150" placeholder="New Page Title"></textarea></div>'.$inputinfo{'title'}.'<div class="upperline inputline">&#160;</div>';
$ntxt.= '<div class="inputline oneline"><label for="new-url_0"><span class="numeral">2</span> Page URL: </label><i class="ibefore'.( ($upf eq "")?' tt_undisplay':'' ).'">'.$par.'</i><i class="inewurl">New-Menu-Title</i><i class="iafter">.'.$htmlext.'</i></span></div>';
$ntxt.= '<div class="inputline inewurl oneline"><label for="new-menuurl_0">Title Shown in Menus: <span class="red">*</span></label>'.( ($upf ne "")?'<input type="hidden" name="opt_new-parent_0" value="'.$par.'" />':'' ).'<input id="new-menuurl_0" class="filterselect" name="pre_new-menuurl_0" tabindex="0" maxlength="50" type="text" placeholder="New Menu Title" value="" /></div>'.$inputinfo{'menu'}.'<div class="lowerline inputline">&#160;</div>';
$ntxt.= '<div class="inputline"><label for="new-name_0"><span class="numeral">3</span> Page Short Title: <span class="red">*</span></label><input id="new-shortname_0" name="pre_new-shortname_0" tabindex="0" maxlength="30" type="text" placeholder="Short Title" value="" /></div>'.$inputinfo{'short'}.'<div class="lowerline inputline">&#160;</div>';

$ntxt.= '<div class="titleline inputline">Optional Configuration</div><div class="inputline"><label for="old_0">Base Page'.$pty.' on:</label><select class="filtersource tt_unchange" id="old_0" name="opt_old_0" tabindex="0">'.( join "",@s ).'</select></div>';

$ntxt.= '<div class="inputline dropsub"><h2><input id="used1_0" name="used1_0" type="checkbox" /><label for="used1_0" class="tt_tabclick navblock nav-edit editseo" tabindex="0" title="edit Page SEO Data">Page SEO Data</label><span class="dropspacer">&#160;</span>';
foreach my $hr( sort keys %headers ){
my $vh = $hr;$vh =~ s/([\w']+)/\u\L$1/g; #'
my $vt = (defined $headers{$hr} && defined $headers{$hr}[2])?$headers{$hr}[2]:"";
$ntxt.= '<div class="inputline"><label for="new-'.$hr.'_0">'.( (defined $headers{$hr} && defined $headers{$hr}[3])?$headers{$hr}[3]:$vh ).':</label>';
$ntxt.= ( $hr =~ /^(description|keywords)$/ )?'<textarea  id="new-'.$hr.'_0" name="pre_new-'.$hr.'_0" tabindex="0" maxlength="300">'.$vt.'</textarea>':'<input id="new-'.$hr.'_0" name="pre_new-'.$hr.'_0" tabindex="0" type="text" value="'.$vt.'" maxlength="300" />';
$ntxt.= '</div>';
$c++;
}
$ntxt.= $inputinfo{'seo'}.'</h2></div>';

$ntxt.= '<div class="inputline dropsub"><h2><input id="used2_0" name="used2_0" type="checkbox" /><label for="used2_0" class="tt_tabclick navblock nav-edit edittags" tabindex="0" title="edit Page Tag Data">Page Tag Data</label><span class="dropspacer">&#160;</span>';
foreach my $ar( sort keys %editareas ){
my $vr = $ar;$vr =~ s/([\w']+)/\u\L$1/g; #'#if($vr eq "name"){ $vr = "Short Title"; } else {  }
my $ev = "";my $dc = "";if( $ar eq "date" ){ $ev = sub_get_date($time,\%config,"/");$dc = " undate"; }
if( $editareas{$ar} > 1 ){ $ntxt.= '<div class="inputline'.$dc.'"><label for="new-'.$ar.'_0">Page '.$vr.':</label><input id="new-'.$ar.'_0" name="opt_new-'.$ar.'_0" tabindex="0" type="text" value="'.$ev.'" /></div>';$c++; }
}
$ntxt.= $inputinfo{'tags'}.'</h2></div>';

$ntxt.= '<div class="inputline dropsub"><h2><input id="used3_0" name="used3_0" type="checkbox" /><label for="used3_0" class="tt_tabclick navblock nav-edit editalias" tabindex="0" title="edit external link">Make Page into an Alias</label><span class="dropspacer">&#160;</span>';
$ntxt.= '<div class="inputline unurl"><label for="new-link_0">Alias Link: </label><input id="new-link_0" name="opt_new-link_0" tabindex="0" maxlength="120" type="text" value="" /></div>'.$inputinfo{'alias'};
$ntxt.= '</h2></div><input id="case_0" name="opt_case_0" value="'.$ub.'" type="hidden">';

$uptxt =~ s/<div class="area setheaderarea"><\/div>/$uph/;
$uptxt =~ s/(<b class="default-folder">).*?(<\/b>)/$1$upd$2/;
#$uptxt =~ s/(name="opt_url_[0-9]+" value=").*?(")/$1$upf$2/;
$uptxt =~ s/(<a class="navblock nav-return"\s*href=").*?(")/$1$upbackurl$2/g;
$uptxt =~ s/(<div class="inputline"><\/div>)/$ntxt/;

###admin_json_out({ 'check pageadd' => " s: [ @s ] \n\nu: $u \nupf: $upf \n\n ".Data::Dumper->Dump([\@ps],["ps"])." \n\n ".Data::Dumper->Dump([\@ptmp],["ptmp"])."\n\n uptxt:$uptxt \n\n $debug" },$origin,$callback);
admin_html_out($uptxt);
}

sub admin_display_pagearchive{
my ($ty,$u) = @_;
my $uptxt = admin_html_in($base.$adminbase.$dest);
my $uph = "";
my $upf = $u;$upf =~ s/^($base)//;
my $ub = sub_admin_getmenu($u,\%config);
my $upd = ($upf eq "")?"this Site":$upf;$upd =~ s/\.($htmlext)$//;
my $nup = "";my $nfu = undef;
if( $upf ne "" ){ ($nup,$nfu) = sub_admin_backlevel($upf,\%config); }
my $upbackurl = $pl."type=viewpages".$nup;
my @ps = ();
my @s = ();
my $ntxt = "";

my ($prerr,$prref) = sub_page_return("editpages",[$u],\%config);
admin_json_out({ 'error' => "pagedupe: fullurl: $fullurl \ntype:$type \nprerr: $prerr \n\n".Data::Dumper->Dump([$prref],["prref"])."\n\n $debug" },$origin,$callback) if defined $prerr;
my @etmp = @{$prref};
my %edata = %{ $etmp[0]{'data'} };

my ($ferr,$fref) = sub_files_return("viewfiles",$base.$docview."Archive/",\%config,"all");
admin_json_out({ 'error' => "alert: no useable data retrievable by server: $ferr $debug" },$origin,$callback) unless defined $fref && !defined $ferr;
my %im = %{ $fref->{'folders'} }; # $im{'folders'} => { 'Group-News' => { '2017' => {},'2015' => {} } }
###admin_json_out({ 'check pagearchive' => "".Data::Dumper->Dump([\%im],["im"])."\n\n $debug" },$origin,$callback);

push @ps,[ 'Archive:',"documents/Archive/" ];
foreach my $k( sort keys %im ){
push @ps,[ '_select_group_',"$k:" ];
my %f1 = %{ $im{$k} };foreach my $k1( sort keys %f1 ){ push @ps,[ $k1,"documents/Archive/$k/$k1/" ]; }
}
@s = sub_admin_chooser($u,\%config,\@ps);
###admin_json_out({ 'check pagearchive 1' => " s: [ @s ] \n\nu: $u \nupf: $upf \n\n ".Data::Dumper->Dump([\%edata],["edata"])." \n\n $debug" },$origin,$callback);

$uph = admin_set_headers( $uph,$dlevel,1,$upf ,"pages",{} );

$ntxt.= '<div class="infoline inputline">An asterisk ( <b class="red">*</b> ) indicates required fields.</div><div class="inputline"><label for="old_0"><span class="numeral">1</span> Add Page beneath: <span class="red">*</span></label><select id="old_0" name="pre_old_0" tabindex="0">'.( join "",@s ).'</select></div><div class="lowerline inputline">&#160;</div>';
$ntxt.= '</div><input id="case_0" name="opt_case_0" value="'.$ub.'" type="hidden">';

$uptxt =~ s/<div class="area setheaderarea"><\/div>/$uph/;
$uptxt =~ s/(<b class="default-folder">).*?(<\/b>)/$1$upd$2/;
$uptxt =~ s/(name="opt_url_[0-9]+" value=").*?(")/$1$upf$2/;
$uptxt =~ s/(<a class="navblock nav-return"\s*href=").*?(")/$1$upbackurl$2/g;
$uptxt =~ s/(<div class="inputline"><\/div>)/$ntxt/;

###admin_json_out({ 'check pagearchive' => " s: [ @s ] \n\nu: $u \nupf: $upf \n\n ".Data::Dumper->Dump([\@ps],["ps"])." \n\n ".Data::Dumper->Dump([\@ptmp],["ptmp"])."\n\n uptxt:$uptxt \n\n $debug" },$origin,$callback);
admin_html_out($uptxt);
}

sub admin_display_pagedupe{
my ($ty,$u) = @_;
my $uptxt = admin_html_in($base.$adminbase.$dest);
my $uph = "";
my $upf = $u;$upf =~ s/^($base)//;
my $ub = sub_admin_getmenu($u,\%config);
my $pp = "Site";if($upf ne ""){$pp = $upf;$pp =~ s/\.($htmlext)$//;$pp =~ s/^.+($qqdelim)//;}
my $upd = ($upf eq "")?"this Site":$upf;$upd =~ s/\.($htmlext)$//;
my $nup = "";my $nfu = undef;
if( $upf ne "" ){ ($nup,$nfu) = sub_admin_backlevel($upf,\%config); }
my $upbackurl = $pl."type=viewpages".$nup;
my $pty = "";
my @ps = ();
my @pt = ();
my @s = ();
my $ntxt = "";
my $ic = "pass";
my $c = 5;

my ($prerr,$prref) = sub_page_return("editpages",[$u],\%config);
admin_json_out({ 'error' => "pagedupe: fullurl: $fullurl \ntype:$type \nprerr: $prerr \n\n".Data::Dumper->Dump([$prref],["prref"])."\n\n $debug" },$origin,$callback) if defined $prerr;
my @etmp = @{$prref};
my %edata = %{ $etmp[0]{'data'} };
my $mpar = "";
my $par = "";
my $tmp = $edata{'url'}->[0];$tmp =~ s/^($base|$baseview)//;$tmp =~ s/\.($htmlext)$//;if( $tmp =~ /($qqdelim)/ ){ $par = $tmp;$par =~ s/^(.+)$qqdelim(.*?)$/$1/;$mpar = $par.".$htmlext";$par.= $delim; } ##==pilbeam
#upf: Modules.Counter-Module.html 
#par: Modules (ibefore) 
#inewurl: 002.001 (inewurl)
###admin_json_out({ 'check pagedupe' => " s: [ @s ] \n\nu: $u \nupf: $upf \npar: $par (ibefore) \ninewurl: ".$edata{'menu'}->[0]." (inewurl)\n\n ".Data::Dumper->Dump([\@etmp],["etmp"])." \n\n $debug" },$origin,$callback);

push @ps,[ '_select_group_','Sections:' ];
push @ps,[ $mpar,$par ];
my @htm = sub_get_html($base,\%config);
my %hs = ();
foreach my $pz( @htm){ 
if( -f $pz ){ my $nz = undef;$pz =~ s/^($base)//i;$pz =~ s/^\///;if( $pz !~ /^($par)/ ){ $nz = $pz;
my $tmp = $pz;$tmp =~ s/\.($htmlext)$//; ##==pilbeam
#if( $tmp =~ /^(.+)($qqdelim)/ ){ my $tc = ($tmp =~ tr/$qqdelim//);if($tc < $menulimit){ $hs{$1."$delim"} = [ $1.".$htmlext",$1."$delim" ]; } } 
if( $tmp =~ /^(.+)($qqdelim)/ ){ my $fc = $1;my @tc = $tmp =~ /$qqdelim/g;if(scalar @tc <= $menu_limit){ $hs{$fc."$delim"} = [ $fc.".$htmlext",$fc."$delim" ]; } } # ( scalar @tc )." <= $menu_limit"
} }
}
for my $i( sort keys %hs){ push @ps,$hs{$i}; }
@s = sub_admin_chooser($u,\%config,\@ps);

$uph = admin_set_headers( $uph,$dlevel,1,$upf ,"pages",{} );

$ntxt.= '<div class="infoline inputline">An asterisk ( <b class="red">*</b> ) indicates required fields.</div><div class="inputline"><label for="old_0"><span class="numeral">1</span> Add Page beneath: <span class="red">*</span></label><select id="old_0" class="newparent" name="pre_old_0" tabindex="0">'.( join "",@s ).'</select></div><div class="lowerline inputline">&#160;</div>';
$ntxt.= '<div class="inputline"><label for="new-title_0"><span class="numeral">2</span> Page Title: <span class="red">*</span></label><textarea id="new-title_0" class="nonsave" name="opt_new-title_0" tabindex="0" maxlength="150">'.$edata{'title'}->[0].'</textarea></div>'.$inputinfo{'title'}.'<div class="upperline inputline">&#160;</div>';
$ntxt.= '<div class="inputline oneline"><label for="new-url_0"><span class="numeral">3</span> Page URL: </label><i class="ibefore'.( ($upf eq "")?' tt_undisplay':'' ).'">'.$par.'</i><i class="inewurl">'.$edata{'url'}->[0].'</i><i class="iafter">.'.$htmlext.'</i></span></div>';
$ntxt.= '<div class="inputline inewurl oneline"><label for="new-menuurl_0">Title Shown in Menus: <span class="red">*</span></label>'.( ($upf ne "")?'<input type="hidden" name="opt_new-parent_0" value="'.$par.'" />':'' ).'<input id="new-menuurl_0" class="filterselect" name="pre_new-menuurl_0" tabindex="0" maxlength="50" type="text" value="'.$edata{'menuname'}->[0].'" /></div>'.$inputinfo{'menu'}.'<div class="lowerline inputline">&#160;</div>';
$ntxt.= '<div class="inputline"><label for="new-name_0"><span class="numeral">4</span> Page Short Title: <span class="red">*</span></label><input id="new-shortname_0" class="nonsave" name="pre_new-shortname_0" tabindex="0" maxlength="30" type="text" value="'.$edata{'shortname'}->[0].'" /></div>'.$inputinfo{'short'}.'<div class="lowerline inputline">&#160;</div>';

$ntxt.= '<div class="titleline inputline">Optional Configuration</div><div class="inputline dropsub"><h2><input id="used1_0" name="used1_0" type="checkbox" /><label for="used1_0" class="tt_tabclick navblock nav-edit editseo" tabindex="0" title="edit Page SEO Data">Page SEO Data</label><span class="dropspacer">&#160;</span>';
foreach my $hr( sort keys %headers ){
my $vh = $hr;$vh =~ s/([\w']+)/\u\L$1/g; #'
my $vt = (defined $headers{$hr} && defined $headers{$hr}[2])?$headers{$hr}[2]:"";
$ntxt.= '<div class="inputline"><label for="new-'.$hr.'_0">'.( (defined $headers{$hr} && defined $headers{$hr}[3])?$headers{$hr}[3]:$vh ).':</label>';
$ntxt.= ( $hr =~ /^(description|keywords)$/ )?'<textarea  id="new-'.$hr.'_0" name="pre_new-'.$hr.'_0" tabindex="0" maxlength="300">'.$vt.'</textarea>':'<input id="new-'.$hr.'_0" name="pre_new-'.$hr.'_0" tabindex="0" type="text" value="'.$vt.'" maxlength="300" />';
$ntxt.= '</div>';
$c++;
}
$ntxt.= $inputinfo{'seo'}.'</h2></div>';

$ntxt.= '<div class="inputline dropsub"><h2><input id="used2_0" name="used2_0" type="checkbox" /><label for="used2_0" class="tt_tabclick navblock nav-edit edittags" tabindex="0" title="edit Page Tag Data">Page Tag Data</label><span class="dropspacer">&#160;</span>';
foreach my $ar( sort keys %editareas ){
my $vr = $ar;$vr =~ s/([\w']+)/\u\L$1/g; #'
my $ev = "";my $dc = "";if( $ar eq "date" ){ $ev = sub_get_date($time,\%config,"/");$dc = " undate"; } else { if( defined $edata{$ar} ){$ev = $edata{$ar}->[0];} }
if( $editareas{$ar} > 1 ){ $ntxt.= '<div class="inputline'.$dc.'"><label for="new-'.$ar.'_0">Page '.$vr.':</label><input id="new-'.$ar.'_0" name="opt_new-'.$ar.'_0" tabindex="0" type="text" value="'.$ev.'" /></div>';$c++; }
}
$ntxt.= $inputinfo{'tags'}.'</h2></div>';

$ntxt.= '<div class="inputline dropsub"><h2><input id="used3_0" name="used3_0" type="checkbox" /><label for="used3_0" class="tt_tabclick navblock nav-edit editalias" tabindex="0" title="edit external link">Make Page into an Alias</label><span class="dropspacer">&#160;</span>';
$ntxt.= '<div class="inputline unurl"><label for="new-link_0">Alias Link: </label><input id="new-link_0" name="opt_new-link_0" tabindex="0" maxlength="120" type="text" value="" /></div>'.$inputinfo{'alias'};
$ntxt.= '</h2></div><input id="case_0" name="opt_case_0" value="'.$ub.'" type="hidden">';

$uptxt =~ s/<div class="area setheaderarea"><\/div>/$uph/;
$uptxt =~ s/(<b class="default-folder">).*?(<\/b>)/$1$upd$2/;
$uptxt =~ s/(name="opt_url_[0-9]+" value=").*?(")/$1$upf$2/;
$uptxt =~ s/(<a class="navblock nav-return"\s*href=").*?(")/$1$upbackurl$2/g;
$uptxt =~ s/(<div class="inputline"><\/div>)/$ntxt/;

###admin_json_out({ 'check pageadd' => " s: [ @s ] \n\nu: $u \nupf: $upf \n\n ".Data::Dumper->Dump([\@ps],["ps"])." \n\n ".Data::Dumper->Dump([\@ptmp],["ptmp"])."\n\n uptxt:$uptxt \n\n $debug" },$origin,$callback);
admin_html_out($uptxt);
}


sub admin_getpagefield{
my ($n,$v,$c) = @_;
my $un = ucfirst $n;$un =~ s/^new\-//i;
my $l = ($n =~ /\-title/)?150:130;
my $s = '<label for="'.$n.'_0">'.$un.': </label>';
$s.= ($n =~ /\-(title)$/)?'<textarea class="'.$c.'" id="'.$n.'_0" name="pre_'.$n.'_0" tabindex="0" maxlength="'.$l.'">'.$v.'</textarea>':'<input type="text" class="'.$c.'" id="'.$n.'_0" name="pre_'.$n.'_0" tabindex="0" maxlength="'.$l.'" value="'.$v.'" />';
$s.= '<a class="mlist-submit" id="mlist-'.$n.'_0">change</a>';
return $s;
}


sub admin_display_pageedit{
my($u,$fu,$etxt,$lev,$eu,$href) = @_;
my $n = $u;$n =~ s/^($obase|$baseview)//;
my $clink = $n;$clink =~ s/^($base)//;
$n =~ s/\.($htmlext)$//;
my %h = %{ $href };
my @dtmp = split /$qqdelim/,$n;
my $deep = $#dtmp;
my $isdoc = ( $clink =~ /^($docview)/ )?1:undef;
my $isarc = ( $clink =~ /^($docview)Archive\// )?1:undef;
my $ispartner = ( $clink =~ /^($partnerbase)/ )?1:undef;
my $req = ( grep { $_ eq $clink } @required )?1:(defined $ispartner)?1:undef;
my $oglock = ( defined $h{'og:image'}[0] && $h{'og:image'}[0] =~ /($cssview)og\// )?1:undef;
my $hclass = ( defined $h{'menu'}[0] && $h{'menu'}[0] =~ /\.(0|00)$/ )?'hide':'show';
my $htclass =  ($hclass eq "hide")?'hidden':'shown';
my $unhclass = ($hclass eq "hide")?'show':'hide';
my $mclass = ( defined $h{'menu'}[0] && $h{'menu'}[0] =~ /\.00$/ )?'hide':'show';
my $mtclass =  ($mclass eq "hide")?'hidden':'shown';
my $unmclass = ($mclass eq "hide")?'show':'hide';
my $isfolder = ( defined $h{'menu'}[0] && $h{'menu'}[0] !~ /^000/ && $h{'menu'}[0] =~ /\.*000/ )?$h{'url'}[0]:undef;
my $isshare = ( defined $h{'sharename'}[0] )?$h{'sharename'}[0]:undef;
my $ishid = ( defined $h{'menu'}[0] && $h{'menu'}[0] =~ /\.(0|00)$/ )?$h{'menu'}[0]:undef;
my $ishh = (defined $ishid)?' data-menu="'.$ishid.'"':'';
my $ver = ( defined $h{'versions'} && scalar @{$h{'versions'}} > 0 )?1:undef;
my $eclink = $uri->encode( $clink );
my $oglink = ( defined $h{'og:image'} )?$h{'og:image'}[0]:( defined $headers{'og:image'} )?$headers{'og:image'}[2]:"none";if($oglink ne "none"){ $oglink =~ s/^\/\/.*?\/($cssview)/$baseview$1/;$oglink = "url(".$oglink.")"; }
my $mod = (defined $h{'modified'} )?$h{'modified'}[0]:(defined $h{'epoch'})?$h{'epoch'}[0]:0;
my $mdd = "";if($mod > 0){ $mdd = sub_get_date($mod,\%config,"-","version");$mdd =~ s/--/\//g; $mdd =~ s/-/ /g;$mdd = ' data-modified="Last Edited: '.$mdd.' GMT"'; } #11:37:09-16--04--2018
my $tdd = "";
my @ted = ();
foreach my $ar( sort keys %editareas ){ if( $editareas{$ar} > 1 && defined $h{$ar} && defined $h{$ar}[0] ){ push @ted,(ucfirst $ar).":".$h{$ar}[0] } }
if(scalar @ted > 0){ $tdd = ' data-tagged="'.( join ' / ',@ted ).'"'; } #'Date: 24/07/18 / Group:July
my $r = "";
###admin_json_out({ 'check pageedit' => "n: $n \nu: $u \nclink:$clink \nisfolder:$isfolder \nishid: $ishid \npages: $pages \ndlevel: $dlevel \ndeep:$deep <> menulimit:$menu_limit \n".Data::Dumper->Dump([\%h],["h"]) },$origin,$callback);

if( defined $isshare ){
$r.= '<div class="text nonmenufolder pages sharealert"><div class="tt_progress"><span class="bar"></span></div><h2><a class="navblock tt_directupdate nav-autofix" href="'.$pl.'type=viewsharefix&amp;url='.$eclink.'" title="fix share links">&#160;</a><a class="navtext tt_directupdate" href="'.$pl.'type=viewsharefix&amp;url='.$eclink.'" title="fix share links">This Page\'s Share Links are incorrect: '.$eclink.' == '.$h{'sharename'}[0].' - <b>click to fix</b></a></h2></div>';
}
$r.= '<div class="text nonmenufolder pages"><h2><a class="navblock nav-edit" href="'.$pl.'type=editblocks&amp;url='.$eclink.'&amp;id='.$mod.'" title="edit Page Content">&#160;</a><a class="navtext" href="'.$pl.'type=editblocks&amp;url='.$eclink.'&amp;id='.$mod.'" title="edit Page">Edit Page Content</a></h2></div>';
$r.= '<div class="text nonmenufolder pages"'.$mdd.'><h2><a class="navblock nav-viewpage" href="'.$clink.'" title="view '.$clink.'" target="_blank">&#160;</a><a class="navtext" href="'.$clink.'" title="view '.$clink.'" target="_blank">View Page</a></h2></div>';
$r.= '<div class="text nonmenufolder pages"><div class="tt_progress"><span class="bar"></span></div><h2><input id="used0_0" name="used0_0" type="checkbox" /><label data-mref="'.$eclink.'" for="used0_0" class="tt_tabclick navblock nav-edit nav-editlink" tabindex="0" title="edit Page Title">Rename Page Title</label><span class="dropspacer">&#160;</span><span class="inputline unsearch">'.( admin_getpagefield('new-title',$h{'title'}[0],'title') ).'</span>'.$inputinfo{'title'}.'</h2></div>'; 

if( defined $req ){
if( $clink ne $index_file ){ $r.= '<div class="text nonmenufolder pages inactive"><h2><span class="navblock nav-rename unrename">&#160;</span><span class="navtext">Title Shown in Menus</span></h2></div>'; }
$r.= '<div class="text nonmenufolder pages inactive"><h2><span class="navblock nav-rename unrename">&#160;</span><span class="navtext">Edit Page Short Title</span></h2></div>';
} else {
my $par = "";
my $nm = $h{'url'}[0];$nm =~ s/\.($htmlext)$//i;if($nm =~ /$qqdelim/){ $nm =~ s/^(.+$qqdelim)//;$par = $1;}
my @pgs = sub_get_html($base,\%config,$base);
###admin_json_out({ 'check pageedit 1' => "n:$n \nu:$u \nclink:$clink \npar:$par\n \nnm:$nm isfolder:$isfolder \nishid: $ishid \npages: $pages \ndlevel: $dlevel \ndeep:$deep <> menulimit:$menu_limit \n".Data::Dumper->Dump([\%h],["h"]) },$origin,$callback);

$r.= '<div class="text nonmenufolder pages"><div class="tt_progress"><span class="bar"></span></div><h2><input id="used3_0" name="used3_0" type="checkbox" /><label data-mref="'.$eclink.'" for="used3_0" class="tt_tabclick navblock nav-edit nav-rename" tabindex="0" title="edit Title that appears in Menus">Title Shown in Menus</label><span class="dropspacer">&#160;</span>';
$r.= '<span class="inputline oneline"><label>New Page URL: </label><i class="ibefore'.( ($clink eq "" || $par eq "html")?' tt_undisplay':'' ).'">'.$par.'</i><i class="inewurl">'.$nm.'</i><i class="iafter">.'.$htmlext.'</i></span>';
$r.= '<span class="inputline oneline inewurl"><label for="new-menuurl_0">Title of this Page in Menus: </label>'.( ($clink ne "")?'<input type="hidden" id="new-parent_0" name="opt_new-parent_0" value="'.$par.'" />':'' ).'<input id="new-menuurl_0" class="url filterselect" name="pre_new-menuurl_0"  tabindex="0" maxlength="50" type="text" value="'.( sub_title_out($nm,\%config) ).'" /><a class="mlist-submit" id="mlist-new-menuurl_0">change</a></span>'.$inputinfo{'menu'};
$r.= '</h2><input class="filtersource" type="hidden" id="filter_0" name="opt_filter_0" value="'.( join "|",@pgs ).'" disabled /></div>';
$r.= '<div class="text nonmenufolder pages"><div class="tt_progress"><span class="bar"></span></div><h2><input id="used5_0" name="used5_0" type="checkbox" /><label data-mref="'.$eclink.'" for="used5_0" class="tt_tabclick navblock nav-edit nav-rename" tabindex="0" title="edit Page Short Title">Edit Page Short Title</label><span class="dropspacer">&#160;</span><span class="inputline"><label for="new-shortname_0">Change Short Title: </label><input class="shortname" id="new-shortname_0" name="pre_new-shortname_0" tabindex="0" type="text" maxlength="30" value="'.$h{'shortname'}[0].'" /><a class="mlist-submit" id="mlist-new-shortname_0">change</a></span>'.$inputinfo{'short'}.'</h2></div>'; 
}

$r.= '<div class="text nonmenufolder pages"><div class="tt_progress"><span class="bar"></span></div><h2><input id="used1_0" name="used1_0" type="checkbox" /><label data-mref="'.$eclink.'" for="used1_0" class="tt_tabclick navblock nav-edit editseo" tabindex="0" title="edit Page SEO">Edit Page SEO Data</label><span class="dropspacer">&#160;</span>';
foreach my $hr( sort keys %headers ){
$r.= '<span class="inputline unfolder"><label for="new-'.$hr.'_0" tabindex="0">'.( (defined $headers{$hr} && defined $headers{$hr}[3])?$headers{$hr}[3]:$hr ).':</label>';
$r.= ( $hr =~ /^(description|keywords)$/ )?'<textarea class="seo" id="new-'.$hr.'_0" name="pre_new-'.$hr.'_0" tabindex="0" maxlength="300">'.( (defined $h{$hr} && defined $h{$hr}[0])?$h{$hr}[0]:"" ).'</textarea>':'<input class="seo" id="new-'.$hr.'_0" name="pre_new-'.$hr.'_0" tabindex="0" type="text" maxlength="300" value="'.( (defined $h{$hr} && defined $h{$hr}[0])?$h{$hr}[0]:"" ).'" />';
$r.= '<a class="mlist-submit" id="mlist-new-'.$hr.'_0">change</a></span>';
}
$r.= $inputinfo{'seo'}.'</h2></div>';

$r.= '<div class="text nonmenufolder pages"'.$tdd.'><div class="tt_progress"><span class="bar"></span></div><h2><input id="used2_0" name="used2_0" type="checkbox" /><label data-mref="'.$eclink.'" for="used2_0" class="tt_tabclick navblock nav-edit edittags" tabindex="0" title="edit Page tag data">Edit Page Tag Data</label><span class="dropspacer">&#160;</span>';
foreach my $ar( sort keys %editareas ){
if($ar ne "name"){
my $ud = ($ar eq "date")?' undate':'';
if( $editareas{$ar} > 1 ){ $r.= '<span class="inputline'.$ud.'"><label for="new-'.$ar.'_0"  tabindex="0">'.$ar.':</label><input class="tags" id="new-'.$ar.'_0" name="opt_new-'.$ar.'_0" tabindex="0" type="text" maxlength="300" value="'.( (defined $h{$ar} && defined $h{$ar}[0])?$h{$ar}[0]:"" ).'" /><a class="mlist-submit" id="mlist-new-'.$ar.'_0">change</a></span>'; }
}
}
$r.= $inputinfo{'tags'}.'</h2></div>';

if( !defined $isdoc){
if( defined $req ){ 
$r.= '<div class="text nonmenufolder pages inactive"><h2><span class="navblock nav-rename unrename">&#160;</span><span class="navtext">External Link or Alias</span></h2></div>';
} else {
my $alias = ( (defined $h{'link'} && $h{'link'}[0] ne $h{'url'}[0])?$h{'link'}[0]:$h{'url'}[0] );
$r.= '<div class="text nonmenufolder pages"><div class="tt_progress"><span class="bar"></span></div><h2><input id="used4_0" name="used4_0" type="checkbox" /><label data-mref="'.$eclink.'" for="used4_0" class="tt_tabclick navblock nav-edit nav-editlink" tabindex="0" title="External Link or Alias">External Link or Alias</label><span class="dropspacer">&#160;</span><span class="inputline unurl"><label for="new-link_0">Change this Page\'s Link in Menus: </label><input class="alias" id="new-link_0" name="pre_new-link_0" tabindex="0" type="text" maxlength="120" value="'.$alias.'" /><a class="mlist-submit" id="mlist-new-linkurl_0">change</a></span>'.$inputinfo{'alias'}.'</h2></div>'; 
}

if( !defined $ispartner ){
if( defined $oglock ){
$r.= '<div class="text nonmenufolder pages"><div class="tt_progress"><span class="bar"></span></div><h2><a class="navblock tt_directupdate nav-lock" href="'.$pl.'type=changeunlockpages&amp;url='.$eclink.'" title="unlock Page Thumbnail">&#160;</a><a class="navtext tt_directupdate" href="'.$pl.'type=changeunlockpages&amp;url='.$eclink.'" title="unlock Page Thumbnail">Page Thumbnail is locked</a></h2></div>';
} else {
$r.= '<div class="text nonmenufolder pages"><div class="tt_progress"><span class="bar"></span></div><h2><a class="navblock tt_directupdate nav-imgpage" style="background-image:'.$oglink.'" href="'.$pl.'type=changeimagepages&amp;url='.$eclink.'" title="update Page Thumbnail">&#160;</a><a class="navtext tt_directupdate" href="'.$pl.'type=changeimagepages&amp;url='.$eclink.'" title="update Page Thumbnail">Update Page Thumbnail</a></h2></div>';
$r.= '<div class="text nonmenufolder pages"><div class="tt_progress"><span class="bar"></span></div><h2><a class="navblock tt_directupdate nav-unlock" href="'.$pl.'type=changelockpages&amp;url='.$eclink.'" title="lock Page Thumbnail">&#160;</a><a class="navtext tt_directupdate" href="'.$pl.'type=changelockpages&amp;url='.$eclink.'" title="lock Page Thumbnail">Page Thumbnail is unlocked</a></h2></div>';
}
if( defined $h{'menu'}[0] ){
my $sp = (defined $isfolder)?'Add Subpage below this Page':'Enable Subpages below this Page';
my $ap = (defined $isfolder)?'add':'changesub';
if( $deep < $menu_limit ){ $r.= '<div class="text nonmenufolder pages"><div class="tt_progress"><span class="bar"></span></div><h2><a class="navblock '.( (defined $isfolder)?'':'tt_directupdate ' ).'nav-addsubpage" href="'.$pl.'type='.$ap.'pages&amp;url='.$eclink.'&amp;case='.$h{'menu'}[0].'" title="'.$sp.'">&#160;</a><a class="navtext" href="'.$pl.'type='.$ap.'pages&amp;url='.$eclink.'&amp;case='.$h{'menu'}[0].'" title="'.$sp.'">'.$sp.'</a></h2></div>'; }
}
$r.= '<div class="text nonmenufolder pages '.$hclass.'page" data-menu="'.$h{'menu'}[0].'"><div class="tt_progress"><span class="bar"></span></div><h2>'.
'<label class="navtext">Page is '.( ucfirst($mtclass) ).' in Sitemap and '.( ucfirst($htclass) ).' in Menus</label>'.( admin_getpagemap((defined $isfolder)?"folder":"page",1,$eclink,$unhclass,$unmclass,$htclass,$mtclass) );
$r.= '</h2></div>';
}
}

$r.= ( defined $req || ($adminuser !~ /admin$/ && defined $isfolder) )?'<div class="text nonmenufolder pages inactive"><h2><span class="navblock nav-delete undelete">&#160;</span><span class="navtext">Delete Page</span></h2></div>':'<div class="text nonmenufolder pages"'.$ishh.'><h2><a class="navblock nav-delete" href="'.$pl.'type=deletepages&amp;url='.$eclink.'" title="delete Page">&#160;</a><a class="navtext" href="'.$pl.'type=deletepages&amp;url='.$eclink.'" title="delete Page'.( (defined $isfolder)?' and Aliases and Subpages':'' ).'">Delete Page'.( (defined $isfolder)?' and all Aliases/Subpages below this Page':'' ).'</a></h2></div>';

if( !defined $isdoc && defined $ver ){
$r.= '<div class="text nonmenufolder pages"><h2><a class="navblock nav-versions" href="'.$pl.'type=viewversionpages&amp;url='.$eclink.'" title="view Page versions">&#160;</a><a class="navtext" href="'.$pl.'type=viewversionpages&amp;url='.$eclink.'" title="view Page versions">View Page Versions</a></h2></div>';
} else {
$r.= '<div class="text nonmenufolder pages inactive"><h2><span class="navblock nav-versions unversions">&#160;</span><span class="navtext">View Page Versions</span></h2></div>';
}

if( defined $isarc || defined $ispartner ){
$r.= '<div class="text nonmenufolder pages inactive"><h2><span class="navblock nav-archive unarchive">&#160;</span><span class="navtext">Archive this Page</span></h2></div>';
} else {
$r.= '<div class="text nonmenufolder pages"><h2><a class="navblock nav-archive" href="'.$pl.'type=archivepages&amp;url='.$eclink.'" title="move this Page to Archive folder">&#160;</a><a class="navtext" href="'.$pl.'type=archivepages&amp;url='.$eclink.'" title="move this Page to Archive folder">Archive this Page</a></h2></div>';
}
$r.= '<input id="url_0" name="opt_url_0" value="'.$eclink.'" type="hidden" /><input id="changed_0" name="opt_changed_0" value="" type="hidden" /><input id="type_0" name="opt_type_0" value="changeaddpages" type="hidden" />';

$etxt =~ s/<div class="text nav-box"><\/div>/$r/; 
$etxt =~ s/(<a class="navblock nav-return"\s*href=".*?)(")/$1$eu$2/g;
my $eh = admin_set_headers( "",$lev,0,$fu,"pages",{},$h{'title'}[0],$isfolder,$ishid );$etxt =~ s/<div class="area setheaderarea"><\/div>/$eh/;
return $etxt;
}

sub admin_display_reorder{
my ($u,$updref,$ty,$showall) = @_;
my @s = ();
my $probs = (defined $ty)?$ty:undef;
my $err = undef;
my ($eerr,$eref) = sub_page_return("viewpages",[$u,$partnerbase],\%config,undef,undef,undef,undef,undef,undef,undef,undef,$showall);
admin_json_out({ 'error' => "display reorder: ".$eerr },$origin,$callback) if defined $eerr;
my @ptmp = @{$eref};
my @nw = @ptmp;
###admin_json_out({ 'check display_reorder' => "u:$u \nupdref: $updref \n\n ".Data::Dumper->Dump([\@nw],["nw"])." \n\n $debug" },$origin,$callback);
@s = admin_drill_reorder($ty,\@nw,\@s,'_0',undef,$updref,$probs);
###admin_json_out({ 'check display_reorder 1' => "u:$u \n\n ".Data::Dumper->Dump([\@s],["s"])." \n\n $debug" },$origin,$callback);
if( defined $updref ){ return @s; } else { return join "\n",@s; }
}

sub admin_drill_pagelist{
my ($pref,$mref,$find) = @_;
my @pset = @{$pref};
my @menu = @{$mref};
for my $i(0..$#pset){
if( !defined $find || @{ $pset[$i]->{'url'} }[0] eq $find ){ push @menu,$pset[$i]; } #@{ $pset[$i]->{'url'} }[0]
if( defined $pset[$i]->{'pages'} ){ @menu = @{ admin_drill_pagelist( $pset[$i]->{'pages'},\@menu,$find ); }; }
}
return \@menu;
}

sub admin_drill_reorder{
my ($ty,$pref,$sref,$ci,$inside,$updref,$probs,$sr) = @_;
my %upd = (defined $updref)?%{$updref}:();
my @ptmp = @{$pref};
my $offclass = "";
my $dbug = "";
if( defined $sr && defined $defsort{$sr} ){ $offclass = " tt_undisplay";@ptmp = sort { $b->{'epoch'}[0] <=> $a->{'epoch'}[0] || lc $a->{'title'}[0] cmp lc $b->{'title'}[0] } @ptmp; } ###admin_json_out({ 'check drill_reorder' => "sr: $sr \n".Data::Dumper->Dump([\@ptmp],["ptmp"]) },$origin,$callback);
my @s = @{$sref};
my $c = 0;
for my $i(0..$#ptmp){ 
my $d = @{ $ptmp[$i]->{'url'} }[0];my $tmp = $d;$tmp =~ s/\.($htmlext)$//;my @dd = $tmp =~ /($qqdelim)/g; ##==pilbeam
if( defined $updref ){ foreach my $k( keys %upd ){ my $dm = $k;$dm =~ s/\.($htmlext)$//;my $qm = '^'.quotemeta($dm);$dbug.= "in: $dm ";if( $d =~ $qm ){ my $old = @{ $ptmp[$i]->{'menu'} }[0];@{ $ptmp[$i]->{'menu'} }[0] =~ s/\.(0|00)$//;@{ $ptmp[$i]->{'menu'} }[0].= $upd{$k};$dbug.= "old:$old replace with ".@{ $ptmp[$i]->{'menu'} }[0]."\n"; } } }
###if( $d eq 'Digital.html' ){
###admin_json_out({ 'check drill_reorder 1' => "\nty:$ty \nd:$d \n\n dbug:$dbug \n\n $d is in upd = ".( defined $upd{$d} )."\n\nptmp[$i] = ".@{ $ptmp[$i]->{'menu'} }[0]." \n\n".Data::Dumper->Dump([\%upd],["upd"]) },$origin,$callback);
###}
my $inm = '<a class="navblock nav-inmenu'.( ( $i > 0 && $i < $#ptmp-1 && defined $ptmp[($i+1)]->{'pages'})?'':' tt_undisplay' ).'" tabindex="0" title="move into next Folder">&#160;</a>';
my $outm = '<a class="navblock nav-outmenu'.( (defined $inside)?'':' tt_undisplay' ).'" tabindex="0" title="move out of this Folder">&#160;</a>';
my $addm = '<a class="navblock nav-addmenu'.$offclass.( (defined $ptmp[$i]->{'pages'})?' nav-removemenu':'' ).'" tabindex="0" title="'.( (defined $ptmp[$i]->{'pages'})?'delete all ':'add' ).' Subpages beneath this Page">&#160;</a>';
my $mvis = ( @{ $ptmp[$i]->{'menu'} }[0] =~ /\.(0|00)$/ )?' mhidepage':'';
if( defined $ptmp[$i]->{'pages'} ){
if( defined $updref ){ push @s,$ptmp[$i]->{'url'}[0].'|'.$ptmp[$i]->{'menu'}[0].'|'.(1+scalar @dd); } else { push @s,'<div class="text menufolder orderline pages'.$mvis.'" data-title="'.@{ $ptmp[$i]->{'url'} }[0].'" data-menu="'.@{ $ptmp[$i]->{'menu'} }[0].'"><input type="hidden" id="checkfile'.$ptmp[$i]->{'menu'}[0].'" name="opt_checkfile'.$ptmp[$i]->{'menu'}[0].'_0" value="'.$ptmp[$i]->{'url'}[0].'|'.$ptmp[$i]->{'menu'}[0].'" disabled /><h2><input id="used'.$i.$ci.'" name="used'.$i.$ci.'" type="checkbox" /><a class="navblock nav-downmenu" tabindex="0" title="move down">&#160;</a><a class="navblock nav-upmenu" tabindex="0" title="move up">&#160;</a>'.$inm.$outm.$addm.'<label for="used'.$i.$ci.'" class="tt_tabclick navblock nav-edit editopen" tabindex="0" title="view Subpages">'.$ptmp[$i]->{'title'}[0].'</label><span class="dropspacer">&#160;</span><div class="reorderparent">'; }
if( $ty ne "showpages" || !defined $upd{$d} ){ @s = admin_drill_reorder($ty,$ptmp[$i]->{'pages'},\@s,$delim.$i.$ci,"inside",$updref,$probs,@{ $ptmp[$i]->{'url'} }[0]); }
if( !defined $updref ){push @s,'</div></h2></div>';}
} else {
if( defined $ptmp[$i]->{'menu'}[0] && $ptmp[$i]->{'menu'}[0] !~ /^000/ && $ptmp[$i]->{'menu'}[0] =~ /(\.*000)/ ){ $ptmp[$i]->{'menu'}[0] =~ s/(\.*000)//; }
if( defined $updref ){ 
my $pr = "";if( defined $probs && $probs =~ /^list/ && defined $ptmp[$i]->{'issues'} ){ $pr = "<i class=\"suggest\">".( join "</i><i class=\"suggest\">",@{ $ptmp[$i]->{'issues'} } )."</i>"; }
push @s,$ptmp[$i]->{'url'}[0].'|'.$ptmp[$i]->{'menu'}[0].'|'.(1+scalar @dd).$pr; } else { push @s,'<div class="text nonmenufolder orderline pages'.$mvis.'" data-title="'.@{ $ptmp[$i]->{'url'} }[0].'" data-menu="'.@{ $ptmp[$i]->{'menu'} }[0].'"><input type="hidden" id="checkfile'.$ptmp[$i]->{'menu'}[0].'" name="opt_checkfile'.$ptmp[$i]->{'menu'}[0].'_0" value="'.$ptmp[$i]->{'url'}[0].'|'.$ptmp[$i]->{'menu'}[0].'" disabled /><h2><input id="used'.$i.$ci.'" name="used'.$i.$ci.'" type="checkbox" /><a class="navblock nav-downmenu '.$offclass.'" tabindex="0" title="move down">&#160;</a><a class="navblock nav-upmenu '.$offclass.'" tabindex="0" title="move up">&#160;</a>'.$inm.$outm.$addm.'<label for="used'.$i.$ci.'" class="tt_tabclick navblock nav-edit editopen" tabindex="0" title="no Subpages">'.$ptmp[$i]->{'title'}[0].'</label><span class="dropspacer">&#160;</span><div class="reorderparent"></div></h2></div>'; }
}
$c++;
}
return @s;
}

sub admin_drill_submenu{
my ($pref,$aref,$pos,$total,$d) = @_;
my $n = join ".",@{$pref}[0..$pos];
my @ar = @{$aref};
my @m = @ar;
my $p = 1+$pos;
for my $i(0..$#ar){ if( defined $ar[$i]{'url'}[0] && $n.".".$htmlext eq $ar[$i]{'url'}[0] ){
if( defined $ar[$i]{'pages'} && scalar @{$ar[$i]{'pages'}} > 0 ){ if($pos == $total){ my %htmp = %{$ar[$i]};@m = @{ $ar[$i]{'pages'} };delete $htmp{'pages'};unshift @m,\%htmp; } else { my ($mref,$msg) = admin_drill_submenu($pref,$ar[$i]{'pages'},$p,$total,$d);@m = (defined $mref)?@{$mref}:();$d.= $msg; } }
} }
return (\@m,$d);
}

sub admin_generate_sizes{
my ($imref,$dir) = @_;
my %sizes = %{$imref};
my $s = '';
my $i = 0;
my $t = 0;
foreach my $k( sort keys %sizes){ my @ks = @{ $sizes{$k} };my $tc = "";my $c = ( $dir =~ /^($ks[0])/ )?" checked":"";if( $c ne ""){$tc = "imagelist";$t++;}$s.= '<span class="'.$tc.'"><input id="versions'.$i.'_0" name="opt_versions'.$i.'_0" value="'.$ks[1].'" tabindex="0" class="generate_check" type="checkbox"'.$c.'><label for="versions'.$i.'_0" class="css-check" data-folder="'.$ks[0].'">Create '.$k.'</label></span>';$i++; }
return $s.'<span class="imagelist"><input  id="duplicate_0" name="opt_duplicate_0" value="duplicate" tabindex="0" class="duplicate_check" type="checkbox"'.( ($t < 1)?" checked":"" ).'><label for="duplicate_0" class="css-check">Keep Images at full size.</label></span>';
}

sub admin_get_clipboard{
my ($f) = @_;
my %res = ('edittexts' => 0,'grids' => 0,'sections' => 0);
find(sub { my $n = $File::Find::name;
my $ok = ( $n =~ /^($base.*?Clipboard\/)(.*?)\.txt$/ )?1:undef;if( defined $ok ){ my $fh = $2;my $c = 0;$res{$fh} = scalar keys %{ @{ sub_search_file($n,$c,['<article'],undef) }[1] }; } #'grids' => [ 0,{'<article' => []} ]
},$f);
###admin_json_out({ 'check get_clipboard' => "f:$f \n\n".Data::Dumper->Dump([\%res],["res"])."\n\n $debug" },$origin,$callback);
return \%res;
}

sub admin_get_allclips{
my ($id,$u,$cref,$old,$new,$replace) =@_;
my @clips = @{$cref};
my %cd = (); 
my $rtxt = "";
my $c = 1;
my $err = undef;
for my $i(0..$#clips){
$cd{ $clips[$i] }= {}; # 'edittext' => {},'grid' => {},'section' => {}
my $cu = $u."/".$clips[$i]."s.txt";
my $nt = '<div class="text nonmenufolder pages"><span><h2>No '.$clips[$i].' Clipboard data currently saved.</h2></span></div>';
###admin_json_out({ 'get_allclips' => "cu:$cu \n\n".Data::Dumper->Dump([\%cd],["cd"])." \n\nold:$old \nnew:$new \nreplace:$replace\n\n$debug" },$origin,$callback);
if( -f $cu ){ 

my $ctxt = admin_html_in($cu);
if( $id =~ /(alter|cut)$/ ){ 
if( $id eq "alter" ){ 
if($new ne ""){
if( defined $replace ){ $ctxt =~ s/(<article\s*id="$old"\s*class="clipboard-$clips[$i]"\s*data-clipname=")(.*?)("\s*>)(.*?)(<\/article>)/$1$replace$3$4$5/ism; }
if( defined $old ){ $ctxt =~ s/(<article\s*id="$old"\s*class="clipboard-$clips[$i]"\s*data-clipname=".*?"\s*>)(.*?)(<\/article>)/$1$new$3/ism; }
} else {
$ctxt =~ s/(<article\s*id="$old"\s*class="clipboard-$clips[$i]"\s*data-clipname=".*?"\s*>)(.*?)(<\/article>)//ism;
}
} else { 
$ctxt.= "\n".$new; 
}
$ctxt =~ s/\t//g;
$ctxt =~ s/\r+/\n/g;
$ctxt =~ s/\n+/\n/g;
###admin_json_out({ 'get_allclips 1' => "id:$id \ncu:$cu \n\n ctxt:$ctxt \n\nerr:$err \nold:$old \nnew:$new \nreplace:$replace\n\n$debug" },$origin,$callback);
}
while( $ctxt =~ /(<article\s*id=")(.*?)("\s*class="clipboard-$clips[$i]"\s*data-clipname=")(.*?)("\s*>)(.*?)(<\/article>)/gism ){ $cd{$clips[$i]}{$2} = [$4,$6]; }

if( $id eq "alter" && !scalar keys %{ $cd{$clips[$i]} } > 0 ){ 
my $herr = sub_page_print($cu,"");if(defined $herr){$err = $herr;}$rtxt.= $nt;
} else {

my $ntxt = "";
foreach my $cl( sort keys %{ $cd{$clips[$i]} } ){
if( scalar keys %{ $cd{$clips[$i]} } > 0 ){
foreach my $k( keys %{ $cd{$clips[$i]} } ){
my $n = @{ $cd{ $clips[$i] }{$k} }[0];
my $sm = @{ $cd{ $clips[$i] }{$k} }[1];
if( $id =~ /(alter|cut)$/ ){
$ntxt.= "<article id=\"$k\" class=\"clipboard-$clips[$i]\" data-clipname=\"$n\">\n$sm</article>\n";
} else {
my $cn = ($clips[$i] eq "edittext")?"block":($clips[$i] eq "grid")?"layout":$clips[$i];
$ntxt.= '<div class="text nonmenufolder pages"><h2>';
$ntxt.= '<input id="used1_'.$c.'" name="used1_'.$c.'" type="checkbox" /><label for="used1_'.$c.'" class="tt_tabclick navblock nav-edit nav-editclipboard clip'.$cn.'" tabindex="'.$c.'" title="edit Clipboard '.( ucfirst $cn ).' data">Edit Clipboard ('.( ucfirst $cn ).') Data</label><span class="dropspacer">&#160;</span>';
$ntxt.= '<span class="inputline unsearch globals clipdata"><div class="tt_progress"><span class="bar"></span></div><input id="old_'.$c.'" name="opt_old_'.$c.'" type="hidden" value="'.$k.'" /><label for="replace_'.$c.'">Edit Name:</label><input class="clipdata" id="replace_'.$c.'" name="pre_replace_'.$c.'" type="text" value="'.$n.'"><textarea class="clipdata" id="new-'.$clips[$i].'_'.$c.'" name="opt_new-'.$clips[$i].'_'.$c.'" tabindex="'.$c.'">'.$sm.'</textarea><a id="mlist_'.$clips[$i].'_'.$c.'" class="mlist-submit clipdata" title="update Clipboard item">Update</a><a id="mlist_'.$clips[$i].'_delete_'.$c.'" class="mlist-delete clipdata" title="delete Clipboard item">Delete</a></span>';
$ntxt.= "</h2></div>\n";
}
$c++;
}
if( $id =~ /(alter|cut)$/ ){ my $herr = sub_page_print($cu,$ntxt);if(defined $herr){$err = $herr;} }
} else {
$ntxt.= $nt;
}
}
$rtxt.= "\n".$ntxt;
}

} else {
$rtxt.= $nt;
}
}
return (\%cd,$rtxt);
}

sub admin_get_js{
my ($nf,$pack) = @_;
my %jsfiles = ();
my %cssfiles = ();
my $c = 0;
my @all = sub_get_html($nf,\%config,undef,$auxfiles,"auxonly"); ###admin_json_out({ 'get js' => "$nf = ".Data::Dumper->Dump([\@js],["js"])."".$debug },$origin,$callback);
for my $i(0..$#all){ 
if( $all[$i] =~ /-full\.(js)$/){ $c++;if(defined $pack){ my $w = $all[$i];$w =~ s/-full\.(js)$/.$1/i;%{ $jsfiles{$w} } = ('top' => "",'tmp' => "");my $tmp = sub_get_contents($all[$i],\%config,"text");$jsfiles{$w}{'tmp'} = $tmp;if( $tmp =~ /^(.+)($jsminline)(.*?\n)(.+)$/ism ){ $jsfiles{$w}{'top'} = $1.$2.$3;$jsfiles{$w}{'tmp'} = $4; } } else { $jsfiles{$all[$i]} = "$i"; } }
if( $all[$i] =~ /-full\.(css)$/){ $c++;if(defined $pack){ my $w = $all[$i];$w =~ s/-full\.(css)$/.$1/i;%{ $cssfiles{$w} } = ('top' => "",'tmp' => "");my $tmp = sub_get_contents($all[$i],\%config,"text");$cssfiles{$w}{'tmp'} = $tmp; } else { $cssfiles{$all[$i]} = "$i"; } }
}
###admin_json_out({ 'get js' => "nf:$nf \npack:$pack \n\n".Data::Dumper->Dump([\%jsfiles],["jsfiles"])."\n\n".Data::Dumper->Dump([\%cssfiles],["cssfiles"])."\n\n".$debug },$origin,$callback);
return ($c,\%jsfiles,\%cssfiles);
}

sub admin_get_pageedit{ 
my ($f,$mod,$edstr,$cjs,$ajs) = @_;
my $u = $f;$u =~ s/^($base)//;
my $ue = $uri->encode($u);
my $bak = $pl."type=editpages&url=".$ue;
my $warn = "";
my $bu = $u;my $tmp = $bu;$tmp =~ s/\.($htmlext)$//;$tmp =~ s/^.+($qqdelim)//;$bu = sub_title_out($tmp,\%config); ##==pilbeam
my $uu = lc $u;$uu =~ s/\.($htmlext)$//;if($uu =~ /$qqdelim/){$uu =~ s/($qqdelim).+$//;} ##==pilbeam
my %eclips = %{ admin_get_clipboard($base.$docview.'Clipboard/') };
my $upfolder = $docview.$imagefolder.'/';if( -d $base.$upfolder.$uu."/"){ $upfolder = $upfolder.$uu.'/'; } else {$upfolder.= 'elements/';}
my @addreceivers = ();foreach my $k(sort keys %RECEIVERS){ push @addreceivers,"'".$k."':'".$RECEIVERS{$k}."'"; }
my @addsubjects = ();foreach my $k(sort keys %SUBJECTS){ my $t = $SUBJECTS{$k};$t =~ s/'/\\'/g;push @addsubjects,"'".$k."':'".$t."'"; }
my @defmods = ();foreach my $k(sort keys %DEFMODS){ push @defmods,"'".$k."':'".$DEFMODS{$k}."'"; }
my @sc = ();foreach my $k(sort keys %defsections){ push @sc,"'".$k."':'".$defsections{$k}->[0]."'"; }
#my $sizer = admin_generate_sizes(\%imgsizes,$upfolder);
my $ajs = "<script type=\"application/javascript\" src=\"config.js\" charset=\"utf-8\"></script><script type=\"application\/javascript\" src=\"".$subdir."admin/minsu.js\" charset=\"utf-8\"></script>\n<script type=\"application/javascript\" src=\"".$subdir."admin/su.js\" charset=\"utf-8\"></script>\n<script type=\"application/javascript\" src=\"".$subdir."admin/contenteditable.js\" charset=\"utf-8\"></script>\n";
my $xjs = "<script type=\"application\/javascript\">Object.append(E,{ 'cfg':{ 'eclips':{'edittexts':".$eclips{'edittexts'}.",'grids':".$eclips{'grids'}.",'sections':".$eclips{'sections'}."},'RECEIVERS':{ ".(join ",",@addreceivers)." },'SUBJECTS':{ ".(join ",",@addsubjects)." },'MODULES':{ ".(join ",",@defmods)." },'defsections':{ ".(join ",",@sc)." },'e_pulltags':".$edstr.",'docfolder':'".$docview."','imgfolder':'".$imagefolder."/','upfolder':'".$upfolder."','modified':'".$mod."' } });</script>\n"; 

#','e_sizes':'".$sizer."
my $txt = admin_html_in($f,"utf");

my $md = undef;if($txt =~ /<meta content="([0-9]+)"\s+name="editmodified"\s*\/>/){$md = $1;}
if(defined $md && $md ne $mod){ $warn = '<div class="tt_modify-warning"><span>WARNING!</span>Displayed Page ('.( sub_get_date($mod,\%config,"/","version") ).') does not match the <a href="'.$bak.'&id='.$md.'" title="edit Live Page">live site Page</a> ('.( sub_get_date($md,\%config,"/","version") ).'). </div>'; }
my $addbar = <<_ADD_BAR_;
<div id="editthis-bar" class="edittopbar">	
	<form id="edit_form_0" class="sendable" accept-charset="UTF-8"><fieldset>$warn	
		<div class="tt_topmenu tt_menu0">		
			<h3 class="hide"><span class="num">1</span> Choose an editable <em class="hilite">Area</em></h3>
			<b class="navblock nav-save unsave" title="save page changes">&#160;</b>
			<b class="navblock nav-revert unrevert" title="revert" title="undo last change">&#160;</b>
			<a class="navblock nav-help" target="_blank" title="pages help" href="admin/help.html">&#160;</a>
			<b class="navblock nav-section unsection" title="highlight sections">&#160;</b>
			<b class="navblock nav-layout unlayout" title="highlight layout grids">&#160;</b>
			<b class="navblock nav-view" title="highlight editable areas">&#160;</b>
			<a class="navblock nav-home" href="$bak" title="back to $bu edit menu">&#160;</a>
		</div>
		<div class="tt_topmenu tt_menu1 tt_undisplay">
			<h3 class="hide"><span class="num">2</span> Text Area <em class="hilite0">Selected</em></h3>
			<b class="navblock nav-save unsave" title="save page changes">&#160;</b>
			<b class="navblock nav-revert unrevert" title="revert" title="undo last change">&#160;</b>
			<a class="navblock nav-help" target="_blank" title="pages help" href="admin/help.html">&#160;</a>
			<b class="navblock nav-convert" title="change Area Type">&#160;</b>
			<b class="navblock nav-cut" title="save Area to Clipboard">&#160;</b>
			<b class="navblock nav-paste unpaste" title="replace Area from Clipboard">&#160;</b>
			<b class="navblock nav-menuback" title="unselect text area">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu2 tt_undisplay">
			<h3 class="hide"><span class="num">3</span> Edit <em class="hilite0">Text</em></h3>
			<b class="navblock nav-update unsave editor" title="update text">&#160;</b>
			<b class="navblock nav-exit unrevert editor" title="revert text">&#160;</b>
			<b class="navblock nav-textformat unalter editor" title="text format">&#160;</b>
			<b class="navblock nav-textitalic unalter editor" title="italic text">&#160;</b>
			<b class="navblock nav-textbold unalter editor" title="bold text">&#160;</b>
			<b class="navblock nav-textlink unalter editor" title="link text">&#160;</b>
			<b class="navblock nav-menuback editor" title="cancel editing">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu3 tt_undisplay">
			<h3 class="hide"><span class="num">4</span> Edit <em class="hilite2">Link</em></h3>
			<b class="navblock nav-update unsave linkeditor" title="update text">&#160;</b>
			<b class="navblock nav-exit unrevert linkeditor" title="revert text">&#160;</b>
			<b class="navblock nav-menuback linkeditor" title="back">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu4 tt_undisplay">
			<h3 class="hide"><span class="num">2</span> Image Area <em class="hilite0">Selected</em></h3>
			<b class="navblock nav-save unsave" title="save page changes">&#160;</b>
			<b class="navblock nav-revert unrevert" title="revert" title="undo last change">&#160;</b>
			<a class="navblock nav-help" target="_blank" title="pages help" href="admin/help.html">&#160;</a>
			<b class="navblock nav-convert" title="change Area Type">&#160;</b>
			<b class="navblock nav-menuback" title="unselect image area">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu5 tt_undisplay">
			<h3 class="hide"><span class="num">3</span> Edit <em class="hilite0">Image</em></h3>
			<b class="navblock nav-update unsave imageeditor" title="update image">&#160;</b>
			<b class="navblock nav-exit unrevert imageeditor" title="revert image">&#160;</b>
			<b class="navblock nav-menuback imageeditor" title="cancel editing">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu6 tt_undisplay">
			<h3 class="hide"><span class="num">3</span> Upload Image</h3>
			<b class="navblock nav-menuback uploadeditor" title="cancel upload">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu7 tt_undisplay">
			<h3 class="hide"><span class="num">2</span> Module Area <em class="hilite0">Selected</em></h3>
			<b class="navblock nav-save unsave" title="save page changes">&#160;</b>
			<b class="navblock nav-revert unrevert" title="revert" title="undo last change">&#160;</b>
			<a class="navblock nav-help" target="_blank" title="pages help" href="admin/help.html">&#160;</a>
			<b class="navblock nav-convert" title="change Area Type">&#160;</b>
			<b class="navblock nav-menuback" title="back">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu8 tt_undisplay">
			<h3 class="hide"><span class="num">3</span> Edit <em class="hilite0">Module</em></h3>
			<b class="navblock nav-update unsave moduleeditor" id="tt_updatefeed-0_0" title="update Module">&#160;</b>
			<b class="navblock nav-exit unrevert moduleeditor" id="tt_cancelfeed-0_0" title="revert Module">&#160;</b>
			<b class="navblock nav-menuback moduleeditor" title="cancel editing">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu9 tt_undisplay">
			<h3 class="hide"><span class="num">1</span> Undo Page Changes?</h3>
			<b class="navblock nav-update" title="revert to saved version">&#160;</b>
			<b class="navblock nav-menuback" title="cancel page revert">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu10 tt_undisplay">
			<div class="tt_progress"><span class="bar"></span></div>
			<h3 class="hide"><span class="num">1</span> Save Page Changes?</h3>
			<b class="navblock nav-update" title="save page">&#160;</b>
			<b class="navblock nav-menuback" title="cancel save">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu11 tt_undisplay">
			<h3 class="hide"><span class="num">2</span> Form Area <em class="hilite0">Selected</em></h3>
			<b class="navblock nav-save unsave" title="save page changes">&#160;</b>
			<b class="navblock nav-revert unrevert" title="revert" title="undo last change">&#160;</b>
			<a class="navblock nav-help" target="_blank" title="pages help" href="admin/help.html">&#160;</a>
			<b class="navblock nav-convert" title="change Area Type">&#160;</b>
			<b class="navblock nav-menuback" title="back">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu12 tt_undisplay">
			<h3 class="hide"><span class="num">3</span> Edit <em class="hilite0">Form</em></h3>
			<b class="navblock nav-update unsave formeditor" id="tt_updateform-0_0" title="update form">&#160;</b>
			<b class="navblock nav-exit unrevert formeditor" id="tt_cancelform-0_0" title="revert form">&#160;</b>
			<b class="navblock nav-menuback formeditor" title="cancel editing">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu13 tt_undisplay">
			<h3 class="hide"><span class="num">2</span> Script Area <em class="hilite0">Selected</em></h3>
			<b class="navblock nav-save unsave" title="save page changes">&#160;</b>
			<b class="navblock nav-revert unrevert" title="revert" title="undo last change">&#160;</b>
			<a class="navblock nav-help" target="_blank" title="pages help" href="admin/help.html">&#160;</a>
			<b class="navblock nav-convert" title="change Area Type">&#160;</b>
			<b class="navblock nav-menuback" title="back">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu14 tt_undisplay">
			<h3 class="hide"><span class="num">3</span> Edit <em class="hilite0">Script</em></h3>
			<b class="navblock nav-update unsave scripteditor" id="tt_updatescript-0_0" title="update script">&#160;</b>
			<b class="navblock nav-exit unrevert scripteditor" id="tt_cancelscript-0_0" title="revert script">&#160;</b>
			<b class="navblock nav-menuback scripteditor" title="cancel editing">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu15 tt_undisplay">
			<h3 class="hide"><span class="num">4</span> Edit <em class="hilite2">Element Details</em></h3>
			<b class="navblock nav-update unsave inputeditor" id="tt_updateinput-0_0" title="update element details">&#160;</b>
			<b class="navblock nav-exit unrevert inputeditor" id="tt_cancelinput-0_0" title="revert details">&#160;</b>
			<b class="navblock nav-menuback inputeditor" title="back">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu16 tt_undisplay">
			<h3 class="hide"><span class="num">3</span> Change Area Type</h3>
			<b class="navblock nav-update unsave typeeditor" id="tt_updatetype-0_0" title="update Area type">&#160;</b>
			<b class="navblock nav-exit unrevert typeeditor" id="tt_canceltype-0_0" title="revert Area type">&#160;</b>
			<b class="navblock nav-menuback typeeditor" title="cancel change Area Type">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu17 tt_undisplay">		
			<h3 class="hide"><span class="num">1</span> Choose a <em class="hilite">Layout Grid</em></h3>
			<b class="navblock nav-save unsave" title="save page changes">&#160;</b>
			<b class="navblock nav-revert unrevert" title="revert" title="undo last change">&#160;</b>
			<a class="navblock nav-help" target="_blank" title="pages help" href="admin/help.html">&#160;</a>
			<b class="navblock nav-section unsection" title="highlight sections">&#160;</b>
			<b class="navblock nav-layout" title="highlight layout grids">&#160;</b>
			<b class="navblock nav-view unview" title="highlight editable areas">&#160;</b>
			<a class="navblock nav-home" href="$bak" title="back to $bu edit menu">&#160;</a>
		</div>
		<div class="tt_topmenu tt_menu18 tt_undisplay">
			<h3 class="hide"><span class="num">2</span> Layout Grid <em class="hilite3">Selected</em></h3>
			<b class="navblock nav-save unsave" title="save page changes">&#160;</b>
			<b class="navblock nav-revert unrevert" title="revert" title="undo last change">&#160;</b>
			<a class="navblock nav-help" target="_blank" title="pages help" href="admin/help.html">&#160;</a>
			<b class="navblock nav-cut" title="save Grid to Clipboard">&#160;</b>
			<b class="navblock nav-paste unpaste" title="replace Grid from Clipboard">&#160;</b>
			<b class="navblock nav-menuback" title="unselect Layout Grid">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu19 tt_undisplay">		
			<h3 class="hide"><span class="num">1</span> Choose a <em class="hilite">Section</em></h3>
			<b class="navblock nav-save unsave" title="save page changes">&#160;</b>
			<b class="navblock nav-revert unrevert" title="revert" title="undo last change">&#160;</b>
			<a class="navblock nav-help" target="_blank" title="pages help" href="admin/help.html">&#160;</a>
			<b class="navblock nav-section" title="highlight sections">&#160;</b>
			<b class="navblock nav-layout unlayout" title="highlight layout grids">&#160;</b>
			<b class="navblock nav-view unview" title="highlight editable areas">&#160;</b>
			<a class="navblock nav-home" href="$bak" title="back to $bu edit menu">&#160;</a>
		</div>
		<div class="tt_topmenu tt_menu20 tt_undisplay">
			<h3 class="hide"><span class="num">2</span> Section <em class="hilite3">Selected</em></h3>
			<b class="navblock nav-save unsave" title="save page changes">&#160;</b>
			<b class="navblock nav-revert unrevert" title="revert" title="undo last change">&#160;</b>
			<a class="navblock nav-help" target="_blank" title="pages help" href="admin/help.html">&#160;</a>
			<b class="navblock nav-cut" title="save Section to Clipboard">&#160;</b>
			<b class="navblock nav-paste unpaste" title="replace Section from Clipboard">&#160;</b>
			<b class="navblock nav-menuback" title="unselect Section">&#160;</b>
		</div>
		<div class="tt_topmenu tt_menu21 tt_undisplay">
			<h3 class="hide"><span class="num">3</span> Edit <em class="hilite0">Clipboard</em></h3>
			<b class="navblock nav-update unsave clipeditor" id="tt_updateclip-0_0" title="update selected">&#160;</b>
			<b class="navblock nav-exit unrevert clipeditor" id="tt_cancelclip-0_0" title="revert selected">&#160;</b>
			<b class="navblock nav-menuback clipeditor" title="cancel editing">&#160;</b>
		</div>
		<input type="hidden" id="url_0" name="opt_url_0" value="$ue" />
		<input type="hidden" id="destination_0" name="opt_destination_0" value="" />
		<input type="hidden" id="type_0" name="opt_type_0" value="changesavepages" />
		<input type="hidden" id="new_0" name="opt_new_0" value="" />

	</fieldset></form>
</div>
_ADD_BAR_

#foreach my $k(sort keys %defsections){ my @v = @{ $defsections{$k} };$txt =~ s/($v[1])/<i class="tt_marker" data-marker="$v[1]"><\/i>$1<i class="tt_marker" data-marker="$v[1]"><\/i>/ism; }
$txt =~ s/(<script async charset="utf-8" src="config.js" type="application\/javascript"><\/script>)/$ajs$xjs/; # v8.1.0
$txt =~ s/(<script charset="utf-8" src="set.js" type="application\/javascript"><\/script>)/$ajs$xjs/;

$txt =~ s/(type="image\/x-icon" \/>)/$1\n$addcss/;
$txt =~ s/(<body.*?class=")(.*?)(".*?>)/$1$2 tt_editthis $3\n$addbar/;

require Encode;$txt = Encode::encode("UTF-8",$txt); 
###admin_json_out({ 'check get_pageedit:' => "f:$f \n u: $u \n\n txt: \n$txt $debug" },$origin,$callback);
print header(-type => 'text/html',-charset => 'utf-8'); #$debug.= "\n\n".$txt;print $debug; 
print $txt;

exit;
}

sub admin_get_pageentry{
my($href,$num,$ty,$pno) = @_;
my %h = %{ $href };
my $hclass = ( defined $h{'menu'}[0] && $h{'menu'}[0] =~ /\.(0|00)$/ )?'mhide':'show';
my $htclass =  ($hclass eq "mhide")?'hidden':'shown';
my $unhclass = ($hclass eq "mhide")?'show':'hide';
my $mclass = ( defined $h{'menu'}[0] && $h{'menu'}[0] =~ /\.00$/ )?'mhide':'show';
my $mtclass =  ($mclass eq "mhide")?'hidden':'shown';
my $unmclass = ($mclass eq "mhide")?'show':'hide';
my $isfolder = ( defined $h{'menu'}[0] && $h{'menu'}[0] !~ /^000/ && $h{'menu'}[0] =~ /\.*000/ )?undef:( defined $h{'children'} && scalar@{ $h{'children'} } > 0 )?undef:1;
my $clink = $h{'url'}[0];$clink =~ s/^($base)//;
my $fclink = sub_title_out($clink,\%config);$fclink.= " folder";
my $mlink = $h{'link'}[0];$mlink =~ s/^($base)//;if( $mlink ne $clink ){ $mlink = "ALIAS for $mlink";}
my $req = ( grep { $_ eq $clink } @required )?1:undef;
my $eclink = $uri->encode($clink);
my $r = "";
###if($h{'url'}[0] =~ /More-News/){ 
###admin_json_out({ 'check pageentry:' => "num:$num \n clink:$clink \n isfolder:$isfolder \n req:$req \n\n".Data::Dumper->Dump([\%h],["h"]) },$origin,$callback); 
###}

if( defined $ty && $ty eq "viewversionpages"){

my @vs = @{ $h{'versions'} };
for my $i(0..$#vs){
$clink = "Version: ".( sub_title_undate($vs[$i],\%config) );
$eclink = $uri->encode($versionbase.$vs[$i]);
$r.= '<div class="text nonmenufolder pages versionpage"><h2><a class="navtext" href="'.$versionbase.$vs[$i].'" title="view '.$clink.'" target="_blank">'.$clink.'</a>'.
'<a class="navblock nav-restore" href="'.$pl.'type=changerestorepages&amp;url='.$eclink.'" title="replace Site Page with this Version">&#160;</a>'.
'<a class="navblock nav-viewpage" href="'.$versionbase.$vs[$i].'" title="view '.$clink.'" target="_blank">&#160;</a>'.
'</h2></div>';
}

} else {

if( defined $h{'pages'} ){
$r.= '<div class="text menufolder pages '.$hclass.'page" data-title="'.$mlink.'" data-menu="'.$h{'menu'}[0].'"><div class="tt_progress"><span class="bar"></span></div><h2>'.
'<a class="navblock nav-right" href="'.$pl.'type=viewpages&amp;url='.$eclink.'" title="view '.$fclink.'">&#160;</a><a class="navtext" href="'.$pl.'type=viewpages&amp;url='.$eclink.'" title="view '.$clink.'">'.$h{'title'}[0].'</a>'.( admin_getpagemap("folder",$pno,$eclink,$unhclass,$unmclass,$htclass,$mtclass) ).'</h2></div>';

} else {
$r.= '<div class="text nonmenufolder pages '.$hclass.'page" data-title="'.$mlink.'" data-menu="'.$h{'menu'}[0].'"><div class="tt_progress"><span class="bar"></span></div><h2>'.
'<a class="navblock nav-edit" href="'.$pl.'type=editpages&amp;url='.$eclink.'" title="edit '.$clink.'">&#160;</a>'.( admin_getpagemap("page",$pno,$eclink,$unhclass,$unmclass,$htclass,$mtclass) );
if( defined $isfolder ){
if( $clink eq $homeurl ){ $r.= '<span class="navblock navtext index">Home Page</span>'; }
} else {
if( defined $h{'children'} && scalar @{ $h{'children'} } > 0 ){ $r.= '<span class="navblock navtext index">Index Page</span>'; }
}
$r.= '<a class="navtext" href="'.$pl.'type=editpages&amp;url='.$eclink.'" title="edit '.$clink.'">'.$h{'title'}[0].'</a></h2></div>';
}

}

return $r;
}

sub admin_getpagemap{
my ($ty,$pno,$eclink,$unhclass,$unmclass,$htclass,$mtclass,$nowrap) = @_;
my $r = (defined $nowrap)?'':'<span class="inputline mapper" data-mref="'.$eclink.'">';
if( $ty eq "folder" ){
$r.= '<input class="'.$unhclass.'pages" id="foldernew-'.$mtclass.'_'.$pno.'" name="pre_new-'.$mtclass.'_0" tabindex="0" type="hidden" value="'.$unhclass.'folderpages"><a class="mlist-submit navblock nav-folder'.$unhclass.'" title="Folder and contents are '.$htclass.' in Menus">&#160;</a>'.
'<input class="'.$unmclass.'mappages" id="foldermapnew-'.$htclass.'_'.$pno.'" name="pre_new-'.$htclass.'_0" tabindex="0" type="hidden" value="'.$unmclass.'mappages"><a class="mlist-submit navblock nav-'.$unmclass.'map" title="Folder and contents are '.$mtclass.' in Sitemap">&#160;</a>';
} else {
$r.= '<input class="'.$unhclass.'pages" id="new-'.$mtclass.'_'.$pno.'" name="pre_new-'.$htclass.'_0" tabindex="0" type="hidden" value="'.$unhclass.'pages"><a class="mlist-submit navblock nav-'.$unhclass.'" title="Page is '.$htclass.' in Menus">&#160;</a>'.
'<input class="'.$unmclass.'mappages" id="mapnew-'.$htclass.'_'.$pno.'" name="pre_new-'.$mtclass.'_0" tabindex="0" type="hidden" value="'.$unmclass.'mappages"><a class="mlist-submit navblock nav-'.$unmclass.'map" title="Page is '.$mtclass.' in Sitemap">&#160;</a>';
}
$r.= (defined $nowrap)?'':'</span>';
return $r;
}

sub admin_getsubmenu{
my ($n,$u,$aref) = @_;
my @ar = @{ $aref };
$n =~ s/\.($htmlext)$//; ##==pilbeam
my @path = split/$qqdelim/,$n;
my @m = ();
my $dbug = "";
if( $n eq $docview ){
@m = @ar;
} else {
my ($mref,$msg) = admin_drill_submenu(\@path,\@ar,0,$#path,"");
@m = @{$mref};
$dbug.= $msg;
###admin_json_out({ 'check submenu:' => "n: $n \nu: $u \npath:[\n @path \n] = $#path \n\ndbug:$dbug \n\n".Data::Dumper->Dump([\@m],["m"]) },$origin,$callback);
}
return @m;
}

sub admin_html_in{
my ($f,$utf) = @_;
my $t = "";
my ($ierr,$otxt) = sub_get_contents($f,\%config,undef,$utf);
admin_json_out({ 'error' => "admin html in error: \n$ierr \n $f \n $otxt \n $debug" },$origin,$callback) if defined $ierr;
$t = $otxt;
$t =~ s/(<base href=")(.*?)(" \/>)/$1$baseview$3/;
$t =~ s/(<body)\s+(id="body0")/$1 data-user="$adminuser" $2/; #"
###admin_json_out({ 'check html_in:' => "f:$f \n\nt: \n\n$t \n"},$origin,$callback);
return $t;
}

sub admin_html_out{ 
my ($t) = @_;
$t =~ s/(<div class="text small righter">\s*<p>)\&#169; thatsthat ([0-9]+)(<\/p>\s*<\/div>)/$1$updated$3/;
$t =~ s/(<p class="sitename">).*?(<\/p>)/$1<b><a class="navtext" href="$baseview" title="Back to Live Site" target="_blank">&#60;&#60; Back to Live Site<\/a><\/b>$userdisplay $2/;
print header(-type => 'text/html',-charset => 'utf-8');
print $t;
exit;
}

sub admin_json_out{
my ($jref,$orig,$call) = @_;
my $type = ref $jref || undef;
if( defined $type ){
eval "use JSON";
if($@){ admin_json_print( Data::Dumper->Dump([$jref],["query"]) ); } else { admin_json_print( "{ \"query\":".JSON->new->allow_nonref->utf8->encode($jref)." }",$orig,$call ); }
} else {
admin_json_print($jref,1,$call);
}
}

sub admin_json_print{
my ($jtxt,$q,$cback) = @_;
print header(-type => 'application/javascript',-charset => 'utf-8');
if( defined $cback && $cback ne "" ){
print "$cback( $jtxt )";
} elsif( defined $q ){ 
print "{ \"query\":[ \"$jtxt\" ] }";
} else {
print $jtxt;
}
exit;
}

sub admin_drill_issue{
my ($pref,$ishref) = @_;
my @p = @{$pref};
my %ish = (defined $ishref)?%{$ishref}:();

for my $i(0..$#p){ 
if( defined $p[$i]->{'issues'} ){ 
$debug.= "$p[$i] = @{$p[$i]->{'issues'}} \n";
$ish{ $p[$i]->{'url'}[0] } = '';my @iss = @{ $p[$i]->{'issues'} };for my $n(0..$#iss){ $ish{ $p[$i]->{'url'}[0] }.= '<span> - '.$iss[$n].'</span>'; } 
}
if( defined $p[$i]->{'pages'} ){ %ish = %{ admin_drill_issue($p[$i]->{'pages'},\%ish); }; }
}

return \%ish;
}

sub admin_list{
# 'folders' => { 
# 'Canvas' => {},
# 'Sandbox' => { 'westfield-house' => {} },
# 'Images' => { 'elements' => {},'socialmedia' => {},'videos' => {},'slideshow' => {},'logos' => { 'customers' => {} },'interface' => {},'news' => {},'team' => {},'backgrounds' => {} },
# 'PDF' => { 'data-sheets' => {},'maps' => {},'Vacancies' => {},'case-studies' => {} } 
# },
#
# 'files' => { 
# 'documents/Digital/Posters/I-couldnt-believe-my-eyes/Print/A4---300dpi-CMYK.pdf' => {
# 'area' => ['UK-Europe],
# 'author' => ['Ben Bloke'],
# 'focus' => ['Financial','Maverick'],
# 'size' => ['4166k'],
# 'group' => ['I couldn\'t believe my eyes poster','This is the other Group text area.'],
# 'text' => ['An A2 Print document that is meant to be a test.', 'Another line of text goes here.'],
# 'href' => ['documents/Digital/Posters/I-couldnt-believe-my-eyes/Print/A4---300dpi-CMYK.pdf'],
# 'issues' => ['Image will not be editable until permissions are changed to 664' ],
# 'url' => ['A4---300dpi-CMYK.pdf'],
# 'parent' => ['documents/Digital/Posters/I-couldnt-believe-my-eyes/Print'],
# 'epoch' => [1482236038],
# 'epochcreated' => [1479081600],
# 'menuname' => ['A4---300dpi-CMYK.pdf'],
# 'path' => ['documents','Digital','Posters','I-couldnt-believe-my-eyes','Print','A4---300dpi-CMYK.pdf'],
# 'tags' => ['England','Ireland','Scotland','Wales'],
# 'image' => ['A4---300dpi-CMYK_thumb.jpg'],
# 'created' => ['14/11/2016' ],
# 'published' => ['20/12/2016'],
# 'title' => ['A4 - 300dpi CMYK.pdf'],
# 'versions' => [ 'News_RSM-Becomes-Member-of-MSPAlliance~~14:05:40-17--05--2017.html' ]
# }
# },
#
# 'pages' => [
# { 'link' => ['index.html'],'shortname' => ['Home'],'epoch' => [1479479457],'blocks' => [],'date' => ['05/10/16'],'menu' => ['000.0'],'menuname' => ['index'],'size' => ['20k'],'published' => ['18/11/2016'],'url' => ['index.html'],'title' => ['Home'] }],
# { 'link' => ['News.html'],'shortname' => ['News'],'epoch' => [1479479458],'blocks' => [], 'date' => ['05/10/16'],'menu' => ['001'],'menuname' => ['News'],'size' => ['22k'],'published' => ['18/11/2016'],'url' => ['News.html'],'title' => ['News'],'pages' => [ { 'link' => ['News_RSM-assists-government-agency-zCloud-transition.html'],'shortname' => ['Government zCloud Transition'],'epoch' => [1479479458],'blocks' => ['<div class=\"row editblock pulled\">\n <div class=\"edittitle\"> <div class=\"text\"><span>RSM assists government agency zCloud transition</span></div></div></div>'] } ] }
# ]
my ($u,$fu,$ltype,$ldest,$resp) = @_;
my $uname = $u;$uname =~ s/^($obase|$baseview)//;
my $mu = $uname;$uname =~ s/\.($htmlext)$//;
my $archive = ( $uname =~ /($docview)archive/i )?1:undef;
if( $ltype =~ /^view/ && $ltype ne "viewpages" ){ $ldest = $base.$adminbase."view.".$htmlext; }
my ($cterr,$ctref) = sub_get_all($fu,$ltype,\%config);
admin_json_out({ 'error' => "alert: no useable data retrievable by server: $cterr $debug" },$origin,$callback) unless defined $ctref && !defined $cterr;
my %m = %{ $ctref };
my %folders = ();
my %files = ();
my @menu = ();
my @submenu = ();
my $nonempty = 1;
my $respoint = (defined $resp)?$resp:"";
my $txt = "";
my $h = "";
my $r = "";
my $exref = undef;

if( $ltype =~ /view(alert|all|fix)$/ ){ #alert 
if( !defined $m{'alerts'} ){ %{ $m{'alerts'} } = (); }

$m{'alerts'} = admin_drill_issue($m{'pages'},$m{'alerts'});

foreach my $k( sort keys %{ $m{'files'} } ){ 
if( defined $m{'files'}{$k}{'issues'} ){ 
$debug.= "$k = @{$m{'files'}{$k}{'issues'}} \n";
$m{'alerts'}{$k} = '';my @iss = @{ $m{'files'}{$k}{'issues'} };for my $i(0..$#iss){ $m{'alerts'}{$k}.= '<span> - '.$iss[$i].'</span>'; } 
}
}
###admin_json_out({ 'check admin_list 0' => "\nfu:$fu \nltype:$ltype \nu:$u \nldest:$ldest \narchive:$archive \n".Data::Dumper->Dump([$m{'alerts'}],["alerts"])." \n\n$debug" },$origin,$callback);

if( scalar keys %{ $m{'alerts'} } < 1 ){ $m{'alerts'}{'No Alerts'} = '<span>Currently no files require attention.</span>'; }
}
###admin_json_out({ 'check admin_list 1' => "\nfu: $fu \nltype: $ltype \nu: $u \nldest: $ldest \npages: $pages \ndocuments: $documents \ndlevel: $dlevel \narchive:$archive\n\n".Data::Dumper->Dump([\%editusers],["editusers"])." \nnew: $new \n\n$debug \n".Data::Dumper->Dump([\%m],["m"])."" },$origin,$callback);

if( defined $origin){
admin_json_out({ 'check admin_list: REMOTE' => "$debug \nltype: $ltype \nfu: $fu \nbase:$base \nnwbase:$nwbase \nobase: $obase \nsubdir: $subdir \nbaseview:$baseview \npages: $pages \ndlevel: $dlevel \norigin: $origin \n\n".Data::Dumper->Dump([\%m],["m"]) },$origin,$callback);
} else {

$txt = admin_html_in($ldest);
###admin_json_out({ 'check admin_list 1' => "u: $u \nuname: $uname \nltype:$ltype\n fu:$fu\n \npages:$pages\n documents:$documents\n ldest:$ldest \n\n".Data::Dumper->Dump([\%m],["m"])."\n\ntxt:$txt \n\n\n $debug" },$origin,$callback);
if( $pages eq "include" || $documents eq "include" ){
if( $txt =~ /<div class="area setnavarea"><\/div>/ ){ 

if( defined $pages && defined $m{'pages'} ){

@menu = ( $ltype eq "viewversionpages")?@{ admin_drill_pagelist($m{'pages'},\@menu,$mu) }:@{ $m{'pages'} };
###admin_json_out({ 'check admin_list 2:' => "ltype: $ltype \ndlevel:$dlevel \nuname:$uname \n".Data::Dumper->Dump([\@menu],["menu"]) },$origin,$callback);
if( scalar @menu > 0 ){
if( $dlevel > 0){ 
@submenu = admin_getsubmenu($mu,$u,\@menu);
if( defined $defsort{$uname.".$htmlext"} ){ @submenu = sort { $b->{'epoch'}[0] <=> $a->{'epoch'}[0] || lc $a->{'title'}[0] cmp lc $b->{'title'}[0] } @submenu; }
###admin_json_out({ 'check admin_list 3' => "u: $u \nuname: $uname \n".Data::Dumper->Dump([\@submenu],["submenu"]) },$origin,$callback);
if( scalar @submenu > 0 ){ for my $i(0..$#submenu){ my $ind = ($uname ne "documents/" && $i < 1)?$i:undef;$r.= admin_get_pageentry($submenu[$i],$ind,$ltype,$i); } } else { $r.= '<div class="text pages"><h2><span class="info">'.$emptymsg.'</span></h2></div>'; }
}
}

} else {
if( defined $documents && defined $m{'folders'} ){ ($r,$nonempty) = admin_set_folders($r,$m{'folders'},$fu,$nonempty,$archive); }
if( defined $documents && defined $m{'files'} ){ ($r,$nonempty) = admin_set_files($r,$m{'files'},$fu,$nonempty); }
}

}
}

###admin_json_out({ 'check admin_list 4' => "u: $u \nsubdir:$subdir \nuname: $uname \nr:$r \n\n" },$origin,$callback);
if( $nonempty < 0.5){ $r = '<div class="text"><h2><span class="info">'.$emptymsg.'</span></h2></div>';$exref = {'undownload' => 1}; }
if( $respoint ne "" ){ $r.= '<div class="text"><h2><div class="info restore">'.$respoint.'</div></h2></div>'; }
$txt =~ s/<div class="area setnavarea"><\/div>/<div class="navarea"><div class="column"><div class="row">$r<\/div><\/div><\/div>/; 
if( $txt =~ /<div class="area setheaderarea"><\/div>/ ){ $h = admin_set_headers( $h,$dlevel,( scalar @submenu ),$fu,( (defined $pages && defined $m{'pages'})?"pages":undef ),$exref,undef,undef,undef,$archive );$txt =~ s/<div class="area setheaderarea"><\/div>/$h/; }
if( defined $m{'alerts'} && keys %{$m{'alerts'}} > 0 ){ my $s = admin_set_alerts($ltype,$m{'alerts'});$txt =~ s/<div class="text setfilearea"><\/div>/$s/; }

###admin_json_out({ 'check admin_list 5: LOCAL' => "$debug \nid: $id \ntype: $type \nfu: $fu \nbase:$base \nnwbase:$nwbase \nobase: $obase \nsubdir: $subdir \nbaseview:$baseview \nsubmenu: [ @submenu ] \npages: $pages \ndlevel: $dlevel \norigin: $origin \n\n".Data::Dumper->Dump([\%m],["m"]) },$origin,$callback);
admin_html_out($txt);
}
}

sub admin_menu_calc{
my ($ins,$s) = @_;
my $ex = "";
my $n = 0;
my $t = $s;if( $t =~ /\.(0|00)$/ ){ $ex = $1;$t =~ s/\.(0|00)$//; }
my $ind = ( $t =~ /\.000$/ )?'.000':'';
if( $ins eq "add" ){ 
if( $t !~ /\./ ){  
$t = sub_numberpad($t+1,'100'); #003 = 4 010 = 11 003.000 = 4
} elsif( $t =~ /\.([0-9])([0-9])([0-9])$/ ){
$t = sub_numberpad($t+0.001,'100'); #001.003 = 1.004 001.009 = 1.010
} else {
$t = $t+0.000001; #003.005007 = 004.005008
}
$t.= $ind; #.000
} else { 
$t =~ s/000$/001/; #001.000 = 001.001 002.003000 = 002.003001
}
return $t.$ex;
}

sub admin_menu_guess{ my ($pref,$p,$n) = @_;my @pt = @{$pref};my $pmen = undef;if( defined $pt[$n-1] ){ $pmen = @{ $pt[$n-1]->{'menu'} }[0];}my $nmen = undef;if( defined $pt[$n+1] ){ $nmen = @{ $pt[$n+1]->{'menu'} }[0]; }return ( defined $nmen )?$nmen:( defined $pmen )?admin_menu_calc("add",$pmen):admin_menu_calc("first",$p); }

sub admin_menu_tools{
my ($ty,$fu) = @_;
my $lstxt = admin_html_in($base.$adminbase."updatemenus.".$htmlext);
my $uf = $fu;$uf =~ s/^($baseview|$base)//;
my %dd = ( 'new-menu' => $new,'old' => $old );
my @mls = ();
my @cm = ();
my $kk = "";
my $mm = "";
my $ml = "";
my $wtype = $ty;
my $dd = undef;
###admin_json_out({ 'check listmenupages' => "ty:$ty \nfu:$fu \nnew:$new \nold: $old\nid:$id \n\n".Data::Dumper->Dump([\%pdata],["PDATA"])." \n\n $debug" },$origin,$callback);

if( $ty eq "resetmenupages" ){
###admin_json_out({ 'check resetmenupages' => "ty:$ty \nfu:$fu \nnew:$new \nold: $old \nid:$id\n\n".Data::Dumper->Dump([\%pdata],["PDATA"])." \n\n $debug" },$origin,$callback);
} else {

if( $ty eq "newlinkpages" || $ty eq "newtitlepages" ){
my $nsw = ($ty eq "newtitlepages")?"title":"link";
###admin_json_out({ 'check '.$ty => "ty:$ty \nnsw:$nsw \nfu:$fu \nnew:$new \nold: $old\n\n".Data::Dumper->Dump([\%pdata],["PDATA"])." \n\n $debug" },$origin,$callback);
my ($nferr,$nf) = sub_admin_new('page',$fu,$uf,{ 'new-'.$nsw.'url' => $new,'old' => $old,'changed' => $pdata{'changed'} },\%config);
if( $ty eq "newlinkpages" ){
print "Location: ".$pl."type=editpages&url=".( $uri->encode($new) )."\n\n";
exit(0);
} else {
$kk.= "<u>$new</u>";
$kk.= (defined $nferr)?"<u class=\"error\">Warning: problem with updating $nsw $nf: $nferr = $debug</u>":"<u class=\"update\">[ updated ]</u>";
###admin_json_out({ 'check '.$ty.' 1' => "ty:$ty \nurl:$url \nfu:$fu\nold: $old \nnew:$new \n\n kk: $kk \n\n $debug" },$origin,$callback);
admin_json_out({ 'result' => $kk },$origin,$callback);
}
}

if( $ty eq "newmenupages" ){
###admin_json_out({ 'check newmenupages' => "ty:$ty \nfu:$fu \nnew:$new \nold: $old \nid:$id\n\n".Data::Dumper->Dump([\%pdata],["PDATA"])." \n\n $debug" },$origin,$callback);
if( defined $id && $id eq "resetmenupages" ){ 
$wtype = "checkmenupages"; 
} else {
my ($nferr,$nf) = sub_admin_new('page',$fu,$uf,\%dd,\%config);
$kk.= "<span class=\"mtitle\">Menu: </span><span>$new</span>";
$kk.= (defined $nferr)?"<u class=\"error\">Warning: problem with updating menu $nf: $nferr = $debug</i>":"<u class=\"update\">[ updated $nf ]</u>";
admin_json_out({ 'result' => $kk },$origin,$callback); 
}
}

}
# 0 = index.html|000.0|1 
# 1 = Mainframe-Services.html|001.000|1 
# 2 = index.html|000.0|1<i class="suggest">URL Tag <u class="old">index.html</u> is wrong - should be <u class="new">Mainframe-Services_Performance-Assurance.html</u></i> 
# 3 = Mainframe-Services_Onsite-&-Remote-Ad--Hoc-Skills-&-Resources.html|001.001|2 

my ($mlref,$cmref) = admin_reset_menus($ty,$wtype,$uf,{},"showall");
@mls = @{$mlref};
@cm = @{$cmref};
###admin_json_out({ 'check get_'.$ty.' 3' => "ty:$ty \nurl:$url \nfu:$fu \nowtype:$wtype n\nmls: ".Data::Dumper->Dump([\@mls],["mls"])." \n\ncm: \n\n".Data::Dumper->Dump([\@cm],["cm"])." \n\n $debug" },$origin,$callback);

if( $ty eq "resetmenupages" ){
admin_menu_tools($fu,"listmenupages");
} elsif( $wtype eq "checkmenupages" ){
pop @cm;
$kk.= '<div class="mlist"><div class="tt_progress"><span class="bar"></span></div><span><a class="mlist-reset" href="'.$pl.'type=resetmenupages" title="reset menus">Click to Reset Menus As Below</a></span></div><div class="mlist">'.(join "</div>\n<div class=\"mlist\">",@cm).'</div>';
###admin_json_out({ 'result' => $kk },$origin,$callback); 
} else {
for my $i(0..$#mls){ 
my @ut = ( $mls[$i] =~ /^(.*?\.$htmlext)\|(.*?)\|([0-9.]+)(.*?)$/ );
if( scalar @ut > 2 ){
my @mn = ($ut[1],'999.00');
my @warn = ( "","","","","" );
my $uold = $ut[0];
my %ha = %{ $cm[0] };

my $alt = ( $i > 0 && defined $ha{$uold} )?$ha{$uold}{'new'}:"";$debug.= "$i = @ut = $alt = $ha{$uold}{'new'}\n";
if( $alt ne "" ){ $warn[0] = '<i class="suggest">MENU Number <u class="dupe">'.$mn[0].'</u> is not in sequence - try <u class="new">'.$alt.'</u></i>'; }
$ml.= '<div class="mlist mstep'.$ut[2].'" data-menu="'.$mn[0].'"><div class="tt_progress"><span class="bar"></span></div>	';
$ml.= '<div class="mline"><u>'.$uold.'</u></div>';
$ml.= ($warn[0] eq "")?'<div class="mline"><span class="mtitle"> Menu: </span><span>'.$mn[0].'</span><span class="ok">ok</span></div>':'<div class="mline">'.$warn[0].'<span class="mtitle"> Reset: </span><input id="used'.$i.'_0" name="used'.$i.'_0" type="checkbox" /><label for="used'.$i.'_0" class="" tabindex="0" title="change menu number"><span>'.$mn[0].'</span></label><span class="inputline unvalue unmenu"><label for="new-'.$ut[0].'_0">New: </label><input id="new-'.$ut[0].'_0" class="menu" name="pre_new-'.$ut[0].'_0" type="text" maxlength="16" value="'.$alt.'" /><a id="mlist_'.$ut[0].'_0" class="mlist-submit" title="change menu ref">change</a><u class="reset">Reset all Menus: </u><input id="checkfile'.$i.'_0" name="opt_checkfile'.$i.'_0" value="resetmenupages" type="checkbox"><label for="checkfile'.$i.'_0" class="css-check">&#160;</label></span></div>';

if( defined $ut[3] ){
if( $ut[3] =~ /(<i class="suggest">URL Tag <u class="old">)(.*?)(<\/u> is wrong - should be <u class="new">)(.*?)(<\/u><\/i>)/ ){ 
$warn[1] = $1.$2.$3.$4.$5;$uold = $2;$ut[0] = $4; 
$ml.= '<div class="mline">'.$warn[1].'<span class="mtitle"> URL Tag: </span><input id="used'.$i.'_1" name="used'.$i.'_1" type="checkbox" /><label for="used'.$i.'_1" class="" tabindex="0" title="change URL tag"><span>'.$uold.'</span></label><span class="inputline unfolder unvalue"><label for="new-'.$ut[0].'_1">New: </label><input id="new-'.$ut[0].'_1" class="url" name="pre_new-'.$ut[0].'_1" type="text" maxlength="120" value="'.$ut[0].'" /><a id="mlist_'.$ut[0].'_1" class="mlist-submit" title="change URL tag">change</a></span></div>';
}
if( $ut[3] =~ /(<i class="suggest">H1 Tag is missing - try <u class="new">)(.*?)(<\/u><\/i>)/ ){ 
my $hold = "(missing)";my $sh1 = "";$warn[2] = $1.$2.$3;$hold = "";$sh1 = $2; 
$ml.= '<div class="mline">'.$warn[2].'<span class="mtitle"> H1 Tag: </span><input id="used'.$i.'_2" name="used'.$i.'_2" type="checkbox" /><label for="used'.$i.'_2" class="" tabindex="0" title="change H1 tag"><span>'.$hold.'</span></label><span class="inputline unfolder unvalue"><label for="new-'.$uold.'_2">New: </label><input id="new-'.$uold.'_2" class="title" name="pre_new-'.$uold.'_2" type="text" maxlength="120" value="'.$sh1.'" /><a id="mlist_'.$uold.'_2" class="mlist-submit" title="change H1 tag">change</a></span></div>';
}
if( $ut[3] =~ /(<i class="suggest">TITLE Tag <u class="old">)(.*?)(<\/u> is wrong - try <u class="new">)(.*?)(<\/u><\/i>)/ ){ 
my $told = "";my $ttitle = "";$warn[3] = $1.$2.$3.$4.$5;$told = $2;$ttitle = $4; 
$ml.= '<div class="mline">'.$warn[3].'<span class="mtitle"> TITLE Tag: </span><input id="used'.$i.'_3" name="used'.$i.'_3" type="checkbox" /><label for="used'.$i.'_3" class="" tabindex="0" title="change TITLE tag"><span>'.$told.'</span></label><span class="inputline unfolder unvalue"><label for="new-'.$uold.'_3">New: </label><input id="new-'.$uold.'_3" class="title" name="pre_new-'.$uold.'_3" type="text" maxlength="120" value="'.$ttitle.'" /><a id="mlist_'.$uold.'_3" class="mlist-submit" title="change TITLE tag">change</a></span></div>';
}
if( $ut[3] =~ /(<i class="suggest">TITLE Tag <u class="old">)(.*?)(<\/u> does not match H1 Tag - try <u class="new">)(.*?)(<\/u><\/i>)/ ){ 
my $sold = "";my $smatch = "";$warn[4] = $1.$2.$3.$4.$5;$sold = $2;$smatch = $4; 
$ml.= '<div class="mline">'.$warn[4].'<span class="mtitle"> TITLE Tag: </span><input id="used'.$i.'_4" name="used'.$i.'_4" type="checkbox" /><label for="used'.$i.'_4" class="" tabindex="0" title="change TITLE tag"><span>'.$sold.'</span></label><span class="inputline unfolder unvalue"><label for="new-'.$uold.'_4">New: </label><input id="new-'.$uold.'_4" class="title" name="pre_new-'.$uold.'_4" type="text" maxlength="120" value="'.$smatch.'" /><a id="mlist_'.$uold.'_4" class="mlist-submit" title="change TITLE tag">change</a></span></div>';
}
#if( $ut[3] =~ /<i class="suggest">(.*?)( will not be editable until permissions are changed to 664<\/i>)/ ){  }
}

$ml.= '</div>';
}
}
###admin_json_out({ 'check get_'.$ty.' 1' => "ty:$ty \nurl:$url \nfu:$fu \n\nml: $ml\n\n $debug" },$origin,$callback);

}

$lstxt =~ s/(<div class="text nav-box">\s*<a class=".*?">.*?<\/a>\s*<h3>).*?(<\/h3>\s*<\/div>)/$1Admin Menu Tools$2$kk$ml/;
admin_html_out($lstxt);
}

sub admin_reset_menus{
my ($ty,$wty,$u,$mref,$show,$speed) = @_;
my @nmls = admin_display_reorder($base,$mref,$ty,$show);
my @cm = ();
###admin_json_out({ 'check resetmenus 1' => "type:$ty \nwty:$wty \nspeed:$speed \nu:$u \nfullurl:$fullurl \nnmls: \n\n".( join "\n",@nmls )."\n\n $debug" },$origin,$callback);
@cm = sub_admin_rankpages($wty,$u,(join "||",@nmls),\%config,$speed); 
###admin_json_out({ 'check resetmenus 2' => "type:$ty \nwty:$wty \nu:$u \nnmls: \n\n".( join "\n",@nmls )."\n\n \ncm: \n\n".Data::Dumper->Dump([\@cm],["cm"])." \n\n $debug" },$origin,$callback);
return (\@nmls,\@cm);
}

sub admin_restore{
# [ [ 'restore~~11:11:13-07--11--2017',1510055953 ],[ 'restore~~11:11:03-07--11--2017',1510055583 ] ]
# [ '/var/www/vhosts/pecreative.co.uk/rsmpartners.com/UPLOADS/RESTORE/restore~~15:09:23-08--11--2017','/var/www/vhosts/pecreative.co.uk/rsmpartners.com/UPLOADS/RESTORE/Full-Set-with-Skills~~15:09:23-08--11--2017' ]
my ($ins,$ps) = @_;
my @p = ( defined $ps )?@{$ps}:();
my @dirs = ();
my @kdirs = ();
my @pdirs = ();
my @new = ();
my @old = ();
my @js = ();
my $allow = $config{'delete_limit'};
my $dn = 0;
my $an = 0;
my $dbug = "";
my $msg = "";
my $nf = undef;
my $nb = undef;

if( $ins eq "restoredelete" ){

$dbug.= "Restore Point deleted. \n";
if( -d $p[0] ){ my $dferr = sub_admin_delete("folder",$p[0],\%config);$dbug = "error deleting folder $p[0]: $dferr \n" if defined $dferr; } else { $dbug = "error deleting $p[0]: $! \n"; }
$msg = $dbug;

} elsif( $ins eq "restoreprotect" ){

$dbug = "Restore Point is now protected. \n";
mv ($p[0],$p[1]) or $dbug = "error renaming $p[0] to $p[1]: $!";
if( -d $p[1]){
$nb = $p[0];$nb =~ s/^($base)//;
$nf = $p[1];$nf =~ s/^($base)//;
@old = sub_get_changed("pages","search",$p[1],\%config,$nb,$nf,"alter",$regexp,"code",$usecase,"inlistdir");
}
$msg = $dbug;

} elsif( $ins eq "restoresite" ){

$msg = "Site restored.";
$nf = $p[0];
$dbug.= "restore folder $nf \n"; # return "ins:$ins \nnf:$nf \n $dbug \n";
if( -d $nf ){
@old = sub_get_html($base,\%config,undef,$auxfiles);
@new = sub_get_html($nf,\%config);
@js = sub_get_html($nf,\%config,undef,$auxfiles,"auxonly");
for my $i(0..$#old){ if( -f $old[$i] ){ my $oerr = sub_admin_delete("restore",$old[$i],\%config);$dbug.= (defined $oerr)?"$oerr \n":" deleted ok \n"; } else { $dbug.= " not found\n"; } }
my $bv = $nf;$bv =~ s/^($base)//;$bv =~ s/(\/+)$//;
$dbug = admin_restore_move("restore",\@new,$baseview.$bv.'/',$baseview,$base,$dbug);
###return "nf:$nf \n\n aux:".$base.$bv."/ to $base \n\n js:[ ".( join "\n",@js )." ] \n\n new: [ ".( join "\n",@new )." ] \n\n old: [ ".( join "\n",@old )." ] \n\n copy: ".$nf.'/'.$docview.$imagefolder." to ".$base.$docview.$imagefolder." \n";
$dbug.= sub_search_aux($base.$bv.'/',$base,\@js,[ '../../../LIB/','../../../FONTS/' ],[ 'LIB/','FONTS/' ],\%config);
my $nferr = sub_admin_delete("folder",$base.$docview.$imagefolder,\%config);$dbug.= "error deleting folder $docview.$imagefolder: $nferr \n" if defined $nferr;
my $derr = sub_folder_copy($base.$bv.'/'.$docview.$imagefolder,$base.$docview.$imagefolder,\%config);$dbug.= "error copying folder ".$nf.'/'.$docview.$imagefolder.": $derr \n" if defined $derr;
$dbug.= 'copied folder '.$nf.'/'.$docview.$imagefolder.' \n';
}
###$msg.= $dbug;

} else {

@dirs = sub_get_restored(\%config);
for my $i(0..$#dirs){ if( $dirs[$i][0] =~ /^restore($repdash$repdash)/ ){ push @kdirs,$dirs[$i]; } else { push @pdirs,$dirs[$i]; } }
$dn = scalar @kdirs;
$an = scalar @pdirs;
$dbug.= "list folder $restorebase [ $dn + $an <> ".$allow." ] = ".Data::Dumper->Dump([\@dirs],["dirs"])." \n";

if( $ins eq "save"){

if( ($dn + $an) >= $allow ){
if( $dn > 0 ){
my $dd = $base.$restorebase.$kdirs[$#kdirs][0];
if( -d $dd ){ my $dferr = sub_admin_delete("folder",$dd,\%config);if(defined $dferr){$dbug = "error deleting folder $dd: $dferr \n";} else {$dn--;} } else { $dbug = "error deleting $dd: $! \n"; }
#return "Restore Point limit has been reached - deleting $dd $dbug";
} else {
return "Restore Point limit has been reached - please delete one or more saved Restore Points.";
}
}
$nf = 'restore'.$repdash.$repdash.( sub_get_date(time,\%config,"-","version") );$nf =~ s/-/--/g;$nf =~ s/ /-/g;
return "error creating folder [ $restorebase$nf ]: please wait for 60 seconds \n" if -d $base.$restorebase.$nf;
my @js = sub_get_html($base,\%config,undef,$auxfiles,"auxonly");
my $err = sub_folder_create($base.$restorebase.$nf,\%config,\@js);
return ("error creating folder [ $restorebase$nf ]: $err \n") if defined $err;
$dn++;
$dbug.= 'created folder '.$restorebase.$nf.' \n';
my $derr = sub_folder_copy($base.$docview.$imagefolder,$base.$restorebase.$nf.'/'.$docview.$imagefolder);
$dbug.= 'copied folder '.$restorebase.$nf.'/'.$docview.$imagefolder.' \n';
$msg.= '<div class="mlist"><div class="tt_progress"><span class="bar"></span></div>	';
$msg.= '<div class="mline">Restore Point created ( '.$dn.' of '.( $allow - $an ).' )</div>';
$msg.= '<div class="mline" data-title="'.$nf.'"><input id="used0_0" name="used0_0" type="checkbox" /><label for="used0_0" tabindex="0" title="Add Name">Name and save this Restore Point permanently:</label><span class="inputline unvalue unurl"><label for="new-url_0">Restore Point Name: </label><input id="new-url_0" class="protect" name="pre_new-url_0" type="text" maxlength="30" value="New Restore Point" /><a id="mlist_url_0" class="mlist-submit" title="save Restore Point">save</a></span></div>';
$msg.= '</div>';
$dbug.= admin_restore_move("save",$ps,$baseview,$baseview.$restorebase.$nf,$restorebase.$nf,$dbug);

} else {

for my $i(0..$#dirs){
my $du = $dirs[$i][0];
if( $du =~ /^restore$repdash$repdash/){ $du =~ s/(--)/\//g;$du =~ s/-/ on /; } else { $du =~ s/$repdash$repdash(.*?)$/ \($1\)/;$du =~ s/(--)/\//g;$du =~ s/-/ /g; }$du =~ s/^.+($repdash)//;
my $onn = $dirs[$i][0];$onn =~ s/($repdash$repdash.*?)$//;
$msg.= '<div class="text nonmenufolder pages"><div class="tt_progress"><span class="bar"></span></div><h2>';
$msg.= '<div class="navblock navicon"><div class="tt_progress"><span class="bar"></span></div><div class="mline" data-title="'.$dirs[$i][0].'"><input id="used'.$i.'_0" name="used'.$i.'_0" type="checkbox" /><label class="navblock nav-rename" for="used'.$i.'_0" tabindex="0" title="Rename">&#160;</label><span class="inputline unvalue unurl"><label for="new-url_0">Rename: </label><input id="new-url_0" class="protect" name="pre_new-url_0" type="text" maxlength="30" value="'.$onn.'" /><a id="mlist_url_0" class="mlist-submit" title="rename Restore Point">save</a></span></div></div>';
$msg.= ($adminuser =~ /admin$/)?'<a class="navblock tt_directupdate nav-upload" href="'.$pl.'type=restoresite&amp;url='.( $uri->encode($dirs[$i][0]) ).'" title="revert Site Pages to this Restore Point">&#160;</a>':'<span class="navblock nav-upload unupload" title="admin users only">&#160;</span>';
$msg.= '<a class="navblock tt_directupdate nav-delete" href="'.$pl.'type=restoredelete&amp;url='.( $uri->encode($dirs[$i][0]) ).'" title="delete this Restore Point">&#160;</a>';
$msg.= '<span class="navtext">Restore Point: <i class="ired">'.$du.'</i></span><a class="navblock nav-viewpage" href="'.$baseview.$restorebase.$dirs[$i][0].'" title="view '.$dirs[$i][0].'" target="_blank">&#160;</a>';
$msg.= '</h2></div>';
}

}
}

#$msg.= $dbug;
return $msg;
}

sub admin_restore_move{
# nb: //rsmpartners.com/
# nfb: //rsmpartners.com/UPLOADS/RESTORE/restore~~13:29:48-20--11--2017/
# nf: UPLOADS/RESTORE/restore~~13:29:48-20--11--2017 
my ($ins,$pref,$nb,$nfb,$nf,$dbug) = @_; # alter 
my @p = @{$pref};
my $nerr = undef;
$nb =~ s/^($http)//;$nb.= "/" if $nb !~ /\/$/;
$nfb =~ s/^($http)//;$nfb.= "/" if $nfb !~ /\/$/;
$nf =~ s/^($base)//;$nf =~ s/(\/)+$//;if($nf ne ""){$nf.= '/';}
for my $i( 0..$#p ){ 
$p[$i] =~ s/^($base)//;
if( -f $base.$p[$i] ){ 
my $dest = $p[$i];if( $ins eq "restore"){ $dest =~ s/^(.+)\///; }
$dbug.= "$i = copy $base$p[$i] to $base$nf$dest \n";
$nerr = sub_admin_copy('Page',$base.$p[$i],$base.$nf.$dest,\%config,"overwrite");
if( defined $nerr){ $dbug.= "error: $nerr \n"; } else { $dbug.= " copied ok \n"; }
}
}
if( !defined $nerr ){ my @old = sub_get_changed("pages","search",$base.$nf,\%config,$nb,$nfb,"alter",$regexp,"code",$usecase); }
$dbug.= "alter nb:$nb to nfb:$nfb \n";
#return ""; #
return $dbug;
}

sub admin_set_alerts{
my ($atype,$mref) = @_;
my %m = %{$mref};
my $fix = ($atype eq "viewfix" || $atype eq "viewsharefix")?1:undef;
my $fixed = undef;
my $none = $m{'No Alerts'};
my $s = (defined $fix || defined $none)?'':'<div class="infoarea"><div class="alert"><a class="navblock nav-autofix" href="'.$pl.'type=viewfix" title="fix all problems">&nbsp;</a><h2><a class="navtext" href="'.$pl.'type=viewfix" title="fix all problems">Fix All Problems</a></h2></div></div>';
$s.= '<div class="infoarea">';
foreach my $k( sort keys %m){
my $ty = "editpages";
my $u = $k;
my $n = $k;
my $fixed = "";
if( $u !~ /\.($htmlext)$/i ){ $ty = "viewfolders";($u) = sub_get_parent($u);$n =~ s/^.+\///; }

###admin_json_out({ 'check set_alerts' => "fu:$u \n listdir: $listdir\n\n $debug" },$origin,$callback);
if( $u !~ /$listdir/){

if(defined $fix){ 
my $er = "";
while( $m{$k} =~ /<span>(.*?)<\/span>/imgs ){ 
$er.= sub_admin_fixerror($k,$1,$n,$pl.'type='.$ty.'&amp;url='.$uri->encode($u),\%config); 
}
$fixed = $er; 
}

}

if( defined $none ){
if( defined $hidealert ){ $s.= '<div class="alert alertsafe"><span class="navblock nav-uninfoalert">&#160;</span><h2><span class="navtext">'.$n.'</span></h2>'.$m{$k}.'</div>'; }
} elsif( defined $fix ){
$s.= '<div class="alert alertfixed"><h2>'.$n.':</h2>'.$fixed.'</div>';
} else {
$s.= '<div class="alert"><a class="navblock nav-infoalert" href="'.$pl.'type='.$ty.'&amp;url='.$uri->encode($u).'" title="manually fix this problem">&#160;</a><h2><a class="navtext" href="'.$pl.'type='.$ty.'&amp;url='.$uri->encode($u).'" title="manually fix this problem">'.$n.'</a></h2>'.$m{$k}.'</div>';
}
}
return $s.'</div>';
}

sub admin_set_files{
my ($r,$mref,$fu,$non) = @_;
my %files = %{ sub_image_used($fu,\%config,$mref) };
my $nonempty = $non;
# 'documents/Digital/Datasheets/Mainframe-Services/Mainframe-Optimisation-Capacity-Cost-Reduction.pdf' => {
# 'author' => [ 'Andrew Downie' ],
# 'menuname' => [ 'Mainframe-Optimisation-Capacity-Cost-Reduction.pdf' ],
# 'size' => [ '346k' ],
# 'group' => [],
# 'href' => [ 'documents/Digital/Datasheets/Mainframe-Services/Mainframe-Optimisation-Capacity-Cost-Reduction.pdf' ],
# 'url' => [ 'documents/Digital/Datasheets/Mainframe-Services/Mainframe-Optimisation-Capacity-Cost-Reduction.pdf' ],
# 'parent' => [ 'documents/Digital/Datasheets/Mainframe-Services' ],
# 'epoch' => [1516191166 ],
# 'epochcreated' => [ 1479081600 ].
# 'path' => [ 'documents','Digital','Datasheets','Mainframe-Services','Mainframe-Optimisation-Capacity-Cost-Reduction.pdf' ],
# 'tags' => [ 'security' ],
# 'image' => [ 'documents/Digital/Datasheets/Mainframe-Services/Mainframe-Optimisation-Capacity-Cost-Reduction_thumb.jpg' ],
# 'created' => [ '14/11/2016' ],
# 'published' => [ '17/01/2018' ],
# 'title' => [ 'Mainframe Optimisation: Capacity Cost Reduction' ]
# }                                                                                                        },
###admin_json_out({ 'check set_files' => "fu:$fu\n keys:".( keys %files )." \n\n".Data::Dumper->Dump([\%files],["files"])." \n\n".Data::Dumper->Dump([$mref],["mref"])."\n\nr:$r \n\n\n $debug" },$origin,$callback);

if( keys %files > 0 ){
foreach my $k( sort keys %files ){ 
my $fp = $uri->encode( $files{$k}{'parent'}[0]."/" );
my $fn = $uri->encode( $k );
my $ulist = 0;if( defined $files{$k}{'used'} && scalar @{ $files{$k}{'used'} } > 0 ){ $ulist++; }

if( $files{$k}{'url'}[0] !~ /_thumb\.(jpg|png|gif)$/i ){
my $sp = '';if( defined $files{$k}{'image'} ){ my $im = $files{$k}{'image'}[0];$im =~ s/^(.+)\///;$sp = ' data-thumb="Image: '.$im.'"'; }
$r.= '<div class="text nonmenufolder"'.$sp.'><div class="tt_progress"><span class="bar"></span></div><h2>';
$r.= ( ( $k =~ /\.(txt|$htmlext)$/ )?'<a class="navblock nav-edit" href="'.$pl.'type=editpages&amp;url='.$fn.'" title="edit Page" target="_blank">&#160;</a>':'' ).
(
($ulist > 0)?
'<a class="navblock nav-delete undelete" title="delete file">&#160;</a><a class="navblock nav-rename unrename" title="rename file">&#160;</a><a class="navblock tt_directupdate nav-used" href="'.$pl.'type=usedfiles&amp;url='.$fn.'" title="show used">&#160;</a>'
:
'<a class="navblock nav-delete" href="'.$pl.'type=deletefiles&amp;url='.$fp.'&amp;old='.$fn.'" title="delete file">&#160;</a><a class="navblock nav-rename" href="'.$pl.'type=renamefiles&amp;url='.$fp.'&amp;old='.$fn.'" title="rename file">&#160;</a>'
).
'<a class="navtext" href="'.$baseview.$k.'" target="_blank" title="view '.$k.'">'. $files{$k}{'menuname'}[0].'</a></h2></div>';
}

}
} else {
$nonempty = $nonempty - 0.5;
}
return ($r,$nonempty);
}

sub admin_set_folders{
my ($r,$mref,$fu,$non,$archive) = @_;
my %folders = %{ $mref };
my $nonempty = $non;
if( keys %folders > 0 ){
###admin_json_out({ 'check set_folders' => "fu:$fu\n keys:".( keys %folders )."\n\n".Data::Dumper->Dump([$mref],["mref"])."\n\nr:$r \n\n\n $debug" },$origin,$callback);
foreach my $k( sort keys %folders ){ 
my $rlink = $fu;$rlink =~ s/^($base)//;
my $dn = $uri->encode( $rlink.$k."/" );
my $req = ( sub_title_out($k,\%config) =~ /($resourcefolder|$partnerfolder|$imagefolder|$pdffolder|$templatefolder)$/)?1:undef;
$r.= '<div class="text menufolder"><h2>'.
'<a class="navblock nav-right" href="'.$pl.'type=viewfolders&amp;url='.$dn.'" title="view folder">&#160;</a>'.
( (defined $archive)?'':'<a class="navblock nav-upload" href="'.$pl.'type=uploadfolders&amp;url='.$dn.'" title="upload to this folder">&#160;</a>' ).
( (defined $req)?'':'<a class="navblock nav-delete" href="'.$pl.'type=deletefolders&amp;url='.$dn.'" title="delete folder">&#160;</a>' ).
( (defined $req)?'':'<a class="navblock nav-rename" href="'.$pl.'type=renamefolders&amp;url='.$dn.'" title="rename folder">&#160;</a>' ).
'<a class="navtext" href="'.$pl.'type=viewfolders&amp;url='.$dn.'" title="view folder">'.( sub_title_out($k,\%config) ).'</a>'.
'</h2></div>';
}
} else {
$nonempty = $nonempty - 0.5;
}

return ($r,$nonempty);
}

sub admin_set_headers{
my ($h,$dulevel,$sub,$fu,$pg,$exref,$edtitle,$isfolder,$ishid,$archive) = @_;
my %ex = (defined $exref)?%{$exref}:();
###admin_json_out({ 'check set_headers' => "h: $h \n dulevel:$dulevel \n sub:$sub \n fu:$fu \n edtitle:$edtitle \n isfolder:$isfolder \narchive:$archive \npg:$pg \n\n".Data::Dumper->Dump([$exref],["exef"])."\n\n $debug" },$origin,$callback);

if( $dulevel < 1 ){ 

$h.= '<div class="area headerarea header'.$dulevel.'"><div class="column"><div class="row"><div class="text"><h2>'.
'<a class="navblock nav-right" href="'.$pl.'type=viewpages" title="view Site Pages">&#160;</a><a class="navtext blank" href="'.$pl.'type=viewpages" title="view Site Pages">Site Pages</a>'.
'</h2></div></div></div></div>'.
'<div class="area headerarea header'.$dulevel.'"><div class="column"><div class="row"><div class="text"><h2>'.
'<a class="navblock nav-right" href="'.$pl.'type=viewfolders" title="view Site Documents">&#160;</a>'.
'<a class="navtext blank" href="'.$pl.'type=viewfolders" title="view Site Documents">Site Documents</a>'.
'</h2></div></div></div></div>';

} else {

if( defined $pg ){ 

my @cpath = ();
my $clink = $fu;$clink =~ s/^($base)//;
my $tmp = $clink;$tmp =~ s/\.($htmlext)$//;
my @ctmp = split /$qqdelim/,$tmp;
my $clen = $#ctmp;
my $clinkprev = $clink;$clinkprev =~ s/\.($htmlext)$//;$clinkprev =~ s/^(.+)$qqdelim.*?$/$1.$htmlext/;
my $cprev = "";
my $uclink = $uri->encode( $clink );
$clen++;

if( $dulevel <= 3 ){
if( $clink eq $base || $clink !~ /\.($htmlext)$/ ){
$h.= '<div class="area headerarea header'.$clen.'"><div class="column"><div class="row"><div class="text">'.
'<h2><a class="navblock nav-header" href="'.$pl.'type=viewall" title="back to Site Files">&#160;</a><a class="navtext" href="'.$pl.'type=viewall" title="back to Site Files">Site Files</a></h2>'.
'</div></div></div></div>';
} else {
$h.= '<div class="area headerarea header'.$clen.'"><div class="column"><div class="row"><div class="text">'.
'<h2><a class="navblock nav-header" href="'.$pl.'type=viewpages" title="back to Site Pages">&#160;</a><a class="navtext" href="'.$pl.'type=viewpages" title="back to Site Pages">Site Pages</a></h2>'.
'</div></div></div></div>';
}
}

for my $i(0..$#ctmp){
$cpath[$i] = join $delim,@ctmp[0..$i]; #( documents/,Solutions.html,Solutions_Presentations.html )
my $cpl = $cpath[$i];if($cpl !~/\.($htmlext)$/){ $cpl.= ".".$htmlext; }
$cprev = ($clink eq $base)?'Site Pages':sub_title_out($cpath[$i],\%config);
if( $i < $#ctmp){
$h.= '<div class="area headerarea header'.$clen.'"><div class="column"><div class="row"><div class="text"><h2>'.
'<a class="navblock nav-header" href="'.$pl.'type=viewpages&amp;url='.$uri->encode($cpl).'" title="back to '.$cprev.'">&#160;</a>'.'<a class="navtext" href="'.$pl.'type=viewpages&amp;url='.$uri->encode($cpl).'" title="back to '.$cprev.'">'.$cprev.'</a>'.
'</h2></div></div></div></div>';
}
if( $i == $#ctmp && defined $isfolder){
my $fd = sub_title_out($isfolder,\%config);
$h.= '<div class="area headerarea header'.$clen.' folderheader"><div class="column"><div class="row"><div class="text"><h2>'.
'<a class="navblock nav-header" href="'.$pl.'type=viewpages&amp;url='.$uri->encode($isfolder).'" title="back to '.$fd.'">&#160;</a>'.'<a class="navtext" href="'.$pl.'type=viewpages&amp;url='.$uri->encode($isfolder).'" title="back to '.$fd.'">'.$fd.'</a>'.
'</h2></div></div></div></div>';
}
}

if( $type eq "viewversionpages" ){
$h.= '<div class="area headerarea header'.$clen.'  folderheader"><div class="column"><div class="row"><div class="text"><h2>'.
'<a class="navblock nav-header" href="'.$pl.'type=editpages&amp;url='.$uclink.'" title="back to '.$cprev.'">&#160;</a>'.'<a class="navtext" href="'.$pl.'type=editpages&amp;url='.$uclink.'" title="back to '.$cprev.'">'.$cprev.'</a>'.
'</h2></div></div></div></div>';
}

if( $type !~ /^(add|archive|changeadd|reorder)pages$/ ){
$h.= '<div class="area headerarea header'.$clen.( (defined $ishid)?' hidepage" data-menu="'.$ishid:'' ).'"><div class="column"><div class="row"><div class="text"><h2>';
if( $type eq "editpages"){
$h.= '<a title="duplicate Page" href="'.$pl.'type=dupepages'.( ($uclink =~ /\.($htmlext)$/i)?'&amp;url='.$uclink:'' ).'" class="navblock nav-dupe">&#160;</a>';
} elsif( $type ne "editpages" && $type ne "dupepages" && $type ne "viewversionpages" && $type ne "changesavepages" && $type !~/(change)*(add|delete|image|archive|restore)pages/ ){
$h.= '<a title="add new Page" href="'.$pl.'type=addpages'.( ($uclink =~ /\.($htmlext)$/i)?'&amp;url='.$uclink:'' ).'" class="navblock nav-addpage">&#160;</a>';
$h.= ($fu ne $base)?'<a class="navblock nav-delete" href="'.$pl.'type=deletepages&amp;url='.$uclink.'" title="delete entire Section">&#160;;</a>':'';
$h.= '<a title="reorder Site Menus" href="'.$pl.'type=reorderpages'.( ($uclink =~ /\.($htmlext)$/i)?'&amp;url='.$uclink:'' ).'" class="navblock nav-rank">&#160;</a>'; #$h.= ( $uclink =~ /\.($htmlext)$/i )?'<span class="navblock nav-rank unrank">&#160;</span>':
}
$h.= '<span class="navtext">'.( ($#ctmp < 0)?'Site Pages':(defined $edtitle)?$edtitle:($type eq "viewversionpages")?"Versions":$cprev ).':</span></h2></div></div></div></div>';
}

} else {

my @dpath = ();
my $dlink = $fu;$dlink =~ s/^($base)//;
my $dlinkprev = $dlink;$dlinkprev =~ s/\/$//;
my @dtmp = split /\//,$dlinkprev;
my $dlen = $#dtmp;
my $startnum = 0;
if( $dlen < 1 ){
$h.= '<div class="area headerarea header'.$dlen.'"><div class="column"><div class="row"><div class="text"><h2>'.
'<a class="navblock nav-header" href="'.$pl.'type=viewall" title="back to Site Files">&#160;</a>'.
'<a class="navtext" href="'.$pl.'type=viewall" title="back to Site Files">Site Files</a></h2>'.
'</div></div></div></div>';
}
if( $dlen > 1 ){
$h.= '<div class="area headerarea header'.$dlen.'"><div class="column"><div class="row"><div class="text"><h2>'.
'<a class="navblock nav-header" href="'.$pl.'type=viewfolders&amp;url='.$docview.'" title="back to Site Documents">&#160;</a>'.
'<a class="navtext" href="'.$pl.'type=viewfolders&amp;url='.$docview.'" title="back to Site Documents">Site Documents</a>'.
'</h2></div></div></div></div>';
$startnum++;
}
for my $i($startnum..$#dtmp){
$dpath[$i] = join "/",@dtmp[0..$i]; #( documents,documents/Images,documents/Images/backgrounds )
my $dtitle = sub_title_out($dpath[$i],\%config);
my $dl = $i+$dulevel;
if( $i >= $#dtmp-2 && $i < $#dtmp){
$h.= '<div class="area headerarea header'.$dlen.'"><div class="column"><div class="row"><div class="text"><h2>'.
'<a class="navblock nav-header" href="'.$pl.'type=viewfolders&amp;url='.$uri->encode( $dpath[$i]."/" ).'" title="back to '.$dtitle.'">&#160;</a>'.
'<a class="navtext" href="'.$pl.'type=viewfolders&amp;url='.$uri->encode( $dpath[$i]."/" ).'" title="back to '.$dtitle.'">'.$dtitle.'</a>'.
'</h2></div></div></div></div>';
}
if($i == $#dtmp){
$h.= '<div class="area headerarea header'.$dlen.( (defined $ishid)?' hidepage" data-menu="'.$ishid:'' ).'"><div class="column"><div class="row"><div class="text"><h2>'.
( (defined $archive && $archive eq 'library')?'':( defined $ex{'unadd'} || $dlen > 5 )?'<span class="navblock nav-add unadd">&#160;</span>':'<a title="add new folder" href="'.$pl.'type=addfolders&amp;url='.$uri->encode( $dpath[$i]."/" ).'" class="navblock nav-add">&#160;</a>' );
if( !defined $archive ){
$h.= ( ( defined $ex{'unupload'} )?'<span class="navblock nav-upload unupload">&#160;</span>':'<a class="navblock nav-upload" href="'.$pl.'type=uploadfolders&amp;url='.$uri->encode( $dpath[$i]."/" ).'" title="upload to '.$dtitle.' folder">&#160;</a>' ).
( ( defined $ex{'undownload'} )?'<span class="navblock nav-download undownload">&#160;</span>':'<a class="navblock nav-download" href="'.$pl.'type=downloadfolders&amp;url='.$uri->encode( $dpath[$i]."/" ).'" title="download files from '.$dtitle.' folder">&#160;</a>' ).
( ( $i == 1 && $dpath[$i] =~ /^($docview)($resourcefolder|$partnerfolder)/ )?'<a class="navblock edittags" href="'.$pl.'type=editlibrary&amp;url='.$uri->encode( $dpath[$i]."/" ).'" title="edit Library File for this folder">&#160;</a>':'' );
}
my $dp = $dpath[$i];if( defined $archive ){ $dp =~ s/index\.($htmlext)$//; }
$h.= '<span class="navtext">'.( ($type =~ /^changesearch/)?'Search Results ':$dp ).':</span>'.
'</h2></div></div></div></div>';
}
}

}

}

###admin_json_out({ 'check set_headers 1' => "h: $h \n dulevel:$dulevel \n sub:$sub \n fu:$fu \n edtitle:$edtitle \n isfolder:$isfolder \narchive:$archive \nresourcefolder:$resourcefolder \npartnerfolder:$partnerfolder \npg:$pg \n\n".Data::Dumper->Dump([$exref],["exef"])."\n\n $debug" },$origin,$callback);
return $h;
}


sub admin_sitemap_update{
my ($s) = @_;
my $upsite = "";
my $output = "";
if( defined $s && -d $s ){ #/var/www/vhosts/pecreative.co.uk/onlinederby.co.uk/cgi-bin/admin/
my $cmd = $s."sitemap.pl";
my $set = $s."config.xml"; 
$output = `$cmd --config=$set 2>&1`; # --testing
if( $output =~ /Reading configuration file:/ ){ $upsite = " (sitemap.xml updated)"; } else { $upsite =" (sitemap.xml error: $output)"; }
}
return $upsite;
}