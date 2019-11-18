
/*#editthis version:8.2.2 EDGE*/

Object.append(Element.NativeEvents,{dragenter:2,dragleave:2,dragover:2,drop:2});

var E = E || { bsr: (window.navigator.pointerEnabled || window.navigator.msPointerEnabled)?4:(!!window.opera || navigator.userAgent.indexOf(' OPR/') >= 0)?3:('WebkitAppearance' in document.documentElement.style)?2:(document.all)?1:(window.InstallTrigger)?0:4,css:['-moz-','-ms-','-webkit-','-o-',''] };
Object.append(E,{
eactive: {},
eclips: {},
edge: '-ms-ime-align' in document.documentElement.style,
efiles: null,
eform: { 'msg':'Please select','req':'<span class="required"></span>','textarea':{'cols':'30','rows':'10'} },
eimages: null,
eimgacc: 0,
eimgnew: ['125','150','175','200','225','250','275','300','50','75','100'],
emissing: 'LIB/css/missing-default.png',
emodpage: 'admin/modules.html',
esections: [],
esort: { 'unrank':'descending menu rank','rank':'ascending menu rank','21':'latest date first','12':'earliest date first','az':'alphanumeric','za':'reverse alphanumeric' },
etextformat: [0,1,2,3,4,5,6,7,8,9],
etitle: document.title,
gridlist: '.sectiontopinner > div[class$=grid],.sectioninner > div[class$=grid],.sectionfooterinner > div[class$=grid]',
pl: '',
prepaste: false,
pullpl: 'view.pl',
rangy: { 'editlink':null },
safari: (navigator.vendor && navigator.vendor.indexOf('Apple') > -1 && !navigator.userAgent.match('CriOS'))?1:(Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0)?1:null,
sectionlist: '.section',
menulist: ['','textarea','text','link','imagearea','image','upload','feedarea','feed','revert','save','formarea','form','scriptarea','script','input','type','','layoutarea','','sectionarea','clipboard'],
url: { cgi:'',folder:'',page:'',site:'',uri:document.URL.replace(/^(sht|f|ht)tp:\/\//,'') },
vids: ['youtube','youku','vimeo'],
viewlist: '.edittitle,.edittext,.editimage,.editline,.editmodule,.editscript',
width: 'desktop',
all:null,ebar:null,ebg:null,editable:[],eloutput:null,esaveable:null,escroll:0,eselection:null,egrids:[],esections:[],html:null,scrollbase:null,timer:null
});

E.pl = E.url.uri.replace(/\?.+$/,'').replace(/^(http.*?)*\/\//,'');E.pl = (('https:' == window.location.protocol)?'https':'http')+'://'+E.pl;E.url.cgi = E.pl.replace(/\/admin.+$/,'/');
E.edittypes = { //E.edittypes.blocks.editmodule.config
areas: {
//'canvas':{},
'minheights':{ name:'',html:'',config:{ mobile:'on|off' } },
//'sandbox':{},
'search':{ name:'Search Area',html:'',config:{ inputs:'min|library',pos:'top|bottom',target:'',type:'all|documents|digital|pages' },defaults:{ inputs:'min',pos:'top',target:'off',type:'all' } },
'slideshow':{ name:'Slideshow Area',html:'',config:{ auto:'on|off',controller:'on|off',	hover:'on|off',start:0,delay:0,interval:0,startdelay:0,transition:'',showholder:'on|off',keepholder:'on|off',key:'on|off' },defaults:{ auto:'off',controller:'on',hover:'off',start:0,delay:3000,interval:1000,startdelay:0,transition:'none',showholder:'off',keepholder:'off',key:'off'} },
'stacker':{ name:'Stacker Area',html:'',config:{ min:0,max:0,rows:0,columns:0,grid:0,mobile:0 } },
'swiper':{ name:'Swiper Area',html:'',config:{ autoplay:'on|off',current:0,direction:'left|right',duration:0,interval:0,nav:'on|off',id:'' },defaults:{ autoplay:'on',current:1,direction:'left',duration:0.8,interval:5,nav:'on|off',id:'' } }
},
blocks:{
'edittitle':{ name:'Header',html:'<div class="text">\n<p>New Header</p></div>',config:{} },
'edittext':{ name:'Text',html:'<div class="text">\n<p>New Text</p></div>',config:{} },
'editimage':{ name:'Image',html:'<div class="text" style="background-image:url(documents/Images/elements/css-placeholder-img.jpg);">\n<p>&#160;</p></div>',config:{} },
'editline': { name:'Line',html:'<div class="text">\n<hr /></div>',config:{} },
'editmodule':{ name:'Modules',config:{
'counter': { name:'Counter',html:'',config:{ start:0,end:0,interval:0,target:0,units:0 } },
'dropwrapper': { name:'Drop Area',html:'',config:{ text:'',title:'' } },
'form':{ name:'Form',html:'',config:{ cgiurl:['input',{'type':'checkbox','value':'1'},'Send using Form action:'],cgireturn:['input',{'type':'checkbox','value':'1'},'Show response in Form area:'],copytype:['input',{'type':'checkbox','value':'1'},'Send a copy to Form email field address:'],formtype:['select',{'html':''},'Select Form subject type and response:',{}],html:['input',{'type':'checkbox','value':'1'},'Don\'t send emails as html:'],locate:['input',{'type':'text','value':''},'Forward Form response to new page:'],recipients:['select',{'html':''},'Send copies to group recipients:',{}],spamresult:['input',{'type':'text','value':''},'The spam question answer:'] } },
'googlemap':{ name:'Google Map',html:'',config:{ latitude:0,longitude:0,href:'',icon:'',zoom:'12|13|14|15|16|17|18',style:'',title:'' },defaults:{ zoom:15 } },
//'quotebox':{ name:'Quote Box',html:'',config:{ type:'rollover|modal|target',element:'quotebox-target' } },
'library':{ name:'Library',html:'',config:{ amount:0,depth:0,form:'',id:'',sort:'date-descending|date-ascending|alphabetical|reverse-alphabetical',text:'',title:'',names:'',onlyarea:'on|off',onlyfocus:'on|off',values:'' },defaults:{ onlyarea:'off',onlyfocus:'off',sort:'date-descending' } },
'menu': { name:'Menu',html:'',config:{ href:'',type:'sidelinks',title:'' } },
'rss':{ name:'Social Media Feed',html:'',config:{ characters:0,href:'',html:'on|off',posts:0,rules:'on|off',text:'',title:'' },defaults:{ characters:200,html:'on',posts:3,rules:'off' } },
//'scroll animation': { name:'Scroll Animation',html:'',config:{ type:'left|up|right|down|scale|appear1,appear2,appear3' },defaults:{ type:'left' } },
'script':{ name:'Script Area',html:'',config:{ text:'' } },
'slider': { name:'Slider',html:'',config:{ effect:'slideup|slidedown|slideleft|slideright',parent:'' },defaults:{ effect:'slideup',parent:'li.column'} },
'view':{ name:'Page Feed',html:'',config:{ id:'index|list|menu|images|blocks|filelist',amount:0,exclude:'none|me',format:'none|library|lightbox|slideshow|stacker|swiper',full:0,href:'',names:'',link:'on|off',onlyarea:'none|me',onlyfocus:'none|me',pass:'',scroll:'on|off',sort:'rank|unrank|21|12|az|za',start:'none|random',submenu:'on|off',title:'',values:'',wrap:'none|list|pull' },defaults:{ id:'list',amount:0,format:'none',full:1,link:'on',onlyarea:'none',onlyfocus:'none',scroll:'off',sort:'rank',start:'none',submenu:'off',wrap:'none' } },
//'videopanel':{ name:'Video Player',html:'',config:{ banner:'',href:'',poster:'',type:'vimeo|youtube' } } 
} }
},
views: { 
'accordion':{},
'tabs':{} 
}
};

var G = G || {};
Object.append(G,{
modules: [],

css:{
onF: function(a){ var c = [],s = '';Object.each(a,function(v,k){ var i;for(i=1;i<v.length;i++){ c.push( G.css.setF(k,i,v[i]) ); }});var j;for(j=0;j<c.length;j++){ var r = ( typeOf(c[j][1]) == 'array')?c[j][1].join(' '):c[j][1];if(r && r != ''){if(r.test(/^\@/)){s+= r+'\n';} else {s+= c[j][0]+' { '+r+' }\n';}} }if(E.bsr == 2){ G.mobile.webkit.each(function(z,i){ s+= z+'\n'; });}if(E.bsr == 4){ G.mobile.ie10.each(function(z,i){ s+= z+'\n'; });}return s; },
setF: function(a,b,c){ 
var j = '',n = [],p = '',q = '',r = [],t,u = [];
switch(a){
case 'loader': p = c[1],t = ['-moz-','','-webkit-','-o-',''][E.bsr];u = ['','','-webkit-','',''][E.bsr]; j = (u == '-webkit-')?' -webkit-animation-direction:linear;':'';return ['',(E.capable)?'@'+t+'keyframes '+c[0]+' { 0%{ opacity:1; } 100%{ opacity:0; } } .'+c[0]+' { position:absolute; top:50%; left:50%; width:32px; height:32px; margin:-16px 0 0 -16px; opacity:'+c[3]+'; } .'+c[0]+' span { position:absolute; display:block; width:'+c[2]+'px; height:'+c[2]+'px; margin:0; padding:0;'+u+'animation-name:'+c[0]+'; '+u+'animation-duration:'+p[0]+'; '+u+'animation-iteration-count:infinite;'+j+' } .'+c[0]+'1 { '+u+'animation-delay:'+p[1]+'; top:0; right:0; } .'+c[0]+'2 { '+u+'animation-delay:'+p[2]+'; bottom:0; right:0; } .'+c[0]+'3 { '+u+'animation-delay:'+p[3]+'; bottom:0; left:0; } .'+c[0]+'4 { '+u+'animation-delay:'+p[4]+'; top:0; left:0; }':'']; break;
case 'tt_unselect': p = '-user-select:none;',r = ['-moz'+p,'-ms'+p,'-webkit'+p,'',p];return ['.'+a,r[E.bsr]+' cursor:pointer;']; break;
}
}
},

functions:{
download: function(a){ a.attachMe({ 'click':function(a){ var h = a.getParent('form').getElement('div.nav-controls a.nav-cancel').getProperty('href'),j = [new Element('div',{'class':'infotext','html':'Your download should start shortly..'}),new Element('a',{'class':'navblock nav-return','styles':{'float':'right'},'href':h,'title':'back to folder','html':'&#160;' }) ];new BgCLS(null,{html:j,sw:'hide'}); } }); } 
},

/////////////////////////////////////

eaddbarG: function(){ var p;if( $('editthis-bar') ){ E.ebar = $('editthis-bar');E.ebar.getElements('.navblock:not(a):not(.linkeditor):not(.inputeditor):not(.typeeditor):not(.moduleeditor):not(.imageeditor):not(.clipeditor)').each(function(z,i){ z.disableMe().touchMe(null,null,G.eblocknavG); },this); } },
eadjustsaveG: function(a,b){ if(!b){$$(a).unclassMe('unrevert unsave');} else if(b == 3){a[0].addClass('unrevert');a[1].addClass('unsave');a[2].addClass('asrevert');} else if(b == 2){a[0].addClass('unrevert');a[1].addClass('unsave');} else {a[0].unclassMe('unrevert');a[1].addClass('unsave');} },

earrangeG: function(a,b,c){
var d = [0,0],f,g,ff,h = {'one':1,'two':2,'three':3,'four':4,'five':5},j,m,mm,n = a.getElement('.text'),o = '',p,q = { 'padding-left':['5','10','15','20'],'padding-right':['5','10','15','20'],'padding-top':['5','10','15','20'],'padding-bottom':['5','10','15','20'],'width':['25','33','50','66','75'],'imgheight':['30','40','50','60','70','80','90','100','110','120','130','140','150','160','170','180','190','200','210','220','230','240','250','260','270','280','290','300'] },t = { 1:'one',2:'two',3:'three',4:'four',5:'five' },v = a.retrieve('editdata'),w,y;
console.log('earrange: ',a,b,c,' = parent:',v.parent,' parenttype:',v.parenttype,' subtype:',v.subtype,' type:',v.type,' n:',n,' editdata:',v);

mm = function(ma,mb,mc){console.log('mm: ',ma,mb,mc);var mw,mp;if(mc && mc == 'up'){mp = mb.goAr(ma,1);mw = (mp >= mb.length-1)?'after':'before';} else {mp = mb.goAr(ma);mw = (mp < 1)?'before':'after';}ma.inject(mb[mp],mw);};
ff = function(fa,fb){ var fg = fb.getPrevious('div[class*=edittext]'),fp,fq,fr = q[fa],fs = [fb],fw = 0,fx = new RegExp(fa+'([0-9]+)','i');fp = ( fb.get('class').test(fx) )?RegExp.$1:''; //console.log('ff: fa:',fa,' fb:',fb,' = fr:',fr,' = fp:',fp,' fs:',fs);
if(fa == 'width' && fb.hasClass('tt_forced') && fg){fs.push(fg);}
if(fp == ''){$$(fs).addClass(fa+q[fa][0]);} else { fw = fr.indexOf(fp);if(fw >= fr.length-1){ $$(fs).removeClass(fa+q[fa][q[fa].length-1]); } else { $$(fs).removeClass(fa+fr[fw]).addClass(fa+fr[1+fw]); } } 
};

if(v && v.parent){
switch(b){
case 'add': if(v.subtype == 'section'){ w = a.clone();w.removeClass('tt_sectionactive').addClass('tt_sectionwaiting').inject(a,'before');G.eselectsectionG(); } else if(v.subtype == 'grid'){ w = a.clone();w.removeClass('tt_gridactive').addClass('tt_gridwaiting').inject(a,'before');G.eselectgridG(); } else { if( a.getElement('form[id^=cgi_form]') ){m = $('body0').getElements('form[id^=cgi_form]').length;w = a.cloneidMe(m);} else {w = a.clone();}w.removeClass('tt_areaactive').addClass('tt_areawaiting').inject(a,'before');G.eselectG(); }G.emenuiconG(a);a.scrollMe(); break;
case 'change': case 'format': j = a.get('class');if( j.test('fullwidthgrid') ){ o = 'fullwidthgrid';p = 'twotwogrid'; } else { if( j.test(/(one|two|three|four|five)(two|three|four|five)grid/) ){ o = RegExp.$1+RegExp.$2+'grid';d = [ h[RegExp.$1],h[RegExp.$2] ];if(b == 'change'){ f = 1+d[0];if(f > 5 || f > d[1] ){f = 1;}p = t[f]+''+t[d[1]]+'grid'; } else { f = 1+d[1];if(f > 5){f = 2};p = 'one'+t[f]+'grid'; } } } if(p){ a.removeClass(o).addClass(p); } break;
case 'delete': G.emenuswitchG(null,0);if(v.subtype == 'section'){ a.vizMe('hide',function(){a.destroy();G.eselectsectionG();G.emenufillG('section');}); } else if(v.subtype == 'grid'){ a.vizMe('hide',function(){a.destroy();G.eselectgridG();G.emenufillG('layout');}); } else { a.vizMe('hide',function(){a.destroy();G.eselectG();G.emenufillG();}); } break;
case 'move': case 'indent': if(v.subtype == 'section'){ j = v.parent.getChildren('div.tt_esection');mm(a,j,c); } else if(v.subtype == 'grid'){ j = v.parent.getChildren('div.tt_egrid');mm(a,j,c); } else { fq = v.parent.getParent('.section.editablesection') || v.parent.getParent('.wrappergrid') || v.parent;j = fq.getElements('*[class^=edit]:not(.edittextemail):not(.edittextlink):not(.editlinkinline):not(.tt_forced)');
if(b == 'indent'){
g = ( a.getProperty('class').test(/\b(width[0-9]+)\b/) )?RegExp.$1:'width25';
if( a.hasClass('tt_forced') ){ p = a.getPrevious('div[class*=tt_forceparent]');if(p){p.unclassMe('tt_forceparentleft tt_forceparentright '+g);a.removeClass('tt_forced');} } else { 
a.addClass(g);p = a.getPrevious('div[class*=edittext]');if(p){p.addClass('tt_forceparentright').addClass(g);a.addClass('tt_forced'); }
 
}} else { mm(a,j,c); }}a.scrollMe(); break;
case 'size': j = a.get('class');if(j && j.test(/inlineimage([0-9]+)/) ){ w = RegExp.$1;y = E.eimgnew[ E.eimgnew.goAr(E.eimgnew.indexOf(w)) ];a.removeClass('inlineimage'+w);if(y != '100'){a.addClass('inlineimage'+y);} } else {a.addClass('inlineimage'+E.eimgnew[0]);} break;
case 'align': p = a.getPrevious('div[class*=tt_forceparent]');if(p){ if(p.hasClass('tt_forceparentleft')){p.removeClass('tt_forceparentleft').addClass('tt_forceparentright');} else {p.removeClass('tt_forceparentright').addClass('tt_forceparentleft');} } else { if( a.hasClass('alignleft') ){ a.removeClass('alignleft').addClass('alignright'); } else { a.removeClass('alignright').addClass('alignleft'); } } break;
case 'height': if(v.subtype == 'editimage' && n){ ff('imgheight',n); } break;
case 'padding-left': case 'padding-right': case 'padding-top': case 'padding-bottom': case 'width': ff(b,a); break;
}
}
G.esaveableG(1,a);
},

eimagelinkG: function(a){
var h,q = [ E.ebar.getElement('.tt_menu5 .nav-exit'),E.ebar.getElement('.tt_menu5 .nav-update') ],t = a.getElement('.text');h = t.getElement('a.editimagelink');
console.log('imagelink: ',t,h);
if(!h){ t.empty();h = new Element('a',{'class':'editimagelink','href':'href_placeholder','title':'view page','html':'&#160;'}).inject(t); }
G.emenuswitchG(E.eloutput,3,{ 'el':h,'url':h.getProperty('href'),'text':h.get('text'),'title':(h.getProperty('title') || ''),'target':( (h.getProperty('target') || h.hasClass('blank'))?1:0 ),'type':'editimagelink','update':q }); 
},

eblocknavG: function(e,b){ 
G.stopG(e);var h,m,n,s,s1,t = $(e.target),w;if( t && !t.hasClass('submitted') ){
h = t.get('class');s = ( t.hasClass('scriptblock') )?14:( t.hasClass('formblock') )?12:(t.getParent('.edittext') && t.getParent('.edittext').getElement('div.text > table') )?8:( t.getParent('.edittext') || t.getParent('.edittitle') )?2:( t.getParent('.editimage') )?5:( t.getParent('.editmodule') )?8:0;
//
console.log('navblock: ',e.type,' = ',e,',= b:',b,'t:',t,' h:',h,' s:',s );


if( h.test('nav-parent') ){ G.emenuswitchG(E.eloutput,8,null,null,null,'parent'); } else
if( h.test('nav-open') ){ s = t.getParent('.navarea');if(s){s = s.getElement('.editgrid.accordion');if(s){if(t.hasClass('unopen')){ t.removeClass('unopen');s.retrieve('ACC').display(0); } else { t.addClass('unopen');s.getElements('.togr,.toge').each(function(z,i){ if(z.hasClass('togr')){z.addClass('accon');} else {z.setStyles({'height':'auto','opacity':1});} }); }} } } else
if( h.test(/nav-(view|layout|section)/) ){ 
s = RegExp.$1;
if( t.hasClass('un'+s) ){
if(s == 'view'){
$('body0').unclassMe('tt_editviewoff tt_editlayouton tt_editsectionon').addClass('tt_editlayoutoff').addClass('tt_editsectionoff');G.emenuswitchG(E.eloutput,0);t = E.ebar.getElement('.tt_menu0');t.getElement('b.nav-view').removeClass('unview');t.getElement('b.nav-layout').addClass('unlayout');t.getElement('b.nav-section').addClass('unsection');G.eselectG();
} else if(s == 'layout'){
$('body0').unclassMe('tt_editlayoutoff  tt_editsectionon').addClass('tt_editviewoff').addClass('tt_editlayouton').addClass('tt_editsectionoff');G.emenuswitchG(E.eloutput,17);t = E.ebar.getElement('.tt_menu17');t.getElement('b.nav-view').addClass('unview');t.getElement('b.nav-layout').removeClass('unlayout');t.getElement('b.nav-section').addClass('unsection');G.eselectgridG();} else {$('body0').removeClass('tt_editlayouton tt_editsectionoff').addClass('tt_editviewoff').addClass('tt_editlayoutoff').addClass('tt_editsectionon');G.emenuswitchG(E.eloutput,19);t = E.ebar.getElement('.tt_menu19');t.getElement('b.nav-view').addClass('unview');t.getElement('b.nav-layout').addClass('unlayout');t.getElement('b.nav-section').removeClass('unsection');G.eselectsectionG();}
} else {
$('body0').unclassMe('tt_editlayouton tt_editsectionon').addClass('tt_editviewoff');if(s == 'view'){$('body0').unclassMe('tt_editlayoutoff tt_editsectionoff');t.addClass('unview');G.emenuswitchG(E.eloutput,0);} else {$('body0').addClass('tt_editlayoutoff').addClass('tt_editsectionoff');if(s == 'layout'){t.addClass('unlayout');G.eselectgridG();} else {t.addClass('unsection');G.eselectsectionG();}
}
}
} else {

if( h.test('nav-reorder') ){ s = t.hasClass('navup')?'up':'down';if( !t.hasClass('unreorder') ){ if( t.hasClass('fieldblock') ){G.eformG(t,'move',s);} else {G.earrangeG(E.eloutput,'move',s);} } } else
if( h.test(/nav-(align|change|format)/) ){ G.earrangeG(E.eloutput,RegExp.$1); } else
if( h.test(/nav-(un)*indent/) ){ G.earrangeG(E.eloutput,'indent'); } else
if( h.test('nav-delete') ){ if(!t.hasClass('undelete') ){ if( t.hasClass('fieldblock') ){G.eformG(t,'delete');} else {G.earrangeG(E.eloutput,'delete');} } } else
if( h.test('nav-textadd') ){ if( t.hasClass('fieldblock') ){G.eformG(t,'add');} else {G.earrangeG(E.eloutput,'add');} } else
if( h.test('nav-edit') ){ if( t.hasClass('fieldblock') ){G.eformG(t,'edit');} else if( t.getParent('.tt_menu1') ){G.emenuswitchG(E.eloutput,2);} else if( t.getParent('.tt_menu4') ){G.emenuswitchG(E.eloutput,5);} else if( t.getParent('.tt_menu6') ){G.emenuswitchG(E.eloutput,5);} else if( t.getParent('.tt_menu7') ){G.emenuswitchG(E.eloutput,8);} else if( t.getParent('.tt_menu11') ){G.emenuswitchG(E.eloutput,12);} else if( t.getParent('.tt_menu17') ){G.emenuswitchG(E.eloutput,18);} else if( t.getParent('.tt_menu19') ){G.emenuswitchG(E.eloutput,20);} else { if(s > 0){G.emenuswitchG(E.eloutput,s);} } } else

if( h.test('nav-table') ){ G.edittableG(E.eloutput); } else

if( h.test('nav-imagelink') ){ G.eimagelinkG(E.eloutput); } else

if( h.test('nav-textlink') ){ G.editchangeG(E.eloutput.getElement('.tt_hasmedium'),'link'); } else
if( h.test('nav-textformat') ){ G.editchangeG(E.eloutput.getElement('.tt_hasmedium'),'format'); } else
if( h.test('nav-textitalic') ){ G.editchangeG(E.eloutput.getElement('.tt_hasmedium'),'italic'); } else
if( h.test('nav-textbold') ){ G.editchangeG(E.eloutput.getElement('.tt_hasmedium'),'bold'); } else

if( h.test('nav-exit') && !t.hasClass('unrevert') && !t.hasClass('linkeditor') ){ if( t.hasClass('textpaste') ){ G.editcloseG('pasteexit'); } else if( t.hasClass('editor') ){ G.editrevertG('.tt_hasmedium'); } else { window.location.reload(); } } else
if( h.test('nav-update') && !t.hasClass('unsave') && !t.hasClass('linkeditor') ){ if( t.hasClass('textpaste') ){ E.eloutput.getElement('.tt_hasmedium').fireEvent('pastetext'); } else if( t.hasClass('editor') ){ G.edithideG('.tt_hasmedium','save');G.emenuswitchG(E.eloutput,1); } else { if(E.eloutput && E.eloutput.hasClass('tt_egrid')){G.eunhiliteG('layout',null,'save');}G.epagesaveG(t); } } else
if( h.test('nav-convert') ){ G.emenuswitchG(E.eloutput,16,null,null,null,'type'); } else
if( h.test(/nav-(cut|paste)/) && !t.hasClass('unpaste') ){ G.emenuswitchG(E.eloutput,21,null,null,null,RegExp.$1); } else
if( h.test('nav-alterlink') ){ G.emenuswitchG(E.eloutput,3,t); } else
if( h.test('nav-upload') ){ G.emenuswitchG(E.eloutput,6,t); } else
if( h.test('nav-revert') && !t.hasClass('unrevert') ){ G.emenuswitchG(E.eloutput,9); } else
if( h.test('nav-save') && !t.hasClass('unsave') ){ G.emenuswitchG(E.eloutput,10); } else
if( h.test(/nav-(sectionshift|gridshift|shift)/) ){ G.emenuiconG(E.eloutput,RegExp.$1); } else
if( h.test('nav-gridback') ){ G.eunhiliteG('layout',E.eloutput); } else
if( h.test('nav-back') ){ G.emenuiconG(E.eloutput); } else

if( h.test(/nav-(size|margin|padding-left|padding-right|padding-top|padding-bottom|align|width|height)/) ){ G.earrangeG(E.eloutput,RegExp.$1); } else

if( h.test('nav-menuback') ){ 
if( h.test('clipeditor') ){ n = ($('body0').hasClass('tt_editviewon'))?'view':($('body0').hasClass('tt_editlayouton'))?'layout':'section';m = (n == 'view')?1:(n == 'layout')?18:20;G.emenuswitchG(E.eloutput,m,null,'close',E.lastscroll); } else 
if( t.getParent('.tt_menu13') || t.getParent('.tt_menu11') || t.getParent('.tt_menu7') || t.getParent('.tt_menu4') || t.getParent('.tt_menu1') || s > 0 ){ G.emenuiconG(E.eloutput,'hide');G.emenufillG(); } else
if( t.getParent('.tt_menu2') || t.getParent('.tt_e1paste') || t.getParent('.tt_menu10') || t.getParent('.tt_menu9') || t.getParent('.tt_menu8') ){ G.emenuswitchG(E.eloutput,1); } else 
if( t.getParent('.tt_menu3') ){ G.emenuswitchG(E.eloutput,2,null,'close',E.lastscroll); } else 
if( t.getParent('.tt_menu5') ){ G.emenuswitchG(E.eloutput,4); } else 
if( t.getParent('.tt_menu6') ){ G.emenuswitchG(E.eloutput,5); } else 
if( t.getParent('.tt_menu12') ){ G.emenuswitchG(E.eloutput,11); } else 
if( t.getParent('.tt_menu14') ){ G.emenuswitchG(E.eloutput,13); } else 
if( t.getParent('.tt_menu15') ){ G.emenuswitchG(E.eloutput,12,null,'close',E.lastscroll); } else
if( t.getParent('.tt_menu16') ){ G.emenuswitchG(E.eloutput,b,null,'close',E.lastscroll); } else
if( t.getParent('.tt_menu18') ){ G.eunhiliteG('layout'); } else 
if( t.getParent('.tt_menu20') ){ G.eunhiliteG('section'); } 
} else {
console.log('eblocknav: ',e,b,h);
}

}
}},

editchangeG: function(a,b){
var ca = rangy.modules.ClassApplier,h,l,m,n,p,q,r,s,t,v,w = 0,y = {};
m = a.retrieve('hasmedium');
p = a.getNext('.text');
if(m && p){ 
t = m['target'];
q = m['q'];
console.log('changeedit: ',a,' = ',b,' q:',q,' t:',t,' p:',p,' m:',m);
if(q && t){
switch(b){
case 'link': 
if( t.get('class').test(/edit(textlink|textemail|linkinline)/) ){ 
y = { 'el':t,'url':t.getProperty('href'),'text':t.get('text'),'title':t.getProperty('title'),'target':( (t.hasClass('blank') || t.getProperty('target'))?1:0 ),'type':v,'update':[].combine(q['save']).combine(q['revert']) };v = 'edit'+RegExp.$1;G.emenuswitchG(E.eloutput,3,y); 
} else {
r = rangy.getSelection();r.removeAllRanges();s = rangy.createRange();s.selectNode(t);r.setSingleRange(s);console.log('rangy: ',t,' = ',r);
y = { 'el':t,'url':'href_placeholder.html','text':t.get('text'),'title':'view page','target':0,'type':'editlinkinline','update':[].combine(q['save']).combine(q['revert']) };
if(ca && r){ n = rangy.createCssClassApplier('editlinkinline',{ elementTagName:'a',elementProperties:{'href':'href_placeholder.html','title':'view page'},applyToEditableOnly:true,onElementCreate:function(t){G.emenuswitchG(E.eloutput,3,y); } });n.toggleSelection();h = 1; } else { console.log('nothing selected ',r); } 
}
break;
case 'format': if( t.get('class').test(/format([0-9]+)/) ){ w = RegExp.$1.toInt();t.removeClass('format'+w);$$(q['convert']).removeClass('textheader'+w);if(w < 8){ t.addClass('format'+(w+1));$$(q['convert']).addClass('textheader'+(w+1)); } else { t.removeClass('textheader8'); } } else { t.addClass('format0');$$(q['convert']).addClass('textheader0'); }h = 1; break;
case 'italic': t.toggleClass('italictext');h = 1; break;
case 'bold': t.toggleClass('boldtext');h = 1; break;
}
}

}
if(h){ $$(q['revert']).removeClass('unrevert');$$(q['save']).removeClass('unsave'); }
},

editcleanG: function(a,b,c,d){ 
var f,h,i,r,p,s,w,x,y;
if(b){ w = a.getElements('a');console.log('check a ',w);for(i=0;i<w.length;i++){ if(w[i].get('html') == ""){ w[i].destroy(); } else { if( w[i].get('html').test(/^<br( \/)*>$/) ){new Element('br').replaces(w[i]);} } } }
if(c){ x = a.getElements('span');console.log('check span',x);for(i=0;i<x.length;i++){ p = G.editparentG(x[i],'div');if( x[i].getChildren('a') ){f = x[i].getChildren('a')[0];}if(f){ ['textbold','textitalic','format'].each(function(z1,i1){ if( x[i].hasClass(z1) ){ f.addClass(z1); } });console.log('replace ',x[i],' with ',f,' in ',p);f.replaces(x[i]); } else if( x[i].getProperty('class') && x[i].getProperty('class').test(/(boldtext|italictext|format)/) ){ x[i].removeClass('editselection'); } else { G.erangyG(x[i],'replace'); } } }
if(d){ y = a.getElements('p');console.log('check p ',y);for(i=0;i<y.length;i++){ if(y[i].get('html') == ""){ y[i].destroy(); } } }
},

editcloseG: function(a){ var d;if(a){ G.emenuswitchG(E.eloutput,1);$('pastetextarea').destroy(); } else { G.edithideG('.tt_hasmedium');if( $('pastemenu') ){$('pastemenu').vizMe('hide',function(){ $$('.tt_ce-left,.tt_ce-right,.tt_ce-bottom').destroy();if( $('pastemenu') ){$('pastemenu').destroy();} });} } },

editscriptG: function(a,b,c){
var f = b.getElement('.scriptblock'),jj,kk,nc = Object.merge({},c),q = [ E.ebar.getElement('.tt_menu14 .nav-exit'),E.ebar.getElement('.tt_menu14 .nav-update') ],tt;console.log('editscript ',a,b,c,' f:',f,nc,q);if(f){
tt = function(te){ var ta,tl,tv;if(te && te.target){ G.stopG(te);ta = $(te.target);tv = ta.get('value');if( tv != c['original'] ){ nc['altered'] = tv;G.eadjustsaveG(q); } else { delete nc['altered'];G.eadjustsaveG(q,2); }ta.growMe(); } };
kk = function(ka){ a.getElements('div.scriptgrid').destroy();var ks,kt,ku = new Element('div',{'class':'scriptgrid tt_undisplay'}).inject(a);
kt = new Element('textarea',{ 'id':'tt_scripteditor','class':'scriptconfig','placeholder':'Add external Script here:','html':c['original'] }).attachMe({'input':tt,'keyup':tt}).inject(ku);
ks = new Element('h3',{'class':'expand','text':'scroll'}).inject(kt,'before').touchMe(null,null,function(ze){ var zm;if( ze && kt ){ zm = $(ze.target);if(zm.get('text') == 'scroll'){kt.growMe('scroll');zm.set('text','expand');} else {kt.growMe();zm.set('text','scroll');} } });
ku.vizMe();
kt.growMe(); 
};
jj = function(je){ G.stopG(je);var jt = je.target,ju = $('tt_scripteditor').get('value');if( jt.hasClass('nav-exit') && !jt.hasClass('unrevert') ){ G.emenuswitchG(E.eloutput,13); } else { if( !jt.hasClass('unsave') ){ E.eloutput.getElement('div.scriptblock').set('html',nc['altered']);if( c['original'] == '' ){ nc['original'] = nc['altered'];delete nc['altered']; }E.eloutput.dataMe(nc);console.log('editscript save = ',b,' target is ',E.eloutput.getElement('div.scriptblock'),' nc:',nc,' replaces ',E.eloutput.retrieve('editdata'));G.esaveableG(1,E.eloutput);G.emenuswitchG(E.eloutput,13); } }};
kk(f);
$$(q).touchMe(null,null,jj);
}},


edittableG: function(a){ var c,d,m,n,r,s,t;d = a.getElement('.text');if(d){t = (d.getElement('table'))?'table':'text';if(t == 'text'){ m = new Element('table',{}).inject(d);n = new Element('tbody',{}).inject(m);d.getElements('p').each(function(z,i){ h = z.getProperty('class') || '';r = new Element('tr',{'class':h}).inject(n);c = new Element('td',{'html':z.get('html')}).inject(r);z.vizMe('hide',function(){z.destroy();}); }); } else { n = d.getElement('table');if(n){ n.getElements('tr').each(function(z,i){ h = z.getProperty('class');s = '';r = new Element('p',{'class':h});z.getElements('td').each(function(z1,i1){ s+= z1.get('html');});r.setProperty('html',s).inject(d);  }); } n.vizMe('hide',function(){n.destroy();}); }a.dataMe();} },

editinputG: function(a,b){
var kd,kf,kg,kh,kj = '',kp = [],kw,ky,i,ks = [];
console.log('input: a:',a,' b:',b);
if(a){
kf = new Element('ul',{'class':'ful','html':'<li class="fli formtitle">Edit '+( (b.detailtype.test(/manifest/i))?'Hidden Spam':(b.detailtype.test(/spam/i))?'Spam Question':b.detailtype.ucStr() )+( (b.detailtype.test(/(manifest|text)/i))?' Field':(b.detailtype.test(/(radio|submit)/i))?' Button':'' )+':</li>'});ks.push(kf);
kp = [ (a[0].get('name'))?a[0].get('name').replace(/^(opt|pre)_/,'').replace(/_([0-9]+)$/,''):'Field Name',(b.labels[0])?b.labels[0].get('text').replace(/\*/g,''):'Label Text' ];
switch(b.detailtype){ 
case 'formtext':
kf.adopt( new Element('li',{'class':'fli formtitle formstyle','html':'<p class="'+((b.formstyle)?b.formstyle:'')+'">'+(b.text || 'Default Text')+'</p>'}) );
kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<label class="labelhidden" for="tt_formtext">Text:</label><input value="'+(b.text || 'Default Text')+'" class="formhidden" name="pre_formtext" id="tt_formtext" type="text" />'}) );
for(i=0;i<E.etextformat.length;i++){ kj+= '<option class="format'+i+'" value="format'+i+'"'+((b.formstyle && b.formstyle == 'format'+i)?' selected':'')+'>Format '+i+'</option>'; }
kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<label class="labelhidden" for="tt_formstyle">Style:</label><select id="tt_formstyle" name="pre_formstyle"><option class="formtext" value="default"'+((b.formstyle)?'':' selected')+'>Normal</option>'+kj+'</select>'}) );
break;
case 'text': case 'textarea':
kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<label class="labelhidden" for="tt_labellink_0">Label Text:</label><input value="'+kp[1]+'" class="formhidden" name="pre_labellink_0" id="tt_labellink_0" type="text" />'}) );
kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<label class="labelhidden" for="tt_namelink_0">Field Name:</label><input value="'+kp[0]+'" class="formhidden" name="pre_namelink_0" id="tt_namelink_0" type="text" />'}) );
kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<label class="labelhidden" for="tt_valuelink_0">Field Value:</label><input value="'+( a[0].get('value') || '' )+'" class="formhidden" name="opt_valuelink_0" id="tt_valuelink_0" type="text" />'}) );
kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<label class="labelhidden" for="tt_placeholder_0">Placeholder:</label><input value="'+( b.placeholder || '' )+'" class="formhidden" name="pre_placeholder_0" id="tt_placeholder_0" type="text" />'}) );
break;
case 'radio': case 'select':
kh = 'Radio';
if(b.detailtype == 'select'){ kh = 'Option';kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<label class="labelhidden" for="tt_labellink_0">Label Text:</label><input value="'+kp[1]+'" class="formhidden" name="pre_labellink_0" id="tt_labellink_0" type="text" />'}) ); }
kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<label class="labelhidden" for="tt_namelink_0">Field Name:</label><input value="'+kp[0]+'" class="formhidden" name="pre_namelink_0" id="tt_namelink_0" type="text" />'}) );
ky = (b.labels.length < 2)?['','']:[' undelete',' unreorder'];
kg = new Element('li',{'class':'fli fieldwrapper'}).inject(kf);
kw = new Element('ul',{'class':'ful fieldblock'}).inject(kg);
kd = (a[0].options)?a[0].options:(a[0].elements)?a[0].elements:a;
for(i=0;i<kd.length;i++){ new Element('li',{'class':'fli fieldblock','html':
'<div class="inputline"><label class="labelhidden" for="tt_optionlabel_'+i+'">'+kh+' Text:</label><input id="tt_optionlabel_'+i+'" name="optionlabel_'+i+'" type="text" value="'+( (kh == 'Radio' && b.labels)?b.labels[i].get('text'):kd[i].get('text') )+'" /></div>'+
'<div class="inputline"><label class="labelhidden" for="tt_optionvalue_'+i+'">'+kh+' Value:</label><input id="tt_optionvalue_'+i+'" name="optionvalue_'+i+'" type="text" value="'+(kd[i].get('value') || '')+'" /></div>'+
'<div class="inputline"><input id="tt_selected_yes_'+i+'" type="radio" class="css-check" value="1" name="tt_selected"'+((b.selected && i == b.selected)?' checked':'')+' /><label class="l-radio css-check" for="tt_selected_yes_'+i+'">Selected:</label></div>'
}).inject(kw); }
break;
case 'checkbox': case 'manifest':
kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<label class="labelhidden" for="tt_labellink_0">Label Text:</label><input value="'+kp[1]+'" class="formhidden" name="pre_labellink_0" id="tt_labellink_0" type="text" />'}) );
kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<label class="labelhidden" for="tt_namelink_0">Field Name:</label><input value="'+kp[0]+'" class="formhidden" name="pre_namelink_0" id="tt_namelink_0" type="text" />'}) );
if(b.detailtype === 'checkbox'){
kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<label class="labelhidden" for="tt_valuelink_0">Field Value:</label><input value="'+( a[0].get('value') || '' )+'" class="formhidden" name="opt_valuelink_0" id="tt_valuelink_0" type="text" />'}) );
kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<input id="tt_selected_yes_0" class="css-check" type="checkbox" value="1" name="opt_tt_selected"'+((b.selected)?' checked':'')+' /><label class="l-checkbox css-check" for="tt_selected_yes_0">Checked:</label>'}) );
}
break;
case 'spam':
kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<label class="labelhidden" for="tt_labellink_0">Question Text:</label><input value="'+kp[1]+'" class="formhidden" name="pre_labellink_0" id="tt_labellink_0" type="text" />'}) );
kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<label class="labelhidden" for="tt_valuelink_0">Question Answer:</label><input value="'+( b.spam || '0' )+'" class="formhidden" name="opt_valuelink_0" id="tt_valuelink_0" type="text" />'}) );
break;
case 'submit':
kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<label class="labelhidden" for="tt_valuelink_0">Button Text:</label><input id="tt_valuelink_0" name="pre_valuelink_0" type="text" value="'+(a[0].get('value') || 'Send')+'" />'}) );
break;
}
if( !b.detailtype.test(/(spam|manifest|submit)/i) ){ 
kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<input id="tt_required" class="css-check" type="checkbox" value="required" name="opt_required"'+((b.required)?' checked':'')+' /><label class="l-checkbox css-check" for="tt_required">'+( (b.detailtype.test(/(formtext)/i))?'Add Required Label':'Required' )+':</label>' }) ); 
kf.adopt( new Element('li',{'class':'fli inputline formglobal','html':'<label class="labelhidden" for="tt_typelink">Change Type:</label><select id="tt_typelink" class="formhidden" name="opt_typelink_0"><option value="formtext"'+((b.detailtype == 'formtext')?' selected':'')+'>Form Header</option><option value="text"'+((b.detailtype == 'text')?' selected':'')+'>Text Input</option><option value="textarea"'+((b.detailtype == 'textarea')?' selected':'')+'>Textarea</option><option value="select"'+((b.detailtype == 'select')?' selected':'')+'>Dropdown</option><option value="checkbox"'+((b.detailtype == 'checkbox')?' selected':'')+'>Checkbox</option><option value="radio"'+((b.detailtype == 'radio')?' selected':'')+'>Radio Input</option></select>'}) ); 
}
}

return ks;
},


////////////////////////////////////
//{ parent:<ul.area.editablearea.swiperarea>,parenttype:"swiper",type:"editimage",subtype:"editimage",parentconfig:Object,original:"url(documents/Images/elements/Breakglass-logo-79h.png)",odim:Object }

editareaG: function(a,b,c,d,e,f,g){
var c1 = {},cc,ff,f,g1,i,jj,kk,m = e,mm,p = (e.parentconfig)?e.parenttype:(c)?c.tag:e.subtype,pp,q = [ b.getElement('.nav-exit'),b.getElement('.nav-update'),b.getElement('.nav-menuback') ],qq,rr,u = '',uu,w,xx = {},yy;
if(c && !c.update){c.update = q;}
console.log('editarea: a:',a,' b:',b,' c:',c,' d:',d,' e:',e,' f:',f,' p:',p,' = m:',m,' q:',q); 

cc = function(ca){
var cd,cf,ch,cj,cm = {},cp,co = [],cq,cs = '',cu,cv,cw,cx,cy,cz,i;
console.log('cc = a:',a,' ca:',ca,' p:',p);
switch(a){
case 'editclipboard': 
var ccc,cch,ccs = G.cacheG(),ccu;i = 0;if( E.eclips[p] ){ Object.each(E.eclips[p],function(v,k){ var ci = new Element('li',{'class':'fli fclip','data-clipname':v[0],'html':v[1] });
co.push( new Element('ul',{'class':'ful'}).adopt(ci) );
new Element('label',{'for':'tt_titlecheck_'+i}).inject(ci,'top');
new Element('input',{'type':'checkbox','id':'tt_titlecheck_'+i,'name':'opt_titlecheck_'+i,'value':''}).inject(ci,'top');
new Element('div',{'class':'clipdata','html':v[0]}).inject(ci,'top');
i++; }); }
if(g == 'cut'){ 
ccc = E.eloutput.cloneidMe(ccs);ccc.unuiMe();console.log('unui = ',ccc);
ccu = new Element('ul',{'class':'ful'});
cch = new Element('article',{'id':p+'_'+ccs,'class':'clipboard-'+p,'data-clipname':'New Clipboard Item'}).adopt(ccc);
new Element('li',{'class':'fli fclip','data-clipname':'New Clipboard Item'}).store('original','New Clipboard Item').inject(ccu).adopt( 
new Element('div',{'class':'clipdata','html':'<label for="tt_titlelink0">Edit Name:</label><input id="tt_titlelink0" name="pre_titlelink_0" type="text" value="New Clipboard Item" />'}),
new Element('input',{'type':'checkbox','id':'tt_titlecheck_0','name':'opt_titlecheck_0','value':''}),
new Element('label',{'for':'tt_titlecheck_0'}),cch );
console.log(p,' = ',E.eclips[p],' c:',ccc,' u:',ccu);
co.push(ccu); }
return co;
break;
case 'edittype':
Object.each(E.edittypes.blocks,function(v,k){ ch = new Element('ul',{'class':'ful'});new Element('li',{'class':'fli '+( (k == 'editmodule')?'fsection ':'' )+'ftitle fmain'+( (k != 'editmodule' && k == e.type)?' fselected':''),'html':v.name }).store('editdata',{name:k,html:v.html}).inject(ch);
if( k == 'editmodule' ){ Object.each(v.config,function(v1,k1){ cj = E.cfg['MODULES'][k1] || v1.html || '';new Element('li',{'class':'fli ftitle '+( (k1 == 'form')?'':' fmod' )+( (k1 != 'editmodule' && k1 == e.subtype)?' fselected':''),'html':v1.name }).store('editdata',{name:k1,html:cj,config:v1.config}).inject(ch); }); }co.push(ch); });return co;
break;
case 'editfeed': case 'editinput': case 'edittable':
if( p == 'table'){

g1 = d.getElements('table');
if(g1 && g1[0]){
cf = g1[0].getElement('thead');ck = g1[0].getElement('tbody');cg = g1[0].getElement('tfoot');n = { 'header':((cf && cf.getElement('tr > td'))?cf.getElement('tr > td').get('html'):'' ),'columns':((ck && ck.rows)?ck.rows[0].cells.length:1),'footer':((cg && cg.getElement('tr > td'))?cg.getElement('tr > td').get('html'):'' ),'update':q };cj = (c)?Object.merge(c,n):n;
console.log('edittext ',d,' has table ',g1[0],' = ',n);
cq = new Element('ul',{'class':'ful','html':'<li class="fli inputline formglobal"><label class="labelhidden" for="header_edit">Table Header</label><textarea class="formhidden" name="pre_header" id="header_edit">'+n.header+'</textarea></li><li class="fli inputline formglobal"><label class="labelhidden" for="columns_edit">Table Columns</label><input value="'+n.columns+'" class="formhidden" name="pre_columns" id="columns_edit" type="text"></li><li class="fli inputline formglobal"><label class="labelhidden" for="footer_edit">Table Footer</label><textarea class="formhidden" name="pre_footer" id="footer_edit">'+n.footer+'</textarea></li>'});
cd = new Element('ul',{'class':'ful tableblock'});
ck.getChildren('tr').each(function(z,i){
cw = new Element('li',{'class':'fli inputline','data-row':i}).inject(cd);
z.getElements('td').each(function(z1,i1){ cx = new Element('input',{'name':'opt_td'+i+'-'+i1,'id':'td'+i+'-'+i1,'data-column':i+'-'+i1,'value':z1.get('html')}).inject(cw); });
});
cd.store('tabledata',cj);
}
return [ cq,cd ];

} else if( p.test(/^(form|input|textarea|select|p)$/i) ){

if(p == 'form'){
g1 = d.getElement('form');n = { 'action':g1.getProperty('action'),'id':g1.get('id'),'method':g1.getProperty('method'),'number':g1.get('id').replace(/^cgi_form_/,'').toInt(),'response':null,'update':q };c = (c)?Object.merge(c,n):n;
if( $('tt_returndiv_'+c.number) && $('tt_returndiv_'+c.number).getStyle('display') != 'none' ){ c.response = $('tt_returndiv_'+c.number); }
cd = E.edittypes.blocks.editmodule.config.form.config;
cd.formtype[3] = E.cfg['SUBJECTS'] || {};
cd.recipients[3] = E.cfg['RECEIVERS'] || {};
g1.getElement('fieldset').getChildren('ul').each(function(z,i){ cz = z.cloneidMe(c.number);cz.getElements('ul.globalform').destroy();co.push(cz);
cz.getElements('p,input,textarea,select').each(function(z1,i1){ if( z1.get('name') ){cv = z1.get('name').replace(/^(opt|pre)_/,'').replace(/_([0-9]+)$/,'');xx[ cv.toLowerCase() ] = 1;}
if(z1.get('tag') != 'p' && z1.getProperty('type') == 'hidden'){cm[cv] = z1.getProperty('value');z1.destroy();} }); },this);
Object.each(cd,function(v,k){
cw = new Element('li',{'class':'fli inputline formconfig'}).inject(cz);
cp = 'before';
xx[ k.toLowerCase() ] = 1;
cx = new Element(v[0],v[1]).inject(cw).setProperties({'name':'opt_'+k,'id':k+'_edit'}).addClass('formhidden');
if( v[3] ){
cs = '';Object.keys(v[3]).sort().each(function(z,i){ cs+= '<option value="'+z+'"'+( (cm[k] && z == cm[k])?' selected':'' )+'>'+z+'</option>' });if(cs == ''){cs = '<option value="">none defined</option>';}cx.set('html',cs);
} else if( v[1] && v[1]['type'] && v[1]['type'] == 'checkbox' ){
if( cm[k] ){cx.setProperty('checked',true);}cp = 'after';
} else {cx.setProperty('value',cm[k]);}
cy = new Element('label',{ 'class':'labelhidden'+( (cp == 'after')?' css-check':'' ),'html':v[2],'for':k+'_edit' }).inject(cx,cp);
});
co.unshift( new Element('ul',{'class':'ful','html':'<li class="fli inputline formglobal"><label class="labelhidden" for="action_edit">Form Action:</label><input value="'+(c.action || E.url.cgi || "")+'" class="formhidden" name="pre_action" id="action_edit" type="text" /></li>\n<li class="fli inputline formglobal"><label class="labelhidden" for="method_edit">Form Method:</label><input value="'+c.method+'" class="formhidden" name="pre_method" id="method_edit" type="text" /></li></ul>'}) );
} else {
co = G.editinputG(ca.elements,ca);
}
return co;

} else { 

if( E.eloutput.getElement('.text') && E.eloutput.getElement('.text').getElement('a') ){ //if(p == 'view' || p == 'library'){ cd = E.eloutput.getElement('.text'); } ////////if(e.parentconfig){  } else { cd = E.eloutput.getElement('.text'); }
console.log('cc = a:',a,' parentconfig:',e.parentconfig,' cd:',cd);
cd = E.eloutput.getElement('.text');
cp = cd.getElement('a');
cj = (p == 'view' || p == 'library')?cp.attriMe():cd.attriMe();
if(cp){ cj = Object.merge(cj,{ 'href':cp.get('href'),'text':cp.get('text'),'title':cp.get('title'),'class':cp.getProperty('class'),'style':cp.get('style') });cj['style'] = cj['style'].replace(/('|")/g,''); }
//console.log('cc: a:',a,' p:',p,' m:',m,' cd:',cd,' cj:',cj);
cu = E.edittypes.blocks.editmodule.config[p] || E.edittypes.areas[p] || null;
ch = new Element('ul',{'class':'ful feeddata'});
co.push( new Element('ul',{'class':'ful','html':'<li class="fli formtitle ehilited">Edit '+cu.name+' <a class="tt_get-guide" data-modname="'+p+'" style="color:#900; clear:none; float:right;" title="show guides for this module">[ view guide ]</a></li>'}) );
if(cu.config){ Object.each(cu.config,function(v,k){ 
cq = new Element('li',{'class':'fli inputline'}).inject(ch).adopt( new Element('label',{'for':'tt_'+k+'_0','html':k+':'}) );
if( !cj[k] && cu.defaults && cu.defaults[k] ){cj[k] = cu.defaults[k];}cw = cj[k] || v; //
//console.log('IN: k:',k,' = v:',v,' cw:',cw,' isNaN:',isNaN(cw));
if( cw == '' || isNaN(cw) === true ){ 
if( v.test && v.test(/\|/) ){ cs = '';cy = v.split('|');if(cw == ''){cs+= '<option value="none">none selected</option>';}for(i=0;i<cy.length;i++){cx = (cy[i] == cw)?' selected':'';cs+= '<option'+cx+' value="'+cy[i]+'">'+( (E.esort[cy[i]])?E.esort[cy[i]]:cy[i] )+'</option>';}cz = new Element('select',{'id':'tt_'+k+'_0','name':'pre_'+k+'_0','html':cs}).inject(cq);} else {cz = new Element('textarea',{'id':'tt_'+k+'_0','name':'pre_'+k+'_0','value':cw,'data-noscroll':'on'}).inject(cq); }
} else { 
cw = Number(cw) || 0;cz = new Element('input',{'type':'text','id':'tt_'+k+'_0','name':'pre_'+k+'_0','value':cw}).inject(cq); 
}
cz.setAttribute('data-feedname',k);
}); }
if(ch){ch.store('feeddata',cj);co.push(ch);}
}

return co;
}
break;
case 'editlink':
cs+= '<ul class="ful">\n'+
'<li class="fli inputline"><input type="checkbox" id="tt_removelink" class="css-check" name="removelink" /><label id="removelinklabel" for="tt_removelink" class="deletelink css-check" >Delete Link:</label></li>\n'+
'<li class="fli inputline"><label for="tt_urllink">Edit URL:</label><input id="tt_urllink"'+( (c.url == 'href_placeholder.html')?'class="tt_inputfail"':'' )+' name="urllink" type="text" value="'+c.url+'" />'+
//<input id="used1_0" name="used1_0" type="checkbox" /><label for="used1_0" class="tt_tabclick navblock navedit nav-editlink" tabindex="0" title="select Page or Document">Select</label><div class="inputline dropsub"><div class="tt_filegrab"></div></div>'+
'</li>\n'+
'<li class="fli inputline"><label for="tt_titlelink">Edit Title:</label><input id="tt_titlelink" name="titlelink" type="text" value="'+c.title+'" /></li>\n'+( (c.el.hasClass('editimagelink'))?'':'<li class="fli inputline"><label for="tt_textlink">Edit Text:</label><input id="tt_textlink" name="textlink" type="text" value="'+c.text+'" /></li>' )+
'<li class="fli inputline"><label for="tt_targetlink">Edit Target:</label><select id="tt_targetlink" name="targetlink"><option value="0"'+((c.target == 0)?' selected':'')+'>Open in same window</option><option value="1"'+((c.target == 1)?' selected':'')+'>Open in new window</option></select></li>\n'+
( (c.el.hasClass('editimagelink'))?'':'<li class="fli inputline"'+((c.el.hasClass('edittextemail'))?' emailtype':'')+'"><label for="tt_typelink">Edit Type:</label><select id="tt_typelink" name="typelink"><option value="editlinkinline"'+((c.el.hasClass('editlinkinline'))?' selected':'')+'>Inline Link</option><option value="edittextlink"'+((c.el.hasClass('edittextlink'))?' selected':'')+'>Button Link</option><option value="edittextemail"'+((c.el.hasClass('edittextemail'))?' selected':'')+'>Email Link</option></select><b class="info">Format: mailto:name@address.domain</b></li>\n' )
cs+= '</ul>';
break;
}
return cs;
},

yy = function(ye){ var ya;if(typeOf(ye) == 'domevent' && $(ye.target) ){ ya = $(ye.target).getParent('form').getElements('li.fli.fieldblock'); } else { ya = Array.convert(ye); }$$(ya).each(function(z,i){ z.removeEvents().touchMe(null,null,ff).addEvents({ 'click:relay(b.inputblock)':function(e,el){ G.stopG(e);console.log('clicked ',el);pp(e); } });z.getElements('input').each(function(z1,i1){z1.changeMe(z1.getParent('.inputline'));}); },this); };

uu = function(ua){ if(ua){ua.getElements('.ehilited').removeClass('ehilited');ua.getElements('.ehilite').destroy();} };

rr = function(ra,rb,rc){
var rd = {};
if( !ra.hasClass('hasguides') && !ra.hasClass('noguides') ){ 
G.epullG(E.pl,null,{ 'type':'getguides','id':rb,'url':E.emodpage },function(rra,rrb){ var rh = (rrb == 'OK')?rrb:'FAILED',rs = "";if(rh == 'OK'){ rd = rra['result'];ra.getElements('li.fli > label').each(function(z,i){ var rf = z.getNext('input,select,textarea'),rv = '';if(rf){ rv = rf.getAttribute('data-feedname') || '';if(rv != '' && rd[rv]){z.getParent('li.fli').setProperty('data-getguide',rd[rv]);} } },this);if(Object.keys(rd).length > 0){ra.addClass('hasguides').addClass('addguides');} else {rc.setProperty('href',E.emodpage).setProperty('target','_blank');ra.addClass('noguides');} } });
} else {
if( ra.hasClass('addguides') ){ ra.removeClass('addguides'); } else { ra.addClass('addguides'); }
}
};

qq = function(qa){ return (qa)?qa.replace(/ /g,'-').replace(/[^a-zÀ-ÿ0-9_]/gi,'').toLowerCase():''; };

pp = function(pe){ 
var pc = pe.alt,pi,pl,pm,pt,pw;G.stopG(pe);pt = $(pe.target);if(pt){ pl = pt.getParent('li.fieldblock');pm = b.getElements('li.fieldblock');
if( pt.hasClass('nav-add') ){ pw = pl.cloneidMe(pm.length);pw.inject(pl,'before');pw.getElements('b.navblock').touchMe(null,null,pp);
if(b.getElements('li.fieldblock').length > 1){b.getElements('.nav-delete').removeClass('undelete');b.getElements('.nav-reorder').removeClass('unreorder');}pl.scrollMe();} else 
if( pt.hasClass('nav-delete') ){ if( !pt.hasClass('undelete') ){ pl.vizMe('hide',function(){ pl.destroy();pm = b.getElements('li.fieldblock');if(pm.length < 2){b.getElements('.nav-delete').addClass('undelete');b.getElements('.nav-reorder').addClass('unreorder');} }); } } else { if( !pl.hasClass('unreorder') ){ if(pc){pi = pm.goAr(pl,1);pw = (pi >= pm.length-1)?'after':'before';} else {pi = pm.goAr(pl);pw = (pi < 1)?'before':'after';}pl.inject(pm[pi],pw); } }
G.eadjustsaveG(q);pl.scrollMe();}
};

ff = function(fe){
console.log('fire ff ',fe);
var i,fa,fc = [],fd,fg,fi = [],fl,fm,fn = { dupes:null,elements:[],formstyle:'default',func:null,labels:[],detailname:(c && c.detailname)?c.detailname:'',number:(c && c.number || 0),detailparent:null,placeholder:null,required:null,selected:null,spam:null,tag:null,text:null,detailtype:'',value:null },fp,fq,fr,fs,ft,fu,fv = {},fx,fy;
fm = function(){ fi = $$(b.getElements('.tt_inputfail'));if(typeof(fi[0]) === 'undefined'){ fi = $$(b.getElements('.tt_changed'));if(typeof(fi[0]) === 'undefined'){G.eadjustsaveG(q,2);} else {G.eadjustsaveG(q);} } else { G.eadjustsaveG(q,1); } };
if(fe){ 
if(typeOf(fe) == 'domevent' && fe.target){fa = $(fe.target);} else if(typeOf(fe) == 'object' && fe.target){ fa = fe.target; } else {fa = $(fe);}
if(a != 'editinput' && p != 'table'){G.stopG(fe);}
console.log('ff = a:',a,' = ',fa,' = ',fe.target,typeOf(fe));
if(fa){ fl = (fa.hasClass('fieldblock'))?fa:(fa.getParent('.fieldblock'))?fa.getParent('.fieldblock'):( fa.hasClass('fli') )?fa:( fa.getParent('li.fli') )?fa.getParent('li.fli'):null;

switch(a){
case 'editclipboard': console.log('ff: fa:',fa,' a:',a,' b:',b,' c:',c,' g:',g,' fl:',fl,' fe:',fe);
if(g == 'paste'){
fi = fl.getParent('ul.ful').getElements('li.fclip');$$(fi).removeClass('fselected');fl.addClass('fselected');console.log('edittype ff :',fe.type,' = ',fa,' = ',fl,' overwrite ',d);G.eadjustsaveG(q);
} else {
fa.getParent('form').checkMe('li.fclip','fail');fm();
}

break;
case 'editinput':
fs = c.tag;
console.log('ff2: fs = ',fs,' fa:',fa,' a:',a,' c:',c,' formstage:',b.getElement('div.formgrid.inputgrid').retrieve('formstage'),' e:',e);
if(fa.get('id') == 'tt_formstyle'){ fn.formstyle = fa.options[fa.options.selectedIndex].value;fd = fa.getParent('ul.ful');if(fd){ $$(fd.getElements('li.formstyle > p')).each(function(z,i){ if(fn.formstyle == 'default'){z.setProperty('class','');} else {z.setProperty('class',fn.formstyle);} }); }if(c.detailparent){c.detailparent.getElements('p').each(function(z,i){ if(fn.formstyle == 'default'){z.setProperty('class','');} else {z.setProperty('class',fn.formstyle);} }); } }
if(fa.get('id') == 'tt_formtext'){ fd = fa.getParent('ul.ful');if(fd){ $$(fd.getElements('li.formstyle > p')).set('text',fa.value); } }
if(fa.get('id') == 'tt_typelink'){ //console.log('change to ',fa.options[fa.options.selectedIndex].value,' from ',c.detailtype);
fn.detailtype = fa.options[fa.options.selectedIndex].value;fn.func = yy;fn.detailparent = c.parent || c.detailparent || fl;fy = (fn.detailtype == c.detailtype)?2:1;fn.required = c.required;
if(fy > 1){ fn = Object.merge({},c); } else { 
fn.selected = 0;
if( fn.detailtype == 'select' || fn.detailtype == 'radio' ){ 
fn.elements = [ new Element('select',{'id':'tt_'+fn.detailname+'_0','name':'pre_'+fn.detailname+'_0','html':'<option value="none" selected>first option</option>'}) ];
} else if( fn.detailtype == 'textarea' ){ 
fn.elements = [ new Element('textarea',{ 'id':'tt_'+fn.detailname+'_0','name':'pre_'+fn.detailname+'_0','value':(fn.text || '') }) ];
} else { fn.elements = [ new Element('input',{ 'type':fn.detailtype,'id':'tt_'+fn.detailname+'_0','name':'pre_'+fn.detailname+'_0','value':(fn.text || '') }) ]; 
}
if( !fn['labels'] || fn['labels'].length < 1 ){ fn['labels'] = [ new Element('label',{'for':'tt_'+fn.detailname+'_0','html':'label text'}) ]; } 
}

c1 = Object.merge({},fn);b.getElement('div.formgrid.inputgrid').vizMe('hide',function(){ kk(c1);G.eadjustsaveG(q); });
} else {
console.log('here = ',fa,fl);
if( fa.get('tag').test(/(input|label)/i) ){
fi = $$(fl.getParent('ul.ful').getElements('.tt_inputfail'));if(typeof(fi[0]) === 'undefined'){ fi = $$(fl.getParent('ul.ful').getElements('.tt_changed'));if(typeof(fi[0]) === 'undefined'){G.eadjustsaveG(q,2);} else {G.eadjustsaveG(q);} } else { G.eadjustsaveG(q,1); }
} else {
if( fl.hasClass('fieldblock') ){ fp = ( !fl.hasClass('ehilited') )?1:null;uu(fa.getParent('form'));if(fp){new Element('div',{'class':'ehilite'}).inject(fl);fl.store('editdata',(b.getElement('div.formgrid.inputgrid').retrieve('formstage') || c)).addClass('ehilited');G.emenuiconG(fl);fl.scrollMe();} }
}

}
break;
case 'editfeed':
fs = e.subtype;
console.log('ff1: fs = ',fs,' fa:',fa,' a:',a,' c:',c,' e:',e,' fe:',fe);

if(fs == 'table'){

if( fl && fa.get('tag') != 'input' && fa.get('tag') != 'textarea' ){ 
fp = ( !fl.hasClass('ehilited') )?1:null;uu(fa.getParent('form'));if(fp){ new Element('div',{'class':'ehilite'}).inject(fl);fl.store('editdata',Object.merge({},e)).addClass('ehilited');G.emenuiconG(fl);fl.scrollMe(); } 
} else if( fa.getParent('ul.tableblock') ){
console.log('updating ',fa);
} else {
fq = fa.get('id');fv = fa.getProperty('value');fp = fa.getParent('.formgrid.editfeed');fu = fp.getElement('ul.tableblock');fn = Object.merge({},(fu.retrieve('tabledata') || {}) );
if( fq.test(/^header/) ){ fn.header = fv; } else if( fq.test(/^footer/) ){ fn.footer = fv; } else { if(fu){ fn.columns = fv;fu.getElements('li.fli').each(function(z,i){ fx = z.getElements('input');fy = [];for(i1=0;i1<fv;i1++){ fy.push( new Element('input',{ 'name':'opt_td'+i+'-'+i1,'id':'td'+i+'-'+i1,'data-column':i+'-'+i1,'value':( (fx[i1])?fx[i1].value:'' ) }) ); } z.empty().adopt(fy); }); } }
fu.store('tabledata',fn);
}
fm();

} else if(fs == 'form'){

if(fl){
if( !fl.hasClass('formglobal') && !fl.hasClass('formconfig') ){ fp = ( !fl.hasClass('ehilited') )?1:null;uu(fa.getParent('form'));if(fp){ 
new Element('div',{'class':'ehilite'}).inject(fl);fc = fl.getElements('label');fi = fl.getElements('p,input,select,textarea');fv = ( fl.hasClass('manifest') )?'manifest':( fi[0].get('name') && fi[0].get('name').test(/^(pre|opt)_spamcheck/) )?'spam':fi[0].get('type');if( fc && fc[0] ){ fr = (fc[0].getElement('span.required'))?'required':null;if( fi[0].get('tag') == 'select' ){ fs = (fi[0].selectedIndex || 0);fv = 'select'; } else if( fi.length > 1 ){ for(i=0;i<fi.length;i++){if(fi[i].get('checked') == true){fs = i;}} } else { fs = null; } } else { if(fi.get('tag') == 'p'){fv = 'formtext';} }
if( fv == 'formtext' && fl.getElement('p') ){if(fl.getElement('p').getProperty('class') && fl.getElement('p').getProperty('class').test(/(format[0-9]+)(\s|$)/) ){fg = RegExp.$1;} else {fg = 'default';}}
fn = Object.merge(fn,{'dupes':xx,'elements':fi,'formstyle':fg,'func':ff,'labels':fc,'detailname':( ( fi[0].get('name') )?fi[0].get('name').replace(/^(opt|pre)_/i,'').replace(/_([0-9]+)$/i,''):'new name' ),'detailparent':fl,'number':(c.number || 0),'required':fr,'placeholder':fi[0].getProperty('placeholder'),'selected':fs,'tag':fi[0].get('tag'),'text':fi[0].get('text'),'detailtype':fv,'update':q});
fl.store('editdata',fn);console.log('ff = fe:',fe,' fa:',fa,' fl:',fl,' fn:',fn);fl.addClass('ehilited');G.emenuiconG(fl);fl.scrollMe();G.emenuswitchG(E.eloutput,8,null,'unfill',E.lastscroll); 
}} else {
console.log('ff form ',fa.get('id'),fa);
fp = Object.merge( {},e );if(fp){ fv = (fa.get('tag') == 'select')?fa.options[fa.options.selectedIndex].value:fa.get('value');fl = fa.getProperty('name').replace(/^(pre|opt)_/,'').replace(/_([0-9]+)$/,'');if( fa.hasClass('tt_changed') && fp[fl] && fp[fl] != fv ){ fp[fl] = fv; }console.log('ff editform fv:',fv,' =  fn:',fn,' fl:',fl,' fp:',fp,' fs:',fs); fm(); }
}
}

} else { 

fn = fa.getParent('ul.ful');if(fn){ fp = Object.merge( {},fn.retrieve('feeddata') );if(fp){ fv = (fa.get('tag') == 'select')?fa.options[fa.options.selectedIndex].value:fa.get('value');fl = fa.getAttribute('data-feedname');if( fa.hasClass('tt_changed') && fl && fl != fv ){ fp[fl] = fv;fn.store('feeddata',fp); }console.log('ff editfeed fn:',fn,' fl:',fl,' feeddata:',fn.retrieve('feeddata'),' fs:',fs);fm();} }

}
break;
case 'editlink':
fv = {url:'',title:'',target:0,text:'',type:''};if(fa){
b.getElements('.tt_inputfail').unclassMe('tt_inputfail');E.eselection = null;
if($('tt_removelink').checked){ 
b.getElements('.fli').each(function(z,i){ if(i > 0 && !z.hasClass('tt_undisplay') ){z.vizMe('hide');} });$('removelinklabel').set('html','Remove link to <b>'+c.url+'</b>?');E.eselection = c.el;$('tt_removelink').addClass('tt_changed');G.eadjustsaveG(q); 
} else { 
b.getElements('.fli').each(function(z,i){ if(i > 0 && z.hasClass('tt_undisplay') ){z.vizMe();} });$('removelinklabel').set('html','Delete Link:');$('tt_removelink').removeClass('tt_changed');E.eselection = null;
switch( fa.get('id') ){
case 'tt_urllink': fv.url = fa.get('value');console.log('url test ',fv.url,' == ',c.url);if(fv.url != c.url){fx = 1;} break;
case 'tt_titlelink': fv.title = fa.get('value');if(fv.title != c.title){fx = 1;} break;
case 'tt_textlink': fv.text = fa.get('value');if(fv.text != c.text){fx = 1;} break;
case 'tt_targetlink': fv.target = fa.options[fa.options.selectedIndex].value;if(fv.target != c.target){fx = 1;} break;
case 'tt_typelink': fv.type = fa.options[fa.options.selectedIndex].value;if( fv.type.test(/email$/) ){fa.getParent('li.fli').addClass('emailtype');} else {fa.getParent('li.fli').removeClass('emailtype');}if(fv.type != c.type){fx = 1;} break;
}
console.log('editref ff: ',fe,fe.type,fa,fa.get('id'),' fv = ',fv,b,c,' == ',fv);
if(fx){ fa.addClass('tt_changed');G.eadjustsaveG(q);fu = $('tt_urllink').get('value');if( $('tt_typelink') && $('tt_typelink').options[$('tt_typelink').options.selectedIndex].value == 'edittextemail' ){ if( !fu.test(/^mailto:/) ){ $('tt_urllink').setProperty('value','mailto:'+fu); }if( !fu.test(/^mailto:(.*?)\@(.*?)\.(.*?)$/i) ){ $('tt_urllink').addClass('tt_inputfail');G.eadjustsaveG(q,1); } }if( fu == '' || fu == 'href_placeholder.html' || !fu.test(/(\S+\.[^/\s]+(\/\S+|\/|))/g) ){ $('tt_urllink').addClass('tt_inputfail');G.eadjustsaveG(q,1); }$$(['tt_titlelink','tt_textlink']).each(function(z,i){ fu = z.get('value');if( fu == '' ||fu.length < 3 ){z.addClass('tt_inputfail');G.eadjustsaveG(q,1);} }); } else { fa.removeClass('tt_changed');fi = $$(b.getElements('.tt_changed'));if( typeof(fi[0]) === 'undefined' ){G.eadjustsaveG(q,2);} }
}
}
break;
case 'edittype': fv = fa.retrieve('editdata');if(fa && fv){ fp = fa.getParent('div.formgrid');fr = fp.getElements('li.tt_selectarea');$$(fr).removeClass('fselected');fa.addClass('fselected');console.log('edittype ff :',fe.type,' = ',fa,' = ',fv,' overwrite ',d);G.eadjustsaveG(q); } break;
}
}}
};


jj = function(je){ G.stopG(je);
console.log('jj: ',je,' a:',a,' b:',b,' c:',c,' f:',f,' g:',g,' p:',p);
/* a:editfeed  b:<div class="tt_topmenu tt_menu8"> c:undefined  f:11 */
var i,i1,ja,jb,jc = 0,jd = {},jf = function(){ var jm = c.el.getParent('.tt_hasmedium'),jn;if(c.type == 'editimagelink'){c.el.getParent('.text').set('html','&#160;');} else {G.erangyG(c.el,'replace');}if(jm && jm.clean){jm.clean();} },jff,jg,jh,ji,jk = {},jl,jm,jn,jo = [],jp,jq,jr,js = '',jt = je.target,ju,jv = {},jw,jx = {},jy,jz = {};
uu(jt.getParent('form'));
if( jt.hasClass('nav-menuback') ){
switch(a){
case 'editclipboard': case 'editinput': case 'editfeed': case 'edittype': G.emenuswitchG(E.eloutput,f,null,'unfill',E.lastscroll); break;
case 'editlink': b.getElement('.formgrid').vizMe('hide',function(){ if( jt.hasClass('asrevert') || c.url == 'href_placeholder.html' ){ jf();G.emenuswitchG(E.eloutput,f,null,'unfill',E.lastscroll); } else { G.eblocknavG(je,f); } }); break;
}
} else if( jt.hasClass('nav-exit') && !jt.hasClass('unrevert') ){
b.getElement('.formgrid').vizMe('hide',function(){ kk(c); });
} else if( jt.hasClass('nav-update') && !jt.hasClass('unsave') ){
switch(a){
case 'editclipboard':
if(g == 'paste'){

jn = b.getElement('.fselected').getElement('article').getChildren();
if(jn && jn[0]){
console.log('editclipboard PASTE: fselected: jr:',jr,' E.eloutput:',E.eloutput)
jq = jn[0].cloneidMe( G.cacheG() );jq.replaces(E.eloutput);
switch(p){
case 'section': $$( jq,jq.getElements('div[class$=section]') ).each(function(z,i){z.datagridMe();z.addClass('tt_esection').hilitesectionMe();E.esections.push(z);});jq.addClass('tt_sectionactive'); break;
case 'grid': $$( jq,jq.getElements('div[class$=grid]') ).each(function(z,i){ z.datagridMe();z.addClass('tt_egrid').hilitegridMe();E.egrids.push(z);});jq.addClass('tt_gridactive'); break;
default: jq.dataMe();jq.addClass('tt_erow').hiliteMe();E.editable.push(jq);jq.addClass('tt_areaactive');
}
}
E.eloutput = jq;G.esaveableG(1,E.eloutput);b.getElements('div.formgrid').destroy();G.emenuswitchG(E.eloutput,f);E.eloutput.scrollMe();

} else {

jq = jt.getParent('form');
jh = b.getElement('.tt_changed');if(jh){ jn = jh.getElement('article'); }
jr = jh.getElement('input[id^=tt_titlelink]');if(jr && jr.get('value')){ jg = jr.get('value'); }
console.log('editclipboard CUT: fselected: jr:',jn,' E.eloutput:',E.eloutput);
if(jn && !jt.hasClass('submitted')){
new Element('input',{'id':'id_0','name':'opt_id_0','type':'hidden','value':'cut'}).inject(jq);
jq.getElement('#url_0').setProperty('value','documents/Clipboard');
jq.getElement('#type_0').setProperty('value','get'+p+'clips');
jq.getElement('#destination_0').setProperty('value','editclipboard.html');
jn.setProperty('data-clipname',jg);js = jn.outstyleMe();jq.getElement('#new_0').setProperty('value',js.wordStr());
b.addClass('tt_progress15').timerMe();jt.addClass('submitted');
//console.log('adding ',js,' to Clipboard as ',p,' and firing: ',jq);
jq.setProperty('method','post').submit();
}
}

break;
case 'edittype': jr = b.getElement('.fselected');console.log('editype: fselected: jr:',jr,' = text:',jr.get('text'),' E.eloutput:',E.eloutput);if(jr){ jv = jr.retrieve('editdata');jb =  'editmodule '+jv.name;jm = 7;if( jr.get('text').test(/^(header|text|image|line)$/i) ){ jb = jv.name;jm = (jr.get('text') == 'Image')?4:1; }jn = new Element('div',{'class':jb+' tt_areaactive','html':jv.html}).replaces(E.eloutput);G.esaveableG(1,jn);E.eloutput = jn;b.getElements('div.formgrid').destroy();G.emenuswitchG(E.eloutput,jm);G.eselectG();G.emenuiconG(E.eloutput);E.eloutput.scrollMe(); } break;
case 'editfeed': case 'editinput': 

if( p.test(/^(input|textarea|select|p)$/i) ){


jg = b.getElement('.inputgrid');
console.log('jj inputgrid ',jg,' from ',jt,' = formstage:',jg.retrieve('formstage') );
jr = ( $('tt_required') )?$('tt_required').checked:null;if(jr && jr != ''){jd['required'] = jr;}
c1 = jg.retrieve('formstage') || c;
jd.type = ( $('tt_typelink') )?$('tt_typelink').options[$('tt_typelink').options.selectedIndex].value:(c1.detailtype)?c1.detailtype:(e.type)?e.type:'text';

jg.getElements('li.fli').each(function(z,i){ 
jo = z.getElements('input,textarea,select');if( jo.length > 0 ){
jv = {};
jo.each(function(z1,i1){
ji = z1.get('id');
if( ji.test(/^tt_labellink_/) ){ jv['text'] = z1.get('value'); }
if( ji.test(/^tt_namelink/) && z1.get('value') != '' ){ jv['name'] = ( xx[ z1.get('value') ] )?z1.get('value')+'_copy':z1.get('value'); }
if( ji.test(/^tt_placeholder/) && z1.get('value') != '' ){ jv['placeholder'] = z1.get('value'); }
if( ji.test(/^tt_spamanswer/) && z1.get('value') != '' ){ jv['spam'] = z1.get('value'); }
if( ji.test(/^tt_formtext/) ){ jv['text'] = z1.get('value'); }
if( ji.test(/^tt_formstyle/) ){ jp = z1.options[z1.options.selectedIndex].value;if(jp != '' && jp != 'default'){jv['formstyle'] = jp;} }
if( ji.test(/^tt_optionlabel_/) ){ jv['label'] = z1.get('value'); }
if( ji.test(/^tt_optionvalue_/) ){ jp = (z1.get('tag') == 'select')?z1.options[z1.options.selectedIndex].value:z1.get('value');if(jp != ''){jv['value'] = jp;} }
if( ji.test(/^tt_selected_/) || z1.get('name').test(/^tt_selected_/) ){ jv['selected'] = (z1.getProperty('checked') == true)?'checked':null; }
if( ji.test(/^tt_valuelink_/) ){ jp = (z1.get('tag') == 'select')?z1.options[z1.options.selectedIndex].value:z1.get('value');if(jp != ''){jv['value'] = jp;} }
});
if( z.hasClass('fieldblock') ){ jd['el_'+jc] = jv; } else { jd = Object.merge(jd,jv); }
console.log('jc:',jc,' = jd:',jd,' jv:',jv,' = detailparent:',c1.detailparent);
jc++;
} 
});

console.log('save: a:',a,' type:',jd.type,' parent:',c1.detailparent,' = jd:',jd,' p:',p);
c1.detailparent.getElements('p,label,input,textarea,select').destroy();
$$(c1.detailparent.getElements('p')).unclassMe('format0 format1 format2 format3 format4 format5 format6 format7 format8');

if(jd.type == 'formtext'){
c1.detailparent.addClass('formtext').adopt( new Element('p',{ 'html':(jd.text || E.eform.msg)+((jd.required)?E.eform.req:'') }) );if(jd.formstyle){ if( jd.formstyle != '' && jd.formstyle != 'default' ){c1.detailparent.getElement('p').addClass(jd.formstyle);} }
} else {
c1.detailparent.removeClass('formtext');
jff = function(jfa,jfb,jfc){ return new Element('label',{ 'for':jfb,'class':'l-'+jd.type+((jd.type == 'checkbox' || jd.type == 'radio')?' css-check':''),'html':((jfc)?jfc:jfa.text)+((jfa.required)?E.eform.req:'') }); };
switch(jd.type){
case 'radio': Object.keys(jd).sort().each(function(z,i){ if( z.test(/^el_([0-9]+)/) ){ jn = new Element('input',{ 'class':'css-check','type':jd.type,'id':qq(jd.name)+'_'+i,'name':((jd.required)?'pre_':'opt_')+qq(jd.name)+'_'+c.number,'value':(jd[z].value || '') });if(jd[z].selected){jn.setProperty('checked',true);}jl = jff( jd[z],qq(jd.name)+'_'+i,jd[z]['label'] );c1.detailparent.adopt(jn,jl); } }); break;
case 'select': Object.keys(jd).sort().each(function(z,i){ if( z.test(/^el_([0-9]+)/) ){ jq+= '<option value="'+jd[z]['value']+'"'+( (jd[z]['selected'])?' selected':'' )+'>'+jd[z]['label']+'</option>'; } });jn = new Element('select',{ 'id':qq(jd.name)+'_'+c.number,'name':((jd.required)?'pre_':'opt_')+qq(jd.name)+'_'+c.number,'html':jq });jl = jff(jd,qq(jd.name)+'_'+c.number),c1.detailparent.adopt(jl,jn); break;
case 'submit': new Element('input',{'type':'submit','name':'submit_'+c.number,'value':jd.value,'class':'sub-s'}).inject(c1.detailparent); break;
default: 
console.log('default: ',a,c1.detailparent,' = ',jd);
jk = Object.merge(jk,{ 'type':jd.type,'id':qq(jd.name)+'_'+c.number,'name':((jd.required)?'pre_':'opt_')+qq(jd.name)+'_'+c.number,'value':(jd.value || '') });if(jd.type == 'checkbox'){ jk = Object.merge(jk,{'class':'css-check'}); }if(jd.placeholder){ jk = Object.merge(jk,{'placeholder':jd.placeholder}); }
if(jd.spam){ jk = Object.merge(jk,{'spam':jd.spam});if( $('spamresult_edit') ){$('spamresult_edit').set('value',jd.spam);} }
console.log('save: ',a,b,c1.detailparent,' = ',jk);
jn = (jd.type == 'textarea')?new Element('textarea',Object.merge(jk,E.eform['textarea'])):new Element('input',jk);if(jd.selected){jn.setProperty('checked',true);}jl = jff(jd,qq(jd.name)+'_'+c.number);
if( jd.type == 'checkbox'){ c1.detailparent.adopt(jn,jl) } else { c1.detailparent.adopt(jl,jn); }
}
}

jg.vizMe('hide');
$$(c.update).unclassMe('unrevert unsave');
console.log('save 2: ',c1.detailparent.get('html'),' c1 = ',c1,' f = ',f,' hide ',b,' change:',E.eloutput );
G.esaveableG(1,E.eloutput);b.getElements('div.formgrid').destroy();G.emenuswitchG(E.eloutput,8,null,'unfill',E.lastscroll);
if(c.func && typeOf(c.func) == 'function'){c.func(c1.detailparent);}


} else if( p == 'form' ){


jg = b.getElement('.formgrid');
jn = $('body0').getElements('form[id^=cgi_form]').length;
jx = new Element('form',{ 'id':'cgi_form_'+jn,'action':( $('action_edit').get('value') || c.action),'method':( $('method_edit').get('value') || c.method ),'accept-charset':'UTF-8' });
ji = jg.getElements('li.fli');
js+= '<fieldset>\n<ul class="ful">\n';
for(i=0;i<ji.length;i++){
jq = ji[i].getFirst('p,input,select,textarea');
jr = (jq && jq.getProperty('name'))?jq.getProperty('name').replace(/_([0-9+]$)/,'_'+jn):'';
if( ji[i].getElement('p') ){
js+= '<li class="'+ji[i].get('class')+'"><p class="'+ji[i].getElement('p').get('class')+'">'+ji[i].getElement('p').get('html')+'</p></li>\n'; //console.log(i,' = p: ',ji[i],' = ',jq,jr);
} else {
if(jq){ 
console.log(i,' = ',ji[i],' = ',jq,jr);
if( ji[i].getElement('input[type=submit]') ){
js+= '\n</ul>\n<ul class="ful">\n<li class="fli"><input class="'+jq.get('class')+'" value="'+jq.get('value')+'" name="submit_'+jn+'" type="submit" />\n';
} else if( ji[i].hasClass('formglobal') ){
//
} else if( ji[i].hasClass('formconfig') ){
jm = [];
if( ji[i].getElement('input[type=checkbox]') ||  ji[i].getElement('input[type=radio]') ){
jm = [ ji[i].getElement('input').get('id').replace(/_edit$/,''),( (ji[i].getElement('input:checked'))?ji[i].getElement('input:checked').get('value'):'') ];
} else if( ji[i].getElement('select') ){
jm = [ ji[i].getElement('select').get('id').replace(/_edit$/,''),ji[i].getElement('select').options[ ji[i].getElement('select').options.selectedIndex ].value ];
} else if( ji[i].getElement('textarea') ){
jm = [ ji[i].getElement('textarea').get('id').replace(/_edit$/,''),ji[i].getElement('textarea').get('value') ];
} else {
jm = [ ji[i].getElement('input').get('id').replace(/_edit$/,''),ji[i].getElement('input').get('value') ];
}
js+= '<input value="'+( (jm[1])?jm[1]:'' )+'" name="opt_'+jm[0]+'_'+jn+'" id="'+jm[0]+'_'+jn+'" type="hidden" />';
} else {
js+= '<li class="'+ji[i].get('class')+'">';
ja =$$( ji[i].getElements('input,select,textarea'));jp = $$(ji[i].getElements('label'));
for(i1=0;i1<ja.length;i1++){
jf = ( jp[i1] && jp[i1].getElement('span.required') )?E.eform['req']:'';
jh = ja[i1].getProperty('placeholder');
jr = ja[i1].get('name').replace(/_([0-9+]$)/,'_'+jn);
jk = ja[i1].get('tag');
ju = ja[i1].getProperty('type');
jb = jp[i1].get('text').replace(/\*/g,'')+jf;
jw = jr.replace(/^(opt|pre)_/,'');
if(ju && ju != 'radio' && ju != 'checkbox'){ js+= '<label class="l-'+ju+'" for="'+jw+'">'+jb+'</label>'; }
switch(jk){
case 'input':
if( ju == 'checkbox'){ js+= '<input class="css-check" type="checkbox" name="'+jr+'" id="'+jw+'" value="'+ja[i1].get('value')+'"'+( (ja[i1].get('checked') == true)?' checked':'' )+' /><label class="l-checkbox css-check" for="'+jw+'">'+jb+'</label>'; } else
if( ju == 'radio'){ js+= '<input class="css-check" type="radio" name="'+jr+'" id="'+jw+'-'+i1+'" value="'+ja[i1].get('value')+'"'+( (ja[i1].get('checked') == true)?' checked':'' )+' /><label class="l-radio css-check" for="'+jw+'-'+i1+'">'+jb+'</label>'; } else
if( ju == 'text'){ js+= '<input type="text" name="'+jr+'" id="'+jw+'"'+( (jh)?' '+jh:'' )+' />'; } else {}
break;
case 'select': js+= '<select name="'+jr+'" id="'+jw+'">'+ja[i1].get('html')+'</select></li>'; break;
case 'textarea': jl = '';Object.each(E.eform['textarea'],function(v,k){ jl+= ' '+k+'="'+v+'"'; });js+= '<textarea'+jl+' name="'+jr+'" id="'+jw+'">'+( (jh)?jh:'' )+'</textarea>'; break;
}
}
js+= '</li>\n';
}

}
}
}

js+= '\n</ul>\n</fieldset>';
console.log('jj: js:',js,' = jx:',jx,' eloutput:',E.eloutput,' c:',c);
jx.set('html',js).replaces(E.eloutput.getElement('form'));
if( $('cgireturn_edit') && $('cgireturn_edit').checked ){ if( !$('tt_returndiv_'+c.number) ){ new Element('div',{'id':'tt_returndiv_'+c.number,'class':'row editblock','html':'<div class="edittext tt_erow tt_areawaiting">\n<div class="ehilite tt_e1row">&#160;</div>\n<div class="text">\n<p>Thank you.</p>\n<p>Please see a copy of your form submission below:</p>\n</div>\n</div>'}).inject(jx.getParent('.editblock'),'after');G.eselectG();G.emenuiconG(jx);jx.scrollMe(); } } else { if( $('tt_returndiv_'+c.number) ){ $('tt_returndiv_'+c.number).destroy(); } }
E.eloutput.dataMe();
console.log('form = ',jx,' target is ',E.eloutput,' editdata is ',E.eloutput.retrieve('editdata'));
G.esaveableG(1,E.eloutput);b.getElements('div.formgrid').destroy();G.emenuswitchG(E.eloutput,11);

} else if( p == 'table' ){

jr = b.getElement('.inputgrid.editfeed');
if(jr){
console.log('jj p:',p,' tabledata:',jv,' E.eloutput:',E.eloutput,' target:',jx);
jn = '<table>';jv = jr.getElement('ul.tableblock').retrieve('tabledata');jx = E.eloutput.getElement('.text'); 
if( jv.header){ jn+= '<thead><tr><td colspan="'+jv.columns+'">'+jv.header+'</td></tr></thead>'; }
jn+= '<tbody>';
jr.getElement('ul.ful.tableblock').getElements('li.fli').each(function(z,i){ jn+= '<tr>';z.getElements('input').each(function(z1,i1){ jn+= '<td>'+z1.value+'</td>'; });jn+= '</tr>'; });
jn+= '</tbody>';
if( jv.footer){ jn+= '<tfoot><tr><td colspan="'+jv.columns+'">'+jv.footer+'</td></tr></tfoot>'; }
jn+= '</table>';
jx.set('html',jn);
G.esaveableG(1,E.eloutput);E.eloutput = jx;b.getElements('div.formgrid').destroy();G.emenuswitchG(E.eloutput,7);G.eselectG();G.emenuiconG(E.eloutput);
}

} else {

jr = b.getElement('.inputgrid .feeddata');
if(jr){ 
jk = {};js = '';jv = jr.retrieve('feeddata');
console.log('jj p:',p,' feeddata:',jv,' E.eloutput:',E.eloutput);
jn = new Element('div',{'class':'editmodule '+p+' tt_areaactive'});
jx = new Element('div',{'class':'text'});
Object.each(jv,function(v,k){ 
if( k.test(/^(href|title|class|style)$/) ){ 
if(v && v != ''){js+= k+'="'+v+'" ';}
} else if(k == 'text'){
jk[k] = v;
} else { 
if(v && v != '' && v != 'none'){js+= 'data-'+k+'="'+v+'" ';}
} 
});

if( E.eloutput.getElement('a') ){ jg = E.eloutput.getElement('a');if(js != ''){ js = js.replace(/\s$/,'');js = '<a '+js+'>'+( (jv.text)?jv.text:'&#160;' )+'</a>'; }jx.setProperty('html',js) } else { jg = jn;jx.setProperty('html',E.eloutput.getElement('div.text').get('html')); }jx.inject(jn);Object.each(jk,function(v,k){ if(v != 'none'){jg.setAttribute('data-'+k,v);} });jn.replaces(E.eloutput);
G.esaveableG(1,E.eloutput);E.eloutput = jn;b.getElements('div.formgrid').destroy();G.emenuswitchG(E.eloutput,7);G.eselectG();G.emenuiconG(E.eloutput);E.eloutput.scrollMe();
}

}

break;
case 'editlink': console.log('editlink save: ',je,' == c.el:',c.el,' E.eselection:',E.eselection,' c:',c);
if( E.eselection ){ jf(); } else { 
jn = new Element('a',{}).setProperty('title',$('tt_titlelink').get('value')).setProperty('href',$('tt_urllink').get('value'));if($('tt_targetlink').options[$('tt_targetlink').options.selectedIndex].value > 0){jn.setProperty('target','_blank');}if(c.type != 'editimagelink'){ jn.set('text',$('tt_textlink').get('value')).unclassMe('edittextlink edittextemail editlinkinline').addClass( $('tt_typelink').options[$('tt_typelink').options.selectedIndex].value); }
if( c.el.get('tag') == 'p'){ c.el.empty().adopt(jn); } else { jn.replaces(c.el); }
}
$(c['update'][0]).removeClass('unsave');$(c['update'][1]).removeClass('unrevert');
G.esaveableG(1,E.eloutput);b.getElements('div.formgrid').destroy();G.emenuswitchG(E.eloutput,f,null,'unfill',E.lastscroll);
break;
}

} else {
//
}
};

kk = function(ka){ var kh = cc(ka),kf,kn;
b.getElements('div.formgrid').destroy();E.eloutput.eliminate('editstage');
kn = new Element('div',{'class':'formgrid '+a}).inject(b).store('formstage',ka).addEvents({ 'click:relay(a.tt_get-guide)':function(e,el){ G.stopG(e);rr(kn,el.getAttribute('data-modname'),el); } });
console.log('kk = ',typeOf(kh),' = ',kh,'a:',a,' p:',p,' formstage:',ka);
if(typeOf(kh) == 'string'){
kn.set('html',kh);kn.getElements('input,select,textarea').each(function(z,i){ if( !z.get('id').test(/^used/) ){ z.attachMe({ 'input':ff,'change':ff,'blur':ff }); } },this);kf = kn.getElement('.tt_filegrab');if(kf){ G.fileG(kn,kf,'all'); }
} else {
kn.adopt(kh);
switch(a){
case 'editclipboard': if(g == 'paste'){ kn.getElements('li.fli:not(.fsection)').addClass('tt_selectarea').touchMe(null,null,ff); } else { kn.addClass('inputgrid').getElements('input,select,textarea').attachMe({ 'change':ff,'input':ff }); } break;
case 'edittype': kn.getElements('li.fli:not(.fsection)').addClass('tt_selectarea').touchMe(null,null,ff); break;
case 'editinput': kn.addClass('inputgrid').formMe();$$(kn.getElements('#tt_typelink,#tt_formstyle,#tt_required')).attachMe({ 'change':ff });$$(kn.getElements('#tt_formtext')).attachMe({ 'change':ff,'input':ff });console.log('kk = ',a,$$(kn.getElements('#tt_typelink,#tt_formtext,#tt_formstyle,#tt_required')));yy( kn.getElements('ul.ful.fieldblock') ); break;
case 'editfeed': kn.addClass('inputgrid').formMe();if(p == 'table'){ kn.getElements('li.formglobal .formhidden').attachMe({ 'change':ff,'input':ff });yy( kn.getElements('ul.ful.tableblock') ); } else if(p == 'form'){ kn.getElements('li.fli:not(.formconfig):not(.formglobal),p,input:not(.formhidden),select:not(.formhidden),textarea:not(.formhidden)').touchMe(null,null,ff);kn.getElements('li.formconfig .formhidden,li.formglobal .formhidden').attachMe({ 'change':ff,'input':ff }); } else { kn.getElements('input,select,textarea').attachMe({ 'change':ff,'input':ff }); } break;
}
if(kn.getElements('li.fli').length < 1){new Element('div',{'class':'info','html':'editing is not currently available for this Module'}).inject(kn);}
}
G.eadjustsaveG(q,2);
};

if(a == 'editclipboard' && g == 'paste'){ G.epullG(E.pl,null,{ 'id':g,'type':'get'+p+'clips','url':E.cfg.docfolder+'Clipboard' },function(cca,ccb){ var ccr = (ccb == 'OK')?ccb:'FAILED';console.log('epullG: ',cca,ccb,ccr);if(ccr == 'OK'){ E.eclips[p] = cca['result'];console.log('Current Clipboard loaded..',cca,ccb,' = ',E.eclips[p]);kk(c); } }); } else { kk(c); }
$$(q).removeEvents().touchMe(null,null,jj);
},

///////////////////////////////////////////////

edithideG: function(a,b){
console.log('unedit: ',a,b);
var m,p,s;
$$(a).each(function(z,i){
m = z.retrieve('hasmedium');
p = z.getNext('.text');
if(m && p){ 
$$(z.getElements('.editselection')).each(function(z1,i1){z1.unwrapMe('a');});$$(z.getElements('p,a,span')).unclassMe('edittarget editselection');if(b){if( p.getParent('.edittags') ){$$(z.getElements('p')).storeMe('class','restore');}s = z.get('html').htmlStr();p.set('html',s);console.log(p,' set to ',s);G.esaveableG(1,p); }
z.vizMe('hide',function(){ p.vizMe();if( z.getParent('.tt_pasteactive') ){z.getParent('.tt_pasteactive').removeClass('tt_pasteactive');}m.destroy();z.destroy();}); 
}
});
$('tt_alldiv').removeClass('tt_pastearea');
},

editopenG: function(a,b){
var ff,gg,hh,jj,m = E.ebar.getElement('div.tt_menu2'),n,o = $('tt_edittextinput'),p = $('pastemenu'),pp,q = { 'el':a,'input':null,'alter':[],'convert':[],'revert':[],'save':[],'original':a.get('html') },qq,r,rr,s = {},ss,tt,uu,v,w,yy;
if(o){ q['input'] = o; }if(p){ q['revert'].push( p.getElement('.nav-exit') );q['alter'].push( p.getElements('.nav-textbold,.nav-textitalic,.nav-textlink') );q['convert'].push( p.getElements('.nav-textformat') );q['save'].push( p.getElement('.nav-update') ); }if(m){ q['alter'].push( m.getElements('.nav-textbold,.nav-textitalic,.nav-textlink') );q['convert'].push( m.getElements('.nav-textformat') );q['revert'].push( m.getElement('.nav-exit') );q['save'].push( m.getElement('.nav-update') ); }

yy = function(ya){ ya.getChildren().each(function(z,i){ if( z.get('tag') != 'p' ){new Element('p').wraps(z);console.log('yy wraps:',z.getParent());} }); };
uu = function(){ $$(q['convert']).unclassMe('textheader0 textheader1 textheader2 textheader3 textheader4 textheader5 textheader6 textheader7 textheader8'); };
tt = function(ta){ q['el'].getElements('.edittarget').removeEvent('paste',rr).removeClass('edittarget');uu();if(ta){delete ta['target'];} };
ss = function(sa,sb){ var sd = ( sb != sa['target'] )?1:null;tt(sa);if(sd && sb != q['el']){ $$(q['alter']).removeClass('unalter');if( sb.get('class') ){ if( sb.get('class').test(/format([0-9]+)/) ){ w = RegExp.$1.toInt();$$(q['convert']).addClass('textheader'+w);} else { uu(); } }$$(q['convert']).removeClass('unalter');sb.addClass('edittarget').attachMe({'paste':rr});q['el'].store( 'hasmedium',Object.merge(sa,{'target':sb,'q':q}) ); } else { $$(q['alter']).addClass('unalter');$$(q['convert']).addClass('unalter'); } };
jj = function(e){ G.stopG(e);var jq = $(e.target).getPrevious('b.nav-update.textpaste');if( $(e.target).value == "" ){jq.addClass('unsave');} else {jq.removeClass('unsave');} },

hh = function(e){ var hd,i,hl,hm,hn,hs,ht,hv,hw,hx,hy,hz = [];
if( e && q && q['el'] ){ 

hm = q['el'].retrieve('hasmedium');
console.log('clicked: ',e,':',typeOf(e),' code:',e.code,' key:',e.key);
if(e.key == 'Backspace' || e.key == 46){ hv = $(e.target).getElement('.editselection.edittarget');console.log('key ',e.key,' target:',hv );if(hv){hv.destroy();} }

if(typeOf(e) == 'domevent'){

var hh2 = function(e,hhb,hhc){ var hhe,hhu,hhw;G.editcleanG(q['el'],'a','span','p');hhu = rangy.getSelection();if(hhu.rangeCount > 0){hhu = hhu.getRangeAt(0);}if( hhu && hhu.toString() != '' ){ console.log('is rangy: ',hhu.toString() );hhw = hhu.commonAncestorContainer;if(hhw.nodeType == 3){hhw = hhw.parentNode;}hhe = new Element('span',{'class':'editselection'});if( hhu.canSurroundContents(hhe) ){ hhu.surroundContents(hhe);console.log('element selected: ',hhu.toHtml(),' = ',hhe,' parent is ',hhw );hhc(hhb,hhe); } } else { hhc(hhb,$(e.target)); } };
console.log('editopen hh: ',e,' type:',e.type,' target:',e.target,' key:',e.key,' class:',e.target.get('class'),' url:',e.target.getProperty('href') );
if( $(e.target).hasClass('pastebefore') ){ //$(e.target).getParent('.tt_pasteactive') || 
G.stopG(e);hw = new Element('div',{'id':'pastetextarea','html':'<b class="navblock nav-update unsave textpaste unselect" title="update text">&#160;</b><b class="navblock nav-exit textpaste unselect" title="revert text">&#160;</b><textarea id="pasteinput"></textarea>'}).inject($('pastemenu'),'before').attachMe({'change':jj,'input':jj});hw.getElements('b').removeEvents().disableMe().touchMe(null,null,G.eblocknavG);
} else {
if( e.type == 'mouseup' || e.type == 'touchend' ){ G.stopG(e);hh2(e,hm,ss); 
} else { 
if(e.type == 'input' || e.type == 'keyup'){ hw = hm.value();hl = hw.replace(/<br( \/)*>/gi,'');if( hl < 2 ){ hx = new Element('p',{'text':''}).inject(q['el']);console.log('hx: ',hx);G.erangyG(hx,'wrap');console.log('hx2: ',hx); } else { if( hm.value() != '' ){ G.stopG(e); } }G.editcleanG(q['el'],'a');hs = 1; } 
}

}

} else {

if( typeOf(e) == 'array' ){ 
switch(e[0]){
case 'revert': $$(q['revert']).addClass('unrevert');$$(q['save']).addClass('unsave'); break;
}
}

} 
if(hs){ q['el'].setStyle('min-height','');$$(q['revert']).removeClass('unrevert');$$(q['save']).removeClass('unsave'); }
}};

pp = function(e){
var i,pc,pd = {},pff,pm = q['el'].retrieve('hasmedium'),pp = "",ps = q['el'].clone(),pt,py;
pff = function(pfa,pfb,pfc){ 

console.log('pff: pfa = ',pfa,' pfb = ',pfb,' pfc = ',pfc);
var pfd,pfn = "",pfs = '',pft;pfa = pfa.replace(/(\r)+/g,'\n').replace(/(\n)+/g,'<br />');
if( pfc && pfc.nodeType == 1 ){ 
pfn = pfa.elstringStr();
if( pfn.test(/^<p/) && pfc != q['el'] ){ new Element('div',{'html':pfn}).replaces(pfc);console.log('replace ',pfc,' with ',pfn); } else { console.log('set html: ',pfn,' into ',pfc);pfc.setProperty('html',pfn); }
pfs = pfb.get('html').htmlStr();
(function(){ pm.value(pfs);pm.clean();G.editcleanG(q['el'],null,null,'p');pm.focus();q['el'].removeClass('pastebefore').setStyle('min-height','');$$(q['revert']).removeClass('unrevert');$$(q['save']).removeClass('unsave'); }).delay('250');
} 

};

if( typeOf(e) == 'object' || typeOf(e) == 'domevent'){
pc = e.clipboardData,
console.log('paste: ',pc,e.type,e);
if(pc){
pt = pc.types;py = pc.items;e.preventDefault();
for(i=0;i < pt.length; i++){ pd[t[i]] = pc.getData(t[i]); }pp = pd['text/plain'] || pd['text/html'] || pd['text/uri-list'] || "";
console.log('pasting 1 from ',{ 'text':pd['text/plain'],'html':pd['text/html'],'uri':pd['text/uri-list'] });
pft = ps.getLast('.edittarget') || ps; //( $(e.target) && $(e.target).hasClass('edittarget') )?$(e.target):q['el'].getElement('.edittarget');
console.log('target: ',pft);
setTimeout(pff.pass([pp,ps,pft]),0);
} else {
if( !E.prepaste ){ var sc = a.scrollTop;E.prepaste = document.createDocumentFragment();while(a.firstChild){ E.prepaste.appendChild(a.firstChild); }setTimeout(function(){ var ph = a.innerHTML;a.innerHTML = E.prepaste;console.log('pasting 2: ',ph);a.appendChild(E.prepaste);a.scrollTop = sc;E.prepaste = false; },0); }
}
} else {
console.log('dropped ',e.type,typeOf(e),' = ',e);
pff(e,q['el'],q['el']);
}
};

rr = function(e){ var i,rc = [],rt = $(e.target),rx = [];(function(){ rx = rt.childNodes;for(i=0;i<rx.length;i++){ if( rx[i].nodeType == 3 ){ rc.push( new Element('p',{'text':rx[i].nodeValue}) ); } else { rc.push( rx[i] ); } }rt.empty().adopt(rc); }).delay(0); };

gg = function(e){ G.stopG(e);var gm = q['el'].retrieve('hasmedium');q['el'].removeClass('pastebefore');gm.value( $('pasteinput').value.elstringStr() );gm.clean();gm.focus();q['el'].setStyle('min-height','');$$(q['revert']).removeClass('unrevert');$$(q['save']).removeClass('unsave');$('pastetextarea').destroy(); },

ff = function(){
var fo,fq = { element:a,mode:Medium.richMode,autofocus:true,autoHR:false,cssClasses:{ editor:'tt_ce-editor',pasteHook:'tt_ce-paste',placeholder:'tt_ce-place',clear:'tt_ce-clear' },attributes:{remove:['style']},tags: {'break':'p','horizontalRule':'hr','paragraph':'p','outerLevel':['p'],'innerLevel':['a','span'] },keyContext:{8:hh,46:hh},beforeInvokeElement:hh,beforeInsertHtml:hh,beforeAddTag:hh }; // function(tag,shouldFocus,isEditable,afterElement){hh('addtag',{'tag':tag,'focus':shouldFocus,'editable':isEditable,'after':afterElement}); }
if( a.getParent('.edittags') ){ $$(a.getElements('p')).storeMe('class'); } else { yy(a); }
var fc = new Medium(fq);
a.undropMe().addClass('tt_hasmedium').store('hasmedium',fc).attachMe({ 'pastetext':gg,'revert':hh.pass([ ['revert'] ]) }).monitorMe(hh);a.addEventListener('paste',pp);
if( q['input'] ){ q['input'].setProperty('value','').attachMe({ 'change':G.filereaderG.pass([ q['input'],pp ]) }); }
$$(q['revert']).addClass('unrevert');$$(q['save']).addClass('unsave');
a.dropMe(pp);
tt();
$$(q['alter']).addClass('unalter');$$(q['convert']).addClass('unalter');
console.log('contenteditable loaded ',a,fc,' q:',q);
};

ff();
},

editparentG: function(a,b){ var n = [];while( a && !a.nodeName.toLowerCase().test(b) ){ n.push(a);a = a.parentNode; }return n; },
editrevertG: function(a){ var m,p;$$(a).each(function(z,i){ m = z.retrieve('hasmedium');p = z.getNext('.text');if(m && p){ m.value(p.get('html'));m.clean();m.focus();z.fireEvent('revert');} }); },

eformG: function(a,b,c){
var d,h,j = [],m,n,o = [],p = (a.getParent('.fieldblock'))?a.getParent('.fieldblock'):a.getParent('li.fli'),q,r,s,u,w;if(p){ d = p.retrieve('editdata');u = Object.merge({},d);q = d['update']; //console.log('eformG a:',a,' b:',b,' c:',c,' = p:',p,' d:',d,' q:',q);
switch(b){
case 'add': m = p.clone().inject(p,'after');
if( p.getParent('li.fieldwrapper') ){ 
o = p.getParent('li.fieldwrapper').getChildren('.fieldblock');w = p.get('html').toString().replace(/\_([0-9]+)"/g,'_'+o.length+'"');m.set('html',w);console.log('m:',m,' w:',w,' func:',d.func);
} else {
if( d.dupes && d.dupes[d.detailname] ){ h = d.dupes[d.detailname];r = new RegExp(d.detailname+'_','g');w = p.get('html').toString().replace(r,d.detailname+h+'_');m.set('html',w);d.dupes[d.detailname]++; }
u.detailname = d.detailname+h;u.detailparent = m;if(u.dupes && u.dupes[d.detailname]){u.dupes[d.detailname]++;}u.labels = m.getElements('label');u.elements = m.getElements('p,input,select,textarea');m.store('editdata',u); //console.log('m = ',m,' u:',u,' = ',w);
}
m.removeClass('ehilited').getElement('div.ehilite').destroy();j = j.combine( [m],m.getElements('p,input,select,textarea') );$$(j).touchMe(null,null,d.func); break;
case 'delete': p.vizMe('hide',function(){ p.destroy(); }); break;
case 'move': j = ( p.getParent('ul.fieldblock') )?p.getParent('ul.fieldblock').getChildren('li.fieldblock'):p.getParent('ul.ful').getChildren('li.fli');if(c && c == 'up'){n = j.goAr(p,1);w = (n >= j.length-1)?'after':'before';} else {n = j.goAr(p);w = (n < 1)?'before':'after';}p.inject(j[n],w);p.scrollMe(); break;
default: G.emenuswitchG(E.eloutput,15,u);
}
G.eadjustsaveG(q);
}},

egridonG: function(a,b){ if(a){ if( !a.hasClass('tt_egrid') ){a = a.getParent('.tt_egrid');}if(a && E.ebar){ $$('div.tt_egrid]').removeClass('tt_gridactive').addClass('tt_gridwaiting');E.eloutput = a;a.removeClass('tt_gridwaiting').addClass('tt_gridactive');if(!b){G.emenuswitchG(a,18);} } } },
eimgtypeG: function(a){ var d,f,h,n,t = E.cfg.upfolder;if(a){ t = a.urlStr();if( t.match(/^(.+\/)/) ){ t = RegExp.$1;E.cfg.upchange = t;console.log('eimgtype: ',t,' becomes ',E.cfg.upchange); } }return [ encodeURIComponent(t),t ]; },

emenufillG: function(a,b,c,d,e,f){
var f1,ff,g,h = [],j = [],n,m,p,q,r,t,u,w,y;if(d){u = (d.retrieve('editstage'))?d.retrieve('editstage'):d.retrieve('editdata');}
if( b == 'edittext' && d.retrieve('subtype') == 'table' ){b = 'edittable';u = 8;}
console.log('menufill: a:',a,' b:',b,' c:',c,' d:',d,' e:',e,' = u:',u);
/*
a:<div class="tt_topmenu tt_menu8"> b:editfeed c:undefined d:<div class="editmodule form tt_erow tt_areaactive"> e:11 u = { parent: div.row.editblock, parenttype: "editblock", type: "editmodule", subtype: "form", original:<html> }
*/
switch(b){
case 'editclipboard': case 'editfeed': case 'editlink': case 'editscript': case 'edittable': case 'edittype': case 'editinput': G.editareaG(b,a,c,d,u,e,f); break;
case 'editupload':
if( c && c.getAttribute('data-upload') ){t = G.eimgtypeG(c.getAttribute('data-upload'));} else {t = G.eimgtypeG(u.original);}w = '[ <a href="'+E.pl+'?type=viewfolders&url='+t[0]+'" title="view target folder" target="_blank">'+t[1]+'</a> ]'; a.getElements('div.uploadgrid').destroy();n = new Element('div',{'class':'uploadgrid'}).inject(a).adopt( 
new Element('div',{'class':'tt_uploadpad'}).adopt( new Element('div',{'class':'tt_module uploader tt_upload-wrapper'}).adopt( 
new Element('div',{'class':'tt_upload-title','html':'<h3>Add images to folder <b>'+w+'</b>:</h3>'}),new Element('div',{'class':'tt_uploadcontrol tt_unselect','tabindex':0,'html':'<h3>Drag file(s) into this box or click to select image(s):</h3></div>'}),new Element('div',{'class':'tt_uploadbox','html':'<div class="tt_upload-list"></div><div class="setuploadarea"></div><div class="tt_progress-wrap"><div class="tt_upload-progress"></div><div class="infotext"><p><b>Maximum Sizes: </b>The webserver will not process files <b>larger than 10MB</b> or <b>exceeding 2000px</b> in width or 4000px in height.</p><p><b>File Names: </b>Please ensure that your file is named with the correct file extension, eg: <b>.jpg</b>, <b>.png</b> or <b>.gif</b> for Images or <b>.pdf</b>, <b>.docx</b> or <b>.zip</b> etc for documents.</p></div></div>'}) 
)),
new Element('input',{'type':'button','value':'','class':'sub-s tt_upload-submit navblock nav-save unsave','name':'submit_0','id':'submit_0'}) );
G.modules['uploader'].onF(a,{'exit':G.emenuswitchG.pass([E.eloutput,5]),'url':E.pl,'usage':1}); 
break;
case 'editimage': 
a.getElements('div.editgrid').destroy();y = (u['altered'])?u['altered']:(u['image'])?u['image']:u['original'];
if( u['editarea'] == 'module' && !u['odim'] ){u['odim'] = E.eloutput.getElement('div:not(.ehilite)').dimMe();}
n = new Element('div',{'class':'editgrid','html':'<ul><li><div class="tt_imageselector tt_undisplay"><div class="tt_imagechooser"><img width="'+u['odim'].w+'" height="'+u['odim'].h+'" src="'+y.urlStr()+'"></div><div class="tt_imagegrab"><div class="tt_imagemenu"></div></div></div><label tabindex="0" class="tt_imageswitch"><b>'+y.urlStr().replace(/_mobile\./,'.')+'</b></label><input type="hidden" value="'+y.urlStr()+'" name="pre_new-image-0_0" class="tt_imageinput" id="new-image-0_0"></li></ul>'}).inject(a);
ff = function(fa,fb){ var fs = E.eloutput.retrieve('editstage');var fd = (fs && u['source'])?u['source']:(u['editarea'] == 'module')?E.eloutput.getElement('div:not(.ehilite)'):E.eloutput.getElement('div.text'),fg = (fs)?fs:E.eloutput.retrieve('editdata'),fu = (u['gg'])?u['gg']:null;
if(fs){
if( fa.hasClass('nav-update') ){ if( fd && fg && fb['new'] ){ fd.set('value',fb['new']);fg = Object.merge(fg,{'image':fb['new']});E.eloutput.store('editstage',fg); }E.ebar.getElement('.tt_menu8').vizMe(null,function(){ if(fu && typeOf(fu) == 'function'){fu();}E.ebar.getElement('.tt_menu5').vizMe('hide'); }); }
} else {
if( fa.hasClass('nav-update') ){ if( fb['new'] ){ if(fg){fg = Object.merge(fg,{'altered':'url('+fb['new']+')'});E.eloutput.store('editdata',fg);}fd.setStyle('background-image','url('+fb['new'].urlStr()+')');G.esaveableG(1,E.eloutput); } } else { if(fg && fg.altered){ E.eloutput.getElement('div.text').setStyle('background-image','url('+fg.original.urlStr()+')');delete fg.altered;E.eloutput.store('editdata',fg); } }G.emenuswitchG(E.eloutput,4); }
};
G.imagerG(n.getElement('label.tt_imageswitch'),3,'grid',ff); 
break;
case 'editscriptarea': case 'editformarea': case 'editfeedarea': case 'editimagearea': G.emenuiconG(d); break;
case 'editlayoutarea': case 'editsectionarea': console.log(b,' ',a,b,c,d,e,u);G.eunfillG();G.emenuiconG(d); break;
case 'edittextarea': G.editcloseG();G.emenuiconG(d); break;
case 'editlayout': case 'editsection': console.log(b,' ',a,b,c,d,e,u);break;
case 'edittext': 
q = d.getElement('div.text');r = q.getParent('.tt_areaactive'); 
p = new Element('div',{ 'class':'tt_editingdiv tt_undisplay','html':q.get('html') }).setStyle('min-height',q.dimMe().h+'px').inject(q,'before').vizMe();
q.vizMe('hide');r.addClass('tt_pasteactive');y = r;if(y == q){ y.addClass('tt_pastewrapper'); }f1 = new Element('div',{'id':'pastemenu','class':'ehilite tt_e1paste'}).inject(p,'before');['left','right','bottom'].each(function(z,i){ new Element('div',{'class':'tt_ce-'+z,'html':'&#160;'}).inject(r) });
E.ebar.getElement('.tt_menu2').getElements('b').each(function(z,i){ z.clone().inject(f1).disableMe().touchMe(null,null,G.eblocknavG); });
g = new Element('b',{'class':'navblock nav-textinput editor tt_unselect','html':'<input type="file" id="tt_edittextinput" title="drag a file into this area or click to import text">'}).inject(f1);
$('tt_alldiv').addClass('tt_pastearea');G.editopenG(p);f1.scrollMe(); 
break;
case 'editsave': q = E.ebar.getElement('.tt_menu10');if(q){$$(q.getElements('.activebar')).destroy();Object.each(E.eactive,function(v,k){ var o = v[0].retrieve('updated');if(o){ w = k.replace(/\s/g,'-').toLowerCase();new Element('div',{'id':w+'_bar','class':'activebar','html':'<input value="1" name="'+w+'" id="'+w+'_active" class="formhidden" type="checkbox"><label class="labelhidden css-check" for="'+w+'_active">Update <b>'+k+'</b> on <b>all</b> Site Pages?</label>'}).inject(q);} }); } break;
case 'editrevert': break;
default: console.log('default');G.editcloseG();$$('.tt_erow').unclassMe('tt_areaactive tt_areawaiting tt_firsttext');G.emenuswitchG(null,0);E.eloutput = null;E.all.removeEvents();
}

},

emenuiconG: function(a,b,c){ 
if(a){ var f,g,h = '',i,j,m,v = a.retrieve('editdata') || null,y = (a.hasClass('tt_esection'))?'SECTION':(a.hasClass('tt_egrid'))?'GRID':'VIEW',p,q;
f = (y == 'SECTION')?a.getElement('.ehilitesection'):(y == 'GRID')?a.getElement('.ehilitegrid'):a.getElement('.ehilite');
j = (y == 'SECTION')?a.countMe('esection'):(y == 'GRID')?a.countMe('egrid'):a.countMe('parent'); //
console.log('emenuicon 1: ',a,b,c,' f = ',f,' j = ',j,' v = ',v,' y = ',y);
if(v){
if(y == 'VIEW'){ y = ((a.getParent('ul.tableblock'))?'row':(a.hasClass('form'))?'form':(a.hasClass('fieldblock'))?v.detailtype:(a.get('tag') == 'li' && a.hasClass('fli'))?'field':(a.hasClass('script'))?'script':v.subtype).toUpperCase().replace(/^edit/i,'');if(y.test(/(FIELD|ROW)/) && !f){ f = new Element('div',{'class':'ehilite'}).inject(a); }if(y == 'SELECT'){y = 'OPTION';} } //
console.log('emenuicon 2: a:',a,' b:',b,' c:',c,' y:',y,' = v:',v);
/*
a:<div class="editmodule form tt_erow tt_areaactive"> b:undefined c:undefined  y:FORM = v:{ parent:div.row.editblock, parenttype:"editblock", type:"editmodule", subtype:"form",original:<html> }
a:<li class="fli ehilited"> b:undefined c:undefined  y:FIELD = v:{ dupes: {…}, elements: […], formstyle: null, func: ff(), labels: […], detailname: "name", number: 0, detailparent:li.fli.ehilited, placeholder:null, required:"required", selected:null, spam:null, tag: "input", text: "", update: Array [ b#tt_cancelfeed-0_0.navblock.nav-exit.unrevert.moduleeditor, b#tt_updatefeed-0_0.navblock.nav-update.unsave.moduleeditor, b.navblock.nav-menuback.moduleeditor ] value: null }
a:<ul class="ful fieldblock ehilited">  b:undefined  c:undefined  y: FIELD  = v:{ detailname:"name" detailparent:undefined detailtype:"select" elements:Array [ select#tt_name_0 ] labels:Array [ label ] required:null selected:0 }
*/
if(b && b == 'sectionshift' ){ q = {}; } else if(b && b == 'gridshift'){ a.addClass('tt_drillgrid');g = a.gridMe();G.eunhiliteG('layout',a,null,(a.getParent('.tt_drillgrid')?'drill':null)); }  else {
if(y == 'GRID'){a.removeClass('tt_drillgrid');}
q =
(y == 'SECTION')?{ 'textadd':'duplicate '+y,'delete':'delete '+y,'reorder':'move '+y+' down','reorder navup':'move '+y+' up','sectionshift':'alter '+y+' layout'  }: 
(y == 'GRID')?{ 'textadd':'duplicate '+y,'delete':'delete '+y,'reorder':'move '+y+' down','reorder navup':'move '+y+' up','change':((a.hasClass('wrappergrid'))?null:'change '+y+' width'),'format':((a.hasClass('wrappergrid'))?null:'change '+y+' type'),'gridshift':((a.getElement('div:not(.ehilitegrid)[class$=grid]') || a.getElement('div.tt_egrid'))?'show inner '+y+'S':null),'gridback':((a.getParent('div.tt_drillgrid'))?'back to parent '+y:null) }:
(y == 'OPTION' || y == 'RADIO')?{ 'textadd':'duplicate '+y,'delete':'delete '+y,'reorder':'move '+y+' area down','reorder navup':'move '+y+' area up' }:
(y == 'ROW')?{ 'textadd':'duplicate '+y,'delete':'delete '+y,'reorder':'move '+y+' area down','reorder navup':'move '+y+' area up' }:
(y == 'FIELD')?{ 'parent':((v.parentconfig)?'edit parent module':null),'edit':'edit '+y,'textadd':'duplicate '+y,'delete':'delete '+y,'reorder':'move '+y+' area down','reorder navup':'move '+y+' area up' }:
(b && b == 'shift')?{ 'width':'alter '+y+' area WIDTH','padding-left':'alter '+y+' LEFT padding','padding-bottom':'alter '+y+' BOTTOM padding','padding-right':'alter '+y+' RIGHT padding','padding-top':'alter '+y+' TOP padding','back':'back','size':((v.type == 'editimage')?'set displayed image size':null) }:
(v.type == 'editimage')?{ 'parent':((v.parentconfig)?'edit parent module':null),'edit':'edit '+y+' area','imagelink':'edit image link','textadd':'duplicate '+y+' area','delete':'delete '+y+' area','indent':'indent '+y+' area','unindent':'unindent '+y+' area','align':'align '+y+' area','reorder':'move '+y+' area down','reorder navup':'move '+y+' area up','shift':'alter '+y+' area layout' }:
(v.type == 'editline')?{ 'textadd':'duplicate '+y+' area','delete':'delete '+y+' area','reorder':'move '+y+' area down','reorder navup':'move '+y+' area up' }:
(v.type == 'editmodule')?{ 'parent':((v.parentconfig)?'edit parent module':null),'edit':'edit '+y+' area','textadd':'duplicate '+y+' area','delete':'delete '+y+' area','reorder':'move '+y+' area down','reorder navup':'move '+y+' area up','shift':'alter '+y+' area layout' }:
{ 'parent':((v.parentconfig)?'edit parent module':null),'edit':'edit '+y+' area','textadd':'duplicate '+y+' area','delete':'delete '+y+' area','reorder':'move '+y+' area down','reorder navup':'move '+y+' area up','shift':'alter '+y+' area layout','table':'alter format to '+((y == 'TABLE')?'TEXT':'TABLE') };
if(b && b == 'shift' && v.type == 'editimage'){ q = Object.merge({'height':'alter '+y+' area HEIGHT'},q); }
console.log('emenuicon 3: ',a,b,f,q);
if(f){ f.getElements('.navblock').destroy();if(!b || b == 'shift'){ p = Object.keys(q);for(i=0;i<p.length;i++){ if(q[ p[i] ]){ h = '';if( p[i].test(/^(delete|reorder)/) ){ if( !j || j.length < 1 ){ h = ' un'+p[i].replace(/(\s.*?)$/,'') } }m = new Element('b',{'title':q[p[i]],'class':'navblock '+( (y.test(/(FIELD|OPTION|RADIO|ROW)/))?'fieldblock ':'' )+'nav-'+p[i]+h,'html':'&#160;'}).inject(f).disableMe();if(!c){m.touchMe(null,null,G.eblocknavG);} } } }f.scrollMe(); }
}
}}},

emenuonG: function(a,b,c){ console.log('menuon: ',a,b,c);var m = a.getParent('.tt_erow'),n = (a.getParent('.editmodule') && a.getParent('.editmodule').getElement('.scriptblock') )?13:(a.getParent('.editmodule') && a.getParent('.editmodule').getElement('form') )?11:(a.getParent('.editmodule'))?7:(a.getParent('.editimage'))?4:1;
if(m && E.ebar){ 
$$('.tt_areaactive').each(function(z,i){ z.getElements('.ehilite').set('html','&#160;'); });
//////////////
console.log('emenuonG:  eloutput:',E.eloutput,' m:',m,' n:',n);
if(E.eloutput && m == E.eloutput){ G.eunhiliteG(); } else { $$('.tt_erow').removeClass('tt_areaactive').addClass('tt_areawaiting');E.eloutput = m;console.log('selected m:',m,' n:',n);m.removeClass('tt_areawaiting').addClass('tt_areaactive');G.emenuswitchG(E.eloutput,n); }
} },

emenuswitchG: function(a,b,c,d,e,f){
var ff,i,i1,j = E.ebar.getElements('.tt_topmenu'),k = E.menulist,n = 0,t = 0,p = 0,v = '',w = '';

ff = function(fn,fv){ //
var fc = (fv == 'editclipboard')?f:null;
console.log('ff = fn:',fn,' fv:',fv,' d:',d,' e:',e,' f:',f,' fc:',fc);
if(fn < 3 || fn == 4 || fn == 7 || fn == 11 || fn == 13 || fn == 17 || fn == 18 || fn == 19 || fn == 20 ){ // 0 1 2 4 7 11 13 17 18 19 20
E.all.removeClass('tt_undisplay');
if(E.eloutput && E.eloutput.scrollMe){ E.eloutput.scrollMe(); }
E.lastscroll = 0;
E.ebar.removeClass('tt_screen');
} else {
E.ebar.addClass('tt_screen');E.lastscroll = e || E.html.getScroll().y;E.all.addClass('tt_undisplay');
}
if(fn < 2 || fn == 4 || fn != 8 || fn != 12 || fn != 14 || fn != 15){ // 0 1 4 5 6 7 9 10 11 13 16 17 18 19 20 21
$('body0').removeClass('tt_opaque');
} else {
$('body0').addClass('tt_opaque');
}
if(fn > 0 && fn != 17 && fn != 19){if(d){console.log('no filling');} else {console.log('refilling ',j[fn],fv,fc,a,t,fc);G.emenufillG(j[fn],fv,c,a,t,fc);}} 
};

for(i=0;i<j.length;i++){ if( j[i].getStyle('display') != 'none' ){t = i;} }
//
console.log('emenuswitch = a:',a,' b:',b,' c:',c,' d:',d,' e:',e,' f:',f,' = t:',t);
/*
a:<div class="editmodule form tt_erow tt_areaactive"> b:11 c:null d:unfill e:256 f:undefined = t:8
E.eloutput,f,null,'unfill',E.lastscroll
*/
n = b || 0;
v = 'edit'+k[n];
w = (n == 20)?'sections':(n == 18)?'grids':(n == 1)?'edittexts':null;
if( w && E.cfg.eclips && E.cfg.eclips[w] && E.cfg.eclips[w] > 0 ){ j[n].getElements('.unpaste').removeClass('unpaste'); }
if( j[n] ){ j[n].removeClass('tt_undisplay');j[n].getSiblings('.tt_topmenu').addClass('tt_undisplay');ff(n,v); } else { console.log(' no ',n,' in ',j); }
},

epagesaveG: function(a){
console.log('epagesave: ',a);
var f = $('edit_form_0'),n,p = a.getParent('.tt_menu10'),q;
if(p){
p.addClass('tt_progress15').timerMe();a.addClass('submitted');
n = E.all.clone(true,true);
n.unuiMe();
n.getElements('div[class*=tt_random]').each(function(z,i){ while( z.getProperty('class') && z.getProperty('class').test(/(tt_random[0-9]+.*?section)/) ){z.removeClass(RegExp.$1);} });
q = n.outstyleMe();f.getElement('input[id=new_0]').setProperty('value',q+'\n<div class="tt_editref"></div>');//console.log('epagesave ',a,q);
f.setProperty('method','post').submit();
} else {
window.location.reload(); 
}
},

erangyG: function(a,b){ var p = G.editparentG(a,'div'),s = rangy.getSelection(),r = rangy.createRange(),w;s.removeAllRanges();if(a && a.parentNode){ switch(b){ 
case 'replace': r.selectNodeContents(a);s.setSingleRange(r);w = document.createTextNode(s.toString());console.log('insert= ',w,' before ',a,' in ',p);a.parentNode.insertBefore(w,a);a.destroy(); break;
case 'wrap': r.selectNodeContents(a);r.collapse(false);s.addRange(r); break;
}} },

esaveableG: function(a,b){ if(b){ Object.each(E.eactive,function(v,k){ if( b == v[0] || b.getParent(v[1]) ){console.log('updated ',v[0]);v[0].store('updated',1);} }); }E.esaveable = (a)?1:null;if(E.esaveable){ E.ebar.getElements('.nav-revert,.nav-save').unclassMe('unsave unrevert'); } else { E.ebar.getElement('.nav-save').addClass('unsave');E.ebar.getElement('.nav-revert').addClass('unrevert');} },
esectiononG: function(a){ if(a){ if( !a.hasClass('tt_esection') ){a = a.getParent('.tt_esection');}if(a && E.ebar){ $$('div.tt_esection]').removeClass('tt_sectionactive').addClass('tt_sectionwaiting');E.eloutput = a;a.removeClass('tt_sectionwaiting').addClass('tt_sectionactive');G.emenuswitchG(a,20); } } },

eselectG: function(){ var i,ii,l,m,q = {},t;E.editable = [];E.all.getElements(E.viewlist).each(function(z1,i1){ if( !z1.getElement('h1') ){ if( !z1.retrieve('editdata') ){ z1.dataMe(); }E.editable.push(z1); } });E.editable.each(function(z,i){ z.addClass('tt_erow').hiliteMe(); },this); },
eselectgridG: function(a,b){ var i,ii,l,m,q = {},t;if(!a){a = E.all;}if(!b){b = E.gridlist;}E.egrids = [];a.getElements(b).each(function(z,i){if( !z.retrieve('editdata') ){ z.datagridMe(); }E.egrids.push(z); });E.egrids.each(function(z,i){ z.addClass('tt_egrid').hilitegridMe(); },this); },
eselectsectionG: function(a){ var i,ii,l,m,q = {},t;E.esections = [];E.all.getElements(E.sectionlist).each(function(z,i){ if( !z.retrieve('editdata') ){ z.datagridMe(); }E.esections.push(z); });E.esections.each(function(z,i){ z.addClass('tt_esection').hilitesectionMe(); },this); },
eunfillG: function(a){ E.all.getElements('.tt_drillgrid,.tt_egrid,.tt_esection').each(function(z,i){if(a){z.removeClass('tt_drillgrid');}z.getElements('.tt_e1grid > .navblock,.tt_e1section > .navblock').destroy();},this); },

eunhiliteG: function(a,b,c,d){ 
var f = (b)?'div:not(.ehilitegrid)[class$=grid]':null,g,p = E.all,v = ((b)?b.retrieve('editdata'):(E.eloutput)?E.eloutput.retrieve('editdata'):null); //console.log('unhilite grid b:',b,' == eloutput:',E.eloutput,' editdata:',v,' caller:' + G.eunhiliteG.caller);
if(a && a == 'section'){ $$('.tt_esection').unclassMe('tt_sectionactive tt_sectionwaiting');G.emenuswitchG(E.eloutput,19);G.eselectsectionG(); } else if(a && a == 'layout'){ 
if(b){ 
p = b.getParent();if(!d){ p.removeClass('tt_drillgrid');if( p.hasClass('tt_gridwaiting') ){b = p.getParent();}if(b && !b.hasClass('tt_egrid')){b = null;f = null;} } //console.log('p:',p,' active:',p.hasClass('tt_gridwaiting'),' b parenttype:',v.parenttype,' b contains ',((b)?b.getElements('.ehilitegrid'):' no b'));
p.getElements('.ehilitegrid').each(function(z,i){z.getSiblings('.tt_egrid').unclassMe('tt_egrid tt_gridactive tt_gridwaiting');z.destroy();},this); 
} else {
g = (E.eloutput)?E.eloutput.getParent('.tt_drillgrid'):null;if(g){g.removeClass('tt_drillgrid');}$$('.tt_e1grid').destroy();
}
$$('.tt_egrid').each(function(z,i){z.unclassMe('tt_gridactive tt_gridwaiting');});if(!c){G.emenuswitchG(E.eloutput,17);G.eselectgridG(b,f);} } else { $$('.tt_erow').unclassMe('tt_areaactive tt_areawaiting');G.emenuiconG(E.eloutput,'hide');G.emenufillG(); } 
},

/////////////////////////////////////

csstestG: function(a,b){ b = b || 'inherit';var d = E.css[E.bsr],f = d+a,g = new Element('div'),h = d+a+':'+b,j = a.replace(/-([a-z]|[0-9])/ig,function(a1,b1){return (b1+'').toUpperCase();}),k = a+':'+b,s;g.style.cssText = h+';'+k+';';G.css3 = ('CSS' in window && 'supports' in window.CSS && (window.CSS.supports(a,b) || window.CSS.supports(f,b)) )?1:('supportsCSS' in window && (window.supportsCSS(a,b) || window.supportsCSS(f,b)) )?1:( typeof g.style[j] === 'string' && g.style[j] !== '' )?1:( typeof g.style[a] === 'string' && g.style[a] !== '' )?1:( typeof g.style[f] === 'string' && g.style[f] !== '' )?1:0;if(G.css3 && G.css3 < 1){console.log('warning: no css3: ',j,':',g.style[j],' ',a,':',g.style[a],' ',f,':',g.style[f],' from ',g.style.cssText);} },
delayG: function(a,b){ var d = (b)?b:200,t;clearTimeout(t);t = function(){a();}.delay(d,this); },
fileG: function(a,b,c){ if( !a.hasClass('tt_fileon') ){ b.empty().timerMe();G.epullG(E.pl,null,{ 'type':'getfiles','url':c },function(fa,fb){ var fr = (fb == 'OK')?fb:'FAILED',fs = "";console.log('epullG: ',fa,fb,fr);if(fr == 'OK'){ a.addClass('tt_fileon');E.efiles = fa['result'];console.log('Current Files loaded..',a,b,' = ',E.efiles);if(fr != 'OK'){ if(f){ b.addClass('sendfail'); } }} }); }},

filereaderG: function(a,b){
var dr,df = a.files,i;
for(i=0;i<df.length;i++){ 
if(df[i].type){ if( window.FileReader ){ 
if( df[i].type.test(/text\/(plain|html)/) ){ dr = new FileReader();dr.onload = (function(dfile){ console.log('dropped ',dfile.target.result,dfile.name,' pass to function ',b);b(dfile.target.result); });dr.readAsText(df[i]); }
if( df[i].type.test(/image.*/) ){ }//dr = new FileReader();dr.onload = (function(dfile){ console.log('dropped ',dfile.target.result,dfile.name,' pass to function ',b);b(['paste',{'src':dfile.target.result,'name':dfile.name}]); });dr.readAsDataURL(df[i]); 
} }
}
},

getimageG: function(a,b,c){ var n = Asset.image(a,{ onError:function(){ console.log('error loading ',a);if(c){ if(c == 'error'){console.log('load error: missing '+a);} else {G.getimageG(E.site+'/'+E.emissing,b,'error');} } else { console.log('trying reload ',a);G.getimageG(a,b,'retry'); } },onLoad:function(){ console.log('loading ',n);b(n,a); } }); },

imagerG: function(a,b,c,d){ var f,g,j,m,n = b,s,t,x,y = ( a.getParent('.tt_topmenu') )?a.getParent('.tt_topmenu'):a;if(a.hasClass('tt_imageswitch') && !a.hasClass('tt_imageon')){m = a.getPrevious('.tt_imageselector');g = a.getNext('input.tt_imageinput');
if(m){ f = m.getElement('div.tt_imagemenu');s = y.getElement('.nav-update');x = y.getElement('.nav-exit');t = y.getElement('.nav-menuback');
if(d){s.store('imagefunction',d);t.store('imagefunction',d);x.store('imagefunction',d);}f.empty().timerMe();
m.vizMe(null,function(){ var p = m.getElement('.tt_imagechooser'),u = E.eimages,v = g.get('value');a.addClass('tt_imageon');s.vizMe();t.vizMe();x.vizMe();
G.epullG(E.pl,null,{ 'type':'getimages','url':E.cfg.docfolder+E.cfg.imgfolder },function(fa,fb){ var fr = (fb == 'OK')?fb:'FAILED',fs = "";console.log('epullG: ',fa,fb,fr);if(fr == 'OK'){ E.eimages = fa['result'];console.log('Current Images loaded..');G.imageselectG(f,p,v,[a,g],x,s,t,m,b);if(fr != 'OK'){ if(f){ f.addClass('sendfail'); } }} }); }); } } 
},

imageselectG: function(a,b,c,d,e,f,g,h,j){
/*'documents/Images/headers/bg-28_header.jpg' => {
'parent' => [ 'documents/Images/headers' ],
'epoch' => [ 1493109181 ],
'name' => [ 'header-bg-28.jpg' ],
'path' => [ 'documents','Images','headers','bg-28_header.jpg' ],
'mobile' => [ 'bg-28_header_mobile.jpg' ],
'size' => [ '78k' ],
'published' => [ '25/04/2017' ],
'href' => [ 'documents/Images/headers/bg-28_header.jpg' ],
'used' => [ 'About.html','Contact.html' ],
'url' => [ 'documents/Images/headers/bg-28_header.jpg' ]
}*/
var o = [],p = '',q = '',s = {'box':b,'cancel':e,'revert':g,'current':c,'new':null,'target':d,'thisone':null,'save':f,'parent':h,'grab':null},t; //
console.log('imageselect: ',s,E.eimages);

var oo = function(oa,ob){ var on = oa.getParent('div.tt_imagelist'),ot = [],ou;ob.addClass('tt_thisone');while(on){ if( on.retrieve('imageurl') ){ ot.unshift( on.retrieve('imageurl') ); }if(on){ ou = on.getPrevious('label.tt_imagetitle') || null;if(ou){ou.addClass('tt_thisone');var op = ou.getPrevious('input');if(op){op.checked = true;}}on = on.getParent('div.tt_imagelist'); }}if( oa.getParent('.tt_imagemenu') ){ oa.scrollMe(null,oa.getParent('.tt_imagemenu')); }return ot; };

var kk = function(ka,kb){ $$( s.parent.getElements('.tt_thisone') ).removeClass('tt_thisone');return oo(ka,kb); };

var hh = function(ha,hb){ var hd = hb,hi = new Image(),hn = [];hi.src = ha.src;hi.width = ha.width;hi.height = ha.height;hi.replaces( $(s.box).getElement('img') );hi.setStyle('max-width:',hi.width+'px');$(s.target[0]).getElement('b').set('text',hd);//console.log('imageselect hh: ',s,' ha:',ha,' hb:',hb,' = ',hb,' == ',s.current);
if(hd == s.current){ s['new'] = null;s.save.addClass('unsave'); s.cancel.addClass('unrevert'); } else { s['new'] = hd;s.save.removeClass('unsave');s.cancel.removeClass('unrevert'); }
$(s.target[1]).setProperty('value',hb);hn = $(s.target[1]).getParent('form').checkMe('tr'); 
};

var ff = function(fe){ 
if(fe){var fa = $(fe.target),fj = fa.getParent('td'),ft,fu;ft = kk(fa,fj);fu = ft.join('/')+'/'+fj.retrieve('fullname');//console.log('ff: fa:',fa,' ft:',ft,' fj:',fj,' fu:',fu);
G.getimageG(E.cfg.docfolder+E.cfg.imgfolder+fu,hh); }
};

var gg = function(ga,gb,gc,gd,ge,g1){ 
var gf = 0,gh,gi,gj = [],gk = Object.keys(ga),gl = '',gm,gn = c,go = '',gp =[],gq,gr,grx,gs = [],gt = {},gu,gv,gv1,gw,gx,gy,gz,i;gp = gn.split('/');
if(gb < 1){ gx = new Element('div',{ 'class':'tt_imageinner tt_accordion' }).inject(gd);gd = gx;} //console.log('--> new gc: ',gc,' = ',g1+'_'+gb);
gk.sort().each(function(z,i){ 
if( Object.keys(ga[z]).length && Object.keys(ga[z]).length > 1 && ga[z]['used'] && typeOf(ga[z]['used']) == 'array' ){ 
if( !gy ){ gx = new Element('table',{'class':'editinnertable'});gm = new Element('tbody',{}).inject(gx);gy = 1; }gj.push(z);gt[z] =ga[z]['mobile'];
} else { 
gv1 = new Element('input',{'id':'toggle'+g1+'_'+gb+'_'+i,'type':'radio','name':'accordion'+g1+'_'+gb}).inject(gd);
gv = new Element('label',{'class':'tt_imagetitle tt_acclevel'+gb+'','html':z+' <b class="navblock nav-upload imageeditor" title="upload new image" data-upload="'+gc+z+'/">&#160;</b>','for':'toggle'+g1+'_'+gb+'_'+i }).inject(gd); //<i>('+g1+'_'+gb+') t['+gb+'_'+i+']</i>
gv.getElement('b').disableMe().touchMe(null,null,G.eblocknavG);
gi = new Element('div',{'class':'row editblock tt_accordion tt_imagelist'}).store('imageurl',z).inject(gd);
E.eimgacc++;gg(ga[z],gb+1,gc+z+'/',gi,ge,E.eimgacc+g1);
}
});

if(gy){ 
gx.inject(gd);
for (i=0;i<gj.length;i++){ if(gf < 1){gz = new Element('tr',{}).inject(gm);}go = '';grx = new RegExp(gc+gj[i]+'$');if( s.current.test(grx) ){ go = ' tt_thisone'; }//console.log(i,' = gc:',gc,' = gb:',gb,' gp:',gp[gb],' gc+gj[i]:',s.current,' =~ /',gc+gj[i],'/$ gj:',gj,' = ga:',ga[ gj[i] ]);
gr = (ga[gj[i]] && ga[gj[i]]['used'] && ga[gj[i]]['used'].length > 0)?'tt_imageused':'';if(gj[i] != ''){ gw = ( gt[ gj[i] ] )?' tt_grid-mobile':'';gu = new Element('td',{'class':gr+go+gw,'html':'<h3 class="tt_imageline">'+gj[i]+'</h3>'}).store('fullname',gj[i]).inject(gz);if(go != ''){s.thisone = gu;oo(gu,gu);}$$(gu.getChildren('h3')).disableMe();}if( gf < ge-1 ){gf++;} else {gf = 0;} }
}
};

var jj = function(je){ G.stopG(je);var jc,ji,jt = $(je.target),jw,jx;
if( !jt.hasClass('unsave') && !jt.hasClass('unrevert') ){ if(jt && jt == s.cancel && $(s.target[1]).get('value') != s.current){ jc = kk(s.thisone,s.thisone);G.getimageG(s.current,hh); }if( jt.hasClass('imageeditor') ){ jx = jt.retrieve('imagefunction');
console.log('jj = ',jt,' = ',jx,typeOf(jx));
if(jx && typeOf(jx) == 'function'){jx(jt,s);} } else { $$([s.save,s.cancel,s.parent]).vizMe('hide');$(s.target[0]).removeClass('tt_imageon');} } 
};

$$([e,f,g]).removeEvents().addEvent('click',jj);
Object.keys(E.eimages).sort().each(function(z,i){ gg(E.eimages[z],0,E.cfg.docfolder+E.cfg.imgfolder,a,j,i); });
a.timerMe('hide').addClass('tt_accordion').addEvents({ 'click:relay(.tt_accordion label)':function(e,el){ var n = $(el).getNext('.editblock'),p = $(el).getPrevious('input');if(p && p.checked == true){G.stopG(e);p.checked = false;} else { if(n){n.scrollMe(null,$(el).getParent('.tt_imagegrab'));} } } });
a.getElements('h3.tt_imageline').touchMe(null,null,ff);
},

initG: function(){
E.edittypes.blocks.editmodule.config.library.config.url = (G.library && G.library.url)?G.library.url:"";
$('body0').addEvents({ 'dragenter':function(e){G.stopG(e);},'dragleave':function(e){G.stopG(e);},'dragover':function(e){G.stopG(e);},'drop':function(e){G.stopG(e);} });
var d,f = E.url.uri.split(/\//),i,gl = '" style="background:transparent url(',hl = ') center no-repeat;"></span><span class="tt_loader',m = [],m1 = [],n = '',t = '',tl,u = navigator.userAgent.toLowerCase(),v = {};E.width = (window.screen.width > 980)?'desktop':(window.screen.width > 480)?'tablet':'mobile';E.url.site = f.shift();E.url.page = f.pop();E.url.folder = f.join('\/');
$$('.tt_module,.tt_function').each(function(z,i){console.log('init: ',z);z.activateMe();});
E.os = (u.test(/windows phone/))?'windows phone': (u.test(/windows/))?'windows':u.test(/(apple-i|iphone|ipad|ipod)/)?'ios':(u.test(/android/))?'android':u.test(/(blackberry|bb|kindle|macintosh|linux|openbsd|firefox)/)?RegExp.$1:'unknown';E.pd = (G.ispointer)?'pointer':(G.istouch)?'touch':'mouse';E.nm = ['firefox','ie','webkit','opera','ie'][E.bsr];
if(E.os == 'ios'){ d = u.match(/(ip(ad|od|hone))/i)[0];if(G.istouch){E.bm = (u.test(/CriOS/i))?'mc':'ms';}t = (d == 'ipad')?'tablet':'mobile';if( navigator.appVersion.test(/OS ([0-9]+)_([0-9]+)(_[0-9]+)*/) ){E.ios = parseFloat(RegExp.$1+'.'+RegExp.$2);} } else if( E.os == 'windows phone' ){ d = 'windows phone';t = 'mobile';E.bm = ''; } else { if( u.test(/mobile/i) ){t = 'mobile';}if(E.os == 'android'){ if( u.test(/android\s*(;\s*release\/)*([0-9.]+)/i) ){E.ias = parseFloat(RegExp.$2);}d = 'android';E.bm = (E.safari)?'as':(E.bsr == 0)?'af':(E.bsr == 2 && !E.safari)?'ac':(E.bsr == 3)?'ao':null;if( u.test(/mobi/i) ){t = 'mobile';} else {t = 'tablet';} } else { if( !['mac','linux','windows'].contains(E.os) ){t = 'mobile';} } }E.device = d || 'pc';E.vp = G.viewportG();
v = { url:E.url,device:E.pd,display:E.width,browser:E.bsr+'/'+E.nm+'/'+E.css[E.bsr],'os':E.os+' '+((E.ios > 0)?E.ios:''),viewport:E.vp.x+','+E.vp.y,screen:window.screen.width+','+window.screen.height,capable:(E.capable || 'no'),usable:(E.usable || 'no') };console.log(v);
E.html = $$('html')[0];if(G.istouch){ $('body0').removeClass('tt_no-touch');if( E.width == 'desktop'){E.width = 'tablet';} }E.all = $('tt_alldiv');E.scrollbase = $('tt_scrolldiv');
G.csstestG('animation-name');if(G.css3 && G.css3 > 0 && G.slideshow){ G.styleG( Object.values(G.slideshow.kf[0]).join('\n')+Object.values(G.slideshow.kf[1]).join('\n') ); }
G.eaddbarG();
if( $('type_0') && $('type_0').get('tag') == 'input' && $('type_0').get('value') == 'changesavepages' ){ E.scrollbase.addEvents({ 'click:relay(*)':function(e,el){ var c = el.getProperty('class'); //console.log('relay ',el,$('body0').getProperty('class'));
if( $('body0').hasClass('tt_editviewoff') ){ if( $('body0').hasClass('tt_editlayouton') ){ if( !c.test(/grid(\s|$)/) && !el.getParent('div[class$=grid]') ){G.stopG(e);G.eunfillG('undrill');G.eunhiliteG('layout'); } } else { if(!c.test(/section(\s|$)/) && !el.getParent('div[class$=section]') ){G.stopG(e);G.eunfillG();G.eunhiliteG('section');} } } else { if( !el.hasClass('editablearea') && !el.getParent('.editablearea') ){G.stopG(e);G.eunhiliteG();} }
} });
G.eselectG(); }
$$('div.nav-add').each(function(z,i){ if( z.getElement('input') ){z.getElements('input').attachMe({'input':function(){this.checkinputMe();} }); } },this);
if(E.cfg && E.cfg.defsections){ Object.each(E.cfg.defsections,function(v,k){ if(v != ''){var w = $('body0').getElement(v);if(w){E.eactive[k] = [w,v];} } });console.log('E.eactive: ',E.eactive); }
G.inscrollG();G.scrollG(G.inviewG.pass(['.tt_animate:not(.tt_slider)','overflow']));G.resizeG(G.inviewG.pass(['.tt_animate:not(.tt_slider)','overflow']));
},

inscrollG: function(){ $$('.tt_animate[data-scrolltrigger]').each(function(z,i){ var d,m,n,u = z.attriMe();if(u.scrolltrigger){ if( u.scrolltrigger.test(/\#/) ){n = $(u.scrolltrigger.replace(/\#/,''));if(n){d = n.dimMe();m = d.h+d.xy[1];}} else if( u.scrolltrigger.test(/\./) ){n = $(G.all).getElement(u.scrolltrigger);if(n){d = n.dimMe();m = d.h+d.xy[1];}} else {m = u.scrolltrigger;}z.store('scrolltrigger',m); } }); },
inviewG: function(a,b){ var v = G.viewportG(),w = G.scrolltopG(),wb,wh,ww;ww = v.x;wh = v.y;wb = (w + wh);if(a){$$(a).each(function(z,i){ var d = z.dimMe(),eb,eh,et,m,u = z.attriMe();eh = d.h;et = d.xy[1];eb = (et+eh);if(u.scrollclass){ m = z.retrieve('scrolltrigger');if(m){ if( m < w ){z.addClass(u.scrollclass); } else { if( z.hasClass(u.scrollclass) ){ z.removeClass(u.scrollclass); } } } } else { if( ww >= 640 ){ if( b && z.getParent() ){z.getParent().addClass('tt_unoverflow');}if( (eb >= w) && (et <= wb) ){ z.addClass('tt_inview'); } else if( (eb < w) && (et <= wb) ){ z.addClass('tt_inview'); } else { z.removeClass('tt_inview'); } }} }); }},

menuG: function(e){ console.log('was menuG',e); },
resizeG: function(a,b){ if(a && typeOf(a) == 'function'){ if(!b){window.removeEvents({ 'resize':G.delayG }).addEvents({ 'resize':G.delayG.pass(a) });} else {window.removeEvents({ 'resize':G.delayG });} }return this; },
scrollG: function(a,b,c){ var ff = function(fa,fb){ $('body0').addClass('scrolling');if(fa){fa();}if(G.scrollTimer != -1){clearTimeout(G.scrolltimer);}G.scrolltimer = window.setTimeout(function(){$('body0').removeClass('scrolling');if(fb){fb();}},500); };if(c){G.scrolltimer= -1;window.removeEventListener('scroll',ff);} else {window.addEventListener('scroll',ff.pass([a,b]),true);} return this; },
scrolltopG: function(){ var d = window.document;return window.pageYOffset || d.compatMode === "CSS1Compat" && d.documentElement.scrollTop || d.body.scrollTop || 0; },
sendG: function(a,b,c,d){ var u = { url:c,data:a,evalScripts:1,update:b,noCache:true,onRequest:function(){}.bind(this),onSuccess:function(tree,xml,htm,js){var j;if(b){b.getParent().timerMe('off');}if( htm.test(/^(\(error:|<h1>Software error:)/) ){ alert(htm);d(b); } else { d(b,htm); } }.bind(this),onTimeout:d.pass(b),onFailure:d.pass(b) };var snk = new Request.HTML(u).post(); },
styleG: function(a,b){ if(!a){a = [G.css.onF(G.css.sty)];b = ['css3'];}a = Array.convert(a);b = Array.convert(b);var i;for(i=0;i<a.length;i++){ if(!b[i]){b[i] = 'style_'+$$('style').length;}var h = ( $(b[i]) )?$(b[i]):new Element('style',{'id':b[i]}).inject(document.head);if(h.styleSheet){h.styleSheet.cssText = a[i];} else {h.appendChild(document.createTextNode(a[i]));} } }
});

[Element,Window,Document].invoke('implement',{
hasEvent: function(e,b){var events = this.retrieve('events'),list = (events && events[e])?events[e].values:null;if(b){var s = '';Object.each(events,function(v,k){s+= k+' = '+v+'; ';});return s;}if(list){var i = list.length;while(i--){ if(i in list){return true;} }}return false;}
});

Element.implement({
activateMe: function(){ var n = this.get('class').split(' ');if( n.contains('tt_function') ){ n.each(function(z,i){ if( G.functions[z] ){ G.functions[z](this); } },this); } else { Object.each(G.modules,function(v,k){ if( this.hasClass(k) && G.modules[k].onF ){ G.modules[k].onF(this); } },this); }return this; },
checkMe: function(a,b){ var n = [];var d = this.getElements(a),i,s,v;for(i=0;i<d.length;i++){ s = d[i].retrieve('original');v = d[i].getElement('input[name^=pre_]');if(s && v && s != v.get('value') ){ n.push(v);d[i].addClass('tt_changed'); } else { d[i].removeClass('tt_changed'); }if(b && !v.get('value').test(/[a-z0-9]/i) ){d[i].addClass('tt_inputfail');} else {d[i].removeClass('tt_inputfail');} }return n; },
countMe: function(a){ if(a){ if(a == 'parent'){ p = this.getParent('.section.editablesection') || this.getParent('.wrappergrid') || this.getParent('.editblock') || this.getParent();return p.getElements('div[class^=edit]'); } else { return this.getSiblings('div.tt_'+a); } } else { if( this.get('tag') == 'ul' ){ return this.getSiblings('ul'); } else if( this.get('tag') == 'li' ){return this.getSiblings('li');} else if( this.get('tag') == 'p' ){return this.getSiblings('p');} else if( this.hasClass('editblock') ){return this.getSiblings('.editblock');} else {return this.getSiblings('.edittext,.editimage,.editline,.editmodule');} } },

dataMe: function(a){ var f = ['copytype','formtype','locate','recipients','spamresult','submit'],h,i,l,p,q = {},r,s,t = { 'parent':this.getParent('.editblock'),'parenttype':'editblock' },y = this.getElement('div:not(.ehilite)');
Object.each(E.edittypes.blocks,function(v,k){ if( this.hasClass(k) ){t['type'] = k;if(k == 'edittext' && this.getElement('div.text > table')){t.subtype = 'table';} else {t.subtype = k;}if(k == 'editmodule'){ Object.each(E.edittypes.blocks.editmodule.config,function(v1,k1){ if( this.hasClass(k1) ){t['subtype'] = k1;} },this); }} },this);
Object.each(E.edittypes.views,function(v,k){ if( this.getParent('.'+k) ){t['parent'] = this.getParent('.'+k);t['parenttype'] = k;} },this);
Object.each(E.edittypes.areas,function(v,k){ if( this.getParent('.'+k+'area') ){t['parent'] = this.getParent('.'+k+'area');t['parenttype'] = k;t['parentconfig'] = this.getParent('.'+k+'area').attriMe();} },this);
if( t['subtype'] == 'form' ){ q.number = this.getElement('form').get('id').replace(/([a-z_])/gi,'').toInt();q.action = this.getElement('form').getProperty('action');q.method = this.getElement('form').getProperty('method');for(i=0;i<f.length;i++){ h =  this.getElement('form').getElement('input[id*='+f[i]+']');if(h){ q[f[i]] = h.value; } } }
this.eliminate('editstage');
if(y){ l = y.getElement('a');if(l){p = l.get('title') || '';} }
q = Object.merge(q,t);
if(a){ 
q = Object.merge(q,a); 
} else { 
q = Object.merge( q,{'original':( (t['subtype'] == 'editimage')?y.getStyle('background-image'):(t['subtype'] == 'script')?this.get('html').replace(/^\s*<div class="scriptblock">\s*/,'').replace(/\s*<\/div>\s*$/,''):this.get('html') ) }); 
if( t['subtype'] == 'editimage' || t['subtype'].test(/video/) ){ q = Object.merge(q,{'odim':y.dimMe()}); }
if( t['subtype'] == 'editimage' && !q['original'].test(/\.(jpg|gif|png)/i) ){q['original'] = (E.site+'/'+E.emissing).urlStr(1);}
if( t['view'] == 'editmodule' && l ){ 
q = Object.merge(q,{ 'config':l.attriMe(),'title':p,'url':l.getProperty('href'),'text':l.get('text') });
if( t['subtype'].test(/video/) ){
q = Object.merge(q,{ 'image':y.getStyle('background-image').urlStr() });if( !q['image'].test(/(jpg|gif|png)/i) ){q['image'] = E.site+'/'+E.emissing;}
} else {
t = p.replace(/^\s+/g,'');
}
}
}
this.store('editdata',q);//console.log(this,' editadata == ',q);
},

datagridMe: function(a){ var h = this.getParent(),i,l,p,q = {},r,s,t = {},u = (this.getProperty('class').test(/(section|grid)(\s*|$)/))?RegExp.$1:'';t = { 'parent':h,'type':u,'parenttype':(h && h.getProperty('class') && h.getProperty('class').test(/(section|grid)(\s*|$)/)?RegExp.$1:'div'),subtype:u };q = Object.merge(q,t);if(a){ q = Object.merge(q,a); } else { q = Object.merge( q,{'original':this.get('html')} ); }this.store('editdata',q); },
disableMe: function(a){ if(typeof(this.onselectstart) != 'undefined'){if(!a){this.onselectstart = function(e){if(e && e.preventDefault){ e.preventDefault();}return false;}} else {this.onselectstart = null;} } else { if(!a){this.addClass('tt_unselect');if(E.bsr == 1 || E.bsr == 3){this.setProperty('unselectable','on');}} else {this.removeClass('tt_unselect');if(E.bsr == 1 || E.bsr == 3){this.erase('unselectable');}} } return this; },
displayMe: function(){ var n = this,r = 1;while( r && n && n != E.scrollbase ){ if( n.getStyle('display') == 'none' ){r = null;}n = n.getParent(); }return r; },
dropMe: function(a){ if(window.FileReader){this.attachMe({ 'dragenter':function(e){ G.stopG(e);this.addClass('tt_dropzone'); }.bind(this),'dragleave':function(e){ G.stopG(e);if(e.target && e.target === this){this.removeClass('tt_dropzone');} }.bind(this),'dragover':function(e){ G.stopG(e);e.preventDefault(); }.bind(this),'drop':function(e){ G.stopG(e);if(e.event.dataTransfer){G.filereaderG(e.event.dataTransfer,a);}this.removeClass('tt_dropzone'); }.bind(this) });}return this; },
getlinkMe: function(){ console.log('getlink: ',this,typeOf(this),this.get('html'));var f = this.get('html'),l = this.getProperty('linkref') || this.getProperty('href') || null,l1,o = {'self':[],'all':[]},s = this.getElements('a'),t = this.getProperty('title'),t1,u = this.hasClass('blank'),u1;if(l){o.self = [this,f,l,t,u];}$$(s).each(function(z,i){ l1 = z.getProperty('linkref') || z.getProperty('href') || null;t1 = z.getProperty('title') || 'link to '+z.get('text');u1 = z.hasClass('blank');if(l1){ o.all.push([z,z.get('html'),l1,t1,u1]); } },this);return o;	},
getpropMe: function(a,b){ var h = {},p,r,s,t,u,y;if(a && typeOf(a) == 'string'){ u = a.split(' ');u.each(function(z,i){t = [];if( z.test( /^(.*?\-)color/) ){ r = new RegExp('^('+b+')\-*(color)(.*?)$'); } else { r = new RegExp('^('+b+')\-(.*?)([0-9\-\._]+)$'); }if( z.test(r) ){ t = [ RegExp.$1,RegExp.$2,RegExp.$3 ];h[ t[1] ] = ( t[2].test(/^[\d-]+$/) )?t[2].toFloat():(t[1] == 'color')?'#'+t[2]:t[2]; } },this); }return h; },
gridMe: function(){ var o = {};o['grids'] = this.getChildren('div:not(.tt_e1grid)[class$=grid]');return o; },
hiliteMe: function(a){ var n,o = this.getChildren('.ehilite'),s;if(o){o.destroy();}if(!a){s = this.getSiblings('.edittitle,.edittext,.editimage,.editline,.editmodule');n = new Element('div',{'class':'ehilite tt_e1row tt_undisplay','html':'&#160;'}).inject(this,'top');if(s && s.length > 0){n.addClass('tt_esiblings'+s.length);}n.removeClass('tt_undisplay').touchMe(null,null,G.emenuonG.pass([n])); }return this; },
hilitegridMe: function(a){ if(!a){if(!this.getElement('.tt_e1grid')){var n = new Element('div',{'class':'ehilitegrid tt_e1grid','html':'&#160;'}).inject(this,'top');n.touchMe(null,null,G.egridonG.pass([n]) );} }return this; },
hilitesectionMe: function(a){ var o = this.getChildren('.ehilitesection');if(o){o.destroy();}if(!a){var n = new Element('div',{'class':'ehilitesection tt_e1section','html':'&#160;'}).inject(this,'top');n.touchMe(null,null,G.esectiononG.pass([n]) ) }return this; },
monitorMe: function(a,b){ this.attachMe({ 'input':function(e){this.removeEvents('keyup');a(e);}.bind(this),'keyup:throttle(250)':a,'mouseup':a }); if('selectionchange' in document){ document.addEventListener('selectionchange',a,true); }if('ontouchend' in document){ this.attachMe({ 'touchend':a });}console.log('monitoring ',this);return this; },
outstyleMe: function(){  var a = this.outerHTML;return a.replace(/(\s*class=""|\s*id=""|\s*style=""|\s*style="\s*opacity:\s*1;\s*")/ig,'').replace(/id="" /ig,'').replace(/(\s+)"/g,' "').replace(/\&nbsp;/g,'&#160;').replace(/\&lt;/g,'&#60;').replace(/\&gt;/g,'&#62;').replace(/url\((&quot;|'|&#8217;)(.*?)(&quot;|'|&#8217;)\)/ig,'url($2)').replace(/(\r|\f)/g,'').replace(/\n\n+/g,'\n'); },
storeMe: function(a,b){ var h = {},p = this.getProperty(a);if(!b && p){ h[a] = p;this.store('stored',h).erase(a); } else { Object.each(this.retrieve('stored'),function(v,k){this.setProperty(k,v); },this);this.eliminate('stored'); }return this; },
styleMe: function(a){ var c = this.get('class'),g,h,i,i1,i2,k,r = 0,s = this.getStyle(a[0]),t;if( a[0] == 'width'){ if( s && s.test(/%/) ){k = s;} else {if(c){ if(c.test( /\bw([0-9]+)\b/) ){k = RegExp.$1;} else {g = G.styler.switchF();h = c.split(/ /);for(i=0;i<g.length;i++){ t = g[i].sheet.cssRules || g[i].sheet.rules || null;if(t){ for (i1=0;i1<t.length;i1++){for(i2=0;i2<h.length;i2++){var rg = new RegExp('\.'+h[i2],'i'),rs = t[i1].style,rt = t[i1].selectorText;if( rt&& rt.toLowerCase().test(rg) ){ if(rs && rs[a[0]] && rs[a[0]].test(a[1]) ){k = rs[a[0]];} }}} } }} }} }return (k)?k.toString().replace(/%$/,''):k; },
testMe: function(){ var t = (this.getParent() && this.getParent().getStyle('opacity') != 1)?null:1;return ( this.displayMe() && (this.getPosition().x > 0 || this.getPosition().y > 0) && this.getStyle('visibility') != 'hidden' && this.getStyle('opacity') > 0)?1:null; },
undropMe: function(){ this.detachMe(['dragenter,dragleave,dragover,drop']);return this; },
unscrollMe: function(a,b){ if(!b){this.setStyle('overflow'+a,'hidden');} else {this.erase('style');}return this; },
unuiMe: function(){ this.getElements('.ehilite,.ehilitegrid,.ehilitesection').destroy();this.removeClass('tt_undisplay');$$( this,this.getElements('.tt_erow,.tt_egrid,.tt_areaactive,.tt_areawaiting,.tt_gridactive,.tt_gridwaiting,.tt_sectionactive,.tt_sectionwaiting') ).unclassMe('tt_erow tt_egrid tt_areaactive tt_areawaiting tt_drillgrid tt_gridactive tt_gridwaiting .tt_sectionactive .tt_sectionwaiting');return this; },
unwrapMe: function(a){ var s;this.getChildren(a).each(function(z,i){ s = 1;z.inject(this,'before'); },this);if(s){this.destroy();} }
});

Array.implement({
maxAr: function(){ var c,m = 0;for (c=0;c<this.length;c++){if(this[c] > m){m = this[c];r = c;}}return r; }
});

String.implement({
cleanStr: function(){ return this.toString().replace(/[^a-zÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ-ÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ¿0-9\[\]\/:\(\)%\^\._ \-\~]/gi,''); },
elstringStr: function(){var a = this.toString().replace(/(\r\n|\n|\r)/g,'<br />');
a = '<p>'+a.replace(/<br \/>/g,'</p><p>')+'</p>';
a = a.unsmartStr().replace(/[^a-zÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ-ÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ¿0-9\-_\.,\/ \&#\;\:\^<>\?"@~\[\]\{\}\+\*\%\!=]/gi,'');
a = a.replace(/(<p>(\s|\&nbsp;|\&#160;)*<\/p>)/g,'');
a = a.replace(/(<p(\s)*class="(edittarget|pastetarget)*">(\s|\&nbsp;|\&#160;)*<\/p>)/g,'');
a = a.replace(/<p>(\s)*<p>/g,'<p>');
a = a.replace(/<\/p>(\s)*<\/p>/g,'</p>');
return a; },
htmlStr: function(){ var a = this.toString().replace(/(<br>|<br \/>)/g,'').replace(/="\s*/g,'="').replace(/\&nbsp;/g,' ').unsmartStr(),i,r = a,s = [],u = '',w = '';while( r.test(/(<p.*?>.*?<\/p>)/gi) ){ s.push(RegExp.$1);r = r.replace(RegExp.$1,''); }r = r.replace(/(<p>)|(<p\s*class=".*?">)|(<\/p>)/gi,'');if( r.test(/[a-zÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ-ÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ¿0-9\-_\.,\/ \&#\;\:\^<>\?"@~\[\]\{\}\+\*\%\!=]+/i) ){console.log('r is ',r);s.unshift('<p>'+r+'</p>'); }for(i=0;i<s.length;i++){ w+= s[i]+'\n'; }w = w.replace(/<p class="">\s*<p class="">/g,'<p class="">').replace(/<\/p>\s*<\/p>/g,'</p>').replace(/<p class=""><\/p>/g,'').replace(/class=""/g,'');console.log('htmlStr = a:',a,' s:',s,' == w:',w);return w; },
httpStr: function(){ var a = this.toString().replace(/%3A/g,':');if(E.bsr > 1){a = a.replace(/'/g,'%27');}return a; },
ucStr: function(a){var s = this.toString();var b = s.split(' ');var i,j = (a)?1:b.length;for(var i=0;i<j;i++){ b[i] = b[i].slice(0,1).toUpperCase()+b[i].slice(1); }return b.join(' ');},
unsmartStr: function(){ var a = this.toString().replace(/(\u2018|\u2019|\u201A|')/g,'&#39;').replace(/(\u201C|\u201D|\u201E)/g,'"').replace(/\u2026/g, '...').replace(/[\u2013\u2014]/g,'-').replace(/\u02C6/g,'^').replace(/\u2039/g,'&#60;').replace(/\u203A/g,'&#62;').replace(/[\u02DC\u00A0]/g,' ');return a; },
urlStr: function(a){ var b = (a)?'url('+this.toString()+')':this.toString().replace(/^url\(/,'').replace(/\)$/,'').replace(/"/g,'');return b.httpStr();}
});



var BgCLS = new Class({
Implements: [Class.Occlude,Options,Events],
Binds: ['onF','offF'],
property:'BACK',
options: { afnc:null,cls:null,dur:null,fnc:null,html:null,id:'woverlay',op:1,ov:0,scr:1,sw:null,tmr:1 },
initialize: function(a,opts){
this.setOptions(opts);
this.el = this.element = ( $(a) )?$(a).setStyles(''):new Element('div',{id:this.options.id,html:'<div class="infowrapper"></div>'}).inject(document.body);if(this.options.html){$$(this.options.html).inject( this.el.getElement('div.infowrapper') );}if( this.occlude() ){return this.occluded;}
if(this.options.cls){ this.el.addClass(this.options.cls); }
this.fnc = this.options.fnc;
this.op = this.options.op;
this.ov = this.options.ov;
this.sw = this.options.sw;
this.tmr = this.options.tmr;
this.v = null;
this.onF();
if( this.options.afnc ){ this.options.afnc(this.el); }
if( this.options.dur ){ if(this.tmr){this.timerF('off');}(function(){ var r = this.el.getElement('a.nav-return');this.offF();if(r){ 
//document.location = r.getProperty('href');
} }).delay(this.options.dur,this); }
},
endF: function(){ this.el.transitionMe(this.el.endMe).vizMe('hide',function(){ this.el.removeEvents().removeClass('tt_display');this.v = null;}.bind(this)); },
onF: function(){ if( !this.el.hasClass('tt_display') ){ this.el.setStyle('opacity',0);if(this.tmr){this.timerF();}this.el.addClass('tt_display');if(this.options.scr){ $$('html')[0].unscrollMe(''); }this.v = 1;this.el.transitionMe(this.el.endMe).vizMe(null,function(){ this.el.removeEvents().touchMe(null,null,this.offF); }.bind(this)); } },
offF: function(a,b){ if( this.el.hasClass('tt_display') ){ if(a && typeOf(a) == 'function'){ a(); } else {if(this.fnc && typeOf(this.fnc) == 'function'){this.fnc();}}console.log('BgCLS off: ',a,b,this.sw,this.options.scr);if(b || this.sw){this.endF();}if(this.options.scr){$$('html')[0].unscrollMe('',1);} } },
timerF: function(a){ if(!a){ this.el.timerMe(); } else { this.el.timerMe('off'); } }
});

var LocalCLS = new Class({
Implements: [Class.Occlude,Events],
Binds: ['abortF','errorF','handleF','updateF'],
property:'LOCAL',
options: { },
par: null,
progress: null,
initialize: function(a,opts){ 
this.el = this.element = $(a).getElement('input');if( this.occlude() ){return this.occluded;}
this.par = $(a).getElement('div.tt_progress-local');
this.target = $('destination_0');
this.progress = null;
if(this.par && this.target){ this.progress = this.par.getElement('div.tt_progress-bar'),this.el.addEvent('change',this.handleF); }
},
abortF: function(){ this.reader.abort(); }, //<button onclick="this.abortF();">Cancel read</button>
errorF: function(e){ switch(e.target.error.code){ case e.target.error.NOT_FOUND_ERR: console.log('File Not Found!'); break;case e.target.error.NOT_READABLE_ERR: console.log('File is not readable'); break;case e.target.error.ABORT_ERR: break;default: console.log('An error occurred reading this file');}; },
handleF: function(e){ 
this.progress.style.width = '0%';this.progress.textContent = '0%';
var reader = new FileReader();
reader.onerror = this.errorF;
reader.onprogress = this.updateF;
reader.onabort = function(e){ console.log('File read cancelled'); }.bind(this);
reader.onloadstart = function(e){ this.par.addClass('loading'); }.bind(this);
reader.onloadend = function(e){ var t = e.explicitOriginalTtarget || e.originalTarget || e.target;this.progress.style.width = '100%';this.progress.textContent = '100%';(function(){this.par.removeClass('loading');}).delay(1000,this);if(t.result){ this.target.setProperty('value',t.result);console.log(this.target.value); } else { console.log('unable to decode ',t); } }.bind(this);
reader.readAsText(e.target.files[0]);
},
updateF: function(e){ if(e.lengthComputable){ var p = Math.round((e.loaded / e.total) * 100);if(p < 100){ this.progress.style.width = p+'%';this.progress.textContent = p+'%'; }} }
});
G.modules['local'] = { onF:function(a){ new LocalCLS(a,{}); } };


var UploaderCLS = new Class({
Implements: [Options,Events],
Binds: ['manualF','sendF','sizeF'],
property:'UPLOAD',
options: { 
accept: '*.*;',autostart:false,block_size:101400,exit:null,gravity_center:null,max_file_size:10000000,max_queue:6,min_file_size:5,multiple:true,url:E.pl,usage:1,vars:{},
onAddFiles: function(a){ this.pbar.set('html','Total: '+a); },
onItemAdded: function(el,file,c){ console.log('item added: ',el);this.bsubmit.removeClass('unsave');el.addClass('item_box').adopt( new Element('div',{'class':'up-filename','html':file.name}),new Element('div',{'class':'up-type','html':file.type}),new Element('div',{class:'up-usage tt_undisplay','html':''}),new Element('div',{'class':'up-delete','html':'&#160;'}).addEvent('click',function(e){ G.stopG(e);this.cancelF(file.id,el); }.bind(this)),new Element('div',{'class':'up-progress'}).set('tween',{duration:200,unit:'%'}) );if(!file.type){return;}
if(this.usage){ this.getusageF( file.name,el.getElement('.up-usage') ); }
if(file.type.match('image') && c){el.addClass('image');new Element('img',{'src': c}).inject(el,'top');this.sizeF('on');} else if(file.type.match('audio') || file.type.match('flac')){el.addClass('audio');} },
onItemCancel: function(a){ var w = 0;a.destroy();if(this.filelist.length < 1){ this.pbar.set('html','');this.bsubmit.addClass('unsave'); w = 1; } else { this.filelist.each(function(z,i){ if( z.type.match('image') ){w++;} }),this; }if(w > 0){this.sizeF('off');} },
onItemComplete: function(a,b){ console.log('item complete: ',a,b);a.vizMe('off').destroy(); }, //if(c.error){this.msg+= c.error+'<br />';} else {this.msg+= c.target+c.filename+': '+c.status+'<br />';}var d = a.getElement('.up-progress');var p = 100;d.tween('width',Math.round((m*p)/100));this.pbar.set('html',Math.floor(p)+'%');el.getElement('.up-delete').destroy();el.setStyle('opacity',1); }, //el.getElement('.progress').destroy();
onItemError: function(a,b,c){ console.log( 'error to: item:',a,' id:',b,' response:',c,' area:',this.area ); },
onItemProgress: function(a,b){ console.log('item progress: '+b+'%');var d = a.getElement('.up-progress');if(!d){return;}d.tween('width',Math.floor(b)+'%');d.set('html',Math.floor(b)+'%'); },
onReset: function(a){},
onSelectError: function(a,b,c){ console.log('select error: ',a,b,c); },
onUploadStart: function(){ console.log('upload start: '); },
onUploadProgress: function(a,b,c){ console.log('upload progress: ',a,' ',b,c);this.pbar.set('html','Total: '+Math.floor(a)+'%'); },
onUploadComplete: function(a,b,c){ var i,f = '',s = "";console.log('upload complete: ('+a+' uploaded) ',b);for(i=0;i<this.filelist.length;i++){ f+= this.filelist[i].response;s+= '<b>'+this.filelist[i].name+'</b>: '+this.filelist[i].response+"<br />"; }if( f != "" ){ this.pbar.set('html',s); }if(b == 0){this.bsubmit.addClass('unsave');this.resetF();} } 
},
method: null,
container: null,

initialize: function(a,opts){
this.el = a;
if(this.el){
this.setOptions(opts);
this.accept = this.options.accept;
this.autostart = this.options.autostart;
this.blocksize = this.options.block_size;
this.bsubmit = this.el.getParent('form').getElement('input.tt_upload-submit') || this.el.getParent('form').getElement('input.sub-s');
this.area = this.el.getElement('.tt_uploadcontrol');
this.htmdest = this.el.getParent('form').getElement('input[id^=new_]').getProperty('value');if( this.htmdest == '' ){this.htmdest = this.destF('add');}
this.dest = this.el.getParent('form').getElement('input[id^=url_]').getProperty('value');if( this.dest.test(/\.html$/) ){this.dest = this.htmdest; }
this.exit = this.options.exit;
this.filelist = [];
this.form = this.el.getParent('form');
this.gcentre = this.options.gravity_center;
this.listarea = this.el.getElement('.tt_upload-list');
this.maxq = this.options.max_queue;
this.max = (E.url && E.url.page && E.url.page.test(/type=uploadsite$/))?100000000:this.options.max_file_size;
this.method = (!window.opera && window.File && window.FileList && window.Blob)?'HTML5':null;
this.min = this.options.min_file_size;
this.multiple = this.options.multiple;
this.ncu = 0;
this.pbar = this.el.getElement('.tt_upload-progress');
this.qpc = 0;
this.sizers = this.el.getParent('form').getElements('.tt_uploadsizer');
this.url = this.options.url;
this.imgoptions = this.form.getElement('.setuploadtitlearea');if(this.imgoptions && !this.url.test(/documents\/Digital/) ){ this.imgoptions.addClass('tt_undisplay'); }
this.usage = this.options.usage;
this.vars = this.options.vars;

console.log('uploader ',a,this.options,' dest:',this.dest,' = htmdest:',this.htmdest);
this.el.store('euploader',this);
this.buildF();
}
},

addfilesF: function(a){ var f,fname,fsize,ftype,i;for (i=0;f = a[i];i++){ fname = f.name || f.fileName;fsize = f.size || f.fileSize;ftype = f.type || f.extension || this.getextensionF(fname) || null;if( typeof fsize != 'undefined' ){if(fsize < this.minsize){this.fireEvent('onSelectError',['minfilesize',fname,fsize]);return false;}if(this.max > 0 && fsize > this.max){this.fireEvent('onSelectError', ['maxfilesize',fname,fsize]);return false;}}if( typeof ftype != 'undefined' && fname.test(/\.(.*?)$/i) ){ i = this.filelist.length;this.filelist[i] = {'file':f,'id':i,'uniqueid':String.uniqueID(),'checked':true,'name':fname,'type':ftype,'size':fsize,'uploaded':false,'uploading':false,'progress':0,'error':false};if(this.listarea){this.additemF(this.filelist[this.filelist.length - 1]);} }this.fireEvent('onAddFiles',[this.filelist.length+' item'+((this.filelist.length > 1)?'s':'')+'..']);if(this.autostart){ this.sendF(); } } },
additemF: function(a){ console.log('additem = ',a,' / ',a.type);var d = new Element('div',{'class': 'dropzone_item','id': 'dropzone_item_' + a.uniqueid}).inject(this.listarea);window.URL = window.webkitURL || window.URL;if(a.type.match('image') && window.URL){ var img = new Element('img');img.addEvent('load',function(e){this.fireEvent('itemAdded',[d,a,img.src,img.getSize()]);window.URL.revokeObjectURL(img.src);img.destroy();}.bind(this));img.src = window.URL.createObjectURL(a.file);this.gcentre.adopt(img);} else {this.fireEvent('itemAdded', [d,a]);} },

buildF: function(){
var ff = function(e){ if(e){G.stopG(e);}if( !$(e.target).hasClass('unsave') ){ if(this.filelist && this.filelist.length > 0){this.sendF();} else if( $('localfiles') ){ G.presendG(this.form); } else {if(this.exit && typeOf(this.exit) == 'function'){this.exit();}} } }.bind(this);
this.url = this.url + ((!this.url.match('\\?'))?'?' : '&') + Object.toQueryString(this.vars);
if(!this.gcentre){this.gcentre = this.bsubmit || this.listarea || this.area;}if(!this.gcentre){return;}
this.container = new Element('div', {'class':'dropzone_hidden_wrap'}).inject(this.gcentre,'after');
this.resetF();
if(this.area){ this.area.addEvents({ 'dragenter':function(e){G.stopG(e);this.area.addClass('dropzone_over');}.bind(this),'dragleave':function(e){G.stopG(e);if(e.target && e.target === this.area){this.area.removeClass('dropzone_over');}}.bind(this),'dragover':function(e){G.stopG(e);e.preventDefault();}.bind(this),'drop':function(e){G.stopG(e);if(e.event.dataTransfer){this.addfilesF(e.event.dataTransfer.files);}this.area.removeClass('dropzone_over');}.bind(this) }); }
this.form.getElements('input.duplicate_check,input.generate_check').each(function(z,i){ z.attachMe({ 'click':function(){ var d = $('duplicate_0'),l = $$( this.el.getParent('form').getElements('input.generate_check:checked') ),o = z.getProperty('checked'),p,t = v = z.getProperty('value');if(z == d){ if( o == true){ $$(l).setProperty('checked',false); } else { if( !l || l.length < 1 ){ z.setProperty('checked',true); } } } else { if( o == true){ d.setProperty('checked',false); } else { if( !l || l.length < 1 ){ d.setProperty('checked',true); } } } }.bind(this) }); },this);
this.bsubmit.attachMe({ 'click':ff });
this.area.attachMe({ 'click':this.manualF });
},

cancelF: function(id,b){ console.log( 'cancel:',id,b,this.filelist[id] );if(this.filelist[id]){this.filelist[id].checked = false;if(this.filelist[id].error){this.nerrors--;} else {this.ncu--;}}this.ncancelled++;if(this.ncu <= 0){this.queuecompleteF();}this.fireEvent('onItemCancel',[b]);},
countinputsF: function(){ var containers = this.container.getElements('input[type=file]');return containers.length; },
destF: function(a){ if( a || this.dest.test(/\.html$/) ){ return (E.cfg && E.cfg.upchange)?E.cfg.upchange:(E.cfg && E.cfg.upfolder)?E.cfg.upfolder:E.url.cgi.replace(/\/(.*?)\/$/,'/'); } else { return this.dest; } },
getextensionF: function(a){ return a.split('.').pop(); },
getusageF: function(a,b){ G.epullG(E.pl,b,{ 'type':'usedfiles','url':this.dest+a },function(sa,sb){ if(sa['result']){console.log('direct pull: ',sa,sa['result']);b.set('html','<b>Currently used in: </b>'+sa['result']).vizMe();} }); },

html5sendF: function(a,b,c){ 
var n = '';if(a.name.test(/\.(.*?)$/) ){ n = '.'+RegExp.$1;a.name = a.name.replace(/\.(.*?)$/,n.toLowerCase()); } 
var d = new FormData(),j,m = (this.listarea)?this.listarea.getElement('#dropzone_item_'+(a.uniqueid)):null,o = ($('destination_0'))?$('destination_0').value:null,q = Object.merge({ 'file':a.file,'X-Requested-With':'XMLHttpRequest','X-File-Name':a.name,'X-File-Size':a.size,'X-File-Id':a.id,'X-File-Total':this.filelist.length-1,'X-File-Resume':c,'type':( (this.el.getParent('form').get('id').test(/^edit_form/))?'changeuploadfolders':this.el.getParent('form').getElement('#type_0').value ),'url':this.destF(),'new':this.destF('add'),'destination':o },this.vars),t;this.sized = "";this.el.getParent('form').getElements('input.generate_check').each(function(z,i){ if(z.getProperty('checked') == true){ this.sized+= z.get('value')+'+'; } },this);this.sized = this.sized.replace(/\+$/,'');q = Object.merge(q,{'sized':this.sized}); 
Object.each(q,function(v,k){ d.append(k,v); });
var x = new XMLHttpRequest();
x.open('POST',this.url,true);
x.upload.onprogress = function(e){ var l = parseInt(e.loaded/e.total*100,10).limit(0,100);this.filelist[a.id].progress = l;this.fireEvent('itemProgress',[m,l]);this.updateprogressF(); }.bind(this);
x.onreadystatechange = function(e){ var j,t = 'there was a connection error with this upload';if(x.readyState == 4){ j = JSON.decode(x.responseText);if( typeOf(j) == 'object' && j.query && typeOf(j.query) == 'object' ){ if(j.query.result){ t = '<span class="imager-ok">'+j.query.result+'</span>'; } else { t ='<span class="imager-error">'+( j.query.debug || j.query.error || t )+'</span>'; }}console.log('received: ',x,' as ',typeOf(j.query),' = ',j.query,' / ',t);this.filelist[a.id].response = t;if(x.status == 200){ this.itemcompleteF(m,a);if(this.ncu < this.maxq && a.checked){this.sendF();} } else { this.itemerrorF(m,a,e);if(this.ncu == 0){this.queuecompleteF();} else if(this.ncu < this.maxq){this.sendF();} } } }.bind(this);
//console.log('send: ',d,' = ',q);
x.send(d);
},

itemcompleteF: function(a,b){this.ncu--;this.nuploaded++;this.filelist[b.id].uploaded = true;this.filelist[b.id].progress = 100;this.updateprogressF();this.fireEvent('onItemComplete',[a,b]);if(this.ncu <= 0 && this.nuploaded + this.nerrors + this.ncancelled == this.filelist.length){this.queuecompleteF();} },
itemerrorF: function(a,b,c){ this.ncu--;this.nerrors++;if(typeof b.id != 'undefined'){this.filelist[b.id].uploaded = true;this.filelist[b.id].error = true;this.fireEvent('onItemError', [a,b.id,c]);}if(this.ncu <= 0){this.queuecompleteF();} },
manualF: function(){ if( this.multiple || (!this.multiple && !this.isuploading) ){ this.xinput.click(); } },
newinputF: function(a){ if(!a){a = this.container;}this.xinput = new Element('input',{id: 'tbxFile_' + this.countinputsF(),name: 'tbxFile_' + this.countinputsF(),type: 'file',size:1,styles:{'position':'absolute','top':'20px','left':'20px'},multiple:this.multiple,accept:this.accept }).inject(a);if( this.method == 'HTML5' && (E.bsr == 3 || E.bsr == 1) ){this.positioninputF();} else {this.xinput.setStyle('visibility','hidden');}this.xinput.addEvent('change',function(e){G.stopG(e);this.addfilesF(this.xinput.files);}.bind(this)); },
positioninputF: function(){ if(!this.bsubmit && true){return;}var btn = this.bsubmit,btncoords = btn.getCoordinates(btn.getOffsetParent());this.xinput.setStyles({'top':btncoords.top,'left':btncoords.left-1,'width':btncoords.width+2,'height':btncoords.height,'opacity':0}); },//this.xinput.position({relativeTo: document.id(subcontainer_id+'_btnAddfile'),position: 'bottomLeft'});
queuecompleteF: function(){ this.fireEvent('uploadComplete',[this.nuploaded,this.nerrors]); },
resetF: function(){ this.filelist = new Array();this.xinput = undefined;this.ncu = 0;this.nuploaded = 0;this.nerrors = 0;this.ncancelled = 0;this.qpc = 0;this.isuploading = false;this.newinputF();this.fireEvent('reset',[this.method]); },
sendF: function(){ this.filelist.each(function(z,i){ if(this.ncu < this.maxq){ if(z.checked && !z.uploading){this.isuploading = true;z.uploading = true;this.ncu++;this.html5sendF(z,0,false);this.isuploading = false;this.fireEvent('onUploadStart');}}},this); },
sizeF: function(a){ if(this.sizers){ if(a == 'on'){ this.sizers.each(function(z,i){z.vizMe();}); } else { this.sizers.each(function(z,i){z.getElement('input').checked = false;z.vizMe('hide');}); } } },
updateprogressF: function(){ var p = 0,n_checked = 0;this.filelist.each(function(z,i){ if(z.checked){p+= z.progress;n_checked++;} });if(n_checked == 0){return;}this.qpc = p / n_checked;this.fireEvent('onUploadProgress',[this.qpc,this.nuploaded+this.ncu,this.filelist.length-this.ncancelled]); }
});
G.modules['uploader'] = { input:null,list:null,def:null,drop:null,onF:function(a,b){ new UploaderCLS(a,b); },startF:function(a){ a.sendF(); } };

window.addEvent('domready',G.initG);