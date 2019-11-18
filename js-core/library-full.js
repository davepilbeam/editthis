//#editthis version:8.2.2 EDGE
Object.append(G.library,{
catcls:'',
inputcls:'',
itemcls:'',
nav:'',
subcls:'',
subs:'',
back:['',':'],
cgi: 'view.pl',
css:null,
cu:'List All:',
data:{},
defimg: 'documents/thumbnail-default.jpg',
ds:'cgi_form_datasearch',
emp:'Currently there are no matching items.',
home:'&#60;&#60; Back',
nodrop:['cache','format','terms'],
order:[
[ 'digital',{ 'image':[1],'focus':[1],'title':[1,1],'author':[0],'published':[0],'area':[0,1],'project':[0],'text':[1,1],'url':[1],'tags':[1,1] } ]
],
sep:'<span> + </span>',
ser:['','Search:','LIB/css/css_icon-search.png'],
ss:'Show All &#62; &#62;',
initF: function(){ G.library.inited = 1; },
libF: function(){ console.log('Library css loaded');$$('div.editmodule.library').each(function(z,i){ var d,g,r;d = z.getElement('a');if(d){g = d.attriMe();if(g.basefolder && g.basefolder.test(/^documents/)){g.url = g.basefolder;delete g.basefolder;}r = d.getProperty('href');if(r && r.test(/dropbox\.com/)){g = Object.merge(g,G.library.dropbox);}new LibraryCLS(z,g);} }); },
loadF: function(){ if( !G.library.css ){ G.library.css = new Asset.css('library.css',{ id:'library',onLoad:G.library.libF }); } else { G.library.libF(); } },
sortF: function(a,b){ return a.localeCompare(b); }
});
var LibraryCLS = new Class({
Implements: [Class.Occlude,Events,Options],
Binds: ['addfileF','addfolderF','addimageF','buildF','displayF','sendF'],
property:'LIB',
options: { url:G.library.url,id:'paginate',amount:0,depth:0,form:null,format:'library',sort:'21',title:null,names:null,values:null,onlyarea:null,onlyfocus:null,pass:null },
initialize: function(a,opts){
this.el = this.element = ($(a).hasClass('libraryarea'))?$(a):($(a).getParent('.libraryarea'))?$(a).getParent('.libraryarea'):a.getParent('ul');if( this.occlude() ){return this.occluded;}
this.setOptions(opts);
var m = this.options;
this.dropbox = null;
this.useform = $$('ul.libraryformarea')[0] || null;
this.ftarget = null;
if( m['form'] && this.useform ){ 
this.fform = this.useform.getElement('form');
this.ftarget = this.useform.getElement('#library_0');
if(m['appname']){ 
new Element('input',{'value':'download','name':'pre_id_0','id':'id_0','type':'hidden'}).inject(this.ftarget,'after');
new Element('input',{'value':m['appname'],'name':'pre_appname_0','id':'appname_0','type':'hidden'}).inject(this.ftarget,'after');
}
}
this.depth = (m['depth'] > 0)?m['depth']:null;
var o,p = [],t = {};
this.files = [];
this.opener = ( E.durl.test(/\#(.*?)$/i) )?RegExp.$1:null; //Library.html#Digital/Datasheets/Security-Software/racfGUI.pdf
if( m['format'] ){ m['format'] = m['format'].toLowerCase(); }
if( m['onlyarea'] ){ t.editarea = G.edittags['editarea'] || null;delete m['onlyarea']; }
if( m['onlyfocus'] ){ t.editfocus = G.edittags['editfocus'] || null;delete m['onlyfocus']; }
Object.each(t,function(v,k){ if(v){ if( typeof m['names'] !== 'undefined' ){ m['names']+= ',';m['values']+= ','; }m['names']+= k;m['values']+= v; } });
this.fno = $$('form[id^=cgi_form').length || 0;
this.d = null,this.data = {};

this.sendF( this.el,m,a.get('html'),function(fa){ this.d = fa;console.log('building library: ',this.d,this.options.title,' m:',m);this.el.addClass('librarydata');
this.buildF(fa,this.options.title);
if(this.depth){ this.depth--;this.el.getElements('.librarylevel'+this.depth).each(function(z,i){p = z.getChildren('input[type=radio]');if(p && p[0]){p[0].checked = true;} }); }if(this.opener){this.displayF(this.opener);} }.bind(this) );
},

/*
area: ["UK-Europe"]
author: ["Ben Bloke"]
epoch: [1479081600]
focus: ["Financial", "Maverick"]
href: ["http://www.westfieldhealthdigitalresource.co.uk/documents/Digital/Posters/Poster-1/Test-PDF1-Poster-A2.pdf"]
image: ["Test-PDF1-Poster-A2.jpg"]
name: ["Test-PDF1-Poster-A2.pdf"]
parent: ["documents/Digital/Posters/Poster-1"]
path: ["documents","Digital","Posters","Poster-1","Print","Test-PDF1-Poster-A2.pdf"]
published: ["14/11/2016"]
size: ["1641k"]
tags: ["England", "Ireland", "Scotland", "Wales"]
text: ["An A2 document that is meant to be a test.", "Another line of text goes here."]
title: ["Ben's Test Document (PDF 1)"]
url ["Test-PDF1-Poster-A2.pdf"]

{ "Posters":{
"Poster-2":{"Test-PDF-Poster-2A.jpg":{"parent":["documents/Digital/Posters/Poster-2"],"epoch":[1481899017],"name":["Test-PDF-Poster-2A.jpg"],"path":["documents","Digital","Posters","Poster-2","Test-PDF-Poster-2A.jpg"],"size":["52k"],"published":["16/12/2016"],"href":["http://www.westfieldhealthdigitalresource.co.uk/documents/Digital/Posters/Poster-2/Test-PDF-Poster-2A.jpg"],"url":["documents/Digital/Posters/Poster-2/Test-PDF-Poster-2A.jpg"],"title":["Test PDF Poster 2A.jpg"]}
}
*/

addfileF: function(a,b){ 
var c = '',d = '',f = '',p,s = '',u = 'Downloadable File',w;
if( a['href'] && a['href'][0] && !a['href'][0].test(/_thumb\.(jpg|png|gif)$/i) ){
d = a['href'][0];f = a['title'][0];if( d.test(/\[(.*?)\]\.(.*?)$/) ){c = RegExp.$1;if(G.library.nocode){f = f.replace(/\[.*?\]/,'');}}
s+= '<div class="libraryitem" data-code="'+c+'">';
if(b){ s+= this.addimageF(a,this.form); }
s+= '<div class="libraryblock">';
if(b){ s+=  this.addtextF(a); }
if(a['title'] && a['title'][0]){u = a['title'][0].replace(/^.+\//,'');}
if(a['href'] && a['href'][0]){w = a['href'][0].replace(/^.+documents\//,'');}
s+= '<div class="librarylink">'+( (this.ftarget)?'<input class="css-check" type="checkbox" id="'+u+'_'+this.fno+'" name="opt_'+u+'_'+this.fno+'" value="'+w+'" /><label for="'+u+'_'+this.fno+'" class="css-check" tabindex="0">'+f+'</label>':'<a href="'+a['href'][0]+'" target="_blank">'+f+'</a>' )+'</div></div>\n</div>\n'; 
}
return s;
},

addfolderF: function(a,b,c,d){
var i,g = 0,j = 0,m = 0,r = '',s = '';
Object.keys(a).sort(G.library.sortF).each(function(z,i){  //console.log('key ',i,' = ',z);
if( z != 'is_group' ){
if( a[z]['path'] ){ //console.log('path ',a[z]['path']);
s+= this.addfileF(a[z],'full');
} else {
if( b < 1 || a[z]['is_group'] ){ //console.log('group ',a[z]['is_group'],' == ',d,' = ',b);
s+= ( (b < 1 || a[z]['is_group'] != d)?'<div class="column tt_accordion librarylevel'+b+'">\n':'' )+'<input id="toggle'+c+'_'+b+'_'+i+'" name="accordion'+b+'_'+i+'" type="radio" /><label for="toggle'+c+'_'+b+'_'+i+'"><p>'+z.pageStr().ucStr()+'</p></label>\n<div class="row editblock">\n'+( this.addfolderF(a[z],b+1,c+'_'+i,a[z]['is_group']) )+'\n</div>\n'+( (b < 1 || a[z]['is_group'] != d)?'</div>\n':'' );
}
}
} },this);
return s;
},

addimageF: function(a,b){ var p = ( a['image'] )?a['image']:G.library.defimg;return '<div class="editimage"><p><a '+( (b)?'href="'+a['href']+'" target="_blank"':'' )+'style="background-image:url('+p+');">&#160;</a></p></div>'; },
addtextF: function(a,b){ b = b || 'text';var d = a[b],h = "";if(d){ h+= ( d[0] )?'<div class="librarygrouptext">'+d[0]+'</div>\n':'';h+= ( d[1] )?'<div class="librarygrouptext">'+d[1]+'</div>\n':''; }return h; },
buildF: function(a,b){ var i,s = '',t = '<div class="row editblock"><div class="edittext">'+( (b)?'<p class="librarytitle">'+b+'</p>':'')+'</div></div>\n';if( this.options['format'] == 'library'){ console.log('build Library: ',this.el,' = ',a[0]);s+= this.addfolderF(a[0],0,'','');this.el.set('html','<form id="cgi_form_'+this.fno+'" method="post" accept-charset="UTF-8" action="'+E.cgiurl+'email.pl"><fieldset><div class="column tt_accordion">\n'+t+s+'\n<div></fieldset></form>\n');if(this.ftarget){ this.el.getElements('input[type=checkbox]').attachMe({'change':function(e){ var t = $(e.target),v;v = t.getProperty('value');if(t.checked){this.files.include(v);} else {this.files.erase(v);}this.ftarget.setProperty('value',this.files.join('||'));console.log('files: ',this.ftarget.getProperty('value')); }.bind(this) }); } } else { console.log('build listing: ',this.el,' = ',a); } },
displayF: function(a){ var ff,t = this.el.getElement('input[value='+a+']');ff = function(fa){ var fp,fr;fa.checked = true;console.log('display: ',fa);fp = fa.getParent('div.editblock');if(fp){ fr = fp.getPrevious('input[type=radio]');if(fr){ff(fr);} } };if(a && t){ this.files.include(a);this.ftarget.setProperty('value',this.files.join('||'));console.log('files: ',this.ftarget.getProperty('value'));ff(t);t.scrollMe(); }},
sendF: function(a,b,c,d,e){ var ff = function(){ a.setProperty('html',c); }.bind(this),s = '',n,o,q;b['js'] = 1;b['cache'] = ( new Date().getTime() )+(parseInt(Math.random()*100)).toString();o = Object.toQueryString(b);n = new Request.JSONP({ url:((b.url == 'dropbox.pl')?E.cgiurl+b.url:E.cgiurl+G.library.cgi),data:o,noCache:true,onRequest: function(){ if(!e){a.setStyles({'background':''}).empty().timerMe();} }.bind(this),onComplete: function(ca){ var cf;a.timerMe('hide');if( typeOf(ca) == 'object' && typeOf(ca.query) == 'object' ){ if(ca.query.error){ console.log('view error: ',ca.query.error); } else if(ca.query.debug){ console.log('view debug: ',ca.query.debug); } else if(ca.query.data){ cf = 1;d(ca.query.data); } else { console.log('received invalid '+typeOf(ca.query)+': ',ca.query); } } else { console.log('received invalid '+typeOf(ca)+': ',ca); }if( !cf ){ ff(); } }.bind(this),onFailure:ff,onTimeout:ff }).send(); }
});