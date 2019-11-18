//#editthis version:8.2.0+
if(!G.console){

G.console = {
active: null,
initG: function(a){ a = a || "",p = ($('tt_debugger')) || new Element('ul',{'id':'tt_debugger','class':'area debugarea'}).inject($(G.all));if(p){ if(!G.console.active){ G.console.el = new Element('div',{ 'class':'row editmodule console' });G.console.fake = new Element('div',{'class':'tt_fakelog'}).inject(G.console.el);
p.empty().adopt(new Element('li',{'html':'<div class="row editblock"><div class="edittitle"><div class="text"><span style="font-size:140%;">Debug Panel</span></div></div></div><div class="row editmodule consoletop"><a class="consoleclear" href="javascript:G.console.clearG();" title="clear data">clear panel</a> <a class="consolesend" href="javascript:G.console.sendG();" title="send debug data for analysis">send panel data</a></div><div class="row editmodule consolepad">&#160;</div>'}).adopt(G.console.el) );G.console.active = 1; }G.console.updateG(a); } },
clearG: function(){ G.console.fake.set('html',''); },
el: null,
fake: null,
info: null,
log: null,
sendG: function(){ if(G.console.track){ var q = E.bug || { 'debug':'debug not set' },snk;q = Object.toQueryString( Object.merge(q,{ 'type':'track','ref':'Debug-Data','data':G.console.fake.get('html') }) );var snk = new Request.HTML({url:G.console.track,data:q,append:G.console.fake,noCache:true,onSuccess:function(tree,els,htm,js){ G.console.updateG(htm); }.bind(this),onTimeout:G.console.updateG.pass(['timeout']),onFailure:G.console.updateG.pass(['failed']) }).post(); } },
splitG: function(a){ var i,s = '';if(a){ for(i=0;i<a.length;i++){ if( a[i] && typeOf(a[i]) == 'element'){ s+= console.info(a[i]); } else if( a[i] && typeOf(a[i]) == 'object' ){ s+= '{ ';Object.each(a[i],function(v,k){ s+= k+' = '+v+',' });s+= s.replace(/,$/,'');s+= ' }'; } else if( a[i] && typeOf(a[i]) == 'array'){ s+= '[ '+a[i].join(',')+' ]'; } else { s+= (a[i])?a[i]:''; }s+= '<br />'; }return s+'<br />'; } else {return '';} },
t: [
'.debugarea { margin-bottom:40px; padding:20px; }',
'.debugarea .row .edittitle h1 { color:#f90; padding:10px 0; }',
'.debugarea .editmodule.consoletop { width:100%; height:36px; background:#f90; text-align:right; border-left:2px solid #f90; border-right:2px solid #f90; clear:both; float:left; }',
'.debugarea .editmodule.consoletop a { display:inline-block; width:100px; height:36px; line-height:300%; color:#fff; text-align:center; border-left:1px solid #fff; padding:0; }',
'.debugarea .editmodule.consoletop a.consoleclear { margin-right:-1px; }',
'.debugarea .editmodule.consoletop a:hover { color:#000; background-color:#fc0; }',
'.debugarea .editmodule.consolepad { width:100%; height:20px; background:#ffe; border-left:2px solid #f90; border-right:2px solid #f90; clear:both; float:left; }',
'.debugarea .editmodule.console { position:relative; width:100%; min-height:210px; height:20vh; max-height:440px; color:#333; background:#ffe; border:2px solid #f90; border-top:0; padding:0 20px 20px; overflow-x:hidden; overflow-y:auto; }',
'.debugarea .editmodule.console .tt_fakelog { height:100%; font-size:120%; line-height:130%; border-bottom:20px #ffe solid; overflow-y:auto; overflow-x:hidden; }'
].join('\n'),
track: ( (E.servertrack && E.servertrack.test(/^pe/))?E.cgiurl:'//thatsthat.co.uk/cgi-bin/' )+'debug.pl',
updateG: function(a){ var b = a || "",f = '';f = G.console.fake.get('html')+b;G.console.fake.set('html',f).scrollMe();G.console.fake.scrollTop = G.console.fake.scrollHeight; }
};
G.styleG(G.console.t);
G.console.log = window.console.log;window.console.log = function(){ var a = G.console.splitG(arguments);G.console.initG(a);G.console.log.apply(window.console,arguments); };
G.console.info = window.console.info;window.console.info = function(){ var a = arguments[0] || null,d = [],s = '';if(a && typeOf(a) == 'element'){ d = [ $(a).getProperty('id'),$(a).getProperty('class') ];s = '&#60;'+$(a).get('tag')+' '+( (d[0])?'id="'+d[0]+'"':'' )+' '+( (d[1])?'class="'+d[1]+'"':'' )+'&#62;<br />'; }G.console.initG(s);G.console.info.apply(window.console,arguments); };
}
