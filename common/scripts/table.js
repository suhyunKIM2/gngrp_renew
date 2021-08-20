
function roundTable(objID) {
       var obj = document.getElementById(objID);
       var Parent, objTmp, Table, TBody, TR, TD;
       var bdcolor, bgcolor, Space;
       var trIDX, tdIDX, MAX;
       var styleWidth, styleHeight;

       // get parent node
       Parent = obj.parentNode;
       objTmp = document.createElement('SPAN');
       Parent.insertBefore(objTmp, obj);
       Parent.removeChild(obj);

       // get attribute
       bdcolor = obj.getAttribute('rborder');
       bgcolor = obj.getAttribute('rbgcolor');
       radius = parseInt(obj.getAttribute('radius'));
       if (radius == null || radius < 1) radius = 1;
       else if (radius > 6) radius = 6;

       MAX = radius * 2 + 1;
       
       /*
              create table {{
       */
       Table = document.createElement('TABLE');
       TBody = document.createElement('TBODY');

       Table.cellSpacing = 0;
       Table.cellPadding = 0;

       for (trIDX=0; trIDX < MAX; trIDX++) {
              TR = document.createElement('TR');
              Space = Math.abs(trIDX - parseInt(radius));
              for (tdIDX=0; tdIDX < MAX; tdIDX++) {
                     TD = document.createElement('TD');
                     
                     styleWidth = '1px'; styleHeight = '1px';
                     if (tdIDX == 0 || tdIDX == MAX - 1) styleHeight = null;
                     else if (trIDX == 0 || trIDX == MAX - 1) styleWidth = null;
                     else if (radius > 2) {
                            if (Math.abs(tdIDX - radius) == 1) styleWidth = '2px';
                            if (Math.abs(trIDX - radius) == 1) styleHeight = '2px';
                     }

                     if (styleWidth != null) TD.style.width = styleWidth;
                     if (styleHeight != null) TD.style.height = styleHeight;

                     if (Space == tdIDX || Space == MAX - tdIDX - 1) TD.style.backgroundColor = bdcolor;
                     else if (tdIDX > Space && Space < MAX - tdIDX - 1) TD.style.backgroundColor = bgcolor;
                     
                     if (Space == 0 && tdIDX == radius) TD.appendChild(obj);
                     TR.appendChild(TD);
              }
              TBody.appendChild(TR);
       }

       /*
              }}
       */

       Table.appendChild(TBody);
       
       // insert table and remove original table
       Parent.insertBefore(Table, objTmp);
}


function SubMenu(obj,type)
{
    var obj
    var div = eval("document.all." + obj);

    if(type=='open'){div.style.display = "block";}
    else if (type == 'over') {div.style.display = "block";}
    else if (type == 'out') {div.style.display = "none";}
}


	//window.onload = prepareTreeMenu;
	function treeMenu(targetID,treeOpen,treeClose,currentOpen,currentClose) {
		var treeMenu = document.getElementById(targetID);
		var treeSub = treeMenu.getElementsByTagName('ul');
		for (var i=0; i<treeSub.length; i++) {
			treeSub[i].style.display = 'none';
		}
		var treeTxt = treeMenu.getElementsByTagName('li');
		for (var k=0; k<treeTxt.length; k++) {
			var treeTxts = treeTxt[k];
			if (treeTxts.getElementsByTagName('ul').length == 0) {
				treeTxts.className = treeOpen;
			} else {
				treeTxts.className = treeClose;
			}
		}
		var treeClick = treeMenu.getElementsByTagName('span');
		for (var j=0; j<treeClick.length; j++) {
			treeClick[j].onclick = function() {
				var treeTxtSub = this.parentNode.getElementsByTagName('ul');
				if (treeTxtSub.length != 0 && treeTxtSub[0].style.display == 'none') {
					treeTxtSub[0].style.display = 'block';
				} else if (treeTxtSub.length != 0 && treeTxtSub[0].style.display == 'block') {
					treeTxtSub[0].style.display = 'none';
				}
				if (this.parentNode.className == treeOpen && treeTxtSub.length != 0) {
					this.parentNode.className = treeClose;
				} else {
					this.parentNode.className = treeOpen;
				}
				for (var y=0; y<treeClick.length; y++) {
					treeClick[y].className = currentClose;
				}
				this.className = currentOpen;
			}
		}
	}
	function prepareTreeMenu() {
		// treeMenu(targetID,treeOpen,treeClose,currentOpen,currentClose);
		// targetID : 트리의 가장 상위 id
		// treeOpen :열린 이미지 class
		// treeClose : 닫힌 이미지 class
		// currentOpen : 현재 페이지 class
		// currentClose :  다른 페이지 class
		treeMenu('treemenu','open','close','on','off');
	}

function m_over(obj) {
	//obj = td
	var tr = obj.parentElement;
	menu_idx = obj.cellIndex;
	
	var l = tr.cells[ obj.cellIndex-1 ];
	var r = tr.cells[ obj.cellIndex+1 ];

	l.style.backgroundImage = "url('/common/images/m_left.jpg')";
	obj.style.backgroundImage = "url('/common/images/m_bg.jpg')";
	obj.className = "menu";
	r.style.backgroundImage = "url('/common/images/m_right.jpg')";
}

function m_out(obj) {
	//obj = td
	var tr = obj.parentElement;
	menu_idx = obj.cellIndex;
	
	var l = tr.cells[ obj.cellIndex-1 ];
	var r = tr.cells[ obj.cellIndex+1 ];

	l.style.backgroundImage = "url('/common/images/mm_left.jpg')";
	obj.style.backgroundImage = "url('/common/images/mm_bg.jpg')";
	obj.className = "menuover";
	r.style.backgroundImage = "url('/common/images/mm_right.jpg')";
}

var menu_obj;
var m;
var sel_menu;
function subView(take){
	document.all[take].style.visibility='visible';
	
	if( arguments.length == 1 ) {
		//대메뉴 그대로 유지해야 함...
		m_over(menu_obj);
		//sub1이면 전자메일....
		return;
	}
	
	m = take;
	 
	var obj = event.srcElement;
	if ( obj.tagName == "A" ) obj = obj.parentElement;
	
	m_over(obj);
	menu_obj = obj;
}
function subHide(take){
	document.all[take].style.visibility='hidden';
	if( arguments.length == 1 ) {
		m_out(menu_obj);
		return;
	}
	
	//현 메뉴를 그대로 유지...
	var obj = event.srcElement;
	if ( obj.tagName == "A" ) obj = obj.parentElement;
	m_out(obj);
	menu_obj = obj;
}