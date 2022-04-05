#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5
###use cPanelUserConfig;
#editthis version:8.2.3 EDGE

use strict;
#use warnings;

use Cwd;
use CGI;
use CGI qw/escape unescape/;
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;$Data::Dumper::Indent = 1;
use Encode;
use File::Copy qw(cp mv);
use File::Find;
use File::Path qw(make_path remove_tree);
use File::Spec;
use File::stat;
use File::Temp qw(:seekable tempfile tempdir);
use HTML::Entities;
use Imager;
use Net::FTP;
use Net::FTP::File;
use Net::FTP::Recursive;
use Net::SFTP::Foreign;
use Time::Local;
use Try::Tiny;


my $envpath = File::Spec->rel2abs( __FILE__ );
$envpath =~ s/(\/cgi\-bin|\/cgi)(.+)\/.*?$/$1$2/;
our $cgix = $1.$2."/";
our $incerr = "";
for my $incfile("$envpath/defs.pm"){
my $increturn = undef;
unless ($increturn = do $incfile){
$incerr.= "couldn't parse $incfile: $@\n" if $@;
$incerr.= "couldn't do $incfile: $!\n" unless defined $increturn;
$incerr.= "couldn't run $incfile\n" unless $increturn;
}
}

our @refs = ();
our $origin = undef;
our $callback = "";
if( defined $ENV{'HTTP_HOST'} && $ENV{'HTTP_HOST'} =~  /thatsthat\.co\.uk/ ){ 
@refs = ( "thatsthat.co.uk" );
our $referers = join "|",@refs;
imager_json_out({ 'error' => "Unauthorised user request from $ENV{'HTTP_REFERER'}" },$origin,$callback) unless $ENV{'HTTP_REFERER'} =~ /($referers)/;
}

our @servers = ( "127.0.0.1" );
push @servers,@defs::serverip;
for my $i(0..$#servers){ $servers[$i] =~ s/\.([0-9]+)$//; }
our $serverip = join "|",@servers;
our $serverenv = $defs::serverenv;
our $softversion = $defs::softversion;

our $base = $defs::base;
our $baseview = $defs::baseview;
our $imagebase = "admin/IMAGER/";
our $imgdir = $imagebase;
our $testimage = "imager_TEST-default.jpg";
our $adminaddr = $defs::adminaddr;
our $fromaddr = $defs::fromaddr;
our $ftpmaster = $defs::ftpmaster;
our $salt = $defs::salt;
our $matchfiles = "gif|jpg|png";
our %imglim = %defs::imager_limits;
our @errs = ();

our %DATA = ( 'type' => [],'dests' => [],'locals' => [],'widths' => [],'heights' => [],'tops' => [],'lefts' => [],'xscales' => [],'yscales' => [],'xyunits' => [],'res' => [] );
our %PUT = ();
our @PICS = ();
our $ximg = undef;
our $xhandle = undef;
our $io_xhandle = undef;
our $xtmpfile = undef;
our $xno = undef;
our $xurl = undef;
our $xtotal = undef;
our $out = "";
our $outerr = "";
our $xcheck = "";
our $xpass = "";
our $ins = undef;
our $ftpbase = undef;
our $debug.= "";

$CGI::POST_MAX = $defs::postmax;
Imager->set_file_limits( width => $imglim{'width'},height => $imglim{'height'},bytes => $imglim{'bytes'} );

imager_json_out({ 'error' => "unauthorised user request received by server [ $serverenv = $ENV{'SERVER_ADDR'} ] envpath:$envpath serverenv: $serverenv == $serverip" },$origin,$callback) unless $serverenv =~ /($serverip)/;
imager_json_out({ 'error' => "data size [ $ENV{'CONTENT_LENGTH'} ] is greater than the maximum ".$CGI::POST_MAX."k allowed)" },$origin,$callback) if $ENV{'CONTENT_LENGTH'} && $ENV{'CONTENT_LENGTH'} > $CGI::POST_MAX;

our $query = CGI->new();
our %pdata = $query->Vars; my @new_keys = keys %pdata;s/^(opt|pre)_(.*?)_([0-9]+)$/$2/ foreach @new_keys;@pdata{@new_keys} = delete @pdata{keys %pdata}; # $debug.= Data::Dumper->Dump([\%pdata],["PDATA"])."\n";
our $postdata = $query->param('POSTDATA'); # $debug.= Data::Dumper->Dump([$postdata],["POSTDATA"])."\n";
our $qerr = $query->cgi_error;if($qerr){ exit 0;imager_json_out({ 'error' => "problem with received data: $qerr" },$origin,$callback); }

foreach my $k( keys %pdata ){
if( $k eq "ins" ){ $ins = $pdata{$k}; } # repic || crop || scale || crop scale
if( $k eq "callback" ){ $callback = $pdata{$k}; } #Request.JSONP.request_map.request_0
if( $k eq "pass" ){ $xpass = $pdata{$k}; } #xxxxxx
if( $k eq "check" ){ $xcheck = $pdata{$k}; } #ttdjHiSLjrTuk
if( $k eq "origin" ){ $origin = $pdata{$k}; } #$ENV{'REMOTE_ADDR'}
if( $k eq "ftpbase" ){ $ftpbase = $pdata{$k}; } #httpdocs/
if( $k eq "X-File-Name" ){ $ximg = $pdata{$k}; } #Man-and-Lady-300x200.jpg
if( $k eq "X-File-Id" ){ $xno = $pdata{$k}; } #0
if( $k eq "X-File-Total" ){ $xtotal = $pdata{$k}; } #2
if( $k eq "X-Return-Url" ){ $xurl = $pdata{$k}; } #documents/Images/videos/
if( $k =~ /^type([0-9]+)$/ && $pdata{$k} ne "" ){ @{ $DATA{'type'} }[$1] = Encode::decode_utf8($pdata{$k}); } #Header Image,Mobile Version,Library Document,Staff Picture,Video Screengrab
if( $k =~ /^dests([0-9]+)$/ ){ my $fullpath = Encode::decode_utf8($pdata{$k});@{ $DATA{'dests'} }[$1] = $fullpath;$fullpath =~ s/^(.+\/)//;@{ $DATA{'locals'} }[$1] = $fullpath; } #test1_header.jpg test1_mobile.jpg test1_thumb.jpg
if( $k =~ /^widths([0-9]+)$/ ){ @{ $DATA{'widths'} }[$1] = $pdata{$k}; } #460
if( $k =~ /^heights([0-9]+)$/ ){ @{ $DATA{'heights'} }[$1] = $pdata{$k}; } #260
if( $k =~ /^tops([0-9]+)$/ ){ @{ $DATA{'tops'} }[$1] = $pdata{$k}; }  #20
if( $k =~ /^lefts([0-9]+)$/ ){ @{ $DATA{'lefts'} }[$1] = $pdata{$k}; } #10
if( $k =~ /^bottoms([0-9]+)$/ ){ @{ $DATA{'bottoms'} }[$1] = $pdata{$k}; } #10
if( $k =~ /^rights([0-9]+)$/ ){ @{ $DATA{'rights'} }[$1] = $pdata{$k}; } #10
if( $k =~ /^xscales([0-9]+)$/ ){ @{ $DATA{'xscales'} }[$1] = $pdata{$k}; } #0.6
if( $k =~ /^yscales([0-9]+)$/ ){ @{ $DATA{'yscales'} }[$1] = $pdata{$k}; } #0.8
if( $k =~ /^xyunits([0-9]+)$/ ){ @{ $DATA{'xyunits'} }[$1] = $pdata{$k}; } #px pc
if( $k =~ /^res([0-9]+)$/ ){ @{ $DATA{'res'} }[$1] = $pdata{$k}; } #72
}

if( !defined $origin ){

$xurl = $base.$imagebase;
$imgdir = $base.$imagebase;
# $send = {
# 'X-File-Id' => 1,
# 'pass' => undef,
# 'type0' => 'OG Image',
# 'X-Return-Url' => '/var/www/vhosts/secretmentalunit.com/onlinederby.co.uk/LIB/',
# 'bottoms0' => 768,
# 'rights0' => 1024,
# 'res0' => 72,
# 'dests0' => '/var/www/vhosts/secretmentalunit.com/onlinederby.co.uk/LIB/index.jpg',
# 'lefts0' => 0,
# 'ins' => 'crop',
# 'tops0' => 0,
# 'check' => undef,
# 'ftpbase' => '/var/www/vhosts/secretmentalunit.com/onlinederby.co.uk/',
# 'X-File-Name' => 'LIB/index.jpg'
# };
if($ins eq "crop" || $ins eq "resize"){
###imager_json_out({ 'imager check' => "received ok: [ $origin $ftpbase @{ $DATA{'dests'} } $xurl ] "},$origin,$callback);

for my $k( keys %DATA){ my @ds = @{ $DATA{$k} };for my $i(0..$#ds){ if( !defined $PICS[$i] ){%{$PICS[$i]} = ();}$PICS[$i]->{$k} = $ds[$i]; } }
###$outerr.= Data::Dumper->Dump([\@PICS],["PICS"])." \n\n".imager_test($ximg,$xtmpfile);
for my $i(0..$#PICS){
my %m = %{ $PICS[$i] };
my @action = ($ins,$m{'widths'},$m{'heights'},$m{'tops'},$m{'lefts'},$m{'bottoms'},$m{'rights'},$m{'xscales'},$m{'yscales'},$m{'xyunits'},$m{'res'});
my ($perr,$plocal,$premote) = imager_process($m{'dests'},$m{'dests'},$m{'locals'},\@action); #'/var/www/vhosts/secretmentalunit.com/onlinederby.co.uk/LIB/index.jpg',pic1_video.jpg,('crop',460,260,top,left,bottom,right,xscale,yscale,72);
imager_html_out($perr) if $perr ne "";
chmod (0664,$base.$imagebase.$m{'locals'}) or try { die "admin_copy: chmod $base$imagebase$m{'locals'} failed: $!"; } catch { $debug.= "admin_copy: chmod $base$imagebase$m{'locals'} failed: $_ "; }; 
if( -f $base.$imagebase.$m{'locals'} ){ mv ($base.$imagebase.$m{'locals'},$m{'dests'}) or $debug.= "Rename error: ".$base.$imagebase.$m{'locals'}." to ".$m{'dests'}.": $! "; } else { $debug.= "error: ".$base.$imagebase.$m{'locals'}." $!"; }
###imager_html_out("imager $ins: ok moved ".$base.$imagebase.$m{'locals'}." to ".$m{'dests'}." $debug");
}
imager_html_out(undef,$debug);

} else {
$outerr = imager_test($testimage,$xurl.$testimage);
imager_json_out({ 'debug' => "$outerr" },$origin,$callback);
}

} else {

$xhandle = $query->upload("filedata"); #raw data
$xtmpfile = $query->tmpFileName($xhandle);
imager_json_out({ 'error' => "unauthorised user request received by server $ENV{'SERVER_ADDR'} origin:$origin ximg:$ximg xhandle:$xhandle serverip: $serverip == $origin" },$origin,$callback) unless defined $origin && defined $ximg && defined $xhandle && $origin =~ /^($serverip)/;

#$DATA = {
#'dests' => ['test-pic1_video.jpg'],
#'widths' => [460]
#'heights' => [260],
#'type' => ['Video Screengrab'],
#'res' => [72],
#'xyunits' => ['px'],
#'xscales' => [],
#'yscales' => [],
#'tops' => [],
#'lefts' => [],
#'bottoms' => [],
#'rights' => [],
#}
#read: sgi png bmp ico tiff pnm tga jpeg gif raw
#write: sgi bmp png ico tiff pnm tga jpeg gif raw 
#name:test-pic1.jpg
#path:/tmp/VG9dENFMHt 
#type:jpeg
#size:183 k
#width:960 px
#height:485 px
#X res: 72 (aspect=100%)
#Y res:72 (aspect=100%)
#aspect:1

if($xtmpfile) {
#imager_json_out({ 'debug' => "received ok: [ $origin $ftpbase @{ $DATA{'dests'} } $xurl = $ximg $xtmpfile ] "},$origin,$callback);

if( $ENV{'SERVER_ADDR'} eq $origin ){ $imgdir = $base.$xurl; }

for my $k( keys %DATA){ my @ds = @{ $DATA{$k} };for my $i(0..$#ds){ if( !defined $PICS[$i] ){%{$PICS[$i]} = ();}$PICS[$i]->{$k} = $ds[$i]; } }
#$outerr.= Data::Dumper->Dump([\@PICS],["PICS"])." \n\n".imager_test($ximg,$xtmpfile);

for my $i(0..$#PICS){
my %m = %{ $PICS[$i] };
my @action = ($ins,$m{'widths'},$m{'heights'},$m{'tops'},$m{'lefts'},$m{'bottoms'},$m{'rights'},$m{'xscales'},$m{'yscales'},$m{'xyunits'},$m{'res'});
my ($perr,$plocal,$premote) = imager_process($xtmpfile,$m{'dests'},$m{'locals'},\@action);
if($perr eq ""){ $PUT{$plocal} = $premote; } else { $outerr.= $perr." "; }
}

#imager_json_out({ 'debug' => "PICS: [ ".Data::Dumper->Dump([\%PUT],["PUT"])."  $xurl = $ximg $xtmpfile ]" },$origin,$callback);
#$PUT = {'Translational-Science-for-Climate-Services-in-China-Summary.jpg' => 'documents/Publications/Climate-Change-Science,-Policy-and-Practice/Translational-Science-for-Climate-Services-in-China/Translational-Science-for-Climate-Services-in-China-Summary.jpg'}

my $ps = scalar keys %PUT;
if($ps > 0){ 
my ($ferr,$fmsg) = imager_ftp(\%PUT,$origin,$ftpbase,$xurl); 
$outerr.= $ferr." " unless $ferr eq "";
$out.= $fmsg." ";
} else {
$outerr.= "resize: there was a configuration error with file $ximg [ $xtmpfile ]";
}

imager_html_out($outerr) if $outerr ne "";
imager_html_out($out);

} else {
imager_html_out("resize: there was an error opening file $ximg [ $xtmpfile ]: $!");
}

###imager_html_out( "received: $ENV{'CONTENT_LENGTH'} xhandle: [$xhandle] \n\npdata: ".Data::Dumper->Dump([\%pdata],["PDATA"])." postdata:".Data::Dumper->Dump([$postdata],["POSTDATA"]) );
}

exit;

##
sub imager_connect_ftp{
my ($iftp,$serv,$dir,$user,$pass,$type) = @_; #
my $ftp = undef;
my $msg = ""; #$debug.= "ftp: $iftp,$serv,$dir,$user,$pass,$type<br />";
my $err = ""; 

if( $iftp > 0 ){

my $ssherr = File::Temp->new or $err = "imager connect: new File Temp failed $!";$Net::SFTP::Foreign::debug = -1;
$ftp = Net::SFTP::Foreign->new( $serv,user => $user,password => $pass ); #,timeout => 60,more => ['-vvv'],stderr_fh => $ssherr
if($ftp->error){
$err.= "imager connect: failed to connect to server '$serv' ".$ftp->error." ".$ftp->status; #seek($ssherr,0,0);while(<$ssherr>){ $err.= "captured stderr: $_  "; }
} else {
$msg.= "imager connect: connected to server '$serv'<br />";
my $fh = $ftp->cwd;if($dir ne "" && $dir ne $fh){ $ftp->setcwd($dir);$fh = $ftp->cwd; } #my $ls = $ftp->ls($fh);if($ftp->error){ $err.= "error: cannot list directory $fh: ".$ftp->error."".$ftp->status; } else { $err.= "$_->{filename} " for (@$ls); }
}

} else {

$ftp = (defined $type)?Net::FTP::Recursive->new($serv,Debug => 3):Net::FTP->new($serv,Debug => 3); #,Passive => 1
$err.= "imager connect: failed to connect to server '$serv': $@ " unless $ftp;
if(defined $ftp){
#$debug.= "$type = $ftp ";
$err.= "error: failed to login as $user: ".$ftp->message." $! " unless $ftp->login($user,$pass);
$err.= "error: failed to set binary mode: ".$ftp->message." $! " unless $ftp->binary();
if($dir ne "" && $dir ne $ftp->pwd){ $err.= "error: cannot change directory to $dir: ".$ftp->message." $! " unless $ftp->cwd($dir); }
}

}
return ($ftp,$err,$msg);
}

sub imager_ftp{
my ($fdref,$serv,$dir,$url) = @_;
my %fd = %{$fdref};
my $msg = "";
my $outfull = "";
my $outfile = "";
my $err = "";

if( $ENV{'SERVER_ADDR'}  eq $origin ){

#imager_json_out({ 'debug' => "local user request received by server $ENV{'SERVER_ADDR'} origin:$origin ximg:$ximg xhandle:$xhandle imgdir:$imgdir serverip: $serverip == $origin" },$origin,$callback);
foreach my $k( keys %fd){
if( $xurl =~ /Publications/ || $xurl =~ /PDF/ ){ $outfull = $fd{$k};$outfile = $k; } else { $outfull = $xurl.$k;$outfile = $fd{$k}; }
#$xurl = documents/Publications/Biodiversity,-Eco--Systems-and-Marine-Conservation/Marine-Managed-Areas/
#$outfull = documents/Publications/Biodiversity,-Eco--Systems-and-Marine-Conservation/Marine-Managed-Areas/Prolinx-MASTER-Logo3.png = $fd{$k} or $xurl.$outfile
#$outfile = Prolinx-MASTER-Logo3.png = $k;
chmod (0664,$base.$outfull) or try { die "admin_copy: chmod $base$outfull failed: $!"; } catch { $debug.= "admin_copy: chmod $base$outfull failed: $_"; }; 
$msg.= '<span class="imager-ok"> Image was successfully resized as <b><a href="'.$outfull.'" target="_blank" title="view image">'.$k.'</a></b></span>';   #[ '.$k.' to '.$outfile.' ]
}

} else {

my($sftp,$user,$pass,$ftpip) = imager_get_auth($serv,$xcheck);
return ("imager ftp: there was an error authorising $serv $sftp $user $pass $ftpip") unless defined $user && defined $pass;
my ($obj,$err,$msg) = imager_connect_ftp($sftp,$ftpip,$dir.$url,$user,$pass); #+"recursive"
return ("imager ftp: there was an error connecting to $serv ($dir.$url,$user,$pass,$ftpip): $err / $msg") unless defined $obj && $err eq "";

if( defined $obj ){  
foreach my $k( keys %fd){
if( $xurl =~ /Publications/ || $xurl =~ /PDF/ ){ $outfull = $fd{$k};$outfile = $k; } else { $outfull = $xurl.$outfile;$outfile = $fd{$k}; }
if( getcwd() ne $base.$imagebase ){ $err.= "imager ftp: cannot change to directory $base.$imagebase $! " unless chdir($base.$imagebase); }
$obj->put($k,$outfile,copy_perm => 0);
if($obj->error){ 
$err.= "error: send $k to $outfile: ".$obj->error." "; 
} else { 
$obj->site('chmod','664',$outfile);
if($obj->error){ 
$err.= "error: chmod $k: ".$obj->error." ".$obj->message." "; 
} else { 
$msg.= '<span class="imager-ok"> Image was successfully resized as <b><a href="'.$outfull.'" target="_blank" title="view image">'.$k.'</a></b></span>';  #[ '.$k.' to '.$outfile.' ] 
} 
}
unlink $base.$imagebase.$k or $msg.= "( NB: unable to delete temp file $base".$imagebase.$k." ) ";
}

$obj->quit;
}

}

return ($err,$msg);
}

sub imager_get_auth{
my ($s,$au) = @_;
my @auth = ();
#$auth[0] = [ '127.0.0.1','0','intasavegroup','ttdjHiSLjrTuk','141.0.165.133' ];
#$auth[1] = [ '127.0.0.1','0','pecreative','ttLBzxTWgOWgo','141.0.165.133' ];
my @ok = ();
for my $i(0..$#auth){
if( $s eq $auth[$i][0] && $au ne "" && $au eq $auth[$i][3] && $xpass ne "" ){ @ok = ($auth[$i][3],$auth[$i][2],$ftpmaster.$xpass,$auth[$i][4]); }
}
#imager_html_out("resize: $s = $au = @ok ");
return @ok;
}

sub imager_html_out{
my ($io) = @_;
print "Content-type: text/html\n\n";
#warningsToBrowser(1);
print $io;
exit;
}


sub imager_json_out{
my ($jref,$orig,$call) = @_;
my $type = ref $jref || undef;
if( defined $type ){
eval "use JSON";
if($@){ imager_json_print( sub_list_dump($jref,'query') ); } else { imager_json_print( "{ \"query\":".JSON->new->allow_nonref->utf8->encode($jref)." }",$orig,$call ); }
} else {
imager_json_print($jref,1,$call);
}
}

sub imager_json_print{
my ($jtxt,$q,$callback) = @_;
if( defined $callback && $callback ne "" ){
print "Content-type: application/javascript; charset=UTF-8\n\n";
print "$callback( $jtxt )";
} elsif( defined $q ){ 
print "Content-type: application/json; charset=UTF-8\n\n";
print "{ \"query\":[ \"$jtxt\" ] }";
} else {
print "Content-type: application/json; charset=UTF-8\n\n";
print $jtxt;
}
exit;
}

sub imager_process{
#$xtmpfile,pic1_video.jpg,('repic',460,260,top,left,bottom,right,xscale,yscale,72);
my ($fd,$dest,$loc,$insref) = @_; # 
my @ins = @{$insref};
my $tmpfile = $imgdir.$loc; #dest:documents/Publications/Biodiversity,-Eco--Systems-and-Marine-Conservation/Marine-Managed-Areas/Prolinx-MASTER-Logo3.png    tmpfile:/var/www/vhosts/pecreative.co.uk/intasave.org/documents/Publications/Biodiversity,-Eco--Systems-and-Marine-Conservation/Marine-Managed-Areas/Prolinx-MASTER-Logo3.png
my $err = "";
return ("imager process: there was an error opening file $fd: $!") unless -f $fd;
my $img = Imager->new;
$img->read(file=>$fd) or return ("imager process: there was an error reading $fd: ".$img->errstr);
my $scaleimg = undef;
my $newimg = undef;
my $ox = $img->getwidth();
my $oy = $img->getheight();

if( $ins[0] eq "repic" ){
$img->settag(name => 'i_xres', value => 72);$img->settag(name => 'i_yres', value => 72);
if( $ox != $ins[1] || $oy != $ins[2] ){ $scaleimg = $img->scale( xpixels => $ins[1],ypixels => $ins[2] ); $newimg = $scaleimg; #####$newimg = $scaleimg->crop( width => $ins[1],height => $ins[2] ); 
} elsif( $ox == $ins[1] && $oy == $ins[2] ){ $newimg = $img; } else { $err = " x:$ins[1] y:$ins[2] ox:$ox oy:$oy "; }
} else {
if( $ins[0] =~ /scale/ ){ if( defined $ins[7] ){ $scaleimg = $img->scaleX(scalefactor => $ins[7]);$newimg = $scaleimg->scaleY(scalefactor => $ins[8]); } else { $newimg = $img->scale( xpixels => $ins[1],ypixels => $ins[2] ); } }
if( $ins[0] =~ /crop/ ){ $newimg = $img->crop( top => $ins[3],left => $ins[4],bottom => $ins[5],right => $ins[6] ); }
}

if( defined $newimg ){
$newimg->write( file => $tmpfile ) or return ("imager process: there was an error writing file $tmpfile: $! ".$newimg->errstr); #return("imager process: tmpfile:$tmpfile dest:$dest loc:$loc = @ins");
return("imager process: there was an error checking file $tmpfile: $!") unless -f $tmpfile;
} else {
$err = "imager process: there was an error processing file $fd: $! $dest $loc $insref $err";
###imager process: there was an error processing file /tmp/3W_dPBdbBc: No such file or directory Translational-Science-for-Climate-Services-in-China-Summary_header.jpg Translational-Science-for-Climate-Services-in-China-Summary_header.jpg ARRAY(0x31b5d38) 
}

return ($err,$loc,$dest);
}

sub imager_test{
my ($fn,$fd) = @_;
return "imager test: there was an error opening file $fd: $!" unless -f $fd;
my $img = Imager->new;
$img->read(file=>$fd) or return "imager test: there was an error reading $fd: ".$img->errstr;
my @read_types = Imager->read_types;
my @write_types = Imager->write_types;
my $ox = $img->getwidth();
my $oy = $img->getheight();
my $oaspect = $img->tags(name=>'i_aspect_only');
my $oformat = $img->tags(name=>'i_format');
my $oxres = $img->tags(name=>'i_xres');
my $oyres = $img->tags(name=>'i_yres');
if( $oaspect != 0){$oxres = 72;$oyres = 72;}
my $osize = (-s $fd) / 1024;$osize = int($osize + $osize/abs($osize*2));
my $xcheck = ""; ###crypt("www_LIB_icy927",$salt); 

return "imager test: Length:$ENV{'CONTENT_LENGTH'} Check:$xcheck Read:@read_types Write: @write_types \nImager test: Name:$fn xurl:$xurl path:$fd ftpbase:$ftpbase type:$oformat \nsize:$osize k \nwidth:$ox px \nheight:$oy px \nX res:$oxres px/inch \nY res:$oyres x/inch \naspect:$oaspect\n>";
}
