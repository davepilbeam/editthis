
/*#editthis version:8.2.2 EDGE*/

var G = G || {};

Object.append(G,{
bsr:(window.navigator.pointerEnabled || window.navigator.msPointerEnabled)?4:(!!window.opera || navigator.userAgent.indexOf(' OPR/') >= 0)?3:('WebkitAppearance' in document.documentElement.style)?2:(document.all)?1:(window.InstallTrigger)?0:4,
css:['-moz-','-ms-','-webkit-','-o-',''], 
css3:0,
csstestG: function(a,b){ b = b || 'inherit';var d = G.css[G.bsr],f = d+a,g = new Element('div'),h = d+a+':'+b,j = a.replace(/-([a-z]|[0-9])/ig,function(a1,b1){return (b1+'').toUpperCase();}),k = a+':'+b,s;g.style.cssText = h+';'+k+';';G.css3 = ('CSS' in window && 'supports' in window.CSS && (window.CSS.supports(a,b) || window.CSS.supports(f,b)) )?1:('supportsCSS' in window && (window.supportsCSS(a,b) || window.supportsCSS(f,b)) )?1:( typeof g.style[j] === 'string' && g.style[j] !== '' )?1:( typeof g.style[a] === 'string' && g.style[a] !== '' )?1:( typeof g.style[f] === 'string' && g.style[f] !== '' )?1:0;if(G.css3 && G.css3 < 1){console.log('warning: no css3: ',j,':',g.style[j],' ',a,':',g.style[a],' ',f,':',g.style[f],' from ',g.style.cssText);} else {G.csstr = ('WebkitTransition' in document.documentElement.style) ?'webkitTransitionEnd':'transitionend';} },
isgesture:'ongesturestart' in window,
ispointer:window.PointerEvent || window.MSPointerEvent,
istouch:'ontouchstart' in window || (window.DocumentTouch && document instanceof DocumentTouch) || 'createTouch' in document || (navigator.MaxTouchPoints > 0) || (navigator.msMaxTouchPoints > 0),
caretgetG:function(a){ var c = 0;if(document.selection){ a.focus();var s = document.selection.createRange();s.moveStart ('character',-a.value.length);c = s.text.length;} else if (a.selectionStart || a.selectionStart == '0')c = a.selectionStart;return c; },
caretsetG:function(a,b){ if(a.setSelectionRange){a.focus();a.setSelectionRange(b,b);} else if (a.createTextRange){var r = a.createTextRange();r.collapse(true);r.moveEnd('character',b);r.moveStart('character',b);r.select();} },
elib:'../LIB/css/css_tt_edit/',
eloader:['L0.png','L1.png','L2.png','L3.png','L4.png'],
escrolladj:50,
safari:(navigator.vendor && navigator.vendor.indexOf('Apple') > -1 && !navigator.userAgent.match('CriOS'))?1:(Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0)?1:null,

alertG: function(a,b,c,d){ a = Array.convert(a);var ff,l,m = $('tt_modal'),t;ff = function(e){ G.stopG(e);m.removeClass(b);if(c && typeOf(c) == 'function'){c();}t.empty().set('html',m.retrieve('revert')); };t = m.getElement('.modal-container');if(m){ if(b){ l = m.getElement('#m-close');if(t && l){ l.attachMe({'click':ff});m.store('revert',t.get('html'));t.empty();$$(a).inject(t);m.addClass(b); } } else { if(t){ t.empty();$$(a).inject(t); } }if(d && typeOf(d) == 'function'){d();} } },
cacheG: function(){ return new Date().getTime()+(parseInt(Math.random()*100)).toString(); },
epullG: function(a,b,c,d){ var ff,q,u;if(b){ u = b.getParent('.mlist') || b.getParent('.text') || null;}c = Object.merge(c,{ 'cache':G.cacheG() });q = Object.toQueryString(c);ff = function(fa){ if(b){b.timerMe('hide');if(u && u.getElement('.tt_progress')){u.removeClass('tt_progress10');}}if( fa && typeOf(fa) == 'object' && fa.query && !fa.query.error ){ d(fa.query,'OK'); } else { d( {},(fa && typeOf(fa) == 'string')?fa:(fa && fa.query.error)?fa.query.error:'returned no data' ); } };var snk = new Request.JSONP({ url:a,data:q,noCache:true,onRequest:function(){ if( b && !b.hasClass('mapper') ){b.setStyles({'background':''}).empty();}if(b){b.timerMe();if(u){u.addClass('tt_progress10');}} }.bind(this),onComplete:ff,onFailure:ff,onTimeout:ff });snk.send(); },

invalidG: function(a){ 
var d = a.getParent('.inputline'),f = a.getParent('form'),g = a.getParent('form').getElement('.filtersource'),
ss = function(sa){ var sm = [];if(sa.get('tag') == 'select'){ sa.getChildren('option').each(function(z,i){ if( !z.get('value').test(/Templates-and-Guides/) ){ sm.push( z.get('value') );} }); } else { sm = sa.getProperty('value').split('|'); }return sm; },
ff = function(a){ var fj = '',fm = [],fs = 1,ft = [];if( a.getParent('.oneline') ){ ft = a.getParent('.oneline').getPrevious('.oneline').getElements('i');$$(ft).each(function(z,i){fj+= z.get('text');}); } else { fj = ( (a.getPrevious('i.ibefore'))?a.getPrevious('i.ibefore').get('text'):"" )+a.getProperty('value')+'.html'; }if(d.retrieve('original') != a.getProperty('value') && g){fm = ss(g);for(i=0;i<fm.length;i++){if( fm[i] == fj ){fs = null;}} } return fs; },
cc = function(a){ var cf,cm = [],cv = f.getElement('input[id^=new-parent]').value;if( a.getProperty('value').test(/^(ht|f)tp(s)*:\/\//) ){ cf = 'pass'; } else { if(cv = 'html'){cv = '';}if(g){ cm = ss(g);for(i=0;i<cm.length;i++){if( cm[i] == a.getProperty('value') ){cf = 'pass';}} } }console.log(a.getProperty('value'),' has:// ',' or found in ',cm,' ',cf);if(a.getProperty('value') == '' || cf != 'pass'){ a.setProperty('value',cv+f.getElement('input[id^=new-menuurl]').value.urlStr('out')+'.html');cf = 'pass'; }return cf; },
h = { 
'new-title_0':{'defs':[ 'New Page Title' ]},
'new-url_0':{'defs':[ 'New-Page-URL' ],'func':[ ff ]},
'new-menuurl_0':{'defs':[ 'New Menu Name' ],'func':[ ff ]},
'new-link_0':{'func':[ cc ]},
'new-name_0':{'defs':[ 'New Short Title' ]},
'new-sub-title_0':{'defs':[ 'New Subpage Title' ]},
'new-sub-url_0':{'defs':[ 'New-Subpage-URL' ],'func':[ ff ]},
'new-sub-link_0':{'func':[ cc ]},
'new-sub-name_0':{'defs':[ 'New Subpage Short Title' ]},
'new-analytics_gref_0':{'test':[ '^UA-([0-9]+)-([0-9]+)$' ]},
'new-date_0':{'func':[ function(a){ var m = a.getProperty('value').dateStr();return m; } ]},
'action_edit':{'test':['^\/\/']},
'method_edit':{'test':['^(get|post)$']}
},i,n = a.getProperty('id'),s = null;
if( h[n] ){ 
a.setProperty('value',a.getProperty('value').replace(/^(\s+|\-+)/,'').replace(/(\s+|\-+)$/,'') );
if(h[n]['defs']){ for(i=0;i<h[n]['defs'].length;i++){ if(a.getProperty('value').toLowerCase() == h[n]['defs'][i].toLowerCase() ){s = 1;} } } 
if(h[n]['test']){ for(i=0;i<h[n]['test'].length;i++){ var r = new RegExp(h[n]['test'][i],'i');if(!a.getProperty('value').toLowerCase().test(r) ){console.log( a.getProperty('value').toLowerCase(),' == ',r );s = 1;} } }
if(h[n]['func']){ for(i=0;i<h[n]['func'].length;i++){ if( !h[n]['func'][i](a) ){s = 1;} } } 
}
if( d && d.hasClass('unmenu') && !a.getProperty('value').test(/^[0-9][0-9][0-9](\.[0-9][0-9][0-9])*([0-9][0-9][0-9])*(\.([0-9]|[0-9][0-9]))*$/)  ){s = 1;}
return s; },

nanG: function(a,b){ var c = ( b && !isNaN(b) )?b:0;return ( a && !isNaN(a) )?a.toInt():c; },

presendG: function(e){ var d,f,g,oh = {},p,r,s,t,u = [];if(typeOf(e) == 'element'){f = $(e);} else {e.preventDefault();f = $(e.target);}
d = f.getElements('.deploy');g = $('destination_0');j = ($('opt_new_0'))?$('opt_new_0'):null;p = f.getProperty('action');s = f.getElement('input[type=submit]');//
console.log('presend: f:',f,' s:',s,' g:',g,' p:',p);
if(s && s.hasClass('directresponse')){
f.getElements('input,textarea,select').each(function(z,i){if( z.name && z.name.test(/^(pre|opt)/i)){if(z.type.test('select')){oh[z.name] = z.options[z.selectedIndex].value;} else if( z.type.test(/(checkbox|radio)/) ){if(z.get('checked') ){oh[z.name] = z.value;}} else {oh[z.name] = z.value;}} });t = ($$('.response_target')[0] || f);G.epullG(p,t,oh,function(sa,sb){ var sp;if(sa['result']){console.log('direct pull: ',sa,sa['result']);t.set('html',sa['result']);sp = t.getParent('.text');if(sp){sp.removeClass('sharealert');}} else {t.set('html','<h3>Search Results:</h3><div class="noresults">No results found.</div>');} });
} else {
if(s && !s.getProperty('class').test(/unsave|submitted/)){ if( !g && d && d.length > 0){G.alertG(new Element('div',{'class':'infotext','html':'<div class="tt_progress"><span class="bar"></span></div>Your download should start shortly..'}).addClass('tt_progress20'),'alertbox');f.submit();} else {u = s.getParent('.row');s.addClass('submitted');u.addClass('tt_progress15');u.getElement('.infotext').timerMe();f.submit();} }
}
},

rankG: function(a){ var c = [ 'up','down','in','out','add','remove'],d = a.getParent('.orderline'),j,m,n,p = a.getParent('.reorderparent'),q,r,w,y,y1,y2;
d.addClass('rankselected');
n = p.getChildren('.orderline');
Array.each(c,function(z,i){ if( a.hasClass('nav-'+z+'menu') ){r = z;} });
switch(r){
case 'add': m = $('body0').getElements('input[id^=checkfile]').length;w = d.cloneidMe(m).inject(d.getElement('.reorderparent'),'top').removeClass('rankselected').addClass('hidepage');y = w.getElement('input[id^=checkfile');if(y){ y1 = y.getProperty('value');y2 = y1.replace(/^(.+\|)/,'').replace(/\.(0|00)$/,'');y2 = y2+'.000.00';y.setProperty('id','checkfile'+y2).setProperty('name','opt_checkfile'+y2+'_0');if( y1.test(/^(.*?)(\.html\|).+$/) ){y1 = RegExp.$1;y.setProperty('value',y1+'_Index'+RegExp.$2+y2);w.getElement('label.editopen').set('text',y1.replace(/_/g,' ')+' Index');}y.rankMe(); }d.uprankMe(); break;
case 'remove': d.addClass('nonmenufolder').removeClass('menufolder').getElement('.reorderparent').empty();d.uprankMe(); break;
case 'up': q = n.goAr(d,1);w = (q >= n.length-1)?'after':'before';d.inject(n[q],w);n[q].getParent('.reorderparent').getElements('.orderline').uprankMe(); break;
case 'down': q = n.goAr(d);w = (q < 1)?'before':'after'; d.inject(n[q],w);n[q].getParent('.reorderparent').getElements('.orderline').uprankMe(); break;
case 'in': q = n.goAr(d);w = n[q].getElement('input[id^=used]');if(w && !w.checked){w.checked = true;}d.inject(n[q].getElement('.reorderparent'),'top');n[q].getParent('.reorderparent').getElements('.orderline').uprankMe(); break
case 'out': w = d.getParent('.orderline').getElement('input[id^=used]');d.inject(d.getParent('.orderline'),'before');if(w && w.checked){w.checked = false;}d.getParent('.reorderparent').getElements('.orderline').uprankMe(); break;
default: (function(){d.removeClass('rankselected');}).delay(1000); 
}
d.scrollMe();
},

stopG: function(a){ if(a && a.type){ a.preventDefault();if(a.stopImmediatePropagation){a.stopImmediatePropagation();}if(a.stopPropagation){a.stopPropagation();} }return a; },
viewportG: function(){return {x:(document.documentElement.clientWidth && document.documentElement.clientWidth > 0)?document.documentElement.clientWidth:screen.width,y:(document.documentElement.clientHeight && document.documentElement.clientHeight > 0)?document.documentElement.clientHeight:screen.height}; },
vp: null
});

Element.implement({ 
alltouchMe: function(a){
var ff = a.click,y = (G.ispointer)?'pointer':(G.istouch)?'touch':'mouse';this.removeEvents({'mouseenter':a.on,'mouseleave':a.off,'touchend':a.touch,'touchcancel':a.touch,'click':a.click});
if(y == 'pointer'){if(window.MSPointerEvent){ this.removeEventListener('MSPointerDown',a.pointer);this.removeEventListener('MSPointerLeave',a.pointoff);} else {this.removeEventListener('pointerdown',a.pointer);this.removeEventListener('pointerleave',a.pointoff);}}
switch(y){
case 'pointer': ff = a.pointer;if(window.MSPointerEvent){ this.attachMe({ 'mouseenter':a.on });this.addEventListener('MSPointerDown',a.pointer,false);this.addEventListener('MSPointerLeave',a.pointoff,false); } else { this.attachMe({ 'mouseenter':a.on });this.addEventListener('pointerdown',a.pointer,false);this.addEventListener('pointerleave',a.pointoff,false); } break;
case 'touch': ff = a.touch;this.attachMe({ 'touchend':a.pointer,'touchcancel':a.pointer }); break;
default: this.attachMe({ 'mouseenter':a.on,'mouseleave':a.off,'click':a.click });
}
this.attachMe({ 'fire':ff });
},

attachMe: function(a){ this.detachMe(a);this.addEvents(a);return this; },
attriMe: function(){ var p = {};Array.prototype.slice.call(this.attributes).forEach(function(z){ var n;if(z.name.test(/^data\-/i) ){ n = z.name.replace(/^data\-/,'');p[n] = z.value; } });return p; },

changeMe: function(a){ 
var k = (this.get('tag') == 'input' && this.getProperty('type') == 'text')?1:(this.get('tag') == 'textarea')?1:null;console.log('changeMe: ',a,k);
if(a){ 
if(k){ this.attachMe({'input':function(){ this.valueMe(a,null,'unsubmit'); }.bind(this) }); }this.valueMe(a,'init','unsubmit').failMe('init'); 
} else { 
if(k){ this.attachMe({'input':function(){ if( !this.getParent('div.nav-tag') ){this.checkinputMe();} }.bind(this) }); }this.checkinputMe('init').failMe('init'); 
}
this.attachMe({ 'change':function(){this.failMe();}.bind(this) }); 
},

checkinputMe: function(a){ var f = this.getParent('form');var h = 300,n,m,p = this.getParent('.inputline'),s,u;//console.log('check: ',a,p,' = ',p.getProperty('class'));
if( this.getProperty('type') == 'text' || this.get('tag') == 'textarea' ){ n = G.caretgetG(this);s = this.get('value');
if( p && p.hasClass('undate') ){ 
m = s.dateStr();if(m != null){this.setProperty('value',m);this.removeClass('tt_inputfail');} 
} else if( p && p.hasClass('unsearch') ){
//
} else {
if( !p || (!p.hasClass('unfolder') && !p.hasClass('unurl')) ){ s = s.replace(/_+/g,'-'); }s = s.replace(/[^a-zÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ-ÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ¿0-9 \/\-\&:;#\^_\(\)\[\]',=\?\.\~]/gi,'x');
if(p){ if( p.hasClass('unspace') || p.hasClass('unurl') ){ s = s.replace(/\s+/g,'-'); }if( p.hasClass('unspace') ){ s = s.replace(/\//g,'~').replace(/:/g,';').replace(/'/g,'^').replace(/\?$/,'^^').replace(/(\s+)$/,'').replace(/^(\s+)/,'').replace(/\.html$/,''); }if( p.hasClass('unmenu') ){ s = s.replace(/[^0-9.]/,''); }if( p.hasClass('inewurl') ){ u = p.getPrevious().getElement('.inewurl');if(u){u.set( 'text',this.getProperty('value').urlStr('out') );if(u.get('text').test(/[a-z0-9]+/i)){u.removeClass('empty');} else {u.addClass('empty');}} } }
if(s.length > h){s = s.substring(0,h);}this.setProperty('value',s.replace(/^overwrite$/,'over-write'));if( this.getProperty('value').test(/[a-z0-9]/i) ){this.removeClass('inputempty');} else {this.addClass('inputempty');}if(!a && this.get('tag') == 'input'){G.caretsetG(this,n);} 
}
}if(p){ this.valueMe(p,a); }return this; 
},

cloneidMe: function(a){ var x,w = this.clone(true,true);w.getElements('*').each(function(z,i){ ['id','name','for'].each(function(z1,i1){ x = z.getProperty(z1);if(x && x.test(/_([0-9]+)$/) ){z.setProperty(z1,x.replace(/([0-9]+)$/,a));} }); });return w; },
detachMe: function(a){ if( typeOf(a) == 'object'){ this.removeEvents(a); } else { Array.convert(a).each(function(z,i){ this.removeEvents(z); },this);}return this; },
dimMe: function(a){ var s,t,w = this.getStyle('width');if( w.test(/%$/) || w == '0px' || isNaN(w) ){t = [this.owMe()[0],this.ohMe()[0]];}s = this.measure(function(){ return [this.getComputedSize(),[ this.getStyle('margin-top').toInt(),this.getStyle('margin-right').toInt(),this.getStyle('margin-bottom').toInt(),this.getStyle('margin-left').toInt()],this.getPosition() ]; });var g = [ G.nanG(s[0]['border-top-width']),G.nanG(s[0]['border-right-width']),G.nanG(s[0]['border-bottom-width']),G.nanG(s[0]['border-left-width']) ],k = [ G.nanG(s[0]['padding-top']),G.nanG(s[0]['padding-right']),G.nanG(s[0]['padding-bottom']),G.nanG(s[0]['padding-left']) ];return {w:((t)?t[0]:s[0]['width']),h:((t)?t[1]:s[0]['height']),d:{bx:(g[1]+g[3]),by:(g[0]+g[2]),mx:(s[1][1]+s[1][3]),my:(s[1][0]+s[1][2]),px:(k[1]+k[3]),py:(k[0]+k[2])},m:s[1],b:g,p:k,u:((a)?this.styleMe(a):null),v:G.viewportG(),xy:[s[2].x,s[2].y] }; },
endMe: function(e){ G.stopG(e);var f;if(e.type.test(/animationend/i) ){ console.log('end: ',e.animationName,' = ',e.type);if( this.hasClass('css-fadeout') ){ this.addClass('tt_undisplay').removeClass('css-fadeout'); } else { this.removeClass('css-fadein'); }this.removeClass('css-active');f = this.retrieve('vizfunction');if( f && typeOf(f) == 'function'){console.log('fire f ',f);f();}}return this;},
failMe: function(a){ a = ( this.getParent('.tt_firstcheck') )?null:a;var p = this.getParent('.inputline'),v = this.getParent('form').getElement('label[for=new-url_0] + i.ibefore');if( !a ){ if( this.name.test(/^pre_/) ){ if( !this.value || !this.value.test(/[a-z0-9]+/i ) ){ this.addClass('tt_inputfail'); } else { if( G.invalidG(this) ){this.addClass('tt_inputfail');} else {this.removeClass('tt_inputfail');} } } else { if( this.value.test(/[a-z0-9]+/i) && G.invalidG(this) ){this.addClass('tt_inputfail');} else {this.removeClass('tt_inputfail');} } }if(p){this.valueMe(p);}
if( this.hasClass('newparent') && v ){ v.set('text',this.options[this.selectedIndex].value); }
return this; },

formMe: function(){ var k;this.getElements('input,select,textarea').inputMe();
this.getElements('label.tt_tabclick').rankMe().tabMe();this.getElements('a.tt_directupdate').each(function(z1,i){ z1.hrefsetMe().attachMe({ 'click':function(e){ 
G.stopG(e);var eh = $(e.target);var ep = eh.getParent('div.text'),er = eh.hasClass('nav-used'),et = (eh.getParent('div.issues'))?eh.getParent('div.issues'):eh.getParent('h2');ep.addClass('tt_progress10');if(er){et.timerMe();}
G.epullG(z1.retrieve('linkref'),((er)?null:et),{},function(sa,sb){ ep.removeClass('tt_progress10').removeClass('sharealert');if(sa['result'] && sa['result'].test(/restoreresult fixed/)){ep.removeClass('issues');}if(er){ et.timerMe('off');$$(et.getElements('.tt_resultwrap')).removeClass('op10').destroy();new Element('div',{'class':'tt_resultwrap css-move5','html':((sa['result'] != '')?sa['result']:"No matching results found.")}).inject(et).addClass('op10'); } else {et.set('html',sa['result']);}if( sa['restart'] ){ (function(){console.log('reloading page..');document.location.reload(true);}).delay(0); } }); } 
}); },this);return this;
},

growMe: function(a){ if(a){
if( a.hasClass('scrolled') ){ a.removeClass('scrolled').setStyle('height','auto'); } else { a.setStyle('height',(G.vp.y - 100)+'px').addClass('scrolled');a.scrollTop = a.scrollHeight;a.scrollMe(); }
}return this;},

hrefsetMe: function(a,b){ if( this.get('tag') == 'a'){ var h =  this.getProperty('href'),l = this.retrieve('linkref');if(!a){ if(h){this.store('linkref',h);if(!b){this.erase('href');}} } else { if(l){ this.setProperty('href',l);this.eliminate('linkref'); } } };return this; },
inputMe: function(a){ var t;if( this.getProperty('type') != 'submit' && this.getProperty('type') != 'hidden' && this.getProperty('name').test(/^(pre|opt)_/i) && !this.getProperty('readonly') ){ if(a){this.getParent('.inputline').store('original',a);t = this;};this.changeMe(t); }if( $('body0').hasClass('reorderpages') && this.get('id') && this.get('id').test(/^checkfile/) ){ this.rankMe(); } return this; }, 

ohMe: function(){ return this.measure(function(){ return [(this.offsetHeight && this.offsetHeight > 0)?this.offsetHeight:this.clientHeight,this.getPosition().y]; }); },
owMe: function(){ return this.measure(function(){ return [(this.offsetWidth && this.offsetWidth > 0)?this.offsetWidth:this.clientWidth,this.getPosition().x]; }); },
progMe: function(){ var p = this.getParent('h2');if(p){ p.timerMe();this.addClass('submitted').getParent('div.text').addClass('tt_progress10');} },
pxMe: function(){ var b = [this.owMe(),this.ohMe()],c = this.measure(function(){ return [ this.scrollWidth,this.scrollHeight,this.dimMe().m ] });return [ b[0][0],b[1][0],b[0][1],b[1][1],c[0],c[1],c[2] ];},
rankMe: function(){ if( $('body0').hasClass('reorderpages') ){ if( this.get('tag') == 'label' ){ this.touchMe(null,null,G.rankG.pass(this)); } else { var h = {},n = this.getNext('h2').getChildren('a.navblock'),v = this.value.split('|');h['url'] = v[0];h['parent'] = this.getParents('.reorderparent').length;h['rank'] = v[1];h['menu'] = this.getParent('.orderline').hasClass('menufolder');this.getParent('.orderline').store('rankinfo',h);$$(n).each(function(z,i){z.touchMe(null,null,G.rankG.pass(z));}); }} return this;},
scrollMe: function(a,b){ var j = G.escrolladj,p,t = (b)?b:$('body0'),r = b || this.viewMe(t);if( $('tt_topdiv') ){j+= $('tt_topdiv').dimMe().h;}p = this.getPosition(t).y;if(r){ var sc = new Fx.Scroll(t).start(0,((t != $('body0'))?p:(p < j)?j:p-j)).chain(function(){ if(a && typeOf(a) == 'function' ){a();} }.bind(this)); }return this; }, //console.log('scroll: ',t,' r:',r,' p:',p,' adj:',j);
submitMe: function(a){
var d = $('new-url_0'),f,g = $('before_new-sub-url_0'),h = $('menuname_0'),j = [],k = $('submenuname_0'),m = [],m1 = [],o = $('new-sub-url_0'),p,u = [ this.getElement('input[type=submit]'),$('tt_updateform-0_0'),$('tt_updateinput-0_0') ];
if(d){f = d.getPrevious('i.ibefore');}m = this.getElements('.tt_inputfail,.filterfail');m1 = this.getElements('.tt_changed:not(.tt_submitted)');if(u && u.length > 0){if(m.length && m.length > 0){p = null;} else { if(m1.length && m1.length > 0 ){p = 1;if(a){ if(a.get('id').test(/changed/)){ m1.each(function(z,i){j.push(z.get('id').replace(/_[0-9]+$/i,''));});} else {this.getElements('input[id^=checkfile]').each(function(z,i){j.push(z.getProperty('value')+"|"+z.getParents('.reorderparent').length);});}}}}if(d && f && g){g.set('text',f.get('text')+d.getProperty('value')+'_');}if(d && h){ h.setProperty( 'value',d.getProperty('value').pageoutStr() );}if(k && o){k.setProperty( 'value',o.getProperty('value').pageoutStr() );}if(p){if(a){a.setProperty('value',j.join('||'));}$$(u).removeClass('unsave');} else {if(a){a.setProperty('value','');}$$(u).addClass('unsave');} }
},
tabMe: function(){ this.attachMe({ 'keyup':function(e){ if(e && e.key && e.key == 'enter'){G.stopG(e);var n = $(this.getProperty('for'));if(n){ if(n.checked){n.checked = false;} else {n.checked = true;} } } }.bind(this) }); },
timerMe: function(a,b){ var t = G.etmr;if(a){ this.getElements('.tt_timeon,.tt_timemask').destroy(); } else { if(t && !this.getElement('.tt_timeon') ){ if(b){new Element('span',{'class':'tt_timemask'}).inject(this);}var n = t.clone().inject(this);n.addClass('tt_timeon').removeClass('tt_undisplay');} }return this; },
touchMe: function(a,b,c){ var n = function(){};var ff = { 'on':(a || n),'off':(b || n),'pointoff':(b || n),'pointer':(c || n),'touch':(c || n),'click':(c || n) };this.alltouchMe(ff);return this; },
transitionMe: function(a,b){ if(!b){ if(G.csstr){ this.addEventListener(G.csstr,a,false); }this.addEventListener( ((E.safari)?'webkitAnimationStart':'animationstart'),a,false );this.addEventListener( ((E.safari)?'webkitAnimationIteration':'animationiteration'),a,false );this.addEventListener( ((E.safari)?'webkitAnimationEnd':'animationend'),a,false ); } else { if(G.csstr){ this.removeEventListener(G.csstr,a); } }return this; }, //console.log(E.safari,' = ',this.retrieve('events'),' = ',G.csstr);
unclassMe: function(a){ this.className = this.className.replace(new RegExp('\\b('+a.replace(/\s+/g,'|')+')\\b','g'),' ').replace(/ +/g,' ').replace(/\s$/,'').cleanStr();return this; },

uprankMe: function(){ var ch= [],h = false,i = 0,j = [],k = this.retrieve('rankinfo'),m = this.getElement('h2 > label.editopen'),n = this.getNext(),o,p = this.getPrevious(),q,t,u = [ this.getElement('h2 > a.nav-addmenu'),this.getElement('h2 > a.nav-upmenu'),this.getElement('h2 > a.nav-downmenu'),this.getElement('h2 > .nav-inmenu'),this.getElement('h2 > .nav-outmenu') ],w = this.getElement('h2 > .reorderparent');
if(p){j.push( parseFloat( p.getFirst('input[id^=checkfile]').getProperty('id').replace(/checkfile/,'').replace(/_/g,'.')) );}
j.push( parseFloat( this.getFirst('input[id^=checkfile]').getProperty('id').replace(/checkfile/,'').replace(/_/g,'.')) );
if(n){ j.push( parseFloat(n.getFirst('input[id^=checkfile]').getProperty('id').replace(/checkfile/,'').replace(/_/g,'.')) );if( n.hasClass('menufolder') ){ u[3].removeClass('tt_undisplay'); } else { u[3].addClass('tt_undisplay'); }if( n.getParent('.reorderparent') && !n.getParent('.reorderparent').hasClass('row') ){ u[4].removeClass('tt_undisplay'); } else { u[4].addClass('tt_undisplay'); } }
if( this.hasClass('menufolder') ){ h = true;u[0].addClass('nav-removemenu').setProperty('title','delete all Subpages beneath this Page');m.setProperty('title','view Subpages');t = w.getChildren();if(!t || t.length < 1){ this.addClass('nonmenufolder').removeClass('menufolder'); }}
if( this.hasClass('nonmenufolder') ){ u[0].removeClass('nav-removemenu').setProperty('title','add Subpages beneath this Page');m.setProperty('title','no Subpages');t = w.getChildren();if(t && t.length > 0){ this.addClass('menufolder').removeClass('nonmenufolder'); }
if( this.getSiblings('.orderline').length > 0 ){ u[1].removeClass('unupmenu');u[2].removeClass('undownmenu'); } else { u[1].addClass('unupmenu');u[2].addClass('undownmenu'); }
}
//console.log(this,' == ',k,h,' and ',k['menu'],' == ',this.getParents('.reorderparent').length,' and ',k['menu'] !== h,' j = ',j );
if( k['menu'] !== h || k['parent'] !== this.getParents('.reorderparent').length ){ this.addClass('tt_changed');//console.log( 'changed 1 ',this,k,' >> ',k['menu'],' !== ',h,' or ',k['parent'],' !== ',this.getParents('.reorderparent').length ); 
} else { this.removeClass('tt_changed');o = j.length;if(o > 0){ while(i<o){ q = j[i]; while(j[++i]<q){ch.push(i);} }if( ch.length > 0 ){ this.addClass('tt_changed');//console.log( 'changed 2 ',this,j,' (',o,'> 0) = ',ch,' >> ',ch.length,' > 0' ); 
} else { this.removeClass('tt_changed'); } } }
this.getParent('form.sendable').submitMe($('new_0'));
(function(){this.removeClass('rankselected');}.bind(this)).delay(1000,this);
return this; },

valueMe: function(a,b,c){ var n = (a.hasClass('clipdata'))?'data'+this.getProperty('name'):'original',o,v = (this.get('tag') == 'textarea')?this.getProperty('value'):(this.get('tag') == 'select' && this.options[this.selectedIndex] )?this.options[this.selectedIndex].get('value'):(this.getProperty('type') && this.getProperty('type') != 'text')?this.getProperty('checked'):this.getProperty('value');if( !this.hasClass('nonsave') ){ if( b && !a.retrieve(n) ){ a.store(n,(this.getParent('.inputline.unvalue'))?"":v); } else { o = a.retrieve(n);if( !this.hasClass('tt_unchange') ){if(o !== v){this.addClass('tt_changed');} else {this.removeClass('tt_changed');}}if(!c){this.getParent('form.sendable').submitMe($('changed_0'));} } }return this; },
viewMe: function(a){ var r,t = this.pxMe();if( t[3] > G.vp.y-10 || t[3] < a.getScroll().y ){r = 1;}return r; }, //console.log('view: r:',r,' = ',t[3],' > ',G.vp.y-10,' or < ',a.getScroll().y);

vizMe: function(a,b){ //
console.log('check vizMe:',this,' = ',a,b);
if( !this.retrieve('vizfunction') ){this.store('vizfunction',b).transitionMe(this.endMe);}
if(a){this.addClass('css-fadeout'); } else {this.addClass('css-fadein').removeClass('tt_hidden').removeClass('tt_undisplay').addClass('css-05s');}this.addClass('css-active');
return this; 
},

});

Array.implement({
goAr: function(a,b){ var n = (typeOf(a) == 'element')?this.indexOf(a):a;var s = (b)?(n-1):(n+1),t = (this.length-1);var r =(s < 0)?t:(s > t)?0:s;return r; }
});

String.implement({
cleanStr: function(){ return this.toString().replace(/[^a-zÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ-ÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ¿0-9\[\]\/#\?:;\(\)%\^\._ \-\~]/gi,''); },
dateStr: function(){ var d = [],g = new Date(),y;y = g.getFullYear();if( this.toString().test(/^([0-9]+)\/([0-9]+)\/([0-9]+)$/) ){ d = [RegExp.$1,RegExp.$2,RegExp.$3];d[0] = d[0].nilStr();d[1] = d[1].nilStr();if(d[2].length == 2){d[2] = '20'+d[2];}if(d[0] < 1 || d[0] > 31 || d[1] < 1 || d[1] > 12  || d[2].toInt() < 1970 || d[2].toInt() > y){ return null;}} else {return null;}return d.join('/'); },
fragMe: function(a){ var f = document.createDocumentFragment(),t = document.createElement('div');t.innerHTML = a;while(t.firstChild){ f.appendChild(t.firstChild); }return f; },
nilStr: function(){var a = this.toString();if(a.length == 1 && a != '0'){a = '0'+a;}return a;},
urlStr: function(a){ var g = this.toString();if(!a){ g = g.replace(/\-/g,' ').replace(/\&amp;/g,'&').replace(/;/g,':').replace(/\^\^$/,'?').replace(/\^/g,"'").replace(/\s\s/g,'-').replace(/\~/g,'/'); } else { g = g.replace(/[^a-zÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ-ÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ¿0-9:\?\'\/\-\s_\&]/gi,'').replace(/:/g,';').replace(/'/g,'^').replace(/\?$/,"^^").replace(/^\s*/,'').replace(/\s*$/,'').replace(/\-/g,'--').replace(/\//g,'~').replace(/ /g,'-'); }return g; },
pageoutStr: function(){ return this.toString().replace(/\.html$/,'').replace(/:/g,';').replace(/^^$/,'?').replace(/\^/g,"'").replace(/\-\-/g,'==').replace(/\-/g,' ').replace(/==/g,'-'); },
wordStr: function(){ return this.toString().replace(/[\u2018|\u2019|\u201A]/g,"'").replace(/[\u201C|\u201D|\u201E]/g, '"').replace(/[\u2026|…]/g,'...').replace(/[\u2013|\u2014]/g,'-').replace(/\u02C6/g,'^').replace(/[\u02DC|\u00A0]/g,' ').replace(/[\u00A3|£]/g,'&#163;').replace(/[\u20AC|€]/g,'&#x20AC;') },
});

window.addEvent('domready',function(){
G.vp = G.viewportG();
G.csstestG('animation-name');
var tl = Asset.images([G.elib+G.eloader[0],G.elib+G.eloader[1],G.elib+G.eloader[2],G.elib+G.eloader[3],G.elib+G.eloader[4]],{ onComplete:function(){gl = '" style="background:transparent url(';hl = ') center no-repeat;"></span><span class="tt_loader';G.etmr = new Element('div',{'class':'tt_loader tt_undisplay','styles':{'background':'url('+tl[0].src+') center no-repeat'},'html':'<span class="tt_loader1'+gl+tl[1].src+hl+'2'+gl+tl[2].src+hl+'3'+gl+tl[3].src+hl+'4'+gl+tl[4].src+') center no-repeat;"></span>'}).inject($('body0'));} }); 
$$(document.getElements('form')).each(function(z,i){ 

if( z.hasClass('sendable') ){
z.formMe().addEvents({ 'click:relay(a.mlist-submit,a.mlist-delete,a.nav-infoalert)':function(e,el){

G.stopG(e);var c,f,l,n,o = {},p,q,s,t = $(el),tp,u = '',v = 1,w,y; //
console.log('mlist-submit ',t,e);
if(t){ 
if( t.hasClass('mlist-delete') ){
c = t.getPrevious('a');y = t.getPrevious('textarea');console.log('delete c:',c,' y:',y);if(c && y){y.set('text','').addClass('tt_changed');c.fireEvent('click',{'target':c});}
} else {
y = (t.getParent('.mapper'))?[ t.getPrevious('input') ]:t.getParent('.inputline')?t.getParent('.inputline').getElements('.tt_changed'):null;if(y && y[0]){f = y[0];}if(t.hasClass('refresh')){console.log('refresh: ',f,' l = ',l,' t = ',t,' q = ',q);}
if( t.hasClass('refresh') || f && !f.hasClass('tt_inputfail') ){
c = t.getNext('input[type=checkbox]');
l = t.getParent('.inputline.mapper') || t.getParent('.seo') || t.getParent('.tags') || t.getParent('.inputline').getPrevious('label') || null;w = (l && l.getAttribute('data-mref'))?l.getAttribute('data-mref'):null;if(f && f.get('id')){u = f.get('id').replace(/^(.*?)new\-/,'').replace(/_([0-9]+)$/,'');v = f.get('id').replace(/^.+_/,'');}s = w || u;tp = (w)?t.getParent('.inputline'):t.getParent('.mline');
p = (t.getParent('.inputline.mapper'))?f.getProperty('value'):(f.hasClass('protect'))?'restoreprotect':(f.hasClass('menu'))?'newmenupages':(f.hasClass('title') || f.hasClass('shortname') || f.hasClass('url') || f.hasClass('seo') || f.hasClass('tags') || f.hasClass('alias'))?'changeaddpages':(f.hasClass('glibrary'))?'changelibrarypages':(f.hasClass('clipdata'))?'getalterclips':(f.hasClass('gsection'))?'changesectionpages':'newtitlepages';
q = { 'class':( f.hasClass('seo')?'seo':f.hasClass('tags')?'tags':f.hasClass('title')?'title':u ),'type':p,'old':( (l && l.getElement('span'))?l.getElement('span').get('text'):'' ),'new':(t.getParent('.inputline.mapper'))?u:f.getProperty('value') };//console.log('url menu ',f,f.getProperty('class'),' l = ',l,' t = ',t,' q = ',q,' w = ',w);
if(w){ if(f.hasClass('seo') || f.hasClass('tags') || f.hasClass('title')){q['changed'] = 'new-'+u;q['new-'+u] = f.getProperty('value');} else if(f.hasClass('url')){q['changed'] = 'new-menuurl';q['new-menuurl'] = (( l && l.getNext('.inputline') && l.getNext('.inputline').getElement('.ibefore') )?l.getNext('.inputline').getElement('.ibefore').get('text'):"")+f.getProperty('value'); } else { if(f.hasClass('alias')){q['changed'] = 'new-link';q['new-link'] = f.getProperty('value');} } }
if(f.hasClass('gsection') || f.hasClass('clipdata') || f.hasClass('glibrary')){
new Element('input',{'type':'hidden','name':'opt_type_0','value':q['type']}).inject(t,'after');new Element('input',{'type':'hidden','name':'opt_'+s+'_0','value':s}).inject(t,'after');new Element('input',{'type':'hidden','name':'opt_new_0','value':q['new']}).inject(t,'after');f.getParent('form.sendable').getElements('*[id^=new-]').setProperty('disabled',true);f.getParent('form.sendable').submit();
} else {
if(w){o.speed = v;}o.url = (tp && f.hasClass('protect'))?tp.getAttribute('data-title'):encodeURIComponent(s);Object.merge(q,o);
if(c && c.checked){ 
new Element('input',{'type':'hidden','name':'opt_type_0','value':'newmenupages'}).inject(t,'after');new Element('input',{'type':'hidden','name':'opt_id_0','value':c.getProperty('value')}).inject(t,'after');new Element('input',{'type':'hidden','name':'opt_url_0','value':s}).inject(t,'after');new Element('input',{'type':'hidden','name':'opt_old_0','value':( (l && l.getElement('span'))?l.getElement('span').get('text'):'' )}).inject(t,'after');f.getParent('form.sendable').submit(); 
} else { 
//console.log('epullG t:',t,' f:',f,' tp:',tp,' q:',q);
G.epullG(f.getParent('form.sendable').getProperty('action'),tp,q,function(sa,sb){ var sf,sg = 'hidepage',sh,sk,sp = t.getParent('.text'),sr = (sb == 'OK')?sb:'FAILED',ss = "",st;
sf = function(sfa,sfb,sfc){ if(sfb){sk = sfb.getProperty('data-menu');console.log('sp = ',sp,' sk = ',sk);if(sk){sk = sk.replace(/\.(0|00)$/,'');sk+=sfa['menu'];sfb.setProperty('data-menu',sk);if( sk.test(/\.(0|00)$/) ){if( document.location.href.test(/editpages/) || sk.test(/000/) ){if(sk.test(/\.00$/)){sg = 'hidemappage';sfb.getParent('form.sendable').removeClass('hidepage');}sfb.getParent('form.sendable').addClass(sg);}sfb.removeClass('showpage').addClass('mhidepage');} else {if( document.location.href.test(/editpages/) || sk.test(/000/) ){sfb.getParent('form.sendable').unclassMe('hidepage hidemappage');}sfb.addClass('showpage').removeClass('mhidepage');}}}if(sfc &&sfa['label']){ sfc.set('html',sfa['label']); }return sfa['html']; };
if(sr == 'OK'){ if( sa['html'] ){ 
if( sa['field'] ){ ss = sa['html'];if(sa['field'] == 'new-date'){st = tp.getParent('.text');if(st){st.setAttribute('data-tagged','Date:'+sa['title']);}} else if(sa['field'] == 'new-title'){st = z.getElement('span.navtext');if(st){st.set('text',sa['title']);}} } else { ss = sf(sa,sp,tp.getPrevious('label')); } 
} else { 
Object.each(sa,function(v,k){ss+= '<span class="senddata">'+v+'</span>';}); 
} }if(tp){ tp.set('html',ss);tp.getElements('input,textarea').each(function(z1,i){z1.inputMe(z1.getProperty('value'));});if(sr != 'OK'){tp.addClass('sendfail');}} }); 
}
}
} } 
}

} });
z.getElements('.tt_expander').attachMe({ 'click':function(){this.growMe(this.getPrevious('textarea'));} }); 
z.attachMe({ 'submit':G.presendG });

}
z.addEvents({ 'click:relay(a.nav-show,a.nav-showmap,a.nav-foldershow,a.nav-infoalert,a.nav-hide,a.nav-hidemap,a.nav-folderhide,a.nav-addrestore)':function(e,el){el.progMe();} });
});
if( document.getElement('form.sendable .inputline > label') ){ document.getElement('form.sendable .inputline > label').scrollMe().focus(); }
$$('ul.area').addEvents({ 'click:relay(.tt_accordion > label)':function(e,el){var n = $(el).getNext('.editblock'),p = $(el).getPrevious('input');if(p && p.checked == true){G.stopG(e);p.checked = false;}} });
$('body0').removeClass('tt_unjs');
['pointer','touch'].each(function(z,i){ if( G['is'+z] ){$('body0').removeClass('tt_no'+z).addClass('tt_'+z);} });
$$('.m-pusher-container').removeClass('loading'); 
});
