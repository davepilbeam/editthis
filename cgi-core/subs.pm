#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5

use cPanelUserConfig;
#editthis version:8.2.2 EDGE +novel

package subs;
use strict;

use CGI qw/:standard/;
use CGI::Util qw/escape unescape/;
use Data::Dumper;
use Encode qw(encode decode);
use File::Basename;
use File::Copy qw(cp mv);
use File::Copy::Recursive qw(dircopy);
use File::Find;
use File::Listing qw(parse_dir);
use List::Util 'shuffle';
use File::Path qw( mkpath rmtree ); #"use File::Path 2.07 qw( make_path remove_tree )";
use File::Spec;
use File::Spec::Functions 'catfile';
use File::Temp;
use File::stat;
use HTML::Entities;
use Symbol;
use Time::Local;
use Try::Tiny;
use URI::Encode;

my %MNS = ('january' => 0,'february' => 1,'march' => 2,'april' => 3,'may' => 4,'june' => 5,'july' => 6,'august' => 7,'september' => 8,'october' => 9,'november' => 10,'december' => 11);

my $uri = URI::Encode->new( { encode_reserved => 1 } );

sub sub_admin_backlevel{
# http://westfieldhealthdigitalresource.co.uk/documents/Images/Test-Folder2/ | documents/Images/news/TESTlogo_header.jpg | Solutions.Page-1.Level-2.html | Solutions.html | documents/Archive/Group-News/2017/News01.html
my($u,$cref) = @_;
my %c = %{$cref};
my $n = $u;
my $fn = undef;
my $f = undef;
my $dbug = "";
if( $n =~ /\.($c{'htmlext'})$/ ){
my $tmp = $n;$tmp =~ s/^($c{'base'}|$c{'baseview'})//;$tmp =~ s/\.($c{'htmlext'})$//;$dbug.= "tmp = $tmp \n"; ##==pilbeam # tmp = Contact
if( $tmp =~ /$c{'qqdelim'}/){
$tmp =~ s/^(.+)$c{'qqdelim'}.*?$/$1.$c{'htmlext'}/i;$n = $tmp; # Solutions.Page-1.html
$fn = $c{'base'}.$n;
} else {
$n = "";
}
} elsif( $n =~ /\/$/ ){
($n,$f) = sub_get_parent($n); # http://westfieldhealthdigitalresource.co.uk/documents/Images/
} elsif( $n =~ /\.($c{'fxfile'})$/i ){
$n =~ s/^(.+)\/.*?$/$1/i;($n,$f) = sub_get_parent($n); # documents/Images/
} else {
$n =~ s/($c{'chapterlister'}|$c{'liblister'}|$c{'taglister'})$//i;
}

###sub_json_out({ 'debug' => "check admin_backlevel: u:$u \n\n n:$n \n\n fn:$fn \ndbug:$dbug \n\n f: $f  = $c{'debug'}" },$c{'origin'},$c{'callback'}); #fu: /var/www/vhosts/pecreative.co.uk/thegatemaker.co.uk/thegatemaker.pecreative.co.html 
return ($n,$fn);
}

sub sub_admin_backuppages{
my ($cref) = @_;
my %c = (defined $cref)?%{$cref}:();
my $msg = "";
if( defined $c{'dest'} && -d $c{'base'} ){
my @htm = sub_get_html($c{'base'},$cref);foreach my $pz( @htm){ if( -f $pz ){ my $nz = $pz;$nz =~ s/^($c{'base'})//i;$nz =~ s/^\///;my $rerr = sub_admin_copy('Page',$pz,$c{'dest'}.$nz,$cref,"overwrite");if( defined $rerr){ $msg.= $rerr." = $nz\n"; } } }
} else {
$msg.= "Read error with folder $c{'dest'} or folder $c{'base'} \n";
}
###sub_json_out({ 'check backuppages' => "msg:$msg \n\n".Data::Dumper->Dump([\%c],["c"])."\n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
return $msg;
}

sub sub_admin_chooser{
my ($fu,$cref,$aref,$sel) = @_;
my %c = %{$cref};
my @ps = ( defined $aref )?@{ $aref }:();
my @ops = ();
my $dbug = "";
for my $i(0..$#ps){ my @ptm = @{ $ps[$i] };if( $ptm[0] =~ /^_select_group_$/ ){ push @ops,'<optgroup label="'.$ptm[1].'"></optgroup>'; } else { my $s = ( defined $sel && $sel eq $ptm[0] )?' selected':'';$dbug.= "sel: $sel == $ptm[0] $ptm[1]";push @ops,'<option value="'.$ptm[1].'"'.$s.'>'.$ptm[0].'</option>'; } }
###sub_json_out({ 'debug' => "check admin_chooser: fu:$fu \n sel:$sel  \n\n ".Data::Dumper->Dump([\@ops],["ops"])." \n\n ".Data::Dumper->Dump([\@ps],["ps"])." \n\n $dbug \n $c{'debug'}" },$c{'origin'},$c{'callback'});
return @ops;
}

sub sub_admin_copy{
my ($ty,$o,$n,$cref,$force) = @_;
my %c = %{$cref};
my ($rref,$ierr,$err,$dbug);
if( -f $n && !defined $force ){ return "this $ty already exists: [ $n ]"; }
return "rename error with $ty [ $o ] $!" unless -f $o;
cp ($o,$n) or try { die "admin_copy: copy $o to $n failed: $!"; } catch { $err = "admin_copy: copy $o to $n failed: $_"; };
if( !defined $err ){ 
if( -f $n ){ chmod (0664,$n) or try { die "admin_copy: chmod $n failed: $!"; } catch { $dbug = "admin_copy: chmod $n failed: $_"; }; } else { $dbug = "admin_copy: $n is not a file $!";  }
}
return $err;
}

sub sub_admin_delete{
my($ty,$u,$cref) = @_;
my %c = %{$cref};
my @hm = ();
my @als = ();
my $s = $u;$s =~ s/^($c{'base'})//;
my $vname = $s;$vname =~ s/\.($c{'htmlext'})$//;
my $dbug = "";
my $err = undef;
if( -d $u ){
rmtree("$u",{ error => \my $ierr });if( @$ierr ){ $err = "";for my $diag (@$ierr){my ($fi,$ms) = %$diag;if ($fi eq ''){ $err.= "general error: $ms\n"; } else { $err.= "problem deleting folder [ $fi ]: $ms\n"; }} }
} elsif( -f $u ){ 

if( $ty eq "page" ){ 

@hm = sub_get_html($c{'base'},$cref,$c{'base'});
for my $i(0..$#hm){
my $qm = '^'.quotemeta($vname).$c{'qqdelim'};
if( $hm[$i] =~ $qm ){ # u = News delete News_.+.html u = News_Test-Page.html delete News_Test-Page_.+.html #
$dbug.= "matches $vname$c{'delim'} = unlink $hm[$i]\n";
my $hname = $hm[$i];$hname =~ s/\.($c{'htmlext'})$//; #$dbug.= "save version $hm[$i]: $hname err = $err \n";
my $verr = sub_admin_save_version($hm[$i],$c{'base'}.$hm[$i],$hname,$cref,"deleted");$err = $verr if defined $verr;
if( -e $c{'base'}.$hm[$i] ){ unlink $c{'base'}.$hm[$i] or $err = "error: delete file [ $c{'base'}$hm[$i] ] failed: $!";$dbug.= sub_delete_og($hname,$cref); }
}
}
my ($alref,$amsg) = sub_get_aliases($s,$cref);$dbug.= $amsg;
my @als = @{$alref}; #$dbug.= "aliases: @als / ".(scalar @als)." / $amsg\n\n";
for my $i(0..$#als){
my $mname = $als[$i];$mname =~ s/\.($c{'htmlext'})$//; 
if( -e $c{'base'}.$als[$i] ){ unlink $c{'base'}.$als[$i] or $err = "error: delete file [ $c{'base'}$als[$i] ] failed: $!";$dbug.= "unlink $c{'base'}$als[$i]: err = $err \n";$dbug.= sub_delete_og($mname,$cref); }
}
if( -e $u ){ unlink $u or $err = "error: delete file [ $u ] failed: $!"; $dbug.= "unlink $u: err = $err\n";$dbug.= sub_delete_og($vname,$cref); }
} else {
if( -e $u ){ unlink $u or $err = "error: delete file [ $u ] failed: $!";$dbug.= "$ty = $u is missing\n"; }
}

} else {
$err = "error: delete [ $u ] failed: $!";
}

if( !defined $err && $ty eq "page" ){
my ($uerr,$n) = sub_admin_updatemenus($u,undef,undef,{'new-updateall' => 1},{},undef,1,$cref);$err = $uerr if defined $uerr && $uerr != 0;
###sub_json_out({ 'check admin_delete' => "ty:$ty u:$u \nn:$n \nuerr:$uerr \n $c{'debug'}" },$c{'origin'},$c{'callback'});
}
###sub_json_out({ 'check admin_delete 1' => "ty:$ty \nu:$u \ndbug: $dbug \n\n".Data::Dumper->Dump([\@hm],["hm"])."\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
return $err;
}

sub sub_delete_og{
my ($f,$cref) = @_;
my %c = %{$cref};
my $im = $f.".jpg";
my $err = undef;
if( $im !~ /default-page\.jpg$/ && -f $c{'base'}.$c{'cssview'}.$im ){ unlink $c{'base'}.$c{'cssview'}.$im or $err = "error deleting ".$c{'base'}.$c{'cssview'}.$im.": $! \n"; }
return $err;
}

sub sub_admin_dropsub{ my ($txt,$n,$t) = @_;return '<div class="inputline dropsub"><h2><input id="used'.$n.'_0" name="used'.$n.'_0" type="checkbox" /><label for="used'.$n.'_0" class="tt_tabclick navblock nav-edit editresult" tabindex="0" title="edit '.$t.'">'.$t.'</label><span class="dropspacer">&#160;</span><div class="inputline">'.$txt.'</div></h2></div>'; }

sub sub_admin_fixerror{
#documents/Images/news/TEST#logo_header.jpg
my ($u,$er,$n,$h,$cref) = @_;
my %c = %{$cref};
my ($pdir,$f) = sub_get_parent($u);
my $s = '';
my $ex = '<span class="alertfail">'.$er.': ';
my $ex1 = '<a href="'.$h.'" title="fix problem" target="_blank">manual fix required</a></span>';
###return "admin_fixeror: u:$u er:$er n:$n h:$h [ $pdir,$f ]\n";
if( $er =~ /permissions are changed to 664/i ){
my $perr = undef;
if( -f $c{'base'}.$u ){ chmod (0664,$c{'base'}.$u) or try { die "fixerror: chmod $u failed: $!"; } catch { $perr = "fixerror: chmod $u failed: $_"; }; } else { $perr = "fixerror: $u is not  a file: $_"; }
if( defined $perr){ $s = $ex.' <strong>'.$perr.'</strong> '.$ex1; } else { $s = '<span>'.$er.': <b>fixed</b></span>'; }
} elsif( $er =~ /permissions need to be changed to 775/i ){
my $terr = undef;
chmod (0775,$c{'base'}.$u) or try { die "fixerror: chmod $u failed: $!"; } catch { $terr = "fixerror: chmod $u failed: $_"; };
if( defined $terr){ $s = $ex.' <strong>'.$terr.'</strong> '.$ex1; } else { $s = '<span>'.$er.': <b>fixed</b></span>'; }
} elsif( $er =~ /Name contains/i ){ 
my $nname = $u;$nname =~ s/^(.+\/)//;
my $f = $1;
$nname =~ s/\.\./\./ig; #Name contains [..]
$nname =~ s/(\r|\n|\s)+/-/ig; #Name contains space Name contains invisible line ending
$nname =~ s/[^a-z0-9\-\~,\' _;\(\)\[\]\&\/\.]//ig; #'#Name contains illegal character
my ($rerr,$rmsg) = sub_rename($c{'base'}.$u,$c{'base'}.$f.$nname,$cref);
if( defined $rerr){ $s = $ex.' <strong>'.$rerr.'</strong> '.$ex1; } else { $s = '<span>'.$er.': <b>file renamed to</b> ('.$nname.') = '.$f.'</span>'; }
} elsif( $er =~ /<u class="old">(.*?)<\/u> does not match H1 Tag - try <u class="new">(.*?)<\/u>/i || $er =~ /TITLE Tag <u class="old">(.*?)<\/u> is wrong - try <u class="new">(.*?)<\/u>/i ){ 
my $old = $1;
my $new = $2;
my ($nferr,$nf) = sub_admin_new('page',$c{'base'}.$u,undef,{ 'new-titleurl' => $new,'old' => $old },$cref,'nomenus');
if( defined $nferr){ $s = $ex." <strong>Warning: problem with updating Title $nf: $nferr</strong> ".$ex1; } else { $s = '<span>'.$er.': <b>title renamed to</b> '.$new.'</span>'; }
} elsif( $er =~ /H1 Tag is missing - try <u class="new">(.*?)<\/u>/i ){ 
my $new = $1;
my ($nferr,$nf) = sub_admin_new('page',$c{'base'}.$u,undef,{ 'new-titleurl' => $new,'old' => "" },$cref,'nomenus');
if( defined $nferr){ $s = $ex." <strong>Warning: problem with updating Title $nf: $nferr</strong> ".$ex1; } else { $s = '<span>'.$er.': <b>title renamed to</b> '.$new.'</span>'; }
} elsif( $er =~ /Share URL <u class="old">(.*?)<\/u> is wrong - should be <u class="new">(.*?)<\/u>/i ){
my $old = $1;my $new = $2;
my ($nferr,$nfmsg) = sub_page_rewrite("alter",$c{'base'}.$u,{'code' => "code"},$cref,[],[ $u ]);
if( defined $nferr){ $s = $ex." <strong>Warning: problem with updating Share links [ $new -> $old ] $nfmsg: $nferr</strong> ".$ex1; } else { $s = '<span>'.$er.': <b>share links renamed to</b> '.$new.'</span>'; }
} else {
# File Extension is [.bak]
# File named $n does not exist
$s = $ex.$ex1;
}
return $s;
}

sub sub_admin_getmenu{ 
my ($u,$cref) = @_;my %c = %{$cref};my $m = "999.00";if( $u =~ /\.($c{'htmlext'})$/ && -f $u ){ my ($ierr,$otxt) = sub_get_contents($u,$cref,"text");if( !defined $ierr && $otxt =~ /<meta\s+content="(.*?)"\s+name="editmenu"/ ){ $m = $1;$m =~ s/\.00*$//;
if( $m =~ /^[0-9][0-9][0-9]$/ ){ 
$m.= '.999.00'; #008
} else {
$m =~ s/(\.)*([0-9][0-9][0-9])$/$1999.00/; #008.000 #008.001000
}
} }return $m; }

sub sub_admin_new{
# new-linkurl Mainframe-Services.Performance-Assurance.html
# old index.html
# url Mainframe-Services.Performance-Assurance.html
#OR
# new-titleurl Helping you make the most of your mainframe environment
# old Making mainframes work harder and more securely
# url index.html 
#OR
# new-menu 000.998
# new-updateall 1
# old 000.999
#OR
# new-baseurl => rsmpartners.com rsmpartners.com/UPLOADS/RESTORE/Mainframe-Skills-Removed~~11:05:55-17--11--2017/News.html
# new-baseid => RSM Partners
# new-copyright => Copyright (c) that\'sthat ltd 2017
# new-author => Dave Pilbeam
# new-overwrite => 1
#OR
# new-parent Solutions_
# new-menuurl New Page
# old documents/Templates-and-Guides/Default-Index-Template.html
# url New-Page.html
#OR
# changed new-menuurl|new-url||new-link
# new-menu 008.001.00
# new-area Security
# new-date 28/02/2017
# new-focus Bizarre
# new-group
# new-link
# new-tags winsome,eclectic
# new-text
# new-analytics_gref UA-58896111-1
# new-analytics_wref 49accf29-f990-4afc-8cb3-d248d186edf7
# new-author Dave Pilbeam
# new-copyright Copyright (c) that'sthat ltd 2017
# new-description RSM Partners is a global provider of mainframe services, software and expertise for IBM z systems, with a reputation for being flexible, reliable and agile.
# new-keywords z infrastructure, hardware, software, security, solutions, services, consultancy, staffing, support, delivery, audit, compliance, risk, vulnerability, remediation, penetration testing, migration, upgrades, hosting, disaster recovery, ISV
# new-shortname Newest One
# new-og:image //www.westfieldhealthdigitalresource.co.uk/LIB/index.jpg
# new-title New Title
# new-menuurl New Page
# old documents/Templates-and-Guides/Default-Page-Template.html
# new-parent Mainframe-Security.
# url documents/Templates-and-Guides/News-Default-Page-Template.html
my ($in,$u,$n,$pref,$cref,$nomenus) = @_;
my %data = (defined $pref)?%{$pref}:();if( defined $data{'class'} ){ delete $data{'class'}; }
my %c = %{$cref};
my %swap = ();
my $pre = "";
my $speed = undef;
my $write = (defined $data{'new-overwrite'})?undef:"nowrite";
my $upmenus = undef;
my $upm = undef;
my $subn = undef;
my $dbug = "";
my $err = undef;
###sub_json_out({ 'check admin_new' => "in:$in u:$u n:$n  \n\n".Data::Dumper->Dump([\%data],["data"])."\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
if( $in eq "page"){ #page

if( defined $data{'new-overwrite'} ){ delete $data{'new-overwrite'}; }
if( defined $data{'new-titleurl'} ){
$data{'new-title'} = $data{'new-titleurl'};delete $data{'new-titleurl'};
my ($merr,$mmsg,$mtxt) = sub_page_update($u,undef,\%data,undef,undef,"samemenu",$cref);
$err = $merr if defined $merr;
return ($err,$mtxt);
} elsif( defined $data{'new-baseurl'} ){
if( defined $data{'addallsite'} ){ delete $data{'addallsite'}; }
my ($merr,$mmsg,$mtxt) = sub_page_update($u,undef,\%data,undef,undef,undef,$cref,$write);
$err = $merr if defined $merr;
return ($err,$mtxt);
} else {
if( defined $data{'new-menuurl'} && $data{'changed'} =~ /new-menu(url)*/ ){ # Capacity Cost Reduction New
$data{'new-url'} = sub_title_in($data{'new-menuurl'},$cref).".".$c{'htmlext'};$data{'changed'}.= "||new-url"; # Capacity-Cost-Reduction-New.html
if( defined $data{'new-parent'} ){ # Mainframe-Services_
if( $data{'new-parent'} =~ /($c{'qqdelim'})$/ ){ $data{'new-url'} = $data{'new-parent'}.$data{'new-url'}; } # Mainframe-Services_Capacity-Cost-Reduction-New.html
delete $data{'new-parent'};
}
my $nu = $data{'new-url'};$nu =~ s/\.($c{'htmlext'})$/.jpg/; # Mainframe-Services_Capacity-Cost-Reduction-New.jpg
my $nulok = ( $nu =~ /($c{'cssview'})og\// )?'og/':'';
if( defined $data{'new-og:image'} || !-f $c{'baseview'}.$c{'cssview'}.$nulok.$nu ){
my $nulok = ( $nu =~ /($c{'cssview'})og\// )?'og/':'';
if( !-f $c{'baseview'}.$c{'cssview'}.$nulok.$nu ){ # //revive.pecreative.co.uk/LIB/Paper_About-Us_Who-We-Are.jpg
my $im = $c{'base'}.$c{'cssview'}.$nulok.$data{'url'};$im =~ s/\.($c{'htmlext'})$/.jpg/; #$dbug.= "og:image $im - change to ".$c{'base'}.$c{'cssview'}.$nulok.$nu." \n";
if( -f $im ){ $dbug.= "og:image $im exists - replace with ".$c{'base'}.$c{'cssview'}.$nulok.$nu."\n";$data{'new-og:image'} = $c{'baseview'}.$c{'cssview'}.$nu;mv ($im,$c{'base'}.$c{'cssview'}.$nulok.$nu) or $dbug.= "error renaming $im to $nu: $! \n";$data{'changed'}.= "||new-og:image"; } 
}
}
if( defined $data{'new-linkurl'} ){ $data{'new-link'} = $data{'new-linkurl'};$data{'new-link'}.= ".".$c{'htmlext'} if $data{'new-link'} !~ /\.($c{'httmlext'})$/;$data{'changed'}.= "||new-link";delete $data{'new-linkurl'}; }
if( defined $data{'new-link'} && defined $data{'url'} && $data{'new-link'} eq $data{'url'} ){ $data{'new-link'} = $data{'new-url'};$data{'changed'}.= "||new-link"; } # Mainframe-Services_Capacity-Cost-Reduction-New.html
delete $data{'new-menuurl'};$data{'changed'} =~ s/(\|\|)*new-menuurl//;
}

if( defined $data{'new-link'} ){ $data{'new-link'} = sub_title_deslash( $data{'new-link'},$c{'secsubs'} ); }
if( defined $data{'new-url'} ){ $data{'new-url'} = sub_title_deslash( $data{'new-url'},$c{'secsubs'} ); }

if( defined $data{'old'} && $data{'old'} ne "" ){
	#
$pre = $data{'old'};
$pre = $c{'templateview'}.$c{'deftemp'} if !-f $c{'base'}.$pre;
if( defined $data{'new-menu'} && defined $data{'new-updateall'} ){
###sub_json_out({ 'check admin_new 3' => "in:$in u:$u n:$n  \n\n".Data::Dumper->Dump([\%data],["data"])."\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
$upmenus = 1;
$upm = "samemenu";
###sub_json_out({ 'check admin_new 4' => "in:$in u:$u n:$n  \n\n".Data::Dumper->Dump([\%data],["data"])."\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
} elsif( $n ne "index" && defined $data{'new-linkurl'} ){
$data{'new-link'} = $data{'new-linkurl'};
$data{'new-url'} = $data{'new-linkurl'};
delete $data{'new-linkurl'};
$upmenus = 1;
$upm = "samemenu";
###sub_json_out({ 'check admin_new 5' => "in:$in u:$u n:$n  \n\n".Data::Dumper->Dump([\%data],["data"])."\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
} else {
if( $data{'type'} eq "changedupepages" ){ $n = $data{'new-url'}; }
###sub_json_out({ 'check admin_new 6' => "$data{'type'} = copy pre:$c{'base'}$pre to nw:$c{'base'}$n \n\n".Data::Dumper->Dump([\%data],["data"])."\n\n $dbug" },$c{'origin'},$c{'callback'});
if( !defined $data{'new-menuurl'} || $n eq "index" ){ 
if( $n eq "index" ){ $n = sub_check_name($data{'new-link'},$cref);$data{'new-url'} = $n; } else { if( !defined $data{'new-menu'}){ $n = sub_check_name($data{'new-url'},$cref);$data{'new-url'} = $n; } }
if( !defined $data{'new-menu'} && defined $data{'url'} ){ $data{'new-menu'} = sub_admin_getmenu($c{'base'}.$data{'url'},$cref);$data{'changed'}.= "||new-menu"; }
if( defined $data{'new-menu'} && !defined $data{'changed'} ){
$data{'changed'}.= "||new-menu";  
###sub_json_out({ 'check admin_new 7' => "$data{'type'} = copy pre:$c{'base'}$pre to nw:$c{'base'}$n \n\n".Data::Dumper->Dump([\%data],["data"])."\n\n $dbug" },$c{'origin'},$c{'callback'});
} else {
return ("error creating page $n from $pre: $! ",$n) if !-f $c{'base'}.$pre;
###sub_json_out({ 'check admin_new 8' => "$data{'type'} = copy pre:$c{'base'}$pre to n:$c{'base'}$n \n\n".Data::Dumper->Dump([\%data],["data"])."\n\n $dbug" },$c{'origin'},$c{'callback'});
my $rerr = sub_admin_copy('Page',$c{'base'}.$pre,$c{'base'}.$n,$cref);
if( defined $rerr){ return ($rerr,$n); } else { my @chs = split /\|\|/,$data{'changed'};for my $i(0..$#chs){ if( defined $data{$chs[$i]} && $data{$chs[$i]} =~ /^new-/ ){ $swap{$chs[$i]} = $data{$chs[$i]}; } } }
}
}
$upmenus = 1;
}
#
} else {
#
if( defined $data{'changed'} ){
$pre = $u;
$pre =~ s/^($c{'base'})//;
my @chs = split /\|\|/,$data{'changed'};for my $i(0..$#chs){ if( defined $data{$chs[$i]} ){ $swap{$chs[$i]} = $data{$chs[$i]}; } }
###sub_json_out({ 'check admin_new 9' => "in:$in \npre:$pre \nn:$n \n\n".Data::Dumper->Dump([\%swap],["swap"])."\n\n \n\n".Data::Dumper->Dump([\%data],["data"])."\n\n $dbug" },$c{'origin'},$c{'callback'});
if( defined $swap{'new-url'} ){ 
$n = sub_check_name($swap{'new-url'},$cref);
###sub_json_out({ 'check admin_new 10' => "pre:".$c{'base'}.$pre." \nn:".$c{'base'}.$n." \n\n".Data::Dumper->Dump([\%swap],["swap"])."\n\n $dbug" },$c{'origin'},$c{'callback'});
my $subslist = join "|",@{$c{'secsubs'}};
my @cm = sub_admin_rename("page",$c{'base'}.$pre,$c{'base'},$n,($pre =~ /^($subslist)/?$pre:""),undef,undef,$cref,$speed);
###sub_json_out({ 'check admin_new 11' => " \n\n".Data::Dumper->Dump([\@cm],["cm"])."\n\n $dbug" },$c{'origin'},$c{'callback'});
$dbug.= "\n".Data::Dumper->Dump([\@cm],["cm"])."\n";
if( !defined $swap{'new-link'} ){
$nomenus = 1;
if( defined $speed ){ if($speed eq "html"){ return($err,$n); } else { sub_json_out({ 'new-url' => "$pre updated successfully to $n",'reload' => $c{'pl'}."type=editpages&url=".( $uri->encode($n) ) },$c{'origin'},$c{'callback'}); } }
}
} else {
$n = $pre;
if( defined $swap{'new-link'} ){ $upmenus = 1; }
}
$upm = "samemenu";
%data = %swap;
}
#
}

}

###sub_json_out({ 'check admin_new 12' => "in:$in \npre:$pre \nu:$u \nn:$n \nsubn:$subn \nnomenus:$nomenus \nupm:$upm \nupmenus:$upmenus \n\n".Data::Dumper->Dump([\%data],["data"])."\n\n".Data::Dumper->Dump([\%swap],["swap"])."\n\n $dbug" },$c{'origin'},$c{'callback'});
if( defined $data{'new-menu'} && $data{'new-menu'} =~ /\.00$/ ){ $upmenus = undef; } #'new-menu' => '001.999.00',
if( !defined $nomenus ){ my ($uerr,$un) = sub_admin_updatemenus($u,$n,$subn,\%data,\%swap,$upm,$upmenus,$cref);$err = $uerr if defined $uerr && $uerr != 0; }

} else { #folder #files

if( -f $u ){
###sub_json_out({ 'check admin_new 12' => "in:$in \ncopy u:$u to $c{'base'}$n \n\n".Data::Dumper->Dump([\%data],["data"])."\n\n $dbug" },$c{'origin'},$c{'callback'});
$err = sub_admin_copy('File',$u,$c{'base'}.$n,$cref);return ("error creating file [ $c{'base'}$n ]: $err",$n) if defined $err;
} else {
if($u !~ /\/$/){ $u.= "/"; }
$n =~ s/^\///;
$n = sub_check_name($n,$cref);
if( -d $u.$n ){
if( !-d $u.$n."-copy" ){ $n.="-copy"; } elsif( !-d $u.$n."-copy2" ){ $n.="-copy2"; } else { $n.="-copy3"; }
$err = sub_folder_create($u.$n,$cref);
return ("error creating folder [ $u$n ]: $err",$n) if defined $err;
} else {
$err = sub_folder_create($u.$n,$cref);
return ("error creating folder [ $u$n ]: $err",$n) if defined $err;
###$err = sub_file_create($u.$n."/.library.txt","");return ("error creating file [ $u$n/.library.txt ]: $err",$n) if defined $err; ### ==pilbeam 
}
}

}


return ($err,$n); #if( !defined $speed || $speed eq "html" ){ sub_json_out({ 'query' => "$pre updated successfully" },$c{'origin'},$c{'callback'}); }
}

sub sub_admin_page_versions{
my ($n,$cref,$del) = @_;
my %c = %{$cref};
$n =~ s/(\.$c{'htmlext'})$//;
my %v = ();
my @gv = sub_get_versions($n,$cref,$del,"stats");
my $vlim = (defined $del)?$c{'delete_limit'}:$c{'version_limit'};
my $cc = $vlim;
my $dbug = "";
my $err = undef;
###sub_json_out({ 'check page_versions' => "n: $n \ndel:$del \n\n".Data::Dumper->Dump([\@v],["v"])."\n\nerr:$err \n\n$c{'debug'}" },$c{'origin'},$c{'callback'}); 
for my $i(0..$#gv){ $v{ $gv[$i][0] } = $gv[$i][1]; }
if( defined $vlim && scalar keys %v > $vlim ){ for my $k( sort { $v{$b} <=> $v{$a} } keys %v){ 
if( $cc < 1){ 
if( -f $c{'base'}.$c{'versionbase'}.$k ){ unlink $c{'base'}.$c{'versionbase'}.$k or try { die "page_versions: delete file $c{'base'}$c{'versionbase'}$k failed: $!"; } catch { $err = "page_versions: unable to delete file $c{'versionbase'}$k: $_"; }; } else { $err = "page_versions: unable to delete file $c{'versionbase'}.$k: $_"; }
$dbug.= "$cc > $vlim = $k = $v{$k} \n"; 
} else { 
$dbug.= "$cc < $vlim = deleting $k = $v{$k}\n"; 
}
$cc--;
} }
###sub_json_out({ 'check page_versions 1' => "n:$n \ndel:$del \nerr:$err \n$dbug \n\n$c{'debug'}" },$c{'origin'},$c{'callback'}); 
return (\%v,$err);
}

sub sub_admin_rankpages{
# index.html|000.0
# index2.html|000.00
# Mainframe-Skills.html|003|1
# Mainframe-Skills_Index-Page.html|003.001|2
# Mainframe-Skills_Project-Delivery.html|004.001|2
# Mainframe-Skills_Systems-Programming.html|004.002|2
# News.html|005.000|1
# News_RSM-assists-government-agency-zCloud-transition.html|001.001.0
# News_GSE-2016.html|001.002.0
# Solutions.html|002.000
# Solutions_Swiper.html|002.001
# Solutions_Slideshow.html|002.002
# Solutions_Presentation.html|002.003000
# Solutions_Presentation_Introduction.html|002.003001
# Solutions_Presentation_Wellness-Portal.html|002.003002.0
# Solutions_Tabs.html|002.004
# Solutions_Digital-Resource.html|002.005
# Contact.html|003.000
# Cookies.html|005.0
# Modules.html|004
# Modules_Index.html|004.000.00
# Terms-and-Conditions.html|006.0
# Site-Map.html|007.0
my ($ty,$u,$new,$cref,$outref) = @_;
my %c = %{$cref};
my @s = split /\|\|/,$new;
my %m = ();
my @ex = ();
my %out = ();
my %changed = ();
my @msg = ();
my @info = ();
my $j = 0;
my $k = 0;
my $m = 0;
my $o = 0;
my $depth = 1;
my $prepar = "";
my $par = "";
my $nextpar = "";
my $hider = "";
my $dbug = "";
for my $i(0..$#s){
my ($n,$v,$d) = split /\|/,$s[$i]; ##index.html|000.000|1
$n =~ s/\.($c{'htmlext'})$//; ##==pilbeam
my $level = $d;
my $w = $v;
my $oldn = $n;
my $lastex = "";
if( $w =~ /(\.(0|00))$/ ){ $w =~ s/(\.(0|00))$//;$lastex = $1; }
my $num = "";
if( $i > 0 ){ $prepar = $s[$i-1];my $tmp = $prepar;$tmp =~ s/\.($c{'htmlext'})\|(.+)$//; #Modules.Counter-Module.html|002.001|1
if( $tmp =~ /$c{'qqdelim'}/ ){$tmp =~ s/(.+)$c{'qqdelim'}.*?$/$1/;$tmp.= $c{'delim'};$prepar = $tmp;} else {$prepar = "";} } 
if( $i < $#s-1 ){ $nextpar = $s[$i+1];my $tmp2 = $nextpar;$tmp2 =~ s/\.($c{'htmlext'})\|(.+)$//; #Modules.Counter-Module.html|002.001|1
if( $tmp2 =~ /$c{'qqdelim'}/ ){$tmp2 =~ s/(.+)$c{'qqdelim'}.*?$/$1/;$tmp2.= $c{'delim'};$nextpar = $tmp2;} else {$nextpar = "";} }
$dbug = "\n\nIN = $n = $w \n";
if( $depth != $level ){ 
my $dr = ( $level > $depth )?1:undef;
if( $par ne $nextpar || ($par ne $prepar && $prepar =~ /$par/) ){ 
$dbug.= "UNLEVEL: [ $depth != $level ] dr:$dr par:$par ne next:$nextpar  || $par ne $prepar && $prepar contains $par \n";
if($level == 1){ $par = "";$n = sub_page_uplevel($n,$c{'qqdelim'}); } else { $par = $n;$par =~ s/\.($c{'htmlext'})$//;$par =~ s/(.+)$c{'qqdelim'}.*?$/$1/;$par.= $c{'delim'}; }
$depth = $level;
if(defined $dr){ 
if($depth == 2){ $j--;$k = 1; } elsif($depth == 3){ $k--;$m = 1; } else { if($depth == 4){ $m--;$o = 1; } } 
} else {
if($depth == 1){ $j++;$k = 0;$m = 0;$o = 0; } elsif($depth == 2){ $k++;$m = 0;$o = 0; } elsif($depth == 3){ $m++;$o = 0; } else { if($depth == 4){ $o++; } }$hider = "";
} 
$dbug.= "CHANGE TO: depth:$depth / dr:$dr / n:$n = oldn:$oldn / par:$par / prepar:$prepar / nextpar:$nextpar [$j $k $m $o] \n";
}
}
if( $depth == 1 ){ 
$num =  sub_admin_rankdrill($depth,$j); 
if( $w =~ /\.000$/ ){ $num.= ".000";$hider = $lastex;$depth++;$k = 1;$dbug.= "added 000 \n"; } else { $j++; }
#$dbug.= "\n\nNEXT: w = $w depth = $depth [$j $k $m $o]\n";
if( $n =~ /$c{'qqdelim'}/ ){ $par = "";$n = sub_page_uplevel($n,$c{'qqdelim'}); } else { $par = $n;$par =~ s/(.+$c{'qqdelim'}).*?$/$1/; }
} elsif( $depth == 2 ){ 
$num = sub_admin_rankdrill($depth,$j,$k);
if( $w =~ /\.[0-9][0-9][0-9]000$/ ){ $num.= "000";$depth++;$m = 1;$dbug.= "added 000 \n"; }
if( $n !~ /^($par)/ ){ 
my $cpar = "";
if( $level != $depth ){ 
$k++;
$n =~ s/^.+($c{'qqdelim'})//;$cpar = ($i == $#s)?"":(defined $nextpar)?$nextpar:(defined $prepar)?$prepar:$par;
$dbug.= "depth 2: LEVEL MISMATCH: [ $level != $depth ] / n:$n != par:$par / cpar:$cpar / num:$num [$j $k $m $o] \n";
$n = $cpar.$n;$prepar = $cpar;$level = scalar split /$c{'qqdelim'}/,$n;$depth = $level;$k = ($k+1) - $depth;
$dbug.= "depth: $depth m:$m ";if( $depth == 1 ){$j++;$hider = "";}$num = sub_admin_rankdrill($depth,$j,$k,$m);$num.= $hider;if( $depth == 2 ){$k++;} else { if( $depth == 3 ){$m++;} } 
} else { 
$dbug.= "depth 2: NAME MISMATCH: [ $level != $depth ] n:$n != par:$par / cpar:$cpar / num:$num [$j $k $m $o] \n";
$n = $par.$n;if( $w =~ /\.000$/ ){ $num.= '000';$depth++;$m = 1; }$num.= $hider;if( $depth == 3 ){$dbug.= "XX m:$m XX \n";}
}
} else { 
if( $level == $depth ){ $k++; }
$dbug.= "depth 2: NAME MATCH [ $level <> $depth ] n:$n == par:$par / prepar:$prepar nextpar:$nextpar / num:$num [$j $k $m $o] \n";
if( $hider ne ""){$lastex = $hider;} # else {$hider = $lastex;}
}
if( $depth == $level ){ $par = $n;$par =~ s/(.+$c{'qqdelim'}).*?$/$1/; }
} elsif( $depth == 3 ){ 
$num = sub_admin_rankdrill($depth,$j,$k,$m);
if( $w =~ /\.[0-9][0-9][0-9]000$/ ){ $hider = $lastex;$num.= "000";$depth++;$o = 1;$dbug.= "added 000 /1 \n"; } else {
if( $w =~ /\.[0-9][0-9][0-9][0-9][0-9][0-9]000$/ ){ $hider = $lastex;$num.= "000";$depth++;$o = 1;$dbug.= "added 000 /2 \n"; }
}
if( $n !~ /^($par)/ ){ 
my $cpar = "";
if( $level != $depth ){ 
$m++;
$n =~ s/^.+($c{'qqdelim'})//;$cpar = ($i == $#s)?"":(defined $nextpar)?$nextpar:(defined $prepar)?$prepar:$par;
$dbug.= "depth 3: UNLEVEL NAME MISMATCH: [ $level != $depth ] / n:$n  != par:$par / cpar:$cpar / num:$num [$j $k $m $o] \n";
$n = $cpar.$n;$prepar = $cpar;$level = scalar split /$c{'qqdelim'}/,$n;$depth = $level;$m = ($m+1) - ($depth-1);
$dbug.= "depth: $depth m:$m ";$num = sub_admin_rankdrill($depth,$j,$k,$m,$o);$num.= $hider;if( $depth == 3 ){$m++;} else { if( $depth == 4 ){$o++;} } 
} else { 
$dbug.= "depth 3: LEVEL NAME MISMATCH: [ $level == $depth ] / n:$n != par:$par / cpar:$cpar / num:$num [$j $k $m $o] \n";
$n = $par.$n;if( $w =~ /\.000$/ ){ $num.= '000';$depth++;$o = 1; }$num.= $hider;
}
} else { 
if( $level == $depth ){ $m++; }
$dbug.= "depth 3: NAME MATCH [ $level <> $depth ] n:$n == par:$par / prepar:$prepar nextpar:$nextpar / num:$num [$j $k $m $o] \n";
if( $hider ne ""){$lastex = $hider;} #else {$hider = $lastex;}
}
if( $depth == $level ){ $par = $n;$par =~ s/(.+$c{'qqdelim'}).*?$/$1/; }
} else {
if( $depth == 4 ){
$dbug.= "4 in = $w = [$j $k $m $o]\n";
$num = sub_admin_rankdrill($depth,$j,$k,$m,$o);
$dbug.= "depth 4: [ $level <> $depth ] n:$n == par:$par / prepar:$prepar nextpar:$nextpar / num:$num [$j $k $m $o] \n";
$o++;
if( $level == $depth && $n !~ /^($nextpar)/ && $prepar ne $nextpar ){ 
$dbug.= "depth 4: LEVEL NAME MISMATCH: [ $level == $depth ] / n:$n !~ nextpar:$nextpar / prepar:$prepar != nextpar:$nextpar / num:$num [$j $k $m $o] \n"; 
$n =~ s/^($prepar)/$nextpar/;
$dbug.= "CHANGE TO: depth:$depth / n:$n / par:$par / prepar:$prepar / nextpar:$nextpar [$j $k $m $o] \n";
}
if( $hider ne ""){$lastex = $hider;} #else {$hider = $lastex;}
}
}
$num.= $lastex;
$n.= ".".$c{'htmlext'};$oldn.= ".".$c{'htmlext'}; ##==pilbeam
if( $oldn ne $n && $new =~ /$n/i ){ 
$n =~ s/\.($c{'htmlext'})$/-copy\.$1/;if( $new =~ /$n/i ){ $n =~ s/-copy\./-copy1\./;if( $new =~ /$n/i ){ $n =~ s/-copy1\./-copy2\./; } } 
}
@{ $out{$v} } = ( $num );  
$dbug.= "v: $v == num: $num == oldn: $oldn == n: $n \n";
if( $v ne $num ){ $changed{$oldn} = { 'old' => $v,'new' => $num,'menuname' => ($oldn ne $n)?$n:$oldn }; } 
if( $ty eq "checkmenupages" ){ push @info,( ($v ne $num)?"<b>":"" )."<span class=\"mtitle\">$oldn: </span><u>$v</u><span class=\"mtitle\"> will ".( ($v eq $num)?"stay as":"become" )." </span><u>$num</u>".( ($oldn ne $n)?$n:"").( ($v ne $num)?"</b>":"" ); }
$dbug.= "$oldn: $v becomes $num ($n) / depth:$depth = level:$level / hider:$hider lastex:$lastex / [$j $k $m $o] / prepar:$prepar = parent:$par \n";
if( $oldn ne $n){ 
push @{ $out{$v} },($oldn,$n); 
$dbug.= "rename $oldn to $n \n\n";
###
my ($rerr,$rmsg) = sub_rename($c{'base'}.$oldn,$c{'base'}.$n,$cref);if( defined $rerr){ push @msg,$rerr; } else { $dbug.= $rmsg;push @msg,$rmsg; } 
}
$c{'debug'}.= $dbug;
}
###sub_json_out({ 'check admin_rankpages: ' => "ty: $ty \nu:$u \nsecsubs: $c{'secsubs'}\n new = $new \n\n".Data::Dumper->Dump([\%out],["out"])."\n\n msg:\n".( join "\n",@msg )." \n\n info:\n".( join "\n",@info )." \n\n $c{'debug'}" },$c{'origin'},$c{'callback'});

my @tmp = ();
my $prref = undef;
if( defined $outref && ref $outref eq 'ARRAY' ){
$prref = $outref;
} else {
my @subs = ($c{'base'});if(defined $c{'secsubs'} && scalar $c{'secsubs'} > 0){ push @subs,@{$c{'secsubs'}}; }for my $i(0..$#subs){ if($subs[$i] !~ /^($c{'base'})/){ $subs[$i] = $c{'base'}.$subs[$i]; } };
my ($prerr,$pref) = sub_page_return("menureorder",\@subs,$cref,undef,undef,undef,undef,undef,undef,\%out);
if( defined $prerr ){ sub_json_out({ 'error' => "admin_rankpages: prerr: $prerr \n\n".Data::Dumper->Dump([$prref],["prref"])."\n\n $c{'debug'}" },$c{'origin'},$c{'callback'}); } else { $prref = $pref; }
}

###sub_json_out({'check admin_rankpages 1: ' => "ty:$ty \nu:$u  \n\n".Data::Dumper->Dump([$outref],["outref"])."\n\n".Data::Dumper->Dump([$prref],["prref"])." \n\n $c{'debug'} " },$c{'origin'},$c{'callback'});
push @info,\%changed;
if( $ty ne "listmenupages" && $ty ne "checkmenupages" ){
my ($merr,$mmsg) = sub_return_menus("menureorder",$u,$prref,$cref,undef,undef,$outref);
if( defined $merr ){ push @msg,"warning: ".$merr; } else { push @msg,$mmsg; }
push @info,( join "\n",@msg );
}
###sub_json_out({'check admin_rankpages 2: ' => "ty:$ty \nu:$u \n\n".Data::Dumper->Dump([\@info],["info"])." \n\n $c{'debug'} " },$c{'origin'},$c{'callback'});
return @info;
}

sub sub_admin_rankdrill{
my ($d,$j,$k,$m,$o,$p) = @_;
my $n = "";
if( $d == 1 ){ $n = sub_numberpad($j,'100'); }
elsif( $d == 2 ){ $n = sub_numberpad($j,'100').".".sub_numberpad($k,'100'); }
elsif( $d == 3 ){ $n = sub_numberpad($j,'100').".".sub_numberpad($k,'100').sub_numberpad($m,'100'); }
elsif( $d == 4 ){ $n = sub_numberpad($j,'100').".".sub_numberpad($k,'100').sub_numberpad($m,'100').sub_numberpad($o,'100'); }
else { if( $d == 5 ){ $n = sub_numberpad($j,'100').".".sub_numberpad($k,'100').sub_numberpad($m,'100').sub_numberpad($o,'100').sub_numberpad($p,'100'); } }
return $n;
}

sub sub_admin_rename{
my ($ty,$u,$npar,$n,$par,$regexp,$usecase,$cref,$speed) = @_;
my %c = %{$cref};
my @cm = ();
my @hm = ();
my $uu = $u;$uu  =~ s/^($c{'base'})//;
my $uf = $uu; # members/Members.Competition.html
my $ur = $uf;$ur =~ s/($par)$/$n/; #
$uu =~ s/\.($c{'htmlext'})$//;
my $sn = $n;$sn =~ s/\.($c{'htmlext'})$//;
my $nn = $npar.$n; #/var/www/vhosts/secretmentalunit.com/thegatemaker.pecreative.co.uk/Mainframe-Services_Ad--Hoc-Skills-&-Resources:-Onsite-&-Remote.html
my $findstr = "";
my $xfind = "";
my $repstr = "";
my $xrep = "";
my $dbug = "";
my $inmenus = undef;
my $err = undef;
# u: /var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/documents/Images/Test-Folder/ 
# npar: /var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/ 
# n: Test-Folder2
# par: documents/Images/
#
# u: /var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/partners/Test2-Outer-Page.html 
# npar: /var/www/vhosts/pecreative.co.uk/partners/westfieldhealthdigitalresource.co.uk/ 
# n: partners/Test2-Outer-Page2.html 
# par: 
#
# ty: file 
# u: /var/www/vhosts/pecreative.co.uk/rsmpartners.com/documents/Images/backgrounds/header-news.png
# npar: /var/www/vhosts/pecreative.co.uk/rsmpartners.com/documents/Images/backgrounds/ 
# n: header-news6.png 
# par: header-news.png 
# nn: /var/www/vhosts/pecreative.co.uk/rsmpartners.com/documents/Images/backgrounds/header-news6.png
# uf: documents/Images/backgrounds/header-news.png 
###sub_json_out({ 'check admin_rename' => "ty:$ty \nu:$u [ exists:".( (-e $u)?"yes":"no" )." ] \n speed:$speed \n\nnpar:$npar \nn:$n \n par:$par \nnn:$nn [ exists:".( (-e $nn)?"yes":"no" )." ] \n uf:$uf to ur:$ur\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
if( -e $u ){
if( -e $nn ){  
if( -d $nn ){ $nn =~ s/(\/)$/-copy$1/i; } elsif( -f $nn ){ $nn =~ s/(\..*?)$/-copy$1/i; } else {}
if( -e $nn ){ $nn =~ s/\-copy/-copy2/; }
if( -e $nn ){ $nn =~ s/\-copy2/-copy3/; }
}
# rename 
# /var/www/vhosts/pecreative.co.uk/denmaur.com/Paper_Products_Revive_Test.html
# to
# /var/www/vhosts/pecreative.co.uk/denmaur.com/Paper_Products_Revive_Test_copy.html
$dbug.= "page: renaming $u to $nn \n";
mv ($u,$nn) or $err = "mv error renaming $u to $nn: $!";
if( !defined $err ){
if( $ty eq "page" ){
@hm = sub_get_html($c{'base'},$cref,$c{'base'});
for my $i(0..$#hm){
my $nw = $hm[$i];
$dbug.= "test: $hm[$i] for $uu|$c{'qqdelim'} \n";
if( $hm[$i] =~ /(^|$c{'qqdelim'})($uu)$c{'qqdelim'}/ ){
$nw =~ s/(^|$c{'qqdelim'})($uu)($c{'qqdelim'})/$1$sn$3/;
mv ($c{'base'}.$hm[$i],$c{'base'}.$nw) or $err = "error renaming $u to $n: $!";
$xfind.= "+$1$2$3";
$xrep.= "+$1$sn$3";
$inmenus = 1;
$dbug.= "sub: renaming $hm[$i] to $nw \n";
}
}
$findstr = $uu.".".$c{'htmlext'}.$xfind;
$repstr = $n.$xrep;
} else {
$findstr = ($ty eq 'file')?$uf:$nn.$par;$findstr =~ s/^($c{'base'})//;
$repstr = ($ty eq 'file')?$ur:$nn.$n;$repstr =~ s/^($c{'base'})//;
}
}
} else {
$err = "error renaming $ty $u to $nn: unknown file $!";
}
if( defined $err){
@cm = ( "Warning: $err" );
} else {
###sub_json_out({ 'debug' => "check admin_rename 1: ty:$ty \n findstr:$findstr \n repstr:$repstr \n hm:[ ".( join "\n",@hm )."] \n dbug: $dbug \n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
@cm = sub_get_changed( (($ty eq "page")?"pages":"all"),"rename",$c{'seclist'},$cref,$findstr,$repstr,"alter",$regexp,"code",$usecase,$inmenus,undef,$speed);
}
return @cm;
}

sub sub_admin_save_page{
my ($u,$fu,$ntxt,$cref,$og,$over) = @_;
my %c = %{$cref};
$u =~ s/^($c{'baseview'})//;
my $vname = $u;$vname =~ s/\.($c{'htmlext'})$//;
my $un = $vname;
$ntxt = sub_clean_utf8( $ntxt,$c{'UTF'},$c{'UTF1'},undef,"keep urls" ); #"despace"
my $err = undef;
my $rerr = undef;
###sub_json_out({ 'check save_page' => "u:$u \nfu:$fu \nvname:$vname \nun:$un \n\nntxt:\n$ntxt \n\n$err \n\n".$c{'debug'} },$c{'origin'},$c{'callback'});
if( $fu =~ /($c{'chapterlister'}|$c{'liblister'}|$c{'taglister'})$/ ){ 
$err = sub_file_create($fu,"") unless !defined $over && -f $fu;return ("page save: error creating file [ $fu ]: $err") if defined $err; $err = sub_page_print($fu,$ntxt);
} else { 
return ("page save: server cannot locate file: $fu $c{'debug'} $! ") unless -f $fu; 
$rerr = sub_admin_save_version($u,$fu,$vname,$cref);
if( defined $rerr){ $err = $rerr." = $vname"; } else { $err = sub_admin_save_write($fu,$u,$cref,$ntxt,$un,$og); }
}
###sub_json_out({ 'check save_page 1' => "u:$u \nfu:$fu \nun:$un \n\nntxt:\n$ntxt \n\n$err \n\n".$c{'debug'} },$c{'origin'},$c{'callback'});
return ($err,$u);
}

sub sub_admin_save_version{
my ($u,$fu,$vname,$cref,$del) = @_;
my %c = %{$cref};
my $vn = sub_get_date(time,$cref,"-","version");$vn =~ s/-/--/g;$vn =~ s/ /-/g;
$vname.= $c{'repdash'}.$c{'repdash'}.( (defined $del)?$del.$c{'repdash'}:"" );
$vname.= $vn.".".$c{'htmlext'}; # Who-We-Are.Careers~~12:18:54-26--11--2015.html Who-We-Are.Careers~~deleted~12:18:54-26--11--2015.html
my $err = undef;
if( $fu !~ /^($c{'base'}$c{'docview'})/ && $fu !~ /^($c{'base'})partners\// ){
my $rerr = sub_admin_copy('Page',$fu,$c{'base'}.$c{'versionbase'}.$vname,$cref,"overwrite");
if( defined $rerr){ 
$err = $rerr." = $vname"; 
} else {
my ($iref,$ierr) = sub_admin_page_versions($u,$cref,$del);$err = "There was a version error with $u: $ierr" if defined $ierr;
}
}
return $err;
}

sub sub_admin_save_write{
#					<div class="m-pusher-container css-move"> 
#						<div id="tt_alldiv">
#							<div id="tt_topbar">
#							</div>
#							<div id="tt_topdiv" class="tt_animate shadow" data-scrolltrigger="460" data-scrollclass="topdivscroll">
#							</div>
#							<div id="tt_mobdiv">
#								<div id="tt_scrolldiv">
			
#									<div class="section topsection">
#									</div>						
#									<div class="section footersection">
#										<div class="sectionfooterinner">
#											<div class="wrappergrid">
#												<ul class="area editablearea footerarea twotwogrid">
#												</ul>
#											</div>
#										</div>
#									</div>
#								</div>
#							</div>
#						</div>
#					</div>
#				<div class="tt_editref"></div>
my ($fu,$u,$cref,$ntxt,$un,$up) = @_;
my %c = %{$cref};
my $mod = time;
my $lok = $un;
my $rr = "";
my $err = undef;
my ($ierr,$otxt) = sub_get_contents($fu,$cref,"text");
if( !defined $ierr ){

if( $fu !~ /$c{'templateview'}/ && defined $up && $up =~ /og/ ){
if( $up eq "unlock og" ){ $lok =~ s/og\///; } else { if( $up eq "lock og" ){ $lok = "og/".$un; } }
$otxt =~ s/<meta(\s+content=".*?")* property="og:image"(\s+content=".*?")* \/>/<meta property="og:image" content="$c{'baseview'}$c{'cssview'}$lok.jpg" \/>/; 
}
if( defined $up && $up =~ /rank/ ){  if( $otxt =~ /<meta\s+content="(.*?)"\s+name="editmenu"\s*\/>/ ){ $rr = $1;
my $dot = $rr;$dot =~ s/\.(0|00)$//;if($dot =~ /\./){$un =~ s/\.//g;}
if($rr =~ /^(.+)\.00$/){$rr = $1.$un.".00";} else {$rr.= $un;}$otxt =~ s/<meta\s+content=".*?"\s+name="editmenu"\s*\/>/<meta content="$rr" name="editmenu" \/>/; } } #<meta content="006.00" name="editmenu" /> 006.000.00
$otxt =~ s/<meta content="([0-9]+)" name="editmodified"\s*\/>/<meta content="$mod" name="editmodified" \/>/;
if( defined $ntxt ){ $ntxt =~ s/\s*<div class="tt_editref"><\/div>\s*$//;$otxt =~ s/^(.+)(<div id="tt_alldiv".*?>.+<\/div>)(\s*<div class="tt_editref"><\/div>.+)$/$1$ntxt$3/ism; }
###sub_json_out({ 'check save_write 1' => "fu:$fu \nu:$u \nun:$un \nlok:$lok \nup:$up \nrr: $rr \n\n print otxt:\n$otxt \n\nntxt:\n$ntxt \n\n$err \n\n".$c{'debug'} },$c{'origin'},$c{'callback'});
my $herr = sub_page_print($fu,$otxt);
if( !defined $herr ){
if( $fu !~ /$c{'templateview'}/ && $fu !~ /($c{'docview'})Archive/i && $fu !~ /^($c{'base'})partners\//i ){
if( defined $up && $up =~ /^(unlock|lock)/ ){ 
if($up =~ /^unlock/){ my ($rerr,$rmsg) = sub_rename($c{'base'}.$c{'cssview'}."og/".$un.".jpg",$c{'base'}.$c{'cssview'}.$un.".jpg",$cref);if( defined $rerr){ $err = $rerr; } } else { my ($rerr,$rmsg) = sub_rename($c{'base'}.$c{'cssview'}.$un.".jpg",$c{'base'}.$c{'cssview'}.$lok.".jpg",$cref);if( defined $rerr){ $err = $rerr; } }
} else {
if( $un !~ /^og\// ){

my ($gerr,$gtxt) = sub_image_generate('og image',$c{'base'}.$u,$c{'base'}.$c{'cssview'}.$u,{ 'PageWidth' => "1200",'CropHeight' => "800",'ConversionDelay' => "5",'ImageQuality' => "70" },'vZpqbZTSJy4AUDTi','html',$cref);
if( defined $gerr ){ $err = $gerr;my $cerr = sub_admin_copy('Image',$c{'base'}.$c{'cssview'}."default-page.jpg",$c{'base'}.$c{'cssview'}.$un.".jpg",$cref,"overwrite"); } else { if($un =~ /\//){ my $rr = $un;$rr =~ s/\///g;my ($rerr,$rmsg) = sub_rename($c{'base'}.$c{'cssview'}.$un.".jpg",$c{'base'}.$c{'cssview'}.$rr.".jpg",$cref);if( defined $rerr){ $err = $rerr; } } } 
}
}
}
} else {
$err = "save_page error: $herr $! ";
}
} else {
$err = "save_page error: $ierr";
}
###sub_json_out({ 'check save_write 3' => "err:$err \n\nfu:$fu \nu:$u \nun:$un \nlok:$lok \nup:$up \nrr: $rr \n\n print otxt:\n$otxt \n\nntxt:\n$ntxt \n\n$err \n\n".$c{'debug'} },$c{'origin'},$c{'callback'});
return $err;
}

sub sub_admin_search{ # ins:all ty:used fu:/var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/ findstr:documents/Images/news/
### $m{'documents'} => {
# 'documents/Images/news/CIOReviewlogo_header.jpg' => {
# 'parent' => [ 'documents/Images/news' ],
# 'epoch' => [ 1481537095 ],
# 'menuname' => [ 'CIOReviewlogo_header.jpg' ],
# 'path' => [ 'documents', 'Images', 'news', 'CIOReviewlogo_header.jpg' ],
# 'mobile' => [ 'CIOReviewlogo_header_mobile.jpg' ],
# 'size' => [ '26k' ],
# 'published' => [ '12/12/2016' ],
# 'href' => [ 'documents/Images/news/CIOReviewlogo_header.jpg' ],
# 'used' => [ 'News_RSM-Included-in-Most-Promising-IBM-Solutions-Providers-2015.html' ],
# 'url' => [ 'documents/Images/news/CIOReviewlogo_header.jpg' ]
# },
# 'documents/Digital/Posters/I-voted-with-my-feet/Print/A3---300dpi-CMYK.pdf' => {
# 'area' => [ 'UK-Europe' ],
# 'author' => [ 'Ben Bloke' ],
# 'focus' => [ 'Financial','Maverick' ],
# 'size' => [ '1918k' ],
# 'group' => [ '\'I voted with my feet\' poster','Use the links below to download artwork' ],
# 'text' => [ 'An A2 Print document that is meant to be a test.','Another line of text goes here.' ],
# 'href' => [ 'documents/Digital/Posters/I-voted-with-my-feet/Print/A3---300dpi-CMYK.pdf' ],
# 'url' => [ 'A3---300dpi-CMYK.pdf' ],
# 'parent' => [ 'documents/Digital/Posters/I-voted-with-my-feet/Print' ],
# 'epoch' => [ 1482235839 ],
# 'epochcreated' => [ 1479081600 ],
# 'menuname' => [ 'A3---300dpi-CMYK.pdf' ],
# 'path' => [ 'documents','Digital','Posters','I-voted-with-my-feet','Print','A3---300dpi-CMYK.pdf' ],
# 'tags' => [ 'England','Ireland','Scotland','Wales' ],
# 'image' => [ 'A3---300dpi-CMYK_thumb.jpg' ],
# 'created' => [ '14/11/2016' ],
# 'published' => [ '20/12/2016' ],
# 'title' => [ 'A3 - 300dpi CMYK.pdf' ]
# },
my ($ins,$ty,$fref,$cref,$findstr,$repstr,$alter,$regex,$code,$case,$inmenus,$inlistdir,$speed) = @_;
if( ref $fref ne "ARRAY" ){ $fref = [$fref]; }
my $u = $fref->[0];
my %c = %{$cref};
my %m = ( 'ins' => $ins,'url' => $fref->[0],'alter' => $alter,'regex' => $regex,'case' => $case,'code' => $code,'searched' => {},'menu' => $inmenus );
my $utype = (defined $ins && $ins eq "all")?"all":(defined $ins && $ins eq "pages")?"pages":(defined $u && $u !~ /\.($c{'fxfile'})$/i)?"folder":(defined $u && $u =~ /\.($c{'htmlext'})$/i)?"pages":(defined $u && $u =~ /\.($c{'fxfile'})$/i)?"file":(defined $c{'documents'} && defined $c{'pages'})?'all':(defined $c{'documents'} && !defined $c{'pages'})?'folder':'pages';
my @ls = ( 'blocks','pages' );
my $dbug = "";
my $msg = undef;
###sub_json_out({ 'check admin_search' => "utype:$utype \nins:$ins \ninlistdir:$inlistdir \nu:$u \nfref:@{$fref} \nfindstr:$findstr \nrepstr:$repstr \n speed:$speed \nalter:$alter \nregex:$regex \ncode:$code \ncase:$case\n\n".Data::Dumper->Dump([\%m],["m"])."\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
foreach my $ar( sort keys %{ $c{'editareas'} } ){ if( $c{'editareas'}{$ar} > 1 ){ push @ls,$ar; } } # [ 'blocks','pages','date','link','menu','shortname','menuname','url' ]
if( defined $inmenus ){ push @ls,('menutext','sitemaptext'); }
my @terms = (defined $findstr)?split /\+/,$findstr:undef; #sausage+water
my @reps = (defined $repstr)?split /\+/,$repstr:undef; #sausage1+water1
@{ $m{'find'} } = @terms;
@{ $m{'replace'} } = @reps;

if( defined $speed && defined $alter ){

$| = 1;
my $pid = fork;
sub_log_out({ 'check admin_search A' => "failed to fork: $!\n dbug:$dbug \n$c{'debug'}" },$c{'base'}) unless defined $pid;
if ($pid == fork){ #parent end
###sub_log_out({ 'check admin_search B' => "forked: $!\n dbug:$dbug \n$c{'debug'}" },$c{'base'});
###sub_json_out({ 'check admin_search B' => "ty:$ty \nutype:$utype \nu:$u \n\n pid:$pid \n\n $dbug" },$c{'origin'},$c{'callback'});
return ($msg,\%m);
} else { #child
close(STDOUT);
my ($umsg,$udbug) = admin_search_update($utype,$fref,\%m,\@ls,$alter,$regex,$case,$code,$inmenus,$inlistdir,$cref,$dbug);
###sub_log_out({ 'check admin_search C' => "msg:$umsg \ndbug:$udbug \n\n $c{'debug'}" },$c{'base'});
exit(0);
}

} else {
my ($umsg,$udbug,$umref) = admin_search_update($utype,$fref,\%m,\@ls,$alter,$regex,$case,$code,$inmenus,$inlistdir,$cref,$dbug);
if( defined $umsg ){ $c{'debug'}.= $umsg; };
$dbug = $udbug;
%m = %{$umref};
###sub_json_out({ 'check admin_search D' => "umsg:$umsg \nudbug:$udbug \n\n".Data::Dumper->Dump([$umref],["umref"]) },$c{'origin'},$c{'callback'});
}

###sub_json_out({ 'check admin_search E' => "$dbug \n\n ins: $ins \n utype = $utype \n \nu:$u \nfref:@{$fref} \n\n".Data::Dumper->Dump([\%m],["m"]) },$c{'origin'},$c{'callback'});
return ($msg,\%m);
}

sub admin_search_update{
my ($utype,$fref,$mref,$lsref,$alter,$regex,$case,$code,$inmenus,$inlistdir,$cref,$dbug) = @_;
my %m = %{$mref}; 
my @ls = @{$lsref};
my %c = %{$cref};
my @terms = @{ $m{'find'} };
my @reps = @{ $m{'replace'} };
my $msg = undef;

###sub_json_out({ 'check admin_search_update' => "utype:$utype \nfref:@{$fref} \ncode $code \ninmenus:$inmenus \n\n".Data::Dumper->Dump([\%m],["m"])."\n\n $dbug" },$c{'origin'},$c{'callback'});
if( $utype eq "all" || $utype eq "pages" ){
my ($perr,$pref) = sub_page_return("searchpages",$fref,$cref,undef,undef,undef,undef,undef,undef,undef,$inmenus,undef,$code,$inlistdir);
return ("search page alert: no useable data retrievable by server: $utype: $perr",$dbug,\%m) unless defined $pref && !defined $perr;
###sub_json_out({ 'check admin_search_update 1' => "utype:$utype \nfref:@{$fref} \ncode: $code \ninmenus: $inmenus \nperr:$perr \n\n".Data::Dumper->Dump([$pref],["pref"])."\n\n $dbug" },$c{'origin'},$c{'callback'});
my @tmp = @{$pref};
for my $i(0..$#tmp){ 
my $pg = $tmp[$i]->{'url'}[0];$dbug.= "searching $pg.. \n";
###$m{'pages'}{$pg} = $tmp[$i]; 
###sub_json_out({ 'check admin_search_update 2' => "type:$utype \nfref:@{$fref} \npg: $pg \n\n".Data::Dumper->Dump([$tmp[$i]],["tmp $i"])."\n\n $dbug" },$c{'origin'},$c{'callback'});
sub_page_findreplace($tmp[$i],\@ls,$m{'searched'},$cref,\@terms,\@reps,$regex,$case,"where",$code,$inmenus);
###if($pg =~ /BOOM_/){
###sub_json_out({ 'check admin_search_update 3' => "file: $pg \n".Data::Dumper->Dump([$tmp[$i]],["tmp $i"])."\n\n \nalter: $alter \npg:$pg \n\n".Data::Dumper->Dump([$m{'searched'}{$pg}],["$pg"])."\n\n  type:$utype \nu:$u \nfref:@{$fref} \n\n $dbug" },$c{'origin'},$c{'callback'});
###}
}
###sub_json_out({ 'check admin_search_update 4' => "code:$code \n utype:$utype \nalter:$alter \nfref:@{$fref} \n\n".Data::Dumper->Dump([\%m],["m"])."\n\n $dbug" },$c{'origin'},$c{'callback'});
}
if( $utype eq "all" || $utype eq "folder" ){
my ($ierr,$iref) = sub_get_source($fref,"searchfolders",$cref);
return ("search folder alert: no useable data retrievable by server: $utype: $ierr",$dbug,\%m) unless defined $iref && !defined $ierr;
my %ftmp = %{ @{ $iref }[0]->{'files'} };
###sub_json_out({ 'check admin_search_update 5' => "type:$utype \nfref:@{$fref} \n\n".Data::Dumper->Dump([\%ftmp],["ftmp"])."\n \n $dbug" },$c{'origin'},$c{'callback'});
foreach my $k( keys %ftmp ){ 
sub_file_findreplace($ftmp{$k},\@ls,$m{'searched'},$cref,\@terms,\@reps,$regex,$case,"where");
###sub_json_out({ 'check admin_search_update 6' => "utype:$utype \nfref:@{$fref} \n\n".Data::Dumper->Dump([\%m],["m"])."\n \n $dbug" },$c{'origin'},$c{'callback'});
}
}
if( defined $alter && scalar keys %{ $m{'searched'} } > 0 ){ 
foreach my $k( sort keys %{ $m{'searched'} } ){
my %tm = %{ $m{'searched'}{$k} };
$dbug.= "searched ALTER: $k = ".Data::Dumper->Dump([$m{'searched'}{$k}],["m"])."\n\n total: $tm{'total'}  \n";
###sub_json_out({ 'check admin_search_update 7' => "$k = $dbug \n\ninmenus:$inmenus \ncode:$code \n\n".Data::Dumper->Dump([\%tm],["tm"]) },$c{'origin'},$c{'callback'});
if( defined $tm{'total'} && $tm{'total'} > 0 ){ 
if( $k =~ /\.($c{'htmlext'})$/ ){ 
my ($werr,$wmsg);
my %htmp = (defined $tm{'new'} && ref $tm{'new'} eq "ARRAY" )?( 'blocks' => 1,'code' => $code,'inmenus' => $inmenus ):( ref $tm{'new'} eq 'SCALAR' && $tm{'new'} ne "")?( 'new' => $tm{'new'} ):( 'blocks' => 1,'meta' => 1,'tags' => 1,'code' => $code,'inmenus' => $inmenus );

#if( defined $tm{'new'} ){
#if( ref $tm{'new'} eq 'SCALAR') && $tm{'new'} ne "" ){ ($werr,$wmsg) = sub_page_rewrite("alter",$c{'base'}.$k,{ 'new' => $tm{'new'} },$cref); } else {($werr,$wmsg) = sub_page_rewrite("alter",$c{'base'}.$k,{ 'blocks' => 1,'code' => $code,'inmenus' => $inmenus },$cref,\@terms,\@reps,$regex,$case);  }
#($werr,$wmsg) = sub_page_rewrite("alter",$c{'base'}.$k,\%htmp,$cref,\@terms,\@reps,$regex,$case);
#}

($werr,$wmsg) = sub_page_rewrite("alter",$c{'base'}.$k,\%htmp,$cref,\@terms,\@reps,$regex,$case);
if( defined $werr ){ if( !defined $msg ){ $msg = $c{'base'}."$k: $werr $wmsg \n"; } else { $msg.= $c{'base'}."$k: $werr $wmsg \n"; } }$dbug.= $c{'base'}."$k: $wmsg \n";
} else {
my $fmsg = sub_file_rewrite($c{'base'}.$k,$cref,\@terms,\@reps,$regex,$case);
if( !defined $msg ){ $msg = $fmsg; } else { $msg.= $fmsg; }$dbug.= $c{'base'}."$k: $fmsg \n";
}
}
}
}

###sub_json_out({ 'check admin_search_update 8' => "$dbug \n utype:$utype \nfref:@{$fref} \nmsg:$msg \n\n".Data::Dumper->Dump([\%m],["m"]) },$c{'origin'},$c{'callback'});
return ($msg,$dbug,\%m);
}

sub sub_file_rewrite{
my ($f,$cref,$tref,$rref,$regex,$case) = @_;
my $u = "";
my $dir = $f;$dir =~ s/^(.+\/)(.*?)$/$1/;$u = $2;
my %c = %{$cref};
my $lister = $dir.$c{'liblister'};
my $chaplister = $dir.$c{'chapterlister'};
my @terms = @{$tref};
my @reps = @{$rref};
my @intxt = ();
my $msg = "";
my $ok = undef;

if( -f $lister || -f $chaplister ){
my $ls = ( -f $lister )?$lister:$chaplister;
my ($ierr,$otxt) = sub_get_contents($ls,$cref,"text");$msg = "warning: file $ls not found: skipping $u <br />" if defined $ierr;
if( $msg eq "" ){
$msg.= "rewriting $u:<br />";
@intxt = split /\n/,$otxt;
for my $i(0..$#intxt){
if( $intxt[$i] !~ /:$/ ){

for my $j( 0..$#terms){
if( defined $case ){
if( $intxt[$i] =~ /$terms[$j]/ ){ $intxt[$i] =~ s/($terms[$j])/$reps[$j]/g;if(!defined $ok){$ok = "";}$ok.= 'line '.$i.': '.$terms[$j].' replaced with '.$reps[$j].'<br />';$msg.= $ok; }
} else {
if( $intxt[$i] =~ /$terms[$j]/i ){ $intxt[$i] =~ s/($terms[$j])/$reps[$j]/gi;if(!defined $ok){$ok = "";}$ok.= 'line '.$i.': '.$terms[$j].' replaced with '.$reps[$j].'<br />';$msg.= $ok; }
}
}

}
}
}

# url: 1-Corporate-Overview.pdf\n
# image: OverviewInfographic100_thumb.jpg\n
# focus:\n
# area:\n
# tags: security
# tags: software
# title: Corporate Overview\n
# text:\n
# group:\n
# created: 14/11/2016\n
# author: Andrew Downie\n
# \n
# url: 2-RSM-Systems-Engineer.pdf\n
# image: RSM-Systems-Engineer_thumb.jpg\n
# focus:\n
# area:\n
# tags:\n
# title: RSM Systems Engineer\n
# text:\n
# group:\n
# created: 14/11/2016\n
# author: Andrew Downie\n
###sub_json_out({ 'check file_rewrite' => "f:$f \n u:$u \ndir:$dir \n\nintxt: [\n ".( join "\n",@intxt )." \n] \nok:$ok \n\nterms:[ @terms ] \nreps:[ @reps ] \nregex:$regex \ncase:$case \nmsg:$msg" },$c{'origin'},$c{'callback'});
if( defined $ok){
my $herr = sub_page_print($ls,(join "\n",@intxt));if( defined $herr ){ $msg.= $herr; } else { $msg.= "<i>updated</i><br />"; }
}

} else {
$msg.= "warning: file $lister or $chaplister not found: skipping $u <br />";
}

###sub_json_out({ 'check file_rewrite 1' => "f:$f \n u:$u \ndir:$dir \n\nintxt: [\n ".( join "\n",@intxt )." \n] \nok:$ok \n\nterms:[ @terms ] \nreps:[ @reps ] \nregex:$regex \ncase:$case \nmsg:$msg" },$c{'origin'},$c{'callback'});
return $msg;
}

sub sub_admin_test_name{
my ($fu,$cref) = @_;
my %c = %{$cref};
my @s = ();
my $n = $fu;$n =~ s/^($c{'base'})//;$n =~ s/^($c{'docview'})//;
my $o = undef;
if( $n =~ /\.\./ ){ push @s,"Name contains [..]"; }
if( $n =~ / /i ){ push @s,"Name contains space"; }
if( $n =~ /(\r\n)/i ){ push @s,"Name contains invisible line ending"; } else { 
if( $n =~ /([^a-z0-9\-\~,\' _;\+\(\)\[\]\&\/\.])/i ){ push @s,"Name contains illegal character: [$1]"; }#'
} 
if( $n =~ /\.(.*?)$/ ){ my $ex = $1;if( $ex !~ /($c{'fxfile'})$/i ){ push @s,"File Extension is [.$ex]"; } else { if( !-f $fu ){push @s,"File named $n does not exist ";} } }
if( scalar @s > 0 ){$o = join ", ",@s;} 
return $o;
}

sub sub_admin_updatemenus{
my ($u,$n,$subn,$dref,$sref,$upm,$upmenus,$cref) = @_;
my %data = %{$dref};
my %swap = %{$sref};
my %c = %{$cref};
my $dbug = "";
my $newm = undef;
my $news = undef;
my $merr = undef;
my $mmsg = undef;
my $mtxt = '';
my $err = undef;
###sub_json_out({ 'check admin_updatemenus' => "u:$u \nn:$n \nsubn:$subn \nupm:$upm \nupmenus:$upmenus \n\n".Data::Dumper->Dump([\%data],["data"])."\n\nsitemap:$c{'base'}$c{'site_file'} \n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
if( defined $upmenus ){
my ($serr,$stxt) = sub_get_contents($c{'base'}.$c{'site_file'},$cref,"text");return ("error: $serr \n Site-Map.html \n $stxt",$n) if defined $serr;
my %mref = %{ sub_parse_menutext($stxt,$cref) };
if( defined $mref{'menutext'}[0] ){ $newm = $mref{'menutext'}[0]; }
if( defined $mref{'sitemaptext'}[0] ){ $news = $mref{'sitemaptext'}[0]; }
}
###sub_json_out({ 'check admin_updatemenus 1' => "u:$u \nn:$n \n\n[ $c{'base'}.$n,$subn ] upm = $upm \n\n".Data::Dumper->Dump([\%data],["data"])."\n\n newm:$newm \n\nnews:$news \n upmenus:$upmenus \n $c{'debug'}" },$c{'origin'},$c{'callback'});
if( !defined $data{'new-updateall'} ){
($merr,$mmsg,$mtxt) = sub_page_update($c{'base'}.$n,$subn,\%data,$newm,$news,$upm,$cref);
$err = $merr if defined $merr;
} else {
delete $data{'new-updateall'};
}
###sub_json_out({ 'check admin_updatemenus 2' => "u:$u \nn:$n \n \nsubn:$subn \nupmenus:$upmenus \nupm:$upm \nmmsg:$mmsg \nerr:$err \n\n".Data::Dumper->Dump([\%data],["data"])."\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
if( defined $upmenus ){ 
$c{'sitepage'} = $c{'site_file'};
$c{'format'} = "updatemenu";
my ($prerr,$prref) = sub_page_return("menureorder",[$c{'base'}],\%c);
sub_json_out({ 'check admin_updatemenus 3' => "prerr: $prerr \n\n".Data::Dumper->Dump([$prref],["prref"])."\n\n $c{'debug'}" },$c{'base'}) if defined $prerr;
my @all = @{$prref};
for my $i(0..$#all){ 
if( defined $swap{'new-link'} && $all[$i]{'data'}{'url'}[0] eq $u ){ $all[$i]{'data'}{'link'}[0] = $swap{'new-link'}; }
$dbug.= "$i: url:".$all[$i]{'data'}{'url'}[0]." link:".$all[$i]{'data'}{'link'}[0]." menuname:".$all[$i]{'data'}{'menuname'}[0].( (defined $all[$i]{'data'}{'issues'})?"\npages:".$all[$i]{'data'}{'pages'}[0]." \nissues:".(join " ",@{$all[$i]{'data'}{'issues'}}):"" )."\n"; 
}
###sub_json_out({'check admin_updatemenus 4' => "u:$u \n\n$dbug \n\n".Data::Dumper->Dump([\@all],["all"])."\n\n $c{'debug'} " },$c{'base'});
($merr,$mmsg) = sub_return_menus("menureorder",$u,\@all,$cref,undef,undef,"dofork");
if( defined $merr ){ $err.= $merr; } else { $dbug.= $mmsg; }
###sub_json_out({ 'check admin_updatemenus 7' => "u:$u \nn:$n n\n".Data::Dumper->Dump([\%swap],["swap"])."\n\n".Data::Dumper->Dump([\%data],["data"])."\n\n mmsg: $mmsg \nerr:$err \n\n $dbug \n $c{'debug'}" },$c{'base'});
} else { 
return ($err,$n); 
}
}

sub sub_array_undupe{ my @in = @_;my %filter = ();my @u = grep { ! $filter{ $_ }++ } @in;return @u; }

sub sub_check_name{ my ($n,$cref) = @_;my %c = %{$cref};my $s = "";my $p = "";my $x = "";$n =~ s/^\s*//;$n =~ s/\s*$//;if( $n =~ /(.+)(\.)($c{'fxfile'})$/i ){ $s = $1;$p = $2;$x = $3;$s =~ s/\.$//;} else {$s = $n;}$s =~ s/ /\-/g;$s =~ s/[^a-z0-9\-\~\^#_\.,;\/\(\)\[\]\&]//gi;return $s.$p.$x; }

sub sub_clean_name{ my ($s,$htm) = @_;return unescape($s); }

sub sub_clean_printable{ my ($s) = @_;if( $s =~ /^\#\!\/usr\/bin\/perl/ ){ $s =~ s/[[:^print:]]+//g; } else { $s =~ s/[[:^print:]]+/ /g; }return $s; }

sub sub_clean_utf8{ 
my ($s,$uref,$uref1,$despace,$keep) = @_;
my @UTF = @{ $uref };
for my $i(0..$#UTF){ $s =~ s/($UTF[$i][0])|($UTF[$i][1])/$UTF[$i][2]/gmsi; }
my @UTF1 = @{ $uref1 };for my $i(0..$#UTF1){ if( $UTF1[$i][0] eq "\&amp;" && defined $keep ){ $s =~ s/((href="|\G)[^"]*?&)amp;/$1/gmsi; }$s =~ s/$UTF1[$i][0]/$UTF1[$i][1]/gmsi; }
#$s =~ s/[^\x00-\x7f]/ /g; #$s =~ s/[^[:ascii:]]+//g;
if(defined $despace){ $s =~ s/^(\t*)( )+(\t*)</$1$3</gm;$s =~ s/>(\t)+$/>/gm;$s =~ s/(\t)+\n$/\n/gm;$s =~ s/(\n){2,}/\n\n/gm; }
$s =~ s/[^[:print:]\t\n\ ]+//g;
return $s; 
}

sub sub_default_sort{
my ($sr,$aref) = @_; 
my @tmp = @{$aref};
return sort { 
($sr eq "unrank")?$b->{'data'}{'menu'}[0] <=> $a->{'data'}{'menu'}[0] || $a->{'data'}{'url'}[0] cmp $b->{'data'}{'url'}[0] || $b->{'data'}{'epoch'}[0] <=> $a->{'data'}{'epoch'}[0] || lc $a->{'data'}{'title'}[0] cmp lc $b->{'data'}{'title'}[0]:
($sr eq "rank")?$a->{'data'}{'menu'}[0] <=> $b->{'data'}{'menu'}[0] || $a->{'data'}{'url'}[0] cmp $b->{'data'}{'url'}[0] || $b->{'data'}{'epoch'}[0] <=> $a->{'data'}{'epoch'}[0] || lc $a->{'data'}{'title'}[0] cmp lc $b->{'data'}{'title'}[0]:
($sr eq "21")?$b->{'data'}{'epoch'}[0] <=> $a->{'data'}{'epoch'}[0] || lc $a->{'data'}{'title'}[0] cmp lc $b->{'data'}{'title'}[0]:
($sr eq "12")?$a->{'data'}{'epoch'}[0] <=> $b->{'data'}{'epoch'}[0] || lc $a->{'data'}{'title'}[0] cmp lc $b->{'data'}{'title'}[0]:
($sr eq "az")?lc $a->{'data'}{'data'}{'title'}[0] cmp lc $b->{'data'}{'title'}[0]:
lc $b->{'data'}{'title'}[0] cmp lc $a->{'data'}{'title'}[0] 
} @tmp;
}

sub sub_epoch_date{ my ($in) = @_;my ($d,$m,$y) = split /\//,$in;if($y < 2000){$y = 2000+$y;}if($d > 0 && $d < 32 && $m > 0 && $m < 13 && $y > 1899){ return timelocal(0,0,0,$d,$m-1,$y); } else { return 0; } }

sub sub_file_create{
my ($nf,$ou) = @_;
my $dbug = "";
my $err = undef;
my $herr = sub_page_print($nf,$ou);
if( defined $herr ){ 
$err = "create file $nf failed: $herr"; 
} else { 
if(-f $nf ){ chmod (0664,$nf) or try { die "filecreate: chmod $nf failed: $!"; } catch { $dbug.= "filecreate: chmod $nf failed: $_"; }; } else { $dbug.= "$nf is not a file $!"; } ###chown (-1,getgrnam($perms{'group'}),$nf) or $err = "chown $nf failed: $!";
}
return $err;
}

sub sub_file_findreplace{
#%h =  {
# 'documents/Images/news/CIOReviewlogo_header.jpg' => {
# 'parent' => ['documents/Images/news'],
# 'epoch' => [1495545603],
# 'path' => ['documents','Images','news','CIOReviewlogo_header.jpg'],
# 'menuname' => ['CIOReviewlogo_header.jpg'],
# 'size' => ['26k'],
# 'versions' => [],
# 'published' => ['23/05/2017'],
# 'href' => ['documents/Images/news/CIOReviewlogo_header.jpg'],
# 'url' => ['documents/Images/news/CIOReviewlogo_header.jpg'],
# 'author' => [ 'Dave Pilbeam' ],
# 'focus' => []
# },
my ($href,$lsref,$foundref,$cref,$findref,$repref,$regex,$case,$where,$code) = @_;
my %h = %{$href};
my @ls = @{$lsref};push @ls,'author'; # ['blocks','pages','archive','area','date','focus','group','tags','text'];
my @terms= @{$findref};
my %c = %{$cref};
my $u = (defined $h{'url'}[0])?$h{'url'}[0]:undef;
my $dbug = "";
###sub_json_out({ 'check file_findreplace in' => "u: $u \n\n ".Data::Dumper->Dump([\%h],["h"])."\n\n \n\n".Data::Dumper->Dump([\@ls],["ls"])."\n\nregex:$regex \ncase:$case \ncode:$code \nwhere:$where\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
if(defined $u){
foreach my $ls( @ls ){
if( defined $h{$ls} ){
my @hb = @{ $h{$ls} };
if( scalar @hb > 0){
for my $i(0..$#hb){  
my $c = 1+$i;
my %sr = sub_search_string($hb[$i],$findref,$repref,$regex,$case,$ls,$cref,$where);
# $sr = {
# 'matches' => { '5' => '<div class="text" style="background-image: url(documents/Images/news/RSM__header_mobile.jpg);">&#160;</div> ' },
# 'result' => '<strong>Found <u>1</u> instance of <i>documents/Images/news/</i> in <u>editable text</u>: </strong><emp>- line 5: <i>&lt;div class=&quot;text&quot; style=&quot;background-image: url(<u>documents/Images/news/</u>RSM__header_mobile.jpg);&quot;&gt;&amp;#160;&lt;/div&gt; </i></emp>',
# 'old' => '<div class="row editblock"><div class="editimage"><div class="text" style="background-image: url(documents/Images/news/RSM__header_mobile.jpg);">&#160;</div></div></div>',
# 'new' => '<div class="row editblock"><div class="editimage"> <div class="text" style="background-image: url(RSM__header_mobile.jpg);">&#160;</div> </div></div>',
# 'totals' => [ 1,1 ]
# };
$dbug.= "checking $ls: $hb[$i] == ".Data::Dumper->Dump([\%sr],["sr"])."\n";
my $pass = undef;
my $tot = 0;
if( defined $sr{'totals'} ){ my %tts = %{ $sr{'totals'} };foreach my $c( keys %tts ){ if( $tts{$c} > 0 ){ $tot = $tot+$tts{$c};$pass = "ok"; } } }
if( defined $pass ){
if( !defined $foundref->{$u}{'matches'} ){ @{ $foundref->{$u}{'matches'} } = (); }if( defined $sr{'matches'} ){ push @{ $foundref->{$u}{'matches'} },values %{$sr{'matches'}}; }
if( !defined $foundref->{$u}{'result'} ){ @{ $foundref->{$u}{'result'} } = (); }if( defined $sr{'result'} ){ if(defined $c{'user'}){$sr{'result'} =~ s/(<emp>\-) (line [0-9]+)/$1block $c: $2/g;}push @{ $foundref->{$u}{'result'} },$sr{'result'}; }
if( !defined $foundref->{$u}{'old'} ){ @{ $foundref->{$u}{'old'} } = (); }if( defined $sr{'old'} ){ push @{ $foundref->{$u}{'old'} },$sr{'old'}; }
if( !defined $foundref->{$u}{'new'} ){ @{ $foundref->{$u}{'new'} } = (); }if( defined $sr{'new'} ){ push @{ $foundref->{$u}{'new'} },$sr{'new'}; }
if( !defined $foundref->{$u}{'total'} ){ $foundref->{$u}{'total'} = $tot; } else { $foundref->{$u}{'total'} = $foundref->{$u}{'total'}+$tot; } 
}
}
}
}
}
}
###if($h{'url'}[0] =~ /zDetect.pdf/){ 
###sub_json_out({ 'check file_findreplace out' => "u: $u \ndbug: $dbug \n\n".Data::Dumper->Dump([\%h],["h"])."\n\n".Data::Dumper->Dump([\@ls],["ls"])."\n\n".Data::Dumper->Dump([$foundref],["foundref"])."\n\nregex:$regex \ncase:$case \n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
###}
}

sub sub_files_return{
my ($in,$u,$cref,$all,$miss) = @_;
my %c = %{ $cref };
my $su = $u;$su =~ s/^($c{'base'})//;
my $depth = scalar split /\//,$su;
my %libfilelist = ();
my %taglist = ();
my %out = ( 'folders' => {},'files' => {} );
my $err = undef;
my @list = sub_get_files($u,undef,$cref,"trim",undef,undef,1);
my @dirs = sub_get_folders($u,$c{'bandir'});
my @tags = ($in ne "viewfiles")?sub_get_tags($u,undef,$cref,"trim"):();
for my $i(0..$#tags){
my ($ierr,$otxt) = sub_get_contents($c{'base'}.$tags[$i],$cref); ###'file'
$c{'debug'} = "alert: $ierr = $tags[$i] \notxt:$otxt \n\n$c{'debug'} \n" if defined $ierr; ###$c{'debug'}.= "alert: $i = $tags[$i] = \notxt:$otxt \n";
$tags[$i] =~ s/($c{'liblister'}|$c{'chapterlister'})$//;
%{ $libfilelist{$tags[$i]} } = sub_parse_tags($otxt,$tags[$i],$cref); # $taglist = { 'documents/Digital/Datasheets/Security-Software'' => { 'documents/Digital/Datasheets/Security-Software/zDetect.pdf' => { epochcreated => [1479081600],area => [],author => ['Andrew Downie'],focus => [],tags => [],image => ['zDetect_thumb.jpg'],created => ['14/11/2016'],archive => [],group => [],text => [],url => ['zDetect.pdf'],title => ['zDetect'] } } }
}
foreach my $k(sort keys %libfilelist){
foreach my $j( sort keys %{ $libfilelist{$k} } ){ $taglist{$j} = $libfilelist{$k}{$j}; }
}
###sub_json_out({'check files_return' => "in: $in \nu:$u \n dirs: [ @dirs ] \n list: [ @list ] \n tags: [ @tags ] \n\n".Data::Dumper->Dump([\%taglist],["taglist"])."\n\nfxfile: $c{'fxfile'} \nbanfile: $c{'banfile'} \n\n$c{'debug'} " },$c{'origin'},$c{'callback'});

for my $i( 0..$#list){ # $list[$i] = documents/PDF/data-sheets/zRSM-GUI-Data-Sheet.pdf  | documents/PDF/data-sheets/
if( !defined $miss || $list[$i] !~ /\.($miss)$/i ){
my $nref = \%out;
my %t = %{ sub_get_filepath($list[$i],$cref) }; # %t = { 'length' => 4,'item' => undef,'file' => 'zDetect.pdf','path' => ['documents','Digital','Datasheets','Security-Software'],'parent' => 'documents/PDF/data-sheets', };
my $tagpar = $list[$i];$tagpar =~ s/^(.+\/).*?$/$1/;
###$c{'debug'}.= "tagpar = $tagpar \n"; 
my $taginfo = ( defined $taglist{$list[$i]} )?$taglist{$list[$i]}:{};
if( $list[$i] !~ /_thumb\.(jpg|png|gif)$/i && !defined $taginfo->{'image'} ){
my $tf = $list[$i];$tf =~ s/\.(.*?)$/_thumb.jpg/;if( -f $c{'base'}.$tf ){ $taginfo->{'image'} = [ $tf ]; }
}
###if( $list[$i] =~ /RSM-Partners-Logo-Tagline.eps$/ ){ 
###sub_json_out({'check files_return 1' => "in:$in \nu:$u \nall:$all \ndepth:$depth \nlist:$list[$i] \ \ntaglist{tagpar}{list} = $taglist{$tagpar}{$list[$i]} \n\nt =  ".Data::Dumper->Dump([\%t],["t"])." = ".Data::Dumper->Dump([$taginfo],["taginfo"])." = ".Data::Dumper->Dump([\%taglist],["taglist"])." \n\n$c{'debug'} " },$c{'origin'},$c{'callback'}); 
###}
#
if( defined $t{'file'} && ( defined $all || $t{'length'} == $depth) ){ 
if( scalar keys %{$taginfo} > 0 ){ @{ $taginfo->{'url'} }[0] = $list[$i];if( defined @{ $taginfo->{'image'} }[0] && @{ $taginfo->{'image'} }[0] !~ /^ht[tps]:/ && $tagpar ne @{ $taginfo->{'image'} }[0] ){ @{ $taginfo->{'image'} }[0] = @{ $taginfo->{'image'} }[0]; } }
###if( $list[$i] =~ /RSM-Partners-Logo-Tagline.eps$/ ){ 
###sub_json_out({'check files_return 2' => "in:$in \nu:$u \nlist:$list[$i] \ntaglist{list} = $taglist{$list[$i]} \n\n ".Data::Dumper->Dump([$taginfo],["taginfo"])." \n\n$c{'debug'} " },$c{'origin'},$c{'callback'}); 
###}
$nref->{'files'}->{ $list[$i] } = sub_get_info($c{'base'}.$list[$i],$cref,$taginfo,"trim sub"); 
} 
$nref = $nref->{'folders'};
if( defined $t{'folder'} && (defined $all || $t{'length'} == $depth) ){ $nref->{ $t{'folder'} } = {}; }
for my $ii( $depth..$#{ $t{'path'} } ){ if( !defined $nref->{ $t{'path'}[$ii] } ){ $nref->{ $t{'path'}[$ii] } = {}; }$nref = $nref->{ $t{'path'}[$ii] }; }
###if( $list[$i] =~ /RSM-Partners-Logo-Tagline.eps$/ ){ 
###sub_json_out({'check files_return 3' => "in:$in \nu:$u \nall:$all \ndepth:$depth \nlist:$list[$i] taglist = ".Data::Dumper->Dump([$taginfo],["taginfo"])." \n\n\n\n ".Data::Dumper->Dump([ $nref->{'files'}->{ $list[$i] } ],["nref"])." \n\n$c{'debug'} " },$c{'origin'},$c{'callback'});
###}
}
}

for my $i( 0..$#dirs){
my $ds = $dirs[$i];$ds =~ s/^.+\///;
if( $dirs[$i]."/" ne $u && -d $u.$ds && !defined $out{'folders'}{$ds} ){ 
%{ $out{'folders'}{$ds} } = (); 
###sub_json_out({'check files_return 3' => "in: $in \nu:$u \n ds: $ds ] \n\n$c{'debug'} " },$c{'origin'},$c{'callback'});
}
}

# 'folders' => { 'Ben\'s-Stuff' => {} },
# 'files' => { 
# 'Test-Document2.txt' => { 'parent' => [ 'documents/Digital' ], 'epoch' => [ 1481739415 ], 'menuname' => [ 'Test-Document2.txt' ], 'path' => [ 'documents', 'Digital', 'Test-Document2.txt' ], 'size' => [ '12k' ], 'published' => [ '14/12/2016' ], 'href' => [ 'documents/Digital/Test-Document2.txt' ], 'url' => [ 'documents/Digital/Test-Document2.txt' ] }, 
# 'test-document2.pdf' => { 'parent' => [ 'documents/Digital' ], 'epoch' => [ 1481739432 ], 'menuname' => [ 'test-document2.pdf' ], 'path' => ['documents','Digital','test-document2.pdf' ], 'size' => [ '1641k' ], 'published' => [ '14/12/2016' ], 'href' => [ 'documents/Digital/test-document2.pdf' ], 'url' => [ 'test-document2.pdf' ], 'area' => [ 'UK-Europe2' ], 'author' => [ 'Ben Chap2' ], 'focus' => [ 'Financial2', 'Maverick2' ], 'text' => ['A document that is meant to be a test2.','Another line of text2.' ], 'created' => [ '13/12/2016' ], 'epochcreated' => [ 1481587200 ], 'tags' => [ 'England2','Scotland2' ], 'image' => [ 'Test-Image2.gif' ], 'title' => [ 'Ben\'s Test Document2' ] } 
# } 
###sub_json_out({'check files_return 4' => "in:$in \nu:$u \nall:$all \ndepth:$depth \n\ntaglist = ".Data::Dumper->Dump([\%taglist],["taglist"])." \n\n out = ".Data::Dumper->Dump([\%out],["out"])." \n\n$c{'debug'} " },$c{'origin'},$c{'callback'});
return ($err,\%out);
}

sub sub_folder_copy{
my ($ex,$nw,$cref) = @_;
my $err = undef;
if( -d $nw ){ rmtree("$nw");$err = sub_folder_create($nw,$cref);return ("error creating folder [ $nw]: $err \n") if defined $err; }
local $File::Copy::Recursive::Dirperms = 0775;
dircopy($ex,$nw) or $err = $!;
return ( defined $err )?"error: create folder $nw failed: $err ":undef;
}

sub sub_folder_create{
my ($nf,$cref,$auxref) = @_;
my %c = %{$cref};
my @aux = (defined $auxref)?@{$auxref}:();
my $dbug = "";
my $err = undef;
mkpath("$nf",{mode => 0775,result => \my $list,error => \my $ierr});if(@$ierr){ $err = "";for my $diag (@$ierr){my ($fi,$ms) = %$diag;if($fi eq ''){ $err.= "general error: $ms\n"; } else { $err.= "error creating [ $fi ]: $ms\n"; }} } ###owner=>$c{'perms'}{'user'},group=>$c{'perms'}{'group'},
if( defined $err ){
return "error: create folder $nf failed: $err \n";
} else {
chmod (0775,$nf) or try { die "folder_create: chmod $nf failed: $! "; } catch { $dbug.= "folder_create: chmod $nf failed: $_ \n";return $dbug; };
if( defined $auxref ){ $dbug.= sub_search_aux($c{'base'},$nf,\@aux,[ 'LIB/','FONTS/' ],[ '../../../LIB/','../../../FONTS/' ],$cref); } 
return undef;
}
}

sub sub_folder_empty{
my ($dir,$stat) = @_; #604800 = 1 week 
my @err = ();
opendir my ($dh),$dir;
while (readdir $dh) {
my $fn = catfile($dir,$_);
my $ok = 1;
if( defined $stat){ my $mdate = stat($fn);my $md = $mdate->mtime;my $age = time() - $md;if( $age < $stat ){ $ok = undef; } }
if( -f $fn && defined $ok ){ unlink $fn or push @err,"error: unable to delete $fn: $! "; }
}
return (scalar @err < 1)?'<span class="restoreresult">'.$dir.' emptied successfully</span>':( '<span class="restoreresult error">'.join '</span><span class="restoreresult error">',@err ).'</span>';
}

sub sub_ftp_connect{
my ($sftp,$ip,$dir,$user,$pass,$recur) = @_;
my $ssherr = undef;
my $ftp = undef;
my $dbug.= "ftp: $sftp,$ip,$dir,$user,$pass,$recur\n";
my $msg = "";
my $err = undef; 
if( defined $sftp ){
$Net::SFTP::Foreign::debug = -1; ###$ssherr = File::Temp->new or $err = "backup connect: new File Temp failed $!";
$ftp = Net::SFTP::Foreign->new( $ip,user => $user,password => $pass ); ###,timeout => 60,more => ['-vvv'],stderr_fh => $ssherr
if($ftp->error){
$err.= "ftp_connect: failed to connect to server '$ip' ".$ftp->error." ".$ftp->status; ###seek($ssherr,0,0);while(<$ssherr>){ $err.= "captured stderr: $_  "; }
} else {
$msg.= "ftp_connect: connected to server '$ip'<br />";
my $fh = $ftp->cwd;if($dir ne "" && $dir ne $fh){ $ftp->setcwd($dir);$fh = $ftp->cwd; } #my $ls = $ftp->ls($fh);if($ftp->error){ $err.= "error: cannot list directory $fh: ".$ftp->error."".$ftp->status; } else { $err.= "$_->{filename} " for (@$ls); }
}
} else {
$ftp = Net::FTP->new($ip,Debug => 3); #$ftp = (defined $recur)?Net::FTP::Recursive->new($ip,Debug => 3):Net::FTP->new($ip,Debug => 3); #,Passive => 1
$err = "ftp_connect: failed to connect to server '$ip': $@ " unless defined $ftp;
if( !defined $err){
#$dbug.= "$type = $ftp ";
$err = "error: failed to login as $user: ".$ftp->message." $! " unless $ftp->login($user,$pass);
if( !defined $err ){ $err = "error: failed to set binary mode: ".$ftp->message." $! " unless $ftp->binary(); }
if( !defined $err && $dir ne "" && $dir ne $ftp->pwd){ $err = "error: cannot change directory to $dir: ".$ftp->message." $! " unless $ftp->cwd($dir); }
}
}
return ($ftp,$err,$msg);
}

sub sub_ftp_drill{
my ($ftp,$dir,$fs,$sref,$oldurl,$err,$msg,$cref,$lastdir,$purge) = @_;
my %c = %{$cref};
my $rdir = $lastdir;
my $outdir = $lastdir || $dir;
my $dbug = "";
if(-d $fs){ 
my @ds =  sub_get_html($fs,$cref,undef,$c{'auxfiles'},undef,"noban");
###if($fs =~ /\/documents\/$/){
###sub_json_out({ 'debug' => "check ftp_drill: dir:$dir lastdir:$lastdir \n$fs = [ @ds ] \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
###}
for my $j(0..$#ds){ ($err,$msg,$outdir) = sub_ftp_drill($ftp,$dir,$ds[$j],$sref,$oldurl,$err,$msg,$cref,$lastdir,$purge); }
} else {
if(-f $fs){ 
$rdir = $fs;$rdir =~ s/^($c{'base'})/$dir/;$rdir =~ s/^(.+)\/.*?$/$1/;$rdir =~ s/\/.*?\.($c{'fxfiles'}|JS)$/\//i;
my $cdir = $ftp->pwd;
$dbug.= "rdir:$rdir = outdir:$outdir = cdir:$cdir <br />";
if( $cdir ne $rdir ){
$dbug.= "change from $cdir to $rdir and ".( (defined $purge && $cdir ne $dir)?"":"don't" )." purge $cdir<br />";
#if( defined $purge && $cdir ne $dir ){ ($dbug) = sub_ftp_purge($ftp,(1*60*60),$dbug); }
my @path = split /\//,$rdir; #/admin
my $pdir = "";
if( $#path > 1 ){
for my $i(0..$#path){
$pdir.= $path[$i]."/";my $ok = undef;my $mk = undef;$ftp->cwd($pdir) or $ok = 1;if(defined $ok){ $ftp->mkdir($pdir) or $mk = 1;if(defined $mk){$err.= "error creating $pdir: ".$ftp->message." <br />";} else {$ftp->cwd($pdir);$dbug.= "created $pdir: ".$ftp->message."<br />";} }
}
$outdir = $pdir;
} else {
$outdir = $rdir;$ftp->cwd($outdir);
}
} else {
$outdir = $rdir;$dbug.= "already in $rdir<br />";
}
$dbug.= "put $fs into $outdir <br />";($err,$msg) = sub_ftp_file($ftp,$dir,$fs,$sref,$oldurl,$err,$msg,$cref); 
}
}
$msg.= $dbug;
#
$msg.= "outdir is $outdir<br />";
return ($err,$msg,$outdir);
}

sub sub_ftp_file{
my ($ftp,$dir,$fs,$sref,$oldurl,$err,$msg,$cref) = @_;
my %c = %{$cref};
my %s = %{$sref};
my %sn = ();foreach my $k( sort keys %s ){ $sn{$k} = @{$s{$k}}[0]; }
my $ts = "@{$c{'titlesep'}}";
my $putfile = $fs;
$putfile =~ s/^($c{'base'})/$dir/;
my $on = ( $fs =~ /^($c{'base'}$c{'adminbase'})/ )?undef:1;
if( defined $on && $fs =~ /\.($c{'htmlext'})$/ ){
my ($nferr,$otxt) = sub_admin_new('page',$fs,undef,\%sn,$cref,'nomenus'); ####$dbug.= "open $ds[$i] = $otxt $nferr\n";
###$msg.= "[put string > html] add $fs $nferr\n";
my ($perr,$pmsg) = sub_ftp_put($ftp,$otxt,$putfile);if( defined $perr ){ $err = (defined $err)?$err.$perr:$perr; }$msg.= $pmsg;
} elsif( defined $on && $fs =~ /\.(htaccess|js|pm)$/i ){
my ($ierr,$otxt) = sub_get_contents($fs,$cref);$msg.= "warning: $ierr\n" if defined $ierr;
###if( $fs =~ /defs\.pm$/){
###sub_json_out({ 'debug' => "check ftp_transfer: $fs \n\n $otxt \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
###}
my %sr = sub_search_string($otxt,[ $oldurl,$ts,$c{'otitle'} ],[ $sn{'new-baseurl'},@{$c{'titlesep'}}[0]." ".$sn{'new-baseid'},$sn{'new-baseid'} ],undef,undef,"code",$cref);
###$msg.= "[put string > auxstring] add $fs (matches:".( scalar keys %{$sr{'matches'}} || 0 ).") $ierr\n";
###$msg.= "\n\n".Data::Dumper->Dump([\%sr],["sr"])."\n\n";
if( scalar keys %{$sr{'matches'}} > 0 ){ $otxt = $sr{'new'}; }
my ($ferr,$fmsg) = sub_ftp_put($ftp,$otxt,$putfile);if(defined $ferr){ $err = (defined $err)?$err.$ferr:$ferr; }$msg.= $fmsg;
} elsif( defined $on ){
###$msg.= "[put file > auxfile] add $fs: ";
my $perr = "transfer $putfile: <b>ok</b> <br />";
if( defined $ftp->size($putfile) ){ $ftp->delete($putfile) or try { die "delete existing $putfile failed: <b>".$ftp->message."</b>"; } catch { $msg.= "$_<br />" }; }
$ftp->put($fs,"$putfile") or try { die "$fs -> $putfile failed: <b>".$ftp->message."</b>"; } catch { $perr = "transfer $_ <br />";$err = (defined $err)?$err.$perr:$perr; };$msg.= $perr;
} else {
###$msg.= "[put admin file > auxfile] add $fs: ";
my $perr = "transfer admin $putfile: <b>ok</b> <br />";
my $ok = undef;my $mk = undef;$ftp->cwd($dir.$c{'adminbase'}) or $mk = 1;if(defined $mk){ $ftp->mkdir($dir.$c{'adminbase'}) or $ok = 1; } else { if( defined $ftp->size($putfile) ){ $ftp->delete($putfile) or try { die "delete existing $putfile failed: <b>".$ftp->message."</b>"; } catch { $msg.= "$_<br />" }; } }
if(defined $ok){$err.= "error creating $dir$c{'adminbase'}: ".$ftp->message." <br />";} else {$ftp->cwd($dir.$c{'adminbase'});$perr.= "created $dir$c{'adminbase'}: ".$ftp->message."<br />";}
$ftp->put($fs,"$putfile") or try { die "$fs -> $putfile into $dir$c{'adminbase'} failed: <b>".$ftp->message."</b>"; } catch { $perr = "transfer $_ <br />";$err = (defined $err)?$err.$perr:$perr; };$msg.= $perr;
}
return ($err,$msg);
}

sub sub_ftp_out{
# %s = {
# pecreative.co.uk => {
# new-copyright => ['Copyright (c) etc 2018'],
# new-author => ['PE etc'],
# new-description => ['etc'],
# new-baseurl => ['pecreative.co.uk'],
# new-analytics_gref => ['UA-000000-1'],
# new-analytics_wref => ['000000'],
# new-baseid => ['PE Etc'],
# new-keywords => ['etc, etc'],
# ftp-ip => ['141.0.165.133'],
# ftp-dir => ['/'],
# ftp-user => ['peetcftp'],
# ftp-password => ['wetcvg']
# }
# }
# %d = { 'addpagesite' => [ '/var/www/vhosts/pecreative.co.uk/revive.pecreative.co.uk/Paper-and-Sustainability-Facts.html','/var/www/vhosts/pecreative.co.uk/revive.pecreative.co.uk/Site-Map.html' ],'addadminsite' => ['/var/www/vhosts/pecreative.co.uk/revive.pecreative.co.uk/admin/'] }
my ($sref,$dref,$oldurl,$cref,$purge) = @_;
my %s = %{$sref};
my %d = %{$dref};
my %c = %{$cref};
my $msg = "";
eval "use Net::FTP";
if($@){ return "unable to use Net::FTP"; } else { eval "use Net::FTP::File";if($@){ return "unable to use Net::FTP::File"; } else {
#eval "use Net::FTP::Recursive";
#if($@){ return "unable to use Net::FTP::Recursive" } else {
foreach my $site( sort keys %s){
$msg.= "Site $site:<br />";
my ($ferr,$fmsg) = sub_ftp_transfer($site,@{$s{$site}{'ftp-ip'}}[0],@{$s{$site}{'ftp-dir'}}[0],@{$s{$site}{'ftp-user'}}[0],@{$s{$site}{'ftp-password'}}[0],$s{$site},$dref,$oldurl,$cref,$purge);
$msg.= (defined $ferr)?$ferr:$fmsg."<br />";
}
#}
} }
return $msg;
}

sub sub_ftp_purge{
my ($ftp,$time,$dbug) = @_;
my @rfiles = $ftp->dir() or $dbug.= "error listing ".$ftp->pwd.": ".$ftp->message." <br />"; 
#$dbug.= "purge ".$ftp->pwd.": [ @rfiles ]<br />";
foreach my $rfile( parse_dir(\@rfiles) ){
my($fname,$ftype,$fsize,$fmtime,$fmode) = @{$rfile};
#$dbug.= " $fname, $ftype, $fsize, $fmtime, $fmode <br />";
next if $ftype ne 'f';
next if ($^T - $fmtime) < $time;
$dbug.= "delete file $fname";
$ftp->delete($fname) or $dbug.= " failed: ".$ftp->message;
$dbug.=" <br />"; 
}
return $dbug;
}

sub sub_ftp_put{
my ($ftp,$otxt,$putfile) = @_;
my $msg = "";
my $err = undef;
my $hfile = gensym;
open($hfile, "<", \$otxt) or try { die "ftp_transfer: open file $putfile failed: $!"; } catch { $err = "ftp_transfer: open file $putfile failed: $_ <br />";$msg.= $err; };
if( defined $hfile && !defined $err ){ my $perr = "transfer $putfile: ok";$ftp->put($hfile,"$putfile") or try { die "transfer $putfile failed: ".$ftp->message; } catch { $err = "transfer $putfile failed: $_ <br />";$perr = ""; };$msg.= $perr."<br />"; }
return ($err,$msg);
}

sub sub_ftp_transfer{
my ($site,$ip,$dir,$user,$pass,$sref,$dref,$oldurl,$cref,$purge) = @_;
my %s = %{$sref};
my %d = %{$dref};
my %c = %{$cref};
my $lastdir = $dir;
my $msg = "";
my $dbug = "";
my $sftp = undef;
my $err = undef;
###sub_json_out({ 'check ftp_transfer' => "site:$site \nip:$ip \ndir:$dir \nuser:$user \npass:$pass \n\n".Data::Dumper->Dump([$sref],["sref"])."\n\n".Data::Dumper->Dump([$dref],["dref"])."\n\noldurl:$oldurl \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
my ($ftp,$cerr,$msg) = sub_ftp_connect($sftp,$ip,$dir,$user,$pass); #,"recursive"
return ("error: there was an error connecting to $site ($ip,$dir,$user,$pass): $cerr / $msg") unless defined $ftp && !defined $cerr;
if( defined $ftp ){  
foreach my $files( sort keys %d){
my @fs = @{ $d{$files} };
for my $i(0..$#fs){ ($err,$msg,$lastdir) = sub_ftp_drill($ftp,$dir,$fs[$i],$sref,$oldurl,$err,$msg,$cref,$lastdir,$purge); }
if( defined $purge ){ ($dbug) = sub_ftp_purge($ftp,(1*60*60),$dbug);$dbug.= "purge ".$ftp->pwd."<br />"; }
}
}
$ftp->quit;
#
$msg.= $dbug;
return ($err,$msg);
}

sub sub_get_aliases{ 
my ($f,$cref) = @_;
my %c = %{$cref};
my @als = ();
my $u = $f;$u =~ s/\.($c{'htmlext'})$//;$u = '^'.quotemeta($u).$c{'qqdelim'};
my $msg = "";
my ($perr,$pref) = sub_page_return("pagelist",[$c{'base'}],$cref);
if( defined $perr ){ $msg.= $perr; } else {
###sub_json_out({ 'check get_aliases' => "f:$f \n\n".Data::Dumper->Dump([$pref],["pref"])."\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
my @tmp = @{ $pref };
for my $i(0..$#tmp){ 
my $pg = $tmp[$i]{'data'}{'url'}[0];
my $lnk = $tmp[$i]{'data'}{'link'}[0];
#$msg.= "searching $pg for $u.. [ $lnk ] \n";
if( $lnk =~ $u && $pg !~ $u ){ push @als,$pg;$msg.= "$lnk ne $pg MATCH\n"; }
}
}
#my ($ferr,$otxt) = sub_get_contents($c{'base'}.$c{'site_file'},$cref,"text");return (\@als,"error: $ferr \n Site-Map.html $! \n") if defined $ferr;my %mref = %{ sub_parse_menutext($otxt,$cref) };if( defined $mref{'sitemaptext'}[0] ){while( $mref{'sitemaptext'}[0] =~ /href="(.*?\.$c{'htmlext'})"/gim ){my $r = $1;$msg.= "$r ";my $qm = '^'.quotemeta($u).$c{'qqdelim'}.'.+)*(\.$c{'htmlext'})$''if( $r =~ $qm ){push @als,$r;$msg.= "= MATCH";}$msg.= "\n";}}
return (\@als,$msg); 
}

sub sub_get_all{ 
my ($u,$in,$cref,$faux) = @_;my %c = %{$cref};my %all = ();my @pagedirs = ( $c{'base'} );if(defined $faux && scalar @$faux > 0){push @pagedirs,@$faux;}my @m = ();my $du = $u;my $dall = undef;if( $in =~ /^view(alert|all|aux|fix|files|searchall)/ ){ $dall = "all";$du = $c{'base'}.$c{'docview'}; }
###sub_json_out({ 'debug' => "get_all check: \nin: $in \nu: $u \nis directory: ".(-d $u)." \ndocuments: $c{'documents'} \npages: $c{'pages'} \ndu: $du \ndall: $dall \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
my $err = undef;
if( defined $c{'documents'} && -d $du ){ my ($ferr,$fref) = sub_files_return($in,$du,$cref,$dall);if( defined $ferr ){ $err = $ferr; } else { %all = %{ $fref }; } }
if( defined $c{'pages'} ){ my ($perr,$pref) = sub_page_return($in,\@pagedirs,$cref);if( defined $perr ){ $err.= $perr; } else { $all{'pages'} = $pref; } }
###sub_json_out({ 'debug' => "get_all check 1: \nin: $in \nu: $u \nis directory: ".(-d $u)." \nn\n".Data::Dumper->Dump([\%all],["all"])."\n\n \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
return ($err,\%all); 
}

sub sub_get_changed{ 
# 'documents/Images/news/RSM__header_mobile.jpg' => {
# 'matches' => [ 'documents/Images/news/RSM__header_mobile.jpg' ],
# 'old' => [ 'documents/Images/news/RSM__header_mobile.jpg' ],
# 'new' => [ 'RSM__header_mobile.jpg' ],
# 'total' => 1,
# 'result' => [ '<strong>Found <u>1</u> instance of <i>documents/Images/news/</i> in <u>page url</u>: </strong><emp><i><u>documents/Images/news/</u>RSM__header_mobile.jpg</i></emp>' ]
# },
# 'News_RSM-Included-in-Most-Promising-IBM-Solutions-Providers-2015.html' => {
# 'matches' => [ '<div class="text" style="background-image: url(documents/Images/news/CIOReviewlogo_header.jpg);">&#160;</div>' ],
# 'old' => [ '<div class="row editblock"><div class="editimage"> <div class="text" style="background-image: url(documents/Images/news/CIOReviewlogo_header.jpg);">&#160;</div></div></div>' ],
# 'new' => [ '<div class="row editblock"><div class="editimage"> <div class="text" style="background-image: url(documents/Images/newsXXX/CIOReviewlogo_header.jpg);">&#160;</div></div></div>' ],    ],
# 'total' => 1,
# 'result' => [ '<strong>Found <u>1</u> instance of <i>documents/Images/news/</i> in <u>editable text</u>: </strong><emp>-block 1: line 8: <i>&lt;div class=&quot;text&quot; style=&quot;background-image: url(<u>documents/Images/news/</u>CIOReviewlogo_header.jpg);&quot;&gt;&amp;#160;&lt;/div&gt; </i></emp>' ]
# }
my ($ins,$ty,$fref,$cref,$findstr,$repstr,$alter,$regex,$code,$case,$inmenus,$inlistdir,$speed) = @_; #ins:all ty:search|used fu: /var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/ findstr:documents/Images/news/
my %c = %{$cref};
my %m = ();
my @s = ();
my $dbug = "";
###sub_json_out({ 'check get_changed' => "ins:$ins ty:$ty \nfref:$fref \ninlistdir:$inlistdir \nfindstr:$findstr \nrepstr:$repstr \nspeed:$speed \nalter:$alter \ninmenus:$inmenus \nregex:$regex \ncase:$case \n\n".Data::Dumper->Dump([\%m],["m"])."\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
my ($resp,$mref) = sub_admin_search($ins,$ty,$fref,$cref,$findstr,$repstr,$alter,$regex,$code,$case,$inmenus,$inlistdir,$speed);
if( defined $resp ){ $c{'debug'}.= $resp; };
%m = %{$mref};
###sub_json_out({ 'check get_changed in' => "ins:$ins ty:$ty \nfref:$fref \nfindstr:$findstr \nrepstr:$repstr \nalter:$alter \n inmenus:$inmenus \n regex:$regex \ncase: $case \n\n".Data::Dumper->Dump([\%m],["m"])."\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
my %ms = %{ $m{'searched'} };
if( scalar keys %ms > 0 ){
my $total = 0;
my $cc = 0;
foreach my $k( sort keys %ms ){
my $u = $k;
my $uf = undef;
my $pty = 'editpages';if( $k !~ /\.($c{'htmlext'})$/ ){ $pty = "viewfolders";($u,$uf) = sub_get_parent($k); }
if( defined $ms{$k}{'total'} ){ $total = $total+$ms{$k}{'total'}; }
$dbug.= "pty:$pty = k:$k = u:$u total = $total\n";
my $eu = $uri->encode($u);
if( $ty eq "search" ){
$s[0].= '<span class="foundlist">';
my $gtxt = '<a href="'.$c{'pl'}.'type='.$pty.'&amp;url='.$eu.'" target="_blank">'.$u.'</a>'.join "\n",@{ $ms{$k}{'result'} };
if( defined $ms{$k}{'result'} ){ $s[0].= sub_admin_dropsub($gtxt,$cc,$u); }
$s[0].= '</span>';
} elsif( $ty eq "rename" ){
$s[0].= '<span class="foundlist"><a href="'.$c{'pl'}.'type='.$pty.'&amp;url='.$eu.'" target="_blank">'.$u.'</a>';
if( defined $ms{$k}{'result'} ){ $s[0].= join "\n",@{ $ms{$k}{'result'} }; }
$s[0].= '</span>';
} else {
my $ve = ( $k =~ /\.($c{'htmlext'})$/ )?'Page':( $k =~ /\.(jpg|png|gif)$/i )?'Image':'File';
$s[0].= '<span class="usedlist tt_'.( ($ve eq "Page")?'listpage"><a ':'listimg"><a style="background-image:url('.$c{'baseview'}.$k.');' ).' href="'.$c{'pl'}.'type='.$pty.'&amp;url='.$eu.'" title="view '.$ve.'" target="_blank"><b>'.( ($ve eq "Page")?$k:$uf ).'</b></a></span>';
}
$cc++;
}
if( $ty eq "search"){ 
unshift @s,'<h3>Search Results:</h3>Total number of lines containing <span class="totallist">'.$findstr.'</span>: <u>'.$total.'</u>'; 
} elsif( $ty eq "rename"){
unshift @s,''.( ($total > 0)?' and affected <u>'.$total.' site file'.( ($total > 1)?"":"s" ).':</u>':'.' ); 
} else { 
unshift @s,'Alert: <span class="totallist">'.$findstr.'</span> is used '.$total.' time'.( ($total > 1)?"s":"" ).' in the following places:'; 
}
}
if( $ty eq "rename"){ unshift@s,'Renaming <span class="totallist">'.$findstr.'</span> to <span class="totallist">'.$repstr.'</span> was successful'; }
###sub_json_out({ 'check get_changed out' => "$dbug = ins:$ins \nty:$ty \nfref:$fref \nfindstr:$findstr \nrepstr:$repstr \nalter:$alter \n regex:$regex \ncase: $case \n\n".Data::Dumper->Dump([\@s],["s"])." \n\n".Data::Dumper->Dump([\%m],["m"])."\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
return @s;
}

sub sub_get_contents{ 
my ($f,$cref,$spaces,$utf) = @_;my %c = %{$cref};my $ln = (defined $spaces && $spaces eq "file")?$c{'defsep'}:undef;my $otxt = "";my $err = undef;if(-f $f){ my $en = (defined $utf)?"<":"<:utf8";my $hfile = gensym;
open($hfile,$en,$f) or try { die "get_contents: open $f failed: $!"; } catch { $err = "get_contents: open $f failed: $_"; };if( defined $hfile && !defined $err ){ flock ($hfile,2);while(<$hfile>){ my $tmp = $_;if(defined $ln){$tmp =~ s/($ln)/$c{'defrestore'}/gm;}$otxt.= (defined $ln)?$tmp.$ln:$tmp; }close($hfile); 
if( defined $spaces && $spaces eq "file" ){ 
$otxt =~ s/[\t\r\f\n]//g;$otxt =~ s/^(\s+)|(\s+)$//mg;$otxt =~ tr/ / /s;$otxt = sub_clean_printable($otxt); 
} elsif( defined $spaces && $spaces eq "filename" ){ 
$otxt =~ s/([^a-zA-Z0-9;\^\-#\&\$£\~\s])//gmsi;$otxt = sub_clean_printable($otxt);
} else { 
$otxt =~ s/(\n+)/\n/g; #html
}
#if( defined $raw ){ unless ( utf8::decode($otxt) ){ require Encode;$otxt = Encode::decode(cp1252 => $otxt); } }
 } } else { $err = "alert: unable to open $f: $! "; }
return ($err,$otxt); 
}

sub sub_get_data{ 
my ($f,$cref) = @_;my %c = %{$cref};my $n = $f;$n =~ s/^($c{'base'})//i;
my $del = ( $n =~ /\.($c{'htmlext'})$/)?$c{'delim'}:"/";
my $msize = sub_get_size($f);my $mdate = stat($f);my $md = $mdate->mtime;my $mc = sub_get_date($md,$cref);
my @vers = sub_get_versions($f,$cref); #[ 'Who-We-Are.Careers~~12:18:54-26--11--2015.html' ]
my %tm = ( 'published' => [ $mc ],'epoch' => [ $md ],'size' => [ $msize ],'url' => [ $n ],'versions' => \@vers );
if( !-w $f ){ if( !defined $tm{'issues'} ){ @{ $tm{'issues'} } = (); }push @{ $tm{'issues'} },( ($f =~ /\.($c{'htmlext'})$/i)?"Page":($f =~ /\.(jpg|png|gif)$/i)?"Image":"File" )." will not be editable until permissions are changed to 664"; }
my ($mpar,$mpath) = sub_get_path($f,$cref,$del);
if( defined $mpar ){ @{ $tm{'parent'} } = ( $mpar ); }
if( defined $mpath ){ 
my $l = scalar @{$mpath} -1;if( defined $c{'menulimit'} && $f =~ /\.($c{'htmlext'})$/i && $l > $c{'menulimit'} ){ if( !defined $tm{'issues'} ){ @{ $tm{'issues'} } = (); }push @{ $tm{'issues'} },"Menu depth of $f is too long: $l should be $c{'menulimit'}"; }
$tm{'path'} = $mpath; 
}
###if( $f =~ /Modules\.Swiper/ ){
###sub_json_out({ 'check get_data' => "f: $f \n\n".Data::Dumper->Dump([\%tm],["tm"])."\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
###}
return \%tm; 
}

sub sub_get_date{ my ($ep,$cref,$sep,$vers) = @_;my %c = %{$cref};my ($s,$min,$h,$md,$m,$y,$wd,$yd,$is) = gmtime($ep);$m++;$md = ($md < 10)?"0".$md:$md;$m = ($m < 10)?"0".$m:$m;$y = 1900+$y;if( defined $vers ){ if(defined $sep){if($vers =~ /version/){$sep = "-";}return $h.":".$min.":".$s." ".$md.$sep.$m.$sep.$y;} else {return sprintf("%02d:%02d:%02d-%02d--%02d--%04d",$h,$min,$s,$md,$m,$y);} } else { my $gap = (defined $sep)?$sep:"/";return $md.$gap.$m.$gap.$y; } }

sub sub_get_files{ my ($nb,$depth,$cref,$trim,$js,$fref,$over) = @_;my %c = %{$cref};my @faux = (defined $fref)?@{$fref}:();my $fset = (scalar @faux > 0)?(join "|",@faux):undef;my $dbug = "";my $fx = $c{'fxfile'};$fx.= (defined $js)?"|".$js:"";my @out;
my $miss = $c{'bandir'};my $docs = $c{'docview'};$docs =~ s/\/$//;if($nb =~ /^($c{'base'}$c{'docview'})/ || defined $fset){ $miss =~ s/(^|\|)$docs(\||$)/|/i; }
find(sub { 
if( -d && $File::Find::dir =~ /^$c{'base'}($miss)/ ){ if(defined $fset){ if( $File::Find::dir !~ /^$c{'base'}($fset)/ ){$File::Find::prune = 1;return;} } else { $File::Find::prune = 1;return; } } 
if( -d && defined $depth ){ if( defined $fset ){ my $ok = undef;for my $i(0..$#faux){if( $c{'base'}.$faux[$i] =~ /^($File::Find::dir)/ ){ $ok = 1; } }if( !defined $ok ){ $File::Find::prune = 1;return; } } else { if( $File::Find::dir ne $File::Find::name ){ $File::Find::prune = 1;return; } } }

my $n = $File::Find::name;
if( $n =~ /\.($fx)$/i && $n !~ /($c{'banfile'})$/ ){ 
my $ok = (defined $over || $File::Find::dir."/" eq $nb)?1:undef;
###
$dbug.= "$over || $File::Find::name eq $nb \n";
if( defined $fset && !defined $ok ){ for my $i(0..$#faux){if( $n =~ /^($c{'base'}$faux[$i])/ ){  $ok = 1;$dbug.= "$n =~ $c{'base'}$faux[$i] = $ok \n";} } }
if( defined $ok ){ if(defined $trim){ $n =~ s/^($c{'base'})//; }if( $n !~ /\/\.(.*?)$/ ){push @out,$n;} } 
}
},$nb);
###sub_json_out({ 'error' => "check get_files: nb:$nb \ndepth:$depth \ntrim:$trim \njs:$js \nmiss:$miss \nover:$over \nfaux: [ @faux ] \nfset:$fset \n\nout = [ @out ] \n\n$dbug \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
return @out; }

sub sub_get_filepath{ my ($line,$cref) = @_;my %c = %{$cref};$line =~ s/^($c{'base'})//;my @g = split /\//g,$line;my $file = pop @g;my $l = scalar @g;my %h = ( 'item' => $g[$c{'dlevel'}],'length' => $l,'path' => \@g );if( $file =~ /\.($c{'fxfile'})$/i ){ $h{'file'} =  $file; } else { $h{'folder'} = $file; }return \%h; }

sub sub_get_folders{ my ($nb,$ban) = @_;my @out;find(sub { /$ban/ and $File::Find::prune = 1;push @out,$File::Find::name if -d },$nb);return @out; }

sub sub_get_html{ my ($nb,$cref,$trim,$aux,$auxonly,$noban,$noadmin) = @_;my %c = %{$cref};my @out = ();find(sub { if(defined $noadmin){/admin/ and $File::Find::prune = 1;}if(!defined $noban){$File::Find::prune = 1 unless $File::Find::dir eq $File::Find::name;/$c{'bandir'}/ and $File::Find::prune = 1;}my $n = $File::Find::name;if(defined $trim){ $n =~ s/^($trim)//; }if( defined $aux && $n =~ /\.($aux)$/i ){ push @out,$n; }if( $n =~ /\.html$/ && $n !~ /($c{'banfile'})$/ && !defined $auxonly ){ push @out,$n; } },$nb);return @out; }

sub sub_get_info{ 
my ($u,$cref,$taginfo,$trim) = @_; #[ { 'parent' => 'Who-We-Are.html','href' => 'Who-We-Are_Meet-the-Team.html','menuname' => 'Meet the Team','type' => '','rank' => 002 } ]
my %c = %{ $cref };
my %t = (defined $taginfo)?%{$taginfo}:();
my $nosub = ( defined $trim && defined $c{'subdir'} && $c{'subdir'} ne "" )?1:undef;
my ($pdir) = sub_get_parent($u);
my %d = ();
my @tmp = ();
my $ntmp = "";
my $htmp = "";
my $ptmp = "";
my $utmp = "";
###sub_json_out({'debug' => "check get_info:u:$u \nc=  ".Data::Dumper->Dump([\%c],["c"]) },$c{'origin'},$c{'callback'});
if( -e $u ){ 
if( !defined $d{'menuname'} ){ @{ $d{'menuname'} } = (); $ntmp = $u;$ntmp =~ s/^($c{'base'})//;if( $ntmp =~ /\.($c{'htmlext'})$/ ){ $ntmp =~ s/(\.$c{'htmlext'})$//;$ntmp = sub_title_out($ntmp,$cref); } else { $ntmp =~ s/^.+\///; }push @{ $d{'menuname'} },$ntmp; }
if( !defined $d{'href'} ){  @{ $d{'href'} } = ();$htmp = $u;$htmp =~ s/^($c{'base'})//;if( defined $nosub ){ $htmp =~ s/$c{'subdir'}//; }push @{ $d{'href'} },$htmp; }
my %dt = %{ sub_get_data($u,$cref) };
if( defined $nosub ){ 
$ptmp = $dt{'parent'};$ptmp =~ s/^($c{'subdir'})//;@{ $dt{'parent'} } = ( $ptmp );
$utmp = $dt{'url'};$utmp =~ s/^($c{'subdir'})//;@{ $dt{'url'} } = ( $utmp );
shift @{ $dt{'path'} }; 
}
if( $htmp =~ /\.($c{'htmlext'})$/ && $htmp =~ /$c{'qqdelim'}/  ){ $ptmp = $htmp;$ptmp =~ s/^(.+)$c{'qqdelim'}(.*?)$/$1/;$ptmp.= ".".$c{'htmlext'};@{ $dt{'parent'} } = ( $ptmp); }
my $p = sub_admin_test_name($u,$cref);if( defined $p ){ push @{ $dt{'issues'} },$p; }
if( -d $pdir && ! -w $pdir ){ push @{ $dt{'issues'} },"Parent directory permissions need to be changed to 775"; }
%d = %{ sub_merge_hash( \%d,\%dt,\%t ) };
###if( $u =~ /RSM-Partners-Logo-Tagline.eps$/ ){ 
###sub_json_out({'debug' => "check get_info1:u:$u \n\n".Data::Dumper->Dump([\%d],["d"])." = ".Data::Dumper->Dump([\%dt],["dt"])." = ".Data::Dumper->Dump([$taginfo],["taginfo"])." \n\n$c{'debug'} " },$c{'origin'},$c{'callback'}); 
###}
}
return \%d; 
}

sub sub_get_images{ my ($nb,$ban) = @_;my @out = ();find(sub { if( -d && /$ban/ ){ $File::Find::prune = 1;return; }if( -f $File::Find::name && $File::Find::name =~ /\.(png|gif|jpg)$/i ){push @out,$File::Find::name;} },$nb); return @out; }

sub sub_get_indexed{ my ($nb,$pat,$dlim,$banf,$ban,$fx) = @_;my @out = ();my $htm = (defined $fx)?$fx:"html";find(sub { if( -d && /$ban/ ){ $File::Find::prune = 1;return; }if( -f $File::Find::name && $File::Find::name =~ /^($pat)($dlim)*/i && $File::Find::name !~ /($banf)$/i ){push @out,$File::Find::name if /\.($htm)$/i;} },$nb);return @out; }

sub sub_get_parent{ my ($fu) = @_;my $d = $fu;my $slash = undef;if($d =~ /\/$/){$d =~ s/\/$//;$slash = "/";}$d =~ s/^(.+\/)(.*?)$/$1/;my $f = $2;return ($d,$f.( (defined $slash)?$slash:'' )); }

sub sub_get_path{ my ($f,$cref,$del,$ext) = @_;my %c = %{$cref};my @p = ();my @path = ();my $par = undef;my $tm = $f;my $htmlext = (defined $ext)?$ext:$c{'htmlext'};my $delim = (defined $del)?$del:$c{'delim'};my $qqdelim = quotemeta($delim);$tm =~ s/^($c{'base'})//;$tm =~ s/\.($htmlext)$//;@path = split /$qqdelim/,$tm;my @tmp = @path;pop @tmp;if( scalar @tmp > 0 ){ $par = ( join $delim,@tmp );if( $f =~ /\.($c{'htmlext'})$/i ){$par.= ".".$c{'htmlext'};} }return ($par,\@path); } ##==pilbeam

sub sub_get_random{ my ($aref,$r) = @_;my @arr = @{ $aref };my @shuf = shuffle(0..$#arr);my @picked = @shuf[ 0..$r-1 ]; my @result = @arr[ @picked ];return @result; }

sub sub_get_remote{
my ($dest,$pref,$cref,$relay) = @_;
my %pd = %{ $pref };
my %c = %{$cref};
my $err = undef;
my $msg = "";
my ($req,$request,$res);
eval "use LWP::UserAgent";
if($@){
$err = "Unfortunately this server can\'t use LWP::UserAgent to open $dest:<br />Reason: $@";
} else {
use HTTP::Request::Common;
if( $c{'http'} eq "https" ){
use LWP::Protocol::https; #stop the warning "possible typo" in next statement
push( @LWP::Protocol::https::EXTRA_SOCK_OPTS,MaxLineLength => 0 );
} else {
use LWP::Protocol::http;
push( @LWP::Protocol::http::EXTRA_SOCK_OPTS,MaxLineLength => 0 );
}
my $ua = LWP::UserAgent->new;
$ua->agent("thatsthat/8.2.2 (Centos 7)");
if( defined $relay && defined $pref){
use HTTP::Request::Common qw(POST);
$res = $ua->request(POST $dest,Content_Type => 'form-data',Content => $pref);
} else {
$res = $ua->request(POST $dest,[%pd]); #//www.hindsfiguresltd.com/cgi-bin/nav.pl
}
if ($res->is_success){ $msg = $res->decoded_content; } else { $err = "Sorry, the server for [ $dest ] appears to be unavailable: ".$res->status_line." = ".$res->as_string; } #$res->content
}
return ($err,$msg);
}

sub sub_get_restored{ my ($cref) = @_;my %c = %{$cref};my @m = ();find(sub { if( -d $File::Find::name && $File::Find::name =~ /($c{'repdash'}$c{'repdash'})([0-9]+):([0-9]+):([0-9]+)-([0-9]+)--([0-9]+)--([0-9]+)$/ ){ my $n = $File::Find::name;my $s = $n;$s =~ s/^($c{'base'}$c{'restorebase'})//i;push @m,[ $s,stat($n)->mtime ]; } },$c{'base'}.$c{'restorebase'});return sort { $b->[1] <=> $a->[1] } @m; }

sub sub_get_size{ my ($i) = @_;my $ftps = -s $i;$ftps = $ftps/1000;my $s = int( $ftps + .5 * ($ftps <=> 0) );if($s < 1){$s = 1;}return $s."k"; }

sub sub_get_similar{ my ($wb,$pat) = @_;my @out = ();find(sub { $File::Find::prune = 1 unless $File::Find::dir eq $File::Find::name;if( -f $File::Find::name && $File::Find::name =~ /\/$pat/i ){push @out,$File::Find::name;} },$wb);return @out; }

sub sub_get_source{
my ($u,$in,$cref,$inlistdir,$fref,$over) = @_; #/var/www/vhosts/pecreative.co.uk/dev.pecreative.co.uk/documents/Archive/News/2017/
my %c = %{$cref};
my @faux = (defined $fref)?@{$fref}:();
my @m = ();
my @w = split /\//,$u;pop @w;
my $v = join "\/",@w; #/var/www/vhosts/pecreative.co.uk/dev.pecreative.co.uk/documents/Archive/News
my $dbug = "";
my $err = undef;
###sub_json_out({ 'check get_source' => "in: $in \nu: $u = ".( -d $u)." \nfaux:".Data::Dumper->Dump([\@faux],["faux"])." \nv: $v \ninlistdir:$inlistdir \nlistdir:$c{'listdir'} \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
if( $in eq "all" || $in eq "searchfolders" ){
my ($ferr,$fref) = sub_files_return($in,$u.$c{'docview'},$cref,"all");
if( defined $ferr ){ $err = $ferr; } else { %{ $m[0] } = %{ $fref }; }
} elsif( $in eq "index" || $in eq "list" || $in eq "menu" || $in eq "archivebase" || $in eq "archivelist" ){
if( $in eq "archivelist" ){ @m = sub_get_folders($v); }
if( $in eq "archivebase" ){ 
@m = sub_get_folders($u); 
} else {
if( $u =~ /($c{'docview'})Archive\// && defined $c{'filter'} ){ 
push @m,sub_get_files($u,"top",$cref); 
} else { 
my $pat = $u;$pat =~ s/(\.$c{'htmlext'})$//;push @m,sub_get_indexed($c{'base'},$pat,$c{'qqdelim'},$c{'banfile'},$c{'bandir'},$c{'htmlext'}); 
}
}
} elsif(-d $u){
if( $in eq "paginate" || $in eq "all" ){ my ($ferr,$fref) = sub_files_return($in,$u,$cref,"all");if( defined $ferr ){ $err = $ferr; } else { %{ $m[0] } = %{ $fref }; }  } else { @m = sub_get_files($u,"top",$cref,undef,undef,\@faux,$over); }
} elsif(-f $u){
push @m,$u;
} else { 
$dbug.= "get source:\n\n unable to open $u: $! ";
}
if( !defined $inlistdir ){ my @s = ();for my $i(0..$#m){ if($m[$i] !~ /($c{'listdir'})/ ){ push @s,$m[$i]; } }@m = @s; }
###sub_json_out({ 'check get_source 1' => "in: $in \nu: $u = ".( -d $u)." \nfaux:".Data::Dumper->Dump([\@faux],["faux"])." \nv: $v \ninlistdir:$inlistdir \nlistdir:$c{'listdir'} \nm:".Data::Dumper->Dump([\@m],["m"])." \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
return ($err,\@m);
}

sub sub_get_subpages{ my ($mref) = @_;my @m = @{$mref};my @n = ();for my $i(0..$#m){ push @n,$m[$i];if( defined $m[$i]->{'pages'} ){my @s = @{ sub_get_subpages($m[$i]->{'pages'}) };push @n,@s;} }return \@n; }

sub sub_get_subnumber{ my ($f,$cref) = @_;my %c = %{$cref};my @subs = ();my $msg = "";$f =~ s/\.($c{'htmlext'})$//;my @pgs = sub_get_html($c{'base'},$cref,$c{'base'});for my $i(0..$#pgs){ $msg.= "$i: ".$pgs[$i]." == "."$f".$c{'delim'};my $qm = '^'.quotemeta($f).$c{'qqdelim'};if( $pgs[$i] =~ $qm ){ push @subs,$pgs[$i];$msg.= " MATCH"; }$msg.="\n"; }return (\@subs,$msg); }

sub sub_get_tags{ my ($nb,$sw,$cref,$trim) = @_;my %c = %{$cref};my @p = ();find(sub { my $n = undef;if( -f $File::Find::name && $File::Find::name =~ /($c{'liblister'}|$c{'chapterlister'})$/i ){ $n = $File::Find::name; }if( -f $File::Find::name && defined $sw && $File::Find::name =~ /($c{'taglister'})$/i ){ $n = $File::Find::name; }if( defined $n ){ if( defined $trim ){ $n =~ s/^($c{'base'})//; }push @p,$n; } },$nb);return @p; }

sub sub_get_target{ my ($in,$bs,$sdir,$url,$nbs) = @_;if($in !~ /^(htt(p|ps):)*\/\//){ $in =~ s/^($sdir)//;$in = $bs.$in; }$in =~ s/($url)/$nbs/;if($in !~ /\.(.*?)$/){ $in =~ s/([^\/])$/\//; }return $in; }

sub sub_get_versions{ my ($fu,$cref,$del,$stats) = @_;my %c = %{$cref};my @m = ();my $u = $fu;$u =~ s/^($c{'base'})//i;$u =~ s/\.($c{'htmlext'})$//;find(sub { if( $File::Find::name =~ /\.($c{'htmlext'})$/i ){ my $n = $File::Find::name;my $s = $n;$s =~ s/^($c{'base'}$c{'versionbase'})//i;my $qm = '^'.quotemeta($u).$c{'repdash'}.$c{'repdash'};if( $s =~ $qm ){ if( defined $stats){ push @m,[ $s,stat($n)->mtime ]; } else { if( !defined $del || $s =~ /$c{'repdash'}$del$c{'repdash'}/ ){ push @m,$s;} } } } },$c{'base'}.$c{'versionbase'});return sort @m; }

sub sub_get_unversion{ my ($u,$cref) = @_;my %c = %{$cref};$u =~ s/^($c{'base'})//;$u =~s/^($c{'versionbase'})//;$u =~ s/~~.+(\.$c{'htmlext'})$/$1/;return $u; }

sub sub_get_usedpages{
my ($fu,$ty,$cref) = @_;
my %c = %{$cref};
my ($dir,$f) = sub_get_parent($fu); # dir: /var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/documents/Images/news f: z13_header.jpg 
my $du = $fu;$du =~ s/^($c{'base'})//i;
my %m = ();
my @r = ();
$m{$du} = sub_get_info($fu,$cref,{},"trim sub");
my %imgs = %{ sub_library_list('images',$dir,$cref,\%m,$c{'mobpic'},$du) }; #%imgs = { 'documents/Images/backgrounds/header-news.png' => ['News.html','News_GSE-2016.html'] }
###sub_json_out({ 'debug' => "fu:$fu \nty:$ty \ndir:$dir \ndu:$du \nf:$f \n\n".Data::Dumper->Dump([\%m],["m"])."\n\n".Data::Dumper->Dump([\%imgs],["imgs"])."\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
@r = ();if( defined $imgs{$du} && ref($imgs{$du}) eq 'ARRAY' ){ @r = sort @{ $imgs{$du} }; }
if( $ty eq "string"){
return join ", ",@r;
} elsif( $ty eq "links"){
my $tx = "";for my $i(0..$#r){ my $k = $r[$i];$tx.= '<a href="'.$r[$i].'" title="link to page" target="_blank">'.sub_title_out($r[$i],$cref).'</a>'; }return $tx;
} else {
return \@r;
}
}

sub sub_html_out{
my ($io) = @_;
print "Content-type: text/html; charset=UTF-8\n\n";
#warningsToBrowser(1);
print $io;
exit;
}

sub sub_image_used{
my ($u,$cref,$mref,$aux,$blocks) = @_; #documents/Images/projects
my %c = %{$cref};
my %m = (defined $mref)?%{$mref}:(); # { 'SNG-pic.jpg' => { 'href' => 'documents/Images/projects/SNG-pic.jpg', 'date' => 1438680196, 'menuname' => '/var/www/vhosts/intasave.org/httpdocs/documents/Images/projects/SNG pic.jpg', 'size' => '121k' }

###sub_json_out({ 'check image_used' => "u:$u \nblocks:$blocks \naux:".Data::Dumper->Dump([$aux],["aux"])."\n\n".Data::Dumper->Dump([\%m],["m"])."\n" },$c{'origin'},$c{'callback'});

my %imgs = %{ sub_library_list('images',$u,$cref,$mref,$c{'mobpic'},undef,$aux,$blocks) }; #'projects' => { 'SNG-pic.jpg' => { 'used' => ['Our-Projects_Solar-Nano-Grids.html'] } } 
my $dbug = "";
###sub_json_out({ 'check image_used 1' => "aux: $aux \nu = $u\n\n".Data::Dumper->Dump([\%imgs],["imgs"])."\n" },$c{'origin'},$c{'callback'});
if( defined $blocks ){ foreach my $k( sort keys %imgs){
$dbug.= "$k \n";
if( $k =~ /^($c{'imageview'})/ ){
if( defined $imgs{$k}{'used'} && scalar @{$imgs{$k}{'used'} } > 0 ){ $dbug.= "$k used in ".( join ", ",@{ $imgs{$k}{'used'} } )."\n"; } else { $dbug.= "$k is unused\n"; } 
} else { 
delete $imgs{$k}; 
}
} }
###sub_json_out({ 'check image_used 2' => "$dbug \n\n imageview:$c{'imageview'} \n" },$c{'origin'},$c{'callback'});
foreach my $h( keys %m){
my $r = @{$m{$h}{'href'}}[0];
my $iref = $imgs{$r};
if( defined $iref && defined $iref->{'used'} && defined $m{$r} ){ $m{$r}{'used'} = $iref->{'used'}; } 
$dbug.= "$r = added used to m \n";
}
###sub_json_out({ 'check image_used 3' => "$dbug \n\n imageview:$c{'imageview'} \n" },$c{'origin'},$c{'callback'});
###sub_json_out({ 'check image_used 4' => "dbug: $dbug \nu = $u\n\n".Data::Dumper->Dump([\%m],["m"])."\n" },$c{'origin'},$c{'callback'}); #.Data::Dumper->Dump([\%imgs],["imgs"])."\n\n";
return \%m;
}

sub sub_json_out{
my ($jref,$orig,$call) = @_;
my $type = ref $jref || undef;
if( defined $type ){
eval "use JSON";
if($@){ sub_json_print( sub_list_dump($jref,'query') ); } else { sub_json_print( "{ \"query\":".JSON->new->allow_nonref->utf8->encode($jref)." }",$orig,$call ); }
} else {
sub_json_print($jref,1,$call);
}
}

sub sub_json_print{
my ($jtxt,$q,$callback) = @_;
if( defined $callback && $callback ne "" ){
print "Content-type: application/javascript; charset=UTF-8\n\n";
print "$callback( $jtxt )";
} elsif( defined $q ){ 
print "Content-type: application/javascript; charset=UTF-8\n\n";
print "{ \"query\":[ \"$jtxt\" ] }";
} else {
print "Content-type: application/json; charset=UTF-8\n\n";
print $jtxt;
}
exit;
}

sub sub_library_drill{
my ($ty,$fd,$fh,$otxt,$dref,$cref) = @_;
my %data = %{$dref};
my %c = %{$cref};
if($ty eq "images"){
while($otxt=~ m/src="(\.\.\/)*($fd)(.*?)\.(jpg|png|gif)"/img){ $data{$1.$2.$3.".".$4}{$fh} = 1; }
while($otxt=~ m/url\("*(\.\.\/)*($fd)(.*?)\.(jpg|png|gif)"*\)/img){ $data{$1.$2.$3.".".$4}{$fh} = 1; }
while($otxt=~ m/data-id="images"(\s)*href="(.*?)"/gis){ $data{$2}{$fh} = 1; }
} else {
while($otxt=~ m/href="(\.\.\/)*($fd)(.*?)\.($c{'extdoc'})"/img){ $data{$1.$2.$3.".".$4}{$fh} = 1; }
while($otxt=~ m/data-id="files"(\s)*href="(.*?)"/gis){ $data{$2}{$fh} = 1; }
}
return \%data;
}

sub sub_libraryfile_out{
# 'files' => {
# 'documents/Digital/Datasheets/Mainframe-Services/Assured-Mainframe-Services-Overview.pdf' => { 
# 'area' => [],
# 'author' => [ 'Andrew Downie' ],
# 'focus' => [],
# 'menuname' => [ 'Assured-Mainframe-Services-Overview.pdf' ],
# 'size' => [ '365k' ],
# 'versions' => [],
# 'group' => [],
# 'href' => [ 'documents/Digital/Datasheets/Mainframe-Services/Assured-Mainframe-Services-Overview.pdf' ],
# 'text' => [],
# 'url' => [ 'documents/Digital/Datasheets/Mainframe-Services/Assured-Mainframe-Services-Overview.pdf' ],
# 'parent' => [ 'documents/Digital/Datasheets/Mainframe-Services' ],
# 'epoch' => [ 1516191163 ],
# 'epochcreated' => [ 1479081600 ],
# 'path' => [ 'documents','Digital','Datasheets','Mainframe-Services','Assured-Mainframe-Services-Overview.pdf' ],
# 'tags' => [ 'services' ],
# 'image' => [ 'documents/Digital/Datasheets/Mainframe-Services/Assured-Mainframe-Services-Overview_thumb.jpg' ],
# 'created' => [ '14/11/2016' ],
# 'published' => [ '17/01/2018' ],
# 'title' => [ 'Assured Mainframe Services Overview' ] 
# } 
# }
#
# url: Assured-Mainframe-Services-Overview.pdf
# image: Assured-Mainframe-Services-Overview_thumb.jpg
# title: Assured Mainframe Services Overview
# created: 14/11/2016 = published
# author: Andrew Downie
# area:
# focus:
# group:
# tags: services
# text:
my($mref,$cref) = @_;
my %im = %{$mref};
my %c = %{$cref};
my $n = 0;
my $ntxt = "";
my $err = undef;
foreach my $k(sort keys %im){
if( $k !~ /_thumb\.(jpg|png|gif)$/ ){
my $u = $k;
my $title = sub_title_out($u,$cref);
my $img = $u;$img =~ s/\.(.*?)$/_thumb.jpg/;
my @ltags = @{ $c{'libtags'} };
for my $i(0..$#ltags){
my $nu = lc $ltags[$i]; #Url Image Title Created Archive Area Author Focus Group Tags Text
if($nu ne "archive"){
if($nu eq "url"){ $ntxt.= (($n < 1)?"":"\n")."$nu: $u\n";$n++; } else { my $f = ($nu eq "created")?"published":$nu;my $h = $im{$k}->{$f};if( defined $h && scalar @{$h} > 0 ){my @kn = @{$h};for my $j(0..$#kn){my $w = $kn[$j];$ntxt.= "$nu: $w\n";} } else { 
if( $nu eq "image" && -f $c{'base'}.$img ){ $ntxt.= "$nu: $img\n"; } elsif($nu eq "title"){$ntxt.= "$nu: $title\n";} else {$ntxt.= "$nu:\n";} } }
}
}
}
}
return $ntxt;
}


sub sub_library_search{ 
my ($ty,$f,$fd,$fh,$dref,$cref) = @_;
my %data = %{$dref};
my %c = %{$cref};
local @ARGV = ($f); ###local $^I = ''; #local($^I) = '.bak';
while (<>){ 

if($ty eq "images"){
if( $_ =~ m/src="(\.\.\/)*($fd)(.*?)\.(jpg|png|gif)"/img){ $data{$1.$2.$3.".".$4}{$fh} = 1; }
if( $_=~ m/url\("*(\.\.\/)*($fd)(.*?)\.(jpg|png|gif)"*\)/img){ $data{$1.$2.$3.".".$4}{$fh} = 1; }
if( $_ =~ m/data-id="images"(\s)*href="(.*?)"/gis){ $data{$2}{$fh} = 1; }
} else {
if( $_ =~ m/href="(\.\.\/)*($fd)(.*?)\.($c{'extdoc'})"/img){ $data{$1.$2.$3.".".$4}{$fh} = 1; }
if( $_ =~ m/data-id="files"(\s)*href="(.*?)"/gis){ $data{$2}{$fh} = 1; }
}

} # continue { }
return \%data;
}

sub sub_library_list{
my ($type,$dir,$cref,$mref,$filter,$single,$aux,$blocks) = @_;
my %c = %{$cref};
my %m = (defined $mref)?%{$mref}:();
my %data = ();
my @par = ();
my @htm = ();
my $fd = $dir;$fd =~ s/^($c{'base'})//;
my %set = ();
my $dbug = "";
if( defined $blocks && defined $aux ){
###sub_json_out({ 'check library_list 1' => "type:$type \nblocks:$blocks \ndir:$dir \n\n".Data::Dumper->Dump([$aux],["aux"])."\n\n \n\n".Data::Dumper->Dump([$mref],["mref"])."\n\n $dbug" },$c{'origin'},$c{'callback'});
@htm = @{$aux};
for my $i(0..$#htm){
my %au = %{$htm[$i]};
if( defined $au{'data'}{'blocks'} ){
my @bs = @{$au{'data'}{'blocks'}};
$dbug.= "aux $i = $au{'data'}{'url'}[0] \n";
#if( $au{'data'}{'url'}[0] =~ /^Contact/ ){ $dbug.= "\n[ ".( join "\n\n",@bs )." ] \n\n"; }
for my $k( 0..$#bs){ %data = %{ sub_library_drill($type,$fd,$htm[$i]->{'data'}{'url'}[0],$bs[$k],\%data,$cref) }; }
}
}
} else {
@htm = (defined $blocks)?sub_get_html($c{'base'},$cref,undef,"css|js",undef,"noban","noadmin"):sub_get_html($c{'base'},$cref);
for my $i(0..$#htm){
if(-f $htm[$i]){
my $fh = $htm[$i];$fh =~ s/^($c{'base'})//;
my $err = undef;

if(defined $blocks){

%data = %{ sub_library_search($type,$htm[$i],$fd,$fh,\%data,$cref) };

} else {
my ($ierr,$otxt) = sub_get_contents($htm[$i],$cref);
if( !defined $ierr ){
%data = %{ sub_library_drill($type,$fd,$fh,$otxt,\%data,$cref) };
} else {
$err = "Open file $htm[$i] failed: $ierr";$dbug.= $err;
}
}

}
}
}
# $tmp = { 'documents/Images/backgrounds/header-news.png' => { 'News_RSM-Awarded-Government-Supplier-Status.html' => 1, 'News_RSM-assists-government-agency-zCloud-transition.html' => 1 } }
#$dref = {
# 'documents/Images/news/government-supplier_header_mobile.jpg' => [ 'Solutions_Swiper.html' ],
# 'documents/Images/news/RSM__header_mobile.jpg' => [ 'Solutions_Swiper.html' ],
# 'documents/Images/news/z13_header.jpg' => [ 'News_The-State-of-Mainframe-Security-in-the-Application-Economy.html' ]
#}
# %m = (
# 'documents/Images/experian.jpg' => {  'parent' => 'documents/Images/logos/customers','epoch' => 1473777141,'menuname' => 'experian.jpg','path' => [ 'documents','Images','logos','customers','experian.jpg' ],'size' => '3k','published' => '13/09/2016','href' => 'documents/Images/logos/customers/experian.jpg','url' => 'documents/Images/logos/customers/experian.jpg' },
# 'documents/Images/news-story1_header_mobile.jpg' => { 'parent' => 'documents/Images/news','epoch' => 1476193382,'menuname' => 'news-story1_header_mobile.jpg','path' => [ 'documents','Images','news','news-story1_header_mobile.jpg ],'size' => '27k','published' => '11/10/2016','href' => 'documents/Images/news/news-story1_header_mobile.jpg','url' => 'documents/Images/news/news-story1_header_mobile.jpg' },       
# )
###sub_json_out({ 'check library_list 2' => "data = ".Data::Dumper->Dump([\%data],["data"])." mref = ".Data::Dumper->Dump([$mref],["mref"])."\n\ndbug: $dbug" },$c{'origin'},$c{'callback'});
foreach my $k( sort keys %data ){
my $tm;
my $mm = "";
my $kk = undef;
if( defined $filter ){ 
if( $filter eq $c{'mobpic'} && $k =~ /\.(png|jpg|gif)$/ ){
if( $k !~ /($c{'mobpic'})\.(png|jpg|gif)$/ ){ 
$tm = $k;$tm =~ s/\.(png|jpg|gif)$/$c{'mobpic'}\.$1/;if( -f $c{'base'}.$tm ){ $mm = $tm;$mm =~ s/^.+\///;$kk = $mm; } 
} else { 
$tm = $k;$tm =~ s/$c{'mobpic'}\.(png|jpg|gif)$/\.$1/;if( -f $c{'base'}.$tm ){ $kk = $tm;$kk =~ s/^.+\///; } 
}
} 
}

if( defined $single && defined $m{$single} ){ 
%m = ( $single => [ sort keys %{$data{$single}} ] );  
} else {
if( defined $m{$k} ){ $dbug.= "$m{$k}{'url'}[0] == $k \n";
@{ $m{$k}{'used'} } = sort keys %{$data{$k}};if( defined $kk ){ @{ $m{$k}{'mobile'} }[0] = $kk; }
} else { 
if( $k !~ /\.($c{'htmlext'}|png|jpg|gif)/ ){ $dbug.= "sort for $k \n"; 
foreach my $j( sort keys %m){ 
if( defined $m{$j}{'parent'} && $m{$j}{'parent'}[0] =~ /^($k)$/ ){ $dbug.= "parent: $j = $m{$j}{'parent'}[0] = $k \n";
@{ $m{$j}{'used'} } = sort keys %{$data{$k}};if( defined $kk ){ @{ $m{$j}{'mobile'} }[0] = $kk; } 
} 
}
}
}
}

}
###sub_json_out({ 'check library_list 3' => "dbug: $dbug" },$c{'origin'},$c{'callback'});
###sub_json_out({ 'check library_list 4' => "base:$c{'base'} dir:$dir \nfilter:$filter \nm = ".Data::Dumper->Dump([\%m],["m"])."\n\n $dbug" },$c{'origin'},$c{'callback'});
return \%m;
}

sub sub_list_dump{ my($data,$title) = @_;$Data::Dumper::Purity = 1;$Data::Dumper::Indent = 0;my $d = Data::Dumper->new([$data],[$title],);return $d->Dump; } #$Data::Dumper::Sortkeys = \&sort_dump;

sub sub_log_out{
my ($jref,$cb) = @_;
my $herr = undef;
my $hfile = gensym;
open($hfile,">:utf8",$cb."UPLOADS/thatserror.txt") or die "open thatsthat error file failed: $! ";
if( defined $hfile && !defined $herr ){
flock ($hfile,2);
print $hfile sub_list_dump($jref,'query');
}
close($hfile);
exit(0);
}

sub sub_menu_newmeta{
my ($en,$dref) = @_;
my %tmp = %{$en};
my %dupes = %{$dref};
my %h = ();
foreach my $k( sort { $tmp{$a}{'data'}{'url'}[0] cmp $tmp{$b}{'data'}{'url'}[0] } keys %tmp ){
if( !defined $dupes{$tmp{$k}{'data'}{'url'}[0]} && !defined $dupes{$tmp{$k}{'data'}{'menu'}[0]} ){
$h{ @{ $tmp{$k}{'data'}{'url'} }[0] } = @{ $tmp{$k}{'data'}{'menu'} }[0];
$dupes{$tmp{$k}{'data'}{'url'}[0]} = 1;
$dupes{$tmp{$k}{'data'}{'menu'}[0]} = 1;
}
if( defined $tmp{$k}{'pages'} ){ %h = %{ sub_merge_hash(\%h,sub_menu_newmeta($tmp{$k}{'pages'},\%dupes) ) }; }
}
return \%h;
}

sub sub_menu_replace{ my ($ntxt,$rep) = @_;my $dtxt = $ntxt;my $num = 1;while( $dtxt =~ /(\s*<ul class="menu">.*?<\/ul>)(\s*<\/div>)/gis ){ my $fnd = quotemeta($1).$2;my $rr = $rep.$2;$rr =~ s/"toggle([0-9]+)-/"toggle$num-/gi;$ntxt =~ s/$fnd/$rr/gism; $num++; }return ($ntxt,"replaced: ".$num." in menus\n"); }

sub sub_menu_return{
my ($tmp,$css,$ind,$home,$full,$cref) = @_;
my %c = %{$cref};
my $soff = $c{'submenus'} || "off";
my $js = "";
my $dbug = "";
if( (defined $full && defined $tmp->{'menu'} && $tmp->{'menu'}[0] !~ /\.00$/) || (defined $tmp->{'menu'} && $tmp->{'menu'}[0] !~ /\.(0|00)$/) || (defined $tmp->{'menu'} && $soff eq "on") ){
$js = "<li>";
my $mtxt = ( $tmp->{'url'}[0] =~ /($ind)$/ )?$home:( defined $tmp->{'menuname'} )?$tmp->{'menuname'}[0]:( defined $tmp->{'url'} )?sub_title_out($tmp->{'url'}[0],$cref):( defined $tmp->{'shortname'} )?$tmp->{'shortname'}[0]:$tmp->{'title'}[0];
my $utxt = ( defined $tmp->{'link'} )?$tmp->{'link'}[0]:$tmp->{'url'}[0];
my $blank = ( $utxt =~ /^(ht|f)tp(s)*/ )?'" target="_blank':'';
my $sub = 0;
if( defined $tmp->{'pages'} ){ 
my @pages = @{ $tmp->{'pages'} };
for my $i(0..$#pages){ 
if( (defined $full && defined $pages[$i]{'menu'} && $pages[$i]{'menu'}[0] !~ /\.00$/) || (defined $pages[$i]{'menu'} && $pages[$i]{'menu'}[0] !~ /\.(0|00)$/) || (defined $tmp->{'menu'} && $soff eq "on") ){ $sub++; }$dbug.= "i = $pages[$i]{'menu'}[0] = $sub\n";
}
}
###sub_json_out({ 'check menu_return' => "css:$css \nind:$ind \nhome:$home \nfull:$full \nsub:$sub \n\n".Data::Dumper->Dump([$tmp->{'pages'}],["pages"])." \n\n".Data::Dumper->Dump([$tmp],["tmp"])."\n\n$c{'debug'} " },$c{'origin'},$c{'callback'});
if( $sub > 0 && $soff ne "on" ){ $js.= '<input id="toggle0-'.$css.'" class="subtoggle" type="checkbox" /><label for="toggle0-'.$css.'" class="subtogglelabel nonselect">'.$mtxt.'<span class="subtoggleicon"></span></label><a href="'.$utxt.$blank.'">'.$mtxt.'</a>'; }
if( $sub < 1 ){ $js.= '<a href="'.$utxt.$blank.'">'.$mtxt.'</a>'; }
if( $sub > 0 ){ 
$js.= "\n<ul>\n<li class=\"submenu-$css\">";$js.= '<a href="'.$utxt.$blank.'">'.$mtxt.'</a></li>';$js.= "\n";

my @pages = @{ $tmp->{'pages'} };
$dbug.= "$utxt pages:".scalar @pages."\n";
for my $i(0..$#pages){ $dbug.= "pages $i = css:$css full:$full sub:$sub\n\n";$js.= sub_menu_return( $pages[$i],$css.'-'.$i,$ind,$home,$full,$cref); }
$js.= "</ul>\n"; 

}
$js.= "</li>\n";
}
###sub_json_out({ 'check menu_return 1' => "js:$js \nind:$ind \nhome:$home \nfull:$full\n\n".Data::Dumper->Dump([$tmp],["tmp"])."\n\ndbug:$dbug " },$c{'origin'},$c{'callback'});
return $js;
}

sub sub_menu_sort{
my ($en,$dref,$cref,$showall) = @_;
my %tmp = %{ $en };
my %dupes = %{$dref};
my %c = %{$cref};
my @nv = ();
my $dbug = "";
my $c = 0;
foreach my $k( 
sort { 
( $tmp{$a}{'sorttype'} eq "url" )?$tmp{$a}{'data'}{'url'}[0] cmp $tmp{$b}{'data'}{'url'}[0]:
( $tmp{$a}{'sorttype'} eq "21" )?$tmp{$b}{'data'}{'epoch'}[0] <=> $tmp{$a}{'data'}{'epoch'}[0] || $tmp{$a}{'data'}{'title'}[0] cmp $tmp{$b}{'data'}{'title'}[0]:
( $tmp{$a}{'sorttype'} eq "12" )?$tmp{$a}{'data'}{'epoch'}[0] <=> $tmp{$b}{'data'}{'epoch'}[0] || $tmp{$a}{'data'}{'title'}[0] cmp $tmp{$b}{'data'}{'title'}[0]:
( $tmp{$a}{'sorttype'} eq "az" )?$tmp{$a}{'data'}{'title'}[0] cmp $tmp{$b}{'data'}{'title'}[0]:
( $tmp{$a}{'sorttype'} eq "za" )?$tmp{$b}{'data'}{'title'}[0] cmp $tmp{$a}{'data'}{'title'}[0]:
$tmp{$a}{'data'}{'menu'}[0] <=> $tmp{$b}{'data'}{'menu'}[0] || $tmp{$a}{'data'}{'url'}[0] cmp $tmp{$b}{'data'}{'url'}[0] || $tmp{$b}{'data'}{'epoch'}[0] <=> $tmp{$a}{'data'}{'epoch'}[0] || $tmp{$a}{'data'}{'title'}[0] cmp $tmp{$b}{'data'}{'title'}[0] #rank
} 
keys %tmp ){ 
#
$dbug.= "$k = $tmp{$k}{'sorttype'} >> $tmp{$k}{'url'}[0] = $tmp{$k}{'data'}{'menu'}[0] \n"; # if $tmp{$k}{'data'}{'url'}[0] =~ /^Events_/;
if( defined $tmp{$k}{'pages'} ){ $tmp{$k}{'data'}{'pages'} = sub_menu_sort( $tmp{$k}{'pages'},\%dupes,$cref,$showall ); }
delete $tmp{$k}{'data'}{'path'};
delete $tmp{$k}{'data'}{'parent'};
if( defined $showall ){
$nv[$c] = $tmp{$k}{'data'};$c++; #$dbug.= "$c = $tmp{$k}{'data'}{'url'}[0] = $k = $tmp{$k}{'sorttype'}\n"; # if $tmp{$k}{'data'}{'url'}[0] =~ /^Events_/;
} else {
if( !defined $dupes{$tmp{$k}{'data'}{'url'}[0]} && !defined $dupes{$tmp{$k}{'data'}{'menu'}[0]} ){ 
if( !defined $tmp{$k}{'data'}{'issues'} || $tmp{$k}{'data'}{'issues'} !~ /URL Tag/ ){ $dupes{$tmp{$k}{'data'}{'url'}[0]} = 1;$dupes{$tmp{$k}{'data'}{'menu'}[0]} = 1;$nv[$c] = $tmp{$k}{'data'};$c++; 
#
$dbug.= "$c = $tmp{$k}{'data'}{'url'}[0] = $k = $tmp{$k}{'sorttype'}\n"; # if $tmp{$k}{'data'}{'url'}[0] =~ /^Events_/; 
} }
}
}
###sub_json_out({ 'check menu_sort' => "$dbug \n\n$c{'debug'} " },$c{'origin'},$c{'callback'});
return \@nv;
}

sub sub_menu_update{
#<ul class="menu">  
#<li><input id="toggle0-1-0" class="subtoggle" type="checkbox" /><label for="toggle-0-1-0" class="subtogglelabel nonselect">Services<span class="subtoggleicon"></span></label><a href="Services.html" target="_blank">Services</a>
#<ul>
#<li><a href="Services.html" target="_blank">Services</a></li>
#<li><a href="Services_Skills-&-Resources.html">Skills &#38; Resources</a></li>
#<li><a href="Services_Solutions.html">Solutions</a></li>
#</ul>
#</li>  
# <li><input id="toggle-software" class="subtoggle" type="checkbox" /><label for="toggle-software" class="subtogglelabel nonselect">Software<span class="subtoggleicon"></span></label><a>Software</a>
#<ul>
#<li><a href="Software.html">Software</a></li>
#<li><a href="Software_racf-GUI.html">racf GUI</a></li>
#<li><a href="Software_exception-Reporter.html">exception Reporter</a></li>
#</ul>
#</li>
#<li><a href="Contact.html">Contact</a></li> 
#</ul>
#
#</div> 
#
my ($ins,$htm,$shtm,$href,$cref,$filesref) = @_;
my %h = %{$href};
my %c = %{$cref};
my @m = (defined $filesref)?sort @{$filesref}:sub_get_files($c{'base'},"top",$cref);
my $msg = "";
my $err = undef;
###sub_json_out({ 'check menu_update 1' => "m = [ ".( join "\n",@m )." ] \n\n$c{'debug'} " },$c{'origin'},$c{'callback'});
for my $i(0..$#m){
if( $m[$i] =~ /(\.$c{'htmlext'})$/ ){
my @lines = ();
my $crum = $m[$i]; $crum =~ s/^($c{'base'})//i;
my $tmp = $crum;$tmp =~ s/\.($c{'htmlext'})$//;
my $pg = sub_page_classout($m[$i],$cref);$pg.= " ".join " ",@{ $c{'body_regx'} };
###
$msg.= "crum:$crum tmp:$tmp pg:$pg == $h{$crum} \n";
my $ntxt = "";
my $rbug = "";
my $nhtm = $htm;
$nhtm =~ s/<li>(<input id=".*?" class="subtoggle" type="checkbox" \/><label for=".*?" class="subtogglelabel nonselect">.*?<span class="subtoggleicon"><\/span><\/label><a href="$crum".*?>.*?<\/a>)/<li class="navoff">$1/gi;
$nhtm =~ s/<li>(<a href="$crum".*?>.*?<\/a><\/li>)/<li class="navoff">$1/gi;
if( -f $m[$i] ){
my $ctxt = ($c{'index_file'} ne "Home")?"<p>":"<p><a href=\"$c{'index_file'}\">$c{'homeurl'}</a><span class=\"crumbjoin\">&#160;</span>";
my @path = split /$c{'qqdelim'}/,$tmp;
for my $j(0..$#path){ 
if($j > 0){ $ctxt.= "<span class=\"crumbjoin\"></span>"; }
if($j < $#path){ my $upp = "";if($j > 0 ){ my @len = @path;splice(@len,$j);$upp = (join $c{'delim'},@len)."$c{'delim'}"; }$ctxt.= "<a href=\"$upp$path[$j].$c{'htmlext'}\">".sub_title_out($path[$j],$cref)."</a>"; } else { $ctxt.= sub_title_out($path[$j],$cref); } 
}
$ctxt.= "</p>";
my ($ferr,$otxt) = sub_get_contents($m[$i],$cref,"text");
if( !defined $ferr ){
$ntxt = $otxt;
$ntxt =~ s/(<body id="body0" class=")(.*?)(">)/$1$pg$3/ism;
#<li><input id="toggle0-2-0" class="subtoggle" type="checkbox" /><label for="toggle0-2-0" class="subtogglelabel nonselect">Solutions<span class="subtoggleicon"></span></label><a>Solutions</a><ul>
#<li><a href="Solutions.html">Solutions</a></li>
#<li><a href="Solutions.Slideshow.html">Slideshow</a></li>
if( defined $h{$crum} ){ ($ntxt,$rbug) = sub_page_replacemeta($ntxt,$cref,undef,undef,undef,undef,{'editmenu' => $h{$crum},'editurl' => $crum });$msg.= $rbug;  } # 'Solutions_Modules.html' => '003.001',
if( $ins =~ /menu/ ){ ($ntxt,$rbug) = sub_menu_replace($ntxt,$nhtm);$msg.= $rbug;$ntxt =~ s/(<div class="crumb">\s*)<p>.*?<\/p>(\s*<\/div>)/$1$ctxt$2/gism; }
if( $m[$i] =~ /($c{'site_file'})$/ ){ ($ntxt,$rbug) = sub_sitemap_replace($ntxt,$shtm);$msg.= $rbug; } #$ntxt =~ s/\n\n*/\n/gm; 
$ntxt = sub_clean_utf8( $ntxt,$c{'UTF'},$c{'UTF1'},"despace" );
###if( $m[$i] =~ /Members\.html/ ){ 
###sub_json_out({ 'check menu_update 2' => "$ntxt \n\nmsg:$msg \n\nerr:$err \n\n".Data::Dumper->Dump([\%h],["h"])."\n\n$c{'debug'} " },$c{'origin'},$c{'callback'}); 
###}
my $herr = sub_page_print($m[$i],$ntxt);if( defined $herr ){ $err = (defined $err)?$err.$herr:$herr; } else { $msg.= "".$crum.": <i>menus updated</i><br />"; }
} else {
$err.= "menu_update error: write page: $ferr <br />";
}
} else {
$err.= "menu_update error: write page: open $m[$i] failed: $! <br />";
}
}
}
return ($err,$msg);
}

sub sub_merge_array (@){ my %h;map { $h{$_}++ == 0 ? $_ : () } @_; }

sub sub_merge_hash{
my ($aref,$bref,$cref,$dref) = @_;
my %hash1 = (defined $aref)?%{$aref}:();
my %hash2 = (defined $bref)?%{$bref}:();
my %hash3 = (defined $cref)?%{$cref}:();
my %hash4 = (defined $dref)?%{$dref}:();
my ($k,$v);
my %merged = ();
while( ($k,$v) = each(%hash1) ){ $merged{$k} = $v; }
while( ($k,$v) = each(%hash2) ){ $merged{$k} = $v; }
while( ($k,$v) = each(%hash3) ){ $merged{$k} = $v; }
while( ($k,$v) = each(%hash4) ){ $merged{$k} = $v; }
return \%merged;
}

sub sub_new_upload{
# X-File-Id\' => 0
# file\' => test2.jpg
# X-File-Total => 0
# X-File-Size => 170846
# X-File-Resume => false
# new => documents/Images/projects/
# X-Requested-With => XMLHttpRequest
# url => documents/Images/projects/
# type => changeuploadfolders
#sized => Document Thumbnails,_thumb,100,140+Header Images,_header,1200,400+Mobile Versions,_header_mobile,480,250
# X-File-Name => test2.jpg
# f: /var/www/vhosts/intasave.org/httpdocs/Our-Projects_Test-Page-1.html/uP_lOADED_documents/Images/projects/ /var/www/vhosts/intasave.org/httpdocs/Our-Projects_Test-Page-1.html/ test2.jpg 
# type: changeuploadfolders
# n: test2.jpg
# url:/var/www/vhosts/intasave.org/httpdocs/documents/Images/projects/
# new:documents/Images/projects/
# tt:0
my ($u,$n,$o,$data,$xname,$xtmpfile,$no,$tot,$sized,$imported,$cref) = @_; 
my %c = %{$cref};
my %m = ();
my $xno = $no+1;
my $xtotal = $tot+1;
if($u !~ /\/$/){ $u.= "/"; }
$n =~ s/^\///;
$o =~ s/^\///;
my $f = $o;
my $last = "";
my $t = "uP_lOADED_";
my $mc = "";
my $dupe = undef;
my $err = undef;
$err = "open $u failed: $!" unless defined $u && -d $u;
if( defined $o && $o ne ""){
$f = $u.$t.$o;
$dupe = 1;
} elsif( defined $n && $n ne "" ){
$f = $u.$n;
} else {
$err = "not enough data received [ $u $n $o ]";
}
my $fd = $f;$fd =~ s/^($c{'base'})//;$fd =~ s/^.+($c{'imagefolder'})\///; #u = /var/www/vhosts/intasave.org/httpdocs/documents/Images/events/ f = documents/Images/events/dev-example.png fd = events/dev-example.png
my $furl = $f;$furl =~ s/^($c{'base'})//;$furl =~ s/^(.+)\/(.*?)\.(png|jpg|gif)$/$1\//i;$furl =~ s/^\///;
###sub_json_out({ 'upload check 1' => "sized: $sized \nfurl: $furl \nerr: $err  \n\nf= $f \ \n\n$c{'debug'} " },$c{'origin'},$c{'callback'});
$err = "File extension for file $fd is missing or incorrect." unless $f =~ /\.($c{'fxfile'}|JS)$/i;

if( $f =~ /\.(png|jpg|gif)$/i && defined $sized && $sized ne "" ){  

###sub_json_out({ 'upload check 2' => "sized: $sized \nfurl: $furl \nX-File-Name =  $xname \nerr: $err \n\n$c{'debug'} " },$c{'origin'},$c{'callback'});
my %send = ( 'check' => $c{'ftpcheck'},'pass' => $c{'ftppass'},'origin' => $ENV{'SERVER_ADDR'},'ftpbase' => $c{'ftpbase'},'ins' => "repic",'X-File-Name' => $xname,'filedata' => [ $xtmpfile ],'X-File-Id' => $no,'X-File-Total' => $tot,'X-Return-Url' => $furl );
my $nc = "";
my $dests = "";
my @szs = split /\+/,$sized;
for my $i(0..$#szs){ 
my @wh = split /,/,$szs[$i];
my $nm = $f;$nm =~ s/^($c{'base'})//;$nm =~ s/.+\/(.*?)\.(png|jpg|gif)$/$1$wh[1].$2/i;
$nc.= "<p>Created ".( (scalar @szs < 1)?"version ".(1+$i):"" )." <b>".$nm."</b> resized for ".$wh[0]." (".$wh[2]." x ".$wh[3]." px)</p>"; 
$send{'type'.$i} = $wh[0]; #Document Thumbnails,Header Images,Mobile Versions,Staff Pictures,Video Screengrabs
$send{'dests'.$i} = $nm; #test1_header.jpg, test1_mobile.jpg
$send{'widths'.$i} = $wh[2]; # 460
$send{'heights'.$i} = $wh[3]; # 260
$send{'res'.$i} = 72; # 72
#'tops'.$i => ""; # 400
#'lefts'.$i => ""; # 400
#'bottoms'.$i => ""; # 400
#'rights'.$i => ""; # 400
#'xscales'.$i => ""; #0.6
#'yscales'.$i => ""; #0.8
#'xyunits'.$i => ""; # px pc
}
$mc = $nc.$mc;
# $send = {
# 'check' => undef,
# 'pass' => undef,
# 'origin' => '127.0.0.1', 
# 'ftpbase' => '/var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/',
# 'ins' => 'repic',
# 'X-File-Name' => 'Test-Image.gif',
# 'filedata' => [ '/tmp/9l224YjUMT' ],
# 'X-File-Id' => 0,
# 'X-File-Total' => 0,
# 'X-Return-Url' => 'documents/Images/posters/',
# 'type0' => 'Library Document',
# 'dests0' => 'documents/Images/posters/Test-Image.gif',   
# 'widths0' => '100',
# 'heights0' => '140',  
# 'res0' => 72
# }
###sub_json_out({ 'upload check 3' =>  "sized: $sized \nimagerelay: $c{'imagerelay'} \nfurl: $furl \nszs: @szs \nnc:$nc \nmc: $mc \nerr: $err \n\n".Data::Dumper->Dump([\%send],["send"])." \n\n $c{'debug'} " },$c{'origin'},$c{'callback'});
#
if( $c{'imagerelay'} eq "localhost" ){
my($rerr,$rret) = sub_get_remote($c{'baseview'}.'cgi-bin/imager.pl',\%send,$cref,"relay");
$err = $rerr if defined $rerr;
$mc = "<p>$rret</p>";
#sized: Library Document,_thumb,100,140 
#furl: documents/Publications/Biodiversity,-Eco--Systems-and-Marine-Conservation/Marine-Managed-Areas/ 
#szs: Library Document,_thumb,100,140 
#nc:<p>Created  <b>documents/Publications/Biodiversity,-Eco--Systems-and-Marine-Conservation/Marine-Managed-Areas/Prolinx_MASTER_Logo3.png</b> resized for Library Document (100 x 140 px)</p> 
#mc: <p>Created  <b>documents/Publications/Biodiversity,-Eco--Systems-and-Marine-Conservation/Marine-Managed-Areas/Prolinx_MASTER_Logo3.png</b> resized for Library Document (100 x 140 px)</p> 
###sub_json_out({ 'upload check 4A' =>  "sized: $sized \nfurl: $furl \nszs: @szs \nnc:$nc \nmc: $mc \nerr: $err \n\n $c{'debug'} " },$c{'origin'},$c{'callback'});
} else {
my($rerr,$rret) = sub_get_remote($c{'imagerelay'},\%send,$cref,"relay");
$err = $rerr if defined $rerr;
$mc = "<p>$rret</p>";
###sub_json_out({ 'upload check 4' =>  "sized: $sized \nfurl: $furl \nszs: @szs \nnc:$nc \nmc: $mc \nerr: $err \n\n $c{'debug'} " },$c{'origin'},$c{'callback'});
}

} else {

if( !defined $err && defined $xtmpfile && defined $f ){
if( defined $dupe && -f $u.$o ){ $f = $u.$o; }
mv ($xtmpfile,$f) or try { die "new_upload: move file $xtmpfile to $f: $!"; } catch { $err = "new_upload:move file $xtmpfile to $f: $_"; };
if( !defined $err ){
chmod (0664,$f) or try { die "new_upload: chmod $f failed: $!"; } catch { $err = "new_upload: chmod $f failed: $_ \n"; };
my $vo = $f;$vo =~ s/^($c{'base'})/$c{'baseview'}/i;

if( defined $imported ){
if( $imported eq "imported" ){
###sub_json_out({ 'upload check 5' =>  "imported: $imported \nu:$u \nn:$n \nf:$f \nvo \n\n $c{'debug'} " },$c{'origin'},$c{'callback'});
sub_zip_in($u,$n,$cref);
} elsif( $imported eq "distribute"){
###sub_json_out({ 'upload check 6' =>  "imported: $imported \nu:$u \nn:$n \nf:$f \nvo \n\n $c{'debug'} " },$c{'origin'},$c{'callback'});
$mc.= $vo.' uploaded <br />';
} else {
$mc.= ' - <a href="'.$vo.'" target="_blank" title="view File">View File</a>';
}
} else {
#vo: https://rsmpartners.com/documents/Partner-Portal/Presentations/test-document.pdf 
# u: /var/www/vhosts/pecreative.co.uk/rsmpartners.com/documents/Partner-Portal/Presentations/ 
# o: 
# f: /var/www/vhosts/pecreative.co.uk/rsmpartners.com/documents/Partner-Portal/Presentations/test-document.pdf 
# n: test-document.pdf
if( $vo =~ /\.($c{'extlib'})$/i ){
my $ext = $1;
my ($ierr,$itxt) = sub_image_generate('thumbnail',$f,$f,{ 'ImageHeight' => "202",'ScaleImage' => "true",'ImageResolutionH' => "72",'ImageResolutionV' => "72",'ScaleProportions' => "true",'PageRange' => "1" },'vZpqbZTSJy4AUDTi',$ext,$cref);$mc.= $itxt;$err = (defined $err)?$err.=$ierr:$ierr if defined $err; }
$mc.= ' - <a href="'.$vo.'" target="_blank" title="view File">View Uploaded File</a> ';
if( $vo !~ /_thumb\.(.*?)$/ ){ my ($er,$m) = sub_libraryfile_update('editlibrary',$f,$cref,'all');$mc.= $er if defined $er; }
}
}
}

}
return ($err,"uploaded successfully ($xno/$xtotal) $mc");
}

sub sub_image_generate{
# curl -F "File=@/path/to/my_file.pdf" -F "ImageResolutionH=72" -F "ImageResolutionV=72" -F "ScaleImage=true" -F "ScaleProportions=true" -F "ImageHeight=75" https://v2.convertapi.com/convert/pdf/to/jpg?Secret=eQVM7qjTRyVvMgyI
# curl -F "File=@/path/to/my_file.html" -F "ConversionDelay=5" -F "ImageWidth=1200" -F "CropHeight=800" -F "JpgQuality=70" https://v2.convertapi.com/convert/html/to/jpg?Secret=vZpqbZTSJy4AUDTi
# https://v2.convertapi.com/convert/pdf/to/jpg?Secret=eQVM7qjTRyVvMgyI&download=attachment
# https://metacpan.org/pod/release/SZBALINT/WWW-Curl-4.12/lib/WWW/Curl.pm
# eQVM7qjTRyVvMgyI
my ($ty,$f,$nw,$pref,$sec,$ext,$c) = @_;
my %p = %{$pref};
my %c = %{$c};
my $next = ($ty eq "thumbnail")?"_thumb.jpg":".jpg";
my $nf = $nw;$nf =~ s/\.($ext)$/$next/i;
my $bf = $nf;$bf =~ s/^($c{'base'})/$c{'baseview'}/;
my $s = "";
my $err = undef;
eval "use WWW::Curl::Easy";

if($@){ 
$s.= "<span>PDF Auto Thumbnail is currently not available on this server.</span>";$err = $s;
} else {

use WWW::Curl::Form;
my $curlf = WWW::Curl::Form->new;

$curlf->formaddfile($f,'file',"multipart/form-data");
$curlf->formadd("download","attachment");
foreach my $k(keys %p){ $curlf->formadd($k,$p{$k}); }

my $cbug;
my $curl = WWW::Curl::Easy->new;
$curl->setopt($curl->CURLOPT_HEADER,0);
if($ty eq "ogi mage"){
$curl->setopt($curl->CURLOPT_URL,"https://v2.convertapi.com/convert/".$ext."/to/jpg/converter/HtmlToImageWebKit?Secret=".$sec."&download=attachment");
} else {
$curl->setopt($curl->CURLOPT_URL,"https://v2.convertapi.com/convert/".$ext."/to/jpg?Secret=".$sec."&download=attachment");
}
$curl->setopt($curl->CURLOPT_WRITEDATA,\$cbug );
$curl->setopt($curl->CURLOPT_HTTPPOST, $curlf);

my $retcode = $curl->perform;
if($retcode == 0){
my $response_code = $curl->getinfo($curl->CURLINFO_HTTP_CODE);

if($response_code == 200){

my $hfile = gensym;
open($hfile,">",$nf) or try { die "open file $nf failed: $! "; } catch { $err = "<span class=\"error\">save_page: open file $nf failed: $_ </span> "; };
if( defined $hfile && !defined $err ){
flock ($hfile,2);
binmode $hfile;
print $hfile $cbug;
close($hfile);
$s.= ' - <span class="ok"><a href="'.$bf.'" title="view created '.$ty.'" target="_blank">Auto '.$ty.' created</a></span> ';
}

} else {
$s.= '<span class="ok">Received response ('.$response_code.') '.Data::Dumper->Dump([\$cbug],["cbug"]).': '.$bf.'</span> ';
}

} else {
$s.= '<span class="error">An error happened: $retcode '.$curl->strerror($retcode).' = '.$curl->errbuf.'</span> ';$err = $s;
}

}
return ($err,$s);
}

sub sub_libraryfile_update{
my ($ty,$f,$cref,$all) = @_;
my %c = %{$cref};
my $dir = $f;$dir =~ s/^($c{'base'}$c{'docview'})(.*?\/)(.*?)$/$1$2/; #(/var/www/vhosts/pecreative.co.uk/rsmpartners.com/documents/)(Partner-Portal/)Presentations/test-document.pdf #(/var/www/vhosts/pecreative.co.uk/rsmpartners.com/documents/)(Partner-Portal/)test-document.pdf
my $lfile = $dir;
my $ltxt = "";
my $err = undef;
if( -f $f && $f =~ /$c{'chapterlister'}/ ){ 

my ($ierr,$otxt) = sub_get_contents($f,$cref,"text");
if( defined $ierr ){ $err.= $ierr; } else { $ltxt = $otxt; }
###sub_json_out({ 'check libraryupdate' => "get chapter $f\n\n ltxt:$ltxt \nerr:$ierr \n$c{'debug'}" },$c{'origin'},$c{'callback'});

} else { 

$lfile = $dir.$c{'liblister'};
if( -f $lfile ){
my ($ferr,$fref) = sub_files_return($ty,$dir,$cref,$all);
$err = "Update Library: $dir: $ferr \n\n".Data::Dumper->Dump([$fref->{'files'}],["files"])."\n\n $c{'debug'}" if defined $ferr;
###sub_json_out({ 'check libraryupdate 1' => "".Data::Dumper->Dump([$fref->{'files'}],["files"])."\n\n err:$err \n$c{'debug'}" },$c{'origin'},$c{'callback'});
if( !defined $err ){ 
$ltxt = sub_libraryfile_out($fref->{'files'},$cref); 
###sub_json_out({ 'check libraryupdate 2' => "dir:$dir \nltxt: $ltxt \n\n".Data::Dumper->Dump([$fref->{'files'}],["files"])."\n\n \n$c{'debug'}" },$c{'origin'},$c{'callback'});
my ($nferr,$nf) = sub_admin_save_page($c{'liblister'},$lfile,$ltxt,$cref,undef,'overwrite');
if( defined $nferr ){ $err = "Update Library file: $ltxt: $nferr \n"; }
}
}

}

return ($err,$ltxt);
}

sub sub_numberpad{ my ($s,$top,$sw) = @_;return (defined $sw && $s < 10)?$sw.$s:(!defined $sw && $s < 10 && $top eq '100')?'00'.$s:(!defined $sw && $s < 10 && $top eq '1000')?'000'.$s:(!defined $sw && $s < 100 && $top eq '100')?'0'.$s:(!defined $sw && $s < 100 && $top eq '1000')?'00'.$s:(!defined $sw && $s < 1000)?'0'.$s:$s; }

sub sub_page_classout{
#newest/News.RSM-Awarded-Government-Supplier-Status.html
my ($h,$cref) = @_;
my $n = $h;
my %c = %{$cref};
$n =~ s/^(.+\/)//i;
$n =~ s/\.($c{'htmlext'})$//;
$n =~ s/(\.)/-/g;
$n =~ s/(\&)//g;
$n = substr($n,0,50);
return lc $n;
}

sub sub_page_findreplace{
# {
# 'News.html' => {
# 'link' => [ 'News.html' ],
# 'shortname' => [ 'News' ],
# 'epoch' => [ 1483527458 ],
# 'blocks' => [],
# 'date' => [ '05/10/16' ],
# 'menu' => [ '001' ],
# 'menuname' => [ 'News' ],
# 'size' => [ '23k' ],
# 'published' => [ '04/01/2017' ],
# 'url' => [ 'News.html' ],
# 'title' => [  'News' ],
# 'pages' => [ 
# { 'link' => [ 'News_RSM-assists-government-agency-zCloud-transition.html' ],
# 'shortname' => [ 'Government zCloud Transition' ],
# 'epoch' => [1483527459 ],
# 'blocks' => [ 
#'<div class="row editblock pulled">
#<div class="edittitle"> <div class="text"><span>RSM assists government agency zCloud transition</span></div> </div> 
#<div class="editimage"> <div class="text" style="background-image: url(documents/Images/news/shutterstock_139497248_header.jpg);">&#160;</div> </div> 
#<div class="edittext"> <div class="text"> <p>26th September 2016: A large government agency was transitioning into the IBM zCloud at a rapid pace. </p> </div> </div> 
#</div> ' ],
# 'area' => [ 'Services' ],
# 'date' => [ '29/09/16' ],
# 'menu' => [ '001.000.0' ],
# 'menuname' => [ 'RSM assists government agency zCloud transition' ],
# 'focus' => [ 'Digital Outcomes' ],
# 'size' => [ '17k' ],
# 'published' => [ '04/01/2017' ],
# 'url' => [ 'News_RSM-assists-government-agency-zCloud-transition.html' ],
# 'title' => [ 'RSM assists government agency zCloud transition' ],
# 'menutext' => [ '' ],
# 'sitemaptext' => [ '' ],
# 'code' = [ 'html' ]
# }
# ]
# }
my ($href,$lsref,$foundref,$cref,$findref,$repref,$regex,$case,$where,$code,$inmenus) = @_;
my %h = %{$href};
my @ls = @{$lsref};
my @terms= @{$findref};
my %c = %{$cref};
my $u = (defined $h{'url'}[0])?$h{'url'}[0]:undef;
my $dbug = "";
###sub_json_out({ 'check page_findreplace in' => "u: $u \n\n ".Data::Dumper->Dump([\%h],["h"])."\n\n \n\n".Data::Dumper->Dump([\@ls],["ls"])."\n\n".Data::Dumper->Dump([$foundref],["foundref"])."\n\nregex:$regex \ncase:$case \ncode:$code \nwhere:$where\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
if(defined $u){
if(defined $code){
my %sr = sub_search_string(@{ $h{'code'} }[0],$findref,$repref,$regex,$case,"code",$cref,$where);
$dbug.= "\nchecking code: ".Data::Dumper->Dump([\%sr],["sr"])."\n\n == in $h{'code'}[0] \n\n";
my $pass = undef;
my $tot = 0;
if( defined $sr{'totals'} ){ my %tts = %{ $sr{'totals'} };foreach my $c( keys %tts ){ if( $tts{$c} > 0 ){ $tot = $tot+$tts{$c};$pass = "ok"; } } }
if( defined $pass ){
if( !defined $foundref->{$u}{'matches'} ){ @{ $foundref->{$u}{'matches'} } = (); }if( defined $sr{'matches'} ){ push @{ $foundref->{$u}{'matches'} },values %{$sr{'matches'}}; }
if( !defined $foundref->{$u}{'result'} ){ @{ $foundref->{$u}{'result'} } = (); }if( defined $sr{'result'} ){ $sr{'result'} =~ s/(<emp>\-) (line [0-9]+)/$1: $2/g;push @{ $foundref->{$u}{'result'} },$sr{'result'}; }
if( !defined $foundref->{$u}{'old'} ){ @{ $foundref->{$u}{'old'} } = (); }if( defined $sr{'old'} ){ push @{ $foundref->{$u}{'old'} },$sr{'old'}; }
if( !defined $foundref->{$u}{'new'} ){ @{ $foundref->{$u}{'new'} } = (); }if( defined $sr{'new'} ){ push @{ $foundref->{$u}{'new'} },$sr{'new'}; }
if( !defined $foundref->{$u}{'total'} ){ $foundref->{$u}{'total'} = $tot; } else { $foundref->{$u}{'total'} = $foundref->{$u}{'total'}+$tot; } 
}
} else {
foreach my $ls( @ls ){
if( defined $h{$ls} ){
if( $ls eq "pages"){
my @p = @{ $h{'pages'} };
foreach my $p(@p){
my %pd = %{$p};
$dbug.= "checking pages: $pd{'url'}[0] == [ @ls ] \n";
sub_page_findreplace($p,$lsref,$foundref,$cref,$findref,$repref,$regex,$case,$where,undef,$inmenus);
}
} else {
my @hb = @{ $h{$ls} };
if( scalar @hb > 0){
for my $i(0..$#hb){  
my $c = 1+$i;
my %sr = ();
if( !defined $inmenus && $ls eq "blocks" &&$hb[$i] =~ /<ul\s*class="menu"/ ){
#$dbug.= "checking $ls: $hb[$i] contains menu"\n";
} else {
%sr = sub_search_string($hb[$i],$findref,$repref,$regex,$case,$ls,$cref,$where);
}
# $sr = {
# 'matches' => { '5' => '<div class="text" style="background-image: url(documents/Images/news/RSM__header_mobile.jpg);">&#160;</div> ' },
# 'result' => '<strong>Found <u>1</u> instance of <i>documents/Images/news/</i> in <u>editable text</u>: </strong><emp>- line 5: <i>&lt;div class=&quot;text&quot; style=&quot;background-image: url(<u>documents/Images/news/</u>RSM__header_mobile.jpg);&quot;&gt;&amp;#160;&lt;/div&gt; </i></emp>',
# 'old' => '<div class="row editblock"><div class="editimage"><div class="text" style="background-image: url(documents/Images/news/RSM__header_mobile.jpg);">&#160;</div></div></div>',
# 'new' => '<div class="row editblock"><div class="editimage"> <div class="text" style="background-image: url(RSM__header_mobile.jpg);">&#160;</div> </div></div>',
# 'totals' => [ 1,1 ]
# };
#$dbug.= "checking $ls: $hb[$i] == ".Data::Dumper->Dump([\%sr],["sr"])."\n";
my $pass = undef;
my $tot = 0;
if( defined $sr{'totals'} ){ my %tts = %{ $sr{'totals'} };foreach my $c( keys %tts ){ if( $tts{$c} > 0 ){ $tot = $tot+$tts{$c};$pass = "ok"; } } }
if( defined $pass ){
if( !defined $foundref->{$u}{'matches'} ){ @{ $foundref->{$u}{'matches'} } = (); }if( defined $sr{'matches'} ){ push @{ $foundref->{$u}{'matches'} },values %{$sr{'matches'}}; }
if( !defined $foundref->{$u}{'result'} ){ @{ $foundref->{$u}{'result'} } = (); }if( defined $sr{'result'} ){ if(defined $c{'user'}){$sr{'result'} =~ s/(<emp>\-) (line [0-9]+)/$1block $c: $2/g;}push @{ $foundref->{$u}{'result'} },$sr{'result'}; }
if( !defined $foundref->{$u}{'old'} ){ @{ $foundref->{$u}{'old'} } = (); }if( defined $sr{'old'} ){ push @{ $foundref->{$u}{'old'} },$sr{'old'}; }
if( !defined $foundref->{$u}{'new'} ){ @{ $foundref->{$u}{'new'} } = (); }if( defined $sr{'new'} ){ push @{ $foundref->{$u}{'new'} },$sr{'new'}; }
if( !defined $foundref->{$u}{'total'} ){ $foundref->{$u}{'total'} = $tot; } else { $foundref->{$u}{'total'} = $foundref->{$u}{'total'}+$tot; } 
}
#$dbug.= "checking $ls: $pass == ".Data::Dumper->Dump([$foundref],["foundref"])."\n\n".Data::Dumper->Dump([$sr{'matches'}],["sr matches"])."\n\n".Data::Dumper->Dump([$sr{'totals'}],["sr totals"])."\n";
}
}
}
}
}
}
}
###if($h{'url'}[0] =~ /Site-Map/){ 
###sub_json_out({ 'check page_findreplace out' => "u: $u \ndbug: $dbug \n\n".Data::Dumper->Dump([\%h],["h"])."\n\n".Data::Dumper->Dump([\@ls],["ls"])."\n\n".Data::Dumper->Dump([$foundref],["foundref"])."\n\nregex:$regex \ncase:$case \n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
###}
###if($h{'url'}[0] =~ /Test-PDF2-Poster-A3.pdf/){ 
###sub_json_out({ 'check page_findreplace out' => "u: $u \ndbug: $dbug \n\n".Data::Dumper->Dump([\%h],["h"])."\n\n".Data::Dumper->Dump([\@ls],["ls"])."\n\n".Data::Dumper->Dump([$foundref],["foundref"])."\n\nregex:$regex \ncase:$case \n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
###}
###if($h{'url'}[0] =~ /728-x-173px-RGB.jpg/){ #IBM-Solutions-Providers-2015 BOOM_
###sub_json_out({ 'check page_findreplace out' => "u: $u \ndbug: $dbug \n\n".Data::Dumper->Dump([\%h],["h"])."\n\n".Data::Dumper->Dump([\@ls],["ls"])."\n\n".Data::Dumper->Dump([$foundref],["foundref"])."\n\nregex:$regex \ncase:$case \ncode:$code \n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
###}
}

sub sub_page_out{
#<div class="editmodule view">
#<div class="text"><a data-id="index" data-amount="6" data-exclude="me" data-format="stacker" href="//www.rsmpartners.com/cgi-bin/newest/view.pl?url=News.html" title="view News">News</a></div>
#<div class="text"><a data-id="index" data-amount="3" data-format="slideshow" data-pass="transition:10,controller:1,delay:3000" href="//www.rsmpartners.com/cgi-bin/newest/view.pl?url=News.html" title="link to News">link to News</a></div>
#</div>
my ($f,$htm,$ty,$fil,$newsfilter,$cref) = @_;
my %c = %{$cref};
my $filter = (defined $fil)?$fil:"";
###sub_json_out({ 'check page_out 1' => "f:$f \nhtm:$htm \nty:$ty \nfilter:$filter \nnewsfilter:$newsfilter\n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
my ($ierr,$otxt) = sub_get_contents($f,$cref);
###sub_html_out("page_out alert: $htm<br /><br />$f <br /> $otxt <br /> $c{'debug'}");
sub_html_out("page_out alert: $ierr <br /><br />$f <br /> $otxt <br /> $c{'debug'}") if defined $ierr;
$otxt =~ s/(<body id="body0" class=")(.*?">)/$1tt_unjs $filter $2/i;
if( defined $ty && $ty eq "stacker"){
#<div class="text"><a data-id="index" data-sort="21" data-amount="9" data-format="stacker" data-position="lower" href="../cgi-bin/view.pl?url=News.html" title="view News">News</a></div>
#<div class="text"><a data-id="index" data-sort="21" data-amount="9" data-format="stacker" data-position="lower" data-filter="editarchive" href="../cgi-bin/view.pl?url=documents/Archive/News/2017/index.html" title="view News">News</a></div>
if( defined $newsfilter ){
$otxt =~ s/(<a.*?data-format="stacker")/$1$htm/im;
} else {
$otxt =~ s/(<ul class=".*?stackerarea.*?">\s*)(<li class="column">.*?<\/li>)(\s*<\/ul>)/$1$htm$3/ism;
}
} else {
$otxt =~ s/<div class="row editblock">\s*<div class="editmodule.*?">\s*<div class="text">\s*<a.*?>.*?<\/a>\s*<\/div>\s*<\/div>\s*<\/div>/$htm/i;
}
###sub_json_out({ 'check page_out 2' => "f:$f \nhtm:$htm \nty:$ty \nfilter:$filter \nnewsfilter:$newsfilter\n\notxt: \n\n$otxt \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
sub_html_out($otxt);
}

sub sub_page_print{
my ($fu,$otxt) = @_;
my $herr = undef;
if( -f $fu ){ 
my $hfile2 = gensym;
open($hfile2,">:utf8",$fu) or try { die "save_page: open file $fu failed: $!"; } catch { $herr = "save_page: open file $fu failed: $_ \n"; }; 
if( defined $hfile2 && !defined $herr ){
flock ($hfile2,2);
print $hfile2 $otxt;
close($hfile2);
}
} else { $herr = "save_page: $fu is not a file $! \n"; }
return $herr;
}

sub sub_page_replacemeta{
#<meta content="UA-58896111-1" name="gref" /><meta content="newest/index-&-etc.html" name="editlink" />
#%ls = {'editgroup' => 'Bizarre','editmenu' => '999.00','analytics_gref' => 'UA-58896111-1','copyright' => 'Copyright (c) that\\'sthat ltd 2017','author' => 'Dave Pilbeam','editurl' => 'Solutions_New-Page.html','og:image' => '//www.westfieldhealthdigitalresource.co.uk/LIB/home-page.jpg','edittext' => '','keywords' => 'z infrastructure, hardware, software, security, solutions, services, consultancy, staffing, support, delivery, audit, compliance, risk, vulnerability, remediation, penetration testing, migration, upgrades, hosting, disaster recovery, ISV','edittags' => '','editarea' => 'USA','editdate' => '27/02/2017','editfocus' => '','description' => 'RSM Partners is a global provider of mainframe services, software and expertise for IBM z systems, with a reputation for being flexible, reliable and agile.','editauthor' => 'Dave Pilbeam','editlink' => '//www.somewhere.co.uk','analytics_wref' => '49accf29-f990-4afc-8cb3-d248d186edf7','editshortname' => 'Newest' }
my ($ntxt,$cref,$findref,$repref,$regex,$case,$lref) = @_;
my %c = %{$cref};
my %ls = (defined $lref)?%{$lref}:(); #'editmenu' => 004.002000 || 003.001 || 002.000 || 001
my %meta = ();
my $new = "";
my $dbug = "";
my $nbug = "";
my $count = 0;
while( $ntxt =~ /(<meta.*?content=")(.*?)(".*?\/>)/gim ){ 
my $m = $1.$2.$3;
my $ov = $2;
my $k = ( $m =~ /(name|property)="(.*?)"/ )?$2:undef;
my $n = undef;
###$dbug.= " def: $k = $c{'defheaders'}{$k} \n";
if( !defined $c{'defheaders'}{$k} ){
if( scalar keys %ls > 0 ){
if( defined $ls{$k} ){ 
$n = ( $ls{$k} eq "" )?'':'<meta content="'.$ls{$k}.'" '.( ($k =~ /^og:/)?'property':'name' ).'="'.$k.'" />';delete $ls{$k}; 
}
} else {
my $nm = $m;
($nm,$count,$nbug) = sub_replace_string("meta",$nm,$findref,$repref,$regex,$case);#$dbug.= $nbug;
if( $count > 0 ){ $n = $nm; }
}
if( defined $k && defined $n ){ @{ $meta{$k} } = ( $m,$n ); }
}
}
###$dbug.= "\n\n".Data::Dumper->Dump([\%meta],["meta"])."\n\n".Data::Dumper->Dump([\%ls],["ls"])." \n\n";
foreach my $k( keys %meta ){
if( $meta{$k}->[0] ne $meta{$k}->[1] ){
($ntxt,$count,$nbug) = sub_replace_string("meta",$ntxt,[ $meta{$k}->[0] ],[ $meta{$k}->[1] ]);$dbug.= "<i class=\"ireplace\">Replaced ".encode_entities($meta{$k}->[0])." with ".encode_entities($meta{$k}->[1]).".</i>"; #$dbug.= $nbug;
}
}
foreach my $k( sort keys %ls ){ if( $ls{$k} ne "" ){ $new.= '<meta content="'.$ls{$k}.'" '.( ($k =~ /^og:/)?'property':'name' ).'="'.$k.'" />'."\n"; } }
if( $new ne "" ){ $ntxt =~ s/(<meta.*?name="editmenu".*?\/>)/$new$1/; }
###if( $ntxt =~ /<meta content="Privacy-Policy-&-Legal-Disclaimer.html" name="editlink" \/>/ ){
###sub_json_out({ 'check page_replacemeta' => "dbug: $dbug \n\n".Data::Dumper->Dump([\%meta],["meta"])."\n\n ntxt:\n $ntxt \n\n regex:$regex \ncase:$case \n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
###}
return ($ntxt,$dbug);
}

sub sub_page_reshare{
# <div id="tt_sharewrapper">
#		<input id="sharebox0" class="sharer" type="checkbox" />
#			<div class="editmodule share css-move5">
#				<div class="text shared linkedinbutton"><a href="https://www.linkedin.com/shareArticle?mini=true&url=https%3A%2F%2Frevive.pecreative.co.uk%2F&title=Title%20Goes%20Here&summary=&source=" title="Share on Linkedin" target="_blank">&#160;</a></div>
#				<div class="text shared twitterbutton"><a href="https://twitter.com/home?status=http%3A//www.rsmpartners.com"  title="Share on Twitter" target="_blank">&#160;</a></div>
#				<div class="text shared facebookbutton"><a href="https://www.facebook.com/sharer/sharer.php?u=http%3A//www.rsmpartners.com" title="Share on facebook" target="_blank">&#160;</a></div>
#				<div class="text shared googlebutton"><a href="https://plus.google.com/share?url=http%3A//www.rsmpartners.com" title="Share on Google+" target="_blank">&#160;</a></div>
#			</div>
#		<label for="sharebox0" class="sharebutton nonselect" title="Share">&#160;<span class="shareboxicon"></span></label>
#	</div>
#
#stitle:Default%20Page 
#share: rep:<div class=\"text shared twitterbutton\"><a href=\"https://twitter.com/intent/tweet?url=https%3A%2F%2Frevive.pecreative.co.uk%2FDefault-Page-Template.html&via=DenmaurPapers\" title=\"Share on Twitter\" target=\"_blank\">&#160;</a></div> 
#surl: https://bigtest.co.uk/Paper_Products_Revive_Revive-100-Silk.html 
my ($txt,$lref,$surl,$stitle,$cref,$zip) = @_;
my %slist = %{$lref};
my %c = %{$cref};
my $in = $surl;
if( defined $zip){ #https://bigtest.co.uk/Paper_Products_Revive_Revive-100-Silk.html
$surl = $uri->encode($zip.$surl);
} else {
if( $surl =~ /^\/\/.*?\// ){ $surl =~ s/^(\/\/.*?\/)//; } else { $surl =~ s/^($c{'baseview'})//; }
if(!defined $surl){$surl = "";} 
$surl = $uri->encode($c{'baseview'}.$surl);
}
$stitle = $uri->encode($stitle);
my $dbug = "shares $in: \nstitle:$stitle \nsurl:$surl \n";
for my $k( keys %slist ){
my $rep = "";
if( $txt =~ /(<div class="text shared $k">).*?(<\/div>)/ ){ $rep.= $1.@{$slist{$k}}[0].$surl.@{$slist{$k}}[1];if( scalar @{$slist{$k}} > 2 ){ $rep.= $stitle.@{$slist{$k}}[2]; }$rep.= '</div>'; }
$txt =~ s/(<div class="text shared $k">).*?(<\/div>)/$rep/ism;
if($rep ne ""){$dbug.= "$k = $rep\n";}
}
###sub_json_out({ 'check page_reshare' => "dbug: $dbug \n\n txt:\n $txt \n\n surl:$surl \n stitle:$stitle \n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
return ($txt,$dbug);
}

sub sub_page_retitle{
my ($otxt,$newh1,$tsep) = @_;
my $nwtitle = "";
my $nwedit = "";
my $p0 = "";
my $p1 = "";
my $oldh1 = "";
my $p2 = "";
my $p3 = "";
my $oldtitle = "";
my $dbug = "";
$newh1  =~ s/\&/&#38;/g;
if( $otxt =~ /(<h1>\s*)(<.*?>)*(.*?)(\s*<\/h1>)/ism ){ #<h1>Caribbean Fish Sanctuary Partnership (C-FISH)</h1>
$p0 = $1;
$p1 = $2;
$oldh1 = $3; $oldtitle = $oldh1;
$p3 = $4;
} 
if( $oldh1 =~ s/(<\/.*?>)$//ism ){ $p2 = $1;$oldtitle =~ s/($p2)$//; }
$otxt =~ s/(<h1>\s*)(<.*?>)*(.*?)(<\/h1>)/$1$2$newh1$p2$4/ism;
if( $otxt =~ /(<title>).*?(<\/title>)/ ){ #Title Text - RSM Partners
$otxt =~ s/(<title>).*?(<\/title>)/$1$newh1 $tsep$2/i
}
$dbug.= "page_retitle: \n $dbug \n\np0 = $p0 \np1 = $p1 \np2 = $p2 \np3 = $p3 \n\n$oldh1 becomes $newh1 \n$oldtitle becomes $newh1 $tsep \n";
return ($otxt,$dbug);
}

sub sub_page_return{
#'data' => {
#'area' => [ 'Services' ],
#'blocks' => [ '\t\t\t\t\t\t<div class="row editblock pulled">\n<div class="edittitle"> <div class="text"><h1>Government dept chooses RSM for Mainframe Managed Service</h1></div> </div> <div class="editimage"> <div class="text" style="background-image: url(documents/Images/news/GovernmentOffice_header.jpg);">&#160;</div> </div> <div class="edittext"> <div class="text"><p>19th September 2016: Like many others, a UK central government department was concerned about staffing continuity in support of their mainframe infrastructure.</p><p>For more information, please email <a class="editlinkinline" title="email us" href="mailto:info@rsmpartners.com">info@rsmpartners.com</a></p> <p></p> </div> </div></div>' ],
#'date' => [ '13/09/16' ],
#'epoch' => [ 1475751954 ],
#'focus' => [ 'Digital Outcomes' ],
#'issues' => [ 'Page will not be editable until permissions are changed to 664' ],
#'link' => [ 'newest/News_Gov-dept-chooses-RSM-Mainframe-Managed-Service.html' ],
#'menu' => [ '002.002012' ],
#'menuname' => [ 'Gov dept chooses RSM Mainframe Managed Service' ],
#'path' => [ '/var/www/vhosts/pecreative.co.uk/rsmpartners.com/newest/News','Gov-dept-chooses-RSM-Mainframe-Managed-Service' ],
# 'pages' => [ 
# [ { 'epoch' => 1475591807, 'published' => '04/10/2016', 'url' => 'newest/News_RSM-Awarded-Government-Supplier-Status.html', 'title' => 'News', 'size' => '17k'  } ], 
# [ { 'epoch' => 1475595723, 'published' => '04/10/2016', 'url' => 'newest/News_Gov-dept-chooses-RSM-Mainframe-Managed-Service.html', 'blocks' => [ '<div class=\"row editblock pulled\">...</div>' ], 'size' => '17k', 'title' => 'News' } ] 
#],
#'parent' => [ '/var/www/vhosts/pecreative.co.uk/rsmpartners.com/newest/News.html' ],
#'published' => [ '06/10/2016' ],
#'title' => [ 'Government dept chooses RSM for Mainframe Managed Service' ],
#'shortname' => [ 'Gov dept chooses RSM' ],
#'size' => [ '16k' ],
#'url' => [ 'newest/News_Gov-dept-chooses-RSM-Mainframe-Managed-Service.html' ]
# 'menutext' => [ '' ],
# sitemaptext => [ '' ],
# code => [ 'html' ]
#},
my ($ins,$fref,$cref,$nameref,$valueref,$start,$amount,$ex,$random,$menuref,$inmenus,$showall,$code,$inlistdir,$siteref) = @_;
my %h = (defined $menuref)?%{ $menuref }:();
my %c = %{ $cref };
my $soff = $c{'submenus'} || "off";
my %editareas = %{ $c{'editareas'} };
my %chek = ();
my %cadd = ();
my @fs = @{$fref};
my $f = shift @fs;
my @csite = (defined $siteref)?@{$siteref}:();
my @ct = ();
my %jout = ();
my @mout = ();
my @out = ();
my @els = ();
my @editnames = ( defined $nameref )?@{$nameref}:();
my @editvalues = ( defined $valueref )?@{$valueref}:();
my $spaces = ($ins eq "searchpages")?"spaces":undef;
my $pulled = ( $c{'format'} eq "updatemenu" )?"":" pulled";
my $over = ($f =~  /($c{'docview'}$c{'resourcefolder'})\//)?1:undef;
my $otxt = "";
my $ntxt = "";
my $dbug = "";
my $group = "";
my $archive = undef;
my $ctref = undef;
my $filtered = undef;
my $err = undef;
#if( $ins eq "menureorder" ){ #if( $c{'format'} eq "updatemenu" ){
###sub_json_out({'check page_return' => "ins: $ins \nf:$f \nfs:[ @fs ] \ninlistdir:$inlistdir \n\nct: [ @ct ] \nover:$over \ncode:$code \n\n".Data::Dumper->Dump([\@csite],["csite"])." \n\n".Data::Dumper->Dump([\%h],["h"])."\n\n".Data::Dumper->Dump([\@editnames],["editnames"])."\n\n".Data::Dumper->Dump([\@editvalues],["editvalues"])."\n\n".Data::Dumper->Dump([$c{'editareas'}],["editareas"])."\n\nsitepage:$c{'sitepage'} \nsitefile:$c{'site_file'} \n\n$c{'debug'} " },$c{'origin'},$c{'callback'});
#}
if( $ins =~ /^view/ || $ins eq "menureorder" || $ins eq "searchpages" || $ins eq "pagelist" || $ins eq "editpages" || $ins eq "index" || $ins =~ /^archive/ || $ins eq "paginate" || $ins eq "all" || $ins eq "list" || $ins eq "menu" ){
if( $ins eq "editpages" ){ 
@ct = ( $f );
} else {
if( $ins eq "archive" || $ins eq "archivebase" || $ins eq "archivelist" ){ 
$f =~ s/index\.($c{'htmlext'})$//i;
} elsif( defined $c{'filter'} ){
if( $ins eq "menu" || $f =~ /.+\/(.*?)\/index\.($c{'htmlext'})$/ ){
$archive = $c{'filter'};$archive =~ s/^edit//i;$group = $editvalues[0];if($group ne ""){$editnames[0] = $archive;} else { if($f !~ /($c{'docview'})Archive\//i){$filtered = $archive;} }$f =~ s/index\.($c{'htmlext'})$//i;
}
#} elsif( $f =~ /.+\/(.*?)\/index\.($c{'htmlext'})$/ && defined $c{'filter'} ){ 
#$archive = $c{'filter'};$archive =~ s/^edit//i;$group = $editvalues[0];if($group ne ""){$editnames[0] = $archive;}$f =~ s/index\.($c{'htmlext'})$//i; 
} else { 
if( defined $c{'sitepage'} && $c{'sitepage'} =~ /($c{'site_file'})$/ ){ $f = $c{'base'}; } 
}

###sub_json_out({'check page_return 0' => "ins: $ins \nf:$f \nsiteref:$siteref \nfs = [ \n".( join "\n",@fs )."\n] \n\n".Data::Dumper->Dump([$fref],["fref"])."\n\n$c{'debug'} " },$c{'origin'},$c{'callback'});
if(defined $siteref){
for my $i(0..$#csite){ my %tmp = %{$csite[$i]};push @ct,$tmp{'url'}[0];$cadd{ $tmp{'url'}[0] } = $csite[$i]; }
} else {
my ($cterr,$csref) = sub_get_source($f,$ins,$cref,$inlistdir,\@fs,$over);if( defined $cterr ){ return ($cterr,\%jout); } else { $ctref = $csref;@ct = @{$csref}; }
}

@ct = ($c{'pagesort'} eq "za")?reverse sort @ct:sort @ct;
if( $ins eq "" || $ins eq "paginate" || $ins eq "all" ){ %jout = sub_return_documents($ins,$f,$ctref,$cref);return ($err,\%jout); }
if( $ins eq "viewaux" ){ push @ct,sub_get_html($c{'base'},$cref,undef,$c{'auxfiles'},"auxonly"); }
}
###sub_json_out({'check page_return 1' => "ins: $ins \nf:$f \narchive:$archive \nfilter:$c{'filter'} \nstart:$start \namount:$amount \n\n ct = [ \n".( join "\n",@ct )."\n] \n\n sort = $c{'pagesort'} \neditvalues = [ @editvalues ]\n\n".Data::Dumper->Dump([\%jout],["jout"])."\n\n$c{'debug'} " },$c{'origin'},$c{'callback'});
return ("alert page_return: no useable data retrievable by server: ins:$ins \nf:$f \n$c{'debug'}",\%jout) unless $ct[0] ne "";
#/var/www/vhosts/pecreative.co.uk/onlinederby.co.uk/documents/Archive/News/index.html
#/var/www/vhosts/pecreative.co.uk/rsmpartners.com/Services_Skills-&-Resources.html
#/var/www/vhosts/pecreative.co.uk/rsmpartners.com/newest/Site-Map.html
#/var/www/vhosts/pecreative.co.uk/rsmpartners.com/ie-icon-150x150.png

if( $ins eq "archivebase" ){
$ntxt = "<div class=\"editmodule view\">\n<div class=\"text\" style=\"min-height:30px;\">\n<ul class=\"menu pulled\">\n";
for my $i(0..$#ct){ 
$ct[$i] =~ s/^($c{'base'})//;my $d = $ct[$i];
if( $d =~ /($c{'htmlext'})$/ ){
$d = sub_title_out($d,$cref);if($d ne "index"){ $ntxt.= "<li class=\"submenu\"><a href=\"$ct[$i]\" title=\"link to Archive Page\">$d</a></li>\n"; }
} else { 
my $ok = ( !defined $ex || $d =~ /($c{'docview'})Archive\/.*?\/.*?$/i )?1:undef;
if(defined $ok){ $d =~ s/^(.+\/)//;$ntxt.= "<li><a href=\"$ct[$i]\" title=\"link to $d Archive\">$d</a></li>\n"; }
}
}
$ntxt.= "</ul>\n</div>\n</div>";
%jout = ('result' => $ntxt);
return ($err,\%jout);
} elsif( $ins =~ /^view/ || $ins eq "menureorder" || $ins eq "searchpages" || $ins eq "pagelist" || $ins eq "editpages" || $ins eq "menu" || $ins eq "archive" || $ins eq "index" || $ins eq "list" || $ins eq "archivelist" ){

my $t = 0;
for my $i(0..$#ct){ 
my $ck = $ct[$i];$ck =~ s/^($c{'base'})//;
my $tmp = $ck;$tmp =~ s/\.($c{'htmlext'})$//; ##==pilbeam
if( $tmp =~ /$c{'qqdelim'}/ ){ my $tc = $tmp;$tc =~ s/^(.+)$c{'qqdelim'}.*?$/$1/;$tc.= ".$c{'htmlext'}";if( !defined $chek{$tc} ){ @{ $chek{$tc} } = (); }push @{ $chek{$tc} },$ck; } 
if($ct[$i] =~ /index\.($c{'htmlext'})$/){ $t++; }
}
###sub_json_out({'check page_return 2' => "ins:$ins \ncode:$code \nt:$t == ct:".(scalar @ct)."\n\ndbug: $dbug \n\n $c{'debug'} " },$c{'origin'},$c{'callback'});

for my $i(0..$#ct){
my %add = ();
my %data = ();
my $itxt = "";
my $cf = $ct[$i];$cf =~ s/^($c{'base'})//;
if( $ct[$i] =~ /\.(css|js)$/ && $ct[$i] !~ /(config|min)\.js$/ ){
my ($ierr,$itxt) = sub_get_contents($c{'base'}.$cf,$cref,"text");return ("page_return alert 1: $ierr $itxt $c{'debug'}",\%jout) if defined $ierr;
%add =  %{ sub_get_data($ct[$i],$cref) };@{ $add{'blocks'} } = ();push @{ $add{'blocks'} },$itxt;push @mout,{'data' => \%add};
} elsif( $ct[$i] =~ /\.($c{'htmlext'})$/){

if( !defined $siteref ){
my ($ierr,$itex) = sub_get_contents($c{'base'}.$cf,$cref,"text");$itxt = $itex;return ("page_return alert 1: $ierr $itxt $c{'debug'}",\%jout) if defined $ierr;%{ $add{'shares'} } = %{ sub_parse_shares($itex,$cref) };
}

if( defined $code ){ 
%add = %{ sub_get_data($ct[$i],$cref) };@{ $add{'code'} } = ();push @{ $add{'code'} },$itxt;push @mout,\%add;
} else {

my $fnd = ($ins eq "index")?[]:\@editnames;
my $ser = ($ins eq "index")?[]:\@editvalues;
my $ok = undef;

if(defined $siteref){

%add = %{ $cadd{$ct[$i]} };$ok = 1;

} else {

###==
my $editref = sub_parse_meta($itxt,\%editareas,$cref);
my @blocks = sub_parse_blocks($itxt,$fnd,$ser,$cref);
my $menutextref = {};if(defined $inmenus){ $menutextref = sub_parse_menutext($itxt,$cref); }
##if( $ct[$i] =~ /good-enough-for-Denzel\.html/ ){ 
##sub_json_out({ 'check page_return 3' => "$ct[$i] = \n".Data::Dumper->Dump([ sub_get_data($ct[$i],$cref) ],["data"])."\n\n".Data::Dumper->Dump([$editref],["editref"])."\n\n".( join "\n--\n",@blocks )."\n\n inmenus:".$inmenus."\n\n".Data::Dumper->Dump([$menutextref],["menutextref"])." " },$c{'origin'},$c{'callback'}); 
##}
%add = %{ sub_merge_hash( \%add,sub_get_data($ct[$i],$cref),$editref,$menutextref ) };
if( defined $chek{$cf} ){ @{ $add{'children'} } = @{ $chek{$cf} }; }
if( defined $add{'date'} ){ @{ $add{'published'} } = @{ $add{'date'} };@{ $add{'epoch'} } = ( sub_epoch_date( @{ $add{'date'} }[0] ) ); }
if( defined $archive && !defined $filtered ){ # ARCHIVE/2018/Group_News_The-local-circular-economy.html ARCHIVE/2018/index.html
my $ap = $add{'url'}[0];if( $add{'link'}[0] =~ /\/index\.($c{'htmlext'})$/ ){ $ap =~ s/\.($c{'htmlext'})$//;$add{'path'} = [$ap]; } else { $ap =~ s/\.($c{'htmlext'})$//;if( $ap =~ /^(.+)$c{'qqdelim'}(.*?)$/ ){ $add{'path'} = [$1,$2.".".$c{'htmlext'}]; } }
}
#sub_json_out({ 'check page_return 4' => "$ct[$i] = \n".Data::Dumper->Dump([\%add],["add"])."\n\n" },$c{'origin'},$c{'callback'}); 

if( scalar @blocks > 0 ){ 
@{ $add{'blocks'} } = ();
for my $j( 0..$#blocks ){ 
my $bok = undef;
$blocks[$j] =~ s/'/&#39;/g; #'
if( $ins ne "searchpages" && $ins ne "editpages" && $blocks[$j] =~ /<h1.*?>(.*?)<\/h1>/ ){ $bok = 1;$blocks[$j] =~ s/<h1.*?>(.*?)<\/h1>/<span>$1<\/span>/g; }
if( $ins ne "searchpages" && $ins ne "editpages"){ $blocks[$j] =~ s/^\s*(<div.*?class=".*?)">/$1 pulled">/; } #"
if( $ins =~ /^(searchpages|editpages|blocks|viewaux|viewsearchall)$/ || defined $bok ){ 
if( defined $c{'pagefull'} && $c{'pagefull'} < 1 ){
$blocks[$j] =~ s/\t//g;
$blocks[$j] =~ s/\s*<\/div>\s*$//;
$blocks[$j] =~ s/^(\s*<div class="row.*?pulled">)\s*<div//;
my $hd = $1;
$dbug.= "START $blocks[$j] \n\n";
my @divs = split /<\/div>\s*<\/div>\s*<div/,$blocks[$j];
my $imgs = 0;
my $texts = 0;
my $dtxt = "";
for my $i(0..$#divs){
my $oky = 1;
if( $divs[$i] =~ /^\s*class="editimage/ ){ #"
$imgs++;if($imgs > 1){ $oky = undef; }$dbug.= "\nIMAGE $i = $divs[$i]\n";
} elsif( $divs[$i] =~ /^\s*class="edittext/ ){ #"
$texts++;if($texts > 1){ $oky = undef; }$dbug.= "\nTEXT $i = $divs[$i]\n";
} else {
$dbug.= "\nOTHER $i = $divs[$i]\n";
}
if( defined $oky ){
if( $divs[$i] !~ /^<div/){ $dtxt.= "\n<div"; }
$dtxt.= $divs[$i];
if( $divs[$i] !~ /\s*<\/div>\s*<\/div>\s*$/ ){ $dtxt.= "</div>\n</div>\n"; }
}
}
$dtxt = $hd.$dtxt."\n\n</div>\n";
$dbug.= "\n\ndtxt = $dtxt \n\n";
push @{ $add{'blocks'} },$dtxt;
} else {
push @{ $add{'blocks'} },$blocks[$j];
}
}
$bok = undef;
}
}

if( $cf ne $add{'url'}[0] ){ if( !defined $add{'issues'} ){ @{ $add{'issues'} } = (); }$add{'htmlname'} = [ $cf ];push @{ $add{'issues'} },"URL Tag <u class=\"old\">$add{'url'}[0]</u> is wrong - should be <u class=\"new\">$cf</u>"; }
if( $add{'menu'}[0] == 000 && $add{'url'}[0] ne "index\.$c{'htmlext'}" ){ $add{'menu'}[0] = 990; }
# https%3A%2F%2Frevive.pecreative.co.uk%2FPaper_Products_Packaging-Board.html&via=DenmaurPapers == Paper_Products_Packaging-Board.html
if( defined $add{'shares'} ){ my $nu = $uri->encode($c{'baseview'}.$cf);foreach my $k( sort keys %{$add{'shares'}} ){ if( $add{'shares'}{$k} !~ /($nu)/ ){ if( !defined $add{'issues'} ){ @{ $add{'issues'} } = (); }$add{'sharename'} = [ $nu." is actually ".$add{'shares'}{$k} ];push @{ $add{'issues'} },"Share URL <u class=\"old\">$add{'shares'}{$k}</u> is wrong - should be <u class=\"new\">$nu</u>"; } } }
##if( $ct[$i] =~ /Paper_Products_Packaging-Board.html/ ){ 
##sub_json_out({ 'check page_return 5' => "$ins \n$ct[$i] \ncf:$cf \nblocks:".scalar @blocks." \n\n $dbug \n\n".Data::Dumper->Dump([\%chek],["chek"])."\n\n".Data::Dumper->Dump([\%add],["add"])."\n\n itxt: \n $itxt " },$c{'origin'},$c{'callback'}); 
##}
if( $ins ne "editpages" ){
if( defined $add{'children'} && scalar @{$add{'children'}} > 0 ){ 
if( defined $add{'menu'}[0] && $add{'menu'}[0] !~ /^000/ && $add{'menu'}[0] !~ /\.*000/ ){ $add{'menu'}[0] =~ s/([0-9][0-9][0-9])\.*([0-9][0-9][0-9])*(\.0|\.00)*$/$1.${2}000$3/;$dbug.= "has subpages = add 000\n"; }
} else {
if( defined $add{'menu'}[0] && $add{'menu'}[0] !~ /^000/ && $add{'menu'}[0] =~ /\.*000/ ){ $add{'menu'}[0] =~ s/\.*000//;$dbug.= "has no subpages = remove 000\n"; }
}
}

if( $ins ne "archivelist" && scalar @editnames > 0){ 
for my $k(0..$#editnames){ my $ed = $editnames[$k];$ed =~ s/^edit//i;if( defined $editvalues[$k] && defined $add{$ed} && scalar @{ $add{$ed} } > 0 && @{ $add{$ed} }[0] =~ /$editvalues[$k]/i ){ $ok = 1; } }
} else {
$ok = 1;
}
###==

}

# '003.002' => [ '003.003' ],'002.004.0' => [ '002.004.0' ],'005' => [ '003.001','Modules.html','Solutions_Modules.html' ],
if( $ins eq "menureorder" && defined $add{'menu'} ){
my $na = $add{'menu'}[0];$na =~ s/\.(0|00)$//; #999.00 | 999.0 | 999 | 999.000 | 999.001.00 | 999.001000 | 999.001001.00
my @nm = ( defined $h{$na} )?@{ $h{$na} }:( defined $h{$na.".00"} )?@{ $h{$na.".00"} }:( defined $h{$na.".0"} )?@{ $h{$na.".0"} }:();
##if( $add{'menu'}[0] =~ /003.000/ ){ 
##sub_json_out({ 'check page_return 6' => "$ins: \n\n h{ ".$na." or ".$na.".00 or ".$na.".0 } \n\n".Data::Dumper->Dump([\%h],["h"])."\n\n".Data::Dumper->Dump([\%add],["add"])."\n\n $dbug \n\n" },$c{'origin'},$c{'callback'});
##}
if( scalar @nm > 0 ){ 
$add{'menu'}[0] = $nm[0];$dbug.= @{$add{'menu'}}[0]." changed to ".$nm[0]."\n";
if( defined $add{'url'} && defined $nm[1] && $add{'url'}[0] eq $nm[1] ){ $add{'url'}[0] = $nm[2];$dbug.= $add{'url'}[0]." changed to ".$nm[2]."\n"; }
##if( $add{'menu'}[0] =~ /003.000/ ){ 
##sub_json_out({ 'check page_return 7' => "meta: ins:$ins = url:$add{'url'}[0] = menu:$add{'menu'}[0] = nm:@nm \n\n $dbug \n\n" },$c{'origin'},$c{'callback'});
##}
}
}
##if( $add{'menu'}[0] =~ /002.000/ ){ 
##sub_json_out({ 'check page_return 8' => "$ins: ok:$ok \n editnames: [ @editnames ] \neditvalues: [ @editvalues ] add: @{$add{'menu'}}[0] \n\n".Data::Dumper->Dump([\%h],["h"])."\n\n".Data::Dumper->Dump([\%add],["add"])."\n\n $dbug \n\n" },$c{'origin'},$c{'callback'}); 
##}

if( defined $ok ){ 
%{ $data{'data'} } = %add;
if( $ins =~ /^(index|list|menu|all)$/ && @{$add{'menu'}}[0] =~ /\.00$/ && $soff ne "on" ){
$c{'debug'}.= "hide @{$add{'menu'}}[0] \n\n";
} else {
push @mout,\%data;$c{'debug'}.= "add @{$add{'menu'}}[0] \n\n"; 
}
}

}
}
}
}
###sub_json_out({'check page_return 9' => "ins:$ins \narchive:$archive \nfiltered:$filtered \nsoff:$soff [$c{'submenus'}] \n\n".Data::Dumper->Dump([\@mout],["mout"])." \n\neditvalues = [ @editvalues ]\n\ndbug: $dbug \n\n $c{'debug'} " },$c{'origin'},$c{'callback'});

if( $ins eq "viewaux" || $ins eq "pagelist" || $ins eq "editpages" || defined $code || $ins eq "menureorder" ){
###sub_json_out({'check page_return 10' => "ins: $ins \n\n".Data::Dumper->Dump([\@mout],["mout"])."\n\n \n\n [ @ct ] $c{'debug'} " },$c{'origin'},$c{'callback'});
return ($err,\@mout);
} elsif( $ins =~ /^view/ || $ins eq "searchpages" || ($ins eq "index" && defined $archive) || ($ins eq "menu" && defined $c{'sitepage'}) ){ 
if( defined $archive ){ my @aout = ();for my $i(0..$#mout){ if( $ins eq "menu" && $group eq "" ){push @aout,$mout[$i];} else {if( defined $mout[$i]{'data'}{$archive} && lc $mout[$i]{'data'}{$archive}[0] eq lc $group ){ push @aout,$mout[$i]; }} }@mout = @aout; }
###sub_json_out({'check page_return 11' => "ins: $ins \narchive:$archive \ngroup:$group \n\n".Data::Dumper->Dump([\@mout],["mout"])."\n\n \n\n [ @ct ] $c{'debug'} " },$c{'origin'},$c{'callback'});
if( $ins eq "index" || ($ins eq "menu" && defined $filtered) ){
@els = sub_return_pages($ins,$f,\@mout,$cref,\@editnames,\@editvalues,$ex);
} else {
my ($merr,$mmsg) = sub_return_menus($ins,$f,\@mout,$cref,$pulled,$showall);
if( $ins eq "menu" ){ my %mref = ( 'result' => $mmsg );$mmsg = \%mref; }
###sub_json_out({'check page_return 12' => "ins: $ins \n\nsiteref:$siteref \n\n".Data::Dumper->Dump([$mmsg],["mmsg"])."\n\n".Data::Dumper->Dump([\@mout],["mout"])."\n\n \n\n [ @ct ] $c{'debug'} " },$c{'origin'},$c{'callback'});
return ($merr,$mmsg,\@mout);
}
} else {
###sub_json_out({'check page_return 13' => "ins: $ins \narchive:$archive \ngroup:$group \n\n".Data::Dumper->Dump([\@mout],["mout"])."\n\n \n\n [ @ct ] $c{'debug'} " },$c{'origin'},$c{'callback'});
if( defined $c{'pulledlink'} && $ins eq "index" && scalar @editnames > 0 && $editnames[0] eq "editarchive" ){
return ($err,{'result' => " data-names=\"editarchive\" data-values=\"$editvalues[0]\"",'type' => 'newsfilter'});
} else {
@els = sub_return_pages($ins,$f,\@mout,$cref,\@editnames,\@editvalues,$ex);
}
}
} elsif( $ins eq "blocks" || $ins eq "area" ){
###sub_json_out({'check page_return 14' => "ins:$ins \n\nf:$f \n\n editnames: [ @editnames ] \neditvalues:[ @editvalues ]) \n\n$dbug \n\n $c{'debug'} " },$c{'origin'},$c{'callback'});
my ($berr,$bref) = sub_return_blocks($f,$cref,\@editnames,\@editvalues,$amount,$random,"ispull");
$err = (defined $err)?$err.$berr:$berr if defined $berr;
@els = @{$bref};
} elsif( $ins eq "filelist" ){
my ($cterr,$ctref) = sub_get_source($f,$ins,$cref);
if( defined $cterr ){ return ($cterr,\%jout); }
my ($ferr,$fref) = sub_return_files($f,$ctref,$cref,$amount,$random);
###sub_json_out({'check page_return 15' => "ins: $ins \n\nferr: $ferr \n\n".Data::Dumper->Dump([$fref],["fref"])."\n\n \n\n $c{'debug'} " },$c{'origin'},$c{'callback'});
$err = (defined $err)?$err.$ferr:$ferr if defined $ferr;
@els = @{$fref};
} elsif( $ins eq "images" ){
my ($imerr,$imref) = sub_return_images($f,$cref,$ntxt,$amount,$random);
###sub_json_out({'check page_return 16' => "ins: $ins \n\nimerr: $imerr \n\n".Data::Dumper->Dump([$imref],["imref"])."\n\n \n\n $c{'debug'} " },$c{'origin'},$c{'callback'});
$err = (defined $err)?$err.$imerr:$imerr if defined $imerr;
@els = @{$imref};
} else {
$err = "alert: unknown ins: $ins: $! ";
}
###sub_json_out({'check page_return 17' => "ins: $ins n\n".Data::Dumper->Dump([\@els],["els"])."\n\n $c{'debug'} " },$c{'origin'},$c{'callback'});
sub_return_pagedata($ins,$f,\@els,$ntxt,$amount,$start,$random,$err,$cref);
}

sub sub_page_rewrite{ 
my ($ins,$u,$dref,$cref,$findref,$repref,$regex,$case) = @_;  #{ 'blocks' => 1,'meta' => 1,'tags' => 1,'title' => 1,'code' => 1,'new' => 'newhtml' } 
my %dest = %{ $dref };
my %c = %{$cref};
my %info = ( 'found' => 0,'updated' => 'no' );
my @terms = (defined $findref)?@{$findref}:();
my @reps = (defined $repref)?@{$repref}:();
my %blocks = {};
my %heads = {};
my %eds = {};
my $ntxt = "";
my $dbug = "u: $u \n";
my $nbug = "";
my $count = 0;
my $msg = "";
my $err = undef;
if(-f $u){ 
my ($ierr,$otxt) = sub_get_contents($u,$cref,"text");
if( !defined $ierr ){ 
$ntxt = $otxt;
###if($u =~ /Site-Map/){
###sub_json_out({ 'check page_rewrite' => " $dbug \n\nnew:".( $dest{'new'}->[0] )."\nmeta:".( defined $dest{'meta'} )." \ntitle:".( defined $dest{'title'} )." \nblocks:".( defined $dest{'blocks'} )." \n$u exists: ".( -f $u )." \nins: $ins \nu:$u \nterms: [ @terms ] \n reps: [ @reps ] \n regex:$regex \ncase: $case \notxt:$otxt" },$c{'origin'},$c{'callback'});
###}

if( defined $dest{'new'} ){
$ntxt = @{ $dest{'new'} }[0];
} elsif( defined $dest{'code'} ){
($ntxt,$count,$nbug) = sub_replace_string("base",$ntxt,$findref,$repref,$regex,$case);
$dbug.= "found $count".($ins eq "alter")?"\n":" = $nbug \n";
$info{'found'} = $count;
if( defined $c{'sharelist'} ){ 
# u = /var/www/vhosts/pecreative.co.uk/dev.pecreative.co.uk/Group_Sustainability.html   /var/www/vhosts/pecreative.co.uk/dev.pecreative.co.uk/documents/Archive/Group-News/2017/Group_News_The-local-circular-economy.html 
my $us = $u;$us =~ s/^($c{'base'})//; # Group_Sustainability.html  documents/Archive/Group-News/2017/Group_News_The-local-circular-economy.html
my $ur = $reps[0];$ur =~ s/(\/+)$//; # Group_Sustainability_Act-On-CO2-at-DenmaurWRONG.html 
if( -f $u ){ $ur = $us; } else { if($ur ne $us){$ur.= '/'.$us;} } #https%3A%2F%2Frevive.pecreative.co.uk%2Fhttps%3A%2F%2Ftest.co.uk%2F
my $ut = "";if( $ntxt =~ /(<h1>\s*)(<.*?>)*(.*?)(\s*<\/h1>)/ism ){ $ut = $3; }
###sub_json_out({ 'check page_rewrite 1' => "u:$u \nur:$ur \nut:$ut nbug:$nbug " },$c{'origin'},$c{'callback'});
($ntxt,$nbug) = sub_page_reshare($ntxt,$c{'sharelist'},$ur,$ut,$cref);
if($ins eq "alter"){$dbug.= "$nbug \n";}
}
###if($u =~ /Site-Map/){
###sub_json_out({ 'check page_rewrite 1' => " $dbug \n\nnew:".( defined $dest{'new'} )."\nmeta:".( defined $dest{'meta'} )."\ntitle:".( defined $dest{'title'} )."\nblocks:".( defined $dest{'blocks'} )."\nu:$u \nins:$ins \nterms: [ @terms ] \nreps: [ @reps ] \nregex:$regex \ncase: $case \n\nntxt:$ntxt" },$c{'origin'},$c{'callback'});
###}
} else {
if( defined $dest{'meta'} || defined $dest{'tags'} ){ my $rbug = "";($ntxt,$rbug) = sub_page_replacemeta($ntxt,$cref,$findref,$repref,$regex,$case);$dbug.= $rbug; }
if( defined $dest{'title'} && $ntxt =~ /(<h1>\s*)(<.*?>)*(.*?)(\s*<\/h1>)/ism ){ #<div class="edittitle"><div class="text"><h1>RSM assists government agency zCloud transition</h1></div></div>
my $t = $3;
($t,$count,$nbug) = sub_replace_string("title",$t,$findref,$repref,$regex,$case);
###$dbug.= $nbug;
if( $count > 0 ){
$info{'retitled'} = 'ok';
($ntxt,$nbug) = sub_page_retitle($ntxt,$t,"@{$c{'titlesep'}}");
$dbug.= $nbug;
}
}
if( defined $dest{'blocks'} ){
my %bs = ();
my $c = 0;
while( $ntxt =~ /<ul class="area editablearea(.*?)"(\s*data-.*?=".*?"\s*)*>\s*<li class="column(\s*tt_.*?\s*)*"(\s*data-.*?=".*?"\s*)*>(.*?)<\/li>\s*<\/ul>(?!\s*(<\/fieldset>|<ul class="ful">))/gism ){
$bs{$c}{'old'} = $5;$bs{$c}{'new'} = $5;
($bs{$c}{'new'},$count,$nbug) = sub_replace_string("blocks",$bs{$c}{'new'},$findref,$repref,$regex,$case);
$c++;
$dbug.= $nbug;
delete $bs{$c} unless $count > 0;
}
foreach my $k( sort { $a <=> $b } keys %bs ){
($ntxt,$count,$nbug) = sub_replace_string("blocks",$ntxt,[ $bs{$k}{'old'} ],[ $bs{$k}{'new'} ]);
$info{'replace blocks'} = $count;
$dbug.= $nbug;
}
}
}

if( $ins eq "alter" ){
if( $ntxt ne $otxt ){ my $herr = sub_page_print($u,$ntxt);if( defined $herr ){ $err = (defined $err)?$err.$herr:$herr; } else { $info{'updated'} = 'ok'; } } else { $dbug.= "$u: no changes \n"; }
} else {
$dbug.= "$u: $count match".(($count == 1)?"":"es")." \n";
}

} else {
$err = "alert: $u: $ierr ";
}
} else { 
$err = "alert: unable to open $u: $! "; 
}
$msg.= $dbug;
###sub_json_out({ 'check page_rewrite 2' => " $dbug \nmsg: $msg \nins: $ins \nu:$u \nterms: [ @terms ] \n reps: [ @reps ] \n regex:$regex \ncase: $case \nntxt: $ntxt" },$c{'origin'},$c{'callback'});
return ($err,$msg,\%info);
}

sub sub_page_update{
# 'new-analytics_gref' => 'UA-58896111-1',
# 'new-analytics_wref' => '49accf29-f990-4afc-8cb3-d248d186edf7',
# 'new-copyright' => 'Copyright (c) that\'sthat ltd 2017',
# 'new-author' => 'Dave Pilbeam',
# 'new-og:image' => 'http://www.westfieldhealthdigitalresource.co.uk/LIB/index.jpg',
#
# 'new-date' => '24/02/2017',
# 'new-url' => 'Solutions_New-Page.html',
# 'new-link' => '',
# 'new-shortname' => 'Newest',
# 'new-group' => '',
# 'new-tags' => '',
# 'new-area' => 'events',
# 'new-focus' => ''
# 'new-text' => '',
#
# 'new-description' => 'RSM Partners is a global provider of mainframe services, software and expertise for IBM z systems, with a reputation for being flexible, reliable and agile.',
# 'new-keywords' => 'z infrastructure, hardware, software, security, solutions, services, consultancy, staffing, support, delivery, audit, compliance, risk, vulnerability, remediation, penetration testing, migration, upgrades, hosting, disaster recovery, ISV',
# 'new-title' => 'New Page',
#
my ($f,$subf,$dref,$newm,$news,$upm,$cref,$keep) = @_;
my %c = %{$cref};
my %data = %{$dref};if( $f !~ /$c{'docview'}Archive\//i && !defined $upm && !defined $keep && !defined $data{'new-menu'} ){ if(defined $subf){ $data{'new-menu'} = "999.000.00";$data{'new-sub-menu'} = "999.001.00"; } else { $data{'new-menu'} = "999.00"; } }
my $ntxt = "";
my $msg = "";
my $err = undef;
###sub_json_out({ 'check page_update 1' => "f:$f \nsubf:$subf \n\n newm:$newm \n\n\n news:$news \n\n upm:$upm \n\n".Data::Dumper->Dump([\%data],["data"])."\n\n'" },$c{'origin'},$c{'callback'});
my ($ferr,$fmsg,$ntxt) = sub_page_updateset($f,$newm,$news,\%data,$cref,undef,$keep);
$err.= $ferr if defined $ferr;
$msg.= "Page update: ".$fmsg;
if( defined $subf ){
###sub_json_out({ 'check page_update 2' => "f:$f \nsubf:$subf \n\n newm:$newm \n\n\n news:$news \n\n upm:$upm \n\n".Data::Dumper->Dump([\%data],["data"])."\n\n'" },$c{'origin'},$c{'callback'}); 
my ($serr,$smsg,$ntxt) = sub_page_updateset($subf,$newm,$news,\%data,$cref,"new-sub-");
$err.= $serr if defined $serr;
$msg.= "Subpage update: ".$smsg;
}
###sub_json_out({ 'check page_update 3' => "f:$f \nsubf:$subf \n newm:$newm \n news:$news \n upm:$upm \n$ntxt:$ntxt \n\nerr: $err \n\nmsg: $msg \n\n".Data::Dumper->Dump([\%data],["data"])."\n\n'" },$c{'origin'},$c{'callback'});
return ($err,$msg,$ntxt);
}

sub sub_page_updateset{
my ($f,$newm,$news,$dref,$cref,$sub,$keep) = @_;
my %data = %{$dref};
my %c = %{$cref};
my $crum = $f;$crum =~ s/^($c{'base'})//;
my $ourl = $f;$ourl =~ s/^($c{'base'})/$c{'baseview'}/;
my $pg = sub_page_classout($f,$cref);$pg.= " ".join " ",@{ $c{'body_regx'} };
my %heads = %{ $c{'headers'} };
my %edits = %{ $c{'editareas'} };
my $basehref = ( defined $data{'new-baseurl'} )?$data{'new-baseurl'}:undef;$basehref =~ s/([^\/])$/$1\//;
my $baseid = ( defined $data{'new-baseid'} )?$data{'new-baseid'}:undef;
my $title = ( defined $sub && defined $data{$sub.'title'} )?$data{$sub.'title'}:( defined $data{'new-title'} )?$data{'new-title'}:undef;
my $uptitle = undef;
my %m = ();
my $ntxt = "";
my $count = 0;
my $num = 1;
my $ot = $c{'base'};$ot =~ s/^(.+\/\/)//;
my $ts = "@{$c{'titlesep'}}";
my $dbug = "";
my $nbug = "";
my $rbug = "";
my $dtxt = "";
my $msg = "";
my $hfile = undef;
my $upshare = undef;
my $zip = undef;
my $err = undef;
foreach my $k( keys %heads ){ if( defined $data{'new-'.$k} ){ $m{$k} = $data{'new-'.$k};$dbug.= "HEAD1: $k = ".$data{'new-'.$k}."\n"; } }
foreach my $k( keys %edits){ if( $edits{$k} > 0 ){ 
my $ed = ( defined $sub && defined $data{$sub.$k} )?$data{$sub.$k}:(defined $data{'new-'.$k} )?$data{'new-'.$k}:undef;
if( defined $ed ){ if( $k eq "author" ){$m{$k} = $ed;$dbug.= "HEAD1: $k = ".$ed."\n";} else {$m{'edit'.$k} = $ed;$dbug.= "EDIT1: $k = ".$ed."\n";} } 
} }
###sub_json_out({ 'check page_updateset 1' => "f:$f  \n\n".Data::Dumper->Dump([\%m],["m"])."\n\n ntxt:\n$ntxt $dbug'" },$c{'origin'},$c{'callback'});
if(-f $f){ 
my ($ierr,$otxt) = sub_get_contents($f,$cref,"text");
if( !defined $ierr ){ 
$ntxt = $otxt;
$ntxt =~ s/(<body id="body0" class=")(.*?)(">)/$1$pg$3/ism;
($ntxt,$rbug) = sub_page_replacemeta($ntxt,$cref,undef,undef,undef,undef,\%m);$dbug.= $rbug;
if( defined $basehref && $ntxt =~ /<base href=".*?"/ ){ 
$ntxt =~ s/$ot/$basehref/g;
$ntxt =~ s/(http.*?)(${basehref}LIB)/\/\/$2/g; #"http://rsmpartners.com/LIB/Mainframe-Security_Software-Solutions_enterpriseConnector.jpg"
$ntxt =~ s/(http.*?)(${basehref}$c{'cgiurl'})/\/\/$2/g; #href="http://www.rsmpartners.com/cgi-bin/view.pl?url=Mainframe-Security.html" 
if( $ntxt =~ /(action=")(.*?)\/([a-z0-9]+\.pl")/imgs ){ my @ac = ($1,$2,$3);$ntxt =~ s/($ac[0])$ac[1]($ac[2])/$1..\/$c{'cgipath'}$2/imgs; } #action="https://rsmpartners.com/email.pl"
$ntxt =~ s/<\!\-\-.*?\-\->//gsm;
if( defined $baseid && $ntxt =~ /<title>.*?($ts)<\/title>/sm ){ $ntxt =~ s/$ts/$c{'titlesep'}->[0] $baseid/gsm; }
$ourl = $f;$ourl =~ s/^($c{'base'})/$c{'http'}\/\/$basehref/;
$upshare = 1;
} else {
if( defined $data{'new-url'} ){ $ourl = $data{'new-url'};if( $ntxt =~ /<title>(.*?)($ts)<\/title>/sm ){$uptitle = $1;}$upshare = 1; } 
}
if( defined $title ){
my $t = "";
if( $ntxt =~ /(<h1>\s*)(<.*?>)*(.*?)(\s*<\/h1>)/ism ){ #<div class="edittitle"><div class="text"><h1>RSM assists government agency zCloud transition</h1></div></div>
$t = $3; 
} else {
if( $ntxt =~ /<li class="column pagetitle">\s*<div class="row">\s*/ ){ $ntxt =~ s/(<li class="column pagetitle">\s*<div class="row">\s*)/$1<div class="text"><h1>New Page Title<\/h1><\/div>\n/;$t = 'New Page Title'; }
}
if($t ne ""){
($t,$count,$nbug) = sub_replace_string("title",$t,[ '.+' ],[ $title ],'regex'); ###$dbug.= $nbug;
if( $count > 0 ){ ($ntxt,$nbug) = sub_page_retitle($ntxt,$t,$ts);$dbug.= $nbug; }
}
$uptitle = $t;
$upshare = 1;
}
#<div class="text"><a data-id="index" data-sort="21" data-amount="9" data-format="stacker" data-position="lower" href="../cgi-bin/view.pl?url=News.html" title="view News">News</a></div>
#<div class="text"><a data-id="index" data-sort="21" data-amount="9" data-format="stacker" data-position="lower" data-filter="editarchive" href="../cgi-bin/view.pl?url=documents/Archive/News/2015/index.html" title="view News">News</a></div>
#<div class="text"><a data-id="archive" data-filter="editarchive" href="../cgi-bin/view.pl?url=documents/Archive/News/2017/" title="view 2017 Archive">link to News archive</a></div>
#<div class="text"><a data-id="archive" data-filter="editarchive" href="../cgi-bin/view.pl?url=documents/Archive/News/2015/index.html" title="view 2015 News Archive">link to News archive</a></div>
if( $f =~ /($c{'docview'}Archive\/.+)\/(.+)$c{'qqdelim'}/i ){ #Group-News/2015/
my $r = $1;
my $di = $2;
my $ir = $r;if( $ir =~ /^.+\/(.*?)\/$/ ){ $ir = $1; }
my $df = $r."/index.".$c{'htmlext'};
$ntxt =~ s/(<div class="m-container">).*?(\s*<div class="m-pusher-container)/$1<label class="m-overlay" for="m-toggle-top"><\/label>$2/is; #"
$ntxt =~ s/<ul class="area navarea"/<ul class="area navarea navarchive"/i;
$ntxt =~ s/<div class="menu navigation">\s*<ul class="menu">.*?<\/ul>\s*<\/div>/<div class="tt_archive"><span><a href="" title="back to Index">Back to Archive Index<\/a><\/span><\/div>$2/is;
$ntxt =~ s/<div class="editmodule menu">\s*<div class="text">\s*<ul class="menu">.*?<\/ul>\s*<\/div>\s*<\/div>/<div class="tt_archive"><span><a href="$df" title="back to Index">Back to Archive Index<\/a><\/span><\/div>/is;
$ntxt =~ s/href="..\/cgi-bin\/view.pl\?url=News.html"(.*?)>(.*?<\/a>)/href="..\/cgi-bin\/view.pl?url=$df"$1>$2/g;
$ntxt =~ s/(<div class="crumb"><p>)(.+)(<span class="crumbjoin"><\/span>.*?<\/p><\/div>)/$1<a href="documents\/Archive\/index.html">Archive<\/a><span class="crumbjoin"><\/span><a href="$df">$ir<\/a>$3/i;
$ntxt =~ s/<a data-id="(index|archive|list|menu|blocks)" /<a data-id="$1" data-filter="editarchive" /gi;
}
if( defined $upshare && defined $c{'sharelist'} ){ 
if( $ourl !~ /^($c{'baseview'})/ && $f !~ /($c{'docview'})Archive\//i ){ $zip = $c{'baseview'}; }
###sub_json_out({ 'check page_updateset 2' => "zip:$zip \nbaseview:$c{'baseview'} \nupshare:$upshare f:$f \nourl:$ourl \nuptitle:$uptitle \n\n ntxt:\n$ntxt \n\n$dbug'" },$c{'origin'},$c{'callback'}); # ourl:https://bigtest.co.uk/Paper_Products_Revive_Revive-100-Silk.html  uptitle: 
($ntxt,$nbug) = sub_page_reshare($ntxt,$c{'sharelist'},$ourl,$uptitle,$cref,$zip);$dbug.= $nbug;
}
if( defined $newm ){ 
$dtxt = $ntxt;while( $dtxt =~ /(\s*<ul class="menu">.*?<\/ul>)(\s*<\/div>)/gis ){ my $fnd = $1.$2;my $rep = $newm.$2;$rep =~ s/"toggle([0-9]+)-/"toggle$num-/gi;$ntxt =~ s/$fnd/$rep/gism; $num++; }
if( defined $news ){ $ntxt =~ s/(\s*<ul class="sitemap">.*?<\/ul>)(\s*<\/div>)/$news$2/gism; }
}
$ntxt = sub_clean_utf8( $ntxt,$c{'UTF'},$c{'UTF1'},"despace" );
###if( $f =~ /Group.Links/ ){
###sub_json_out({ 'check page_updateset 3' => "upshare:$upshare f:$f \n\n ntxt:\n$ntxt \n\n$dbug'" },$c{'origin'},$c{'callback'});
###}
if( !defined $keep ){ 
my $herr = sub_page_print($f,$ntxt);if( defined $herr ){ $err = (defined $err)?$err.$herr:$herr; } else { $msg.= $crum.": <i>updated and saved</i><br />"; }
} else {
$msg.= $crum.": <i>updated</i><br />";
}
} else {
$err = "error: write page_updateset 1: $ierr <br />";
}
} else {
$err = "error: write page_updateset 2: open $f failed: $! <br />";
}
###sub_json_out({ 'check page_updateset 4' => "f:$f  \n\n".Data::Dumper->Dump([\%m],["m"])."\n\n ntxt:\n$ntxt $dbug'" },$c{'origin'},$c{'callback'});
return ($err,$msg,$ntxt);
}

sub sub_page_uplevel{ 
my ($u,$dm) = @_; #Contact.html Solutions_Page-1.html News_Other_Page-1.html
my @n = split /$dm/,$u;
if( scalar @n > 1 ){ shift @n; }
return join "$dm",@n;
}

sub sub_parse_blocks{
my ($otxt,$nref,$vref,$cref,$areaclass) = @_;
my @enames = (defined $nref)?@{$nref}:();
my @evalues = (defined $vref)?@{$vref}:();
my %c = %{$cref};
my @items = ();
my $istag = (scalar @enames > 0 && scalar @evalues > 0)?"(".(join "|",@evalues).")":undef;
my $hok = ( defined $istag && scalar @enames > 0 && $otxt =~ /<meta\s*(content="$istag")*\s*name="$enames[0]"(content="$istag")*\s*\/>/ )?1:undef; #<meta content="sausage" name="editarea" />
my $dbug = "\nenames = [ @enames ] \nevalues = [ @evalues ] \nistag:$istag\n hok:$hok \nareaclass:$areaclass \n";
if( defined $areaclass){ #<ul class=\"area editablearea slideshowarea homeslidearea\" data-startdelay=\"1000\" data-delay=\"200\" data-interval=\"500\" data-hover=\"on\" data-controller=\"on\" data-auto=\"on\">\n\t\t\t\t\t\t\t\t\t\t<li class=\"column 
while( $otxt =~ /<ul class="area editablearea(.*?)"((\s*data-.*?=".*?"\s*)*>\s*<li class="column.*?>.*?<\/li>\s*<\/ul>)\s*(<ul class="area|<\/div>)/gism ){
my $cls = $1;
my $agot = $2;
if( $areaclass eq "editablearea" || $cls =~ /$areaclass/ ){ push @items,'<ul class="area editablearea'.$cls.'"'.$agot; }
}
} else {
while( $otxt =~ /<ul class="area editablearea(.*?)"(\s*data-.*?=".*?"\s*)*>\s*<li class="column(\s*tt_.*?\s*)*"(\s*data-.*?=".*?"\s*)*>(.*?)<\/li>\s*<\/ul>(?!\s*(<\/fieldset>|<ul class="ful">))/gism ){
my $cls = $1;
my $agot = $5;
my $ok = undef;
$dbug.= "new = $1 = $5 \n\n";
if( defined $hok ){$ok = 1;} elsif( scalar @evalues > 0 ){ for my $i(0..$#evalues){if($cls =~ /($evalues[$i])/i){$ok = 1;$dbug.= "$evalues[$i] = $cls \n\nagot: $agot\n";}} } else { $ok = 1; }
my @lis = ();if( $agot =~ /<\/li>\s*<li class="column.*?">/i ){ @lis = split /<\/li>\s*<li class="column.*?">/,$agot; } else { $lis[0] = $agot; }
for my $i( 0..$#lis ){
$lis[$i] =~ s/(<\/div>\s*<div id="tabcontent.*?" class="tabcontent.*?">\s*)|(<input.*?<\/label>\s*)//gism;
$lis[$i] =~ s/(<\/div>\s*<div class=".*?grid">\s*)//gism;
$dbug.= "$i = $lis[$i] \n";
if(defined $ok){ @items = @{ sub_parse_blockinner($lis[$i],\@items) }; }
}
}
}
###if( $otxt =~ /25th February 2019: In a previous blog, I talked about/){
###sub_json_out({ 'check parse_blocks' => "$dbug \n\n".Data::Dumper->Dump([\@items],["items"])."\n\n$otxt =\n $otxt " },$c{'origin'},$c{'callback'});
###}
return @items;
}

sub sub_parse_blockinner{
my ($txt,$iref) = @_;
my @items = (defined $iref)?@{$iref}:();
if( $txt =~ /<\/div>\s*<div class="row editblock">/i ){
my @blocks = split /<\/div>\s*<div class="row editblock">/,$txt;
for my $j(0..$#blocks){ $blocks[$j] =~ s/^.*?<div class="row editblock">//ism;if( $blocks[$j] !~ /<\/div>\s*<\/div>\s*<\/div>/ ){ $blocks[$j].= "\n</div>"; }push @items,"<div class=\"row editblock\">\n".$blocks[$j]; }
} else {
if( $txt ne "" ){ $txt =~ s/^.*?<div class="row editblock">//ism;if( $txt !~ /<\/div>\s*<\/div>\s*<\/div>/ ){ $txt.= "\n</div>"; }push @items, "<div class=\"row editblock\">\n".$txt; } 
}
return \@items;
}

sub sub_parse_menutext{
my ($otxt,$cref) = @_;
my %c = %{$cref};
my %m = ();
if( $otxt =~ /(<ul class="menu">.*?<\/ul>)(\s*<\/div>)/is ){ $m{'menutext'} = [ $1 ]; }
if( $otxt =~ /(<ul class="sitemap">.*?<\/ul>)(\s*<\/div>)/is ){ $m{'sitemaptext'} = [ $1 ]; }
return \%m;
}

sub sub_parse_meta{
#<meta content="05/10/16" name="editdate" />
#<meta content="newest/index-&-etc.html" name="editlink" />
#<meta content="newest/index.html" name="editurl" />
#<meta content="Home" name="editshortname" />
#<meta content="UA-58896111-1" name="gref" />
my ($otxt,$edref,$cref) = @_;
my %editareas = %{$edref};
my %c = %{$cref};
my %heads = %{ $c{'headers'} };
my %edits = ();
my $atitle = "";
my $ah1 = "missing";
my $ts = "@{$c{'titlesep'}}";
my $stitle = undef;
my $sh1 = undef;
my $dbug = "";
while( $otxt =~ /(<meta.*? \/>)/gim ){ 
my $f = $1;
my $v = $f;$f =~ s/^.*?(name|property|http-equiv)="(.*?)".+$/$2/;
if($v =~ /content="(.*?)"/i){ $v = $1; }
for my $k( keys %heads ){if( $f eq $k ){ @{ $edits{$k} } = ( $v ); $dbug.= "$f = $v\n"; } }
for my $k( keys %editareas){ my $n = ($k eq "name")?'shortname':$k;if( $f eq "edit".$k && $editareas{$k} > 0 ){ $dbug.= "$f ($n) = $v\n";@{ $edits{$n} } = ( $v ); } } 
}
if( defined $edits{'url'} ){ push @{ $edits{'menuname'} },sub_title_out( @{ $edits{'url'} }[0],$cref );$dbug.= "$edits{'url'}->[0] = $edits{'menuname'}->[0] \n"; }
if( $otxt =~ /<h1>\s*(.*?)\s*<\/h1>/ ){ $sh1 = $1;@{ $edits{'title'} } = ( $sh1 ); } 
if( $otxt =~ /<title>(.*?)<\/title>/i ){
$atitle = $1;
$stitle = $atitle;
if( !defined $stitle || $stitle eq "" ){
$stitle = ( defined $sh1 )?$sh1:( defined $edits{'menuname'} )?@{ $edits{'menuname'} }[0]:"";
if( !defined $edits{'issues'} ){ @{ $edits{'issues'} } = (); }push @{ $edits{'issues'} },'TITLE Tag <u class="old">'.$atitle.'</u> is wrong - try <u class="new">'.$stitle.'</u>';
} else {
$stitle =~ s/\s*($ts)$//;
if( defined $sh1 && $stitle ne $sh1 ){
if( !defined $edits{'issues'} ){ @{ $edits{'issues'} } = (); }push @{ $edits{'issues'} },'TITLE Tag <u class="old">'.$stitle.'</u> does not match H1 Tag - try <u class="new">'.$sh1.'</u>';
} 
}
}
if( !defined $sh1 || $sh1 eq "" ){
if( !defined $edits{'issues'} ){ @{ $edits{'issues'} } = (); }push @{ $edits{'issues'} },'H1 Tag is missing - try <u class="new">'.$stitle.'</u>';
}
###sub_json_out({ 'check parse_meta' => "".Data::Dumper->Dump([\%edits],["edits"])."\n\n otxt:$otxt \n\n$dbug \n\n" },$c{'origin'},$c{'callback'}); 
# $edits = {
# 'shortname' => [ 'RSM joins MSPAlliance' ],
# 'date' => [ '24/04/17' ],
# 'area' => [ 'Services' ],
# 'analytics_gref' => [ 'UA-96342629-1' ],
# 'menu' => [ '004.026.0' ], 
# 'copyright' => [ 'Copyright (c) that\\'sthat ltd 2017' ],
# 'focus' => [ 'Cloud' ], 
# 'author' => [ 'Dave Pilbeam' ],
# 'menuname' => [ 'RSM Becomes Member of MSPAlliance' ], 
# 'description' => [ 'RSM Partners is a global provider of mainframe services, software and expertise for IBM z systems, with a reputation for being flexible, reliable and agile.' ],
# 'og:image' => [ 'http://rsmpartners.com/LIB/default-page.jpg' ],
# 'keywords' => [ 'z infrastructure, hardware, software, security, solutions, services, consultancy, staffing, support, delivery, audit, compliance, risk, vulnerability, remediation, penetration testing, migration, upgrades, hosting, disaster recovery, ISV' ], 
# 'url' => [ 'News_RSM-Becomes-Member-of-MSPAlliance.html' ],
# 'title' => [ 'RSM Becomes Member of MSPAlliance' ],
# 'analytics_wref' => [ '49accf29-f990-4afc-8cb3-d248d186edf7' ] 
# }
return \%edits;
}

sub sub_parse_shares{
my ($txt,$cref) = @_;
my %c = %{$cref};
my %s = ();
if( $txt =~ /<div id="tt_sharewrapper">\s*(.*?)\s*<\/div>\s*<label/ism ){
my $bt = $1;
my @sh = split /<\/div>\s*<div/,$bt;
for my $i(0..$#sh){
my $k = undef;if( $sh[$i] =~ /title="Share on\s*(.*?)"\s*target="_blank">/i ){ $k = $1;if( $sh[$i] =~ /(u|url)=(http.*?)"/ ){ $s{$k} = $2; } } #"
}
}
return \%s;
}

sub sub_parse_tags{
my ($txt,$u,$cref) = @_;
my %c = %{$cref};
my %tags = ();
my @en = ();

my $tagref = undef;

if( $txt =~ /^new-baseurl:/ ){

my %set = ();
@en = split /$c{'defsep'}\s*/,$txt;
my $k = ( $en[0] =~ /^new-baseurl:\s*(.*?)\s*$/ )?$1:"new site";
for my $i(0..$#en){ my $n = undef;if( $en[$i] =~ /[a-z0-9\/]+/i && $en[$i] =~ /^(.*?):\s*(.*?)\s*$/ ){ $n = $1;@{ $set{$1} } = ( $2 ); } }
$tags{$k} = \%set;

} else {

@en = split /\n/,$txt; ###$tags{'dbug'} = {};
for my $i(0..$#en){
my $k = undef;
if( $en[$i] =~ /^url:\s*(.*?)\s*$/ ){ 
$k = $1;$tags{$k} = {};$tagref = $tags{$k}; ###$tags{'dbug'}->{'starturl'} = "url = $k\n";
} 
if( $en[$i] =~ /[a-z0-9\/]+/i && $en[$i] =~ /^(.*?):\s*(.*?)\s*$/ ){ 
my $n = $1;my $v = $2; ###$tags{'dbug'}->{$n} = "n = $n v = $v \n";
@{ $tagref->{$n} } = () if !defined $tagref->{$n};push @{ $tagref->{$n} },$v if $v =~ /[a-z0-9\/]+/i;
}
if( defined $tagref->{'created'} ){ $tagref->{'epochcreated'} = [ sub_epoch_date( @{ $tagref->{'created'} }[0] ) ]; }
}

}
###sub_json_out({'check parse_tags' => "u: $u\n\n ".Data::Dumper->Dump([\%tags],["tags"])."\n\n \ntxt:$txt \n\n $c{'debug'} " },$c{'origin'},$c{'callback'});
return %tags;
}

sub sub_rename{
my($rold,$rnew,$cref) = @_;
my %c = %{$cref};
my $sold = $rold;$sold =~ s/^($c{'base'})//;
my $snew = $rnew;$snew =~ s/^($c{'base'})//;
my $msg = "Renamed <i>".$sold."&#160;</i> to <i>".$snew."&#160;</i>.<br />";
my $err = undef;
return ("Rename error with file [ $rold ]: $! <br />","") unless -e $rold;
mv ($rold,$rnew) or $err = "Rename error: $rold to $rnew: $! <br />";
return ($err,$msg);
}

sub sub_replace_string{
my ($ty,$ntxt,$findref,$repref,$regex,$case) = @_;
my @terms = (defined $findref)?@{ $findref }:();
my @reps = (defined $repref)?@{ $repref }:();
my @c = ();
my $dbug = "";
for my $i( 0..$#terms){
my $match = 0;
my $tm = $terms[$i];
my $rp = $reps[$i];
if( defined $ty && $ty eq "links" ){ $tm =~ s/\&/&#38;/g;$rp =~ s/\&/&#38;/g; }
if( !defined $regex ){ $tm = quotemeta $tm; }
my $pattern = (defined $case)?"(?s)$tm":"^(.*$tm.*)\$"; ####my $pattern = (defined $case)?$tm:"^(.*$tm.*)\$"; ###$dbug.= "@terms = $pattern \n"; 
while ($ntxt =~ /$pattern/gim){ 
my $got = $1; 
$dbug.= "found: [ ".encode_entities($tm)." ] in [ ".encode_entities($got)." ]";
$match++;
}
if($match > 0){ if(defined $case){ @c = $ntxt =~ s/$tm/$rp/gism; } else { @c = $ntxt =~ s/$tm/$rp/gim;$dbug.= ": match".((scalar @c > 1)?"es":"").": ".( scalar @c )."<br />"; } }
}
return ($ntxt,(scalar @c),$dbug);
}

sub sub_return_blocks{
my ($f,$cref,$enref,$evref,$ispull) = @_;
my %c = %{$cref};
my @editnames = (defined $enref)?@{$enref}:();
my @editvalues = (defined $evref)?@{$evref}:();
my @out = ();
my $cf = $f;$cf =~ s/^($c{'base'})//;
my $areaclass = undef;
my $ok = undef;
my $err = undef;
my ($ierr,$otxt) = sub_get_contents($c{'base'}.$cf,$cref,"text");return ("$f blocks error: $ierr") if defined $ierr;
if( scalar @editnames > 0){ 
if( $editnames[0] eq "classname"){
if( defined $editvalues[0] ){ 
$areaclass = $editvalues[0];if( $otxt =~ /<ul\s+class="area\s+editablearea.*?($areaclass).*?"/ ){ $ok = 1; } 
} else {
$areaclass="editablearea";if( $otxt =~ /<ul\s+class="area\s+editablearea.*?"/ ){ $ok = 1; } 
}
} else {
for my $k(0..$#editnames){ my $ed = $editnames[$k];if( defined $editvalues[$k] && $otxt =~ /<meta\s*(name="$ed")*(content="$editvalues[$k]"\s*)(name="$ed"\s*)*\/>/si ){ $ok = 1; } }
}
} else {
$ok = 1;
}
if( defined $ok ){
my @blocks = sub_parse_blocks($otxt,$enref,$evref,$cref,$areaclass);
if( defined $areaclass){
@out = @blocks;
} else {
for my $i( 0..$#blocks ){ 
$blocks[$i] =~ s/'/&#39;/g; #'
if( defined $ispull ){ $blocks[$i] =~ s/^(<div.*?class=".*?)">/$1 pulled">/; }#" 
push @out,$blocks[$i];
}
}
###sub_json_out({'check return_blocks' => "f: $f \n\n".Data::Dumper->Dump([\@out],["out"])."\n\n ".Data::Dumper->Dump([\@blocks],["blocks"])."\n\n $c{'debug'} " },$c{'origin'},$c{'callback'});
}
if( scalar @out < 1 ){ $err = "alert return_blocks: no page list available f:$f: out:[ @out ] "; }
###sub_json_out({'check return_blocks' => "f: $f \n\n ".Data::Dumper->Dump([\@out],["out"])."\n\n \notxt:$otxt \n\n $c{'debug'} " },$c{'origin'},$c{'callback'});
return ($err,\@out);
}

sub sub_return_documents{
# 'test-document2.pdf' => { 
# 'parent' => [ 'documents/Digital' ], 
# 'epoch' => [ 1481739432 ], 
# 'menuname' => [ 'test-document2.pdf' ], 
# 'path' => ['documents','Digital','test-document2.pdf' ], 
# 'size' => [ '1641k' ], 
# 'published' => [ '14/12/2016' ], 
# 'href' => [ 'documents/Digital/test-document2.pdf' ], 
# 'url' => [ 'test-document2.pdf' ], 
# 'area' => [ 'UK-Europe2' ], 
# 'author' => [ 'Ben Chap2' ], 
# 'focus' => [ 'Financial2', 'Maverick2' ], 
# 'text' => ['A document that is meant to be a test2.','Another line of text2.' ], 
# 'created' => [ '13/12/2016' ], 
# 'epochcreated' => [ 1481587200 ], 
# 'tags' => [ 'England2','Scotland2' ], 
# 'image' => [ 'Test-Image2_thumb.gif' ], 
# 'title' => [ 'Ben\'s Test Document2' ] 
# } 
my ($ins,$f,$ctref,$cref) = @_;
my @ct = @{$ctref};
my %c = %{$cref};
my %jout = ();
my @mout = ();
for my $i(0..$#ct){
if( ref $ct[$i] eq ref {} ){
###sub_json_out({'debug' => "check return_documents 1:ins: $ins \n\n ".Data::Dumper->Dump([ $ct[$i] ],["ct"])." \n\n$c{'debug'} " },$c{'origin'},$c{'callback'});
my %ord = %{ $ct[$i]{'files'} };
foreach my $k( keys %ord ){
if( defined $ord{$k}{'epochcreated'} ){ @{ $ord{$k}{'epoch'} } = @{ $ord{$k}{'epochcreated'} };delete $ord{$k}{'epochcreated'}; }
if( defined $ord{$k}{'created'} ){ @{ $ord{$k}{'published'} } = @{ $ord{$k}{'created'} };delete $ord{$k}{'created'}; }
if( !defined $ord{$k}{'title'} ){ @{ $ord{$k}{'title'} }[0] = sub_title_out( @{ $ord{$k}{'menuname'} }[0],$cref ); }
if( defined $ord{$k}{'href'} && defined @{ $ord{$k}{'href'} }[0] && @{ $ord{$k}{'href'} }[0] !~ /^($c{'baseview'})/ ){ @{ $ord{$k}{'href'} }[0] = $c{'baseview'}.@{ $ord{$k}{'href'} }[0]; }
push @mout,$ord{$k};
}
}
}
@{ $jout{'data'} } = ();
my $usplit = scalar (split /\//,$c{'sitepage'}); # ( 'documents','Digital' )
foreach my $io (sort { ($c{'pagesort'} eq "21")?$b->{'epoch'}[0] <=> $a->{'epoch'}[0] || lc $a->{'title'}[0] cmp lc $b->{'title'}[0]:($c{'pagesort'} eq "12")?$a->{'epoch'}[0] <=> $b->{'epoch'}[0] || lc $a->{'title'}[0] cmp lc $b->{'title'}[0]:($c{'pagesort'} eq "az")?lc $a->{'title'}[0] cmp lc $b->{'title'}[0]:lc $b->{'title'}[0] cmp lc $a->{'title'}[0] } @mout ){
if( $c{'format'} eq "library" ){
my $dref = \%{ $jout{'data'}[0] };
my @tree = @{ $io->{'path'} };
for my $i($usplit..$#tree){ 
if( $i < $#tree ){
if( !defined $dref->{$tree[$i]} ){ $dref->{$tree[$i]} = {};$c{'debug'}.= "tree: $i = $tree[$i] {}\n";$dref->{$tree[$i]}->{'is_group'} = $tree[$i];$c{'debug'}.= "is_group: $i = $tree[$i] \n"; }$dref = $dref->{$tree[$i]}; 
} else {
$dref->{ $tree[$i] } = $io;
}
}
} else {
push @{ $jout{'data'} },$io;
}
}
###sub_json_out({'debug' => "check return_documents 2:\n\nins: $ins \n\npagesort: $c{'pagesort'} \n usplit: $usplit \n\n \n\njout: ".Data::Dumper->Dump([\%jout],["jout"])." \n\n$c{'debug'} " },$c{'origin'},$c{'callback'});
return %jout;
}

sub sub_return_files{
my ($f,$fref,$cref,$amount,$random) = @_;
my @files = @{$fref};
my %c = %{$cref};
my %jout = ();
my @out = ();
my @tout = ();
my $dbug = "";
my $rank = $c{'pagesort'};if( $rank =~ /rank/ ){$rank = "az";}
my $err = undef;
for my $i(0..$#files){
my $sh = $files[$i];$sh =~ s/^($c{'base'})//;
my $tmp = $files[$i];$tmp =~ s/^($c{'base'})/$c{'baseview'}/;
my $ext = lc $tmp;$ext =~ s/^(.+)\.//;
my $tt = sub_title_out( $tmp,$cref );$tt =~ s/\.(.*?)$//; #ucfirst = $tt =~ s/([\w']+)/\u\L$1/g;
%{ $jout{$sh} } = ();
if( $sh =~ /$c{'chapterlister'}$/ ){
my $n = $1;
my ($ierr,$ctxt) = sub_get_contents($files[$i],$cref,"text");
if( !defined $ierr ){ $ctxt =~ /^(.*?)\n/;$tt = $n.": ".$1;$jout{$sh}{'sorttype'} = "url"; }
} else {
$jout{$sh}{'sorttype'} = $rank;
}
#$dbug.= "$i = $sh = $tt \n";

%{ $jout{$sh}{'data'} } = %{ sub_merge_hash( {},sub_get_data($files[$i],$cref),{'title' => [$tt],'href' => [$tmp],'type' => [$ext]} ) };
}
# %jout = ( 'documents/PDF/Policies/Terms-of-Business/POL50-Demo-Test-2.pdf' => { 'data' => { 'published' => ['26/02/2018'], 'versions' => [],'epoch' => [1519647593],'size' => ['1562k'],'parent' => ['documents/PDF/Policies/Terms-of-Business'],'url' => ['documents/PDF/Policies/Terms-of-Business/POL49-Demo-Test-1.pdf'] } } )
###$dbug.= "\n\n".Data::Dumper->Dump([\%jout],["jout"])." \n\n";
my @mout = @{ sub_menu_sort(\%jout,{},$cref,"files") };
###sub_json_out({'check return_files' => "f:$f \npagesort:$rank \n\n$dbug \n\n".Data::Dumper->Dump([\@mout],["mout"])." \n\n$c{'debug'}"},$c{'origin'},$c{'callback'});
for my $i(0..$#mout){ 
my %h = %{$mout[$i]};
if( $h{'href'}->[0] =~ /^(.+)\/$c{'chapterlister'}$/ ){
my $novel = $1;my $chap = $2;$novel =~ s/^.+\///;$h{'href'}->[0] = $c{'baseview'}.$c{'cgipath'}.'novelize.pl?novel='.$novel.'&chapter='.$chap;
push @out,'<a class="filelistitem filelist'.$h{'type'}->[0].'" href="'.$h{'href'}->[0].'" title="go to chapter '.$chap.'" data-size="'.$h{'size'}->[0].'" data-published="'.$h{'published'}->[0].'"><span>'.$h{'title'}->[0].'</span></a>'; 
} else {
push @out,'<a class="filelistitem filelist'.$h{'type'}->[0].'" href="'.$h{'href'}->[0].'" title="download '.(uc $h{'ext'}->[0]).' file" target="_blank" data-size="'.$h{'size'}->[0].'" data-type="'.(uc $h{'type'}->[0]).'" data-published="'.$h{'published'}->[0].'"><span>'.$h{'title'}->[0].'</span></a>'; 
}
}
###sub_json_out({'check return_files 1' => "f:$f \npagesort:$rank \n\nfiles = (".( scalar @out ).") ".Data::Dumper->Dump([\@out],["out"])." \n\n$c{'debug'}"},$c{'origin'},$c{'callback'});
if( scalar @out > 0 ){
@tout = @out;
if( defined $random && scalar @tout >= $random){ @tout = sub_get_random(\@tout,$#tout); }
if( defined $amount && $amount > 0 && scalar @tout > $amount ){ @tout = @tout[0..($amount-1)]; }
} else {
$err = "alert: no image list available $f: $! ";
}
return ($err,\@tout);
}

sub sub_return_images{
my ($f,$cref,$ntxt,$amount,$random) = @_;
my %c = %{$cref};
my %jout = ();
my @out = ();
my @tout = ();
my $dbug = "";
my $err = undef;
my @imgs = sub_get_images($f,$c{'bandir'});
for my $i(0..$#imgs){
my $tmp = $imgs[$i];$tmp =~ s/^($c{'base'})/$c{'baseview'}/;
my $sh = $imgs[$i];$sh =~ s/^($c{'base'})//;
$dbug.= "$i = $sh \n";
%{ $jout{$sh} } = ();
$jout{$sh}{'sorttype'} = $c{'pagesort'};
%{ $jout{$sh}{'data'} } = %{ sub_get_data($imgs[$i],$cref); }
}
# %jout = ( 'documents/Images/logos/partners/suse.jpg' => { 'data' => { 'epoch' => [1495545546],'menu' => [],'size' => ['5k'],'versions' => [],'published' => [ '23/05/2017'],'url' => ['documents/Images/logos/partners/suse.jpg'] } } )
###$dbug.= "\n\n".Data::Dumper->Dump([\%jout],["jout"])." \n\n";
my @mout = @{ sub_menu_sort(\%jout,{},$cref,"images") };
###sub_json_out({'check return_images' => "f:$f \npagesort:$c{'pagesort'} \n\n$dbug \n\ni".Data::Dumper->Dump([\@mout],["mout"])." \n\n$c{'debug'}"},$c{'origin'},$c{'callback'});
my $io = "tt_odd";
for my $i(0..$#mout){ 
my %h = %{$mout[$i]};
my $mu = @{ $h{'url'} }[0];$mu =~ s/^($c{'base'})/$c{'baseview'}/;
my $smu = sub_title_out( $mu,\%c );$smu =~ s/\.(.*?)$//; ###$smu =~ s/([\w']+)/\u\L$1/g; #'uc first
my $a1 = ( defined $c{'keeplinks'} )?" href=\"$mu\" target=\"_blank\"":"";
push @out,"<a class=\"imageitem\" style=\"background-image:url($mu);\"$a1><span class=\"$io\">$smu</span></a>"; 
if($io eq "tt_odd"){$io = "tt_even";} else {$io = "tt_odd";}
}
###sub_json_out({'check return_images 1' => "f:$f \npagesort:$c{'pagesort'} \n\nimgs = (".( scalar @out ).") ".Data::Dumper->Dump([\@out],["out"])." \n\n$c{'debug'}"},$c{'origin'},$c{'callback'});
if( scalar @out > 0 ){
@tout = @out;
if( defined $random && scalar @tout >= $random){ @tout = sub_get_random(\@tout,$#tout); }
if( defined $amount && $amount > 0 && scalar @tout > $amount ){ @tout = @tout[0..($amount-1)]; }
} else {
$err = "alert: no image list available $f: $! ";
}
return ($err,\@tout);
}

sub sub_return_menus{
# 'data' => {
# 'shortname' => ['Capacity Cost Reduction'],
# 'issues' => [ 'URL Tag <u class="old">Mainframe-Services_Capacity-Cost-Reduction.html</u> is wrong - should be <u class="new">Mainframe-Services_Capacity-Cost-Reduction2.html</u>' ],
# 'blocks' => [],
# 'date' => [  '10/01/17'],
# 'analytics_gref' => [ 'UA-96342629-1' ],
# 'copyright' => [ 'Copyright (c) that\'sthat ltd 2017' ],
# 'author' => [ 'Dave Pilbeam' ],
# 'menuname' => [ 'Capacity Cost Reduction' ],
# 'og:image' => [ '//thegatemaker.pecreative.co.uk/LIB/default-page.jpg' ],
# 'size' => [ '48k' ],
# 'keywords' => [ 'z infrastructure, hardware, software, security, solutions, services, consultancy, staffing, support, delivery, audit, compliance, risk, vulnerability, remediation, penetration testing, migration, upgrades, hosting, disaster recovery, ISV' ],
# 'versions' => [],
# 'url' => [ 'Mainframe-Services_Capacity-Cost-Reduction.html' ],
# 'htmlname' => [ 'Mainframe-Services_Capacity-Cost-Reduction2.html' ],
# 'link' => [ 'Mainframe-Services_Capacity-Cost-Reduction.html'],
# 'epoch' => [ 1497269062 ],
# 'parent' => [ 'Mainframe-Services.html' ],
# 'menu' => [ '001.006' ],
# 'path' => [ 'Mainframe-Services',  'Capacity-Cost-Reduction2' ],
# 'description' => [ 'The Gate Maker is a global provider of mainframe services, software and expertise for IBM z systems, with a reputation for being flexible, reliable and agile.' ],
# 'published' => [ '12/06/2017' ],
# 'title' => [ 'Capacity Cost Reduction' ],
# 'analytics_wref' => [ '49accf29-f990-4afc-8cb3-d248d186edf7' ]
# }
my ($ins,$f,$outref,$cref,$pulled,$showall,$dref) = @_;
my @mout = @{$outref};
my %c = %{$cref};
my %jout = ();
my %ord = ();
my @files = ();
my $dp = $c{'sitepage'};$dp =~ s/\.($c{'htmlext'})$//;
my $depth = ( $ins =~ /^view/ || $ins eq "searchpages" || $ins eq "menureorder" )?0:( defined $c{'sitepage'} )?$dp =~ /$c{'qqdelim'}/g:0;
my $ntxt = "";
my $msg = "";
my $dbug = "";
my $archive = ($ins eq "menu" && defined $c{'filter'} && defined $f && $f =~ /($c{'docview'})Archive\//i)?"full":undef;
my $err = undef;
#if( $ins eq "menureorder" ){
###sub_json_out({'check return_menus' => ":ins:$ins $f \narchive:$archive \npagesort:$c{'pagesort'} \nsitepage: $c{'sitepage'} \ndepth: $depth \n\nmout: ".Data::Dumper->Dump([\@mout],["mout"])." \n\n$c{'debug'} " },$c{'origin'},$c{'callback'});
#}
my @tmp = @mout;
for my $i (0..$#tmp ){
if( ref $tmp[$i] eq ref {} && defined $tmp[$i]->{'data'} ){
my $tt = "";
push @files,$c{'base'}.$tmp[$i]->{'data'}->{'url'}[0] if $tmp[$i]->{'data'}->{'url'}[0] !~ /($c{'site_file'})$/;
my @pth = @{ $tmp[$i]->{'data'}->{'path'} }; # 'path' => [ 'Solutions','Presentation', 'Converged-Communications' ],
my $drilled = ($ins eq "editpages")?1:( defined $tmp[$i]->{'data'}->{'url'} && $tmp[$i]->{'data'}->{'url'}[0] eq $c{'sitepage'} )?1:( defined $tmp[$i]->{'data'}->{'parent'} && $tmp[$i]->{'data'}->{'parent'}[0] =~ /($c{'sitepage'})$/ )?1:undef;
my $fullpth = undef;
my $sorttype = undef;
if( $depth < 1 || defined $drilled ){
for my $n($depth..$#pth){ 
if( $n == $depth ){ 
$fullpth = \%ord;$tt.= $pth[$n];if( !defined $fullpth->{$tt} ){ %{ $fullpth->{$tt} } = (); }$fullpth = $fullpth->{$tt}; 
$sorttype = ( $depth > 0 && defined $c{'defsort'}->{$tt.".$c{'htmlext'}"} )?$c{'defsort'}->{$tt.".$c{'htmlext'}"}:$c{'pagesort'};$fullpth->{'sorttype'} = $sorttype; 
} else { 
if( !defined $fullpth->{'pages'} ){ %{ $fullpth->{'pages'} } = ();}$fullpth = $fullpth->{'pages'};
if( defined $archive){ $tt = join $c{'delim'},@pth; } else {$tt = join $c{'delim'},@pth[0..$n];}
if( !defined $fullpth->{$tt} ){ %{ $fullpth->{$tt} } = ();}$fullpth = $fullpth->{$tt};
}
if( $n == $#pth ){ %{ $fullpth->{'data'} } = %{ $tmp[$i]->{'data'} };$fullpth->{'sorttype'} = $sorttype; }
}
}
}
}
##if( $ins eq "menureorder" ){
##sub_json_out({'check return_menus 1' => "ins:$ins n\n".Data::Dumper->Dump([\%ord],["ord"])." \n\n$c{'debug'} " },$c{'origin'},$c{'callback'});
##}
my @out = @{ sub_menu_sort(\%ord,{},$cref,$showall) };
my %men = %{ sub_menu_newmeta(\%ord,{}); };
##sub_json_out({'check return_menus 2' => "ins:$ins \nsitepage:$c{'sitepage'} \npagesort:$c{'pagesort'} \n\n".Data::Dumper->Dump([\%men],["men"])." \n\n".Data::Dumper->Dump([\@out],["out"])."\n\n$c{'debug'}"},$c{'origin'},$c{'callback'});
return ($err,\@out) if ($ins =~ /^view/ || $ins eq "searchpages" || $ins eq "editpages" );
##$Data::Dumper::Sortkeys = sub { [ sort { $_[0]->{$a} <=> $_[0]->{$b} || $a cmp $b } keys %{$_[0]} ] };
##sub_json_out({'check return_menus 3' => "ins:$ins \nsitepage:$c{'sitepage'} \nfilter:$c{'filter'} \npagesort:$c{'pagesort'} \n\n$dbug \n\nmen: ".Dumper(\%men)." \n\n$c{'debug'}"},$c{'origin'},$c{'callback'});
#%men = (
# 'index.html' => '000.0',
# 'Mainframe-Services.html' => '001.000',
# 'Mainframe-Services.Performance-Assurance.html' => '001.001.0',
# 'Mainframe-Services.Ad--Hoc-Skills-&-Resources:-Onsite-&-Remote.html' => '001.002',
# 'Mainframe-Services.Project-Delivery.html' => '001.003',
# 'Mainframe-Security.html' => '002.000',
# 'Mainframe-Security.Best-Practice-Health-Check.html' => '002.001',
# 'Mainframe-Security.Penetration-Testing.html' => '002.002',
# 'Mainframe-Skills.html' => '003',
# 'News.html' => '004.000',
# )
###sub_json_out({'check return_menus 4' => "ins:$ins \nsitepage:$c{'sitepage'} \n\npagesort:$c{'pagesort'} \n\n".Data::Dumper->Dump([\@out],["out"])." \n\n".Data::Dumper->Dump([\%men],["men"])." \n\n$c{'debug'}"},$c{'origin'},$c{'callback'});
$ntxt.= "\n<ul class=\"menu$pulled\">\n";
for my $i(0..$#out){ $ntxt.= sub_menu_return($out[$i],$i."-0",$c{'index_file'},$c{'homeurl'},( (defined $archive)?$archive:$c{'fullmenu'} ),$cref); }
$ntxt.= "</ul>";
###sub_json_out({ 'check return_menus 5' => "ntxt:$ntxt \n\n ".Dumper(\@out)." \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
if( $ins eq "menureorder" || (defined $c{'format'} && $c{'format'} eq "updatemenu") ){ 
my $stxt = "<ul class=\"sitemap\">\n";
for my $i(0..$#out){ $stxt.= sub_menu_return($out[$i],$i."-0",$c{'index_file'},$c{'homeurl'},"full",$cref); }
$stxt.= "</ul>";
###sub_json_out({ 'check return_menus 6' => "ntxt:$ntxt \n\nstxt:$stxt \n\n ".Dumper(\%men)." \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
my $filesref = (scalar @files > 0)?\@files:undef;
###sub_json_out({ 'check return_menus 7' => "dref:$dref \n\n".Data::Dumper->Dump([$filesref],["filesref"])."\n\n$c{'debug'}" },$c{'origin'},$c{'callback'});

my $merr = "";
my $mmsg = "";
my ($perr,$pmsg) = sub_menu_update($ins,$ntxt,$stxt,\%men,$cref,[$c{'base'}.$c{'site_file'}]);
$err = $perr if defined $perr;
$mmsg.= $pmsg if defined $pmsg;

if( defined $filesref ){
if( scalar @files > ($c{'pagelimit'} / 3) && defined $dref ){ 
my ($fbug,$ferr,$fmsg) = return_menu_fork( $filesref,sub { my ($sfile) = @_;return sub_menu_update($ins,$ntxt,$stxt,\%men,$cref,$sfile); },3,$cref);
$dbug.= $fbug."\n" if defined $fbug;
$err.= $ferr if defined $ferr;
$mmsg.= $fmsg if defined $fmsg;
###sub_json_out({ 'check return_menus 8' => "fmsg:\n$fmsg \nferr:$ferr \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
} else {
($merr,$mmsg) = sub_menu_update($ins,$ntxt,$stxt,\%men,$cref,$filesref);
$err.= $merr if defined $merr;
$msg.= $mmsg if defined $mmsg;
###sub_json_out({ 'check return_menus 9' => "mmsg:\n$mmsg \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
}
} else {
$mmsg.= "No files can be located to update.\n"; 
}

$msg.= $mmsg;
} else {
$msg = $ntxt;
}
return ($err,$msg);
}

sub return_menu_fork{
my ($fref,$subref,$pno,$cref) = @_;
my @files = @{$fref};
my @arrays = ();
my $pro = (defined $pno)?$pno:4;
my %c = %{$cref};
my %resp = ();
my $msg = "";
my $debug = "";
my $err = undef;
my $i = 0;
for my $file(sort @files){ if( $file !~ /$c{'site_file'}/ ){ push @{ $arrays[$i++ % $pro] },$file; } }
###sub_json_out({ 'check menu_fork 1' => "pro:$pro\n\n".Data::Dumper->Dump([\@arrays],["arrays"])." \n\n".Data::Dumper->Dump([\@files],["files"])." \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
$| = 1;
$debug.= "process = ($$) \n";
my $forks = 0;
foreach my $i(0..$#arrays){

my $pid = fork;
if( !defined $pid ){
###sub_log_out({ 'check menu_fork 2' => "$i - failed to fork $pid $array[$i]: $!\n\n $c{'debug'}" },$c{'base'});
next;
}
if ($pid ){ #parent end
$forks++;
$debug.= "parent ($$) = child $forks ($pid) starts \n";
###return ($debug,$err,"@files");
} else { #child
close STDOUT;
my ($serr,$smsg) = $subref->($arrays[$i]);
if( defined $serr ){ $msg.= "warning: $serr \n"; } else { $msg.= "$smsg \n"; }
###sub_log_out({ 'check menu_fork 3' => "$i = pro:$pro \n\n".Data::Dumper->Dump([\$arrays[$i]],["array $i"])."\n\n mmsg: $msg \nerr:$err \n\n $debug \n $c{'debug'}" },$c{'base'});
exit;
}

}
sleep 2;
###for my $i (1..$forks){ my $pid = wait();$debug.= "parent ($$) = child $i ($pid) exits \n"; }
###sub_json_out({ 'check menu_fork 4' => "debug:$debug \nerr:$err \nmsg:$msg \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
return ($debug,$err,$msg);
}

sub sub_return_pagedata{
my ($ins,$f,$elsref,$ntxt,$amount,$start,$random,$err,$cref) = @_;
my %c = %{$cref};
my @els = @{$elsref};
my %jout = ();
my @fout = ();
my $purl = $c{'sitepage'};
my $pfil = "";
if($ins eq "archivelist"){ $pfil= 'data-filter="editarchive"';$purl = $f;$purl =~ s/^($c{'base'})//;$purl.= 'index.html' unless $purl =~ /\.index$/; }
my $pgn = "";
my $dbug = "";
###sub_json_out({ 'check return_pagedata' => "ins: $ins \namount:$amount \nstart:$start \nrandom:$random \n [ \n ".( join "\n--\n\n",@els )."\n ]\n\nformat:$c{'format'} \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
if( scalar @els > 0 ){
if( $ins =~ /(index|archivelist)/ ){
my @pag = ();
my $cc = 0;
my $gcc = 0;
my $tcc = 0;
for my $i(0..$#els){
$cc++;
$tcc++;
if( $amount < 1){
push @fout,$els[$i];$dbug.= "$i = amount:[$amount] cc:[$cc] = adding $els[$i]\n>";
} else {
if( $cc >= $start && $cc < ($start+$amount) ){ push @fout,$els[$i];$dbug.= "$i = amount:[$amount] cc:[$cc] = adding $els[$i]\n"; }
if( $tcc <= $amount ){ $tcc++; }
if( $#els > $amount - 1 ){ 
my $am = ($amount > 0 && $cc % $amount == 0)?1:undef;
if( $cc == 1 || defined $am ){ $gcc++;my $st = ( defined $am )?(1+$cc):$cc;my $hi = ( $start == $st )?" class=\"hipage\"":"";push @pag,"<div><a$hi data-id=\"$ins\" data-sort=\"$c{'pagesort'}\" $pfil data-scroll=\"on\" data-amount=\"$amount\" data-start=\"$st\" data-position=\"$c{'position'}\" data-format=\"$c{'format'}\"$c{'attri'} href=\"$purl\">$gcc</a></div>";$tcc = 0; } 
}
}
}
if( $amount > 0 ){
my $pgg = join "&#160;",@pag;
#<div class="paginate"><div><a data-id="index" data-start="1" data-amount="6" data-exclude="me" data-format="stacker" href="News.html" title="view News">News</a></div>&#160<a data-id="index" data-sort="21" data-start="7" data-amount="6" data-format="stacker" href="News.html" title="view News">News</a></div></div>
$pgn = "<li class=\"column pagination\">$pgg</li>"; 
}
} else {
@fout = @els;
if( defined $random && scalar @fout >= $random){ @fout = sub_get_random(\@fout,$#fout); }
if( defined $amount && $amount > 0 && scalar @fout > $amount ){ @fout = @fout[0..($amount-1)]; }
###sub_json_out({ 'check return_pagedata 1' => "amount:$amount \nrandom:$random \n [ \n ".( join "\n--\n\n",@fout )."\n ]\n\nformat:$c{'format'} \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
}
###sub_json_out({ 'check return_pagedata 2' => "ins: $ins \namount:$amount \nstart:$start \nrandom:$random \n [ \n ".( join "\n--\n\n",@fout )."\n ]\n\nformat:$c{'format'} \n\n$dbug" },$c{'origin'},$c{'callback'});
if( $c{'format'} eq "slideshow" ){
if($ins eq "area"){ $ntxt = "@fout"; } else { $ntxt = "<li class=\"column tt_slideshow-inner slide tt_undisplay\">".(  join "</li>\n<li class=\"column tt_slideshow-inner slide tt_undisplay\">",@fout )."</li>\n"; }
} elsif( $c{'format'} eq "stacker" ){
$ntxt = "<li class=\"column tt_stacked\">".(  join "</li>\n<li class=\"column tt_stacked\">",@fout )."</li>\n"
} else {
if( defined $c{'pagewrap'} ){ $ntxt = "<div class=\"viewpulled\">".(  join "</div>\n<div class=\"viewpulled\">",@fout )."</div>\n"; } else { $ntxt = join "\n",@fout; }
}
if( $ins =~ /(index|archivelist)/ && $pgn ne "" && $amount > 0 ){ $ntxt.= $pgn; }
} else {
$err = "alert return_pagedata: $ins = $f = $ntxt no page list available $! "; 
}
%jout = ('result' => $ntxt);
return ($err,\%jout);
}

sub sub_return_pages{
#<div class="row editblock tt_services tt_digital-outcomes">
#<div class="editimage"><div class="text"><a title="view page" href="News_GSE-2016.html" style="background-image:url(documents/Images/news/RSM__header_mobile.jpg);" class="editimage">&#160;</a>#<div class="editimage"><div class="text">
#<div class="editititle"><div class="text"><a title="view page" href="News_GSE-2016.html" class="edittitle">RSM showcases security software suite at GSE 2016</a>#<div class="editimage"><div class="text">
#<div class="edittext"><div class="text"><p>3rd October 2016: At this year's GSE Conference on 1-2 November 2016 in Northampton solutions. <a title="view page" href="News_GSE-2016.html" class="editmore">&#160;</a></p></div.</div>
#</div>
my ($ins,$f,$outref,$cref,$enref,$evref,$ex) = @_;
my @mout = @{$outref};
my %c = %{$cref};
my @editnames = @{$enref};
my @editvalues = @{$evref};
my @bks = ();
my %jout = ();
my %ord = ();
my %arclist = ();
my @els = ();
my $archivefolder = $c{'docview'}."Archive/";
my $archive = (defined $c{'filter'})?$c{'filter'}:undef;if(defined $archive){ $archive =~ s/^edit//; }
my $filtered = ($ins eq "menu" && defined $archive && $f !~ /($archivefolder)/i )?$archive:undef;
my $adepth = ( $ins eq "archive" && defined $archive && $f =~ /\/([0-9][0-9][0-9][0-9])\/$/)?1:undef; #/Archive/Group-News/2017/ Archive/News/2017/ 
my $ntxt = "";
my $dbug = "";
###sub_json_out({'check return_pages' => "f: $f \nex: $ex \nins:$ins \nsite file:$c{'site_file'} \nadepth:$adepth \narchive:$archive \nfiltered:$filtered \npagesort:$c{'pagesort'} \nformat:$c{'format'} \nposition: $c{'position'} \nclsdata: $c{'clsdata'} \n\n ".Data::Dumper->Dump([\@editnames],["editnames"])." \n\n ".Data::Dumper->Dump([\@editvalues],["editvalues"])."\n\n".Data::Dumper->Dump([\@mout],["mout"])." \n\n$c{'debug'}"},$c{'origin'},$c{'callback'});
my @tmp = sub_default_sort($c{'pagesort'},\@mout);
for my $i (0..$#tmp ){ 
my $bhref = @{ $tmp[$i]->{'data'}{'link'} }[0] || @{ $tmp[$i]->{'data'}{'url'} }[0];
my $bsname = @{ $tmp[$i]->{'data'}{'shortname'} }[0];
my $group = (defined $archive && defined $tmp[$i]->{'data'}{$archive} )?$tmp[$i]->{'data'}{$archive}[0]:undef;
if( ref $tmp[$i] eq ref {} && $bhref !~ /($c{'site_file'})$/ ){ 
my $ok = undef;
if( !defined $ex || $bhref !~ /($ex)$/ ){
if( scalar @editnames > 0){ 
for my $k(0..$#editnames){ 
my $ed = $editnames[$k];$ed =~ s/^edit//i;$dbug.= "$k: $ed = $editvalues[$k] == ".@{ $tmp[$i]->{'data'}{$ed} }[0]." \n";
if( defined $tmp[$i]->{'data'}{$ed} && scalar @{ $tmp[$i]->{'data'}{$ed} } > 0 ){
if( $ins eq "archive"){ if( defined $adepth || @{ $tmp[$i]->{'data'}{$ed} }[0] ne "" ){ $ok = 1;
if(defined $editvalues[$k] && @{ $tmp[$i]->{'data'}{$ed} }[0] =~ /$editvalues[$k]/i){  @{ $tmp[$i]->{'data'}{'navoff'} }[0] = $editvalues[$k]; } 
} } else { if(defined $editvalues[$k] && @{ $tmp[$i]->{'data'}{$ed} }[0] =~ /$editvalues[$k]/i){$ok = 1;} }
}
}
} else {
$ok = ( $ins =~ /^(index|menu|list)$/ && $bhref eq $c{'sitepage'} )?undef:1;
}
}
$dbug.= "\n".$tmp[$i]->{'data'}{'url'}[0]." ok:$ok editnames:[ ".( scalar @editnames )." ] editvalues: [ @editvalues ] adepth:$adepth \nbhref:$bhref == sitepage:$c{'sitepage'} \n";
if( defined $ok ){
if( defined $adepth || ($ins eq "archive" || defined $filtered) ){
my $dir = $f; $dir =~ s/^($c{'base'})//;
$dbug.= "is archive = dir:$dir = url: $tmp[$i]->{'data'}{'url'}[0] archive: $group \n";
if( defined $filtered && defined $tmp[$i]->{'data'}{$filtered} ){
my @amon = @{ $tmp[$i]->{'data'}{$filtered} };if( !defined $arclist{$amon[0]} ){ $arclist{$amon[0]} = '<li><a class="pulledlink nav-'.( lc $amon[0] ).'" href="../cgi-bin/view.pl?url='.$dir.'&id=index&amount=9&format=stacker&position=lower&pulled=1&names='.$c{'filter'}.'&values='.( $uri->encode($amon[0]) ).'" title="link to '.$amon[0].' News">'.$amon[0].'</a></li>'."\n"; }
} else {
if( defined $group && !defined $arclist{$group} ){ 
$arclist{$group} = '<li><a class="pulledlink nav-'.( lc $group ).'" href="../cgi-bin/view.pl?url='.$dir.'&id=index&amount=9&format=stacker&position=lower&pulled=1&filter='.$c{'filter'}.'&values='.( $uri->encode($group) ).'" title="link to '.$dir.$group.' Archive">'.$group.'</a></li>'."\n";
#'<li><a class="pulledlink nav-'.( lc $group ).'" href="../cgi-bin/view.pl?url='.$dir.'&id=index&values='.( $uri->encode($group) ).'&filter='.$c{'filter'}.'" title="link to '.$dir.$group.' Archive">'.$group.'</a></li>'."\n"; 
}
}
} else {
@bks = ( defined $tmp[$i]->{'data'}{'blocks'} )?@{ $tmp[$i]->{'data'}{'blocks'} }:();
if( defined $archive && $bhref !~ /^($archivefolder)/i ){ $bhref = $archivefolder.$bhref; }
my $focus = ( defined $tmp[$i]->{'data'}{'focus'} )?"tt_".lc @{ $tmp[$i]->{'data'}{'focus'} }[0]:"";$focus =~ s/ /-/g;if($focus ne ""){$focus = " ".$focus;}
my $area = ( defined $tmp[$i]->{'data'}{'area'} )?"tt_".lc @{ $tmp[$i]->{'data'}{'area'} }[0]:"";$area =~ s/ /-/g;if($area ne ""){$area = " ".$area;}
my $alk = ( $c{'format'} eq "slideshow" || $c{'format'} eq "stacker" )?"\n<a class=\"editlink\" href=\"".$bhref."\" title=\"".$bsname."\">&#160;</a>":"";

for my $j(0..$#bks){
$dbug.= "--> blocks $j = $bks[$j]\n";
my $nar = (defined $archive && defined $group)?' data-'.( lc $archive ).'="'.( lc $group ).'"':'';
$bks[$j] =~ s/<div class="row editblock pulled">/<div class="row editblock$area$focus pulled"$nar>$alk/;
if( $c{'format'} eq "slideshow" ){
if( defined $c{'clsdata'} ){ $bks[$j] =~ s/(<div class="edittext">)/<div class="edittext tt_slider tt_animate $c{'clsdata'}"><div class="slidertitle"><span class="tt_show">$bsname<\/span><span class="tt_hide">@{ $tmp[$i]->{'data'}{'title'} }[0]<\/span><\/div>/; }
} elsif( $c{'format'} eq "stacker" ){
if( defined $c{'position'} && $c{'position'} eq "lower" ){
$bks[$j].= '<div class="row editblock pulled"><div class="edittext"><div class="text"><p><a title="view page" href="'.$bhref.'" class="editmore">&#160;</a></p></div></div></div>';
} else {
$bks[$j] = '<div class="row editblock pulled"><div class="edittext '.$c{'type'}.'"><div class="text"><p><a title="view page" href="'.$bhref.'" class="editmore">&#160;</a></p></div></div></div>'.$bks[$j];
}
} else { 
$bks[$j] =~ s/(<div class="editimage\s*">\s*<div class="text" style=".*?">).*?(<\/div>\s*<\/div>)/$1<a class="pulledlink" href="$bhref" title="$bsname">\&#160;<\/a>$2/; 
}
my $ps = $bks[$j];if( $c{'format'} ne "stacker" && $ps =~ /(<p.*?)<\/p>/ism ){ $ps = $1.' <a title="view page" href="'.$bhref.'" class="editmore">&#160;</a></p>';$dbug.= "$j: ".$ps."\n";$bks[$j] =~ s/<p.+<\/p>/$ps/ism; }
push @els,$bks[$j];
}
}
#$dbug.= "$i = bhref:$bhref = ex:$ex = ok:$ok ".( scalar @els )." (epoch:".@{ $tmp[$i]->{'data'}{'epoch'} }[0]." = published:".@{ $tmp[$i]->{'data'}{'published'} }[0].") rank:".@{ $tmp[$i]->{'data'}{'menu'} }[0]."\n";
}
} 
}
my @sbase = ();
my $nf = undef;
my $upf = undef;
if( defined $adepth || $ins eq "archive" || defined $filtered ){
my @aout = ();
$nf = $f;$nf =~ s/^($c{'base'})($archivefolder)//i; #News/ or 2017/Group-News/
@sbase = split /\//,$nf; #sbase: [ News ] or [ 2017 Group-News ]
my $fbase = $archivefolder.( join "\/",@sbase ); # documents/Archive/News or documents/Archive/2017/Group-News
my $fname = pop @sbase;$fname = sub_title_out($fname,$cref); #News or Group News
my $upbase = $archivefolder.( (scalar @sbase > 0)?join "\/",@sbase:"" ); # documents/Archive or documents/Archive/2017
my $upname = (scalar @sbase > 0)?pop @sbase:"Archive";$upf = sub_title_out($upf,$cref);  # "Archive" or 2017
for my $k(keys %arclist){ my $am = $MNS{lc $k};if(defined $am){$aout[$am] = $arclist{$k};} }
$upf = ($upbase ne $archivefolder && $upbase ne $fbase)?"<li><a href=\"$upbase\" title=\"link to $upname Archive folder\">$upname Archive</a></li>\n":"";
if( defined $filtered){
@els = ( "<ul class=\"menu pulled\"><li><ul>\n".( join "\n",@aout )."</ul></li></ul>\n" );
} else {
@els = ( "<ul class=\"menu pulled\"><li><ul>$upf<li><a href=\"$fbase/index.html\" title=\"link to Archive\" target=\"_blank\">$fname</a></li>\n".( join "\n",@aout )."</ul></li></ul>\n" );
}
###sub_json_out({'check return_pages 1' => "ins:$ins \nf:$f \nnf:$nf \nsbase: [ @sbase ] \nformat:$c{'format'} \npagesort:$c{'pagesort'} \nex:$ex \nfiltered:$filtered \narchive:$archive \nclsdata: $c{'clsdata'} \n\n".Data::Dumper->Dump([\%arclist],["arclist"])." \n\n".Data::Dumper->Dump([\@els],["els"])." \n\n ".Data::Dumper->Dump([\@editnames],["editnames"])." \n\n ".Data::Dumper->Dump([\@editvalues],["editvalues"])." \n\n ".Data::Dumper->Dump([$cref],["editnames"])." \n\ndbug: $dbug \n\n$c{'debug'}"},$c{'origin'},$c{'callback'});
}
###sub_json_out({'check return_pages 2' => "ins:$ins \nf:$f \nformat:$c{'format'} \npagesort:$c{'pagesort'} \nex:$ex \nfiltered:$filtered \narchive:$archive \nclsdata: $c{'clsdata'} \n\n".Data::Dumper->Dump([\%arclist],["arclist"])." \n\n".Data::Dumper->Dump([\@els],["els"])." \n\n ".Data::Dumper->Dump([\@editnames],["editnames"])." \n\n ".Data::Dumper->Dump([\@editvalues],["editvalues"])." \n\n ".Data::Dumper->Dump([$cref],["cref"])." \n\ndbug: $dbug \n\n$c{'debug'}"},$c{'origin'},$c{'callback'});
return @els;
}

sub sub_search_aux{
# odir:/var/www/vhosts/pecreative.co.uk/rsmpartners.com/ /var/www/vhosts/pecreative.co.uk/rsmpartners.com/UPLOADS/RESTORE/RSM-Test-Site~~11:01:02-17--11--2017/
# ndir: /var/www/vhosts/pecreative.co.uk/rsmpartners.com/UPLOADS/RESTORE/RSM-Test-Site~~11:01:02-17--11--2017/ /var/www/vhosts/pecreative.co.uk/rsmpartners.com/ 
# aux: /var/www/vhosts/pecreative.co.uk/rsmpartners.com/library.css /var/www/vhosts/pecreative.co.uk/rsmpartners.com/UPLOADS/RESTORE/RSM-Test-Site~~11:01:02-17--11--2017/library.css
my ($odir,$ndir,$aref,$findref,$repref,$cref) = @_;
my @aux = (defined $aref)?@{$aref}:();
my %c = %{$cref};
$odir =~ s/(\/+)$//;
$ndir =~ s/(\/+)$//;
my $dbug = "";
for my $i(0..$#aux){ 
$aux[$i] =~ s/^(.+\/)//;
if( -f $odir.'/'.$aux[$i] ){
if( $aux[$i] =~ /\.(css|js|pm|pl|xml)$/){
my ($ierr,$otxt) = sub_get_contents($odir."/".$aux[$i],$cref);$dbug.= "warning: $ierr\n" if defined $ierr;
my %sr = sub_search_string($otxt,$findref,$repref,undef,undef,"code",$cref);
if( scalar keys %{$sr{'matches'}} > 0 ){ $otxt = $sr{'new'}; }
my $nerr = sub_page_print($ndir."/".$aux[$i],$otxt);
$dbug.= (defined $nerr)?"$nerr\n":" copied ok\n";
} else {
cp ($odir.'/'.$aux[$i],$ndir.'/'.$aux[$i]) or $dbug.= "error: copy ".$odir."/".$aux[$i]." to ".$ndir."/".$aux[$i]." failed: $! \n";
}
}
}
return $dbug;
}

sub sub_search_file{ 
my ($f,$c,$oldref,$nobound) = @_;
local @ARGV = ($f);
###local $^I = ''; #local($^I) = '.bak';
my @old = @{$oldref};
my %res = ();
my %found = ();
while (<>){ 
for my $i(0..$#old){
if( $_ =~ m/(>|\G)([^<]*?)($old[$i])/i ){ #not in tags
$found{$old[$i]} = 1;
@{ $res{$old[$i]} } = () if !defined $res{$old[$i]};
if(defined $nobound){ 
if( $_ =~ m/^(.*?)($old[$i])(.*?)$/i ){ push @{ $res{$old[$i]} },$1."x_X_x".$2."y_Y_y".$3;$c++; }
} else { 
if($_ =~ m/^(.*?)(\b$old[$i]\b)(.*?)$/i ){ push @{ $res{$old[$i]} },$1."x_X_x".$2."y_Y_y".$3;$c++; }
}
} 
}
} # continue { }
return ( scalar keys %found >= scalar @old )?[$c,\%res]:[0,{}];
}

sub sub_searchreplace_file{ #my $c = 0;@{ $results{$fh} } = @{ sub_searchreplace_file($n,$c,\@old,\@new,$nobound) };
my ($f,$c,$oldref,$newref,$nobound) = @_;
local @ARGV = ($f);
local $^I = ''; #local($^I) = '.bak';
my @old = @{$oldref};
my @new = @{$newref};
my %res = ();
while (<>){ 
for my $i(0..$#old){
my $nw = (defined $new[$i])?$new[$i]:undef; 
if( defined $nw){
@{ $res{$old[$i]} } = () if !defined $res{$old[$i]};
if( defined $nobound ){ if($_ =~ m/$old[$i]/){ $_ =~ s/^(.*?)($old[$i])(.*?)$/$1$nw$3/;push @{ $res{$old[$i]} },$1."x_X_x".$2."y_Y_y".$3;$c++; } } else { if($_ =~ m/\b$old[$i]\b/){$_ =~ s/^(.*?)(\b$old[$i]\b)(.*?)$/$1$nw$3/;push @{ $res{$old[$i]} },$1."x_X_x".$2."y_Y_y".$3;$c++; } }
}
}
print;
} # continue { }
return [$c,\%res];
}

sub sub_search_string{
# $sr = {
# 'matches' => { '5' => '<div class="text" style="background-image: url(documents/Images/news/RSM__header_mobile.jpg);">&#160;</div> ' },
# 'result' => '<strong>Found <u>1</u> instance of <i>documents/Images/news/</i> in <u>editable text</u>: </strong><emp>- line 5: <i>&lt;div class=&quot;text&quot; style=&quot;background-image: url(<u>documents/Images/news/</u>RSM__header_mobile.jpg);&quot;&gt;&amp;#160;&lt;/div&gt; </i></emp>',
# 'old' => '<div class="row editblock"><div class="editimage"><div class="text" style="background-image: url(documents/Images/news/RSM__header_mobile.jpg);">&#160;</div></div></div>',
# 'new' => '<div class="row editblock"><div class="editimage"> <div class="text" style="background-image: url(RSM__header_mobile.jpg);">&#160;</div> </div></div>',
# 'totals' => [ 1,1 ]
# };
my ($txt,$findref,$repref,$regex,$case,$ty,$cref,$where,$bug) = @_;
my @terms = @{ $findref };
my @reps = @{ $repref };
my %c = %{$cref};
my %h = ( 'old' => $txt,'matches' => {},'totals' => {} );
my %eds = {};foreach my $ar( sort keys %{ $c{'editareas'} } ){ if( $c{'editareas'}{$ar} > 1 ){ $eds{$ar} = $ar." tag"; } }
my $dbug = "";
###if($ty eq "blocks"){
###if($ty eq "code"){
###if(defined $bug){
###sub_json_out({ 'check search_string in' => "txt: $txt \n\nty: $ty \nterms: [ @terms ] \n reps: [ @reps ] \n regex:$regex \ncase: $case \n\n $c{'debug'}" },$c{'origin'},$c{'callback'});
###}
for my $i( 0..$#terms){
my $tm = $terms[$i];
my $rp = $reps[$i];
my $ourl = ($tm =~ /\.($c{'htmlext'})$/)?sub_title_out($tm,$cref):undef;
my $nurl =  ($rp =~ /\.($c{'htmlext'})$/)?sub_title_out($rp,$cref):undef;
if( !defined $h{'totals'}{$tm} ){ $h{'totals'}{$tm} = 0; }
#if( defined $ty && $ty eq "links" ){ $tm =~ s/\&/&#38;/g;$rp =~ s/\&/&#38;/g; }
my $tt = (defined $rp && $rp ne "")?"and replaced ":""; 
my @found = ();
my $co = 0;
if( !defined $regex ){ $tm = quotemeta $tm; }
my $pattern = (defined $case)?"(?s)$tm":"^(.*$tm.*)\$"; ###$dbug.= "@terms = $pattern \n";
while ($txt =~ /$pattern/gim){ 
my $got = $1; ###$dbug.= "got:$got === pattern:$pattern ";
my $def = $got;
my $prev_lines = substr( $txt,0,pos($txt) ) =~ tr/\n//+1;
my $got_lines = $got =~ tr/\n//;
my $foundline = $prev_lines - $got_lines;
$co++;
my $wdef = $def;$wdef =~ s/($tm)/<u>$1<\/u>/img;
my $edef = encode_entities($def);my $ecap = $edef;my $etm = encode_entities($tm);$edef =~ s/($etm)/<u>$1<\/u>/img;
if($tt ne ""){
if($ty eq "code"){
my $erp = encode_entities($rp);$ecap =~ s/$etm/<u>$erp<\/u>/img;
push @found,"- line $foundline: <i>$edef</i> became <i>$ecap</i>\n";
} else {
$wdef =~ s/$tm/$rp/img;
push @found,"<i>$def</i> became <i>$edef</i>\n";
}
$h{'matches'}{$foundline} = $def;
} else {
if($ty eq "code"){
push @found,"- line $foundline: <i>$edef</i>\n";
} else {
push @found,( (defined $where && $ty eq "blocks")?"- line $foundline: ":"" )."<i>$edef</i>\n";
}
$h{'matches'}{$foundline} = $def;
}
}
if( defined $where ){ $dbug.= "\n<strong>Found $tt<b>$co</b> instance".( ($co > 1)?"s":"" )." of <i>$terms[$i]</i>"; }
my $ed = ( defined $c{'user'} )?"editable ":""; 
if( defined $where ){ 
$dbug.= " in <u>".(  ($ty =~ /^(url|link)$/i)?"page $ty":($ty eq "name")?"page title":($ty eq "blocks")?$ed."text":( defined $eds{$ty} )?$eds{$ty}:$ty )."</u>"; 
$dbug.= "".( ($tt ne "")?" with <i>$rp</i>":"" ).": </strong>\n<emp>".( join "</emp><emp>",@found )."</emp>\n";
}
$h{'totals'}{$terms[$i]}+= $co;
if($co > 0){ 
if( defined $ourl && defined $nurl && $txt =~ /><a href="$tm">(.*?)<\/a><\/li>/i ){ $txt =~ s/<a href="$tm">(.*?)<\/a><\/li>/<a href="$rp">$nurl<\/a><\/li>/gi; } ###$dbug.= "co:$co ourl:$ourl = replace $1 with $nurl \n\n";
if(defined $case){ $txt =~ s/$tm/$rp/gism; } else { $txt =~ s/$tm/$rp/gim; }
$h{'new'} = $txt; 
} ###$dbug.= "$txt == replaced with $rp\n\n";
}
$h{'result'} = $dbug;
###if( $ty eq "blocks"){ ###if( $ty eq "code"){ ###if(defined $bug){
###sub_json_out({ 'check search_string out' => "ty: $ty \nterms: [ @terms ] \n\n reps: [ @reps ] \n\n regex:$regex \ncase: $case  \n\ndbug == $dbug \n\n".Data::Dumper->Dump([\%h],["h"])."\n\n \ntxt: $txt \n $c{'debug'}" },$c{'origin'},$c{'callback'});
###}
return %h;
}

sub sub_sitemap_replace{ my ($ntxt,$rep) = @_;my @c = $ntxt =~ s/(\s*<ul class="sitemap">.*?<\/ul>)(\s*<\/div>)/$rep$2/gism;return ($ntxt,"replaced: ".scalar @c." in sitemap\n"); }

sub sub_split_attributes{
my ($s) = @_;
my @at = ();
my @as = split /\b.*?=".*?"/,$s; #<div style="margin-top: 0px;" id="tt_alldiv" class="tt_tmp box-shadow1">
for my $i(0..$#as){
if($as[$i] =~ /^(.*?)="(.*?)"$/){ push @at,"\"$1\":\"$2\""; }
}
return @at;
}

sub sub_title_deslash{
my ($u,$dref) = @_; 
my $dirs = join "|",@{$dref};
$u =~ s/^($dirs)(%2F|%252F|~)(.*?\.html)/$1\/$3/i; #members~Members.Competition2.html
$u =~ s/(%26|%2526)/&/g; #Privacy-Policy-&-Legal-Disclaimer.html
return $u;
}

sub sub_title_in{
#Ad-Hoc Skills & Resources: Onsite & Remote Dave's
my ($h,$cref) = @_;
my $n = $h;
my %c = %{$cref};
$n =~ s/($c{'docspace'})/====/g;
$n =~ s/ /$c{'docspace'}/g;
$n =~ s/====/$c{'docspace'}$c{'docspace'}/g;
$n =~ s/($c{'repdash'})($c{'repdash'})/\+\+/g;
$n =~ s/\//$c{'repdash'}/g;
$n =~ s/\+\+/$c{'repdash'}/g;
$n =~ s/\&#38;/&/;
$n =~ s/:/;/g;
$n =~ s/'/^/g; #'
$n =~ s/\?$/^^/; #'
return $n;
}

sub sub_title_out{
#This-Page.html
#newest/News.RSM-Awarded-Government-Supplier;-Status-Dave^s.html
my ($h,$cref) = @_;
my %c = %{$cref};
my $n = $h;
$n =~ s/^(.+\/)//i;
$n =~ s/\.($c{'fxfile'})$//i;
$n =~ s/^.+($c{'qqdelim'})//i;
$n =~ s/($c{'docspace'})($c{'docspace'})($c{'docspace'})($c{'docspace'})/ ==== /g;
$n =~ s/($c{'docspace'})($c{'docspace'})/====/g;
$n =~ s/($c{'docspace'})/ /g;
$n =~ s/====/$c{'docspace'}/g;
$n =~ s/($c{'repdash'})($c{'repdash'})/\+\+/g;
$n =~ s/$c{'repdash'}/\//g;
$n =~ s/\+\+/$c{'repdash'}/g;
$n =~ s/;/:/g;
$n =~ s/\^\^$/?/; #'
$n =~ s/\^/'/g; #'
$n =~ s/\&/&#38;/g;
return $n;
}

sub sub_title_undate{ my ($s,$cref) = @_;my %c = %{$cref};$s =~ s/^.+$c{'repdash'}$c{'repdash'}(.*?)\.$c{'htmlext'}$/[ $1/i;$s =~ s/($c{'qqdelim'})/./g;$s =~ s/([0-9])$c{'docspace'}([0-9])/$1 ] $2/;$s =~ s/$c{'docspace'}$c{'docspace'}/$c{'docspace'}/g;return $s; } # http://rsmpartners.com/VERSIONS/Contact~~14_07_57-19--07--2017.html 

sub sub_zip_file{
my ($u,$zip,$cref,$repref,$oldurl) = @_;
my %c = %{$cref};
my $ts = "@{$c{'titlesep'}}";
my $nz = $u;$nz =~ s/^($c{'base'})//i;$nz =~ s/^\///;
my $msg ="";
if( $nz =~ /\.($c{'htmlext'})$/ ){
if( defined $repref ){ 
my ($nferr,$otxt) = sub_admin_new('page',$u,undef,$repref,$cref,'nomenus');
$msg.= "[file > html] add $nz $nferr\n";
$zip->addString(encode("utf8",$otxt),$nz); 
###if( $u =~ /Group_Sustainability_Act-On-CO2-at-DenmaurA.html$/){
###sub_json_out({ 'debug' => "check zip_out: u: $u \n\n $otxt \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
###}
} else {
$msg.= "[file > htmlfile] add $nz \n";
$zip->addFile($u,$nz);
}
} elsif( $nz =~ /\.(htaccess|js|pm)$/i ){
my ($ierr,$otxt) = sub_get_contents($u,$cref);$msg.= "warning: $ierr\n" if defined $ierr;
###if( $u =~ /defs\.pm$/){
###sub_json_out({ 'debug' => "check zip_out: u: $u \n\n $otxt \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
###}
if( defined $repref ){ 
my %sr = sub_search_string($otxt,[ $oldurl,$ts,$c{'otitle'} ],[ $repref->{'new-baseurl'},@{$c{'titlesep'}}[0]." ".$repref->{'new-baseid'},$repref->{'new-baseid'} ],undef,undef,"code",$cref); #[thegatemaker.pecreative.co.uk,- The Gate Maker,The Gate Maker] [rsmpartners.com,- RSM Partners,RSM Partners]
$msg.= "[file > auxstring] add $nz (matches:".( scalar keys %{$sr{'matches'}} || 0 ).") $ierr\n";
###$msg.= "\n\n".Data::Dumper->Dump([\%sr],["sr"])."\n\n";
if( scalar keys %{$sr{'matches'}} > 0 ){ $otxt = $sr{'new'}; }
} else {
$msg.= "[file > auxfile] add $nz \n";
}
$zip->addString(encode("utf8",$otxt),$nz); 
} elsif( -d $u ){ 
$msg.= "[file > dir?] = $u $nz"; #$msg.= sub_zip_dir($u,$zip,$cref,$repref);
} else {
$msg.= "[file > file] add $nz \n";
$zip->addFile($u,$nz);
}
return $msg;
}

sub sub_zip_dir{
my ($fz,$zip,$cref,$repref,$oldurl) = @_;
my %c = %{$cref};
my $ts = "@{$c{'titlesep'}}";
my $msg ="";
my $nz = $fz;$nz =~ s/^($c{'base'})//;$nz =~ s/^\///;
if($fz !~ /\/$/){$fz.="/";}
find(sub { 
my $n = $File::Find::name;
if( $n ne $fz ){
my $nz = $n;$nz=~ s/^($c{'base'})//;$nz =~ s/^\///;
if( -f $n ){
if( $nz =~ /\.($c{'htmlext'}|css|htaccess|js|pm)$/i ){
#$msg.= "[dir > aux] adding file $n as $nz \n";
my ($ierr,$otxt) = sub_get_contents($n,$cref);$msg.= "warning: $ierr\n" if defined $ierr;
###if( $nz =~ /defs\.pm$/){
###sub_json_out({ 'debug' => "check zip_out: nz: $nz \n\n $otxt \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
###}
if(defined $repref){
my %sr = sub_search_string($otxt,[ $oldurl,$ts,$c{'otitle'} ],[ $repref->{'new-baseurl'},@{$c{'titlesep'}}[0]." ".$repref->{'new-baseid'},$repref->{'new-baseid'} ],undef,undef,"code",$cref); #[thegatemaker.pecreative.co.uk,- The Gate Maker,The Gate Maker] [rsmpartners.com,- RSM Partners,RSM Partners]
$msg.= "[dir > html+aux] add string $nz (matches:".( scalar keys %{$sr{'matches'}} || 0 ).") $ierr\n";
###$msg.= "\n\n".Data::Dumper->Dump([\%sr],["sr"])."\n\n";
if( scalar keys %{$sr{'matches'}} > 0 ){ $otxt = $sr{'new'}; }
}
$zip->addString(encode("utf8",$otxt),$nz);
} else {
$msg.= sub_zip_file($n,$zip,$cref,$repref); #$zip->addFileOrDirectory($File::Find::name,$n); 
}
} elsif( -d $n){
$zip->addDirectory($n,$nz);
} else {
$msg.= "[dir > ?] unknown file $n \n";
}
}
},$fz);
return $msg;
}

sub sub_zip_in{
# $members = [ bless({
# 'externalFileName' => '/var/www/vhosts/pecreative.co.uk/revive.pecreative.co.uk/admin/BACKUP/revivepecreativecouk02-01-2018.zip',
# 'uncompressedSize' => 27366,
# 'fileName' => 'Paper-and-Sustainability-Facts.html',
# 'fileAttributeFormat' => 3,
# 'lastModFileDateTime' => 1277322665
# },'Archive::Zip::ZipFileMember' ) ]
my ($u,$n,$cref) = @_; #u:/var/www/vhosts/pecreative.co.uk/revive.pecreative.co.uk/admin/BACKUP/ n:revivepecreativecouk02-01-2018.zip
my %c = %{$cref};
my $msg = "";
my $dbug = "";
my $err = undef;
###sub_json_out({ 'check zip_in' => "u: $u \nn:$n \nimported:[ @imported ] \nimp:$imp \ndbug:dbug \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
eval "use Archive::Zip qw( :ERROR_CODES :CONSTANTS )";
if( $@ ){ $msg = "Unfortunately this server can't use Archive::Zip: $@ "; } else {
eval "use Archive::Zip::MemberRead";
if( $@ ){ $msg = "Unfortunately this server can't use Archive::Zip::MemberRead: $@ "; } else {
eval "use File::Temp qw(:seekable tempfile tempdir)";
if( $@ ){ $msg = "Unfortunately this server can't use File::Temp: $@ "; } else {
my $zip = Archive::Zip->new();
my $status = $zip->read($u.$n);
if( $status != "AZ_OK" ){ try { die "zip_in: read $u$n failed: $!"; } catch { $err = "zip_in: read $u$n failed: $_ \n"; }; }
if( !defined $err){
my @members = $zip->memberNames();
foreach my $mname (@members){
$dbug.= "Extracting $mname:";
if( -e $c{'base'}.$mname ){ my $dferr = sub_admin_delete("item",$c{'base'}.$mname,$cref);if(defined $dferr){$dbug = "error deleting $c{'base'}$mname: $dferr \n";} else {$dbug.= " (replaced) ";} } else { $dbug.= " (new) "; }
$status = $zip->extractMember($mname,$c{'base'}.$mname); #$zip->extractMemberWithoutPaths($memberName)
$dbug.= ($status != "AZ_OK")?"failed $!\n":"ok\n";
}
}
#my @pagemembers = $zip->membersMatching( "\.$c{'htmlext'}" );
#my @scriptmembers = $zip->membersMatching( '\.(js|pl|pm)$' );
#my @docmembers = $zip->membersMatching( "^$c{'docview'}" );
unlink $u.$n or $msg.= "download error: delete file [ $u$n ] failed: $!";
###sub_json_out({ 'check zip_in 1' => "u: $u \nn:$n \n\n$dbug \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
}
}
}
return $msg;
}

sub sub_zip_out{
# u:  '/var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/documents'
# %dpp = {
# 'addadminsite' => [ '/var/www/vhosts/pecreative.co.uk/revive.pecreative.co.uk/admin/' ],
# 'addstructuresite' => [  '/var/www/vhosts/pecreative.co.uk/revive.pecreative.co.uk/FONTS','/var/www/vhosts/pecreative.co.uk/revive.pecreative.co.uk/library.css','/var/www/vhosts/pecreative.co.uk/revive.pecreative.co.uk/.htaccess' ],
# 'addlibsite' => [ '/var/www/vhosts/pecreative.co.uk/revive.pecreative.co.uk/LIB/' ],
# 'addcgisite' => [ '/var/www/vhosts/pecreative.co.uk/revive.pecreative.co.uk/cgi-bin/'  ],
# 'adddocumentsite' => [ '/var/www/vhosts/pecreative.co.uk/revive.pecreative.co.uk/documents/' ],
# 'addpagesite' => [ '/var/www/vhosts/pecreative.co.uk/revive.pecreative.co.uk/Paper-and-Sustainability-Facts.html','/var/www/vhosts/pecreative.co.uk/revive.pecreative.co.uk/index.html' ],
# 'addscriptsite' => [ '/var/www/vhosts/pecreative.co.uk/revive.pecreative.co.uk/set.js' ]      
# fref: [ '/var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/documents/Images/logos/customers','/var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/TESTreviewlogo.jpg' ]
# dir: documents || revive.pecreative.co.uk
# nwzip:  '/var/www/vhosts/pecreative.co.uk/westfieldhealthdigitalresource.co.uk/admin/BACKUP/documents16-01-17.zip'
my ($u,$fref,$dir,$nwzip,$save,$cref,$oldurl,$repref,$dpref) = @_;
my @f = (defined $fref)?@{$fref}:();
my %c = %{$cref};
my %dpp = (defined $dpref)?%{$dpref}:();
my $utitle = $nwzip;$utitle =~ s/^($c{'base'})//;
my $ztitle = $utitle;$ztitle =~ s/^($c{'backupbase'})//;
my $msg = "";
my $size = 0;
my $stxt = "";
my $adj = undef;
my $data = undef;
my $dbug = "";
###sub_json_out({ 'debug' => "check zip_out: u:$u \n\n".Data::Dumper->Dump([\%dpp],["dpp"])."\n\n f: [ @f ] \n\ndir:$dir \nnwzip:$nwzip \n save:$save \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
eval "use Archive::Zip qw( :ERROR_CODES :CONSTANTS )";
if( $@ ){
$msg = "Unfortunately this server can't use Archive::Zip: $@ ";
} else {
eval "use File::Temp qw(:seekable tempfile tempdir)";
if( $@ ){
$msg = "Unfortunately this server can't use File::Temp: $@ ";
} else {
my $zip = Archive::Zip->new();
if( scalar keys %dpp > 0 ){
if( defined $dpp{'addstructuresite'} ){ my @ds = ( 'UPLOADS/','UPLOADS/RESTORE/','UPLOADS/TRASH/','UPLOADS/SHOP/','UPLOADS/IMAGE/','UPLOADS/FILE/' );for my $i(0..$#ds){ $zip->addDirectory($ds[$i]);$dbug.= "[dir > new] add $ds[$i]\n"; } }
foreach my $fz( sort keys %dpp ){ my @fa = @{ $dpp{$fz} };for my $i(0..$#fa){ if( -f $fa[$i] ){ $dbug.= sub_zip_file($fa[$i],$zip,$cref,$repref,$oldurl); } else { if( -d $fa[$i] ){ $dbug.= sub_zip_dir($fa[$i],$zip,$cref,$repref,$oldurl); } } } }
} else {
foreach my $fz( sort @f ){ if( -f $fz ){ $dbug.= sub_zip_file($fz,$zip,$cref,$repref,$oldurl); } else { if( -d $fz ){ $dbug.= sub_zip_dir($fz,$zip,$cref,$repref,$oldurl); } } }
}
###sub_json_out({ 'debug' => "check zip_out 2: u:$u \n\ndbug:\n$dbug \n\n".Data::Dumper->Dump([\%dpp],["dpp"])."\n\n f: [ @f ] \n\ndir:$dir \nnwzip:$nwzip \n oldurl:$oldurl \nsave:$save \n\n".Data::Dumper->Dump([$repref],["repref"])."\n\n \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
my $status = $zip->writeToFileNamed($nwzip);
if( $status == "AZ_OK" ){
###sub_json_out({ 'debug' => "check zip_out 3: @f \n\ndir: $dir \nnwzip: $nwzip \n save: $save \n\n dbg = $dbug \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
$size = -s "$nwzip";
$stxt = sub_get_size($nwzip);
if( $size > $CGI::POST_MAX ){ $CGI::POST_MAX = $size+1000;$adj = 1; }
###sub_json_out({ 'debug' => "check zip_out 4: adj: $adj\nutitle: $utitle \nztitle: $ztitle \nnwzip: $nwzip \n size: $size <>  ${CGI::POST_MAX} \nstxt: $stxt \nsave: $save \n\n dbg = $dbug \n\nf: \n@f \n\n$c{'debug'}" },$c{'origin'},$c{'callback'});
if( defined $save ){
$msg = "<a href=\"$utitle\" title=\"link to download zip\">Download $ztitle Zip ( $stxt )</a>";
} else {
print "Content-Type:x-download\n"; #print "Content-Type:application/octet-stream; name=\"$ztitle\"\n";print "Content-Length: $size\n";
print "Content-Disposition: attachment;filename=\"$ztitle\"\n\n";
my $hfile = gensym;
open($hfile,$nwzip);
binmode $hfile; #while(read($hfile,$data,1024) ){ print("$data"); }
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
1;