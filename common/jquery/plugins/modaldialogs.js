/**
 * ModalDialog - Creates a modal dialog using jQuery UI
 *
 * Copyright (c) 2010 Wesley Jordan <wesley@livebusinessonline.com>
 * Licensed under the MIT license:
 *   http://www.opensource.org/licenses/mit-license.php
 * 
 * Place the following code on your page:
 * <div id="modalDiv" style="display: none;"></div>
 * 
 * general parameters:
 * m: mode      (str) - html or iframe
 * w: width     (int)
 * h: height    (int) - default = 'auto' (auto only works in html mode)
 * c: content   (str) - content of dialog when using html mode
 * u: url       (str) - src of iframe when using iframe mode
 * t: title     (str)
 * d: draggable (bool)
 * r: resizable (bool)
 *
 * advanced parameters:
 * b: buttons - @link http://jqueryui.com/demos/dialog/#option-buttons
 * x: onclose - supports a single function name which receives: event, ui
 *
 * examples:
 * ModalDialog({'t':'Results', 'c':'The result of Foo + Bar is FooBar'})
 * ModalDialog({'t':'jQuery is Amazing', 'w':500, 'h':500, 'm':'iframe', 'u':'http://jquery.org'})
 * ModalDialog({'t':'Sample', 'c':$('#example').html(), 'b':{'OK':function(){$(this).dialog('close');}}, 'x':'Foo'})
 *
 * usage notes:
 * The onclose functionality is not nearly as advanced as the default jQueryUI
 * dialog functionality.  This is for two reasons, first it perfectly suits the
 * needs of my app and second I use the onclose option to remove the contents of
 * modalDiv before calling the function defined by x. If the div content is not
 * removed it will be shown briefly on the next call to ModalDialog.
 *
 * The iframe source script can communicate with the calling page. This makes
 * it possible to set the value of hidden fields after your script completes
 * and prior to closing the form.  Coupled with the onclose function you have
 * the ability do things like detect if changes were made in the iframe dialog
 * when it's closed and then update the parent ui accordingly.
 *
 * The following example shows how an iframe dialog can update a hidden field
 * in the parent page and then close the dialog window.
 *
 * function CloseWin(){
 *   window.parent.$("#hidFld").val('1');
 *   window.parent.$("#modalDiv").dialog('close');
 *   return false;
 * }
 *
 * If you set the onclose function to be called, that function can then detect
 * the changed hidden field and take the necessary action(s).
 *
 * other notes:
 * This function obviously doesn't incorporate all of the options available in
 * the jQueryUI dialog widget. I only included what was necessary for my app.
 * You could very easily add additional options by creating new default values
 * and then adding the new options to the dialogOpts variable.
 *
 * For more information about the jQueryUI dialog widget go to:
 * @link http://jqueryui.com/demos/dialog
 */

var modalDiv;
function ModalDialog()
{
  // default values
  var lp = "";
  var tp = "";
  
  var m = "html";
  var w = 300;
  var h = 'auto';
  //var c = "";
  var t = 'ModalDialogs';
  var b = {};
  var d = true;
  var r = false;
  var x = null;
  var modal = true;
  var esc = true;
  var sh = "";
  var p = "center";

  //var modalDiv = document.getElementById("modalDiv");
  
//  var modalDiv = $("#modalDiv");
//  if ( !modalDiv.length ) {
	 // overlay = $('<div class="ui-widget-overlay" style="position:absolute;top:0;left:0;right:0;bottom:0;z-index:9999;z-order:100000;"></div>');
      //overlay.appendTo($(document.body));
      
  //var tmp = $([name='modalDiv']);
//  var tmp = $([name="modalDiv"]);
//  var modalDiv;
//  if ( !tmp.length ) {
//	  //alert();
//	  modalDiv = $('<div name="modalDiv" sid="modalDiv"></div>');
//      modalDiv.appendTo($(document.body));
//  } else {
//	  var modalDiv = $('<div name="modalDiv" sid="modalDiv"></div>');
//      modalDiv.appendTo($(document.body));
//  }
//  
  modalDiv = $('<div name="modalDiv" sid="modalDiv"></div>');
  modalDiv.appendTo($(document.body));
 
  var tmp = document.getElementsByName('modalDiv');

//      alert( modalDiv.length);      
//	  var div = document.createElement("DIV");
//	  div.setAttribute("id", "modalDiv");
//	  document.body.appendChild( div );
	  
//  }
  
  // parameters
  if(arguments.length==1) {
    var params = arguments[0];
    for (key in params) eval(key + " = params[key]");
  }

	if ( lp == "" || tp == "" ) {
		//p = "center";
		if ( tmp.length == 0 ) {
			p = ['60%','50%'];
			//p = "center";
		} else {
			t1 = 50 + (tmp.length+1);
			t1 = t1 + "%";
			//l1
			//p = ['50%','50%'];
			p = [t1, t1];
		}
		
	} else {
		p = [lp,tp];
	}
  // check for required parameters
  if(m=="iframe" && u==undefined) { alert("ModalDialog Frame SRC parameter not defined."); return; }

  // defines the animation speed
  $.fx.speeds._default = 250;

	//if ( $("#modalDiv").dialog("isOpen") ) $("#modalDiv").dialog("close");
	if ( modalDiv.dialog("isOpen") ) modalDiv.dialog("close");
	
  // dialog options
  var dialogOpts = {
    modal: modal,
    closeOnEscape: esc,
    bgiframe: (m=="iframe") ? true : false,
    autoOpen: false,
    height: h,
    width: w,
    
    show: sh,
    draggable: d,
    resizable: r,
	position: p,
    title: t,
    buttons: b,
    beforeClose: function(event, ui) {
    	//$("#modalDiv").html("");
    	modalDiv.html("");
    	//modalDiv.remove();
        if(x!=null) eval(x+"(event,ui)");
    },
    close: function(event, ui) {
    	modalDiv.remove();
      //$("#modalDiv").html("");
      if(x!=null) eval(x+"(event,ui)");
    },
    open: function() {    	
      if(m=="iframe")
      {
    	  var modalIFrame = $('<iframe name="modalIFrame" id="modalIFrame" width="100%" height="100%" marginWidth="0" marginHeight="0" frameBorder="0" scrolling="auto"></iframe>');
    	  modalIFrame.appendTo(modalDiv);
    	  
        //modalDiv.html('<iframe name="modalIFrame" id="modalIFrame" width="100%" height="100%" marginWidth="0" marginHeight="0" frameBorder="0" scrolling="auto"></iframe>');
        //var i = $([name="modalIFrame"]);
        //modalIFrame = i[i.length];
        modalIFrame.attr('src', u);
        //$("#modalIFrame").attr('src',u);
      }
      else 
    	  {
    	  modalDiv.html(c)
    	  }
    }
  };

  //modalDiv.dialog(dialogOpts)
  modalDiv.dialog(dialogOpts)
  .bind('dialogdragstart', function() {
	  var overlay = $('.ui-widget-overlay');
	  if (!overlay.length) {
    	  overlay = $('<div class="ui-widget-overlay" style="position:absolute;top:0;left:0;right:0;bottom:0;z-index:9999;z-order:100000;"></div>');
          overlay.appendTo($(document.body));
          overlay.show();
      }
      else 
      {
          overlay.show();
      }
//	  modalDiv.css("display", "none");
//	  modalDiv.css("height", "200px");
//	  modalDiv.children().first().css("height", "200px");
//	  modalDiv.parent().css("height", "200px");
  })
  
  .bind('dialogdragstop', function() {
	  $('.ui-widget-overlay').hide();
	  $('.ui-widget-overlay').remove();
	  //modalDiv.css("display", "block");
	  //modalDiv.parent().css("height", "600px");
  });

  modalDiv.dialog("open");

  // dialog position move
  try {
  //alert( tmp.length ); 오류 발생함...
  
  if ( tmp.length == 0 ) {
	  var div_p = tmp.parentElement;
  } else {
	  var div_p = tmp[tmp.length-1].parentElement;
  }
  //var div_p = tmp[tmp.length-1].parentElement;
  
  t1 = div_p.style.top.replace(/px/,"") ;
  l1 = div_p.style.left.replace(/px/,"") ;

  t1 = (t1*1) + (tmp.length * 33);
  l1 = (l1*1) + (tmp.length * 33);

  div_p.style.top = t1 + "px";
  div_p.style.left = l1 + "px";
  } catch (e) {
	  //IE error !
  }
}

function ModalDialogClose(args) {
	// multi dialog error !
	modalDiv.dialog("close");
}
