//#editthis version:8.2.2 EDGE
Object.append(G.slideshow,{
css:null,
defs: [ ], 
formats: [''], 
hid:false, 
htmcloser: '&#215;', 
htmfunc: function(a){ console.log('slideshow ',a,' loaded'); }, 
htmclimit: 150, 
htmnav: '<a class="navslideprev" title="previous">&#60;</a><a class="navslidenext" title="next">&#62;</a>', 
htmtlimit: 70,
init: [],
initF: function(){ G.slideshow.inited = 1; },
loadF: function(){ if( !G.slideshow.css ){ G.slideshow.css = new Asset.css('slideshow.css',{ id:'slideshow',onLoad:G.slideshow.slideF }); } else { G.slideshow.slideF(); } },
slideF: function(){ console.log('Slideshow css loaded');$$('.slideshowarea').each(function(z,i){ G.slideshow.onF(z); }); }
});
var SlideshowCLS = new Class({
Implements: [Events,Options,Class.Occlude],
Binds: ['actF','controlF','holdF','pauseF','prepitemF','refreshF','retransF','sliderF','startitemF','unpauseF'],
property:'SSHOW',
options: { auto:null,controller:null,delay:3000,dselector:'tt_slideshow-el',format:'',hide:null,interval:1000,liselector:'tt_slideshow-inner',keepholder:null,key:null,showholder:null,start:0,startdelay:0,transition:'none' },
initialize: function(a,opts){
this.el = this.element = a;if( this.occlude() ){return this.occluded;}
this.setOptions(opts);
this.all = Array.combine(G.slideshow.trans,G.slideshow.transcls);
this.auto = this.options.auto;
this.c = this.options.controller;
this.delay = this.options.delay;
this.dselector = this.options.dselector;
this.items = [];
this.fm = (this.options.format != '')?this.options.format:null;
this.hold = false;
this.holder = this.el.getElement('.slideholder');
this.interval = this.options.interval;
this.keep = this.options.keepholder;
this.key = this.options.key;
this.liselector = this.options.liselector;
this.loop = null;
this.out = true;
this.outtimer = 0;
this.paused = null;
this.sdelay = this.options.startdelay;
this.showhold = this.options.showholder;
this.showgo = null;
this.showpause = null;
this.sindex = this.options.start;
this.slides = [],
this.timers = {};
this.transition = this.options.transition;
this.ty = (this.el.get('class').test(/overlayslide/))?'overlay':'slide';
this.v = ( E.safari && E.safari.test(/^safari (7|6|5|4|3)/) )?0:(E.capable == null)?0:(G.css3 && G.css3 > 0)?1:0;
this.controller,this.curslide,this.curitem,this.fired,this.index,this.nextslide,this.rest,this.starter,this.t;
if(this.el.getStyle('position') == 'static'){this.el.setStyle('position','relative');}
if(this.showhold && this.holder){ this.holder.addClass('tt_display'); }
if(this.c){ this.showpause = new Element('div',{'id':'slidepauser','class':'slidepause','html':'II'}).inject(this.el).addEvent('click',this.actF);this.showgo = new Element('div',{'id':'slidegoer','class':'slidego  tt_undisplay','html':'&gt;&gt;'}).inject(this.el).addEvent('click',this.actF); }
(function(){ if(this.v > 0){ this.buildF(); } }).delay(this.sdelay,this);
},

buildF: function(){
var c = [],d,f,g,h,i,j,k,m,n1,o,o1,p,q,r,r1,s,t,t1,u,v,w,w1,x,y,y1;
if(this.v < 1){ this.el.addClass('incapable') }if(this.fm){ this.el.addClass(this.fm); }if(this.c){ this.controller = new Element('li',{'class':'controller'}).inject(this.el);new Element('div',{'class':'controlwrapper'}).inject(this.controller); }c = this.el.getChildren('.'+this.liselector);
c.each(function(z,i){ 
w = z.attriMe();k = (this.key && w.slidekey)?w.slidekey:(this.key)?'Slide '+(1+i):'';y = (w.interval)?w.interval.toInt():(this.interval)?this.interval.toInt():1000;z.store('ss-wait',y);y = y.cssStr();t = (w.transition)?w.transition:'none';r = (w.delay)?w.delay.toInt():this.delay.toInt();z.store('ss-hold',((w.hold)?w.hold.toInt():0));
z.store('ss-delay',r);r = r.cssStr();z.addClass('css-'+y+'s').addClass('css-delay'+r).store('ss-transition',t);if(!w.list){z.setAttribute('data-list','s'+this.items.length);}
if(this.c){ new Element('span',{'class':'slidecontrol','data-number':this.items.length,'text':k}).inject(this.controller.getElement('.controlwrapper')).trueclickMe(null,null,this.controlF); }
this.imageF(z.getElement('.editimage > .text'));
if(i == this.sindex){this.index = this.items.length;this.curslide = z;this.curitem = z;}
this.slides.push(z);this.items.push(z);
u = z.getElements('.'+this.dselector);if(u && u.length && u.length > 0){ u.each(function(z1,i1){ 
z1.erase('style');w1 = z1.attriMe();y1 = (w1.interval)?w1.interval.toInt():this.interval.toInt();z1.store('ss-wait',y1);y1 = y1.cssStr();t1 = (w1.transition)?w1.transition:'none';r1 = (w1.delay)?w1.delay.toInt():this.delay.toInt();z1.store('ss-hold',((w1.hold)?w1.hold.toInt():0));
z1.store('ss-delay',r1);r1 = r1.cssStr();z1.addClass('css-'+y1+'s').addClass('css-delay'+r1).store('ss-transition',t1);if(!w1.list){z1.setAttribute('data-list','s'+this.items.length);}if(w1.hide){ z1.store('ss-hide',w1.hide); }this.items.push(z1); },this); }
},this);
if(this.curslide){
this.nextslide = this.slides[this.slides.goAr(this.curslide)];
G.slideshow.init.push(this);
if(this.auto){ this.visibleF();this.loop = 1;}
G.defrefresh.push(this.el);this.el.attachMe({ 'refresh':this.refreshF });
if(G.slideshow.htmfunc && typeOf(G.slideshow.htmfunc) == 'function'){ G.slideshow.htmfunc(this.el); }
if(!this.keep){this.startitemF(this.index,'init');}
}
},

actF: function(e){
var t;if(typeOf(e) == 'element'){ t = e; } else {G.stopG(e);t = $(e.target); }
var g = this.el.getElement('#slidegoer'),p = this.el.getElement('#slidepauser');
if(t == g){
p.vizMe(null,function(){g.addClass('tt_undisplay');console.log('act = unpause');this.outtimer = 0;this.unpauseF();}.bind(this));
} else {
g.vizMe(null,function(){p.addClass('tt_undisplay');console.log('act = pause');this.outtimer = 1;this.pauseF();}.bind(this));
}
},

controlF: function(e){ G.stopG(e);
var f,s,t = $(e.target),x;this.hold = true;if(t && !t.hasClass('active')){ f = t.getAttribute('data-number');if(f){
this.loop = null;
if(this.ty == 'slide'){
this.curslide = this.items[f];s = this.slides.indexOf(this.curslide);this.nextslide = this.slides[this.slides.goAr(s)]; //console.log('controlF hold: ',this.hold,' paused:',this.paused,' f:',f,' s:',s,' curslide:',this.curslide.getAttribute('data-list'),' nextslide:',this.nextslide.getAttribute('data-list'));
this.actF(this.el.getElement('#slidepauser'));
this.startitemF(f,'init');
} else {
s = this.items.goAr(f,1);this.prepitemF(s,'control');
}
} } 
},

imageF: function(a){ var g,p = '',s = [];if(a){ p = a.getStyle('background-image');if(p && p.test( /url\((.+)\.(gif|jpg|png)\)/i ) ){ s = [ RegExp.$1,RegExp.$2 ]; }if(s[0]){ if( s[0].test(/_mobile$/i) ){ if(E.width != 'mobile' ){p = p.replace(/_mobile\./i,'.');g = 1;} } else { if(E.width == 'mobile' ){p = 'url('+s[0]+'_mobile.'+s[1]+')';g = 1;} } }if( g || typeof( a.retrieve('slideimg') ) === 'undefined' ){ a.store('slideimg',p).erase('style').setStyle('background-image',p); } } },

pauseF: function(){ this.out = false;this.paused = (this.curitem == this.curslide)?2:1; //console.log('pause:',this.paused,' curitem:',this.curitem.getAttribute('data-list'),' curslide:',this.curslide.getAttribute('data-list'),' nextslide:',this.nextslide.getAttribute('data-list'));
if(this.controller){this.controller.addClass('paused');}this.curitem.getElements('li:not(.tt_undisplay) .tt_slider').addClass('tt_onview'); 
},

prepitemF: function(a,b){ 
var c = this.items.indexOf(a),d = a.retrieve('ss-hold') || 0,h = a.retrieve('ss-hide'),n,p,q,x; //console.log('prepitemF hold:',this.hold,' paused:',this.paused,' a:',a.getAttribute('data-list'),' curslide:',this.curslide.getAttribute('data-list'),' next:',this.nextslide.getAttribute('data-list'));
n = this.items.goAr(c);q = this.items[n];if( q.hasClass(this.dselector) ){p = 'element';}
x = b || p || this.rest || this.loop == 1 || null; //console.log('prepitemF: ',this.index,'/',this.curitem,' x = ',' b:',b,' or p:',p,' or rest:',this.rest,' or loop:',this.loop,' last:',a);
if( this.hold == false && this.paused && this.paused < 2 && a.hasClass(this.liselector) ){ //console.log('prepitem hold:',this.hold,' paused a:',a.getAttribute('data-list'),' curslide:',this.curslide.getAttribute('data-list'),' nextslide:',this.nextslide.getAttribute('data-list'));
return; 
} else {

if(x){
(function(){
this.index = n;this.curitem = q;
if(!this.auto){this.rest = this.curitem;}
if( a.hasClass(this.liselector) ){ 
if(this.ty == 'slide' && this.paused == 2){this.paused = 1;console.log('prep paused = ',this.paused);}
if(this.holder && !this.keep){ this.holder.addClass('op0').destroy();this.holder = null;}this.resetF(a,b); 
} else { p = 'next';if(b){this.resetF(a,b);}if(h){ (function(){a.addClass('op0');}).delay(h,this); } 
}
if( p || this.rest || this.loop == 1 ){if(this.rest){this.loop = null;if(!p || p != 'element'){this.rest = null;}}if(q != this.fired){this.startitemF(this.index,b);}}
}).delay(d,this);
} 

}
},

refreshF: function(){ this.el.unclassMe('ss_desktop ss_tablet ss_mobile').addClass('ss_'+E.width); return this; },
retransF: function(a){ a.each(function(z,i){ var t = z.retrieve('ss-transition');z.removeClass('css-active');if(t){z.removeClass('css-'+t);}this.retransF( z.getElements('.'+this.dselector) ); },this); },
resetF: function(a,b,c){ this.slides.each(function(z,i){ if( z == a || z.hasClass('css-active') ){ z.addClass('css-prev');if(b && b == 'unpause'){z.removeClass('tt_undisplay');} } else { z.addClass('tt_undisplay').removeClass('css-prev').removeClass('css-undelay');z.getElements('.'+this.dselector).addClass('tt_undisplay');} },this); },
sliderF: function(a){ if(this.hover && this.paused){var s = a.getElement('.slider');if(s){console.log('fire any sliders ',a,s);a.fireEvent('run');}}return this; },

startitemF: function(a,b){ 
var d,f,g,n = a,p = 0,t = [],x;f = this.items[n]; //console.log('startitemF: n:',n,' f:',f,' b:',b);
if( this.hold == false && this.paused && this.paused < 2 && f.hasClass(this.liselector) ){ 
f = this.items[this.items.goAr(f,1)];if( this.nextslide != f ){ this.nextslide = f; } //console.log('startitem paused f:',f.getAttribute('data-list'),' out:',this.out,' curslide:',this.curslide.getAttribute('data-list'),' nextslide:',this.nextslide.getAttribute('data-list'),' paused:',this.paused); 
this.hold = false;if(this.out == true){this.actF(this.el.getElement('#slidegoer'));}return; 
} else {

if(f){ //console.log('startitemF: n:',n,' f:',f.getAttribute('data-list'),' b:',b);
if( f.hasClass(this.liselector) ){ x = this.slides.indexOf(f);this.curslide = f;this.nextslide = this.slides[this.slides.goAr(x)];if(b){f.addClass('css-undelay');} //console.log('slides no:',x,' curslide is ',this.curslide.getAttribute('data-list'),' nextslide is ',this.nextslide.getAttribute('data-list'));
}
g = f.getAttribute('data-list');p = f.retrieve('ss-wait');t = [f.retrieve('ss-delay'),f.retrieve('ss-transition')];
if(t[1] && t[1] != 'none'){ 
if(b){t[0] = 0;} //console.log('add active ',g,' ',t[1],' after delay:',t[0],' then wait:',p,' [ ',b,' ]');
p+= t[0];f.addClass('css-'+t[1]).removeClass('tt_undisplay');f.addClass('css-active'); //console.log(f,' is active');
if( f.hasClass(this.dselector) && f.getElement('.'+this.dselector) ){
if(f != this.fired){this.fired = f;this.prepitemF(f);}
} else { 
(function(){ if( f.hasClass(this.liselector) ){ //console.log(' active ',g,'ended after ',p);
this.retransF( this.el.getElements('.'+this.liselector+'.css-prev') );this.upF(n);}this.prepitemF(f); }).delay(p,this); 
}
} else { if(this.loop == 1){this.prepitemF(f);} }//console.log('no active ',g,': ',f,n,p);
}

}
},

unpauseF: function(){
var n = this.nextslide;this.paused = null;this.out = true;if(this.controller){this.controller.removeClass('paused');}this.el.getElements('.tt_slider.tt_onview').removeClass('tt_onview');
if( this.loop < 1 || this.outtimer < 1 ){
if(this.hold == false){ //console.log('unpause hold ',this.hold,' curslide:',this.curslide.getAttribute('data-list'),'  nextslide:',n.getAttribute('data-list'));
if(this.auto){ this.loop = 1;this.upF(this.items.indexOf(n));this.prepitemF(n,'unpause'); } 
} else {
this.hold = false;n = this.items.indexOf(n); //console.log('unpause hold ',this.hold,' n: ',n,' curslide:',this.curslide.getAttribute('data-list'),'  nextslide:',this.nextslide.getAttribute('data-list'));
if(this.auto){ this.loop = 1;this.upF(n);this.startitemF(n,'init');}
}
} else {
console.log('no unpause = outtimer:',this.outtimer);
}
},

upF: function(a){ var g;if(this.controller){g = this.controller.getElement('span.slidecontrol[data-number='+a+']');this.controller.getElements('span.slidecontrol').removeClass('active');if(g){g.addClass('active');} }},
visibleF: function(){ var h,y;Object.each(G.slideshow.kch,function(v,k){ if(k in document){ if(!y){h = k;y = v;G.slideshow.hid = document[h];} }});if(h){ document.addEventListener(y,function(){ if(G.slideshow.hid != document[h]){ if(document[h]){G.slideshow.hid = true;this.actF(this.el.getElement('#slidepauser'));} else {G.slideshow.hid = false;this.actF(this.el.getElement('#slidegoer'));}G.slideshow.hid = document[h]; } }.bind(this)); window.onblur = function(){ if(G.slideshow.hid == false){ G.slideshow.hid = true;this.actF(this.el.getElement('#slidepauser')); } }.bind(this);window.onfocus = function(){ if(G.slideshow.hid == true){ G.slideshow.hid = false;this.actF(this.el.getElement('#slidegoer')); } }.bind(this); } } //console.log('new tab: page is hid: ',G.slideshow.hid,' == ',document[h]);
});