#!/usr/bin/perl -I/var/www/vhosts/pecreative.co.uk/perl5/lib/perl5
#editthis version:8.2.2 EDGE
package defs;
use strict;
our $root = $ENV{'SERVER_NAME'};$root =~ s/(^www\.)//i;
our $http = ( $ENV{'HTTPS'} )?"https:":"http:";
our $softversion = "8.2.2";
### EDIT BELOW
our $obase = $http."//domain.com/"; #no subfolder
our $otitle = "Domain Name"; # = site title
our @titlesep = ( "-","Domain Name" ); # = <title>Page H1 Text - site title</title>
our @serverip = ("0.0.0.0"); # = site IP(s)
our @toaddr = ("admin\@domain.com"); # = "address1\@etc.com","address2\@etc.com"
our @bccaddr = (); # = "address1","address2","admin\@thatsthat.co.uk"
our $cgipath = "cgi-bin/"; # cgi-bin location //www.site.co.uk/[X/]
our $webbase =  $root; # usually "httpdocs|public_html|$root"
our $subdir = ""; # html subfolder: //www.site.co.uk/[X/] - add closing /
our $adminaddr = "admin\@domain.com";
our $fromaddr = "webadmin\@domain.com"; # website\@x.com - IIS: use $mail_program user
our $etitle = "Domain Title"; # = email default title
our $title = "Email Enquiry"; # = email default form action
our $thank = "Thank You"; # = email default signoff
our $mail_program = "/usr/sbin/sendmail -t"; #IIS /usr/sbin/sendmail -f admin\@x.com"
our @emailorder = (); #( 'name','address','house-number','street','area','town','county','country','postcode','email','phone','message','details' );
our $authuser = undef; #"no"
our $authpass =undef; #"no"
our $smtp_server = "smtp.".$root.":25"; #"127.0.0.1";
our $authsmtp = undef;
our $authport = 25;
our $spamurl = 1; #undef
our $uncache = 1; #undef
our $ftpbase = "httpdocs/";
our $bakmaster = "";
our $ftpmaster = "";
our $ftppass = undef;
our $ftpcheck = undef;
our $dositemap = 1; #undef
our @defarchive = ( 'News' ); #()
our $novelpage = ""; #html page
our $novelbase = "documents/Novels/";
our $noveldir = ""; #Name-of-Novel
our $chapterfile = "chapter";
# form mail group definitions:
our %RECEIVERS = ( # $toaddr will get copy anyway
#'group1' => "y\@googlemail.com",
#'group2' => "y\@fastmail.fm"
);
# form ajax response text:
our %COPY = (
'Email Enquiry' => "Your details have successfully been sent and you will receive a response shortly.",
'Contact Enquiry' => "Your details have successfully been sent and you will receive a response shortly.",
'Ring Back Enquiry' => "Your details have successfully been sent and you will receive a response shortly.",
'Dropbox Download' => "Partner Portal file download has been requested:",
'Library Download' => "Literature download confirmations.",
'Members Login' => "Login successful.",
'Downloads' => "Thank you. Your download has been emailed to the address provided.",
'White Paper' => "Thank you for requesting access to our White Papers and Reports.",
'Registration Request' => "Thank you for registering; we will be contacting you shortly.",
'New Subscriber - Group' => "Thank you for subscribing.",
'Question' => "Your feedback has been successfully received.",
'Prize Draw' => "Your details have successfully been sent. Good Luck!."
);
our %sharelist = ( 
'linkedinbutton' => [ '<a href="https://www.linkedin.com/shareArticle?mini=true&url=','&title=','&summary=&source=" class="blank" title="Share on Linkedin" target="_blank">&#160;</a>' ],
'twitterbutton' => [ '<a href="https://twitter.com/intent/tweet?url=','&via=Online_Derby" title="Share on Twitter" target="_blank">&#160;</a>' ],
'facebookbutton' => [ '<a href="https://www.facebook.com/sharer/sharer.php?u=','" class="blank" title="Share on facebook" target="_blank">&#160;</a>' ],
'googlebutton' => [ '<a href="https://plus.google.com/share?url=','" class="blank" title="Share on Google+" target="_blank">&#160;</a>' ]
);
# email html footer:
our $efoot = <<_MSG_FOOT;
<br />
<strong><a style="color:#c00" href="$http//domain.com">domain.com</a></strong><br />
<br />
<b>Domain Name (c) 2020</b><br />
<br />
This message is for the designated recipient only and may contain confidential, privileged, proprietary, or otherwise private information. If you have received it in error, please notify the sender immediately and delete the original. Any other use of this email by you is prohibited.<br /> 
<br />
_MSG_FOOT
#'
# form html header:
our $htmlhead = <<_HTML_OUT_;
<!DOCTYPE html> 
<html lang="en">
	<head>
	
	</head>
	<body style="width:90%; font-family:verdana,sans-serif; color:#000; font-size:90%;">
_HTML_OUT_
# form html footer:
our $htmlfoot = "</body></html>";
our $paragraph_limit = 250;
our $mobpic = "_mobile";
our %imgsizes = ( 
'Document Thumbnail' => ["documents/Digital/","Document Thumbnail,_thumb,202,150"],
'Content Picture' => ["documents/Images/elements/","Content Image","_content,900,600"],
'Events Header Image' => ["documents/Images/events/","Events Header Image,_header,900,400+Mobile Version,_header_mobile,480,250"],
'News Header Image' => ["documents/Images/news/","News Header Image,_header,900,400+Mobile Version,_header_mobile,480,250"],
'Product Image' => ["documents/Images/products/","Product Image,_product,300,300"],
'Product Logo' => ["documents/Images/logos/","Product Logo,_logo,300,300"],
'Team Picture' => ["documents/Images/team/","Team Picture,_team,300,300"],
'Video Screengrab' => ["documents/Images/videos/","Video Screengrab,_video,460,260"] 
);
our %editusers = ( 'News' => 'edituser' );
# editable tags:
our %editareas = (
'title' => 0, #editable types
'text' => 0,
'image' => 0,
'script' => 0,
'module' => 0,
'url' => 1, #page only
'link' => 1,
'shortname' => 1,
'menuname' => 1,
'menu' => 1,
'author' => 1,
'modified' => 1,
'date' => 2, #tags
'focus' => 2,
'area' => 2,
'archive' => 2,
'group' => 2,
'tags' => 2,
'text' => 2
);
our $libtags = "Url Image Title Created";
our $droptags = "Archive Area Author Focus Group Tags Text";
our %defsort = (
'News.html' => '21',
'Events.html' => '21'
);
our %headers = (
'analytics_gref' => [ "name","content","UA-00000000-1","Google Code" ],
#'analytics_lref' => [ "name","content","domain.com","Lead Forensics Code" ],
#'analytics_esref' => [ "name","content","i7j0","Es Mail Code" ],
#'analytics_wref' => [ "name","content","00aaaa00-a000-0aaa-0aa0-a000a000aaa0","WOW Code" ],
'copyright' => [ "name","content","Copyright (c) Dave Pilbeam 2019" ],
'author' => [ "name","content","Domain Name" ],
'og:image' => [ "property","content",$obase."LIB/default-page.jpg" ],
'description' =>  [ "name","content","Description goes here." ],
'keywords' =>  [ "name","content","Keywords go here." ]
);
our %defheaders = (
'application-name' => 'thatsthat',
'viewport' => 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0'
);
our %signinfields = (
'newalert' => "New Member Sign-Up Details",
'usermsg' => "Congratulations, you are now a member of Our Club",
'useremail' => "Your New Sign-up Details",
'loginfile' => "Sign-In.html",
'masteruser' => "member",
'masterpass' => "OurClubPassword",
'dest' => "members/index.html",
'titleform' => '<ul class="area editablearea signtitlearea">.*?<\/ul>',
'inform' => '<div class="form signin">\s*<form.*?>\s*<fieldset>.*?<\/fieldset>\s*<\/form>\s*<\/div>',
'upform' => '<div class="form signup">\s*<form.*?>\s*<fieldset>.*?<\/fieldset>\s*<\/form>\s*<\/div>'
);
our %inputinfo = (
'title' => '<span class="inputinfo">The <b>Page Title</b> (150 characters maximum) will become the title displayed on the page itself in a H1 tag.</span>',
'menu' => '<span class="inputinfo">The <b>Title of Page in Menus</b> (50 characters maximum) will become the Page name displayed in the Site Navigation Menus and will also be the actual Page URL, eg: Menu name <b>My New Page</b> will have the Page URL <b>My-New-Page.html</b> where spaces are replaced by dashes and only basic characters are allowed.</span>',
'short' => '<span class="inputinfo">The <b>Page Short Title</b> (30 characters maximum) will be displayed instead of the full Page Title when there is limited space; eg: in Tablet or Mobile views.</span>',
'alias' => '<span class="inputinfo">Entering an <b>External Link or Alias</b> causes the Site Navigation Menus to follow that link instead of going to the actual page. This new link must either be <b>an existing Page URL</b> or <b>an external URL starting with http(s)://</b></span>',
'seo' => '',
'sizer' => '<div class="tt_sizer_info"><b>Upload the Images in this list at full size.</b><p>Check this box to upload a copy of all included Images at full size.</p>	<b>Create Document Thumbnails</b><p>Check this box to upload a copy of all included Images as thumbnails to display in a Library Module.</p>	<b>Create News Header Images</b><p>Check this box to upload a copy of all included Images as News Header Images (suitable for display in a Slideshow Module and also includes Mobile versions).</p><b>Create Staff Pictures</b><p>Check this box to upload a copy of all included Images as a Staff Picture.</p><b>Create Video Screengrabs</b><p>Check this box to upload a copy of all included Images as Video Screengrabs to display in a Video Module.</p></div>',
'tags' => ''
);
our $libdeftxt = <<_LIBDT_;
url: name.pdf
image: name_thumb.jpg
focus: focus text 1
focus: focus text 2
area: UK
tags: tag text 1
tags: tag text 2
title: title text
text: A line of text.
text: Another line of text.
group: group text
created: 01/01/2019
author: Dave Pilbeam
_LIBDT_
### <-- EDIT ABOVE
our $parknetip = "";
our %perms = ( 'user' => "apache",'group' => "psacln" );
our @bakauth = ();
our $cssview = "LIB/";
our $docview = "documents/";
our $partnerview = "partners";
our $resourcefolder = "Digital";
our $imagefolder = "Images";
our $partnerfolder = "Partner-Portal";
our $pdffolder = "PDF";
our $templatefolder = "Templates-and-Guides";
our $shopfolder = "UPLOADS/SHOP";
our $restorefolder = "UPLOADS/RESTORE";
our $trashfolder = "UPLOADS/TRASH";
our $serverenv = $ENV{'SERVER_ADDR'};if( !$ENV{'SERVER_ADDR'} ){$serverenv = $ENV{'LOCAL_ADDR'};} #208.109.250.222
our $nwbase = $ENV{'DOCUMENT_ROOT'}."/";if( !$ENV{'DOCUMENT_ROOT'} ){my $pp = $ENV{'PATH_TRANSLATED'};$pp =~ tr/\\/\//; my $ii = $ENV{'PATH_INFO'};$ii =~ tr/\\/\//;$pp =~ s/($ii)$//;$nwbase = $pp."/"; }
our $cgibase = $ENV{'SCRIPT_FILENAME'};if( !$ENV{'SCRIPT_FILENAME'} ){ $cgibase = $ENV{'PATH_TRANSLATED'};$cgibase =~ tr/\\/\//; }
$cgibase =~ s/^(.+\/).*?\.p[lm]$/$1/;
our $nwurl = $http."//".$ENV{'SERVER_NAME'}."/";
our $cgiurl = $http."//".$ENV{'SERVER_NAME'}."/".$cgipath;
our $base = $nwbase.$subdir;
our $baseview = $nwurl.$subdir;
our $imagerelay = "https://thatsthat.co.uk/cgi-bin/imager.pl";
our $cgirelay = "https://thatsthat.co.uk/cgi-bin/";
our $thumb = '64';
our $delim = "."; #_
our $spacer = "-";
our $docspace = "-";
our $postmax = 10240000;
our $upload_limit = 9;
our %imager_limits = ( 'width' => 2400,'height' => 4500,'bytes' => 12_000_000 );
our @required = ( "index.html","Cookies.html","Privacy-Policy.html","Privacy-Policy-&-Legal-Disclaimer.html","Legal-Disclaimer.html",'Legal.html',"Search.html","Site-Map.html","Terms-and-Conditions.html" );
our $body_regx = [ 'tt_nopointer','tt_notouch','tt_nocss3','tt_uncookied','tt_unjs' ];
our $homeurl = "Home"; #Group
our $taglister = ".tags.txt";
our $liblister = ".library.txt";
our $chapterlister = "chapter-([0-9]+).txt";
our $htmlext = "html";
our $index_file = "index.".$htmlext;
our $redirect = $baseview.$index_file;
our $site_file = "Site-Map.html";
our $search_file = "Search.html";
our $menu_limit = 3;
our $adminbase = "admin/";
our $backupbase = "admin/BACKUP/";
our $versionbase = "VERSIONS/";
our $page_limit = 180;
our $version_limit = 3;
our $delete_limit = 10;
our $repdash = "~";
our $defsep = "<-//->";
our $defrestore = "r_R--R_r";
our $editable = "tt_alldiv";
our $emptxt = "directory is empty";
our $navicontemp = "default";
our $sendtemp = $base."hticons/TEMP/"; # /cgi-bin/TEMP/
our $remlister = "view.pl";
our $auxfiles = "txt|htaccess|css|js|xml|ico|jpg|png|gif|pm|pl";
our %EXT_IMGS = ('image/gif' => 'GIF','image/jpeg' => 'JPEG','image/jpg' => 'JPG','image/png' => 'PNG');
our %EXT_LIB =  ('msword' => 'DOC','vnd.openxmlformats-officedocument.wordprocessingml.document' => 'DOCX','pdf' => 'PDF','text' => 'TXT','vnd.ms-excel' => 'XLS','vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'XLSX','vnd.ms-powerpoint' => 'PPS','vnd.openxmlformats-officedocument.presentationml.slideshow' => 'PPSX','vnd.openxmlformats-officedocument.presentationml.presentation' => 'PPTX');
our %EXT_FILES = ('x-msaccess' => 'MDB','text' => 'MSG','text' => 'OFT','application/x-photoshop' => 'PSD','zip' => 'ZIP');foreach my $k(keys %EXT_LIB){ $EXT_FILES{$k} = $EXT_LIB{$k}; }
our %FX = ('DOCX' => 'Word','DOC' => 'Word','HTML' => 'html','PDF' => 'PDF','PSD' => 'Photoshop','PPS' => 'PPS','PPT' => 'PPT','PPTX' => 'PPTX','TXT' => 'text','OFT' => 'oft','MSG' => 'msg','XLS' => 'Excel','XLSX' => 'Excel','ZIP' => 'Zip','PNG' => 'png','JPG' => 'jpg','EPS' =>'eps');
our %MS = ('january' => 11,'february' => 10,'march' => 9,'april' => 8,'may' => 7,'june' => 6,'july' => 5,'august' => 4,'september'=>  3,'october' => 2,'november' => 1,'december' => 0);
our @LISTDIR = ( "admin","email","FONTS","hticons","cgi-bin","documents/Images","documents/Sandbox","LIB/css/css_tt_edit","UPLOADS","VERSIONS"); #"documents/PDF"
our @BANDIR = ( "admin","documents",'email',"FONTS","LIB","hticons","cgi-bin","LIB/css/css_tt_edit","UPLOADS","VERSIONS","partners");
our @BANFILE = ( "header\.html","footer\.html","google(.*?)\.html","gravityscan(.*?)\.php" );
our @RESERVED = ($cssview.'css',$cssview.'navigation');
our @BANSERV = ('plesk-stat');
our @XLIST = ();
our @XXLIST = ('150.70.');
our %defsections = (
'Inline Styles' => [ '','(<style>.*?<\/style>\s*<link)' ],
'Top Bar' => [ '#tt_topbar','(<div id="tt_topbar">\s*<div class="tt_topbarinner">\s*<div>.*?<\/div>\s*<\/div>\s*<\/div>\s*<div)' ],
'Archive Index' => [ 'div.archiveindexsection','(<div class="section editablesection newsindexsection.*?">\s*<div class="sectioninner">\s*<div class="threefourgrid">.*?</div>\s*<div class="onefourgrid">.*?</div>\s*</div>\s*</div>)' ], #<div class="section footersection">
'Footer Section' => [ 'div.footersection','(<div class="section footersection">\s*<div class="sectionfooterinner">.*?<\/div>\s*<\/div>\s*</div>\s*<\/div>\s*<\/div>\s*<\/div>\s*<div class="tt_editref"></div>)' ]
);
our %defmods = ( 
counter => '<div class="text" data-start="0%" data-end="50" data-interval="50" data-target="1" data-units="2">\n<p class="format1">0%</p><p class="format6">of the total</p>\n</div>',
dropwrapper => '<label for="dropwrapper0" class="nonselect" title="view Contacts">CONTACT US<span class="dropwrapper0icon"></span></label>\n<input id="dropwrapper0" type="checkbox" />\n<div class="text"><table><tbody><tr><td>PE creative:</td><td>01332 291141</td></tr><tr><td>That\\\'s That Ltd:</td><td>01332 294746</td></tr></tbody></table></div>',
form =>
'<div class="form email">\n'.
'<form id="cgi_form_0" method="post" accept-charset="UTF-8" action="'.$cgiurl.'email.pl"><fieldset>\n'.
'<ul class="ful">\n'.
'<li class="fli"><label for="message_0">Your question<span class="required"></span></label><textarea rows="15" cols="30" name="pre_message_0" id="message_0"></textarea></li>\n'.
'<li class="fli"><label for="name_0">Name<span class="required"></span></label><input name="pre_name_0" id="name_0" type="text" /></li>\n'.
'<li class="fli manifest"><label for="address_0" tabindex="-1">Address<span class="required"></span></label><input name="pre_address_0" id="address_0" type="text" tabindex="-1" /></li>\n'.
'<li class="fli"><label for="email_0">Email<span class="required"></span></label><input name="pre_email_0" id="email_0" type="text" /></li>\n'.
'<li class="fli"><label for="spamcheck_0">10+1=? (to prevent spam) <span class="required"></span></label><input name="pre_spamcheck_0" id="spamcheck_0" type="text" /></li>\n'.
'</ul>\n'.
'<ul class="ful"><li class="fli">\n'.
'<input class="sub-s" value="Send &#187;" name="submit_0" type="submit" />\n'.
'<input value="Contact Enquiry" name="opt_formtype_0" id="formtype_0" type="hidden" />\n'.
'<input value="11" name="opt_spamresult_0" id="spamresult_0" type="hidden" />\n'.
'</li></ul>\n'.
'</fieldset></form>\n'.
'</div>\n' ,
googlemap => '<div class="text" data-zoom="17" data-icon="documents/Images/icons/map-thatsthat-icon.png" data-latitude="52.918627" data-longitude="-1.478389"><a href="https://www.google.com/maps/place/Parkhouse+Evans+Ltd/@52.918627,-1.478389,17z/data=!4m5!3m4!1s0x0:0x5da005a45465240e!8m2!3d52.9186273!4d-1.4783888?hl=en-GB" title="thatsthat" class="popup button" style="background-image:url(documents/Images/elements/map-googlemap.png);"> </a></div>',
library => '<div class="text"><a data-form="on" href="'.$cgiurl.'documents/Digital/" title="view digital resource" target="_blank">View our Digital Resource Library &#62;&#62;</a></div>',
menu => '<div class="text">\n<ul class="sidelinks">\n<li><a title="link to map of site contents" href="Site-Map.html">Site Map </a></li>\n</ul>\n</div>',
#quotebox => '',
rss => '<div class="text"><a data-posts="3" href="https://twitter.com/thatsthatltd" title="read our latest posts on Twitter">Follow thatsthat on Twitter</a></div>',
#scroll animation' => '',
script => '<div class="text"><script type="application/javascript" charset="utf-8">//code goes here<\/script></div>',
slider => '<div class="text"><p class="format1">Title</p><p>Text</p></div>',
table => '<table><tbody><tr><td>Name 1:</td><td>00000 000000</td></tr><tr><td>Name 2:</td><td>00000 000000</td></tr></tbody></table>',
view => '<div class="text"><a data-id="list" data-sort="21" data-amount="1" data-exclude="me" href="'.$cgiurl.'view.pl?url=News.html" title="view News page">link to latest news</a></div>' #,
#videopanel => '<div class="video-banner banner1" data-video-banner="https://player.vimeo.com/external/232830853.hd.mp4?s=917915a20e91670341b4d249bde9481bff3b8a96&profile_id=174" data-video-banner-poster="documents/Images/videos/videopanel-default.jpg">\n<div class="responsive-video"><video poster="documents/Images/videos/videopanel-default.jpg" autoplay="" loop=""><source type="video/mp4" src="https://player.vimeo.com/external/232830853.hd.mp4?s=917915a20e91670341b4d249bde9481bff3b8a96&profile_id=174"></source></video></div>\n<div class="video-content"><div class="video-content_inner"><div class="video-content_inner_inner"><h1>Helping you make the most of your mainframe environment</h1></div></div></div>\n</div>'
);
our @UTF = (
[ "\x{00ae}","&reg;","&#174;" ],
[ "\x{00a9}","&copy;","&#169;" ],
[ "\x{00a0}","&nbsp;","&#160;" ],
[ "\x{2122}","&trade;","&#8482;" ],
[ "\x{00a3}","&pound;","&#163;" ],
[ "\x{020ac}","&euro;","&#8364;" ],
[ "\x{2013}","&ndash;","&#8211;" ],
[ "\x{2014}","&mdash;","&#8212;" ],
[ "\x{2018}","&lsquo;","&#39;" ],
[ "\x{2019}","&rsquo;","&#39;" ],
[ "\x{201a}","&sbquo;","&#39;" ],
[ "\x{201c}","&ldquo;","&#39;" ],
[ "\x{201d}","&rdquo;","&#39;" ],
[ "\x{201e}","&bdquo;","&#39;" ]
);
our @UTF1 = (
[ "\&amp;","&#38;" ],
[ "\x{0x2A}","&#42;" ],
[ "\x{00ac}","&#172;" ],
[ "\x{00ab}","&#171;" ],
[ "\x{00bb}","&#187;" ],
[ "\x{00a2}","&#162;" ],
[ "\x{005}","&#165;" ],
[ "\x{00b5}","&#181;" ],
[ "\x{2022}","&#8226;" ],
[ "\x{2713}","&#10003;" ],
[ "\x{2714}","&#10004;" ],
[ "\x{2717}","&#10007;" ],
[ "\x{2718}","&#10008;" ]
);
1;