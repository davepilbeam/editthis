#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5

#editthis version:8.2.2 EDGE

use strict;
#use warnings;
#use cPanelUserConfig;

use Data::Dumper;
use File::Find;
use File::Path;
use File::Spec;
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
our $index_file = $defs::index_file;
our $site_file = $defs::site_file;
our $listdir = join "|",@defs::LISTDIR;
our $banfile = join "|",@defs::BANFILE;

our $inurl = $ENV{'REDIRECT_URL'}; # /News.Crypto-as-a-Service.html
our $inquery = $ENV{'REDIRECT_QUERY_STRING'}; # /cgi-bin/view.pl?url=News.html

our @htm = finder_get_html($base,{'listdir' => $listdir,'banfile' => $banfile,'trim' => $base});
our $redirect = $site_file;
our $old = '<h1>(.*?)<\/h1>'; #'<div class="row editblock">\s*<ul class="sitemap">';
our $new = '<h1>Sorry - the server is unable to find '.$inurl.'</h1>'; #'<div class="row editblock"><div class="finderinfo">Sorry the server is currently unable to locate the page at '.$inurl.'.</div><ul class="sitemap">';
our $otxt = "";
our $debug = "";
our $err = undef;

for my $i(0..$#htm){
if( $htm[$i] =~ /($inurl)$/i ){ my $t = $htm[$i];$t =~ s/^\///;$redirect = $t; }
}
###finder_html_out("DEBUG 1:<br /><br />base: $base <br />inurl: $inurl<br />inquery: $inquery <br />redirect:$redirect<br />".Data::Dumper->Dump([\@htm],["htm"])."<br />listdir:$listdir<br />banfile:$banfile<br />debug: $debug");

$redirect = $index_file if !-f $base.$redirect;
($err,$otxt) = finder_html_in($base.$redirect);
if( defined $err || $redirect eq $site_file ){ $otxt =~ s/$old/$new/ism; }
###finder_html_out("DEBUG 2:<br /><br />err:$err<br />otxt:<br />$otxt<br /><br />debug: $debug");
finder_html_out($otxt);

###
sub finder_get_contents{ my ($f) = @_;my $otxt = "";my $err = undef;if(-f $f){ my $en = "<:utf8";my $hfile = gensym;open($hfile,$en,$f) or try { die "get_contents: open $f failed: $!"; } catch { $err = "get_contents: open $f failed: $_"; };if( defined $hfile && !defined $err ){ flock ($hfile,2);while(<$hfile>){ my $tmp = $_;$otxt.= $tmp; }close($hfile);$otxt =~ s/(\n+)/\n/g; } } else { $err = "alert: unable to open $f: $! "; }return ($err,$otxt); }

sub finder_get_html{ my ($nb,$cref) = @_;my %c = %{$cref};my @out = ();find(sub { /$c{'listdir'}/ and $File::Find::prune = 1;my $n = $File::Find::name;if( $n =~ /\.html$/ && $n !~ /($c{'banfile'})$/ ){ $n =~ s/^($c{'trim'})/\//;push @out,$n; } },$nb);return @out; }

sub finder_html_in{
my ($f) = @_;
my ($ierr,$otxt) = finder_get_contents($f,{});
my $t = "";
return ($ierr,$t) if defined $ierr;
$t = $otxt;
$t =~ s/(<base href=")(.*?)(" \/>)/$1$baseview$3/;
return (undef,$t);
}

sub finder_html_out{
my ($io) = @_;
print "Content-type: text/html\n\n";
print $io;
exit;
}
