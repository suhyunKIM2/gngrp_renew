<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title></title>
</head>
<body>
<script type="text/javascript">
<c:if test="${message != null && message != ''}" >
alert("${message}");
</c:if>

function SelfClose() { 

    if (/MSIE/.test(navigator.userAgent)) { 
          if(navigator.appVersion.indexOf("MSIE 7.0")>=0) { 
              window.open('about:blank','_self').close(); 
          } else { 
          window.opener = self; 
          self.close();
          }
    } 
} 
    
var parentURL = "<c:if test="${parentURL != null && parentURL != ''}">${parentURL}</c:if>";

if(window.opener != null){
	var parentWin = window.opener;
	if(parentURL != "")  parentWin.location.href = parentURL;
	else parentWin.location.reload();
	self.close();
} else {
	
	if (navigator.userAgent.match(/iPad/) == null && navigator.userAgent.match(/Mobile|Windows CE|Windows Phone|Opera Mini|POLARIS/) != null){
		self.location.href = "/mobile/mobile_inglist.jsp?menu240";
		alert( "처리 되었습니다");
	} else {
		//if ( parent.frames.length < 2 ) {
		try {
			//alert( parentURL );
			if(parent.closeModalDialog) parent.closeModalDialog();
			/*
			window.opener='self';
			window.open('','_parent','');
			window.close();
			*/
			self.location.href = parentURL;
		} catch(e) {
			alert( 'TEST');
		}
		
		/*
		if ( parent.frames.length < 2 ) {
			parent.location.reload();
		} else {
			if( parent.parent.document.getElementById("if_list") != null){	
				var reloadFrame = parent.parent.document.getElementById("if_list");
				if(parentURL != "")  reloadFrame.src = parentURL;
				else {
					//contentDocuemnt 모든 브라우저 지원(IE는 8부터)
					if(reloadFrame.contentDocument) reloadFrame.contentDocument.location.reload(true);
					else reloadFrame.src = reloadFrame.src;
				}
			}
		}
		*/
	}
}

</script>
</body>
</html>