#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5

use cPanelUserConfig;
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
our $novelpage = $defs::novelpage;
our $novelbase = $defs::novelbase;
our $noveldir = $defs::noveldir;
our $chapterfile = $defs::chapterfile;
our $chapter = 1;
###

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
our $base = $defs::base; #/home/o1s4dgnh2ptx/public_html/thepubcat.co.uk/
our $baseview = $defs::baseview;
our $cgiurl = $defs::cgiurl;
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

our $invokepage = $ENV{'HTTP_REFERER'};
our $invokeuser = $ENV{'REMOTE_USER'};
our $response = "";
our $callback = "";
our $debug = "";

our $datetime = novel_get_date(); #14:10:39_15--10--2015
our $sendtime = $datetime;
$sendtime =~ s/\-\-/-/g;
our $senddate = $sendtime;$senddate =~ s/^(.*?)_//;$senddate =~ s/\-/\//g; #03/06/2016
our $usetime = $sendtime;$usetime =~ s/:/-/g;
$sendtime =~ s/_/ /g; #14:10:39 15-10-2015

novel_respond("error: Unauthorised user request received by server $ENV{'SERVER_ADDR'}") unless $serverenv =~ /^($serverip)/;
novel_respond("error: Data size [ ".$ENV{'CONTENT_LENGTH'}." ] is greater than the maximum ".$CGI::POST_MAX."k allowed") if $ENV{'CONTENT_LENGTH'} && $ENV{'CONTENT_LENGTH'} > $CGI::POST_MAX;

# https://thepubcat.co.uk/cgi-bin/novelize.pl
# https://thepubcat.co.uk/cgi-bin/novelize.pl?novel=The-Pub-Cat&chapter=01 #0 is all

our $query = CGI->new();
our %pdata = $query->Vars; my @new_keys = keys %pdata;s/^(opt|pre)_(.*?)_([0-9]+)$/$2/ foreach @new_keys; @pdata{@new_keys} = delete @pdata{keys %pdata}; # 
$debug.= Data::Dumper->Dump([\%pdata],["PDATA"])."\n";
our $postdata = $query->param('POSTDATA'); # $debug.= Data::Dumper->Dump([$postdata],["POSTDATA"])."\n";
our $qerr = $query->cgi_error;if($qerr){ exit 0;novel_respond("error: Problem with received data: $qerr"); }

foreach my $k( keys %pdata ){
my $h = undef;
if( $k eq "callback" ){ $callback = $pdata{$k}; }
if( $k eq "novel" ){ $noveldir = $pdata{$k}; }
if( $k eq "chapter" ){ $chapter = $pdata{$k}; }
}

novel_exit( "Novel:".( -d $base.$novelbase.$noveldir )."or Base:".( -f $base.$novelpage )." not found.." ) unless -d $base.$novelbase.$noveldir && -f $base.$novelpage;
###novel_respond("Debug 1 from $invokepage Request received by server: $ENV{'SERVER_ADDR'} remote address: $ENV{'REMOTE_ADDR'} remoteuser: $invokeuser referrer:$referrer $serverenv == $serverip $debug");

novel_get_chapters( $base.$novelbase.$noveldir.'/',$chapterfile,$chapter );

exit;

####

sub novel_exit{
my ($txt) = @_;
my $otxt = (defined $txt)?$txt:"The requested data is currently unavailable.";
novel_respond($otxt);
}

sub novel_get_date{ my @now = localtime();return sprintf( "%02d:%02d:%02d_%02d--%02d--%04d",$now[2],$now[1],$now[0],$now[3],$now[4]+1,$now[5]+1900 ); }

sub novel_get_chapters{
my ($d,$c,$n) = @_;
my %sets = ();
my @num = ();
my $ntxt = "";
my $nav = "";
my $err = undef;

my @files = novel_get_files($d,$c);
###novel_respond("get_chapters base:$base$novelbase = noveldir:$noveldir = d:$d c:$c n:$n files = [ @files ]");

for my $i(0..$#files){
my $s = "";
my $hfile = gensym;
open($hfile,"<",$files[$i]) or try { die "get_contents: open $files[$i] failed: $!"; } catch { $err = "novel_respond: open $files[$i] failed: $_"; };
if( defined $hfile && !defined $err ){ 
flock ($hfile,2);while(<$hfile>){ my $tmp = $_;$s.= $tmp; }close($hfile);
$sets{$i} = $s;
} else {
$sets{$i} = "error: $files[$i] $err";	
}
}

for my $k (sort keys %sets){
if($k > 0){ 
push @num,'<a href="'.$cgiurl.'novelize.pl?novel='.$noveldir.'&chapter='.$k.'" title="chapter '.$k.'">&#160;'.$k.'&#160;</a>';
if( $n == 0 || $n == $k ){ $ntxt.= novel_to_html($sets{$k}); } 
}
}

$nav = join " |&#160;",@num;
if( $n > 1 ){ $nav = '<a href="'.$cgiurl.'novelize.pl?novel='.$noveldir.'&chapter='.($n -1).'" title="previous chapter">&#60;&#60;prev</a> |&#160'.$nav; }
if( $n <= $#num ){ $nav.= '  |&#160;<a href="'.$cgiurl.'novelize.pl?novel='.$noveldir.'&chapter='.(1+$n).'" title="next chapter">next &#62;&#62;</a>'; }
novel_respond($ntxt,$nav);
}

sub novel_get_files{ 
my ($dir,$f) = @_;
my @out = ();
my @files = ();
find(sub {
$File::Find::prune = 1 unless $File::Find::dir eq $File::Find::name;
my $n = $File::Find::name;
if(defined $f){ ### $n =~ s/($File::Find::dir)//;$n =~ s/^\///;
push @out,$n; 
}
},$dir);
return sort @out; 
}

sub novel_html_out{
my ($io) = @_;
print "Content-type: text/html; charset=UTF-8\n\n";
#warningsToBrowser(1);

print $io;

exit;
}

sub novel_respond{
my ($t,$nav) = @_;
my $f = $base.$novelpage;
my $s = "";
my $err = undef;

my $hfile = gensym;
open($hfile,"<",$f) or try { die "get_contents: open $f failed: $!"; } catch { $err = "novel_respond: open $f failed: $_"; };
if( defined $hfile && !defined $err ){ 
flock ($hfile,2);while(<$hfile>){ my $tmp = $_;$s.= $tmp; }close($hfile); 
$s =~ s/(<div class="text"><h1>.*?)(<\/h1>)/$1: Chapter $chapter$2/ism;
$s =~ s/(<div class=".*?maintextsection">\s*<div class="sectioninner">\s*<ul class="area">\s*<li class="column">\s*<div class="row">\s*<div class="text">)(<\/div>)/$1$t$2/ism;
} else {
$s = "error: $err";
}

if( defined $nav ){ $s =~ s/(<div class=".*?mainnavsection">\s*<div class="sectioninner">\s*<ul class="area">\s*<li class="column">\s*<div class="row">\s*<div class="text">)(<\/div>)/$1$nav$2/ism; }

novel_html_out($s);
exit;
}

sub novel_to_html{
my ($s) = @_;
my $t = "";
$s =~ s/^(.*?)\n//;$t = $1;
$t = '<p class="title">'.$t.'</p>';
#$s =~ s/^\n$/BLANK/ig;
$s =~ s/\n/<\p>\n<p>/g;
return ($t."<p>".$s."</p>");
}
