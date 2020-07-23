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
our $cgipath = $defs::cgipath;
our $cgirelay = $defs::cgirelay;
our $base = $defs::base;
our $baseview = $defs::baseview;
our $docview = $defs::docview;
our $index_file = $defs::index_file;
our $site_file = $defs::site_file;
our $listdir = join "|",@defs::LISTDIR;
our $bansearch = $listdir."|LIB";
our $banfile = join "|",@defs::BANFILE;

my $cssdir = $base.$docview.'CSS/';
$banfile.= "|all-css-full.css";
my %common = ();
my %files = ();
my %unique = ();
my %media = ();
my $ctxt = "";
my $ftxt = "";
my $debug = "";
my $c = 0;
my @err = ();

find(sub { my $n = $File::Find::name;/^($bansearch)$/i and $File::Find::prune = 1;/($banfile)$/ and return;
my $ok = ( $n =~ /\.(css)$/ )?1:undef;
if( defined $ok ){
my ($cref,$fref,$i,$db) = diff_search_file($n,$c,\%common,\%files);
%common = %{$cref};
%files = %{$fref};
$c = $i;
$debug.= $db;
}
},$cssdir);

###diff_html_out("DEBUG 1:<br />base:$base <br />cssdir:$cssdir<br />".Data::Dumper->Dump([\%common],["common"])."<br />".Data::Dumper->Dump([\%files],["files"])."<br />err:[ @err ] <br /><br />listdir:$listdir<br />banfile:$banfile<br />debug:$debug");

foreach my $k( sort{ $common{$a} <=> $common{$b} } keys %common){ # ($common{$k})<br />
if( $k =~ /^\s*\}\s*$/ ){ push @err,"(Alert: $common{$k}) =  $k<br />\n"; }
if($k =~ /^\@media.*?and \((min|max)-width:([0-9]+)px\)/){ $media{$2.$1} = $k; } else { $ctxt.= "$k<br />\n"; }
} 
foreach my $k( sort{ $b <=> $a } keys %media){ $ctxt.= "$k = $media{$k}<br />\n"; }
my $werr = diff_write_file($ctxt,$cssdir."all-css-full.css");

push @err,$werr if defined $werr;
foreach my $k( keys %files ){ my @ar = @{ $files{$k} };if( $ar[0] ne "common" ){ my @tmp = ( $k,$ar[1] );push @{ $unique{$ar[0]} },\@tmp; } }
#diff_html_out("DEBUG 2:<br />base:$base <br />cssdir:$cssdir<br /><br />ctxt:$ctxt<br /><br />".Data::Dumper->Dump([\%unique],["unique"])."<br /><br />err:[ @err ] <br /><br />listdir:$listdir<br />banfile:$banfile<br />debug:$debug");

# 'documents/CSS/Media.css' => [ [ '.mediaslidearea .tt_slideshow-inner[data-list=s30] .tt_slideshow-el { background-color:transparent; opacity:1; top:15%; } ', 816 ] ]
foreach my $k( sort keys %unique ){
$ftxt.= "$k</br>\n";
my @lines = sort { $a->[1] <=> $b->[1] } @{ $unique{$k} };
for my $i(0..$#lines){
$ftxt.= "$lines[$i][0]<br />\n"; #($lines[$i][1])
}
$ftxt.= "<br />\n";
}
#($err,$otxt) = diff_html_in($base.$redirect);
#if( defined $err || $redirect eq $site_file ){ $otxt =~ s/$old/$new/ism; }
###diff_html_out("DEBUG 2:<br /><br />err:$err<br />otxt:<br />$otxt<br /><br />debug: $debug");

#
diff_html_out("DEBUG 3:<br />base:$base <br />cssdir:$cssdir<br /><br />ctxt:$ctxt<br /><br />ftxt:$ftxt<br /><br />err:[ @err ] <br /><br />listdir:$listdir<br />banfile:$banfile<br />debug:$debug");



###
sub diff_get_contents{ my ($f) = @_;my $otxt = "";my $err = undef;if(-f $f){ my $en = "<:utf8";my $hfile = gensym;open($hfile,$en,$f) or try { die "get_contents: open $f failed: $!"; } catch { $err = "get_contents: open $f failed: $_"; };if( defined $hfile && !defined $err ){ flock ($hfile,2);while(<$hfile>){ my $tmp = $_;$otxt.= $tmp; }close($hfile);$otxt =~ s/(\n+)/\n/g; } } else { $err = "alert: unable to open $f: $! "; }return ($err,$otxt); }

sub diff_get_files{ my ($nb,$ty,$cref) = @_;my %c = %{$cref};my @out = ();find(sub { if(defined $c{'listdir'}){/$c{'listdir'}/ and $File::Find::prune = 1;}my $n = $File::Find::name;if( $n =~ /\.($ty)$/ && $n !~ /($c{'banfile'})$/ ){ if(defined $c{'trim'}){$n =~ s/^($c{'trim'})/\//;}push @out,$n; } },$nb);return @out; }

sub diff_html_in{
my ($f) = @_;
my ($ierr,$otxt) = diff_get_contents($f,{});
my $t = "";
return ($ierr,$t) if defined $ierr;
$t = $otxt;
$t =~ s/(<base href=")(.*?)(" \/>)/$1$baseview$3/;
return (undef,$t);
}

sub diff_html_out{
my ($io) = @_;
print "Content-type: text/html\n\n";
print $io;
exit;
}

sub diff_search_file{ 
my ($f,$c,$cref,$fref) = @_;
local @ARGV = ($f); ###local $^I = ''; #local($^I) = '.bak';
my %common = %{$cref};
my %files = %{$fref};
my $fh = $f;$fh =~ s/^($base)//;
my $i = $c;
my $dbug = "<br />searching $fh...<br />\n";
my $str = undef;
while (<>){ 
my $line = $_;
if( $line !~ /^\/\*/ && $line !~ /\*\/$/ ){

if( $line =~ /^\@media / ){
$str = $line; #$dbug.= "started $str <br />";
} elsif( defined $str && $line !~ /^\s*\}\s*$/ ){
$str.= $line;
} else {

if( defined $str && $line =~ /^\s*\}\s*$/ ){ $line = $str.$line;$dbug.= "end $line ($i)<br />";$str = undef; }
if( defined $files{$line} ){
if( !defined $common{$line} ){ $common{$line} = $i++; }
@{ $files{$line} } = ("common");
} else {
@{ $files{$line} } = ($fh,$i++); 
}

}

}
} # continue { }
return (\%common,\%files,$i,$dbug);
}

sub diff_write_file{
my ($ntxt,$cb) = @_;
my $herr = undef;
my $hfile = gensym;
open($hfile,">:utf8",$cb) or try { die "write_file: $cb failed: $!"; } catch { $herr.= "write_file: $cb failed: $_"; }; 
if( defined $hfile && !defined $herr ){
flock ($hfile,2);
print $hfile $ntxt;
}
close($hfile);
return $herr;
}
