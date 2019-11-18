#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5

#editthis version:8.2.2 EDGE

use strict;
#use warnings;

use CGI;
use CGI qw/escape unescape/;
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
use Encode;

use File::Basename;
use File::Copy;
use File::Find;
use HTML::Entities;
use File::Path;
use File::Spec;
use File::stat;

my $envpath = File::Spec->rel2abs( __FILE__ );
$envpath =~ s/(\/cgi\-bin|\/cgi)(.+)\/.*?$/$1$2/;
our $cgix = $1.$2."/";
our $incerr = "";
for my $incfile("$envpath/defs.pm","$envpath/subs.pm"){
my $increturn = undef;
unless ($increturn = do $incfile){
$incerr.= "couldn't parse $incfile: $@\n" if $@;
$incerr.= "couldn't do $incfile: $!\n" unless defined $increturn;
$incerr.= "couldn't run $incfile\n" unless $increturn;
}
}

our $searchcss = <<_SEARCH_CSS;
.tt_dropcontainer { width:20%; margin-right:10px; padding-bottom:20px; clear:none; float:left; }
.tt_dropcontainer > label { width:100%; font-weight:bold; clear:both; float:none; }
.tt_dropcontainer > select { display:block; min-width:120px; border:1px solid #ccc; clear:both; float:none; }
.searchleft > .tt_dropcontainer:last-child { margin-right:0; }
.searchblock { text-align:left; margin-bottom:20px; }
.search0 { font-family:'head_bold'; font-size:200%; line-height:200%; }
.search1 { font-family:'head_regular'; font-size:150%; line-height:160%; padding:5px 0; }
.search1 > i { font-style:normal; color:#00f; }
.search2 { font-size:120%; line-height:140%; padding-bottom:4px; }
.search2 li:first-child > label:first-child { padding-left:0; }
.search2 .sub-i { width:auto; height:34px; color:#fff; background:#36A3B8; font-size:100%; text-align:center; margin-left:-2px; padding:0 20px; }
.search2 .form-sg { width:50%; }
.searchfound { margin:10px 0; }
.searchfound > a { font-size:120%; line-height:140%; }
.searchfound > a::after { content:" >>"; }
.searchfound.pdf > a::after { content: "(PDF)"; color:#999; margin-left:6px; }
.searchfound.doc > a::after { content: "(DOC)"; color:#999; margin-left:6px; }
.searchfound.docx > a::after { content: "(DOCX)"; color:#999; margin-left:6px; }
.searchfound.ppt > a::after { content: "(PPT)"; color:#999; margin-left:6px; }
.searchfound.pptx > a::after { content: "(PPTX)"; color:#999; margin-left:6px; }
.searchfound.xls > a::after { content: "(XLS)"; color:#999; margin-left:6px; }
.searchfound.xlsx > a::after { content: "(XLSX)"; color:#999; margin-left:6px; }
.searchfound.zip > a::after { content: "(ZIP)"; color:#999; margin-left:6px; }
.searchfound > span { margin:10px; }
.searchfound emp { display:block; margin:5px 0 0; }
.searchfound u {  text-decoration:none; }
.searchfound u:first-child { background-color:#f2e5ff; }
.searchfound i { font-style:normal; color:#00f; }
.searchfound strong i { font-style:italic; color:#36A3B8; }
.searchfound strong u { font-style:italic; }
_SEARCH_CSS

our $shopfolder = $defs::shopfolder;
our $search_file = $defs::search_file;
our $doshop = undef;

our $pageamount = 0;
our $pagesort = 'rank';
our $pagestart = 1;
our $cache = 0;
our $remote = 0;

our @servers = @defs::serverip;
for my $i(0..$#servers){ $servers[$i] =~ s/\.([0-9]+)$//; }
our $serverenv = $defs::serverenv;
our $serverip = join "|",@servers;
our $sendtemp = $defs::sendtemp;

our $body_regx = $defs::body_regx;
our $notags = $defs::notags;
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
our $resourcefolder = $defs::resourcefolder;
our $pdffolder = $defs::pdffolder;
our $cssview = $defs::cssview;

our $index_file = $defs::index_file;
if( defined $defs::homeurl ){ $homeurl = $defs::homeurl; }
our $site_file = $defs::site_file;
our $mobpic = $defs::mobpic;
our %editable = %defs::editable;
our %defsort = %defs::defsort;
our %headers = %defs::headers;
our %defheaders = %defs::defheaders;
our $htmlhead = $defs::htmlhead;
our $htmlfoot = $defs::htmlfoot;

our $resdir = join "|",@defs::RESERVED;
our $listdir = join "|",@defs::LISTDIR;
our $bansearch = $listdir."|LIB";
our $bandir = join "|",@defs::BANDIR;
our $banfile = join "|",@defs::BANFILE;
our $extimg = join "|",values %defs::EXT_IMGS;
our $extdoc = join "|",values %defs::EXT_FILES;
our $extset = $extimg."|".$extdoc;
our $auxfiles = $defs::auxfiles;

our %editareas = %defs::editareas;
our $edittags = join "|", keys %editareas;
our $droptags = $defs::droptags || "Archive Area Author Focus Group Tags Text";
our %IMS = %defs::EXT_IMGS;
our %FX = %defs::FX;
my %LIB = ( "_data" => {} );
our @UTF = @defs::UTF;
our @UTF1 = @defs::UTF1;
our @css_files = @defs::css_files;
our $fxfile = (join "|",keys %FX)."|".(join "|",values %IMS);

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
our $repdash = "~";

our %config = ();
our @enames = ();
our @evalues = ();
our $url = undef;
our $callback = undef;
our $attri = "";
our $pagewrap = undef;
our $clsdata = undef;
our $js = undef;
our $fullmenu = undef;
our $filter = undef;
our $format = undef;
our $exclude = undef;
our $sitepage = undef;
our $origin = undef;

our $time = time;
our @DATER = (
$time - 604800, # now - 1 week 
$time - 2629743, # now - 1 month
$time - 15778458, # now - 6 months
$time - 31556926, # now - 1 year
$time - 157784630, # now - 5 years
$time - 946707780 # now - 30 years
);

my %MNS = ('january' => 0,'february' => 1,'march' => 2,'april' => 3,'may' => 4,'june' => 5,'july' => 6,'august' => 7,'september' => 8,'october' => 9,'november' => 10,'december' => 11);

local *sub_clean_name = \&subs::sub_clean_name;
local *sub_get_contents = \&subs::sub_get_contents;
local *sub_get_date = \&subs::sub_get_date;
local *sub_get_html = \&subs::sub_get_html;
local *sub_json_out = \&subs::sub_json_out;
local *sub_json_print = \&subs::sub_json_print;
local *sub_merge_hash = \&subs::sub_merge_hash;
local *sub_page_findreplace = \&subs::sub_page_findreplace;
local *sub_search_file = \&subs::sub_search_file;
local *sub_searchreplace_file = \&subs::sub_searchreplace_file;
local *sub_title_out = \&subs::sub_title_out;

our %IN = ();
our %DATA = ();
our @terms = ();
our @reps = ();
our %filters = (); # 'author' => 'author' 
our %includes = ();
our $type = "new";
our $library = "none";
our $boxpos = "after";
our $outtype = "text";
our $notword = undef;
our $tagson = undef;
our $pages = undef;
our $documents = undef;
our $debug = "";

$CGI::POST_MAX = $defs::postmax;

sub_json_out({ 'error' => "alert: server configuration problem:\n\n $incerr \ncgipath:$cgipath \ncgix:$cgix \nenvpath:$envpath \nip:$ENV{'REMOTE_ADDR'}" }) if $incerr ne "";
sub_json_out({ 'error' => "alert: unauthorised user request received by server $serverenv from $ENV{'REMOTE_ADDR'}" }) unless $serverenv =~ /^($serverip)/; # == $serverip / $debug
sub_json_out({ 'error' => "data size [ ".$ENV{'CONTENT_LENGTH'}." ] is greater than the maximum ".$CGI::POST_MAX."k allowed" }) if $ENV{'CONTENT_LENGTH'} && $ENV{'CONTENT_LENGTH'} > $CGI::POST_MAX;

local our $query = CGI->new();
local our %pdata = $query->Vars; my @new_keys = keys %pdata;s/^(opt|pre)_(.*?)_([0-9]+)$/$2/ foreach @new_keys; @pdata{@new_keys} = delete @pdata{keys %pdata}; # 
$debug.= Data::Dumper->Dump([\%pdata],["PDATA"])."\n";
local our $postdata = $query->param('POSTDATA'); # $debug.= Data::Dumper->Dump([$postdata],["POSTDATA"])."\n";
local our $qerr = $query->cgi_error;if($qerr){ exit 0;sub_json_out({'error' => "error: problem with received data: $qerr" }); }

#cgi-bin/search.pl
#cgi-bin/search.pl form = opt_js=1&datasearch=test
#cgi-bin/search.pl?callback=Request.JSONP.request_map.request_0&datasearch=Denmaur&type=all&js=1
#cgi-bin/search.pl?callback=Request.JSONP.request_map.request_0&cgi=search.pl&inputs=library&name=Search&pos=top&type=new&js=1
#cgi-bin/search.pl?callback=Request.JSONP.request_map.request_0&cgi=search.pl&inputs=min&name=Search&pos=top&js=1
#cgi-bin/search.pl?callback=Request.JSONP.request_map.request_0&datasearch=Denamur&replace=IBM&type=pages&js=1

foreach my $k( keys %pdata ){
if( $k eq "callback" ){ $callback = $pdata{$k}; } # Request.JSONP.request_map.request_0
if( $k eq "cache" ){ $cache = $pdata{$k}; } # 144222753956534
if( $k eq "type" ){ $type = $pdata{$k}; } # new | shopsearch | tags | all | pages | documents | digital
if( $k eq "inputs" ){ $library = $pdata{$k}; } # none | min | library
if( $k eq 'datasearch' ){ $type = "all";@terms = split /\+/,$pdata{'datasearch'};foreach my $p( @terms ){ $terms[$p] = sub_clean_name( Encode::decode( 'utf8',$terms[$p] ),$htmlext ); } } #find1+find2
if( $k eq 'replace' ){ @reps = split /\+/,$pdata{'replace'};foreach my $p( @reps ){ $reps[$p] = sub_clean_name( Encode::decode( 'utf8',$reps[$p] ),$htmlext ); } } #replace1+replace2
if( $k eq 'filter' ){ $filter = $pdata{$k}; } #editgroup
if( $k eq "html" && $pdata{$k} eq "on" ){ $tagson = $pdata{$k}; } # off | on
if( $k eq 'boxpos' ){ $boxpos = $pdata{$k}; } # before | after
if( $k eq 'notword' && $pdata{$k} eq "on" ){ $notword = $pdata{$k}; } # off | on
if( $k eq 'outtype' ){ $outtype = $pdata{$k}; } # code | meta | html | text
if( $k eq "url" ){ $url = $pdata{$k}; } # Solutions_Page.html
if( $k eq "js" ){ $js = $pdata{$k}; } # 1
if( $k eq "origin" ){ $origin = $pdata{$k}; } # http://othersite.thatsthat.co.uk/
if( $k =~ /^data\-(.*?)$/ ){ my $dn = $1;if( $pdata{$k} ne "none" ){ if( !defined $IN{$dn} ){ $IN{$dn} = ""; } else { $IN{$dn}.= "+"; }$IN{$dn}.= sub_clean_name( Encode::decode( 'utf8',$pdata{$k} ),$htmlext ); }} # archive | area | author | focus | tags | text
}

sub_json_out({ 'error' => "search 1 check: \n\nunauthorised user request received by server $serverenv == $serverip" },$origin,$callback) unless $serverenv =~ /^($serverip)/;
###if( defined $origin ){ sub_json_out({ 'debug' => "search 2 check: \n\n$debug \norigin: $origin" },$origin,$callback); }

if( !defined $url ){ $url = (!defined $js)?$base:($type eq "shopsearch")?$base.$shopfolder.'/':($type eq "documents")?$base.$docview:($type eq "digital")?$base.$docview.$resourcefolder:$base; }
$pages = ($type eq "pages")?"include":undef;
$documents = ($type eq "documents")?"include":undef;
if( $type eq "tags" ||  $type eq "all" ){ for my $k( keys %IN ){ my @ins = split /\+/,$IN{$k};for my $i(0..$#ins){ push @terms, sub_clean_name( Encode::decode( 'utf8',$ins[$i] ),$htmlext ); } } }
sub_json_out({ 'error' => "main 3: \n\nno data received by server: $debug" },$origin,$callback) unless $url ne "" && -d $url;
###sub_json_out({ 'debug' => "search 3 check:\n\n envpath:$envpath \ncgipath:$cgipath \ncgix:$cgix \ncallback:$callback \ntype:$type \nformat:$format \nurl:$url \nbase:$base \n\n".Data::Dumper->Dump([\%IN],["IN"])." \n\ndatasearch:[ @terms ] \nreplace:[ @reps ] \norigin: $origin \n\n$debug" },$origin,$callback);

# url: /var/www/vhosts/pecreative.co.uk/rsmpartners.com/newest/documents/
# envpath: /var/www/vhosts/pecreative.co.uk/rsmpartners.com/cgi-bin/newest/ 
# cgipath: cgi-bin/newest/
# base: /var/www/vhosts/pecreative.co.uk/rsmpartners.com/newest/ 
# nwbase: /var/www/vhosts/pecreative.co.uk/rsmpartners.com/
# obase: http://www.rsmpartners.com/
# baseview: http://www.rsmpartners.com/newest/
# type: all
# datasearch: MSPAlliance
# origin:

%config = ( 
'attri' => $attri,
'auxfiles' => $auxfiles,
'bandir' => $bandir,
'banfile' => $banfile,
'base' => $base,
'baseview' => $baseview,
'body_regx' => $body_regx,
'callback' => $callback,
'clsdata' => $clsdata,
'cssview' => $cssview,
'debug' => $debug,
'defheaders' => \%defheaders,
'defrestore' => $defrestore,
'defsep' => $defsep,
'defsort' => \%defsort,
'delim' => $delim,
'dlevel' => 0,
'docspace' => $docspace,
'documents' => $documents,
'docview' => $docview,
'editareas' => \%editareas,
'extdoc' => $extdoc,
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
'id' => "",
'index_file' => $index_file,
'imagefolder' => $imagefolder,
'imagerelay' => $imagerelay,
'imageview' => $imageview,
'js' => $js,
'listdir' => $listdir,
'liblister' => $liblister,
'mobpic' => $mobpic,
'nwbase' => $nwbase,
'nwurl' => $nwurl,
'obase' => $obase,
'otitle' => $otitle,
'origin' => $origin,
'pages' => $pages,
'pagesort' => $pagesort,
'pagewrap' => $pagewrap,
'perms' => \%perms,
'pl' => "",
'pulledlink' => undef,
'qqdelim' => $qqdelim,
'repdash' => $repdash,
'resourcefolder' => $resourcefolder,
'site_file' => $site_file,
'sitepage' => $sitepage,
'subdir' => $subdir,
'taglister' => $taglister,
'titlesep' => \@titlesep,
'user' => undef,
'UTF' => \@UTF,
'UTF1' => \@UTF1
);

my %fdata = ();
my %indata = ();
my %fulldata = ();
my $droptxt = "";
my $newtxt = "";
my $stxt = "";
my $err = undef;

if( $type =~ /(tags|digital|all)$/ || $library eq "library" ){
my %drops = ();
$droptxt.= '<input type="hidden" name="opt_type_0" value="'.( ($type eq "new")?'all':$type ).'" /><input type="hidden" name="opt_inputs_0" value="library" />';
foreach my $ar( keys %editareas ){ 
if( $editareas{$ar} > 1 ){ 
my $vr = $ar;$vr =~ s/([\w']+)/\u\L$1/g; #'# {  'Area' => 'area','Author' => 'author','Date' => 'date','Focus' => 'focus','Group' => 'group','Text' => 'text','Tags' => 'tags' }
$filters{$vr} = $ar;
}
$filters{'Author'} = 'author';
} 
my ($terr,$tref,$fref) = search_searchsite("tags",$url,[],[],$notword,\%filters,\%IN);if( defined $terr ){ $err = $terr;$debug.= $err."\n"; } else { %fdata = %{$tref};%indata = %{$fref}; }
foreach my $k( sort { $fdata{$a} cmp $fdata{$b} } keys %fdata){
my %tmp = %{ $fdata{$k} };
foreach my $f( keys %tmp ){
my %fil = %{ $tmp{$f} };
if( defined $fil{'filters'}){ my %ds = %{$fil{'filters'}};foreach my $j( sort { $ds{$a} cmp $ds{$b} } keys %ds ){ if( !defined $drops{$j} ){ $drops{$j} = {}; }if( !defined $drops{$j}->{$ds{$j}} ){ $drops{$j}->{$ds{$j}} = 1; } else { $drops{$j}->{$ds{$j}}++; } } }
}
}
# $drops = { 'Archive' => {'September' => 2,'July' => 3,'October' => 1,'August' => 1 },'Tags' => { 'software' => 7,'skills' => 2 } }
###sub_json_out({ 'search 5 check' => "type:$type \nurl: $url \ndocuments:$documents pages:$pages  \n\n".Data::Dumper->Dump([\%filters],["filters"])."\n\n".Data::Dumper->Dump([\%drops],["drops"])."\n\n".Data::Dumper->Dump([\%indata],["indata"])."\n\n $debug" },$origin,$callback);

my $c = 0; 
for my $k( sort keys %drops){
if( !defined $droptags || $droptags =~ /\b$k\b/i ){
my %op = ();
for my $k1( sort keys %{$drops{$k}} ){$op{ lc $k1 } = 1;}
my $lc = lc $k;
if( scalar keys %op > 1 ){
$droptxt.= '<div class="tt_dropcontainer tt_dropped-'.$c.'"><label for="data-'.$lc.'_0">'.$k.'</label><select name="opt_data-'.$lc.'_0" id="data-'.$lc.'_0" size="5" multiple><option value="none" selected>none</option>';

my @keys = sort keys %op;
my @sort = ();
if($lc eq "archive"){
for my $i(0..$#keys){ my $am = $MNS{lc $keys[$i]};if(defined $am){ $sort[$am] = $keys[$i];} }
} else {
@sort = @keys;
}

for my $i(0..$#sort){
my $oo = $sort[$i];$oo =~ s/([\w']+)/\u\L$1/g; #'
$droptxt.= '<option value="'.( lc $sort[$i] )."\">$oo</value>\n";
}
$droptxt.= '</select></div>';
}
$c++;
}
}
}

if( !defined $callback ){
if( $droptxt ne "" ){ $droptxt = '<li class="fli searchleft">'.$droptxt.'</li>'; }
$newtxt.= <<_FOUTPUT_;
<li class="column datasearch">
<form accept-charset="UTF-8" id="cgi_form_datasearch" method="post" action="${baseview}${cgipath}search.pl"><fieldset>
	<ul class="ful">
		$droptxt
		<li class="fli searchright"><input name="opt_js_9" value="1" type="hidden">
			<label for="tooltipbox9" class="tooltipbutton tt_unselect" title="Site Search">&#160;<span class="searchboxicon"></span></label>
			<input class="form-sg " name="pre_datasearch_9" id="datasearch_9" placeholder="Search:" value="" type="text" />
			<input name="submit_9" value="" class="sub-i" type="submit" />
			<input id="tooltipbox9" class="tooltipper" type="checkbox" />
			<div class="edittext tooltip css-move5" />
				<div class="text"><a href="${baseview}${cgipath}search.pl" title="Tooltip">Search is not case-sensitive - Separate multiple terms with '+'</a></div>
			</div>
		</li>
	</ul>
</fieldset></form>
</li>
_FOUTPUT_

}

if( $type ne "new" ){ 
my @results = ();
#if( defined $library ){ $library = $droptxt; }

if( $type eq "shopsearch" ){
search_searchshop(\%fdata,\@terms);
} else { 
if( $type ne "tags" && $type ne "digital" ){ my ($aerr,$aref) = search_searchsite($type,$url,\@terms,\@reps,$notword);if( defined $aerr ){ $err = $aerr;$debug.= $err."\n"; } else { %fdata = %{$aref}; } }
}
#%fdata = {  'Layout.Test-Page.html' => [ 9, { 
# 'test' => [
# '<meta content=\"Layout.Test-Page.html\" name=\"editurl\" />',
# '<title>Test Page - Online Derby</title>',
# '<body id=\"body0\" class=\"layout.test-page tt_nopointer tt_notouch tt_nocss3 tt_uncookied tt_unjs\">',
# '\t\t\t\t\t\t\t\t\t\t\t<div class=\"text\"><h1>Test Page</h1><div class=\"crumb\"><p><a href=\"Layout.html\">Layout</a><span class=\"crumbjoin\"></span>Test Page</p></div></div>',
# '\t\t\t\t\t\t\t\t\t\t\t\t\t\t<p class=\"format3\">1. This line has the word test in it.</p>',
# ],
# 'October' => [ '\t\t\t\t\t\t\t\t\t\t\t\t\t<div class=\"text\"><p>A promotion, an internship and two introductions.. (Seach test for the word x_X_xOctobery_Y_y)</p>' ]
# } ] }
#
# %indata = { 
# 'documents/Digital/Policies/.library.txt' => { 'documents/Digital/Policies/Modern-Slavery-Statement.pdf' => { 'author' => 'Andrew Bruguier','archive' => 'October'  } },
# 'News.PrePrint--S-added-to-Denmaur-stock-portfolio.html' => { 'News.PrePrint--S-added-to-Denmaur-stock-portfolio.html' => { 'author' => 'Andrew Bruguier' } } 
# }
foreach my $k( keys %fdata ){ 
my @fa = @{ $fdata{$k} };
if( scalar @fa > 0 && $fa[0] > 0 ){ 

my %tmp = %{ $fa[1] };
my $s = "";
my $c = 0;
foreach my $j(keys %tmp){
my @lines = @{ $tmp{$j} };
#$debug.= "$j = @lines\n\n"; #october = \t\t\t\t\t\t\t\t\t\t\t\t\t<div class=\"text\"><p>A promotion, an internship and two introductions.. (Seach test for the word x_X_xOctobery_Y_y)</p>
for my $i(0..$#lines){

my $en = $lines[$i];$en =~ s/<(.*?)>//gism unless defined $tagson;$en = encode_entities($en);
if( $en =~ /x_X_x(.*?)y_Y_y\b/ ){ #<span>Mainframe <i>Security</i>Mainframe Security</span> #<span>Mainframe Security</span>
$en =~ s/x_X_x/<i>/g;$en =~ s/y_Y_y/<\/i>/g;
if( $outtype eq "code" || ($outtype eq "meta" && $lines[$i] =~ /^\s*<meta/im) ){ 
$s.= "<span>$en</span>\n";$c++;
} elsif( $outtype eq "code" || ($outtype eq "html" && $lines[$i] =~ /^\s*(<title|<body|<div|<p)/im) ){
$s.= "<span>$en</span>\n";$c++;
} else {
if( $outtype eq "code" || $outtype eq "text" ){ $s.= "<span>$en</span>\n";$c++; }
}
}

}
if($c > 0){ $fulldata{$k} = [$c,$k,$s]; }
}

} 
}

if( $type eq "tags" || $type eq "all" ){ 
foreach my $k( sort keys %indata ){ 
my %f = %{ $indata{$k} };
foreach my $j(sort keys %f){ 
my %h = %{ $f{$j} };
my @s = ();
my $c = 0;
foreach my $n(sort keys %h){ push @s,"<span><b>".( ucfirst $n )."</b> Tag: <i>$h{$n}</i></span>";$c++; }
if( $c >= scalar @terms ){ if( !defined $fulldata{$j} ){ $fulldata{$j} = [1,$j,(join "",@s)."\n"]; } else { $fulldata{$j}->[0]++;$fulldata{$j}->[2].= (join "",@s)."\n"; } }
}
} 
}

foreach my $k(keys %fulldata){
push @results,$fulldata{$k};
}


###sub_json_out({ 'search 6 check' => "type:$type \nurl:$url \nouttype:$outtype \nterms:[ @terms ] \nreps: [ @reps ]\n\n".Data::Dumper->Dump([\@results],["results"])."\n\n".Data::Dumper->Dump([\%fulldata],["fulldata"])."\n\n".Data::Dumper->Dump([\%fdata],["fdata"])."\n\n".Data::Dumper->Dump([\%indata],["indata"])."\n\n $debug" },$origin,$callback);
if( scalar @results < 1 ){
$stxt.= '<div class="searchfail">No items matching these terms are currently available.</div>';
} else {
my @rout = sort { $b->[0] <=> $a->[0] || $a->[1] cmp $b->[1] } @results;
for my $i(0..$#rout){ 
my $ext = lc $baseview.$rout[$i]->[1];$ext =~ s/^.+\.(.*?)$/ $1/;
$stxt.= '<div class="searchfound'.$ext.'"><a href="'.$baseview.$rout[$i]->[1].'" title="visit Page" target="_blank">'.( sub_title_out($rout[$i]->[1],\%config) ).'</a><span>'.$rout[$i]->[0].' match'.( ($rout[$i]->[0] > 1)?'es':'' ).'</span><div class="tt_dropwrapper tt_searchwrapper"><div class="row editblock"><div class="editmodule dropwrapper"><label for="dropwrapper_'.$i.'" class="nonselect" title="view results for this Page">View Details &#62;&#62;</label><input id="dropwrapper_'.$i.'" type="checkbox"><div class="text">'.$rout[$i]->[2].'</div></div></div></div></div>'."\n"; 
}
}

}

if( !defined $callback ){ $stxt = ($boxpos eq "before")?"$newtxt\n$stxt":"$stxt\n$newtxt"; } else { $stxt = ($boxpos eq "before")?"$droptxt\n$newtxt\n$stxt":"$stxt\n$droptxt\n$newtxt"; }
###sub_json_out({ 'search 7 check' => "type:$type \nurl: $url \n\nstxt:$stxt \\njs:$js n\n $debug" },$origin,$callback);
search_output($type,$stxt,$base.$search_file,\@terms,$js,$droptxt);

exit;


###

sub search_html_in{
my ($f) = @_;
my ($ierr,$otxt) = sub_get_contents($f,\%config);
my $t = "";
sub_json_out({ 'error' => "admin list error: $ierr \n $f \n $otxt \n $debug" },$origin,$callback) if defined $ierr;
$t = $otxt;
$t =~ s/(<base href=")(.*?)(" \/>)/$1$baseview$3/;
return $t;
}

sub search_html_out{
my ($t) = @_;
print "Content-type: text/html\n\n";
print $t;
###print $debug;
exit;
}

sub search_output{
#									<ul class="area editablearea content2area searcharea">
#										<li class="column">
#											<div class="row editblock">
#												<div class="editmodule search">
#													<div class="text"><a data-inputs="library" href="../cgi-bin/search.pl" title="Search">Site Search </a></div>
#												</div>
#											</div>
#										</li>
#									</ul>
my ($ty,$stxt,$f,$trmref,$sjs,$lib) = @_;
my $date = sub_get_date($time,\%config,"-");
my $trm = (defined $trmref)?"for <i>".( join "+",@{$trmref} )."</i>":"";
my $otxt = "";
my $se = "";

if( $ty eq "new" ){

$se = <<_OUTPUT_;
<li class="column searchblock">
<div class="search0">Site Search</div>
<div class="search2 datasearch">$stxt</div>
</li>
_OUTPUT_

} else {

if($stxt eq ""){ $stxt = '<div class="searchfound">No results found.</div>'; }
$se = <<_OUTPUT1_;
<li class="column searchblock">
<div class="search0">Search Results</div>
<div class="search1">Search results $trm on $date:</div>
<div class="search2 datasearch">$stxt</div>
</li>
_OUTPUT1_

}

###sub_json_out({ 'search_output 1' => "ty:$ty \nstxt:$stxt \nf:$f \n sjs:$sjs \ntrm:$trm \n\nlib:$lib \n\nse:$se \n\n\notxt: $otxt \n\n config:\n".Data::Dumper->Dump([\%config],["config"])." $debug" },$origin,$callback);
if( defined $callback && $ty eq "new" ){ 
if(defined $lib && $lib ne ""){sub_json_out({'result' => $lib},$origin,$callback);} else {sub_json_out({'result' => $se},$origin,$callback);} 
} elsif( $ty eq "new" && defined $callback && defined $lib && $lib ne "" ){ 
sub_json_out({'result' => $lib},$origin,$callback); 
} else { 
$otxt = search_html_in($f);
$otxt =~ s/(<\/style>\s*<link rel="shortcut icon")/$searchcss$1/ism;
$otxt =~ s/(<ul class="area editablearea.*?searcharea">).*?(<\/ul>)/$1$se$2/ism;
search_html_out($otxt); 
}
}

sub search_searchtags{
my ($f,$fdref,$filterref,$termref,$inref) = @_;
local @ARGV = ($f);
my %fil = (defined $filterref)?%{$filterref}:();
my %fin = (defined $inref)?%{$inref}:();
my $fname = "";
my $ut = $f;$ut =~ s/^($base)//;
if( $f =~ /\.library\.txt$/ ){

$ut =~ s/\.library\.txt$//;
$fil{'Image'} = 'image';
while (<>){ 
if( $_ =~ /^url:\s*(.*?)\s*$/ ){ $fname = $1;$fdref->{$fname}{'filters'} = {}; }
foreach my $k( keys %fil ){ 

if( $_ =~ m/^$fil{$k}:\s*(.*?)$/i ){ 
my $rs = $1;
foreach my $j( keys %{$inref} ){ if( $j =~ /^($fil{$k})$/i && $inref->{$j} =~ /$rs/i ){ $termref->{$ut.$fname}{$j} = $rs; } }
if( $rs ne "" ){ if( defined $fdref->{$fname}{'filters'}{$k} ){ $fdref->{$fname}{'filters'}{$k}.= "\n$rs"; } else { $fdref->{$fname}{'filters'}{$k} = $rs; } }
}

}
} # continue { }

} else {

while (<>){ 
foreach my $k( keys %fil ){ my $ed = ($k eq "Author")?'':'edit';$ed.=$fil{$k};if( $_ =~ m/<meta content="(.*?)" name="$ed" \/>/i ){ my $rs = $1;$fdref->{$k}{'filters'}{$k} = $rs;
foreach my $j( keys %{$inref} ){ if( $j =~ /^($fil{$k})$/i && $inref->{$j} =~ /$rs/i ){ $termref->{$ut}{$j} = $rs; } }
} }
} # continue { }

}

return ($fdref,$termref);
}

sub search_searchshop{
my ($fileref,$fnref) = @_;
my @fs = sort keys %{$fileref};
my @terms = (defined $fnref)?@{$fnref}:();
for my $i(0..$#terms){ if( length($terms[$i]) < 3 ){ search_output("the search terms are too vague."); } }

our %SHOP = ();
our %RESULTS = ();
our %EXAMPLES = ();
our %COUNTS = ();
our %TITLES = ();
our @LIST = ();
our @LS = ();
my @entries = ();
my $intitle = undef;
my $sjs = undef;
my $out = "";
my $str = "";

foreach my $file(@fs){
if($file =~ /\/*(.*?)(\.js)$/i){
my $jn = $1;
$COUNTS{$file} = 0;

for my $i(0..$#terms){
$terms[$i] =~ s/\s/\\s/g;
if( ($jn =~ /^(.*$terms[$i].*)$/gim) ){ 
$COUNTS{$file}++;
$intitle = 'yes';
}
}

open(my $slist, "<$file") or $debug.= "error: $file not opened)<br />";
flock ($slist,2);
while(<$slist>){my $tmp = $_;$str.= $tmp;}
close($slist);

#{"entry":{"6":"24","1":"8 OF 3 MEDIUM FOOT","3":"5028","0":"GOOD","7":"0.9","9":"21.6","2":"4477"},"period":"ANATOLIAN/SYRIAN","type":"SPEARMEN"},
$TITLES{$file} = $jn; ###$debug.= "$file = $str<br />";
@entries = split /\},\{/,$str;

for my $i(0..$#terms){
$terms[$i] =~ s/\s/\\s/g;
if( !defined $intitle && !($str =~ /^(.*$terms[$i].*)$/gim) ){

$RESULTS{$file} = 'no';
last;

} else {

###$debug.= Data::Dumper->Dump([\@fs], ["fs"]), $/;search_output($debug);

$RESULTS{$file} = 'yes';
$EXAMPLES{$file} = "_JS_";
my @res = ();
for my $j(0..$#entries){ ###$debug.= "$j = $entries[$j] ";
if( defined $intitle || ($entries[$j] =~ /^(.*$terms[$i].*)$/gim) ){ 
$COUNTS{$file}++;
push @res,$entries[$j];
}
}
$SHOP{$file} = \@res;

}
}

}
}

foreach my $key(sort keys %RESULTS){
if($RESULTS{$key} eq 'yes'){
my $add = $key;
my $cs =$COUNTS{$key}; #my $cs = join ")(",@{ $COUNTS{$key} };
$add =~ s/^($base)/$baseview/;
my $t = $base;
$t =~ s/^\///;
$TITLES{$key} =~ s/^($t)//;
$TITLES{$key} =~ s/($spacer)/ /g;
$TITLES{$key} =~ s/  /-/g;
$TITLES{$key} =~ s/\~/\//g;
$TITLES{$key} =~ s/^(data_)//g;

if( $EXAMPLES{$key} eq "_JS_" ){
if( $TITLES{$key} !~ "00 navigation" ){
my $jt = "{ ".join(" },{ ",@{ $SHOP{$key} } ); 

$jt =~ s/\](\s)*$//;
if( $jt !~ /\}$/ ){ $jt.= " }"; }
$jt = "[".$jt."]";
$jt =~ s/^\[\{ \[\{/\[\{/; 
###$debug.= "$TITLES{$key} =  $jt<br /></br>";
$sjs = 1;push @LIST,[ $cs,"\"".$TITLES{$key}."\",\"".$cs."\",\"".(join ",",@terms)."\",$jt" ]; #15 American Civil War = [{ "entry":{"6":"24","3":"274","7":"1.5","9":"36","2":"41384","1":"UNION CAVALRY","4":"12 CAVALRY","0":"AVERAGE"},"period":"UNION CAVALRY","size":"25MM" }]

}

} elsif( $EXAMPLES{$key} eq "_PDF_" ){
push @LIST,[$cs,"<li><strong><a href=\"".$add."\">".$TITLES{$key}."</a></strong> <i> (PDF file)</i></li>\n"];
} else {
$EXAMPLES{$key} =~ s/\&#160;/ /g;push @LIST,[$cs,"<li><strong><a href=\"".$add."\">".$TITLES{$key}."</a></strong> ".$EXAMPLES{$key}." (".$cs." found)</li>\n"];
}

}
}

@LIST = sort { lc $b->[0] <=> lc $a->[0] } @LIST;
###search_html_out($debug);

for my $i(0..$#LIST){ $LS[$i] = $LIST[$i][1]; }
if( defined $sjs ){ 
my @r = ();
for my $i(0..$#LS){ push @r,$LS[$i]; }
sub_json_out({ 'results' => \@r },$origin,$callback)
} else { 
$out.= join "",@LS;
$out =~ s/\&/\&#36;/gm;
$out =~ s/\&\#160;/ /gm;
$out =~ s/\&\#169;/ /gm;
$out =~ s/\&#160;/ /gm;
search_output($out); 
}

}

sub search_searchsite{
# url: Managed-Services.pdf
# image: Managed-Services_thumb.jpg
# focus:
# area:
# tags:
# services
# title: Managed Services
# text:
# group:
# created:26/10/2017
# author: Andrew Downie
my ($ty,$dir,$oldref,$newref,$nobound,$filterref,$inref) = @_;
my %results = ();
my %infound = ();
my @old = (defined $oldref)?@{$oldref}:();
my @new = (defined $newref)?@{$newref}:(); 
my $dbug = undef;

if( $ty eq "tags" ){

find(sub { my $n = $File::Find::name;/^($bansearch)$/i and $File::Find::prune = 1;/($banfile)$/ and return;
if( $n =~ /\.($htmlext)$/ || $n =~ /\.library.txt$/ ){
my $fh = $n;$fh =~ s/^($base)//;
my %fd = ();my %fi = ();my($rref,$foundref) = search_searchtags($n,\%fd,$filterref,\%fi,$inref);
$results{$fh} = $rref;
$infound{$fh} = $foundref;
#$dbug.= "$fh = $results{$fh} \n"
}
},$dir);

} elsif( $ty eq "shopsearch" ){

find(sub { my $n = $File::Find::name;/^($bandir)$/i and $File::Find::prune = 1;/($banfile)$/ and return; /\.(js)$/ and $results{$n} = 0; },$dir);

} else {

if( scalar @old > 0 ){
find(sub { my $n = $File::Find::name;/^($bansearch)$/i and $File::Find::prune = 1;/($banfile)$/ and return;
my $ok = ( $n =~ /\.($htmlext)$/ )?1:undef;
if( defined $ok ){
my $fh = $n;$fh =~ s/^($base)//;
if( scalar @new > 0 ){
my $c = 0;@{ $results{$fh} } = @{ sub_searchreplace_file($n,$c,\@old,\@new,$nobound) };
} else {
my $c = 0;@{ $results{$fh} } = @{ sub_search_file($n,$c,\@old,$nobound) };
}
#$dbug.= "$fh = $results{$fh} \n"
}
},$dir);
}

}

return ($dbug,\%results,\%infound);
}