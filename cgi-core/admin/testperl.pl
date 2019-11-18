#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5

#editthis version:8.2.2 EDGE

use strict;
use warnings;

use Config;
use File::Spec;

my ($lwp,$okLWP,$ua,$u,$auth,$capture,$daemon,$status,$ebay,$resp,$lsimple,$mails,$mime,$mlite,$esimple,$sender,$sendmail,$esender,$encode,$creator,$transport,$ios,$iostr,$ole,$smtp,$config,$filestat,$filefind,$filepath,$util,$filecopy,$filetmp,$cgi,$cgiescape,$cgicarp,$dumper,$encode2,$uri,$filebase,$filespec,$hreq,$jsn,$scalar,$sobj,$tloc,$face,$twit,$tiny,$imager,$whtm,$zip);

my $envpath = File::Spec->rel2abs( __FILE__ );
$envpath =~ s/(\/cgi\-bin|\/cgi)\/.*?$/$1/;
our $cgix = $1."/";

my $w = 35; 
my $f = "<b>%" . $w . "s</b> : %s\n"; 
my $f2 = " " x $w . " & %s\n";

my $ferr = "";
eval "use FCGI";
if( $@ ){
$ferr = "no FCGI: $!";
} else {
my $request = FCGI::Request();if ($request->IsFastCGI ){ $ferr = "FastCGI running"; } else { $ferr = "CGI running"; }
}

print "Content-type: text/html\n\n";

print "<html><body><pre>";

printf $f, "Server","<b>$ENV{'HTTP_HOST'}</b><br />";
printf $f, "editthis","v8.2.0";
printf $f, "OS",$Config{osname};
printf $f, "Version",$Config{archname};
printf $f, "Perl", "v$]";
printf $f, "envpath",$envpath;
printf $f, "CGI",$cgix;
printf $f, "Script User",getpwuid( $< );
printf $f, "Protocol",$ferr;
print "<br />";

printf $f,"Library Locations"," ";
#print $f, "CONF{smtp}", (defined $CONF && defined $CONF->{smtp} && defined $CONF->{smtp}->{enabled}? "" : "not " )."enabled";
printf $f, "\@INC", $INC[0]; foreach my $x (1..$#INC){ printf $f2, $INC[$x];}

print "<br />";

printf $f,"Environment Variables"," ";
foreach my $k (sort keys %ENV ){ 
printf $f, $k, $ENV{$k}; 
}
foreach my $k (sort keys %Config ){ 
printf $f, $k, $Config{$k}; 
}

print "<br /></pre></body></html>\n";

exit;