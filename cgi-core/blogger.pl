#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5

#editthis version:8.2.2 EDGE

use strict;
#use warnings;

use CGI;
use CGI qw/escape unescape/;
use CGI::Carp qw(fatalsToBrowser);
use File::Basename;
use File::Spec;
use Scalar::Util 'blessed';
use Time::Local;
use Data::Dumper;

my $envpath = "";
our $cgix = "";
our $incerr = "";

our @servers = ( "127.0.0.1","141.0.165.133","141.0.165.151","86.15.164.221","81.168.114.213","94.197.127.29","46.32.235.70","10.168.1.117" );
our $serverenv = $ENV{'SERVER_ADDR'};
our $burl = "/feeds/posts/default?alt=rss";

our @refs = ();
if( defined $ENV{'HTTP_HOST'} && $ENV{'HTTP_HOST'} =~  /thatsthat\.uk/ ){ 
@refs = ( "thatsthat.uk" );
our $referers = join "|",@refs;
blog_url_out("error: Unauthorised user request from $ENV{'HTTP_REFERER'} ") unless $ENV{'HTTP_REFERER'} =~ /($referers)/;
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
our $softversion = "8.5.0";

our %DATA = ();
our @s = ();
our @u = ();
our $thistag = undef;
our $entryflag = undef;
our $ents = 0;

our $input = "";
our $callback = "";
our $url = "";
our $sname = "";
our $count = 20;
our $iconsrc = "";
our $iconw = 0;
our $iconh = 0;
our $tw = "http://blogspot.co.uk/"; 
our $link = "http://blogspot.uk";
our $debug = "";

blog_url_out({ 'error' => "alert: server configuration problem:\n\n $incerr \n\ncgix:$cgix \nenvpath:$envpath \nip:$ENV{'REMOTE_ADDR'}" }) if $incerr ne "";
blog_url_out("(error: Unauthorised user request from $serverenv )") unless $serverenv =~ /($serverip)/;

if($ENV{'REQUEST_METHOD'} eq "POST"){read(STDIN, $input, $ENV{'CONTENT_LENGTH'});} else {$input = $ENV{'QUERY_STRING'};}
our @in = split (/&/,$input);
foreach(@in){
s/\+/ /g;
our ($name, $value) = split(/=/,$_);
$name = unescape($name);
$name=~ s/^(pre_)|(opt_)//;
$value = unescape($value);
$value =~ s/\n\r//g;
$value =~ s/\r\n//g;
$value =~ s/[^a-zA-Z0-9\-\_\+\@\%\&\#<>'"\+=\/\.£\|,:;\(\)\{\}\?\!\[\]\s]//g;
if($name eq "type" && $value ne ""){ $url = $value;$url =~ s/\/$//;$sname = $url.$burl; } #http://rsmzspecialists.blogspot.co.uk
if($name eq "callback"){ $callback = $value; }
if($name eq "count"){ $count = $value; }
}

blog_url_out("(error: the server for $url appears to be unavailable = callback:$callback url:$url sname:$sname)") unless $sname ne "";


# rss
# channel -> link
# channel -> openSearch:startIndex
# channel -> openSearch:itemsPerPage
# channel -> item
# channel -> item -> link = VALUE => 'http://rsmzspecialists.blogspot.com/2016/02/rsm-partners-receives-ready-for-ibm.html'
# channel -> item -> author = VALUE => 'noreply@blogger.com (Andrew Downie)'
# channel -> item -> description = VALUE => 'html'
# channel -> item -> media:thumbnail' = ATTRS' => { 'width' => '72', 'url' => 'https://4.bp.blogspot.com/-VK8xfrp9QyA/VsJaFppKx2I/AAAAAAAAABI/hxoRklFCqjM/s72-c/SFtT5v_1435849536.jpg', 'height' => '72' }
# channel -> item -> guid = VALUE => 'tag:blogger.com,1999:blog-9199109126125963405.post-5925921322528361908',
# channel -> item -> atom:updated = VALUE' => '2016-02-16T01:16:04.768-08:00',
# channel -> item -> category = VALUE' = 'News',
# channel -> item -> title = VALUE' > 'RSM Partners Receives Ready for IBM Security Intelligence Validation  As a leader in z Systems Security Consulting',
# channel -> item -> pubDate = VALUE' => 'Tue, 16 Feb 2016 09:16:00 +0000

#link = value: http://blog.pecreative.co.uk/2018/04/new-branding-excites-unions.html
#author = value: noreply@blogger.com (parky)
#description = value: <a href="https://2.bp.blogspot.com/-5LxybqEv1Do/WtCzrG85OjI/AAAAAAAABn0/ho9p4S-AMwwryfL5VBltZFdlvya1ONPGgCLcBGAs/s1600/UL.jpeg" imageanchor="1" style="clear: right; float: right; margin-bottom: 1em; margin-left: 1em; text-align: left;"><img border="0" data-original-height="1354" data-original-width="1600" height="168" src="https://2.bp.blogspot.com/-5LxybqEv1Do/WtCzrG85OjI/AAAAAAAABn0/ho9p4S-AMwwryfL5VBltZFdlvya1ONPGgCLcBGAs/s200/UL.jpeg" width="200" /></a><br />
#PE Creative client UnionLine provide specialist claims services for union members across the UK. Being nationally recognised the company requires a logo style which reflects both professionalism and trustworthiness. The new brand utilises the UL element of the name as a clever device that is also be used as a social media icon and as a general graphic device.<br /><br />
#The team spent a lot of time developing the exact font style, line weights and proportions of the various elements in order to create a clean, professional and fit-for-purpose brand identity.<br />
#<a href="https://3.bp.blogspot.com/-LkMTLNqrHe0/WtCzcuDm5kI/AAAAAAAABn4/0VXkEEZ4oTsTtbtZ2PjRDOEeDHFBXNq7gCEwYBhgL/s1600/UnionLine_logos.jpg" imageanchor="1" style="clear: right; float: right; margin-bottom: 1em; margin-left: 1em;"><img border="0" data-original-height="1600" data-original-width="1600" height="200" src="https://3.bp.blogspot.com/-LkMTLNqrHe0/WtCzcuDm5kI/AAAAAAAABn4/0VXkEEZ4oTsTtbtZ2PjRDOEeDHFBXNq7gCEwYBhgL/s200/UnionLine_logos.jpg" width="200" /></a><br />
#The logo development is now being rolled out across newly published literature, stationery, exhibition panels as well as on-line collateral.<br /><br />
#UnionLine said <i>"We are really pleased with the new look and believe that this will help us to continue to take our organsiation successfully into the 21st century, Jonny and his team have done a really professional job, on budget and on time"</i><br /><br />
#Jonny Evans commented "it's always exciting to work with an existing brand along with its loyalties and customer expectations and to be able to successfully help them improve and expand their reach. Both in terms of brand identity and visual appeal we are delighted that the new identity has been so well received".<br /><br />
#One of the key remits was to ensure that Scottish law be included across the identity. To this end we developed UnionLine Scotland with the same amount of care and attention. Subtlety along with a quiet confidence underpins both brands, whilst retaining a strong link between the two markets.<br /><br />
#If your brand is looking tired and you would like to talk to the brand experts, then please give us a call on 01332 291141 and we will be happy to help and advise. Take a look at our creative portfolio <a href="http://www.parkhouse-evans.co.uk/flipbook/files/assets/basic-html/index.html#1" target="_blank">here</a>
#media:thumbnail = value: 
#guid = value: tag:blogger.com,1999:blog-389084634497824427.post-8854866983072220089
#atom:updated = value: 2018-04-13T06:47:46.582-07:00
#category = value: Advertising
#title = value: New Branding Excites the Unions
#thr:total = value: 0
#pubDate = value: Fri, 13 Apr 2018 13:45:00 +0000

eval "use XML::SimpleObject";
if($@){
#blog_url_out("the Blogger module is currently unavailable on this server");
$debug.= "The Blogger module 'XML::SimpleObject' is currently unavailable on this server..\n";
push @s,$debug;

} else {

my ($rerr,$rdata) = blog_get_remote($sname);
###blog_json_print( "$callback( { \"query\":[ { 'rerr':\"$rerr\",'rdata':\"".Data::Dumper->Dump([$rdata],["rdata"])."\" } ] } )" );
blog_json_print( "$callback( { \"query\":[ {'error' => 'blogger 1:\n\n$rerr ".Data::Dumper->Dump([$rdata],["rdata"])."'} ] }" ) if defined $rerr;

my $xml = new XML::SimpleObject(XML => $rdata,ErrorContext => 2);
###$debug.= Data::Dumper->Dump([$xml],["xml"])."\n";

foreach my $c ($xml->children_names){ #$debug.= "\nrss = c:$c \n";
my $fobj = $xml->child($c);
foreach my $c1 ($fobj->children_names){ #$debug.= "\nchannel = c1:$c1 \n";
if($c1 eq "channel" ){
my $f1obj = $fobj->child($c1);
foreach my $c2 ($f1obj->children){ 
if($c2->name eq "item" ){
#$debug.= "f1 = child: ".$c2->name.": ".$c2->value."\n";
my %entry = ();
foreach my $c3 ($c2->children){ 
#$debug.= "c3 = child: ".$c3->name.": ".$c3->value."\n"; 
$entry{$c3->name} = $c3->value; 
}
push @s,\%entry;
}
}
}
}
}

}

###blog_json_print( "$callback( { \"query\":[ ".JSON->new->allow_nonref->encode(\%DATA)." ] } )" );
###blog_json_print( "$callback( { \"query\":[ \"$debug'\"] } )" );

for my $i( 0..($count-1) ){ 
my %outs = %{ $s[$i] };
my $title = $outs{'title'};$title =~ s/^<br\s*\/*>//;
my $desc = $outs{'description'}; #$desc =~ s/^<a(.*?)<\/a>//;
$desc =~ s/^<br\s*\/*>//;
my $author = $outs{'author'};if( $author =~ /\((.*?)\)/ ){ $author = $1; }
push @u,'<div class="bloggerinner"><span class="bloggertitle">'.$title.'</span>'.$desc.'<br /><span class="bloggerby">by <a href="'.$outs{'link'}.'" title="link to Blog">'.$author.'</a></span></div>';
}

eval "use JSON";
if($@){
return blog_list_dump(\@u,'query');
} else {
for my $i(0..$#u){ $u[$i] = JSON->new->allow_nonref->encode($u[$i]); }
blog_json_print( "$callback( { \"query\":[ ".( join ",",@u )." ] } )" );
}

exit;



##

sub blog_get_remote{
my ($dest) = @_;
my $err = undef;
my $msg = "";
my ($req,$request,$res);
eval "use LWP::UserAgent";
if($@){
$err = "Unfortunately this server can\'t use LWP::UserAgent to open $dest:<br />Reason: $@";
} else {
use HTTP::Request::Common;
use LWP::Protocol::http; # stop the warning "possible typo" in next statement
push( @LWP::Protocol::http::EXTRA_SOCK_OPTS,MaxLineLength => 0 );
my $ua = LWP::UserAgent->new;
$ua->agent("thatsthat/$softversion (Ubuntu)");
$res = $ua->request(GET $dest);
if ($res->is_success){ $msg = $res->decoded_content; } else { $err = "Sorry, the server for [ $dest ] appears to be unavailable: ".$res->status_line." = ".$res->as_string; } #$res->content
}
return ($err,$msg);
}

sub blog_json_print{
my ($arr,$text) = @_;
print "Content-type: application/javascript\n\n";
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

sub blog_url_out{
my ($io) = @_;
print "Content-type: text/html\n\n";
print $io;
exit;
}

sub blog_list_dump{
my($data,$title) = @_;
$Data::Dumper::Purity = 1;
$Data::Dumper::Indent = 0;
#$Data::Dumper::Sortkeys = \&sort_dump;
my $d = Data::Dumper->new([$data],[$title],);
return $d->Dump;
}