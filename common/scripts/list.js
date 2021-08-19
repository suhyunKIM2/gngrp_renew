function t_set_refresh() {
	var tbl = document.getElementById( "mail_list" );
	var tr = tbl.rows;
	for( var i=0; i< tr.length; i++ ) {
		if ( i%2 ) {
			tr[i].style.backgroundColor = "#FFFFFF";
		} else {
			tr[i].style.backgroundColor = "#F9F9F9";
		}
	}
}

function t_set( args ) {
	var tbl = document.getElementById( "mail_list" );
	var tr = tbl.rows;
	for( var i=0; i< tr.length; i++ ) {
		if ( i%2 ) {
			tr[i].style.backgroundColor = "#FFFFFF";
		} else {
			tr[i].style.backgroundColor = "#F9F9F9";
		}
		
		tr[i].onmouseover = function () {
			if ( this.cells[0].childNodes.length > 0 ) {
				if ( this.cells[0].childNodes[0].tagName == "INPUT" ) {
					var chk = this.cells[0].childNodes[0];
					if ( chk.checked ) {
						return;
					}
				}
			}
			this.style.backgroundColor = "#EEEEF4";
		}

		if ( i%2 ) {
			tr[i].onmouseout = function () {
			if ( this.cells[0].childNodes.length > 0 ) {
				if ( this.cells[0].childNodes[0].tagName == "INPUT" ) {
					var chk = this.cells[0].childNodes[0];
					if ( chk.checked ) {
						return;
					}
				}
			}
				this.style.backgroundColor = "#FFFFFF";
			}
		} else {
			tr[i].onmouseout = function () {
			if ( this.cells[0].childNodes.length > 0 ) {
				if ( this.cells[0].childNodes[0].tagName == "INPUT" ) {
					var chk = this.cells[0].childNodes[0];
					if ( chk.checked ) {
						return;
					}
				}
			}
				this.style.backgroundColor = "#F9F9F9";
			}
		}
	}
}

var winx = 0;
var winy = 0;
function afterShowAttach() {
	if ( xmlhttp.readyState == 4 ) {
		if ( xmlhttp.status != 200 ) {
			alert( '오류가 발생하였습니다 : XMLHTTP     \n\n오류위치 : afterShowAttach()' );
			xmlhttp = null ;
			return;
		}

	var statusStr ;
	oPopup = window.createPopup();
	var oPopupBody = oPopup.document.body;
	oPopupBody.innerHTML = xmlhttp.responseText ;

	wid = 250 ;
	hei = 105;

//	x = window.event.x-265;
//	y = window.event.y-40;
	
	oPopup.show(winx, winy, wid, hei , document.body);
	xmlhttp = null ;
	}
}

function attach_down( args ) {
	self.location =  args;
}

function chkBg() {
	var chkbox = window.event.srcElement;
	var tr = chkbox.parentElement.parentElement;
	if ( chkbox.checked ) {
		tr.style.backgroundColor = "#D5E2F5";
	} else {
		tr.style.backgroundColor = "#EEEEF4";
	}
}