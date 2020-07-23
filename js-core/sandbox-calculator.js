//#editthis version:8.2.2
//#sandbox version:calculator
if( typeof(G['sandbox-calculator']) === 'undefined' ){ Object.append(G,{ 'sandbox-calculator':{} }); }
Object.append(G['sandbox-calculator'],{
el:null,
form:null,
n:[
'<tr class="partA" style="background-color:#E9E07B;"><td class="mobhide"></td><td><label for="sc-ref">Company:</label></td><td><input id="sc-name" name="sc-name" type="text" value="" /> <a class="icon" title="optional name">?</a></td><td class="mobhide"></td></tr>',
'<tr class="partA" style="background-color:#E9E07B;"><td class="mobhide"></td><td><label for="sc-ref">Job Reference:</label></td><td><input id="sc-ref" name="sc-ref" type="text" value="" /> <a class="icon" title="optional job reference">?</a></td><td class="mobhide"></td></tr>',
'<tr class="partA" style="background-color:#E9E07B;"><td class="mobhide"></td><td><label for="cal-width">Width (mm):</label></td><td><input id="cal-width" name="cal-width" type="number" min="0" value="" required /> <a class="icon" title="width of printing paper sheet">?</a></td><td class="mobhide"></td></tr>',
'<tr class="partA" style="background-color:#E9E07B;"><td class="mobhide"></td><td><label for="cal-length">Length (mm):</label></td><td><input id="cal-length" name="cal-length" type="number" min="0" value="" required /> <a class="icon" title="length of printing paper sheet ">?</a></td><td class="mobhide"></td></tr>',
'<tr class="partA" style="background-color:#E9E07B;"><td class="mobhide"></td><td><label for="cal-weight">Weight (g/m&sup2;):</label></td><td><input id="cal-weight" name="cal-weight" type="number" min="0" value="" required /> <a class="icon" title="also referred to paper grammage">?</a></td><td class="mobhide"></td></tr>',
'<tr class="partA" style="background-color:#E9E07B;"><td class="mobhide"></td><td><label for="cal-quantity">Quantity (sheets):</label></td><td><input id="cal-quantity" name="cal-quantity" type="number" min="0" value="" required /> <a class="icon" title="input actual quantity of printing sheets required">?</a></td><td class="mobhide"></td></tr>',
'<tr class="partA" style="background-color:#E9E07B;"><td class="mobhide"></td><td></td><td></td><td class="mobhide"></td></tr>',
'<tr class="partA" style="background-color:#E9E07B;"><td class="mobhide"></td><td><label for="sc-tonnes">Tonnes:</label></td><td><input id="sc-tonnes" name="sc-tonnes" type="number" min="0" step="any" value="" /></td><td class="mobhide"></td></tr>',
'<tr class="partA" style="background-color:#E9E07B;"><td class="mobhide"></td><td></td><td></td><td class="mobhide"></td></tr>',
'<tr class="partA"><td class="mobhide"></td><td></td><td></td><td class="mobhide"></td></tr>',
'<tr class="partA"><td colspan="3"><input type="hidden" name="page" value="CO2-Calculator-Results" /><input type="hidden" name="type" value="calculator" /><input id="cal-reset" name="cal-reset" type="reset" value="RESET" /> <input id="cal-submit" name="cal-submit" type="submit" value="SEE RESULTS" /></td><td class="mobhide"></td></tr>'
/*'<tr class="partB reshead" style="background-color:#23b9d6;"><td colspan="3"><h2 style="color:#fff;">Your Results:</h2></td></tr>',
'<tr class="partB" style="background-color:#FFF;"><td colspan="3"></td></tr>',
'<tr class="partB" style="background-color:#FFF; height:60px;"><td class="co2-icon"></td><td><input id="sc-total-tonnes" name="sc-total-tonnes" type="text" value="0" readonly /></td><td>tonnes of carbon emissions would be reduced Carbon Balancing your paper order</td></tr>',
'<tr class="partB" style="background-color:#FFF;"><td colspan="3"></td></tr>',
'<tr class="partB" style="background-color:#23b9d6;"><td colspan="3" style="padding:1px"></td><td style="padding:1px"></td></tr>',
'<tr class="partB"><td colspan="3"></td><td></td></tr>',
'<tr class="sc-header partB"><td colspan="3">and this is equivalent to:</td><td></td></tr>',
'<tr class="partB" style="background-color:#FFF;"><td colspan="3"></td><td></td></tr>',
'<tr class="partB" style="background-color:#FFF; height:60px; border-bottom:1px solid #ccc;"><td class="car-icon"></td><td><input id="sc-result-miles" name="sc-result-miles" type="text" value="0" readonly /></td><td>Car miles neutralised</td></tr>',
'<tr class="partB" style="background-color:#FFF; height:60px; border-bottom:1px solid #ccc;"><td class="nocar-icon"></td><td><input id="sc-result-cars" name="sc-result-cars" type="text" value="0" readonly /></td><td>Equivalent of taking this many average petrol cars off the road each year</td></tr>',
'<tr class="partB" style="background-color:#FFF; height:60px; border-bottom:1px solid #ccc;"><td class="drive-icon"></td><td><input id="sc-result-coastline" name="sc-="result-coastline" type="text" value="0" readonly /></td><td>Driving round Britains coastline this many times</td></tr>',
'<tr class="partB" style="background-color:#FFF; height:60px;"><td class="plane-icon"></td><td><input id="sc-result-flights" name="sc-="result-flights" type="text" value="0" readonly /></td><td>Number of passenger return flights London - New York</td></tr>',
'<tr class="sc-ref partB" style="background-color:#FFF;"><td colspan="3">Data from Defra 2018 GHG conversion factors</td><td></td></tr>',
'<tr class="partB" style="background-color:#FFF;"><td colspan="3"></td><td></td></tr>',
'<tr class="partB"><td colspan="3"></td><td></td></tr>',
'<tr class="sc-header partB"><td colspan="3">Additional benefits to the World Land Trust:</td><td></td></tr>',
'<tr class="partB" style="background-color:#FFF;"><td colspan="3"></td><td></td></tr>',
'<tr class="partB" style="background-color:#FFF; height:60px; border-bottom:1px solid #ccc;"><td class="land-icon"></td><td><input id="sc-result-metres" name="sc-="result-metres" type="text" value="0" readonly /></td><td>Square metres of High Conservation Land preserved with the World Land Trust</td></tr>',
'<tr class="partB" style="background-color:#FFF; height:60px;"><td class="ball-icon"></td><td><input id="sc-result-pitches" name="sc-result-pitches" type="text" value="0" readonly /></td><td>Equivalent football pitches land area preserved</td></tr>',
'<tr class="partB" style="background-color:#FFF;"><td colspan="3"></td><td></td></tr>',
'<tr><td colspan="3"></td><td></td></tr>',
'<tr class="partB"><td colspan="3"><input id="sc-again" name="sc-again" type="again" value="TRY AGAIN" /></td><td></td></tr>'*/
].join('\n'),
t: [
'table.calculator { font-size:120%; line-height:120%; text-align:left; width:100%; border-collapse:collapse; }',
'table.calculator tbody > tr:first-child td { padding-top:15px; }',
'table.calculator tbody > tr:last-child td { padding-bottom:15px; }',
'table.calculator input {	 width:auto; max-width:125px; color:#23b9d6; font-size:110%; border:1px solid #23b9d6; padding:4px 8px; clear:none; float:left; }',
'table.calculator input[type=text] { color:#23b9d6 !important; font-weight:normal !important; text-align:left !important; border:1px solid #23b9d6 !important; margin-right:0 !important; }',
'table.calculator .sc-ref td { font-style:italic; font-size:90%; }',
'table.calculator td { padding:5px 20px; }',
'table.calculator tr > td:last-child { }',
'table.calculator .sc-header td { font-weight:bold; padding:15px 0 10px 0; }',
'table.calculator .icon { display:block; width:16px; height:16px; color:#fff !important; background:#23b9d6; font-size:90%; line-height:130%; text-align:center; font-weight:bold; border-radius:8px; clear:none; float:left; }',
'#cal-reset, #cal-submit, #cal-again { color:#fff; background:#9e9e9e; text-align:center; padding:5px 10px; margin:20px 20px 20px 0; border:none; cursor:pointer; -webkit-appearance: none; }',
'#cal-reset:hover, #cal-submit:hover, #cal-again:hover { background:#393634; }',
'#cal-submit { color:#fff; background:#CDC56C; }'
].join('\n'),
initF: function(){ G['sandbox-calculator'].inited = 1; },
calcF: function(e){ var m = 0,n,p = 0,r = 0,t,u = 0,v;if(e){
G.stopG(e);t = e.target;n = t.name;v = t.type;
if(v == 'number'){
if( t == $('sc-tonnes') ){ $('cal-width').value = 0;$('cal-length').value = 0;$('cal-weight').value = 0;$('cal-quantity').value = 0;r = $('sc-tonnes').value; } else { if(  $('cal-width').value > 0 || $('cal-length').value > 0 || $('cal-weight').value > 0 || $('cal-quantity').value > 0 ){ $('sc-tonnes').value = 0;
//$('sc-total-tonnes').value = 0;$('sc-result-miles').value = 0;$('sc-result-cars').value = 0;$('sc-result-coastline').value = 0;$('sc-result-flights').value = 0;$('sc-result-metres').value = 0;$('sc-result-pitches').value = 0;
}
if( $('cal-width').value > 0 && $('cal-length').value > 0 && $('cal-weight').value > 0 && $('cal-quantity').value > 0 ){ r = ( $('cal-width').value * $('cal-length').value * $('cal-weight').value * $('cal-quantity').value ) / 1000000000000;$('sc-tonnes').value = r.toFixed(2); }
}
/*if(r > 0){ u =  ( r*0.67 );$('sc-total-tonnes').value = u.toFixed(2);m = Math.floor( u/(0.29561/1000) );$('sc-result-miles').value = m;$('sc-result-cars').value = Math.floor( m/12000 );$('sc-result-coastline').value = Math.floor( m/5000 );$('sc-result-flights').value = Math.floor( (u/(0.21256/1000))/11172 );p =  Math.floor( u*700 );$('sc-result-metres').value = p;$('sc-result-pitches').value =  (p/7140).toFixed(2); } else { $('sc-total-tonnes').value = 0;$('sc-result-miles').value = 0;$('sc-result-cars').value = 0;$('sc-result-coastline').value = 0;$('sc-result-flights').value = 0;$('sc-result-metres').value = 0;$('sc-result-pitches').value =  0; }*/
} else {
console.log(e.type,' -> ',t.name,' = ',t.value,' v:',v);
}
}
},
loadF: function(a){ G.styleG(G['sandbox-calculator'].t);G['sandbox-calculator'].drawF(a);console.log('sandbox-calculator ',a,' loaded'); },
drawF:function(a){ a.empty();G['sandbox-calculator'].form = new Element('form',{'id':'sc-form','method':'post','accept-charset':'UTF-8','action':'../cgi-bin/output.pl','html':'<fieldset></fieldset>'}).inject(a);G['sandbox-calculator'].el = new Element('table',{'class':'calculator','html':'<tbody>'+G['sandbox-calculator'].n+'</tbody>'}).inject(G['sandbox-calculator'].form.getElement('fieldset'));
G['sandbox-calculator'].form.getElements('input').attachMe({'input':G['sandbox-calculator'].calcF});
}
});