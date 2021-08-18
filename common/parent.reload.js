	var isWindow = (top == window);
	var isFrame = (window.frameElement != null);
	var isOpener = (window.opener != null);
	var isParent = (window.parent != null);
	//console.log(isWindow + "/" + isFrame + "/" + isOpener + "/" + isParent); 
	
	function parentReload(url) {
		var list = getFrameByName("if_list");
		if (list) {
			if (url) {
				if (list.src = url && list.document.getElementById("dataGrid")) {
					list.$("#dataGrid").trigger("reloadGrid");
				} else {
					list.src = url;
				}
			} else {
				if (list.document.getElementById("dataGrid")) {
					list.$("#dataGrid").trigger("reloadGrid");
				} else {
					list.src = list.src;
				}
			}
		}
	}
	
	function windowClose() {
		if (isOpener && isWindow) {
			window.close();
		} else if (isParent && isFrame) {
			var elem = window.frameElement.parentElement.parentElement;
			var className = elem.getAttribute("class");
			if (className.toLowerCase().indexOf("dhtmlwindow") > -1) {
				elem.outerHTML = "";
			}
		}
	}
	
	function getFrameByName(name) {
		var f_windows = new Array();
		var f_window = null;
		
		if (isOpener && isWindow) 
			f_windows = window.opener.top.frames;
		else if (isParent && isFrame) 
			f_windows = window.top.frames;

		for(var i = 0; i < f_windows.length; i++) {
			if (f_windows[i].name == name)
				f_window = f_windows[i];
		}
		return f_window;
	}
