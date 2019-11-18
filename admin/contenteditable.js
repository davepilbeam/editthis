
//#editthis version:8.1.0

(function(){

var ctor = function(){};var inherits = function(parent, protoProps){
var child;
if(protoProps && protoProps.hasOwnProperty('constructor')){
child = protoProps.constructor;} else {
child = function(){ return parent.apply(this, arguments); };}

ctor.prototype = parent.prototype;child.prototype = new ctor();
if(protoProps){extend(child.prototype, protoProps);}
child.prototype.constructor = child;child.__super__ = parent.prototype;return child;};
function extend(target, ref){
var name, value;for( name in ref ){
value = ref[name];if(value !== undefined){
target[ name ] = value;}
}
return target;};
var Undo;if(typeof exports !== 'undefined'){
Undo = exports;} else {
Undo = this.Undo = {};}

Undo.Stack = function(){
this.commands = [];this.stackPosition = -1;this.savePosition = -1;};
extend(Undo.Stack.prototype, {
execute: function(command){
this._clearRedo();command.execute();this.commands.push(command);this.stackPosition++;this.changed();},

undo: function(){
this.commands[this.stackPosition].undo();this.stackPosition--;this.changed();},

canUndo: function(){
return this.stackPosition >= 0;},

redo: function(){
this.stackPosition++;this.commands[this.stackPosition].redo();this.changed();},

canRedo: function(){
return this.stackPosition < this.commands.length - 1;},

save: function(){
this.savePosition = this.stackPosition;this.changed();},

dirty: function(){
return this.stackPosition != this.savePosition;},

_clearRedo: function(){
this.commands = this.commands.slice(0, this.stackPosition+1);},

changed: function(){
}
});
Undo.Command = function(name){
this.name = name;}

var up = new Error("override me!");
extend(Undo.Command.prototype, {
execute: function(){
throw up;},

undo: function(){
throw up;},

redo: function(){
this.execute();}
});
Undo.Command.extend = function(protoProps){
var child = inherits(this, protoProps);child.extend = Undo.Command.extend;return child;};
}).call(this);

(function(factory,root){
if(typeof define == "function" && define.amd){
define(factory);} else if(typeof module != "undefined" && typeof exports == "object"){
module.exports = factory();} else {
root.rangy = factory();}
})(function(){

var OBJECT = "object",FUNCTION = "function",UNDEFINED = "undefined";var domRangeProperties = ["startContainer","startOffset","endContainer","endOffset","collapsed","commonAncestorContainer"];
var domRangeMethods = ["setStart","setStartBefore","setStartAfter","setEnd","setEndBefore","setEndAfter","collapse","selectNode","selectNodeContents","compareBoundaryPoints","deleteContents","extractContents","cloneContents","insertNode","surroundContents","cloneRange","toString","detach"];
var textRangeProperties = ["boundingHeight","boundingLeft","boundingTop","boundingWidth","htmlText","text"];
var textRangeMethods = ["collapse","compareEndPoints","duplicate","moveToElementText","parentElement","select","setEndPoint","getBoundingClientRect"];
function isHostMethod(o,p){
var t = typeof o[p];return t == FUNCTION || (!!(t == OBJECT && o[p])) || t == "unknown";}

function isHostObject(o,p){
return !!(typeof o[p] == OBJECT && o[p]);}

function isHostProperty(o,p){
return typeof o[p] != UNDEFINED;}

function createMultiplePropertyTest(testFunc){
return function(o,props){
var i = props.length;while (i--){
if(!testFunc(o,props[i])){
return false;}
}
return true;};}

var areHostMethods = createMultiplePropertyTest(isHostMethod);var areHostObjects = createMultiplePropertyTest(isHostObject);var areHostProperties = createMultiplePropertyTest(isHostProperty);
function isTextRange(range){
return range && areHostMethods(range,textRangeMethods) && areHostProperties(range,textRangeProperties);}

function getBody(doc){
return isHostObject(doc,"body") ? doc.body : doc.getElementsByTagName("body")[0];}

var modules = {};
var isBrowser = (typeof window != UNDEFINED && typeof document != UNDEFINED);
var util = {
isHostMethod: isHostMethod,isHostObject: isHostObject,isHostProperty: isHostProperty,areHostMethods: areHostMethods,areHostObjects: areHostObjects,areHostProperties: areHostProperties,isTextRange: isTextRange,getBody: getBody
};
var api = {
version: "1.3.0-alpha.20150122",initialized: false,isBrowser: isBrowser,supported: true,util: util,features: {},modules: modules,config: {
alertOnFail: true,alertOnWarn: false,preferTextRange: false,autoInitialize: (typeof rangyAutoInitialize == UNDEFINED) ? true : rangyAutoInitialize
}
};
function consoleLog(msg){
if(typeof console != UNDEFINED && isHostMethod(console,"log")){
console.log(msg);}
}

function alertOrLog(msg,shouldAlert){
if(isBrowser && shouldAlert){
alert(msg);} else  {
consoleLog(msg);}
}

function fail(reason){
api.initialized = true;api.supported = false;alertOrLog("Rangy is not supported in this environment. Reason: "+reason,api.config.alertOnFail);}

api.fail = fail;
function warn(msg){
alertOrLog("Rangy warning: "+msg,api.config.alertOnWarn);}

api.warn = warn;
var extend;if({}.hasOwnProperty){
util.extend = extend = function(obj,props,deep){
var o,p;for(var i in props){
if(props.hasOwnProperty(i)){
o = obj[i];p = props[i];if(deep && o !== null && typeof o == "object" && p !== null && typeof p == "object"){
extend(o,p,true);}
obj[i] = p;}
}
if(props.hasOwnProperty("toString")){
obj.toString = props.toString;}
return obj;};
util.createOptions = function(optionsParam,defaults){
var options = {};extend(options,defaults);if(optionsParam){
extend(options,optionsParam);}
return options;};} else {
fail("hasOwnProperty not supported");}

if(!isBrowser){
fail("Rangy can only run in a browser");}

(function(){
var toArray;
if(isBrowser){
var el = document.createElement("div");el.appendChild(document.createElement("span"));var slice = [].slice;try {
if(slice.call(el.childNodes,0)[0].nodeType == 1){
toArray = function(arrayLike){
return slice.call(arrayLike,0);};}
} catch (e){}
}

if(!toArray){
toArray = function(arrayLike){
var arr = [];for(var i = 0,len = arrayLike.length; i < len;++i){
arr[i] = arrayLike[i];}
return arr;};}

util.toArray = toArray;})();
var addListener;if(isBrowser){
if(isHostMethod(document,"addEventListener")){
addListener = function(obj,eventType,listener){
obj.addEventListener(eventType,listener,false);};} else if(isHostMethod(document,"attachEvent")){
addListener = function(obj,eventType,listener){
obj.attachEvent("on"+eventType,listener);};} else {
fail("Document does not have required addEventListener or attachEvent method");}

util.addListener = addListener;}

var initListeners = [];
function getErrorDesc(ex){
return ex.message || ex.description || String(ex);}

function init(){
if(!isBrowser || api.initialized){
return;}
var testRange;var implementsDomRange = false,implementsTextRange = false;

if(isHostMethod(document,"createRange")){
testRange = document.createRange();if(areHostMethods(testRange,domRangeMethods) && areHostProperties(testRange,domRangeProperties)){
implementsDomRange = true;}
}

var body = getBody(document);if(!body || body.nodeName.toLowerCase() != "body"){
fail("No body element found");return;}

if(body && isHostMethod(body,"createTextRange")){
testRange = body.createTextRange();if(isTextRange(testRange)){
implementsTextRange = true;}
}

if(!implementsDomRange && !implementsTextRange){
fail("Neither Range nor TextRange are available");return;}

api.initialized = true;api.features = {
implementsDomRange: implementsDomRange,implementsTextRange: implementsTextRange
};
var module,errorMessage;for(var moduleName in modules){
if( (module = modules[moduleName]) instanceof Module ){
module.init(module,api);}
}

for(var i = 0,len = initListeners.length; i < len;++i){
try {
initListeners[i](api);} catch (ex){
errorMessage = "Rangy init listener threw an exception. Continuing. Detail: "+getErrorDesc(ex);consoleLog(errorMessage);}
}
}

api.init = init;
api.addInitListener = function(listener){
if(api.initialized){
listener(api);} else {
initListeners.push(listener);}
};
var shimListeners = [];
api.addShimListener = function(listener){
shimListeners.push(listener);};
function shim(win){
win = win || window;init();
for(var i = 0,len = shimListeners.length; i < len;++i){
shimListeners[i](win);}
}

if(isBrowser){
api.shim = api.createMissingNativeApi = shim;}

function Module(name,dependencies,initializer){
this.name = name;this.dependencies = dependencies;this.initialized = false;this.supported = false;this.initializer = initializer;}

Module.prototype = {
init: function(){
var requiredModuleNames = this.dependencies || [];for(var i = 0,len = requiredModuleNames.length,requiredModule,moduleName; i < len;++i){
moduleName = requiredModuleNames[i];
requiredModule = modules[moduleName];if(!requiredModule || !(requiredModule instanceof Module)){
throw new Error("required module '"+moduleName+"' not found");}

requiredModule.init();
if(!requiredModule.supported){
throw new Error("required module '"+moduleName+"' not supported");}
}

this.initializer(this);},

fail: function(reason){
this.initialized = true;this.supported = false;throw new Error("Module '"+this.name+"' failed to load: "+reason);},


warn: function(msg){
api.warn("Module "+this.name+": "+msg);},


deprecationNotice: function(deprecated,replacement){
api.warn("DEPRECATED: "+deprecated+" in module "+this.name+"is deprecated. Please use "+
replacement+" instead");},


createError: function(msg){
return new Error("Error in Rangy "+this.name+" module: "+msg);}
};
function createModule(name,dependencies,initFunc){
var newModule = new Module(name,dependencies,function(module){
if(!module.initialized){
module.initialized = true;try {
initFunc(api,module);module.supported = true;} catch (ex){
var errorMessage = "Module '"+name+"' failed to load: "+getErrorDesc(ex);consoleLog(errorMessage);if(ex.stack){
consoleLog(ex.stack);}
}
}
});modules[name] = newModule;return newModule;}

api.createModule = function(name){
var initFunc,dependencies;if(arguments.length == 2){
initFunc = arguments[1];dependencies = [];} else {
initFunc = arguments[2];dependencies = arguments[1];}

var module = createModule(name,dependencies,initFunc);
if(api.initialized && api.supported){
module.init();}
};
api.createCoreModule = function(name,dependencies,initFunc){
createModule(name,dependencies,initFunc);};

function RangePrototype(){}
api.RangePrototype = RangePrototype;api.rangePrototype = new RangePrototype();
function SelectionPrototype(){}
api.selectionPrototype = new SelectionPrototype();
api.createCoreModule("DomUtil",[],function(api,module){
var UNDEF = "undefined";var util = api.util;
if(!util.areHostMethods(document,["createDocumentFragment","createElement","createTextNode"])){
module.fail("document missing a Node creation method");}

if(!util.isHostMethod(document,"getElementsByTagName")){
module.fail("document missing getElementsByTagName method");}

var el = document.createElement("div");if(!util.areHostMethods(el,["insertBefore","appendChild","cloneNode"] ||
!util.areHostObjects(el,["previousSibling","nextSibling","childNodes","parentNode"]))){
module.fail("Incomplete Element implementation");}

if(!util.isHostProperty(el,"innerHTML")){
module.fail("Element is missing innerHTML property");}

var textNode = document.createTextNode("test");if(!util.areHostMethods(textNode,["splitText","deleteData","insertData","appendData","cloneNode"] ||
!util.areHostObjects(el,["previousSibling","nextSibling","childNodes","parentNode"]) ||
!util.areHostProperties(textNode,["data"]))){
module.fail("Incomplete Text Node implementation");}

var arrayContains = /*Array.prototype.indexOf ?
function(arr,val){
return arr.indexOf(val) > -1;}:*/

function(arr,val){
var i = arr.length;while (i--){
if(arr[i] === val){
return true;}
}
return false;};
function isHtmlNamespace(node){
var ns;return typeof node.namespaceURI == UNDEF || ((ns = node.namespaceURI) === null || ns == "http://www.w3.org/1999/xhtml");}

function parentElement(node){
var parent = node.parentNode;return (parent.nodeType == 1) ? parent : null;}

function getNodeIndex(node){
var i = 0;while( (node = node.previousSibling) ){++i;}
return i;}

function getNodeLength(node){
switch (node.nodeType){
case 7:
case 10:
return 0;case 3:
case 8:
return node.length;default:
return node.childNodes.length;}
}

function getCommonAncestor(node1,node2){
var ancestors = [],n;for(n = node1; n; n = n.parentNode){
ancestors.push(n);}

for(n = node2; n; n = n.parentNode){
if(arrayContains(ancestors,n)){
return n;}
}

return null;}

function isAncestorOf(ancestor,descendant,selfIsAncestor){
var n = selfIsAncestor ? descendant : descendant.parentNode;while (n){
if(n === ancestor){
return true;} else {
n = n.parentNode;}
}
return false;}

function isOrIsAncestorOf(ancestor,descendant){
return isAncestorOf(ancestor,descendant,true);}

function getClosestAncestorIn(node,ancestor,selfIsAncestor){
var p,n = selfIsAncestor ? node : node.parentNode;while (n){
p = n.parentNode;if(p === ancestor){
return n;}
n = p;}
return null;}

function isCharacterDataNode(node){
var t = node.nodeType;return t == 3 || t == 4 || t == 8 ; }

function isTextOrCommentNode(node){
if(!node){
return false;}
var t = node.nodeType;return t == 3 || t == 8 ; }

function insertAfter(node,precedingNode){
var nextNode = precedingNode.nextSibling,parent = precedingNode.parentNode;if(nextNode){
parent.insertBefore(node,nextNode);} else {
parent.appendChild(node);}
return node;}

function splitDataNode(node,index,positionsToPreserve){
var newNode = node.cloneNode(false);newNode.deleteData(0,index);node.deleteData(index,node.length - index);insertAfter(newNode,node);
if(positionsToPreserve){
for(var i = 0,position; position = positionsToPreserve[i++]; ){
if(position.node == node && position.offset > index){
position.node = newNode;position.offset -= index;}
else if(position.node == node.parentNode && position.offset > getNodeIndex(node)){++position.offset;}
}
}
return newNode;}

function getDocument(node){
if(node.nodeType == 9){
return node;} else if(typeof node.ownerDocument != UNDEF){
return node.ownerDocument;} else if(typeof node.document != UNDEF){
return node.document;} else if(node.parentNode){
return getDocument(node.parentNode);} else {
throw module.createError("getDocument: no document found for node");}
}

function getWindow(node){
var doc = getDocument(node);if(typeof doc.defaultView != UNDEF){
return doc.defaultView;} else if(typeof doc.parentWindow != UNDEF){
return doc.parentWindow;} else {
throw module.createError("Cannot get a window object for node");}
}

function getIframeDocument(iframeEl){
if(typeof iframeEl.contentDocument != UNDEF){
return iframeEl.contentDocument;} else if(typeof iframeEl.contentWindow != UNDEF){
return iframeEl.contentWindow.document;} else {
throw module.createError("getIframeDocument: No Document object found for iframe element");}
}

function getIframeWindow(iframeEl){
if(typeof iframeEl.contentWindow != UNDEF){
return iframeEl.contentWindow;} else if(typeof iframeEl.contentDocument != UNDEF){
return iframeEl.contentDocument.defaultView;} else {
throw module.createError("getIframeWindow: No Window object found for iframe element");}
}

function isWindow(obj){
return obj && util.isHostMethod(obj,"setTimeout") && util.isHostObject(obj,"document");}

function getContentDocument(obj,module,methodName){
var doc;
if(!obj){
doc = document;}

else if(util.isHostProperty(obj,"nodeType")){
doc = (obj.nodeType == 1 && obj.tagName.toLowerCase() == "iframe") ?
getIframeDocument(obj) : getDocument(obj);}

else if(isWindow(obj)){
doc = obj.document;}

if(!doc){
throw module.createError(methodName+"(): Parameter must be a Window object or DOM node");}

return doc;}

function getRootContainer(node){
var parent;while ( (parent = node.parentNode) ){
node = parent;}
return node;}

function comparePoints(nodeA,offsetA,nodeB,offsetB){
var nodeC,root,childA,childB,n;if(nodeA == nodeB){
return offsetA === offsetB ? 0 : (offsetA < offsetB) ? -1 : 1;} else if( (nodeC = getClosestAncestorIn(nodeB,nodeA,true)) ){
return offsetA <= getNodeIndex(nodeC) ? -1 : 1;} else if( (nodeC = getClosestAncestorIn(nodeA,nodeB,true)) ){
return getNodeIndex(nodeC) < offsetB  ? -1 : 1;} else {
root = getCommonAncestor(nodeA,nodeB);if(!root){
throw new Error("comparePoints error: nodes have no common ancestor");}

childA = (nodeA === root) ? root : getClosestAncestorIn(nodeA,root,true);childB = (nodeB === root) ? root : getClosestAncestorIn(nodeB,root,true);
if(childA === childB){
throw module.createError("comparePoints got to case 4 and childA and childB are the same!");} else {
n = root.firstChild;while (n){
if(n === childA){
return -1;} else if(n === childB){
return 1;}
n = n.nextSibling;}
}
}
}

var crashyTextNodes = false;
function isBrokenNode(node){
var n;try {
n = node.parentNode;return false;} catch (e){
return true;}
}

(function(){
var el = document.createElement("b");el.innerHTML = "1";var textNode = el.firstChild;el.innerHTML = "<br />";crashyTextNodes = isBrokenNode(textNode);
api.features.crashyTextNodes = crashyTextNodes;})();
function inspectNode(node){
if(!node){
return "[No node]";}
if(crashyTextNodes && isBrokenNode(node)){
return "[Broken node]";}
if(isCharacterDataNode(node)){
return '"'+node.data+'"';}
if(node.nodeType == 1){
var idAttr = node.id ? ' id="'+node.id+'"' : "";return "<"+node.nodeName+idAttr+">[index:"+getNodeIndex(node)+",length:"+node.childNodes.length+"]["+(node.innerHTML || "[innerHTML not supported]").slice(0,25)+"]";}
return node.nodeName;}

function fragmentFromNodeChildren(node){
var fragment = getDocument(node).createDocumentFragment(),child;while ( (child = node.firstChild) ){
fragment.appendChild(child);}
return fragment;}

var getComputedStyleProperty;if(typeof window.getComputedStyle != UNDEF){
getComputedStyleProperty = function(el,propName){
return getWindow(el).getComputedStyle(el,null)[propName];};} else if(typeof document.documentElement.currentStyle != UNDEF){
getComputedStyleProperty = function(el,propName){
return el.currentStyle[propName];};} else {
module.fail("No means of obtaining computed style properties found");}

function NodeIterator(root){
this.root = root;this._next = root;}

NodeIterator.prototype = {
_current: null,
hasNext: function(){
return !!this._next;},


next: function(){
var n = this._current = this._next;var child,next;if(this._current){
child = n.firstChild;if(child){
this._next = child;} else {
next = null;while ((n !== this.root) && !(next = n.nextSibling)){
n = n.parentNode;}
this._next = next;}
}
return this._current;},


detach: function(){
this._current = this._next = this.root = null;}
};
function createIterator(root){
return new NodeIterator(root);}

function DomPosition(node,offset){
this.node = node;this.offset = offset;}

DomPosition.prototype = {
equals: function(pos){
return !!pos && this.node === pos.node && this.offset == pos.offset;},


inspect: function(){
return "[DomPosition("+inspectNode(this.node)+":"+this.offset+")]";},


toString: function(){
return this.inspect();}
};
function DOMException(codeName){
this.code = this[codeName];this.codeName = codeName;this.message = "DOMException: "+this.codeName;}

DOMException.prototype = {
INDEX_SIZE_ERR: 1,HIERARCHY_REQUEST_ERR: 3,WRONG_DOCUMENT_ERR: 4,NO_MODIFICATION_ALLOWED_ERR: 7,NOT_FOUND_ERR: 8,NOT_SUPPORTED_ERR: 9,INVALID_STATE_ERR: 11,INVALID_NODE_TYPE_ERR: 24
};
DOMException.prototype.toString = function(){
return this.message;};
api.dom = {
arrayContains: arrayContains,isHtmlNamespace: isHtmlNamespace,parentElement: parentElement,getNodeIndex: getNodeIndex,getNodeLength: getNodeLength,getCommonAncestor: getCommonAncestor,isAncestorOf: isAncestorOf,isOrIsAncestorOf: isOrIsAncestorOf,getClosestAncestorIn: getClosestAncestorIn,isCharacterDataNode: isCharacterDataNode,isTextOrCommentNode: isTextOrCommentNode,insertAfter: insertAfter,splitDataNode: splitDataNode,getDocument: getDocument,getWindow: getWindow,getIframeWindow: getIframeWindow,getIframeDocument: getIframeDocument,getBody: util.getBody,isWindow: isWindow,getContentDocument: getContentDocument,getRootContainer: getRootContainer,comparePoints: comparePoints,isBrokenNode: isBrokenNode,inspectNode: inspectNode,getComputedStyleProperty: getComputedStyleProperty,fragmentFromNodeChildren: fragmentFromNodeChildren,createIterator: createIterator,DomPosition: DomPosition
};
api.DOMException = DOMException;});
api.createCoreModule("DomRange",["DomUtil"],function(api,module){
var dom = api.dom;var util = api.util;var DomPosition = dom.DomPosition;var DOMException = api.DOMException;
var isCharacterDataNode = dom.isCharacterDataNode;var getNodeIndex = dom.getNodeIndex;var isOrIsAncestorOf = dom.isOrIsAncestorOf;var getDocument = dom.getDocument;var comparePoints = dom.comparePoints;var splitDataNode = dom.splitDataNode;var getClosestAncestorIn = dom.getClosestAncestorIn;var getNodeLength = dom.getNodeLength;var arrayContains = dom.arrayContains;var getRootContainer = dom.getRootContainer;var crashyTextNodes = api.features.crashyTextNodes;

function isNonTextPartiallySelected(node,range){
return (node.nodeType != 3) &&    (isOrIsAncestorOf(node,range.startContainer) || isOrIsAncestorOf(node,range.endContainer));}

function getRangeDocument(range){
return range.document || getDocument(range.startContainer);}

function getBoundaryBeforeNode(node){
return new DomPosition(node.parentNode,getNodeIndex(node));}

function getBoundaryAfterNode(node){
return new DomPosition(node.parentNode,getNodeIndex(node)+1);}

function insertNodeAtPosition(node,n,o){
var firstNodeInserted = node.nodeType == 11 ? node.firstChild : node;if(isCharacterDataNode(n)){
if(o == n.length){
dom.insertAfter(node,n);} else {
n.parentNode.insertBefore(node,o == 0 ? n : splitDataNode(n,o));}
} else if(o >= n.childNodes.length){
n.appendChild(node);} else {
n.insertBefore(node,n.childNodes[o]);}
return firstNodeInserted;}

function rangesIntersect(rangeA,rangeB,touchingIsIntersecting){
assertRangeValid(rangeA);assertRangeValid(rangeB);
if(getRangeDocument(rangeB) != getRangeDocument(rangeA)){
throw new DOMException("WRONG_DOCUMENT_ERR");}

var startComparison = comparePoints(rangeA.startContainer,rangeA.startOffset,rangeB.endContainer,rangeB.endOffset),endComparison = comparePoints(rangeA.endContainer,rangeA.endOffset,rangeB.startContainer,rangeB.startOffset);
return touchingIsIntersecting ? startComparison <= 0 && endComparison >= 0 : startComparison < 0 && endComparison > 0;}

function cloneSubtree(iterator){
var partiallySelected;for(var node,frag = getRangeDocument(iterator.range).createDocumentFragment(),subIterator; node = iterator.next(); ){
partiallySelected = iterator.isPartiallySelectedSubtree();node = node.cloneNode(!partiallySelected);if(partiallySelected){
subIterator = iterator.getSubtreeIterator();node.appendChild(cloneSubtree(subIterator));subIterator.detach();}

if(node.nodeType == 10){ throw new DOMException("HIERARCHY_REQUEST_ERR");}
frag.appendChild(node);}
return frag;}

function iterateSubtree(rangeIterator,func,iteratorState){
var it,n;iteratorState = iteratorState || { stop: false };for(var node,subRangeIterator; node = rangeIterator.next(); ){
if(rangeIterator.isPartiallySelectedSubtree()){
if(func(node) === false){
iteratorState.stop = true;return;} else {
subRangeIterator = rangeIterator.getSubtreeIterator();iterateSubtree(subRangeIterator,func,iteratorState);subRangeIterator.detach();if(iteratorState.stop){
return;}
}
} else {
it = dom.createIterator(node);while ( (n = it.next()) ){
if(func(n) === false){
iteratorState.stop = true;return;}
}
}
}
}

function deleteSubtree(iterator){
var subIterator;while (iterator.next()){
if(iterator.isPartiallySelectedSubtree()){
subIterator = iterator.getSubtreeIterator();deleteSubtree(subIterator);subIterator.detach();} else {
iterator.remove();}
}
}

function extractSubtree(iterator){
for(var node,frag = getRangeDocument(iterator.range).createDocumentFragment(),subIterator; node = iterator.next(); ){

if(iterator.isPartiallySelectedSubtree()){
node = node.cloneNode(false);subIterator = iterator.getSubtreeIterator();node.appendChild(extractSubtree(subIterator));subIterator.detach();} else {
iterator.remove();}
if(node.nodeType == 10){ throw new DOMException("HIERARCHY_REQUEST_ERR");}
frag.appendChild(node);}
return frag;}

function getNodesInRange(range,nodeTypes,filter){
var filterNodeTypes = !!(nodeTypes && nodeTypes.length),regex;var filterExists = !!filter;if(filterNodeTypes){
regex = new RegExp("^("+nodeTypes.join("|")+")$");}

var nodes = [];iterateSubtree(new RangeIterator(range,false),function(node){
if(filterNodeTypes && !regex.test(node.nodeType)){
return;}
if(filterExists && !filter(node)){
return;}
var sc = range.startContainer;if(node == sc && isCharacterDataNode(sc) && range.startOffset == sc.length){
return;}

var ec = range.endContainer;if(node == ec && isCharacterDataNode(ec) && range.endOffset == 0){
return;}

nodes.push(node);});return nodes;}

function inspect(range){
var name = (typeof range.getName == "undefined") ? "Range" : range.getName();return "["+name+"("+dom.inspectNode(range.startContainer)+":"+range.startOffset+","+
dom.inspectNode(range.endContainer)+":"+range.endOffset+")]";}


function RangeIterator(range,clonePartiallySelectedTextNodes){
this.range = range;this.clonePartiallySelectedTextNodes = clonePartiallySelectedTextNodes;

if(!range.collapsed){
this.sc = range.startContainer;this.so = range.startOffset;this.ec = range.endContainer;this.eo = range.endOffset;var root = range.commonAncestorContainer;
if(this.sc === this.ec && isCharacterDataNode(this.sc)){
this.isSingleCharacterDataNode = true;this._first = this._last = this._next = this.sc;} else {
this._first = this._next = (this.sc === root && !isCharacterDataNode(this.sc)) ?
this.sc.childNodes[this.so] : getClosestAncestorIn(this.sc,root,true);this._last = (this.ec === root && !isCharacterDataNode(this.ec)) ?
this.ec.childNodes[this.eo - 1] : getClosestAncestorIn(this.ec,root,true);}
}
}

RangeIterator.prototype = {
_current: null,_next: null,_first: null,_last: null,isSingleCharacterDataNode: false,
reset: function(){
this._current = null;this._next = this._first;},


hasNext: function(){
return !!this._next;},


next: function(){
var current = this._current = this._next;if(current){
this._next = (current !== this._last) ? current.nextSibling : null;
if(isCharacterDataNode(current) && this.clonePartiallySelectedTextNodes){
if(current === this.ec){
(current = current.cloneNode(true)).deleteData(this.eo,current.length - this.eo);}
if(this._current === this.sc){
(current = current.cloneNode(true)).deleteData(0,this.so);}
}
}

return current;},


remove: function(){
var current = this._current,start,end;
if(isCharacterDataNode(current) && (current === this.sc || current === this.ec)){
start = (current === this.sc) ? this.so : 0;end = (current === this.ec) ? this.eo : current.length;if(start != end){
current.deleteData(start,end - start);}
} else {
if(current.parentNode){
current.parentNode.removeChild(current);} else {
}
}
},
isPartiallySelectedSubtree: function(){
var current = this._current;return isNonTextPartiallySelected(current,this.range);},


getSubtreeIterator: function(){
var subRange;if(this.isSingleCharacterDataNode){
subRange = this.range.cloneRange();subRange.collapse(false);} else {
subRange = new Range(getRangeDocument(this.range));var current = this._current;var startContainer = current,startOffset = 0,endContainer = current,endOffset = getNodeLength(current);
if(isOrIsAncestorOf(current,this.sc)){
startContainer = this.sc;startOffset = this.so;}
if(isOrIsAncestorOf(current,this.ec)){
endContainer = this.ec;endOffset = this.eo;}

updateBoundaries(subRange,startContainer,startOffset,endContainer,endOffset);}
return new RangeIterator(subRange,this.clonePartiallySelectedTextNodes);},


detach: function(){
this.range = this._current = this._next = this._first = this._last = this.sc = this.so = this.ec = this.eo = null;}
};
var beforeAfterNodeTypes = [1,3,4,5,7,8,10];var rootContainerNodeTypes = [2,9,11];var readonlyNodeTypes = [5,6,10,12];var insertableNodeTypes = [1,3,4,5,7,8,10,11];var surroundNodeTypes = [1,3,4,5,7,8];
function createAncestorFinder(nodeTypes){
return function(node,selfIsAncestor){
var t,n = selfIsAncestor ? node : node.parentNode;while (n){
t = n.nodeType;if(arrayContains(nodeTypes,t)){
return n;}
n = n.parentNode;}
return null;};}

var getDocumentOrFragmentContainer = createAncestorFinder( [9,11] );var getReadonlyAncestor = createAncestorFinder(readonlyNodeTypes);var getDocTypeNotationEntityAncestor = createAncestorFinder( [6,10,12] );
function assertNoDocTypeNotationEntityAncestor(node,allowSelf){
if(getDocTypeNotationEntityAncestor(node,allowSelf)){
throw new DOMException("INVALID_NODE_TYPE_ERR");}
}

function assertValidNodeType(node,invalidTypes){
if(!arrayContains(invalidTypes,node.nodeType)){
throw new DOMException("INVALID_NODE_TYPE_ERR");}
}

function assertValidOffset(node,offset){
if(offset < 0 || offset > (isCharacterDataNode(node) ? node.length : node.childNodes.length)){
throw new DOMException("INDEX_SIZE_ERR");}
}

function assertSameDocumentOrFragment(node1,node2){
if(getDocumentOrFragmentContainer(node1,true) !== getDocumentOrFragmentContainer(node2,true)){
throw new DOMException("WRONG_DOCUMENT_ERR");}
}

function assertNodeNotReadOnly(node){
if(getReadonlyAncestor(node,true)){
throw new DOMException("NO_MODIFICATION_ALLOWED_ERR");}
}

function assertNode(node,codeName){
if(!node){
throw new DOMException(codeName);}
}

function isOrphan(node){
return (crashyTextNodes && dom.isBrokenNode(node)) ||
!arrayContains(rootContainerNodeTypes,node.nodeType) && !getDocumentOrFragmentContainer(node,true);}

function isValidOffset(node,offset){
return offset <= (isCharacterDataNode(node) ? node.length : node.childNodes.length);}

function isRangeValid(range){
return (!!range.startContainer && !!range.endContainer && !isOrphan(range.startContainer) && !isOrphan(range.endContainer) && isValidOffset(range.startContainer,range.startOffset) && isValidOffset(range.endContainer,range.endOffset));}

function assertRangeValid(range){
if(!isRangeValid(range)){
throw new Error("Range error: Range is no longer valid after DOM mutation ("+range.inspect()+")");}
}

var styleEl = document.createElement("style");var htmlParsingConforms = false;try {
styleEl.innerHTML = "<b>x</b>";htmlParsingConforms = (styleEl.firstChild.nodeType == 3); } catch (e){
}

api.features.htmlParsingConforms = htmlParsingConforms;
var createContextualFragment = htmlParsingConforms ?

function(fragmentStr){
var node = this.startContainer;var doc = getDocument(node);
if(!node){
throw new DOMException("INVALID_STATE_ERR");}

var el = null;
if(node.nodeType == 1){
el = node;
} else if(isCharacterDataNode(node)){
el = dom.parentElement(node);}

if(el === null || (
el.nodeName == "HTML" && dom.isHtmlNamespace(getDocument(el).documentElement) && dom.isHtmlNamespace(el)
)){

el = doc.createElement("body");} else {
el = el.cloneNode(false);}

el.innerHTML = fragmentStr;

return dom.fragmentFromNodeChildren(el);} :

function(fragmentStr){
var doc = getRangeDocument(this);var el = doc.createElement("body");el.innerHTML = fragmentStr;
return dom.fragmentFromNodeChildren(el);};
function splitRangeBoundaries(range,positionsToPreserve){
assertRangeValid(range);
var sc = range.startContainer,so = range.startOffset,ec = range.endContainer,eo = range.endOffset;var startEndSame = (sc === ec);
if(isCharacterDataNode(ec) && eo > 0 && eo < ec.length){
splitDataNode(ec,eo,positionsToPreserve);}

if(isCharacterDataNode(sc) && so > 0 && so < sc.length){
sc = splitDataNode(sc,so,positionsToPreserve);if(startEndSame){
eo -= so;ec = sc;} else if(ec == sc.parentNode && eo >= getNodeIndex(sc)){
eo++;}
so = 0;}
range.setStartAndEnd(sc,so,ec,eo);}

function rangeToHtml(range){
assertRangeValid(range);var container = range.commonAncestorContainer.parentNode.cloneNode(false);container.appendChild( range.cloneContents() );return container.innerHTML;}

var rangeProperties = ["startContainer","startOffset","endContainer","endOffset","collapsed","commonAncestorContainer"];
var s2s = 0,s2e = 1,e2e = 2,e2s = 3;var n_b = 0,n_a = 1,n_b_a = 2,n_i = 3;
util.extend(api.rangePrototype,{
compareBoundaryPoints: function(how,range){
assertRangeValid(this);assertSameDocumentOrFragment(this.startContainer,range.startContainer);
var nodeA,offsetA,nodeB,offsetB;var prefixA = (how == e2s || how == s2s) ? "start" : "end";var prefixB = (how == s2e || how == s2s) ? "start" : "end";nodeA = this[prefixA+"Container"];offsetA = this[prefixA+"Offset"];nodeB = range[prefixB+"Container"];offsetB = range[prefixB+"Offset"];return comparePoints(nodeA,offsetA,nodeB,offsetB);},


insertNode: function(node){
assertRangeValid(this);assertValidNodeType(node,insertableNodeTypes);assertNodeNotReadOnly(this.startContainer);
if(isOrIsAncestorOf(node,this.startContainer)){
throw new DOMException("HIERARCHY_REQUEST_ERR");}


var firstNodeInserted = insertNodeAtPosition(node,this.startContainer,this.startOffset);this.setStartBefore(firstNodeInserted);},


cloneContents: function(){
assertRangeValid(this);
var clone,frag;if(this.collapsed){
return getRangeDocument(this).createDocumentFragment();} else {
if(this.startContainer === this.endContainer && isCharacterDataNode(this.startContainer)){
clone = this.startContainer.cloneNode(true);clone.data = clone.data.slice(this.startOffset,this.endOffset);frag = getRangeDocument(this).createDocumentFragment();frag.appendChild(clone);return frag;} else {
var iterator = new RangeIterator(this,true);clone = cloneSubtree(iterator);iterator.detach();}
return clone;}
},
canSurroundContents: function(){
assertRangeValid(this);assertNodeNotReadOnly(this.startContainer);assertNodeNotReadOnly(this.endContainer);
var iterator = new RangeIterator(this,true);var boundariesInvalid = (iterator._first && (isNonTextPartiallySelected(iterator._first,this)) ||
(iterator._last && isNonTextPartiallySelected(iterator._last,this)));iterator.detach();return !boundariesInvalid;},


surroundContents: function(node){
assertValidNodeType(node,surroundNodeTypes);
if(!this.canSurroundContents()){
throw new DOMException("INVALID_STATE_ERR");}

var content = this.extractContents();
if(node.hasChildNodes()){
while (node.lastChild){
node.removeChild(node.lastChild);}
}

insertNodeAtPosition(node,this.startContainer,this.startOffset);node.appendChild(content);
this.selectNode(node);},


cloneRange: function(){
assertRangeValid(this);var range = new Range(getRangeDocument(this));var i = rangeProperties.length,prop;while (i--){
prop = rangeProperties[i];range[prop] = this[prop];}
return range;},


toString: function(){
assertRangeValid(this);var sc = this.startContainer;if(sc === this.endContainer && isCharacterDataNode(sc)){
return (sc.nodeType == 3 || sc.nodeType == 4) ? sc.data.slice(this.startOffset,this.endOffset) : "";} else {
var textParts = [],iterator = new RangeIterator(this,true);iterateSubtree(iterator,function(node){
if(node.nodeType == 3 || node.nodeType == 4){
textParts.push(node.data);}
});iterator.detach();return textParts.join("");}
},

compareNode: function(node){
assertRangeValid(this);
var parent = node.parentNode;var nodeIndex = getNodeIndex(node);
if(!parent){
throw new DOMException("NOT_FOUND_ERR");}

var startComparison = this.comparePoint(parent,nodeIndex),endComparison = this.comparePoint(parent,nodeIndex+1);
if(startComparison < 0){ return (endComparison > 0) ? n_b_a : n_b;} else {
return (endComparison > 0) ? n_a : n_i;}
},
comparePoint: function(node,offset){
assertRangeValid(this);assertNode(node,"HIERARCHY_REQUEST_ERR");assertSameDocumentOrFragment(node,this.startContainer);
if(comparePoints(node,offset,this.startContainer,this.startOffset) < 0){
return -1;} else if(comparePoints(node,offset,this.endContainer,this.endOffset) > 0){
return 1;}
return 0;},


createContextualFragment: createContextualFragment,
toHtml: function(){
return rangeToHtml(this);},


intersectsNode: function(node,touchingIsIntersecting){
assertRangeValid(this);assertNode(node,"NOT_FOUND_ERR");if(getDocument(node) !== getRangeDocument(this)){
return false;}

var parent = node.parentNode,offset = getNodeIndex(node);assertNode(parent,"NOT_FOUND_ERR");
var startComparison = comparePoints(parent,offset,this.endContainer,this.endOffset),endComparison = comparePoints(parent,offset+1,this.startContainer,this.startOffset);
return touchingIsIntersecting ? startComparison <= 0 && endComparison >= 0 : startComparison < 0 && endComparison > 0;},


isPointInRange: function(node,offset){
assertRangeValid(this);assertNode(node,"HIERARCHY_REQUEST_ERR");assertSameDocumentOrFragment(node,this.startContainer);
return (comparePoints(node,offset,this.startContainer,this.startOffset) >= 0) &&    (comparePoints(node,offset,this.endContainer,this.endOffset) <= 0);},



intersectsRange: function(range){
return rangesIntersect(this,range,false);},


intersectsOrTouchesRange: function(range){
return rangesIntersect(this,range,true);},


intersection: function(range){
if(this.intersectsRange(range)){
var startComparison = comparePoints(this.startContainer,this.startOffset,range.startContainer,range.startOffset),endComparison = comparePoints(this.endContainer,this.endOffset,range.endContainer,range.endOffset);
var intersectionRange = this.cloneRange();if(startComparison == -1){
intersectionRange.setStart(range.startContainer,range.startOffset);}
if(endComparison == 1){
intersectionRange.setEnd(range.endContainer,range.endOffset);}
return intersectionRange;}
return null;},


union: function(range){
if(this.intersectsOrTouchesRange(range)){
var unionRange = this.cloneRange();if(comparePoints(range.startContainer,range.startOffset,this.startContainer,this.startOffset) == -1){
unionRange.setStart(range.startContainer,range.startOffset);}
if(comparePoints(range.endContainer,range.endOffset,this.endContainer,this.endOffset) == 1){
unionRange.setEnd(range.endContainer,range.endOffset);}
return unionRange;} else {
throw new DOMException("Ranges do not intersect");}
},
containsNode: function(node,allowPartial){
if(allowPartial){
return this.intersectsNode(node,false);} else {
return this.compareNode(node) == n_i;}
},
containsNodeContents: function(node){
return this.comparePoint(node,0) >= 0 && this.comparePoint(node,getNodeLength(node)) <= 0;},


containsRange: function(range){
var intersection = this.intersection(range);return intersection !== null && range.equals(intersection);},


containsNodeText: function(node){
var nodeRange = this.cloneRange();nodeRange.selectNode(node);var textNodes = nodeRange.getNodes([3]);if(textNodes.length > 0){
nodeRange.setStart(textNodes[0],0);var lastTextNode = textNodes.pop();nodeRange.setEnd(lastTextNode,lastTextNode.length);return this.containsRange(nodeRange);} else {
return this.containsNodeContents(node);}
},
getNodes: function(nodeTypes,filter){
assertRangeValid(this);return getNodesInRange(this,nodeTypes,filter);},


getDocument: function(){
return getRangeDocument(this);},


collapseBefore: function(node){
this.setEndBefore(node);this.collapse(false);},


collapseAfter: function(node){
this.setStartAfter(node);this.collapse(true);},

getBookmark: function(containerNode){
var doc = getRangeDocument(this);var preSelectionRange = api.createRange(doc);containerNode = containerNode || dom.getBody(doc);preSelectionRange.selectNodeContents(containerNode);var range = this.intersection(preSelectionRange);var start = 0,end = 0;if(range){
preSelectionRange.setEnd(range.startContainer,range.startOffset);start = preSelectionRange.toString().length;end = start+range.toString().length;}

return {
start: start,end: end,containerNode: containerNode
};},

moveToBookmark: function(bookmark){
var containerNode = bookmark.containerNode;var charIndex = 0;this.setStart(containerNode,0);this.collapse(true);var nodeStack = [containerNode],node,foundStart = false,stop = false;var nextCharIndex,i,childNodes;
while (!stop && (node = nodeStack.pop())){
if(node.nodeType == 3){
nextCharIndex = charIndex+node.length;if(!foundStart && bookmark.start >= charIndex && bookmark.start <= nextCharIndex){
this.setStart(node,bookmark.start - charIndex);foundStart = true;}
if(foundStart && bookmark.end >= charIndex && bookmark.end <= nextCharIndex){
this.setEnd(node,bookmark.end - charIndex);stop = true;}
charIndex = nextCharIndex;} else {
childNodes = node.childNodes;i = childNodes.length;while (i--){
nodeStack.push(childNodes[i]);}
}
}
},
getName: function(){
return "DomRange";},


equals: function(range){
return Range.rangesEqual(this,range);},


isValid: function(){
return isRangeValid(this);},

inspect: function(){
return inspect(this);},

detach: function(){
}
});
function copyComparisonConstantsToObject(obj){
obj.START_TO_START = s2s;obj.START_TO_END = s2e;obj.END_TO_END = e2e;obj.END_TO_START = e2s;
obj.NODE_BEFORE = n_b;obj.NODE_AFTER = n_a;obj.NODE_BEFORE_AND_AFTER = n_b_a;obj.NODE_INSIDE = n_i;}

function copyComparisonConstants(constructor){
copyComparisonConstantsToObject(constructor);copyComparisonConstantsToObject(constructor.prototype);}

function createRangeContentRemover(remover,boundaryUpdater){
return function(){
assertRangeValid(this);
var sc = this.startContainer,so = this.startOffset,root = this.commonAncestorContainer;
var iterator = new RangeIterator(this,true);
var node,boundary;if(sc !== root){
node = getClosestAncestorIn(sc,root,true);boundary = getBoundaryAfterNode(node);sc = boundary.node;so = boundary.offset;}

iterateSubtree(iterator,assertNodeNotReadOnly);
iterator.reset();
var returnValue = remover(iterator);iterator.detach();
boundaryUpdater(this,sc,so,sc,so);
return returnValue;};}

function createPrototypeRange(constructor,boundaryUpdater){
function createBeforeAfterNodeSetter(isBefore,isStart){
return function(node){
assertValidNodeType(node,beforeAfterNodeTypes);assertValidNodeType(getRootContainer(node),rootContainerNodeTypes);
var boundary = (isBefore ? getBoundaryBeforeNode : getBoundaryAfterNode)(node);(isStart ? setRangeStart : setRangeEnd)(this,boundary.node,boundary.offset);};}

function setRangeStart(range,node,offset){
var ec = range.endContainer,eo = range.endOffset;if(node !== range.startContainer || offset !== range.startOffset){
if(getRootContainer(node) != getRootContainer(ec) || comparePoints(node,offset,ec,eo) == 1){
ec = node;eo = offset;}
boundaryUpdater(range,node,offset,ec,eo);}
}

function setRangeEnd(range,node,offset){
var sc = range.startContainer,so = range.startOffset;if(node !== range.endContainer || offset !== range.endOffset){
if(getRootContainer(node) != getRootContainer(sc) || comparePoints(node,offset,sc,so) == -1){
sc = node;so = offset;}
boundaryUpdater(range,sc,so,node,offset);}
}

var F = function(){};F.prototype = api.rangePrototype;constructor.prototype = new F();
util.extend(constructor.prototype,{
setStart: function(node,offset){
assertNoDocTypeNotationEntityAncestor(node,true);assertValidOffset(node,offset);
setRangeStart(this,node,offset);},


setEnd: function(node,offset){
assertNoDocTypeNotationEntityAncestor(node,true);assertValidOffset(node,offset);
setRangeEnd(this,node,offset);},


/**
 * Convenience method to set a range's start and end boundaries. Overloaded as follows:
 * - Two parameters (node,offset) creates a collapsed range at that position
 * - Three parameters (node,startOffset,endOffset) creates a range contained with node starting at
 *   startOffset and ending at endOffset
 * - Four parameters (startNode,startOffset,endNode,endOffset) creates a range starting at startOffset in
 *   startNode and ending at endOffset in endNode
 */
setStartAndEnd: function(){
var args = arguments;var sc = args[0],so = args[1],ec = sc,eo = so;
switch (args.length){
case 3:
eo = args[2];break;case 4:
ec = args[2];eo = args[3];break;}

boundaryUpdater(this,sc,so,ec,eo);},

setBoundary: function(node,offset,isStart){
this["set"+(isStart ? "Start" : "End")](node,offset);},


setStartBefore: createBeforeAfterNodeSetter(true,true),setStartAfter: createBeforeAfterNodeSetter(false,true),setEndBefore: createBeforeAfterNodeSetter(true,false),setEndAfter: createBeforeAfterNodeSetter(false,false),
collapse: function(isStart){
assertRangeValid(this);if(isStart){
boundaryUpdater(this,this.startContainer,this.startOffset,this.startContainer,this.startOffset);} else {
boundaryUpdater(this,this.endContainer,this.endOffset,this.endContainer,this.endOffset);}
},
selectNodeContents: function(node){
assertNoDocTypeNotationEntityAncestor(node,true);
boundaryUpdater(this,node,0,node,getNodeLength(node));},


selectNode: function(node){
assertNoDocTypeNotationEntityAncestor(node,false);assertValidNodeType(node,beforeAfterNodeTypes);
var start = getBoundaryBeforeNode(node),end = getBoundaryAfterNode(node);boundaryUpdater(this,start.node,start.offset,end.node,end.offset);},


extractContents: createRangeContentRemover(extractSubtree,boundaryUpdater),
deleteContents: createRangeContentRemover(deleteSubtree,boundaryUpdater),
canSurroundContents: function(){
assertRangeValid(this);assertNodeNotReadOnly(this.startContainer);assertNodeNotReadOnly(this.endContainer);
var iterator = new RangeIterator(this,true);var boundariesInvalid = (iterator._first && isNonTextPartiallySelected(iterator._first,this) ||
(iterator._last && isNonTextPartiallySelected(iterator._last,this)));iterator.detach();return !boundariesInvalid;},


splitBoundaries: function(){
splitRangeBoundaries(this);},


splitBoundariesPreservingPositions: function(positionsToPreserve){
splitRangeBoundaries(this,positionsToPreserve);},


normalizeBoundaries: function(){
assertRangeValid(this);
var sc = this.startContainer,so = this.startOffset,ec = this.endContainer,eo = this.endOffset;
var mergeForward = function(node){
var sibling = node.nextSibling;if(sibling && sibling.nodeType == node.nodeType){
ec = node;eo = node.length;node.appendData(sibling.data);sibling.parentNode.removeChild(sibling);}
};
var mergeBackward = function(node){
var sibling = node.previousSibling;if(sibling && sibling.nodeType == node.nodeType){
sc = node;var nodeLength = node.length;so = sibling.length;node.insertData(0,sibling.data);sibling.parentNode.removeChild(sibling);if(sc == ec){
eo+= so;ec = sc;} else if(ec == node.parentNode){
var nodeIndex = getNodeIndex(node);if(eo == nodeIndex){
ec = node;eo = nodeLength;} else if(eo > nodeIndex){
eo--;}
}
}
};
var normalizeStart = true;
if(isCharacterDataNode(ec)){
if(ec.length == eo){
mergeForward(ec);}
} else {
if(eo > 0){
var endNode = ec.childNodes[eo - 1];if(endNode && isCharacterDataNode(endNode)){
mergeForward(endNode);}
}
normalizeStart = !this.collapsed;}

if(normalizeStart){
if(isCharacterDataNode(sc)){
if(so == 0){
mergeBackward(sc);}
} else {
if(so < sc.childNodes.length){
var startNode = sc.childNodes[so];if(startNode && isCharacterDataNode(startNode)){
mergeBackward(startNode);}
}
}
} else {
sc = ec;so = eo;}

boundaryUpdater(this,sc,so,ec,eo);},


collapseToPoint: function(node,offset){
assertNoDocTypeNotationEntityAncestor(node,true);assertValidOffset(node,offset);this.setStartAndEnd(node,offset);}
});
copyComparisonConstants(constructor);}

function updateCollapsedAndCommonAncestor(range){
range.collapsed = (range.startContainer === range.endContainer && range.startOffset === range.endOffset);range.commonAncestorContainer = range.collapsed ?
range.startContainer : dom.getCommonAncestor(range.startContainer,range.endContainer);}

function updateBoundaries(range,startContainer,startOffset,endContainer,endOffset){
range.startContainer = startContainer;range.startOffset = startOffset;range.endContainer = endContainer;range.endOffset = endOffset;range.document = dom.getDocument(startContainer);
updateCollapsedAndCommonAncestor(range);}

function Range(doc){
this.startContainer = doc;this.startOffset = 0;this.endContainer = doc;this.endOffset = 0;this.document = doc;updateCollapsedAndCommonAncestor(this);}

createPrototypeRange(Range,updateBoundaries);
util.extend(Range,{
rangeProperties: rangeProperties,RangeIterator: RangeIterator,copyComparisonConstants: copyComparisonConstants,createPrototypeRange: createPrototypeRange,inspect: inspect,toHtml: rangeToHtml,getRangeDocument: getRangeDocument,rangesEqual: function(r1,r2){
return r1.startContainer === r2.startContainer && r1.startOffset === r2.startOffset && r1.endContainer === r2.endContainer && r1.endOffset === r2.endOffset;}
});
api.DomRange = Range;});
api.createCoreModule("WrappedRange",["DomRange"],function(api,module){
var WrappedRange,WrappedTextRange;var dom = api.dom;var util = api.util;var DomPosition = dom.DomPosition;var DomRange = api.DomRange;var getBody = dom.getBody;var getContentDocument = dom.getContentDocument;var isCharacterDataNode = dom.isCharacterDataNode;

if(api.features.implementsDomRange){

(function(){
var rangeProto;var rangeProperties = DomRange.rangeProperties;
function updateRangeProperties(range){
var i = rangeProperties.length,prop;while (i--){
prop = rangeProperties[i];range[prop] = range.nativeRange[prop];}
range.collapsed = (range.startContainer === range.endContainer && range.startOffset === range.endOffset);}

function updateNativeRange(range,startContainer,startOffset,endContainer,endOffset){
var startMoved = (range.startContainer !== startContainer || range.startOffset != startOffset);var endMoved = (range.endContainer !== endContainer || range.endOffset != endOffset);var nativeRangeDifferent = !range.equals(range.nativeRange);
if(startMoved || endMoved || nativeRangeDifferent){
range.setEnd(endContainer,endOffset);range.setStart(startContainer,startOffset);}
}

var createBeforeAfterNodeSetter;
WrappedRange = function(range){
if(!range){
throw module.createError("WrappedRange: Range must be specified");}
this.nativeRange = range;updateRangeProperties(this);};
DomRange.createPrototypeRange(WrappedRange,updateNativeRange);
rangeProto = WrappedRange.prototype;
rangeProto.selectNode = function(node){
this.nativeRange.selectNode(node);updateRangeProperties(this);};
rangeProto.cloneContents = function(){
return this.nativeRange.cloneContents();};

rangeProto.surroundContents = function(node){
this.nativeRange.surroundContents(node);updateRangeProperties(this);};
rangeProto.collapse = function(isStart){
this.nativeRange.collapse(isStart);updateRangeProperties(this);};
rangeProto.cloneRange = function(){
return new WrappedRange(this.nativeRange.cloneRange());};
rangeProto.refresh = function(){
updateRangeProperties(this);};
rangeProto.toString = function(){
return this.nativeRange.toString();};

var testTextNode = document.createTextNode("test");getBody(document).appendChild(testTextNode);var range = document.createRange();
/*--------------------------------------------------------------------------------------------------------*/


range.setStart(testTextNode,0);range.setEnd(testTextNode,0);
try {
range.setStart(testTextNode,1);
rangeProto.setStart = function(node,offset){
this.nativeRange.setStart(node,offset);updateRangeProperties(this);};
rangeProto.setEnd = function(node,offset){
this.nativeRange.setEnd(node,offset);updateRangeProperties(this);};
createBeforeAfterNodeSetter = function(name){
return function(node){
this.nativeRange[name](node);updateRangeProperties(this);};};
} catch(ex){

rangeProto.setStart = function(node,offset){
try {
this.nativeRange.setStart(node,offset);} catch (ex){
this.nativeRange.setEnd(node,offset);this.nativeRange.setStart(node,offset);}
updateRangeProperties(this);};
rangeProto.setEnd = function(node,offset){
try {
this.nativeRange.setEnd(node,offset);} catch (ex){
this.nativeRange.setStart(node,offset);this.nativeRange.setEnd(node,offset);}
updateRangeProperties(this);};
createBeforeAfterNodeSetter = function(name,oppositeName){
return function(node){
try {
this.nativeRange[name](node);} catch (ex){
this.nativeRange[oppositeName](node);this.nativeRange[name](node);}
updateRangeProperties(this);};};}

rangeProto.setStartBefore = createBeforeAfterNodeSetter("setStartBefore","setEndBefore");rangeProto.setStartAfter = createBeforeAfterNodeSetter("setStartAfter","setEndAfter");rangeProto.setEndBefore = createBeforeAfterNodeSetter("setEndBefore","setStartBefore");rangeProto.setEndAfter = createBeforeAfterNodeSetter("setEndAfter","setStartAfter");
/*--------------------------------------------------------------------------------------------------------*/

rangeProto.selectNodeContents = function(node){
this.setStartAndEnd(node,0,dom.getNodeLength(node));};
/*--------------------------------------------------------------------------------------------------------*/


range.selectNodeContents(testTextNode);range.setEnd(testTextNode,3);
var range2 = document.createRange();range2.selectNodeContents(testTextNode);range2.setEnd(testTextNode,4);range2.setStart(testTextNode,2);
if(range.compareBoundaryPoints(range.START_TO_END,range2) == -1 && range.compareBoundaryPoints(range.END_TO_START,range2) == 1){

rangeProto.compareBoundaryPoints = function(type,range){
range = range.nativeRange || range;if(type == range.START_TO_END){
type = range.END_TO_START;} else if(type == range.END_TO_START){
type = range.START_TO_END;}
return this.nativeRange.compareBoundaryPoints(type,range);};} else {
rangeProto.compareBoundaryPoints = function(type,range){
return this.nativeRange.compareBoundaryPoints(type,range.nativeRange || range);};}

/*--------------------------------------------------------------------------------------------------------*/


var el = document.createElement("div");el.innerHTML = "123";var textNode = el.firstChild;var body = getBody(document);body.appendChild(el);
range.setStart(textNode,1);range.setEnd(textNode,2);range.deleteContents();
if(textNode.data == "13"){
rangeProto.deleteContents = function(){
this.nativeRange.deleteContents();updateRangeProperties(this);};
rangeProto.extractContents = function(){
var frag = this.nativeRange.extractContents();updateRangeProperties(this);return frag;};} else {
}

body.removeChild(el);body = null;
/*--------------------------------------------------------------------------------------------------------*/

if(util.isHostMethod(range,"createContextualFragment")){
rangeProto.createContextualFragment = function(fragmentStr){
return this.nativeRange.createContextualFragment(fragmentStr);};}

/*--------------------------------------------------------------------------------------------------------*/

getBody(document).removeChild(testTextNode);
rangeProto.getName = function(){
return "WrappedRange";};
api.WrappedRange = WrappedRange;
api.createNativeRange = function(doc){
doc = getContentDocument(doc,module,"createNativeRange");return doc.createRange();};})();}

if(api.features.implementsTextRange){
/*
This is a workaround for a bug where IE returns the wrong container element from the TextRange's parentElement()
method. For example,in the following (where pipes denote the selection boundaries):

<ul id="ul"><li id="a">| a </li><li id="b"> b |</li></ul>

var range = document.selection.createRange();alert(range.parentElement().id); 
This method returns the common ancestor node of the following:
- the parentElement() of the textRange
- the parentElement() of the textRange after calling collapse(true)
- the parentElement() of the textRange after calling collapse(false)
*/
var getTextRangeContainerElement = function(textRange){
var parentEl = textRange.parentElement();var range = textRange.duplicate();range.collapse(true);var startEl = range.parentElement();range = textRange.duplicate();range.collapse(false);var endEl = range.parentElement();var startEndContainer = (startEl == endEl) ? startEl : dom.getCommonAncestor(startEl,endEl);
return startEndContainer == parentEl ? startEndContainer : dom.getCommonAncestor(parentEl,startEndContainer);};
var textRangeIsCollapsed = function(textRange){
return textRange.compareEndPoints("StartToEnd",textRange) == 0;};
var getTextRangeBoundaryPosition = function(textRange,wholeRangeContainerElement,isStart,isCollapsed,startInfo){
var workingRange = textRange.duplicate();workingRange.collapse(isStart);var containerElement = workingRange.parentElement();
if(!dom.isOrIsAncestorOf(wholeRangeContainerElement,containerElement)){
containerElement = wholeRangeContainerElement;}


if(!containerElement.canHaveHTML){
var pos = new DomPosition(containerElement.parentNode,dom.getNodeIndex(containerElement));return {
boundaryPosition: pos,nodeInfo: {
nodeIndex: pos.offset,containerElement: pos.node
}
};}

var workingNode = dom.getDocument(containerElement).createElement("span");
if(workingNode.parentNode){
workingNode.parentNode.removeChild(workingNode);}

var comparison,workingComparisonType = isStart ? "StartToStart" : "StartToEnd";var previousNode,nextNode,boundaryPosition,boundaryNode;var start = (startInfo && startInfo.containerElement == containerElement) ? startInfo.nodeIndex : 0;var childNodeCount = containerElement.childNodes.length;var end = childNodeCount;
var nodeIndex = end;
while (true){
if(nodeIndex == childNodeCount){
containerElement.appendChild(workingNode);} else {
containerElement.insertBefore(workingNode,containerElement.childNodes[nodeIndex]);}
workingRange.moveToElementText(workingNode);comparison = workingRange.compareEndPoints(workingComparisonType,textRange);if(comparison == 0 || start == end){
break;} else if(comparison == -1){
if(end == start+1){
break;} else {
start = nodeIndex;}
} else {
end = (end == start+1) ? start : nodeIndex;}
nodeIndex = Math.floor((start+end) / 2);containerElement.removeChild(workingNode);}


boundaryNode = workingNode.nextSibling;
if(comparison == -1 && boundaryNode && isCharacterDataNode(boundaryNode)){
workingRange.setEndPoint(isStart ? "EndToStart" : "EndToEnd",textRange);
var offset;
if(/[\r\n]/.test(boundaryNode.data)){
var tempRange = workingRange.duplicate();var rangeLength = tempRange.text.replace(/\r\n/g,"\r").length;
offset = tempRange.moveStart("character",rangeLength);while ( (comparison = tempRange.compareEndPoints("StartToEnd",tempRange)) == -1){
offset++;tempRange.moveStart("character",1);}
} else {
offset = workingRange.text.length;}
boundaryPosition = new DomPosition(boundaryNode,offset);} else {

previousNode = (isCollapsed || !isStart) && workingNode.previousSibling;nextNode = (isCollapsed || isStart) && workingNode.nextSibling;if(nextNode && isCharacterDataNode(nextNode)){
boundaryPosition = new DomPosition(nextNode,0);} else if(previousNode && isCharacterDataNode(previousNode)){
boundaryPosition = new DomPosition(previousNode,previousNode.data.length);} else {
boundaryPosition = new DomPosition(containerElement,dom.getNodeIndex(workingNode));}
}

workingNode.parentNode.removeChild(workingNode);
return {
boundaryPosition: boundaryPosition,nodeInfo: {
nodeIndex: nodeIndex,containerElement: containerElement
}
};};
var createBoundaryTextRange = function(boundaryPosition,isStart){
var boundaryNode,boundaryParent,boundaryOffset = boundaryPosition.offset;var doc = dom.getDocument(boundaryPosition.node);var workingNode,childNodes,workingRange = getBody(doc).createTextRange();var nodeIsDataNode = isCharacterDataNode(boundaryPosition.node);
if(nodeIsDataNode){
boundaryNode = boundaryPosition.node;boundaryParent = boundaryNode.parentNode;} else {
childNodes = boundaryPosition.node.childNodes;boundaryNode = (boundaryOffset < childNodes.length) ? childNodes[boundaryOffset] : null;boundaryParent = boundaryPosition.node;}

workingNode = doc.createElement("span");
workingNode.innerHTML = "&#feff;";
if(boundaryNode){
boundaryParent.insertBefore(workingNode,boundaryNode);} else {
boundaryParent.appendChild(workingNode);}

workingRange.moveToElementText(workingNode);workingRange.collapse(!isStart);
boundaryParent.removeChild(workingNode);
if(nodeIsDataNode){workingRange[isStart ? "moveStart" : "moveEnd"]("character",boundaryOffset);}
return workingRange;};

WrappedTextRange = function(textRange){
this.textRange = textRange;this.refresh();};
WrappedTextRange.prototype = new DomRange(document);
WrappedTextRange.prototype.refresh = function(){
var start,end,startBoundary;
var rangeContainerElement = getTextRangeContainerElement(this.textRange);
if(textRangeIsCollapsed(this.textRange)){
end = start = getTextRangeBoundaryPosition(this.textRange,rangeContainerElement,true,true).boundaryPosition;} else {
startBoundary = getTextRangeBoundaryPosition(this.textRange,rangeContainerElement,true,false);start = startBoundary.boundaryPosition;
end = getTextRangeBoundaryPosition(this.textRange,rangeContainerElement,false,false,startBoundary.nodeInfo).boundaryPosition;}

this.setStart(start.node,start.offset);this.setEnd(end.node,end.offset);};
WrappedTextRange.prototype.getName = function(){
return "WrappedTextRange";};
DomRange.copyComparisonConstants(WrappedTextRange);
var rangeToTextRange = function(range){
if(range.collapsed){
return createBoundaryTextRange(new DomPosition(range.startContainer,range.startOffset),true);} else {
var startRange = createBoundaryTextRange(new DomPosition(range.startContainer,range.startOffset),true);var endRange = createBoundaryTextRange(new DomPosition(range.endContainer,range.endOffset),false);var textRange = getBody( DomRange.getRangeDocument(range) ).createTextRange();textRange.setEndPoint("StartToStart",startRange);textRange.setEndPoint("EndToEnd",endRange);return textRange;}
};
WrappedTextRange.rangeToTextRange = rangeToTextRange;
WrappedTextRange.prototype.toTextRange = function(){
return rangeToTextRange(this);};
api.WrappedTextRange = WrappedTextRange;
if(!api.features.implementsDomRange || api.config.preferTextRange){
var globalObj = (function(f){ return f("return this;")(); })(Function);if(typeof globalObj.Range == "undefined"){
globalObj.Range = WrappedTextRange;}

api.createNativeRange = function(doc){
doc = getContentDocument(doc,module,"createNativeRange");return getBody(doc).createTextRange();};
api.WrappedRange = WrappedTextRange;}
}

api.createRange = function(doc){
doc = getContentDocument(doc,module,"createRange");return new api.WrappedRange(api.createNativeRange(doc));};
api.createRangyRange = function(doc){
doc = getContentDocument(doc,module,"createRangyRange");return new DomRange(doc);};
api.createIframeRange = function(iframeEl){
module.deprecationNotice("createIframeRange()","createRange(iframeEl)");return api.createRange(iframeEl);};
api.createIframeRangyRange = function(iframeEl){
module.deprecationNotice("createIframeRangyRange()","createRangyRange(iframeEl)");return api.createRangyRange(iframeEl);};
api.addShimListener(function(win){
var doc = win.document;if(typeof doc.createRange == "undefined"){
doc.createRange = function(){
return api.createRange(doc);};}
doc = win = null;});});
api.createCoreModule("WrappedSelection",["DomRange","WrappedRange"],function(api,module){
api.config.checkSelectionRanges = true;
var BOOLEAN = "boolean";var NUMBER = "number";var dom = api.dom;var util = api.util;var isHostMethod = util.isHostMethod;var DomRange = api.DomRange;var WrappedRange = api.WrappedRange;var DOMException = api.DOMException;var DomPosition = dom.DomPosition;var getNativeSelection;var selectionIsCollapsed;var features = api.features;var CONTROL = "Control";var getDocument = dom.getDocument;var getBody = dom.getBody;var rangesEqual = DomRange.rangesEqual;

function isDirectionBackward(dir){
return (typeof dir == "string") ? /^backward(s)?$/i.test(dir) : !!dir;}

function getWindow(win,methodName){
if(!win){
return window;} else if(dom.isWindow(win)){
return win;} else if(win instanceof WrappedSelection){
return win.win;} else {
var doc = dom.getContentDocument(win,module,methodName);return dom.getWindow(doc);}
}

function getWinSelection(winParam){
return getWindow(winParam,"getWinSelection").getSelection();}

function getDocSelection(winParam){
return getWindow(winParam,"getDocSelection").document.selection;}

function winSelectionIsBackward(sel){
var backward = false;if(sel.anchorNode){
backward = (dom.comparePoints(sel.anchorNode,sel.anchorOffset,sel.focusNode,sel.focusOffset) == 1);}
return backward;}

var implementsWinGetSelection = isHostMethod(window,"getSelection"),implementsDocSelection = util.isHostObject(document,"selection");
features.implementsWinGetSelection = implementsWinGetSelection;features.implementsDocSelection = implementsDocSelection;
var useDocumentSelection = implementsDocSelection && (!implementsWinGetSelection || api.config.preferTextRange);
if(useDocumentSelection){
getNativeSelection = getDocSelection;api.isSelectionValid = function(winParam){
var doc = getWindow(winParam,"isSelectionValid").document,nativeSel = doc.selection;
return (nativeSel.type != "None" || getDocument(nativeSel.createRange().parentElement()) == doc);};} else if(implementsWinGetSelection){
getNativeSelection = getWinSelection;api.isSelectionValid = function(){
return true;};} else {
module.fail("Neither document.selection or window.getSelection() detected.");}

api.getNativeSelection = getNativeSelection;
var testSelection = getNativeSelection();var testRange = api.createNativeRange(document);var body = getBody(document);
var selectionHasAnchorAndFocus = util.areHostProperties(testSelection,["anchorNode","focusNode","anchorOffset","focusOffset"]);
features.selectionHasAnchorAndFocus = selectionHasAnchorAndFocus;
var selectionHasExtend = isHostMethod(testSelection,"extend");features.selectionHasExtend = selectionHasExtend;
var selectionHasRangeCount = (typeof testSelection.rangeCount == NUMBER);features.selectionHasRangeCount = selectionHasRangeCount;
var selectionSupportsMultipleRanges = false;var collapsedNonEditableSelectionsSupported = true;
var addRangeBackwardToNative = selectionHasExtend ?
function(nativeSelection,range){
var doc = DomRange.getRangeDocument(range);var endRange = api.createRange(doc);endRange.collapseToPoint(range.endContainer,range.endOffset);nativeSelection.addRange(getNativeRange(endRange));nativeSelection.extend(range.startContainer,range.startOffset);} : null;
if(util.areHostMethods(testSelection,["addRange","getRangeAt","removeAllRanges"]) && typeof testSelection.rangeCount == NUMBER && features.implementsDomRange){

(function(){

var sel = window.getSelection();if(sel){
var originalSelectionRangeCount = sel.rangeCount;var selectionHasMultipleRanges = (originalSelectionRangeCount > 1);var originalSelectionRanges = [];var originalSelectionBackward = winSelectionIsBackward(sel); 
for(var i = 0; i < originalSelectionRangeCount;++i){
originalSelectionRanges[i] = sel.getRangeAt(i);}

var body = getBody(document);var testEl = body.appendChild( document.createElement("div") );testEl.contentEditable = "false";var textNode = testEl.appendChild( document.createTextNode("\u00a0\u00a0\u00a0") );
var r1 = document.createRange();
//r1.setStart(textNode,1);
r1.collapse(true);sel.addRange(r1);collapsedNonEditableSelectionsSupported = (sel.rangeCount == 1);sel.removeAllRanges();
if(!selectionHasMultipleRanges){
var chromeMatch = window.navigator.appVersion.match(/Chrome\/(.*?) /);if(chromeMatch && parseInt(chromeMatch[1]) >= 36){
selectionSupportsMultipleRanges = false;} else {
var r2 = r1.cloneRange();r1.setStart(textNode,0);
//r2.setEnd(textNode,3);
//r2.setStart(textNode,2);
sel.addRange(r1);sel.addRange(r2);selectionSupportsMultipleRanges = (sel.rangeCount == 2);}
}

body.removeChild(testEl);sel.removeAllRanges();
for(i = 0; i < originalSelectionRangeCount;++i){
if(i == 0 && originalSelectionBackward){
if(addRangeBackwardToNative){
addRangeBackwardToNative(sel,originalSelectionRanges[i]);} else {
api.warn("Rangy initialization: original selection was backwards but selection has been restored forwards because the browser does not support Selection.extend");sel.addRange(originalSelectionRanges[i]);}
} else {
sel.addRange(originalSelectionRanges[i]);}
}
}
})();}

features.selectionSupportsMultipleRanges = selectionSupportsMultipleRanges;features.collapsedNonEditableSelectionsSupported = collapsedNonEditableSelectionsSupported;
var implementsControlRange = false,testControlRange;
if(body && isHostMethod(body,"createControlRange")){
testControlRange = body.createControlRange();if(util.areHostProperties(testControlRange,["item","add"])){
implementsControlRange = true;}
}
features.implementsControlRange = implementsControlRange;
if(selectionHasAnchorAndFocus){
selectionIsCollapsed = function(sel){
return sel.anchorNode === sel.focusNode && sel.anchorOffset === sel.focusOffset;};} else {
selectionIsCollapsed = function(sel){
return sel.rangeCount ? sel.getRangeAt(sel.rangeCount - 1).collapsed : false;};}

function updateAnchorAndFocusFromRange(sel,range,backward){
var anchorPrefix = backward ? "end" : "start",focusPrefix = backward ? "start" : "end";sel.anchorNode = range[anchorPrefix+"Container"];sel.anchorOffset = range[anchorPrefix+"Offset"];sel.focusNode = range[focusPrefix+"Container"];sel.focusOffset = range[focusPrefix+"Offset"];}

function updateAnchorAndFocusFromNativeSelection(sel){
var nativeSel = sel.nativeSelection;sel.anchorNode = nativeSel.anchorNode;sel.anchorOffset = nativeSel.anchorOffset;sel.focusNode = nativeSel.focusNode;sel.focusOffset = nativeSel.focusOffset;}

function updateEmptySelection(sel){
sel.anchorNode = sel.focusNode = null;sel.anchorOffset = sel.focusOffset = 0;sel.rangeCount = 0;sel.isCollapsed = true;sel._ranges.length = 0;}

function getNativeRange(range){
var nativeRange;if(range instanceof DomRange){
nativeRange = api.createNativeRange(range.getDocument());nativeRange.setEnd(range.endContainer,range.endOffset);nativeRange.setStart(range.startContainer,range.startOffset);} else if(range instanceof WrappedRange){
nativeRange = range.nativeRange;} else if(features.implementsDomRange && (range instanceof dom.getWindow(range.startContainer).Range)){
nativeRange = range;}
return nativeRange;}

function rangeContainsSingleElement(rangeNodes){
if(!rangeNodes.length || rangeNodes[0].nodeType != 1){
return false;}
for(var i = 1,len = rangeNodes.length; i < len;++i){
if(!dom.isAncestorOf(rangeNodes[0],rangeNodes[i])){
return false;}
}
return true;}

function getSingleElementFromRange(range){
var nodes = range.getNodes();if(!rangeContainsSingleElement(nodes)){
throw module.createError("getSingleElementFromRange: range "+range.inspect()+" did not consist of a single element");}
return nodes[0];}

function isTextRange(range){
return !!range && typeof range.text != "undefined";}

function updateFromTextRange(sel,range){
var wrappedRange = new WrappedRange(range);sel._ranges = [wrappedRange];
updateAnchorAndFocusFromRange(sel,wrappedRange,false);sel.rangeCount = 1;sel.isCollapsed = wrappedRange.collapsed;}

function updateControlSelection(sel){
sel._ranges.length = 0;if(sel.docSelection.type == "None"){
updateEmptySelection(sel);} else {
var controlRange = sel.docSelection.createRange();if(isTextRange(controlRange)){
updateFromTextRange(sel,controlRange);} else {
sel.rangeCount = controlRange.length;var range,doc = getDocument(controlRange.item(0));for(var i = 0; i < sel.rangeCount;++i){
range = api.createRange(doc);range.selectNode(controlRange.item(i));sel._ranges.push(range);}
sel.isCollapsed = sel.rangeCount == 1 && sel._ranges[0].collapsed;updateAnchorAndFocusFromRange(sel,sel._ranges[sel.rangeCount - 1],false);}
}
}

function addRangeToControlSelection(sel,range){
var controlRange = sel.docSelection.createRange();var rangeElement = getSingleElementFromRange(range);
var doc = getDocument(controlRange.item(0));var newControlRange = getBody(doc).createControlRange();for(var i = 0,len = controlRange.length; i < len;++i){
newControlRange.add(controlRange.item(i));}
try {
newControlRange.add(rangeElement);} catch (ex){
throw module.createError("addRange(): Element within the specified Range could not be added to control selection (does it have layout?)");}
newControlRange.select();
updateControlSelection(sel);}

var getSelectionRangeAt;
if(isHostMethod(testSelection,"getRangeAt")){
getSelectionRangeAt = function(sel,index){
try {
return sel.getRangeAt(index);} catch (ex){
return null;}
};} else if(selectionHasAnchorAndFocus){
getSelectionRangeAt = function(sel){
var doc = getDocument(sel.anchorNode);var range = api.createRange(doc);range.setStartAndEnd(sel.anchorNode,sel.anchorOffset,sel.focusNode,sel.focusOffset);
if(range.collapsed !== this.isCollapsed){
range.setStartAndEnd(sel.focusNode,sel.focusOffset,sel.anchorNode,sel.anchorOffset);}

return range;};}

function WrappedSelection(selection,docSelection,win){
this.nativeSelection = selection;this.docSelection = docSelection;this._ranges = [];this.win = win;this.refresh();}

WrappedSelection.prototype = api.selectionPrototype;
function deleteProperties(sel){
sel.win = sel.anchorNode = sel.focusNode = sel._ranges = null;sel.rangeCount = sel.anchorOffset = sel.focusOffset = 0;sel.detached = true;}

var cachedRangySelections = [];
function actOnCachedSelection(win,action){
var i = cachedRangySelections.length,cached,sel;while (i--){
cached = cachedRangySelections[i];sel = cached.selection;if(action == "deleteAll"){
deleteProperties(sel);} else if(cached.win == win){
if(action == "delete"){
cachedRangySelections.splice(i,1);return true;} else {
return sel;}
}
}
if(action == "deleteAll"){
cachedRangySelections.length = 0;}
return null;}

var getSelection = function(win){
if(win && win instanceof WrappedSelection){
win.refresh();return win;}

win = getWindow(win,"getNativeSelection");
var sel = actOnCachedSelection(win);var nativeSel = getNativeSelection(win),docSel = implementsDocSelection ? getDocSelection(win) : null;if(sel){
sel.nativeSelection = nativeSel;sel.docSelection = docSel;sel.refresh();} else {
sel = new WrappedSelection(nativeSel,docSel,win);cachedRangySelections.push( { win: win,selection: sel } );}
return sel;};
api.getSelection = getSelection;
api.getIframeSelection = function(iframeEl){
module.deprecationNotice("getIframeSelection()","getSelection(iframeEl)");return api.getSelection(dom.getIframeWindow(iframeEl));};
var selProto = WrappedSelection.prototype;
function createControlSelection(sel,ranges){
var doc = getDocument(ranges[0].startContainer);var controlRange = getBody(doc).createControlRange();for(var i = 0,el,len = ranges.length; i < len;++i){
el = getSingleElementFromRange(ranges[i]);try {
controlRange.add(el);} catch (ex){
throw module.createError("setRanges(): Element within one of the specified Ranges could not be added to control selection (does it have layout?)");}
}
controlRange.select();
updateControlSelection(sel);}

if(!useDocumentSelection && selectionHasAnchorAndFocus && util.areHostMethods(testSelection,["removeAllRanges","addRange"])){
selProto.removeAllRanges = function(){
this.nativeSelection.removeAllRanges();updateEmptySelection(this);};
var addRangeBackward = function(sel,range){
addRangeBackwardToNative(sel.nativeSelection,range);sel.refresh();};
if(selectionHasRangeCount){
selProto.addRange = function(range,direction){
if(implementsControlRange && implementsDocSelection && this.docSelection.type == CONTROL){
addRangeToControlSelection(this,range);} else {
if(isDirectionBackward(direction) && selectionHasExtend){
addRangeBackward(this,range);} else {
var previousRangeCount;if(selectionSupportsMultipleRanges){
previousRangeCount = this.rangeCount;} else {
this.removeAllRanges();previousRangeCount = 0;}
var clonedNativeRange = getNativeRange(range).cloneRange();try {
this.nativeSelection.addRange(clonedNativeRange);} catch (ex){
}

this.rangeCount = this.nativeSelection.rangeCount;
if(this.rangeCount == previousRangeCount+1){

if(api.config.checkSelectionRanges){
var nativeRange = getSelectionRangeAt(this.nativeSelection,this.rangeCount - 1);if(nativeRange && !rangesEqual(nativeRange,range)){
range = new WrappedRange(nativeRange);}
}
this._ranges[this.rangeCount - 1] = range;updateAnchorAndFocusFromRange(this,range,selectionIsBackward(this.nativeSelection));this.isCollapsed = selectionIsCollapsed(this);} else {
this.refresh();}
}
}
};} else {
selProto.addRange = function(range,direction){
if(isDirectionBackward(direction) && selectionHasExtend){
addRangeBackward(this,range);} else {
this.nativeSelection.addRange(getNativeRange(range));this.refresh();}
};}

selProto.setRanges = function(ranges){
if(implementsControlRange && implementsDocSelection && ranges.length > 1){
createControlSelection(this,ranges);} else {
this.removeAllRanges();for(var i = 0,len = ranges.length; i < len;++i){
this.addRange(ranges[i]);}
}
};} else if(isHostMethod(testSelection,"empty") && isHostMethod(testRange,"select") &&    implementsControlRange && useDocumentSelection){

selProto.removeAllRanges = function(){
try {
this.docSelection.empty();
if(this.docSelection.type != "None"){
var doc;if(this.anchorNode){
doc = getDocument(this.anchorNode);} else if(this.docSelection.type == CONTROL){
var controlRange = this.docSelection.createRange();if(controlRange.length){
doc = getDocument( controlRange.item(0) );}
}
if(doc){
var textRange = getBody(doc).createTextRange();textRange.select();this.docSelection.empty();}
}
} catch(ex){}
updateEmptySelection(this);};
selProto.addRange = function(range){
if(this.docSelection.type == CONTROL){
addRangeToControlSelection(this,range);} else {
api.WrappedTextRange.rangeToTextRange(range).select();this._ranges[0] = range;this.rangeCount = 1;this.isCollapsed = this._ranges[0].collapsed;updateAnchorAndFocusFromRange(this,range,false);}
};
selProto.setRanges = function(ranges){
this.removeAllRanges();var rangeCount = ranges.length;if(rangeCount > 1){
createControlSelection(this,ranges);} else if(rangeCount){
this.addRange(ranges[0]);}
};} else {
module.fail("No means of selecting a Range or TextRange was found");return false;}

selProto.getRangeAt = function(index){
if(index < 0 || index >= this.rangeCount){
throw new DOMException("INDEX_SIZE_ERR");} else {
return this._ranges[index].cloneRange();}
};
var refreshSelection;
if(useDocumentSelection){
refreshSelection = function(sel){
var range;if(api.isSelectionValid(sel.win)){
range = sel.docSelection.createRange();} else {
range = getBody(sel.win.document).createTextRange();range.collapse(true);}

if(sel.docSelection.type == CONTROL){
updateControlSelection(sel);} else if(isTextRange(range)){
updateFromTextRange(sel,range);} else {
updateEmptySelection(sel);}
};} else if(isHostMethod(testSelection,"getRangeAt") && typeof testSelection.rangeCount == NUMBER){
refreshSelection = function(sel){
if(implementsControlRange && implementsDocSelection && sel.docSelection.type == CONTROL){
updateControlSelection(sel);} else {
sel._ranges.length = sel.rangeCount = sel.nativeSelection.rangeCount;if(sel.rangeCount){
for(var i = 0,len = sel.rangeCount; i < len;++i){
sel._ranges[i] = new api.WrappedRange(sel.nativeSelection.getRangeAt(i));}
updateAnchorAndFocusFromRange(sel,sel._ranges[sel.rangeCount - 1],selectionIsBackward(sel.nativeSelection));sel.isCollapsed = selectionIsCollapsed(sel);} else {
updateEmptySelection(sel);}
}
};} else if(selectionHasAnchorAndFocus && typeof testSelection.isCollapsed == BOOLEAN && typeof testRange.collapsed == BOOLEAN && features.implementsDomRange){
refreshSelection = function(sel){
var range,nativeSel = sel.nativeSelection;if(nativeSel.anchorNode){
range = getSelectionRangeAt(nativeSel,0);sel._ranges = [range];sel.rangeCount = 1;updateAnchorAndFocusFromNativeSelection(sel);sel.isCollapsed = selectionIsCollapsed(sel);} else {
updateEmptySelection(sel);}
};} else {
module.fail("No means of obtaining a Range or TextRange from the user's selection was found");return false;}

selProto.refresh = function(checkForChanges){
var oldRanges = checkForChanges ? this._ranges.slice(0) : null;var oldAnchorNode = this.anchorNode,oldAnchorOffset = this.anchorOffset;
refreshSelection(this);if(checkForChanges){
var i = oldRanges.length;if(i != this._ranges.length){return true;}
if(this.anchorNode != oldAnchorNode || this.anchorOffset != oldAnchorOffset){return true;}
while (i--){if(!rangesEqual(oldRanges[i],this._ranges[i])){return true;}}
return false;}
};

var removeRangeManually = function(sel,range){
var ranges = sel.getAllRanges();sel.removeAllRanges();for(var i = 0,len = ranges.length; i < len;++i){
if(!rangesEqual(range,ranges[i])){
sel.addRange(ranges[i]);}
}
if(!sel.rangeCount){
updateEmptySelection(sel);}
};
if(implementsControlRange && implementsDocSelection){
selProto.removeRange = function(range){
if(this.docSelection.type == CONTROL){
var controlRange = this.docSelection.createRange();var rangeElement = getSingleElementFromRange(range);
var doc = getDocument(controlRange.item(0));var newControlRange = getBody(doc).createControlRange();var el,removed = false;for(var i = 0,len = controlRange.length; i < len;++i){
el = controlRange.item(i);if(el !== rangeElement || removed){
newControlRange.add(controlRange.item(i));} else {
removed = true;}
}
newControlRange.select();
updateControlSelection(this);} else {
removeRangeManually(this,range);}
};} else {
selProto.removeRange = function(range){
removeRangeManually(this,range);};}

var selectionIsBackward;
if(!useDocumentSelection && selectionHasAnchorAndFocus && features.implementsDomRange){
selectionIsBackward = winSelectionIsBackward;selProto.isBackward = function(){return selectionIsBackward(this);};
} else {
selectionIsBackward = selProto.isBackward = function(){return false;};
}
selProto.isBackwards = selProto.isBackward;
selProto.toString = function(){var rangeTexts = [];for(var i = 0,len = this.rangeCount; i < len;++i){rangeTexts[i] = ""+this._ranges[i];}return rangeTexts.join("");};

function assertNodeInSameDocument(sel,node){
if(sel.win.document != getDocument(node)){throw new DOMException("WRONG_DOCUMENT_ERR");}}
selProto.collapse = function(node,offset){
assertNodeInSameDocument(this,node);var range = api.createRange(node);range.collapseToPoint(node,offset);this.setSingleRange(range);this.isCollapsed = true;};
selProto.collapseToStart = function(){
if(this.rangeCount){
var range = this._ranges[0];this.collapse(range.startContainer,range.startOffset);} else {
throw new DOMException("INVALID_STATE_ERR");}
};

selProto.collapseToEnd = function(){if(this.rangeCount){var range = this._ranges[this.rangeCount - 1];this.collapse(range.endContainer,range.endOffset);} else {throw new DOMException("INVALID_STATE_ERR");}};

selProto.selectAllChildren = function(node){assertNodeInSameDocument(this,node);var range = api.createRange(node);range.selectNodeContents(node);this.setSingleRange(range);};

selProto.deleteFromDocument = function(){
if(implementsControlRange && implementsDocSelection && this.docSelection.type == CONTROL){
var controlRange = this.docSelection.createRange();var element;while (controlRange.length){
element = controlRange.item(0);controlRange.remove(element);element.parentNode.removeChild(element);}
this.refresh();} else if(this.rangeCount){
var ranges = this.getAllRanges();if(ranges.length){
this.removeAllRanges();for(var i = 0,len = ranges.length; i < len;++i){
ranges[i].deleteContents();}
this.addRange(ranges[len - 1]);}
}
};

selProto.eachRange = function(func,returnValue){ for(var i = 0,len = this._ranges.length; i < len;++i){if( func( this.getRangeAt(i) ) ){return returnValue;}} };

selProto.getAllRanges = function(){
var ranges = [];this.eachRange(function(range){
ranges.push(range);});return ranges;};
selProto.setSingleRange = function(range,direction){
this.removeAllRanges();this.addRange(range,direction);};
selProto.callMethodOnEachRange = function(methodName,params){
var results = [];this.eachRange( function(range){
results.push( range[methodName].apply(range,params) );} );return results;
};

function createStartOrEndSetter(isStart){
return function(node,offset){
var range;if(this.rangeCount){
range = this.getRangeAt(0);range["set"+(isStart ? "Start" : "End")](node,offset);} else {
range = api.createRange(this.win.document);range.setStartAndEnd(node,offset);}
this.setSingleRange(range,this.isBackward());};}
selProto.setStart = createStartOrEndSetter(true);selProto.setEnd = createStartOrEndSetter(false);
api.rangePrototype.select = function(direction){
getSelection( this.getDocument() ).setSingleRange(this,direction);};
selProto.changeEachRange = function(func){
var ranges = [];var backward = this.isBackward();
this.eachRange(function(range){
func(range);ranges.push(range);});
this.removeAllRanges();if(backward && ranges.length == 1){
this.addRange(ranges[0],"backward");} else {
this.setRanges(ranges);}
};

selProto.containsNode = function(node,allowPartial){
return this.eachRange( function(range){
return range.containsNode(node,allowPartial);},
true ) || false;};
selProto.getBookmark = function(containerNode){
return {
backward: this.isBackward(),rangeBookmarks: this.callMethodOnEachRange("getBookmark",[containerNode])
};
};

selProto.moveToBookmark = function(bookmark){
var selRanges = [];for(var i = 0,rangeBookmark,range; rangeBookmark = bookmark.rangeBookmarks[i++]; ){
range = api.createRange(this.win);range.moveToBookmark(rangeBookmark);selRanges.push(range);}
if(bookmark.backward){
this.setSingleRange(selRanges[0],"backward");} else {
this.setRanges(selRanges);}
};

selProto.toHtml = function(){var rangeHtmls = [];this.eachRange(function(range){rangeHtmls.push( DomRange.toHtml(range) );});return rangeHtmls.join("");};

if(features.implementsTextRange){
selProto.getNativeTextRange = function(){var sel,textRange;if( (sel = this.docSelection) ){var range = sel.createRange();if(isTextRange(range)){return range;} else {throw module.createError("getNativeTextRange: selection is a control selection"); }} else if(this.rangeCount > 0){return api.WrappedTextRange.rangeToTextRange( this.getRangeAt(0) );} else {throw module.createError("getNativeTextRange: selection contains no range");}};
}

function inspect(sel){
var rangeInspects = [];var anchor = new DomPosition(sel.anchorNode,sel.anchorOffset);var focus = new DomPosition(sel.focusNode,sel.focusOffset);var name = (typeof sel.getName == "function") ? sel.getName() : "Selection";
if(typeof sel.rangeCount != "undefined"){for(var i = 0,len = sel.rangeCount; i < len;++i){rangeInspects[i] = DomRange.inspect(sel.getRangeAt(i));}}
return "["+name+"(Ranges: "+rangeInspects.join(",")+")(anchor: "+anchor.inspect()+",focus: "+focus.inspect()+"]";
};

selProto.getName = function(){
return "WrappedSelection";};
selProto.inspect = function(){
return inspect(this);};
selProto.detach = function(){
actOnCachedSelection(this.win,"delete");deleteProperties(this);};
WrappedSelection.detachAll = function(){
actOnCachedSelection(null,"deleteAll");};
WrappedSelection.inspect = inspect;WrappedSelection.isDirectionBackward = isDirectionBackward;
api.Selection = WrappedSelection;
api.selectionPrototype = selProto;
api.addShimListener(function(win){
if(typeof win.getSelection == "undefined"){
win.getSelection = function(){
return getSelection(win);};}
win = null;});
});

var docReady = false;
var loadHandler = function(e){if(!docReady){docReady = true;if(!api.initialized && api.config.autoInitialize){init();}}};
if(isBrowser){
if(document.readyState == "complete"){
loadHandler();} else {
if(isHostMethod(document,"addEventListener")){
document.addEventListener("DOMContentLoaded",loadHandler,false);}
addListener(window,"load",loadHandler);}
}
return api;},
this);

(function(factory,root){
if(typeof define == "function" && define.amd){
define(["./rangy-core"],factory);} else if(typeof module != "undefined" && typeof exports == "object"){
module.exports = factory( require("rangy") );} else {
factory(root.rangy);}
})(function(rangy){
rangy.createModule("ClassApplier",["WrappedSelection"],function(api,module){
var dom = api.dom;var DomPosition = dom.DomPosition;var contains = dom.arrayContains;var isHtmlNamespace = dom.isHtmlNamespace;
var defaultTagName = "span";
function each(obj,func){
for(var i in obj){
if(obj.hasOwnProperty(i)){
if(func(i,obj[i]) === false){
return false;}
}
}
return true;}

function trim(str){
return str.replace(/^\s\s*/,"").replace(/\s\s*$/,"");}
var hasClass,addClass,removeClass;if(api.util.isHostObject(document.createElement("div"),"classList")){
hasClass = function(el,className){
return el.classList.contains(className);};
addClass = function(el,className){
return el.classList.add(className);};
removeClass = function(el,className){
return el.classList.remove(className);};} else {
hasClass = function(el,className){
return el.className && new RegExp("(?:^|\\s)"+className+"(?:\\s|$)").test(el.className);};
addClass = function(el,className){
if(el.className){
if(!hasClass(el,className)){
el.className+= " "+className;}
} else {
el.className = className;}
};
removeClass = (function(){function replacer(matched,whiteSpaceBefore,whiteSpaceAfter){return (whiteSpaceBefore && whiteSpaceAfter) ? " " : "";}return function(el,className){if(el.className){el.className = el.className.replace(new RegExp("(^|\\s)"+className+"(\\s|$)"),replacer);}};}
)();
}

function sortClassName(className){return className && className.split(/\s+/).sort().join(" ");};

function getSortedClassName(el){return sortClassName(el.className);};

function haveSameClasses(el1,el2){return getSortedClassName(el1) == getSortedClassName(el2);};

function movePosition(position,oldParent,oldIndex,newParent,newIndex){var posNode = position.node,posOffset = position.offset;var newNode = posNode,newOffset = posOffset;if(posNode == newParent && posOffset > newIndex){++newOffset;}if(posNode == oldParent && (posOffset == oldIndex  || posOffset == oldIndex+1)){newNode = newParent;newOffset+= newIndex - oldIndex;}if(posNode == oldParent && posOffset > oldIndex+1){--newOffset;}position.node = newNode;position.offset = newOffset;};

function movePositionWhenRemovingNode(position,parentNode,index){if(position.node == parentNode && position.offset > index){--position.offset;}};

function movePreservingPositions(node,newParent,newIndex,positionsToPreserve){if(newIndex == -1){newIndex = newParent.childNodes.length;}var oldParent = node.parentNode;var oldIndex = dom.getNodeIndex(node);for(var i = 0,position; position = positionsToPreserve[i++]; ){movePosition(position,oldParent,oldIndex,newParent,newIndex);}if(newParent.childNodes.length == newIndex){newParent.appendChild(node);} else {newParent.insertBefore(node,newParent.childNodes[newIndex]);}};

function removePreservingPositions(node,positionsToPreserve){var oldParent = node.parentNode;var oldIndex = dom.getNodeIndex(node);for(var i = 0,position; position = positionsToPreserve[i++]; ){movePositionWhenRemovingNode(position,oldParent,oldIndex);}node.parentNode.removeChild(node);};

function moveChildrenPreservingPositions(node,newParent,newIndex,removeNode,positionsToPreserve){var child,children = [];while ( (child = node.firstChild) ){movePreservingPositions(child,newParent,newIndex++,positionsToPreserve);children.push(child);}if(removeNode){removePreservingPositions(node,positionsToPreserve);}return children;};

function replaceWithOwnChildrenPreservingPositions(element,positionsToPreserve){return moveChildrenPreservingPositions(element,element.parentNode,dom.getNodeIndex(element),true,positionsToPreserve);};

function rangeSelectsAnyText(range,textNode){var textNodeRange = range.cloneRange();textNodeRange.selectNodeContents(textNode);var intersectionRange = textNodeRange.intersection(range);var text = intersectionRange ? intersectionRange.toString() : "";return text != "";};

function getEffectiveTextNodes(range){var nodes = range.getNodes([3]);var start = 0,node;while ( (node = nodes[start]) && !rangeSelectsAnyText(range,node) ){++start;}var end = nodes.length - 1;while ( (node = nodes[end]) && !rangeSelectsAnyText(range,node) ){--end;}return nodes.slice(start,end+1);};

function elementsHaveSameNonClassAttributes(el1,el2){if(el1.attributes.length != el2.attributes.length) return false;for(var i = 0,len = el1.attributes.length,attr1,attr2,name; i < len;++i){attr1 = el1.attributes[i];name = attr1.name;if(name != "class"){attr2 = el2.attributes.getNamedItem(name);if( (attr1 === null) != (attr2 === null) ) return false;if(attr1.specified != attr2.specified) return false;if(attr1.specified && attr1.nodeValue !== attr2.nodeValue) return false;}}return true;};

function elementHasNonClassAttributes(el,exceptions){for(var i = 0,len = el.attributes.length,attrName; i < len;++i){attrName = el.attributes[i].name;if( !(exceptions && contains(exceptions,attrName)) && el.attributes[i].specified && attrName != "class"){return true;}}return false;};

var getComputedStyleProperty = dom.getComputedStyleProperty;var isEditableElement = (function(){
var testEl = document.createElement("div");return typeof testEl.isContentEditable == "boolean" ?
function(node){
return node && node.nodeType == 1 && node.isContentEditable;} :
function(node){
if(!node || node.nodeType != 1 || node.contentEditable == "false"){
return false;}
return node.contentEditable == "true" || isEditableElement(node.parentNode);};}
)();

function isEditingHost(node){var parent;return node && node.nodeType == 1 && (( (parent = node.parentNode) && parent.nodeType == 9 && parent.designMode == "on") ||(isEditableElement(node) && !isEditableElement(node.parentNode)));};
function isEditable(node){return (isEditableElement(node) || (node.nodeType != 1 && isEditableElement(node.parentNode))) && !isEditingHost(node);};
var inlineDisplayRegex = /^inline(-block|-table)?$/i;
function isNonInlineElement(node){return node && node.nodeType == 1 && !inlineDisplayRegex.test(getComputedStyleProperty(node,"display"));};

var htmlNonWhiteSpaceRegex = /[^\r\n\t\f \u200B]/;
function isUnrenderedWhiteSpaceNode(node){
if(node.data.length == 0){
return true;}
if(htmlNonWhiteSpaceRegex.test(node.data)){
return false;}
var cssWhiteSpace = getComputedStyleProperty(node.parentNode,"whiteSpace");switch (cssWhiteSpace){
case "pre":
case "pre-wrap":
case "-moz-pre-wrap":
return false;case "pre-line":
if(/[\r\n]/.test(node.data)){
return false;}
}
return isNonInlineElement(node.previousSibling) || isNonInlineElement(node.nextSibling);
};

function getRangeBoundaries(ranges){var positions = [],i,range;for(i = 0; range = ranges[i++]; ){positions.push(new DomPosition(range.startContainer,range.startOffset),new DomPosition(range.endContainer,range.endOffset));}return positions;};

function updateRangesFromBoundaries(ranges,positions){for(var i = 0,range,start,end,len = ranges.length; i < len;++i){range = ranges[i];start = positions[i * 2];end = positions[i * 2+1];range.setStartAndEnd(start.node,start.offset,end.node,end.offset);}};

function isSplitPoint(node,offset){if(dom.isCharacterDataNode(node)){if(offset == 0){return !!node.previousSibling;} else if(offset == node.length){return !!node.nextSibling;} else {return true;}}return offset > 0 && offset < node.childNodes.length;};

function splitNodeAt(node,descendantNode,descendantOffset,positionsToPreserve){
var newNode,parentNode;var splitAtStart = (descendantOffset == 0);
if(dom.isAncestorOf(descendantNode,node)){return node;}
if(dom.isCharacterDataNode(descendantNode)){
var descendantIndex = dom.getNodeIndex(descendantNode);if(descendantOffset == 0){
descendantOffset = descendantIndex;} else if(descendantOffset == descendantNode.length){
descendantOffset = descendantIndex+1;} else {
throw module.createError("splitNodeAt() should not be called with offset in the middle of a data node ("+
descendantOffset+" in "+descendantNode.data);}
descendantNode = descendantNode.parentNode;}
if(isSplitPoint(descendantNode,descendantOffset)){
newNode = descendantNode.cloneNode(false);parentNode = descendantNode.parentNode;if(newNode.id){
newNode.removeAttribute("id");}
var child,newChildIndex = 0;
while ( (child = descendantNode.childNodes[descendantOffset]) ){
movePreservingPositions(child,newNode,newChildIndex++,positionsToPreserve);}
movePreservingPositions(newNode,parentNode,dom.getNodeIndex(descendantNode)+1,positionsToPreserve);return (descendantNode == node) ? newNode : splitNodeAt(node,parentNode,dom.getNodeIndex(newNode),positionsToPreserve);} else if(node != descendantNode){
newNode = descendantNode.parentNode;
var newNodeIndex = dom.getNodeIndex(descendantNode);
if(!splitAtStart){newNodeIndex++;}
return splitNodeAt(node,newNode,newNodeIndex,positionsToPreserve);}
return node;};

function areElementsMergeable(el1,el2){return el1.namespaceURI == el2.namespaceURI && el1.tagName.toLowerCase() == el2.tagName.toLowerCase() && haveSameClasses(el1,el2) && elementsHaveSameNonClassAttributes(el1,el2) && getComputedStyleProperty(el1,"display") == "inline" && getComputedStyleProperty(el2,"display") == "inline";};

function createAdjacentMergeableTextNodeGetter(forward){
var siblingPropName = forward ? "nextSibling" : "previousSibling";
return function(textNode,checkParentElement){
var el = textNode.parentNode;var adjacentNode = textNode[siblingPropName];if(adjacentNode){
if(adjacentNode && adjacentNode.nodeType == 3){
return adjacentNode;}
} else if(checkParentElement){
adjacentNode = el[siblingPropName];if(adjacentNode && adjacentNode.nodeType == 1 && areElementsMergeable(el,adjacentNode)){
var adjacentNodeChild = adjacentNode[forward ? "firstChild" : "lastChild"];if(adjacentNodeChild && adjacentNodeChild.nodeType == 3){
return adjacentNodeChild;}
}
}
return null;};
};

var getPreviousMergeableTextNode = createAdjacentMergeableTextNodeGetter(false),getNextMergeableTextNode = createAdjacentMergeableTextNodeGetter(true);
function Merge(firstNode){this.isElementMerge = (firstNode.nodeType == 1);this.textNodes = [];var firstTextNode = this.isElementMerge ? firstNode.lastChild : firstNode;if(firstTextNode){this.textNodes[0] = firstTextNode;}};

Merge.prototype = {
doMerge: function(positionsToPreserve){
var textNodes = this.textNodes;var firstTextNode = textNodes[0];if(textNodes.length > 1){
var firstTextNodeIndex = dom.getNodeIndex(firstTextNode);var textParts = [],combinedTextLength = 0,textNode,parent;for(var i = 0,len = textNodes.length,j,position; i < len;++i){
textNode = textNodes[i];parent = textNode.parentNode;if(i > 0){
parent.removeChild(textNode);if(!parent.hasChildNodes()){
parent.parentNode.removeChild(parent);}
if(positionsToPreserve){
for(j = 0; position = positionsToPreserve[j++]; ){
if(position.node == textNode){
position.node = firstTextNode;position.offset+= combinedTextLength;}
if(position.node == parent && position.offset > firstTextNodeIndex){
--position.offset;if(position.offset == firstTextNodeIndex+1 && i < len - 1){
position.node = firstTextNode;position.offset = combinedTextLength;}
}
}
}
}
textParts[i] = textNode.data;combinedTextLength+= textNode.data.length;}
firstTextNode.data = textParts.join("");}
return firstTextNode.data;},

getLength: function(){var i = this.textNodes.length,len = 0;while (i--){len+= this.textNodes[i].length;}return len;},
toString: function(){var textParts = [];for(var i = 0,len = this.textNodes.length; i < len;++i){textParts[i] = "'"+this.textNodes[i].data+"'";}return "[Merge("+textParts.join(",")+")]";}};

var optionProperties = ["elementTagName","ignoreWhiteSpace","applyToEditableOnly","useExistingElements","removeEmptyElements","onElementCreate"];
var attrNamesForProperties = {};
function ClassApplier(className,options,tagNames){
var normalize,i,len,propName,applier = this;applier.cssClass = applier.className = className; 
var elementPropertiesFromOptions = null,elementAttributes = {};
if(typeof options == "object" && options !== null){
if(typeof options.elementTagName !== "undefined"){
options.elementTagName = options.elementTagName.toLowerCase();}
tagNames = options.tagNames;elementPropertiesFromOptions = options.elementProperties;elementAttributes = options.elementAttributes;
for(i = 0; propName = optionProperties[i++]; ){
if(options.hasOwnProperty(propName)){
applier[propName] = options[propName];}
}
normalize = options.normalize;} else {
normalize = options;}
applier.normalize = (typeof normalize == "undefined") ? true : normalize;
applier.attrExceptions = [];var el = document.createElement(applier.elementTagName);applier.elementProperties = applier.copyPropertiesToElement(elementPropertiesFromOptions,el,true);each(elementAttributes,function(attrName){
applier.attrExceptions.push(attrName);});applier.elementAttributes = elementAttributes;
applier.elementSortedClassName = applier.elementProperties.hasOwnProperty("className") ?
sortClassName(applier.elementProperties.className+" "+className) : className;
applier.applyToAnyTagName = false;var type = typeof tagNames;if(type == "string"){
if(tagNames == "*"){
applier.applyToAnyTagName = true;} else {
applier.tagNames = trim(tagNames.toLowerCase()).split(/\s*,\s*/);}
} else if(type == "object" && typeof tagNames.length == "number"){
applier.tagNames = [];for(i = 0,len = tagNames.length; i < len;++i){
if(tagNames[i] == "*"){
applier.applyToAnyTagName = true;} else {
applier.tagNames.push(tagNames[i].toLowerCase());}
}
} else {
applier.tagNames = [applier.elementTagName];}
}

ClassApplier.prototype = {
elementTagName: defaultTagName,elementProperties: {},elementAttributes: {},ignoreWhiteSpace: true,applyToEditableOnly: false,useExistingElements: true,removeEmptyElements: true,onElementCreate: null,

copyPropertiesToElement: function(props,el,createCopy){
var s,elStyle,elProps = {},elPropsStyle,propValue,elPropValue,attrName;
for(var p in props){
if(props.hasOwnProperty(p)){
propValue = props[p];elPropValue = el[p];
if(p == "className"){
addClass(el,propValue);addClass(el,this.className);el[p] = sortClassName(el[p]);if(createCopy){
elProps[p] = propValue;}
} else if(p == "style"){
elStyle = elPropValue;if(createCopy){
elProps[p] = elPropsStyle = {};}
for(s in props[p]){
if(props[p].hasOwnProperty(s)){
elStyle[s] = propValue[s];if(createCopy){
elPropsStyle[s] = elStyle[s];}
}
}
this.attrExceptions.push(p);} else {
el[p] = propValue;if(createCopy){
elProps[p] = el[p];
attrName = attrNamesForProperties.hasOwnProperty(p) ? attrNamesForProperties[p] : p;this.attrExceptions.push(attrName);}
}
}
}
return createCopy ? elProps : "";},

copyAttributesToElement: function(attrs,el){for(var attrName in attrs){if(attrs.hasOwnProperty(attrName)){el.setAttribute(attrName,attrs[attrName]);}}},
hasClass: function(node){return node.nodeType == 1 && (this.applyToAnyTagName || contains(this.tagNames,node.tagName.toLowerCase())) && hasClass(node,this.className);},
getSelfOrAncestorWithClass: function(node){while (node){if(this.hasClass(node)){return node;}node = node.parentNode;}return null;},
isModifiable: function(node){return !this.applyToEditableOnly || isEditable(node);},
isIgnorableWhiteSpaceNode: function(node){return this.ignoreWhiteSpace && node && node.nodeType == 3 && isUnrenderedWhiteSpaceNode(node);},

postApply: function(textNodes,range,positionsToPreserve,isUndo){
var firstNode = textNodes[0],lastNode = textNodes[textNodes.length - 1];
var merges = [],currentMerge;
var rangeStartNode = firstNode,rangeEndNode = lastNode;var rangeStartOffset = 0,rangeEndOffset = lastNode.length;
var textNode,precedingTextNode;
for(var i = 0,len = textNodes.length; i < len;++i){
textNode = textNodes[i];precedingTextNode = getPreviousMergeableTextNode(textNode,!isUndo);if(precedingTextNode){
if(!currentMerge){
currentMerge = new Merge(precedingTextNode);merges.push(currentMerge);}
currentMerge.textNodes.push(textNode);if(textNode === firstNode){
rangeStartNode = currentMerge.textNodes[0];rangeStartOffset = rangeStartNode.length;}
if(textNode === lastNode){rangeEndNode = currentMerge.textNodes[0];rangeEndOffset = currentMerge.getLength();}} else {currentMerge = null;}}
var nextTextNode = getNextMergeableTextNode(lastNode,!isUndo);
if(nextTextNode){if(!currentMerge){currentMerge = new Merge(lastNode);merges.push(currentMerge);}currentMerge.textNodes.push(nextTextNode);}
if(merges.length){for(i = 0,len = merges.length; i < len;++i){merges[i].doMerge(positionsToPreserve);}range.setStartAndEnd(rangeStartNode,rangeStartOffset,rangeEndNode,rangeEndOffset);}
},

createContainer: function(doc){
var el = doc.createElement(this.elementTagName);this.copyPropertiesToElement(this.elementProperties,el,false);this.copyAttributesToElement(this.elementAttributes,el);addClass(el,this.className);if(this.onElementCreate){
this.onElementCreate(el,this);}
return el;},

elementHasProperties: function(el,props){
var applier = this;return each(props,function(p,propValue){
if(p == "className"){
return sortClassName(el.className) == applier.elementSortedClassName;} else if(typeof propValue == "object"){
if(!applier.elementHasProperties(el[p],propValue)){
return false;}
} else if(el[p] !== propValue){
return false;}
});},

applyToTextNode: function(textNode,positionsToPreserve){var parent = textNode.parentNode;if(parent.childNodes.length == 1 && this.useExistingElements && isHtmlNamespace(parent) && contains(this.tagNames,parent.tagName.toLowerCase()) && this.elementHasProperties(parent,this.elementProperties)){
addClass(parent,this.className);} else {var el = this.createContainer(dom.getDocument(textNode));textNode.parentNode.insertBefore(el,textNode);el.appendChild(textNode);}},
isRemovable: function(el){return isHtmlNamespace(el) && el.tagName.toLowerCase() == this.elementTagName && getSortedClassName(el) == this.elementSortedClassName && this.elementHasProperties(el,this.elementProperties) && !elementHasNonClassAttributes(el,this.attrExceptions) && this.isModifiable(el);},
isEmptyContainer: function(el){var childNodeCount = el.childNodes.length;return el.nodeType == 1 && this.isRemovable(el) && (childNodeCount == 0 || (childNodeCount == 1 && this.isEmptyContainer(el.firstChild)));},
removeEmptyContainers: function(range){var applier = this;var nodesToRemove = range.getNodes([1],function(el){return applier.isEmptyContainer(el);});var rangesToPreserve = [range];var positionsToPreserve = getRangeBoundaries(rangesToPreserve);for(var i = 0,node; node = nodesToRemove[i++]; ){removePreservingPositions(node,positionsToPreserve);}
updateRangesFromBoundaries(rangesToPreserve,positionsToPreserve);},

undoToTextNode: function(textNode,range,ancestorWithClass,positionsToPreserve){
if(!range.containsNode(ancestorWithClass)){
var ancestorRange = range.cloneRange();ancestorRange.selectNode(ancestorWithClass);if(ancestorRange.isPointInRange(range.endContainer,range.endOffset)){
splitNodeAt(ancestorWithClass,range.endContainer,range.endOffset,positionsToPreserve);range.setEndAfter(ancestorWithClass);}
if(ancestorRange.isPointInRange(range.startContainer,range.startOffset)){
ancestorWithClass = splitNodeAt(ancestorWithClass,range.startContainer,range.startOffset,positionsToPreserve);}
}
if(this.isRemovable(ancestorWithClass)){
replaceWithOwnChildrenPreservingPositions(ancestorWithClass,positionsToPreserve);} else {
removeClass(ancestorWithClass,this.className);}
},

splitAncestorWithClass: function(container,offset,positionsToPreserve){
var ancestorWithClass = this.getSelfOrAncestorWithClass(container);if(ancestorWithClass){
splitNodeAt(ancestorWithClass,container,offset,positionsToPreserve);}
},

undoToAncestor: function(ancestorWithClass,positionsToPreserve){
if(this.isRemovable(ancestorWithClass)){
replaceWithOwnChildrenPreservingPositions(ancestorWithClass,positionsToPreserve);} else {
removeClass(ancestorWithClass,this.className);}
},

applyToRange: function(range,rangesToPreserve){
rangesToPreserve = rangesToPreserve || [];
var positionsToPreserve = getRangeBoundaries(rangesToPreserve || []);
range.splitBoundariesPreservingPositions(positionsToPreserve);
if(this.removeEmptyElements){
this.removeEmptyContainers(range);}
var textNodes = getEffectiveTextNodes(range);
if(textNodes.length){
for(var i = 0,textNode; textNode = textNodes[i++]; ){
if(!this.isIgnorableWhiteSpaceNode(textNode) && !this.getSelfOrAncestorWithClass(textNode) && this.isModifiable(textNode)){
this.applyToTextNode(textNode,positionsToPreserve);}
}
textNode = textNodes[textNodes.length - 1];range.setStartAndEnd(textNodes[0],0,textNode,textNode.length);if(this.normalize){
this.postApply(textNodes,range,positionsToPreserve,false);}
updateRangesFromBoundaries(rangesToPreserve,positionsToPreserve);}
},

applyToRanges: function(ranges){var i = ranges.length;while (i--){this.applyToRange(ranges[i],ranges);}return ranges;},
applyToSelection: function(win){var sel = api.getSelection(win);sel.setRanges( this.applyToRanges(sel.getAllRanges()) );},

undoToRange: function(range,rangesToPreserve){
rangesToPreserve = rangesToPreserve || [];var positionsToPreserve = getRangeBoundaries(rangesToPreserve);
range.splitBoundariesPreservingPositions(positionsToPreserve);
if(this.removeEmptyElements){
this.removeEmptyContainers(range,positionsToPreserve);}
var textNodes = getEffectiveTextNodes(range);var textNode,ancestorWithClass;var lastTextNode = textNodes[textNodes.length - 1];
if(textNodes.length){
this.splitAncestorWithClass(range.endContainer,range.endOffset,positionsToPreserve);this.splitAncestorWithClass(range.startContainer,range.startOffset,positionsToPreserve);for(var i = 0,len = textNodes.length; i < len;++i){
textNode = textNodes[i];ancestorWithClass = this.getSelfOrAncestorWithClass(textNode);if(ancestorWithClass && this.isModifiable(textNode)){
this.undoToAncestor(ancestorWithClass,positionsToPreserve);}
}
range.setStartAndEnd(textNodes[0],0,lastTextNode,lastTextNode.length);
if(this.normalize){
this.postApply(textNodes,range,positionsToPreserve,true);}
updateRangesFromBoundaries(rangesToPreserve,positionsToPreserve);}
},

undoToRanges: function(ranges){ var i = ranges.length;while (i--){this.undoToRange(ranges[i],ranges);} return ranges; },
undoToSelection: function(win){ var sel = api.getSelection(win);var ranges = api.getSelection(win).getAllRanges();this.undoToRanges(ranges);sel.setRanges(ranges); },
isAppliedToRange: function(range){
if(range.collapsed || range.toString() == ""){
return !!this.getSelfOrAncestorWithClass(range.commonAncestorContainer);} else {
var textNodes = range.getNodes( [3] );if(textNodes.length)
for(var i = 0,textNode; textNode = textNodes[i++]; ){
if(!this.isIgnorableWhiteSpaceNode(textNode) && rangeSelectsAnyText(range,textNode) && this.isModifiable(textNode) && !this.getSelfOrAncestorWithClass(textNode)){
return false;}
}
return true;}
},
isAppliedToRanges: function(ranges){
var i = ranges.length;if(i == 0){
return false;}
while (i--){
if(!this.isAppliedToRange(ranges[i])){
return false;}
}
return true;},


isAppliedToSelection: function(win){var sel = api.getSelection(win);return this.isAppliedToRanges(sel.getAllRanges());},
toggleRange: function(range){if(this.isAppliedToRange(range)){this.undoToRange(range);} else {this.applyToRange(range);}},
toggleSelection: function(win){if(this.isAppliedToSelection(win)){this.undoToSelection(win);} else {this.applyToSelection(win);}},
getElementsWithClassIntersectingRange: function(range){var elements = [];var applier = this;range.getNodes([3],function(textNode){var el = applier.getSelfOrAncestorWithClass(textNode);if(el && !contains(elements,el)){elements.push(el);}});return elements;},
detach: function(){}
};
function createClassApplier(className,options,tagNames){return new ClassApplier(className,options,tagNames);}

ClassApplier.util = { hasClass: hasClass,addClass: addClass,removeClass: removeClass,hasSameClasses: haveSameClasses,replaceWithOwnChildren: replaceWithOwnChildrenPreservingPositions,elementsHaveSameNonClassAttributes: elementsHaveSameNonClassAttributes,elementHasNonClassAttributes: elementHasNonClassAttributes,splitNodeAt: splitNodeAt,isEditableElement: isEditableElement,isEditingHost: isEditingHost,isEditable: isEditable };
api.CssClassApplier = api.ClassApplier = ClassApplier;api.createCssClassApplier = api.createClassApplier = createClassApplier;
}); },this);

(function(w,d){
'use strict';
var rangy = w['rangy'] || null,undo = w['Undo'] || null,key = w.Key = {
'backspace': 8,'tab': 9,'enter': 13,'shift': 16,'ctrl': 17,'alt': 18,'pause': 19,'capsLock': 20,'escape': 27,'pageUp': 33,'pageDown': 34,'end': 35,'home': 36,'leftArrow': 37,'upArrow': 38,'rightArrow': 39,'downArrow': 40,'insert': 45,'delete': 46,'0': 48,'1': 49,'2': 50,'3': 51,'4': 52,'5': 53,'6': 54,'7': 55,'8': 56,'9': 57,'a': 65,'b': 66,'c': 67,'d': 68,'e': 69,'f': 70,'g': 71,'h': 72,'i': 73,'j': 74,'k': 75,'l': 76,'m': 77,'n': 78,'o': 79,'p': 80,'q': 81,'r': 82,'s': 83,'t': 84,'u': 85,'v': 86,'w': 87,'x': 88,'y': 89,'z': 90,'leftWindow': 91,'rightWindowKey': 92,'select': 93,'numpad0': 96,'numpad1': 97,'numpad2': 98,'numpad3': 99,'numpad4': 100,'numpad5': 101,'numpad6': 102,'numpad7': 103,'numpad8': 104,'numpad9': 105,'multiply': 106,'add': 107,'subtract': 109,'decimalPoint': 110,'divide': 111,'f1': 112,'f2': 113,'f3': 114,'f4': 115,'f5': 116,'f6': 117,'f7': 118,'f8': 119,'f9': 120,'f10': 121,'f11': 122,'f12': 123,'numLock': 144,'scrollLock': 145,'semiColon': 186,'equalSign': 187,'comma': 188,'dash': 189,'period': 190,'forwardSlash': 191,'graveAccent': 192,'openBracket': 219,'backSlash': 220,'closeBracket': 221,'singleQuote': 222
},Medium = (function(){

var Medium = function(userSettings){
"use strict";
var medium = this,defaultSettings = utils.deepExtend({},Medium.defaultSettings),settings = this.settings = utils.deepExtend(defaultSettings,userSettings),cache = new Medium.Cache(),selection = new Medium.Selection(),action = new Medium.Action(this),cursor = new Medium.Cursor(this),undoable = new Medium.Undoable(this),el,newVal,i;
for(i in defaultSettings){
if(defaultSettings.hasOwnProperty(i)){if(typeof defaultSettings[i] !== 'object' && defaultSettings.hasOwnProperty(i) && settings.element.getAttribute('data-medium-'+key)){newVal = settings.element.getAttribute('data-medium-'+key);if(newVal.toLowerCase() === "false" || newVal.toLowerCase() === "true"){newVal = newVal.toLowerCase() === "true";}settings[i] = newVal;}}
}

if(settings.modifiers){
for(i in settings.modifiers){
if(settings.modifiers.hasOwnProperty(i)){if(typeof(key[i]) !== 'undefined'){settings.modifiers[key[i]] = settings.modifiers[i];}}
}
}

if(settings.keyContext){for(i in settings.keyContext){if(settings.keyContext.hasOwnProperty(i)){if(typeof(key[i]) !== 'undefined'){settings.keyContext[key[i]] = settings.keyContext[i];}}}}
el = settings.element;
el.contentEditable = true;el.className+= (' '+settings.cssClasses.editor)+(' '+settings.cssClasses.editor+'-'+settings.mode);
settings.tags = (settings.tags || {});if(settings.tags.outerLevel){
settings.tags.outerLevel = settings.tags.outerLevel.concat([settings.tags.paragraph,settings.tags.horizontalRule]);}

this.settings = settings;this.element = el;el.medium = this;
this.action = action;this.cache = cache;this.cursor = cursor;this.utils = utils;this.selection = selection;
medium.clean();medium.placeholders();action.preserveElementFocus();
this.dirty = false;this.undoable = undoable;this.makeUndoable = undoable.makeUndoable;
if(settings.drag){medium.drag = new Medium.Drag(medium);medium.drag.setup();}
action.setup();
cache.initialized = true;
this.makeUndoable(true);
};

Medium.prototype = {
placeholders: function(){
if(!w.getComputedStyle){return;}
var s = this.settings,placeholder = this.placeholder || (this.placeholder = d.createElement('div')),el = this.element,style = placeholder.style,elStyle = w.getComputedStyle(el,null),qStyle = function(prop){
return elStyle.getPropertyValue(prop)
},text = utils.text(el),cursor = this.cursor,childCount = el.children.length,hasFocus = Medium.activeElement === el;
el.placeholder = placeholder;

if( !hasFocus && text.length < 1 && childCount < 2 ){
if(el.placeHolderActive){return;}
if(!el.innerHTML.match('<'+s.tags.paragraph)){el.innerHTML = '';}

if(s.placeholder.length > 0){
if(!placeholder.setup){
placeholder.setup = true;
style.background = qStyle('background');style.backgroundColor = qStyle('background-color');
style.fontSize = qStyle('font-size');style.color = elStyle.color;
style.marginTop = qStyle('margin-top');style.marginBottom = qStyle('margin-bottom');style.marginLeft = qStyle('margin-left');style.marginRight = qStyle('margin-right');
style.paddingTop = qStyle('padding-top');style.paddingBottom = qStyle('padding-bottom');style.paddingLeft = qStyle('padding-left');style.paddingRight = qStyle('padding-right');
style.borderTopWidth = qStyle('border-top-width');style.borderTopColor = qStyle('border-top-color');style.borderTopStyle = qStyle('border-top-style');style.borderBottomWidth = qStyle('border-bottom-width');style.borderBottomColor = qStyle('border-bottom-color');style.borderBottomStyle = qStyle('border-bottom-style');style.borderLeftWidth = qStyle('border-left-width');style.borderLeftColor = qStyle('border-left-color');style.borderLeftStyle = qStyle('border-left-style');style.borderRightWidth = qStyle('border-right-width');style.borderRightColor = qStyle('border-right-color');style.borderRightStyle = qStyle('border-right-style');
placeholder.className = s.cssClasses.placeholder+' '+s.cssClasses.placeholder+'-'+s.mode;placeholder.innerHTML = '<div>'+s.placeholder+'</div>';el.parentNode.insertBefore(placeholder,el);}
el.className+= ' '+s.cssClasses.clear;
style.display = '';style.minHeight = el.clientHeight+'px';style.minWidth = el.clientWidth+'px';
if( s.mode !== Medium.inlineMode && s.mode !== Medium.inlineRichMode ){this.setupContents();if(childCount === 0 && el.firstChild){cursor.set(this,0,el.firstChild);}}
}
el.placeHolderActive = true;
} else if(el.placeHolderActive){
el.placeHolderActive = false;style.display = 'none';el.className = utils.trim(el.className.replace(s.cssClasses.clear,''));this.setupContents();
}
},

clean: function(el){
var s = this.settings,placeholderClass = s.cssClasses.placeholder,attributesToRemove = (s.attributes || {}).remove || [],tags = s.tags || {},onlyOuter = tags.outerLevel || null,onlyInner = tags.innerLevel || null,outerSwitch = {},innerSwitch = {},paragraphTag = (tags.paragraph || '').toUpperCase(),html = this.html,attr,text,j;
el = el || s.element;
if(s.mode === Medium.inlineRichMode){
onlyOuter = s.tags.innerLevel;}
if(onlyOuter !== null){for(j = 0; j < onlyOuter.length; j++){outerSwitch[onlyOuter[j].toUpperCase()] = true;}}
if(onlyInner !== null){for(j = 0; j < onlyInner.length; j++){innerSwitch[onlyInner[j].toUpperCase()] = true;}}
utils.traverseAll(el,{
element: function(child,i,depth,parent){
var nodeName = child.nodeName,shouldDelete = true,attrValue;
for(j = 0; j < attributesToRemove.length; j++){attr = attributesToRemove[j];if(child.hasAttribute(attr)){attrValue = child.getAttribute(attr);if(attrValue !== placeholderClass && (!attrValue.match('medium-') && attr === 'class')){child.removeAttribute(attr);}}}
if( onlyOuter === null && onlyInner === null ){return;}
if(depth  === 1 && outerSwitch[nodeName] !== undefined){shouldDelete = false;} else if(depth > 1 && innerSwitch[nodeName] !== undefined){shouldDelete = false;}
if(shouldDelete){
if(w.getComputedStyle(child,null).getPropertyValue('display') === 'block'){
if(paragraphTag.length > 0 && paragraphTag !== nodeName){utils.changeTag(child,paragraphTag);}
if(depth > 1){
while (parent.childNodes.length > i){parent.parentNode.insertBefore(parent.lastChild,parent.nextSibling);}}
} else {
switch (nodeName){
case 'BR':if(child === child.parentNode.lastChild){if(child === child.parentNode.firstChild){break;}text = d.createTextNode("");text.innerHTML = '&nbsp';child.parentNode.insertBefore(text,child);break;}
default:while (child.firstChild !== null){child.parentNode.insertBefore(child.firstChild,child);}utils.detachNode(child);break;}
}
}
}
});
},

insertHtml: function(html,callback,skipChangeEvent){var result = (new Medium.Html(this,html)).insert(this.settings.beforeInsertHtml),lastElement = result[result.length - 1];if(skipChangeEvent === true){utils.triggerEvent(this.element,"change");}if(callback){callback.apply(result);}switch (lastElement.nodeName){case 'UL':case 'OL':case 'DL':if(lastElement.lastChild !== null){this.cursor.moveCursorToEnd(lastElement.lastChild);break;}default:this.cursor.moveCursorToEnd(lastElement);}return this;},
addTag: function(tag,shouldFocus,isEditable,afterElement){if(!this.settings.beforeAddTag(tag,shouldFocus,isEditable,afterElement)){var newEl = d.createElement(tag),toFocus;if(typeof isEditable !== "undefined" && isEditable === false){newEl.contentEditable = false;}if(newEl.innerHTML.length == 0){newEl.innerHTML = ' ';}if(afterElement && afterElement.nextSibling){afterElement.parentNode.insertBefore(newEl,afterElement.nextSibling);toFocus = afterElement.nextSibling;} else {this.element.appendChild(newEl);toFocus = this.lastChild();}if(shouldFocus){this.cache.focusedElement = toFocus;this.cursor.set(this,0,toFocus);}return newEl;}return null;},
invokeElement: function(tagName,attributes,skipChangeEvent){var settings = this.settings,remove = attributes.remove || [];attributes = attributes || {};switch (settings.mode){case Medium.inlineMode:case Medium.partialMode:return this;default:}if(remove.length > 0){if(!utils.arrayContains(settings,'class')){remove.push('class');}}(new Medium.Element(this,tagName,attributes)).invoke(this.settings.beforeInvokeElement);if(skipChangeEvent === true){utils.triggerEvent(this.element,"change");}return this;},
value: function(value){if(typeof value !== 'undefined'){this.element.innerHTML = value;this.clean();this.placeholders();this.makeUndoable();} else {return this.element.innerHTML;}return this;},
focus: function(){var el = this.element;el.focus();return this;},
select: function(){utils.selectNode(Medium.activeElement = this.element);return this;},
isActive: function(){return (Medium.activeElement === this.element);},
setupContents: function(){var el = this.element,children = el.children,childNodes = el.childNodes,initialParagraph,s = this.settings;if(!s.tags.paragraph || children.length > 0 || s.mode === Medium.inlineMode || s.mode === Medium.inlineRichMode){return Medium.Utilities;}if(childNodes.length > 0){initialParagraph = d.createElement(s.tags.paragraph);if(el.innerHTML.match('^[&]nbsp[;]')){el.innerHTML = el.innerHTML.substring(6,el.innerHTML.length - 1);}initialParagraph.innerHTML = el.innerHTML;el.innerHTML = '';el.appendChild(initialParagraph);} else {initialParagraph = d.createElement(s.tags.paragraph);initialParagraph.innerHTML = '&nbsp;';el.appendChild(initialParagraph);}return this;},
destroy: function(){var el = this.element,settings = this.settings,placeholder = this.placeholder || null;if(placeholder !== null && placeholder.setup){placeholder.parentNode.removeChild(placeholder);delete el.placeHolderActive;}el.removeAttribute('contenteditable');el.className = utils.trim(el.className.replace(settings.cssClasses.editor,'').replace(settings.cssClasses.clear,'').replace(settings.cssClasses.editor+'-'+settings.mode,''));this.action.destroy();if(this.settings.drag){this.drag.destroy();}},
clear: function(){this.element.innerHTML = '';this.placeholders();},
splitAtCaret: function(){if(!this.isActive()){return null;}var selector = (w.getSelection || d.selection),sel = selector(),offset = sel.focusOffset,node = sel.focusNode,el = this.element,range = d.createRange(),endRange = d.createRange(),contents;range.setStart(node,offset);endRange.selectNodeContents(el);range.setEnd(endRange.endContainer,endRange.endOffset);contents = range.extractContents();return contents;},
deleteSelection: function(){if(!this.isActive()){return;}var sel = rangy.getSelection(),range;if(sel.rangeCount > 0){range = sel.getRangeAt(0);range.deleteContents();}},
lastChild: function(){return this.element.lastChild;},
bold: function(){switch (this.settings.mode){case Medium.partialMode:case Medium.inlineMode:return this;}
(new Medium.Element(this,'bold')).setClean(false).invoke(this.settings.beforeInvokeElement);return this;},
underline: function(){switch (this.settings.mode){case Medium.partialMode:case Medium.inlineMode:return this;}
(new Medium.Element(this,'underline')).setClean(false).invoke(this.settings.beforeInvokeElement);return this;},
italicize: function(){switch (this.settings.mode){case Medium.partialMode:case Medium.inlineMode:return this;}
(new Medium.Element(this,'italic')).setClean(false).invoke(this.settings.beforeInvokeElement);return this;},
quote: function(){return this;},
paste: function(text){var value = this.value(),length = value.length,totalLength,settings = this.settings,selection = this.selection,el = this.element,medium = this,postPaste = function(text){text = text || '';if(text.length > 0){el.focus();Medium.activeElement = el;selection.restoreSelection(sel);text = utils.encodeHtml(text);totalLength = text.length+length;if(settings.maxLength > 0 && totalLength > settings.maxLength){text = text.substring(0,settings.maxLength - length);}if(settings.mode !== Medium.inlineMode){text = text.replace(/\n/g,'<br>');}(new Medium.Html(medium,text)).setClean(false).insert(settings.beforeInsertHtml,true);medium.clean();medium.placeholders();}};medium.makeUndoable();if(text !== undefined){postPaste(text);} else if(settings.pasteAsText){var sel = selection.saveSelection();utils.pasteHook(this,postPaste);} else {setTimeout(function(){medium.clean();medium.placeholders();},20);}return true;},
undo: function(){var undoable = this.undoable,stack = undoable.stack,can = stack.canUndo();if(can){stack.undo();}return this;},
redo: function(){var undoable = this.undoable,stack = undoable.stack,can = stack.canRedo();if(can){stack.redo();}return this;}
};
Medium.inlineMode = 'inline';Medium.partialMode = 'partial';Medium.richMode = 'rich';Medium.inlineRichMode = 'inlineRich';Medium.Messages = {pastHere: 'Paste Here'};
Medium.defaultSettings = {
element: null,modifier: 'auto',placeholder: "",autofocus: false,autoHR: true,mode: Medium.richMode,maxLength: -1,modifiers: {'b': 'bold','i': 'italicize','u': 'underline'},tags: {'break': 'br','horizontalRule': 'hr','paragraph': 'p','outerLevel': ['pre','blockquote','figure'],'innerLevel': ['a','b','u','i','img','strong']},cssClasses: {
editor: 'Medium',pasteHook: 'Medium-paste-hook',placeholder: 'Medium-placeholder',clear: 'Medium-clear'
},attributes: {
remove: ['style','class']
},pasteAsText: true,beforeInvokeElement: function(){
},beforeInsertHtml: function(){
},maxLengthReached: function(element){
},beforeAddTag: function(tag,shouldFocus,isEditable,afterElement){
},keyContext: null,drag: false
};

(function(Medium,w,d){
"use strict";
function isEditable(e){if(e.hasOwnProperty('target') && e.target.getAttribute('contenteditable') === 'false'){utils.preventDefaultEvent(e);return false;}return true;}

Medium.Action = function(medium){
this.medium = medium;
this.handledEvents = {
keydown: null,keyup: null,blur: null,focus: null,paste: null,click: null
};
};Medium.Action.prototype = {
setup: function(){
this
.handleFocus()
.handleBlur()
.handleKeyDown()
.handleKeyUp()
.handlePaste()
.handleClick();},

destroy: function(){
var el = this.medium.element;
utils
.removeEvent(el,'focus',this.handledEvents.focus)
.removeEvent(el,'blur',this.handledEvents.blur)
.removeEvent(el,'keydown',this.handledEvents.keydown)
.removeEvent(el,'keyup',this.handledEvents.keyup)
.removeEvent(el,'paste',this.handledEvents.paste)
.removeEvent(el,'click',this.handledEvents.click);},

handleFocus: function(){

var medium = this.medium,el = medium.element;
utils.addEvent(el,'focus',this.handledEvents.focus = function(e){
e = e || w.event;
if(!isEditable(e)){return false;}

Medium.activeElement = el;
medium.placeholders();});
return this;},

handleBlur: function(){
var medium = this.medium,el = medium.element;
utils.addEvent(el,'blur',this.handledEvents.blur = function(e){
e = e || w.event;
if(Medium.activeElement === el){
Medium.activeElement = null;}

medium.placeholders();});
return this;},


handleKeyDown: function(){
var action = this,medium = this.medium,settings = medium.settings,cache = medium.cache,el = medium.element;
utils.addEvent(el,'keydown',this.handledEvents.keydown = function(e){
e = e || w.event;
if(!isEditable(e)){return false;}

var keepEvent = true;
if(e.keyCode === 229){return;}
utils.isCommand(settings,e,function(){cache.cmd = true;},function(){cache.cmd = false;});
utils.isShift(e,function(){cache.shift = true;},

function(){
cache.shift = false;});
utils.isModifier(settings,e,function(cmd){
if(cache.cmd){

if( (settings.mode === Medium.inlineMode) || (settings.mode === Medium.partialMode) ){
utils.preventDefaultEvent(e);return false;}

var cmdType = typeof cmd;var fn = null;if(cmdType === "function"){
fn = cmd;} else {
fn = medium[cmd];}

keepEvent = fn.call(medium,e);
if(keepEvent === false || keepEvent === medium){
utils.preventDefaultEvent(e);utils.stopPropagation(e);}
return true;}
return false;});
if(settings.maxLength !== -1){
var len = utils.text(el).length,hasSelection = false,selection = w.getSelection(),isSpecial = utils.isSpecial(e),isNavigational = utils.isNavigational(e);
if(selection){
hasSelection = !selection.isCollapsed;}

if(isSpecial || isNavigational){return true;}
if(len >= settings.maxLength && !hasSelection){settings.maxLengthReached(el);utils.preventDefaultEvent(e);return false;}}

switch (e.keyCode){
case key['enter']:
if(action.enterKey(e) === false){
utils.preventDefaultEvent(e);}
break;case key['backspace']:
case key['delete']:
action.backspaceOrDeleteKey(e);break;}
return keepEvent;});
return this;},

handleKeyUp: function(){
var action = this,medium = this.medium,settings = medium.settings,cache = medium.cache,cursor = medium.cursor,el = medium.element;
utils.addEvent(el,'keyup',this.handledEvents.keyup = function(e){
e = e || w.event;
if(!isEditable(e)){return false;}
utils.isCommand(settings,e,function(){
cache.cmd = false;},

function(){
cache.cmd = true;});medium.clean();medium.placeholders();
var keyContext;if(
settings.keyContext !== null&& ( keyContext = settings.keyContext[e.keyCode] )
){
var el = cursor.parent();
if(el){
keyContext.call(medium,e,el);}
}

action.preserveElementFocus();});
return this;},

handlePaste: function(){
var medium = this.medium,el = medium.element,text,i,max,data,cD,type,types;
utils.addEvent(el,'paste',this.handledEvents.paste = function(e){
e = e || w.event;
if(!isEditable(e)){return false;}

i = 0;utils.preventDefaultEvent(e);text = '';cD = e.clipboardData;
if(cD && (data = cD.getData)){
types = cD.types;max = types.length;for(i = 0; i < max; i++){
type = types[i];switch (type){
case 'text/plain':
return medium.paste(cD.getData('text/plain'));}
}
}

medium.paste();});
return this;},

handleClick: function(){
var medium = this.medium,el = medium.element,cursor = medium.cursor;
utils.addEvent(el,'click',this.handledEvents.click = function(e){
if(!isEditable(e)){cursor.caretToAfter(e.target);}
});
return this;},

enterKey: function(e){
var medium = this.medium,el = medium.element,settings = medium.settings,cache = medium.cache,cursor = medium.cursor;
if( settings.mode === Medium.inlineMode || settings.mode === Medium.inlineRichMode ){return false;}

if(cache.shift){
if(settings.tags['break']){medium.addTag(settings.tags['break'],true);return false;}
} else {

var focusedElement = utils.atCaret(medium) || {},children = el.children,lastChild = focusedElement === el.lastChild ? el.lastChild : null,makeHR,secondToLast,paragraph;
if(
lastChild&& lastChild !== el.firstChild&& settings.autoHR&& settings.mode !== Medium.partialMode&& settings.tags.horizontalRule
){

utils.preventDefaultEvent(e);
makeHR =
utils.text(lastChild) === ""&& lastChild.nodeName.toLowerCase() === settings.tags.paragraph;
if(makeHR && children.length >= 2){
secondToLast = children[ children.length - 2 ];
if(secondToLast.nodeName.toLowerCase() === settings.tags.horizontalRule){
makeHR = false;}
}

if(makeHR){medium.addTag(settings.tags.horizontalRule,false,true,focusedElement);focusedElement = focusedElement.nextSibling;}
if((paragraph = medium.addTag(settings.tags.paragraph,true,null,focusedElement)) !== null){paragraph.innerHTML = '';cursor.set(medium,0,paragraph);}
}
}
return true;
},

backspaceOrDeleteKey: function(e){
var medium = this.medium,settings = medium.settings,el = medium.element;
if(settings.onBackspaceOrDelete !== undefined){
var result = settings.onBackspaceOrDelete.call(medium,e,el);
if(result){return;}
}
if(el.lastChild === null){return;}
var lastChild = el.lastChild,beforeLastChild = lastChild.previousSibling;
if(lastChild&& settings.tags.horizontalRule&& lastChild.nodeName.toLocaleLowerCase() === settings.tags.horizontalRule){
el.removeChild(lastChild);
} else if(lastChild&& beforeLastChild&& utils.text(lastChild).length < 1&& beforeLastChild.nodeName.toLowerCase() === settings.tags.horizontalRule&& lastChild.nodeName.toLowerCase() === settings.tags.paragraph){
el.removeChild(lastChild);el.removeChild(beforeLastChild);
}
},

preserveElementFocus: function(){
var anchorNode = w.getSelection ? w.getSelection().anchorNode : d.activeElement;if(anchorNode){
var medium = this.medium,cache = medium.cache,el = medium.element,s = medium.settings,cur = anchorNode.parentNode,children = el.children,diff = cur !== cache.focusedElement,elementIndex = 0,i;
if(cur === s.element){
cur = anchorNode;}
for(i = 0; i < children.length; i++){if(cur === children[i]){elementIndex = i;break;}}
if(diff){cache.focusedElement = cur;cache.focusedElementIndex = elementIndex;}
}
}
};
})(Medium,w,d);

(function(Medium){"use strict";Medium.Cache = function(){this.initialized = false;this.cmd = false;this.focusedElement = null};})(Medium);

(function(Medium){
"use strict";
Medium.Cursor = function(medium){this.medium = medium;};
Medium.Cursor.prototype = {
set: function(pos,el){
var range;
if(d.createRange){
var selection = w.getSelection(),lastChild = this.medium.lastChild(),length = utils.text(lastChild).length - 1,toModify = el ? el : lastChild,theLength = ((typeof pos !== 'undefined') && (pos !== null) ? pos : length);
range = d.createRange();range.setStart(toModify,theLength);range.collapse(true);selection.removeAllRanges();selection.addRange(range);} else {
range = d.body.createTextRange();range.moveToElementText(el);range.collapse(false);range.select();}
},

moveCursorToEnd: function(el){
var selection = rangy.getSelection(),
range = rangy.createRange();
range.setStartAfter(el);range.setEnd(el,el.length || el.childNodes.length);
selection.removeAllRanges();selection.addRange(range);
},

moveCursorToAfter: function(el){
var sel = rangy.getSelection();if(sel.rangeCount){
var range = sel.getRangeAt(0);range.collapse(false);range.collapseAfter(el);sel.setSingleRange(range);}
},

parent: function(){
var target = null,range;
if(w.getSelection){range = w.getSelection().getRangeAt(0);target = range.commonAncestorContainer;target = (target.nodeType === 1? target: target.parentNode);} else if(d.selection){target = d.selection.createRange().parentElement();}
if(target.tagName == 'SPAN'){target = target.parentNode;}
return target;
},

caretToBeginning: function(el){this.set(0,el);},
caretToEnd: function(el){this.moveCursorToEnd(el);},
caretToAfter: function(el){this.moveCursorToAfter(el);}
};
})(Medium);

(function(Medium){
"use strict";Medium.Drag = function(medium){
this.medium = medium;
var that = this,iconSrc = this.iconSrc.replace(/[{][{]([a-zA-Z]+)[}][}]/g,function(ignore,match){if(that.hasOwnProperty(match)){return that[match];}return ignore;}),icon = this.icon = d.createElement('img');
icon.className = this.buttonClass;icon.setAttribute('contenteditable','false');icon.setAttribute('src',iconSrc);
this.hide();this.element = null;this.protectedElement = null;this.handledEvents = {dragstart: null,dragend: null,mouseover: null,mouseout: null,mousemove: null};};Medium.Drag.prototype = {
elementClass: 'Medium-focused',buttonClass: 'Medium-drag',
iconSrc: 'data:image/svg+xml;utf8,\
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="21.424px" height="21.424px" viewBox="0 0 21.424 21.424" style="enable-background:new 0 0 21.424 21.424;" xml:space="preserve">\
<g>\
<g>\
<path style="fill:{{iconColor}};" d="M13.616,17.709L13.616,17.709h0.781l-3.686,3.715l-3.685-3.715h0.781l0,0H13.616z M13.616,17.709 M14.007,17.709 M12.555,19.566 M8.87,19.566 M7.418,17.709 M7.809,17.709 M10.712,17.709"/>\
<path style="fill:{{iconColor}};" d="M13.616,3.715L13.616,3.715h0.781L10.712,0L7.027,3.715h0.781l0,0H13.616z M13.616,3.715 M14.007,3.715 M12.555,1.858 M8.87,1.858 M7.418,3.715 M7.809,3.715 M10.712,3.715"/>\
<path style="fill:{{iconColor}};" d="M3.716,13.616L3.716,13.616v0.781L0,10.712l3.716-3.685v0.781l0,0V13.616z M3.716,13.616 M3.716,14.007 M1.858,12.555 M1.858,8.87 M3.716,7.417 M3.716,7.808 M3.716,10.712"/>\
<path style="fill:{{iconColor}};" d="M17.709,13.616L17.709,13.616v0.781l3.715-3.685l-3.715-3.685v0.781l0,0V13.616z M17.709,13.616 M17.709,14.007 M19.566,12.555 M19.566,8.87 M17.709,7.417 M17.709,7.808 M17.709,10.712"/>\
</g>\
<path style="fill-rule:evenodd;clip-rule:evenodd;fill:{{iconColor}};" d="M10.712,6.608c2.267,0,4.104,1.838,4.104,4.104 c0,2.266-1.837,4.104-4.104,4.104c-2.266,0-4.104-1.837-4.104-4.104C6.608,8.446,8.446,6.608,10.712,6.608L10.712,6.608z M10.712,7.515c-1.765,0-3.196,1.432-3.196,3.197s1.432,3.197,3.196,3.197c1.766,0,3.197-1.432,3.197-3.197 S12.478,7.515,10.712,7.515z"/>\
</g>\
</svg>',iconColor: '#231F20',setup: function(){this.handleDragstart().handleDragend().handleMouseover().handleMouseout().handleMousemove();},

destroy: function(){utils.removeEvent(this.icon,'dragstart',this.handledEvents.dragstart).removeEvent(this.icon,'dragend',this.handledEvents.dragend).removeEvent(this.icon,'mouseover',this.handledEvents.mouseover).removeEvent(this.icon,'mouseout',this.handledEvents.mouseout).removeEvent(this.medium.element,'mousemove',this.handledEvents.mousemove);},
hide: function(){utils.hide(this.icon);},

handleDragstart: function(){
var me = this;
utils.addEvent(this.icon,'dragstart',this.handledEvents.dragstart = function(e){
if(me.protectedElement !== null){return;}
e = e || w.event;
me.protectedElement = utils.detachNode(me.element);
me.icon.style.opacity = 0.00;});
return this;},

handleDragend: function(){
var me = this;
utils.addEvent(this.icon,'dragend', this.handledEvents.dragend = d.body.ondragend = function(e){
if(me.protectedElement === null){return;}
setTimeout(function(){me.cleanCanvas();me.protectedElement = null;},1);});
return this;
},

handleMouseover: function(){
var me = this;
utils.addEvent(this.icon,'mouseover',this.handledEvents.mouseover = function(e){
if(me.protectedElement !== null){return;}
utils.stopPropagation(e).addClass(me.element,me.elementClass);
});
return this;
},

handleMouseout: function(){
var me = this;
utils.addEvent(this.icon,'mouseout',this.handledEvents.mouseout = function(e){
if(me.protectedElement !== null){return;}
utils.stopPropagation(e).removeClass(me.element,me.elementClass);});return this;
},

handleMousemove: function(){
var me = this;
utils.addEvent(this.medium.element,'mousemove',this.handledEvents.mousemove = function(e){
e = e || w.event;var target = e.target || {};
if(target.getAttribute('contenteditable') === 'false'){me.show(target);}
});
return this;
},

show: function(el){
if(el === this.icon && this.protectedElement === null){return;}
this.element = el;
var style = this.icon.style,left = el.offsetLeft,top = el.offsetTop;
el.dragIcon = this.icon;el.parentNode.appendChild(this.icon);
style.opacity = 1;style.left = left+'px';style.top = top+'px';
utils.show(this.icon);
},

cleanCanvas: function(){
var target,inserted = false,buttons = d.getElementsByClassName(this.buttonClass);
this.icon.style.opacity = 1;
while (buttons.length > 0){
if(utils.isVisible(target = buttons[0])){
if(!inserted){
target.parentNode.insertBefore(this.element,target);inserted = true;}
utils.detachNode(target);}
}
utils.detachNode(this.icon);}
};
})(Medium);

(function(Medium){
"use strict";

Medium.Element = function(medium,tagName,attributes){
this.medium = medium;this.element = medium.element;
switch (tagName.toLowerCase()){
case 'bold':
this.tagName = 'b';break;case 'italic':
this.tagName = 'i';break;case 'underline':
this.tagName = 'u';break;default:
this.tagName = tagName;}
this.attributes = attributes || {};this.clean = true;};
Medium.Element.prototype = {
invoke: function(fn){
if(Medium.activeElement === this.element){
if(fn){fn.apply(this);}
var attr = this.attributes,tagName = this.tagName.toLowerCase(),applier,cl;
if(attr.className !== undefined){cl = (attr.className.split[' '] || [attr.className]).shift();delete attr.className;} else {cl = 'medium-'+tagName;}
applier = rangy.createClassApplier(cl,{
elementTagName: tagName,elementAttributes: this.attributes
});
this.medium.makeUndoable();
applier.toggleSelection(w);
if(this.clean){this.medium.clean();this.medium.placeholders();}
}
},

setClean: function(clean){this.clean = clean;return this;}
};
})(Medium);

(function(Medium){
"use strict";
Medium.Html = function(medium,html){this.html = html;this.medium = medium;this.clean = true;this.injector = new Medium.Injector();};
Medium.Html.prototype = {
insert: function(fn,selectInserted){
if(Medium.activeElement === this.medium.element){if(fn){fn.apply(this);}var inserted = this.injector.inject(this.html,selectInserted);if(this.clean){this.medium.clean();this.medium.placeholders();}this.medium.makeUndoable();return inserted;} else {return null;}
},
setClean: function(clean){this.clean = clean;return this;}
};
})(Medium);

(function(Medium){
"use strict";
Medium.Injector = function(){};
Medium.Injector.prototype = {

inject: function(htmlRaw){
var nodes = [],html,isConverted = false;
if(typeof htmlRaw === 'string'){var htmlConverter = d.createElement('div');htmlConverter.innerHTML = htmlRaw;html = htmlConverter.childNodes;isConverted = true;} else {html = htmlRaw;}
this.insertHTML('<span id="Medium-wedge"></span>');
var wedge = d.getElementById('Medium-wedge'),parent = wedge.parentNode,i = 0;
wedge.removeAttribute('id');
if(isConverted){
while (i < html.length){nodes.push(html[i]);i++;}while (html.length > 0){parent.insertBefore(html[0],wedge);} ////rjc parent.insertBefore(html[html.length - 1]
} else {
nodes.push(html);parent.insertBefore(html,wedge);
}
parent.removeChild(wedge);wedge = null;return nodes;
},

insertHTML: function(html,selectPastedContent){
var sel,range;if(w.getSelection){
sel = w.getSelection();
if(sel.getRangeAt && sel.rangeCount){
range = sel.getRangeAt(0);range.deleteContents();
var el = d.createElement("div");el.innerHTML = html;var frag = d.createDocumentFragment(),node,lastNode;
while ( (node = el.firstChild)){lastNode = frag.appendChild(node);}var firstNode = frag.firstChild;range.insertNode(frag);if(lastNode){range = range.cloneRange();range.setStartAfter(lastNode);if(selectPastedContent){range.setStartBefore(firstNode);} else {range.collapse(true);}sel.removeAllRanges();sel.addRange(range);} }
} else if((sel = d.selection) && sel.type != "Control"){
var originalRange = sel.createRange();originalRange.collapse(true);sel.createRange().pasteHTML(html);
if(selectPastedContent){range = sel.createRange();range.setEndPoint("StartToStart",originalRange);range.select();}
}
}
};
})(Medium);

(function(Medium){
"use strict";
Medium.Selection = function(){};
Medium.Selection.prototype = {
saveSelection: function(){ if(w.getSelection){var sel = w.getSelection();if(sel.rangeCount > 0){return sel.getRangeAt(0);}} else if(d.selection && d.selection.createRange){ return d.selection.createRange();}return null; },
restoreSelection: function(range){ if(range){if(w.getSelection){var sel = w.getSelection();sel.removeAllRanges();sel.addRange(range);} else if(d.selection && range.select){ range.select();}} }
};})(Medium);

(function(Medium){
"use strict";
Medium.Toolbar = function(medium,buttons){
this.medium = medium;
var elementCreator = d.createElement('div');
elementCreator.innerHTML = this.html;
this.buttons = buttons;this.element = elementCreator.children[0];d.body.appendChild(this.element);this.active = false;this.busy = true;
this.handledEvents = {scroll: null,mouseup: null,keyup: null};
};

Medium.Toolbar.prototype = {
fixedClass: 'Medium-toolbar-fixed',showClass: 'Medium-toolbar-show',hideClass: 'Medium-toolbar-hide',
html:
'<div class="Medium-toolbar">\
<div class="Medium-tail-outer">\
<div class="Medium-tail-inner"></div>\
</div>\
<div id="Medium-buttons"></div>\
<table id="Medium-options">\
<tbody>\
<tr>\
</tr>\
</tbody>\
</table>\
</div>',
setup: function(){this.handleScroll().handleMouseup().handleKeyup();},destroy: function(){utils.removeEvent(w,'scroll',this.handledEvents.scroll).removeEvent(d,'mouseup',this.handledEvents.mouseup).removeEvent(d,'keyup',this.handledEvents.keyup);},
handleScroll: function(){var me = this;utils.addEvent(w,'scroll',this.handledEvents.scroll = function(){if(me.active){me.goToSelection();}});return this;},
handleMouseup: function(){var me = this;utils.addEvent(d,'mouseup',this.handledEvents.mouseup = function(){if(Medium.activeElement === me.medium.element && !me.busy){me.goToSelection();}});return this;},
handleKeyup: function(){var me = this;utils.addEvent(d,'keyup',this.handledEvents.keyup = function(){if(Medium.activeElement === me.medium.element && !me.busy){me.goToSelection();} });return this;},
goToSelection: function(){ var high = this.getHighlighted(),y = high.boundary.top - 5,el = this.element,style = el.style;if(w.scrollTop > 0){utils.addClass(el,this.fixedClass);} else {utils.removeClass(el,this.fixedClass);}if(high !== null){if(high.range.startOffset === high.range.endOffset && !high.text){utils.removeClass(el,this.showClass).addClass(el,this.hideClass);this.active = false;} else {utils.removeClass(el,this.hideClass).removeClass(el,this.showClass);style.opacity = 0.01;utils.addClass(el,this.showClass);style.opacity = 1;style.top = (y - 65)+"px";style.left = ((high.boundary.left+(high.boundary.width / 2))- (el.clientWidth / 2))+"px";this.active = true;}} },
getHighlighted: function(){var selection = w.getSelection(),range = (selection.anchorNode ? selection.getRangeAt(0) : false);if(!range){return null;}return { selection : selection,range : range,text : utils.trim(range.toString()),boundary : range.getBoundingClientRect() };}
};
})(Medium);

(function(Medium){
"use strict";
Medium.Undoable = function(medium){
var me = this,element = medium.settings.element,timer,startValue,stack = new Undo.Stack(),
EditCommand = Undo.Command.extend({
constructor: function(oldValue,newValue){this.oldValue = oldValue;this.newValue = newValue;},
execute: function(){},
undo: function(){element.innerHTML = this.oldValue;medium.canUndo = stack.canUndo();medium.canRedo = stack.canRedo();medium.dirty = stack.dirty();},
redo: function(){ element.innerHTML = this.newValue;medium.canUndo = stack.canUndo();medium.canRedo = stack.canRedo();medium.dirty = stack.dirty();} }),
makeUndoable = function(isInit){
var newValue = element.innerHTML;if(isInit){startValue = element.innerHTML;stack.execute(new EditCommand(startValue,startValue));} else if(newValue != startValue){if(!me.movingThroughStack){stack.execute(new EditCommand(startValue,newValue));startValue = newValue;medium.dirty = stack.dirty();}utils.triggerEvent(medium.settings.element,"change");}
};
this.medium = medium;this.timer = timer;this.stack = stack;this.makeUndoable = makeUndoable;this.EditCommand = EditCommand;this.movingThroughStack = false;
utils.addEvent(element,'keyup',function(e){if(e.ctrlKey || e.keyCode === key.z){utils.preventDefaultEvent(e);return;}clearTimeout(timer);timer = setTimeout(function(){makeUndoable();},250);}).addEvent(element,'keydown',function(e){if(!e.ctrlKey || e.keyCode !== key.z){me.movingThroughStack = false;return;}utils.preventDefaultEvent(e);me.movingThroughStack = true;if( e.shiftKey){stack.canRedo() && stack.redo() } else {stack.canUndo() && stack.undo();} });
};
})(Medium);

(function(Medium){
"use strict";
Medium.Utilities = {
isCommand: function(s,e,fnTrue,fnFalse){if((s.modifier === 'ctrl' && e.ctrlKey ) || (s.modifier === 'cmd' && e.metaKey ) || (s.modifier === 'auto' && (e.ctrlKey || e.metaKey) ) ){return fnTrue.call();} else {return fnFalse.call();} },
isShift: function(e,fnTrue,fnFalse){if(e.shiftKey){return fnTrue.call();} else {return fnFalse.call();} },
isModifier: function(settings,e,fn){var cmd = settings.modifiers[e.keyCode];if(cmd){return fn.call(null,cmd);}return false;},
special: (function(){var special = {};special[key['backspace']] = true;special[key['shift']] = true;special[key['ctrl']] = true;special[key['alt']] = true;special[key['delete']] = true;special[key['cmd']] = true;return special;}
)(),
isSpecial: function(e){return typeof Medium.Utilities.special[e.keyCode] !== 'undefined';},
navigational: (function(){var navigational = {};navigational[key['upArrow']] = true;navigational[key['downArrow']] = true;navigational[key['leftArrow']] = true;navigational[key['rightArrow']] = true;return navigational;})(),
isNavigational: function(e){return typeof Medium.Utilities.navigational[e.keyCode] !== 'undefined';},
addEvents: function(element,eventNamesString,func){var i = 0,eventName,eventNames = eventNamesString.split(' '),max = eventNames.length,utils = Medium.Utilities;for(;i < max; i++){eventName = eventNames[i];if(eventName.length > 0){utils.addEvent(element,eventName,func);}}return Medium.Utilities;},
addEvent: function addEvent(element,eventName,func){if(element.addEventListener){element.addEventListener(eventName,func,false);} else if(element.attachEvent){element.attachEvent("on"+eventName,func);} else {element['on'+eventName] = func;}return Medium.Utilities;},
removeEvent: function removeEvent(element,eventName,func){if(element.removeEventListener){element.removeEventListener(eventName,func,false);} else if(element.detachEvent){element.detachEvent("on"+eventName,func);} else {element['on'+eventName] = null;}return Medium.Utilities;},
preventDefaultEvent: function(e){if(e.preventDefault){e.preventDefault();} else {e.returnValue = false;}return Medium.Utilities;},
stopPropagation: function(e){e = e || window.event;e.cancelBubble = true;if(e.stopPropagation !== undefined){e.stopPropagation();}return Medium.Utilities;},
isEventSupported: function(element,eventName){eventName = 'on'+eventName;var el = d.createElement(element.tagName),isSupported = (eventName in el);if(!isSupported){el.setAttribute(eventName,'return;');isSupported = typeof el[eventName] == 'function';}el = null;return isSupported;},
triggerEvent: function(element,eventName){var e;if(d.createEvent){e = d.createEvent("HTMLEvents");e.initEvent(eventName,true,true);e.eventName = eventName;element.dispatchEvent(e);} else {e = d.createEventObject();element.fireEvent("on"+eventName,e);}return Medium.Utilities;},
deepExtend: function(destination,source){var property,propertyValue;for(property in source) if(source.hasOwnProperty(property)){propertyValue = source[property];if(propertyValue !== undefined&& propertyValue !== null&& propertyValue.constructor !== undefined&& propertyValue.constructor === Object){destination[property] = destination[property] || {};Medium.Utilities.deepExtend(destination[property],propertyValue);} else {destination[property] = propertyValue;}}return destination;},
pasteHook: function(medium,fn){medium.makeUndoable();var tempEditable = d.createElement('div'),el = medium.element,existingValue,existingLength,overallLength,s = medium.settings,value,body = d.body,bodyParent = body.parentNode,scrollTop = bodyParent.scrollTop,scrollLeft = bodyParent.scrollLeft;tempEditable.className = s.cssClasses.pasteHook;tempEditable.setAttribute('contenteditable',true);body.appendChild(tempEditable);utils.selectNode(tempEditable);bodyParent.scrollTop = scrollTop;bodyParent.scrollLeft = scrollLeft;setTimeout(function(){value = utils.text(tempEditable);el.focus();if(s.maxLength > 0){existingValue = utils.text(el);existingLength = existingValue.length;overallLength = existingLength+value.length;if(overallLength > existingLength){value = value.substring(0,s.maxLength - existingLength);}}utils.detachNode( tempEditable );bodyParent.scrollTop = scrollTop;bodyParent.scrollLeft = scrollLeft;fn(value);},0);return Medium.Utilities;},
traverseAll: function(element,options,depth){var children = element.childNodes,length = children.length,i = 0,node;depth = depth || 1;options = options || {};if(length > 0){for(;i < length;i++){node = children[i];switch (node.nodeType){case 1:Medium.Utilities.traverseAll(node,options,depth+1);if(options.element !== undefined){options.element(node,i,depth,element);}break;case 3:if(options.fragment !== undefined){options.fragment(node,i,depth,element);}}length = children.length;if(node === element.lastChild){i = length;}}}return Medium.Utilities;},
trim: function(string){return string.replace(/^[\s]+|\s+$/g,'');},
arrayContains: function(array,variable){var i = array.length;while (i--){if(array[i] === variable){return true;}}return false;},
addClass: function(el,className){if(el.classList){el.classList.add(className);} else {el.className+= ' '+className;}return Medium.Utilities;},
removeClass: function(el,className){if(el.classList){ el.classList.remove(className);} else {el.className = el.className.replace(new RegExp('(^|\\b)'+className.split(' ').join('|')+'(\\b|$)','gi'),' ');}return Medium.Utilities;},
hasClass: function(el,className){if(el.classList){return el.classList.contains(className);} else {return new RegExp('(^| )'+className+'( |$)','gi').test(el.className);}},
isHidden: function(el){return el.offsetWidth === 0 || el.offsetHeight === 0;},
isVisible: function(el){return el.offsetWidth !== 0 || el.offsetHeight !== 0;},
encodeHtml: function( html ){return d.createElement( 'a' ).appendChild(d.createTextNode( html ) ).parentNode.innerHTML;},
text: function(node,val){if(val !== undefined){if(node === null){return this;}if(node.textContent !== undefined){node.textContent = val;} else {node.innerText = val;}return this;}else if(node === null){return this;}else if(node.innerText !== undefined){return utils.trim(node.innerText);}else if(node.textContent !== undefined){return utils.trim(node.textContent);}else if(node.data !== undefined){return utils.trim(node.data);}return '';},
changeTag: function(oldNode,newTag){var newNode = d.createElement(newTag),node,nextNode;node = oldNode.firstChild;while (node){nextNode = node.nextSibling;newNode.appendChild(node);node = nextNode;}oldNode.parentNode.insertBefore(newNode,oldNode);oldNode.parentNode.removeChild(oldNode);return newNode;},
detachNode: function(el){if(el.parentNode !== null){el.parentNode.removeChild(el);}return this;},
selectNode: function(el){var range,selection;el.focus();if(d.body.createTextRange){range = d.body.createTextRange();range.moveToElementText(el);range.select();} else if(w.getSelection){selection = w.getSelection();range = d.createRange();range.selectNodeContents(el);selection.removeAllRanges();selection.addRange(range);}return this;},
baseAtCaret: function(medium){if(!medium.isActive()){return null;}var sel = w.getSelection ? w.getSelection() : document.selection;if(sel.rangeCount){var selRange = sel.getRangeAt(0),container = selRange.endContainer;switch (container.nodeType){case 3:if(container.data && container.data.length != selRange.endOffset) return false;break;}return container;}return null;},
atCaret: function(medium){var container = this.baseAtCaret(medium) || {},el = medium.element;if(container === false){return null;}while (container && container.parentNode !== el){container = container.parentNode;}if(container && container.nodeType == 1){return container;}return null;},
hide: function(el){
el.style.display = 'none';},
show: function(el){el.style.display = '';},
hideAnim: function(el){el.style.opacity = 1;},

showAnim: function(el){
el.style.opacity = 0.01;el.style.display = '';}
};})(Medium);rangy.rangePrototype.insertNodeAtEnd = function(node){
var range = this.cloneRange();range.collapse(false);range.insertNode(node);range.detach();this.setEndAfter(node);};
return Medium;}()),utils = Medium.Utilities;
if(typeof define === 'function' && define['amd']){
define(function(){ return Medium; });} else if(typeof module !== 'undefined' && module.exports){
module.exports = Medium;} else if(typeof this !== 'undefined'){
this.Medium = Medium;}

}).call(this,window,document);
