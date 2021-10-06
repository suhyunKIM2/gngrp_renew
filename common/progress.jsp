<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ include file="../common/usersession.jsp" %>
<%
	String cType = request.getParameter("ctype");
%>
<script>
	var wid = 328;
	var hei = 130;
	var stop = 0;
	var sleft = 0;
	var sType = "<%=cType%>";
	if(sType==1){
		stop = 100 ;
		sleft = ( (document.body.clientWidth) / 2 ) - 125;
		argTitle = "메일을 발송 중 입니다.....";
	}else if(sType==2){
		stop = (document.body.clientHeight - hei) / 2;
		sleft = (document.body.clientWidth - wid) / 2;
		argTitle = "메일을 가져오는 중 입니다.....";
	}else{
		stop = (document.body.clientHeight - hei) / 2;
		sleft = (document.body.clientWidth - wid) / 2;
		argTitle = "데이터를 저장 중 입니다.....";
	}
	
	argMsg = "화면이 바뀌기전까지 기다려주십시오.<BR>작업진행 중에 화면을 이동하면 작업이 중단됩니다";
	
	tag = '<div id="myid" style="display:none;width:' + wid + 'px; height:' + hei + 'px; position:absolute; top:' + stop + 'px; left:' + sleft + 'px;';
	tag += 'background:#b7d4fa; border:2px solid #8fc1d8; border-top:2px solid #8fc1d8; ';
	tag += 'border-left:2px solid #8fc1d8; font:normal 9pt tahoma; padding-top: 1px; ';
	tag += 'padding-left:2px; padding-bottom:2px; padding-right:2px; padding-top:3px;">&nbsp;';
	
	tag += '<span id=nek_title style="width:100%; height:25px;padding-top:3px; font-weight:bold; border:0px red solid; ">';
	tag += '<img src="/common/images/vwicn011.gif" width=13 height=11 align=absmiddle>&nbsp;' + argTitle + '</span><BR>';
	
	tag += '<table width=100% height=110 border=0 style="position:relative; top:5px;"><tr>';
	tag += '<td bgcolor=white align=center style="font-family:tahoma; font-size:9pt; font-weight:bold;" valign=top>';
	tag += '<img src=/common/images/loading_img.gif align=absmiddle style="cursor:hand; "><BR><BR>' + argMsg + '</TD></TR></TABLE>';
	tag += '</div>';
 	document.write(tag);
</script>