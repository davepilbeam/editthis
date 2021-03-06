//#editthis version:8.2.2 EDGE
Object.append(G.swiper,{
defs:{
contentclass: 'z-swipe-content',
itemclass: 'z-swipe-item',
wrapclass: 'z-swipe-wrap',
current: 1,
duration: 0.8,//
minpercent: null,
autoplay: 'on',
direction: 'left',
events: [ 'tap','sort','slideend','sortend','swipestart','swipe','swipeend' ],
interval: 5
},
css:null,
initF: function(){ G.swiper.inited = 1; },
loadF: function(){ G.swiper.swipeF(); },
swipeF: function(){ console.log('Swiper css loaded');$$('.swiperarea').each(function(z,i){ G.swiper.onF(z); }); }
});
var SwiperCLS = new Class({
Implements:[Class.Occlude,Events,Options],
Binds:[ ],
property:'SWIPER',
options: { autoplay:G.swiper.defs.autoplay,current:G.swiper.defs.current,duration:G.swiper.defs.duation,direction:G.swiper.defs.direction,id:'',interval:G.swiper.defs.interval,minpercent:G.swiper.defs.minpercent,nav:null,tap:null,sort:null,slideend:null,sortend:null,swipestart:null,swipe:null,swipeend:null },
initialize:function(a,b,opts){
this.el = this.element = a;if( this.occlude() ){return this.occluded;}
this.target = b;
this.wrapclass = G.swiper.defs.wrapclass;
this.contentclass = G.swiper.defs.contentclass
this.itemclass = G.swiper.defs.itemclass;
this.setOptions(opts);
this.sl = this.el.getChildren();
this.wrap = this.el.getElement('.'+this.wrapclass) || new Element('li',{'class':this.wrapclass}).inject(this.el,'top');
if(this.wrap){
this.zcontent = new Element('ul',{'class':this.contentclass}).inject(this.wrap,'top').adopt(this.sl);
this.slides = this.zcontent.getChildren();$$(this.slides).each(function(z,i){z.disableMe().addClass('tt_unselect '+this.itemclass+' z-item'+i);},this);
this.hold = false;
this.num = $$('ul.swiperarea').length || 1;this.wrap.setProperty('id','swiper'+this.num);
if(this.options.id != ''){ this.el.addClass(this.options.id); }
if(this.options.nav && this.options.nav == 'on'){ this.wrap.addClass('z-swipe-nav'); }
this.options.autoplay = (this.options.autoplay && this.options.autoplay == 'on')?true:false;
this.options.minPercentToSlide = (this.options.minpercent && this.options.minpercent > 0)?this.options.minpercent:null;
if(this.options.current > 0){this.options.current--;}
this.zslider = new Slider(this.wrap,'.'+this.itemclass,this.options);
this.wrap.addEventListener('mouseenter',function(e){ this.zslider.hold(); }.bind(this));
this.wrap.addEventListener('mouseleave',function(e){ this.zslider.restart(); }.bind(this));
G.swiper.defs.events.each(function(z,i){ var n = this.options[z];if( n && this.options[n] && typeOf(this.options[n]) == 'function' ){ this.wrap.addEventListener(n,this.options[n]); } },this); //function(e){ console.log(e.type,' = yes, time:'+Date.now()); }
this.el.addClass('css-active');
}
}
});
//https://github.com/creeperyang/zSlider ==pilbeam replace z-slide- with z-swipe-
"use strict";!function(a,b){"function"==typeof define&&define.amd?define([],b):"object"==typeof exports?module.exports=b():a.Slider=b()}(this,function(){function a(a,c,d){var e,f,g,h,k;if(!a||!c)return console.error("Slider: arguments error."),this;if(e="string"==typeof a?document.querySelector(a):a,!e)return console.error("Slider: cannot find container."),this;if(f="string"==typeof c?e.querySelectorAll(c):c,!f||!f.length)return console.error("Slider: no item inside container."),this;k=this,d=d||{};for(var l in b)void 0===d[l]&&(d[l]=b[l]);f=Array.prototype.slice.call(f),g=f.length,1!==g&&(h=e.clientWidth,this.options=d,this.compareDistance=0,this.timeId=null,this.width=h,d.minPercentToSlide&&(this.compareDistance=h*d.minPercentToSlide),i(this,e,f,g,d.current,h),j(this,"z-swipe-indicator","z-swipe-dot",this.realCount||g,this.current,"active"),p(this,m,n,o),window.addEventListener("resize",function(){q(k)},!1),d.autoplay&&(this.interval=Math.max(2e3,1e3*d.interval),this.autoplay()))}var b={current:0,duration:.8,minPercentToSlide:null,autoplay:!0,direction:"left",interval:5},c=function(a){setTimeout(a,0)},d=function(a){return a.charAt(0).toUpperCase()+a.slice(1)},e=function(a){function b(b){if(b in a)return{prop:b,prefix:c[1]};b=d(b);for(var g,h,i=0;i<f;i++)if(g=e[i]+b,g in a){h=c[i];break}return{prop:g,prefix:h}}var c=["-moz-","-webkit-","-o-","-ms-"],e=["Moz","Webkit","O","ms"],f=c.length;return function(a,c,d){var e=b(c);a.style[e.prop]=d,d&&(a.style[e.prop]=e.prefix+d)}}(document.body.style),f=function(a,b,c){var d;return d=document.createEvent("Event"),d.initEvent(a,b,c),d},g=function(a,b,c,d,f,g){"undefined"==typeof d&&(d=""),"undefined"==typeof f&&(f=d),"undefined"==typeof g&&(g=f),e(a,"transition",d),e(b,"transition",f),e(c,"transition",g)},h=function(a,b,c,d,f){e(b,"transform","translate3d("+d+"px, 0, 0)"),e(a,"transform","translate3d("+(d-f)+"px, 0, 0)"),e(c,"transform","translate3d("+(d+f)+"px, 0, 0)")},i=function(a,b,c,d,f,g){var h,i,j,k,l=d;for(2===d&&(j=c[0].cloneNode(!0),b.appendChild(j),c.push(j),j=c[1].cloneNode(!0),b.appendChild(j),c.push(j),d=4),h=d-1,(f>h||f<0)&&(f=0),0!==f&&(c=c.splice(f,d-f).concat(c)),c[0].uuid=0,c[h].uuid=h,e(c[0],"transform","translate3d(0, 0, 0)"),e(c[h],"transform","translate3d(-"+g+"px, 0, 0)"),k=1;k<h;k++)i=c[k],i.uuid=k,e(i,"transform","translate3d("+g+"px, 0, 0)");a.container=b,a.list=c,a.realCount=l,a.count=d,a.current=f},j=function(a,b,d,e,f,g){var h,i=document.createElement("span"),j=document.createElement("div"),k=[];for(j.className=b||"z-swipe-indicator",i.className=d||"z-swipe-dot",h=1;h<e;h++)k.push(j.appendChild(i.cloneNode(!1)));k.push(j.appendChild(i)),k[f].className="z-swipe-dot "+g,a.indicatorWrap=j,a.indicators=k,a.container.appendChild(j),c(function(){j.style.left=(a.width-getComputedStyle(j).width.replace("px",""))/2+"px"})},k=function(a,b,c){a[b].className="z-swipe-dot",a[c].className="z-swipe-dot active"},l=function(a){var b,c=a.count-1,d=a.width,f=a.list,g=a.indicatorWrap;for(e(f[c],"transform","translate3d(-"+d+"px, 0, 0)"),b=1;b<c;b++)e(f[b],"transform","translate3d("+d+"px, 0, 0)");g.style.left=(d-getComputedStyle(g).width.replace("px",""))/2+"px"},m=function(a,b){b.options.autoplay&&clearTimeout(b.timeId)},n=function(a,b,c){var d=b.list,e=d[0],f=d[d.length-1],i=d[1];g(f,e,i,""),h(f,e,i,c,b.width)},o=function(a,b,c){var d;d=Math.abs(c)<b.compareDistance?"restore":c<0?"left":"right",b.slide(d,c),b.options.autoplay&&b.autoplay()},p=function(a,b,c,d){function e(a,b){return/touch/.test(a.type)?(a.originalEvent||a).changedTouches[0]["page"+b]:a["page"+b]}function g(a){if("touchstart"===a.type)q=!0;else if(q)return q=!1,!1;return!0}function h(c){!r&&g(c)&&(r=!0,k=e(c,"X"),l=e(c,"Y"),o=0,p=0,v=setTimeout(function(){t=!0},200),b(c,a),this.dispatchEvent(f("swipestart",!0,!0)),"mousedown"===c.type&&(c.preventDefault(),document.addEventListener("mousemove",i,!1),document.addEventListener("mouseup",j,!1)))}function i(b){var d;r&&(m=e(b,"X"),n=e(b,"Y"),o=m-k,p=n-l,t||u||s||(Math.abs(p)>10?(s=!0,d=f("touchend",!0,!0),this.dispatchEvent(d)):Math.abs(o)>7&&(u=!0)),u&&(b.preventDefault(),c(b,a,o),d=f("swipe",!0,!0),d.movement={diffX:o,diffY:p},w.dispatchEvent(d)),t&&(b.preventDefault(),d=f("sort",!0,!0),w.dispatchEvent(d)),(Math.abs(o)>5||Math.abs(p)>5)&&clearTimeout(v))}function j(b){var c;r&&(r=!1,u?(d(b,a,o),c=f("swipeend",!0,!0),c.customData={diffX:o,diffY:p},w.dispatchEvent(c)):t?(c=f("sortend",!0,!0),w.dispatchEvent(c)):!s&&Math.abs(o)<5&&Math.abs(p)<5&&("touchend"===b.type,c=f("tap",!0,!0),w.dispatchEvent(c)),u=!1,t=!1,s=!1,clearTimeout(v),"mouseup"===b.type&&(document.removeEventListener("mousemove",i),document.removeEventListener("mouseup",j)))}var k,l,m,n,o,p,q,r,s,t,u,v,w=a.container;w.addEventListener("mousedown",h,!1),w.addEventListener("touchstart",h,!1),w.addEventListener("touchmove",i,!1),w.addEventListener("touchend",j,!1),w.addEventListener("touchcancel",j,!1)},q=function(a){a.options.autoplay&&null!==a.timeId&&(clearTimeout(a.timeId),a.timeId=null),a.resizeTimeId&&clearTimeout(a.resizeTimeId),a.resizeTimeId=setTimeout(function(){a.width=a.container.clientWidth,a.options.minPercentToSlide&&(a.compareDistance=a.width*a.options.minPercentToSlide),l(a),a.options.autoplay&&a.autoplay()},200)};return a.version="0.0.1",a.defaults=b,
a.prototype.autoplay=function(){var a=this.interval,b=this;this.timeId=setTimeout(function(){b.slide(),b.autoplay()},a)},
a.prototype.hold=function(){var b = this;clearTimeout(this.timeId);b.options.autoplay = false}, //==pilbeam
a.prototype.restart=function(){var b = this;clearTimeout(this.timeId);b.options.autoplay = true;b.autoplay()}, //==pilbeam
a.prototype.slide=function(a,b){var c,d,e,i,j,l=this.list,m=this.current,n=this.count,o=this.width,p=this.options.duration;a=a||this.options.direction,b=b||0,"left"===a?(l.push(l.shift()),this.current=(m+1)%n,p*=1-Math.abs(b)/o):"right"===a?(l.unshift(l.pop()),this.current=(m-1+n)%n,p*=1-Math.abs(b)/o):p*=Math.abs(b)/o,d=l[0],e=l[n-1],i=l[1],c="transform "+p+"s linear","left"===a||"restore"===a&&b>0?g(e,d,i,c,c,""):("right"===a||"restore"===a&&b<0)&&g(e,d,i,"",c,c),h(e,d,i,0,o),2===this.realCount?(this.current=this.current%2,k(this.indicators,m%2,this.current)):k(this.indicators,m,this.current),j=f("slideend",!0,!0),j.slider=this,j.currentItem=d,this.container.dispatchEvent(j)},a});