<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<% request.setCharacterEncoding("utf-8");%>
<%
	String actionURL			= request.getParameter("actionurl");
	String maxFileCount		= request.getParameter("maxfilecount");
	String maxFileSize		= request.getParameter("maxfilesize");
	String attachFiles			= request.getParameter("attachfiles");

	if (actionURL == null) actionURL = "";
	if (maxFileCount  == null || "".equals(maxFileCount)) maxFileCount = "-1";
	if (maxFileSize  == null || "".equals(maxFileSize)) maxFileSize = "-1";
	if (attachFiles == null) attachFiles = "";

	String userAgent = request.getHeader("User-Agent");
	String cabfile = "nektrans_java_w.cab#Version=1,0,0,8";
	if (userAgent == null || 
		userAgent.indexOf("Windows 95") > 0 ||
		userAgent.indexOf("Windows 98") > 0)
	{
		cabfile = "nektrans_java_a.cab#Version=1,0,0,9";
	}
	//System.out.println("fileup url==>"+	actionURL) ; 
%>
<script src="../common/scripts/active_control.js"></script>
<table width="100%" height="100" border="0" cellspacing="0" cellpadding="0" id="btntbl">
	<tr>
		<td width="120" class=td_le1 nowrap>첨부파일</td>
		<td class=td_le2>
			<script language="javascript">
				uploadControl("<%=cabfile%>", "<%=attachFiles%>", "<%=actionURL%>", "<%=maxFileCount%>", "<%=maxFileSize%>");
			</script>
		</td>
	</tr>
</table>