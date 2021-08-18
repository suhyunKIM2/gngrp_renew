<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.*;" %>
<% request.setCharacterEncoding("utf-8"); %>
<%@ include file="../common/usersession.jsp"%>

<% 
    String sReturnURL = request.getParameter("Print_requestURL") ;
    if ( (sReturnURL == null ) || ("".equals(sReturnURL)) ) sReturnURL = "" ;
    String attachfiles = request.getParameter("attachfiles");
    if ( attachfiles == null ) attachfiles = "" ;
%>
<HTML>
	<HEAD>
		<title></title>
		<script language="javascript" src="./scripts/webprint_tool.js"></script>
		<style>
		@page a4sheet { size: 21.0cm 29.7cm }
		.a4{ page: a4sheet; page-break-after: always }
		.Appborder {font-family:Tahoma, 돋움; font-size:9pt; color:#30546A; height:20px; border:1px solid #90B9CB; padding:2 2 2 4; vertical-align:middle;text-align:center; border-collapse:collapse;}
		</style>
		<script>
		function printClick() {
			var zoomVal = document.getElementsByName("zoomValue")[0].value;
			DisplayPrintForm(zoomVal);
			
			disableLink();
		}
		
		function Keycode(e){
			var result;
			if(window.event)
			result = window.event.keyCode;
			else if(e)
			result = e.which;
			return result;
		}

		</script>
	</HEAD>
	<BODY style="margin-left:0px;padding:10,10,10,10;" topmargin="0" onload="printClick();">
		<form id="WebPrintForm" method="post" onSubmit="return false">
    		<input type="hidden" name="Print_requestURL" value="<%= sReturnURL %>">
			<div id="PrintTool" style="WIDTH: 100%; HEIGHT: 40px;">
			<!--인쇄-->
			<table width="100%" cellspacing="0" cellpadding="0" border="0">
				<tr> 
					<td width=5><img src=./images/print_left.gif></td>
					<td width=100% background=./images/print_middle.gif>
						<table width=100% cellspacing="0" cellpadding="0" border="0">
							<tr>
								<td width=5></td>
								<td width=360><!-- <img src=./images/i_print_select.gif align=absmiddle> -->
<!-- 									<input type="checkbox" onClick="ItemDispaly(this, 'printtitle')" value="제목">제목
									<input type="checkbox" onClick="ItemDispaly(this, 'printbutton')" value="버튼">버튼
									<input type="checkbox" onClick="ItemDispaly(this, 'printcomment')" value="간단한 의견">간단한 의견
									<input type="checkbox" onClick="ItemDispaly(this, 'printdocmap')" value="관련문서">관련문서
 -->								</td>
								<td width=235><img src=./images/i_print_size.gif align=absmiddle>&nbsp;
									<INPUT style="TEXT-ALIGN:right" id="zoomValue" name="zoomValue" VALUE="100" SIZE=6 class=input03 
									onkeydown='if( Keycode(event) ==13) {DisplayPrintForm(this.value); return false;};' donkeyPress="if(window.event.keyCode == 13){DisplayPrintForm(WebPrintForm.all.zoomValue); return false;}">%&nbsp;
									<a href="#" onclick='DisplayPrintForm(document.getElementsByName("zoomValue")[0].value);'>
									<img src=./images/btn_apply.gif align=absmiddle border=0></a>
								</td>
								<td width="*" align=right>
									<a href="#" onclick="RealPrintAction()"><img src=./images/btn_print.gif align=absmiddle border=0></a>&nbsp;
									<a href="#" onclick="returnDoc()"><img src=./images/btn_back.gif align=absmiddle border=0></a>&nbsp;
								</td>
							</tr>
						</table> 
					</td>
					<td width=5><img src=./images/print_right.gif></td>
				</tr>
			</table> <!--인쇄끝-->
		</div>
		</form>
<!-- 		<table cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td style="width:14mm">&nbsp;</td>
				<td style="width:182mm">
 -->	
<%
    if (sReturnURL.indexOf("/approval/") > 0 ) {
%>
    <link rel=STYLESHEET type="text/css" href="./css/apprread.css">
<%
    } else if (sReturnURL.equals("CLOSE")) {
    	%>
        <link rel=STYLESHEET type="text/css" href="./css/apprread.css">
    <%
	} else {    
%>
<!--        <link rel=STYLESHEET type="text/css" href="./css/read_print.css"> -->
<%
    }
%>
<%-- 	<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>"> --%>
	<link rel="STYLESHEET" type="text/css" href="/common/css/style.css">
		<div id="PreviewDocument" name="PreviewDocument">
		<%
			String pHTML = request.getParameter("Print_innerHTML");
			
			//수행버튼 제거
			int btnIdx = pHTML.indexOf("id=btntbl");
			while(btnIdx>-1){
				pHTML = pHTML.substring(0, pHTML.indexOf("id=btntbl"))
					 + "style=\"display:none;\""
					 + pHTML.substring(pHTML.indexOf("id=btntbl")+9, pHTML.length());
				btnIdx = pHTML.indexOf("id=btntbl");
			}

			btnIdx = pHTML.indexOf("id=attachControl");
			while(btnIdx>-1){
				pHTML = pHTML.substring(0, pHTML.indexOf("id=attachControl"))
					 + "style=\"display:none;\""
					 + pHTML.substring(pHTML.indexOf("id=attachControl")+16, pHTML.length());
				btnIdx = pHTML.indexOf("id=attachControl");
			}
			
			//-----------------------------------------
			
			int sIdx = pHTML.indexOf("<script");
			int eIdx = 0;
			if (sIdx <0) sIdx = pHTML.indexOf("<SCRIPT");
			while(sIdx > -1)
			{
				eIdx = pHTML.indexOf("/script>");
				if (eIdx < 0) eIdx = pHTML.indexOf("/SCRIPT>");
				pHTML = pHTML.substring(0, sIdx - 1) + pHTML.substring(eIdx + 8);
				sIdx = pHTML.indexOf("<script");
				if (sIdx < 0) sIdx = pHTML.indexOf("<SCRIPT");
			}
            out.println(pHTML) ; 
	
		%>
		<%//=pHTML%>
		<%if (!attachfiles.equals("") ) { %>
		<table width="100%" height="30" border="0" cellspacing="0" cellpadding="0" id=btntbl>
			<tr>
				<td width="15%" class=td_le1>첨부파일</td>
				<td class=td_le2>
				<%
					StringTokenizer st = new StringTokenizer(attachfiles, "|");
					int num = 1;
					while(st.hasMoreTokens()){
						String str = st.nextToken();
						if(num%3==2){
							out.print("<div>"+(num/3+1)+". "+str+"</div>");
						}
						num++;
					}
				%>
				</td>
			</tr>
		</table>
		<%} %>
		</div>
					<!-- </td>
					<td style="width:14mm">&nbsp;</td>
				</tr>
			</table> -->
	</BODY>
</HTML>
