<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<% 	request.setCharacterEncoding("UTF-8"); %>
<%@ include file="../common/usersession.jsp"%>

<html>
<head>
<link rel=STYLESHEET type="text/css" href="<%= cssPath %>/list.css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
<script src="<%=scriptPath %>/common.js"></script>
<title>사용자 일괄 등록</title>
<script language="javascript">
	function goSubmit(){
		var csvfile = mainForm.csvfile.value;
		if(csvfile==""){
			alert("파일을 선택해주십시오");
			return;
		}else{
			if(csvfile.substring(csvfile.indexOf(".")+1,csvfile.length).toLowerCase()!="csv"){
				alert("CSV파일을 선택해주십시오");
				return;
			}
		}
		
		//진행 상태바
		var pgObj = document.getElementById("myid");
	 	pgObj.style.display = "";
	 	
		mainForm.submit();
	}
</script>
</head>

<body style="margin-left:15px;margin-top:10px;">
<form name="mainForm" method="post" action ="./user_batch.jsp"  enctype="multipart/form-data">
<input type="hidden" value="insert" name="cmd">

<!-- 진행 상태바 -->
<jsp:include page="/common/progress.jsp" flush="true">
    <jsp:param name="ctype" value="3"/>
</jsp:include>

<!-- 타이틀 시작 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" height="34">
	<tr> 
		<td height="27"> 
			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27">
				<tr> 
					<td width="35"><img src="<%=imagePath %>/sub_img/sub_title_admin.jpg" width="27" height="27"></td>
					<td class="SubTitle">사용자 일괄 등록</td>
					<td valign="bottom" width="*" align="right"> 
						<table border="0" cellspacing="0" cellpadding="0" height="17">
							<tr> 
								<td valign="top" class="SubLocation">관리자 &gt; <b>조직관리</td>
								<td align="right" width="15"><img src="<%=imagePath %>/sub_img/sub_title_location_icon.jpg" width="10" height="10"></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr> 
		<td height="3"></td>
	</tr>
	<tr> 
		<td height="3"> 
			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="3">
				<tr> 
					<td width="200" bgcolor="eaeaea"><img src="<%=imagePath %>/sub_img/sub_title_line.jpg" width="200" height="3"></td>
					<td bgcolor="eaeaea"></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<!-- 타이틀 끝 -->

<table><tr><td class=tblspace03></td></tr></table>

<!---수행버튼 --->
<table width="100%" cellspacing="0" cellpadding="0" border="0">
	<tr>
		<td align="left"> 
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px">
				<tr> 
					<td width="60"> 
						<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:goSubmit();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma01','','<%=imagePath %>/btn2_left.jpg',1)">
							<tr>
								<td width="23"><img id="btnIma01" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;저장</span></td>
								<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
							</tr>
						</table>
						<td width="*">&nbsp;</td>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<!-- 수행버튼 끝 -->

<table><tr><td class=tblspace09></td></tr></table>

<table width="100%" cellspacing="0" cellpadding="0" border="0" style="border-collapse:collapse;">
	<tr>
		<td width="600" valign="top">
			<table width="100%" cellspacing="0" cellpadding="0"  style="border:1px solid #90B9CB; padding:2 2 2 4; background-color:#EDF2F5;">
				<tr>
					<td class="td_ce1" width="200">사용자 파일 불러오기</td>
					<td class="td_le2"><input type="file" value="" name="csvfile" style="width:300px;"></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<table><tr><td class=tblspace09></td></tr></table>

<table width="100%" cellspacing=0 cellpadding=0 border=0>
	<tr>
	<td width="*" style="padding:10 10 10 10;">
		</td>
	</tr>
</table>
</form>
</body>
</HTML>