<%@ page contentType="text/html;charset=utf-8" %>
<% 	request.setCharacterEncoding("utf-8"); %>
<%@ include file="../common/usersession.jsp"%>
<FRAMESET ROWS="40,*"  border="0">
	<FRAME SRC="./organization_title.jsp" name="tree_title"   noresize="yes" border="0" scrolling="no">
	<FRAMESET COLS="10,280,*" border="0">
		<frame src="" name="null_frame" scrolling="no">
		<FRAME SRC="../common/department_selector.htm?openmode=2&isadmin=1&onlydept=1&winname=parent.dept_frame" NAME="tree_frame" scrolling="no">
		<FRAME SRC="" NAME="dept_frame">
	</FRAMESET>
</FRAMESET>