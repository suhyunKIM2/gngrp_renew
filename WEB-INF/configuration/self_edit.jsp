<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="nek3.common.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="nek3.web.form.configuration.UserWebForm"%>


<%!
	private String setSelectedOption(int i1, int i2)
	{
		String selectStr = "";
		if (i1 == i2) selectStr = "selected";
		return selectStr;
	}

	private String setSelectedOption(String str1, String str2)
	{
		String selectStr = "";
		if (str1.equals(str2)) selectStr = "selected";
		return selectStr;
	}
	
	String cssPath = "../common/css";
	String imgCssPath = "/common/css/blue";
	String imagePath = "../common/images/blue";
	String scriptPath = "../common/script";

%>
<!DOCTYPE html>
<html>
<head>
<META http-equiv="Expires" content="-1"> 
<META http-equiv="Pragma" content="no-cache"> 
<META http-equiv="Cache-Control" content="No-Cache"> 
<title><spring:message code="emp.private.info" text="개인정보"/></title>
<%@ include file="../common/include.mata.jsp"%>
<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jquery.form.jsp"%>
<%@ include file="../common/include.common.jsp"%>
<script src="http://dmaps.daum.net/map_js_init/postcode.v2.js"></script>
<script type="text/javascript">
	//영문/숫자를 혼합으로 구성되어있는지 체크하는 함수
	function  isAlphaNumeric(str) {
		var intChk = false;
		var strChk = false;
		var speChk = false;
		var strAry = /[a-zA-Z]/;	//영문 
		var intAry = /[0-9]/;		//숫자
		var speAry = /[\{\}\[\]\/?.,;:|\)*~`!^\-_+<>@\#$%&\\\=\(\'\"]/gi;	//특수문자
		
		for (var i = 0; i < str.length; i++) {	//영문
			if (strAry.test(str.charAt(i))) {
				strChk = true;
			}
		}
		for (var i = 0; i < str.length; i++) {	//숫자
			if (intAry.test(str.charAt(i))) {
				intChk = true;
			}
		}
		for (var i = 0; i < str.length; i++) {	//특수문자
			if (speAry.test(str.charAt(i))) {
				speChk = true;
			}
		}
		if(intChk&&strChk&&speChk){
			return true;
		}
		return false;
	}

	function inputValidation(){
		var frm = document.getElementById("userWebForm");
		var pwd = frm.elements["user.pwdHash"];
		var loginId = frm.elements["user.loginId"];
		var ppwd = frm.elements["user.previousPwdHash"];
		$(pwd).rules("remove");
		$(ppwd).rules("remove");
		//$("input[id='user.pwdHash']").rules("remove"); 이 방법도 사용가능
		$("#confirmPwdHash").rules("remove");
		if(frm.elements["changePasswd"].checked){
			$(pwd).rules("add",{
				required: true,
// 				minlength:8,
				<%if(SystemConfig.getInstance().getLoginModule() == 1){%>
				complexPwd:true,
				notEqualTo:loginId,
				<%}%>				 
				messages: {
					required: "<spring:message code='v.password.required' text='비밀번호를  입력하십시요' />",
					minlength: "<spring:message code='emp.password.minlength' text='비밀번호 길이는 8자리 이상이어야 합니다.' />",
					notEqualTo:"<spring:message code='emp.id.password.same' text='로그인ID와 동일한 비밀번호는 설정할 수 없습니다'/>"
				}
			});
			$("#confirmPwdHash").rules("add",{
				required: true,
				/*equalTo:$("input[id='user.pwdHash']"),*/
				equalTo:pwd,
				messages:{
					required:"<spring:message code='emp.password.required' text='비밀번호확인을 입력해 주십시요' />",
					equalTo:"<spring:message code='emp.pwdConfirm.unmatch' text='비밀번호와 비밀번호확인이 일치하지 않습니다' />"
				}
			});
			$(ppwd).rules("add",{
				required: true,			 
				messages: {
					required: "<spring:message code='v.password.required' text='비밀번호를  입력하십시요' />"
				}	
			});
		}
		
		var isValid = validator.form();
		if (!isValid) validator.focusInvalid();
		return isValid;

	}
	function goSubmit(){
		var frm = document.getElementById("userWebForm");
		
		if(!inputValidation()) return;
		
		if(!confirm("저장하시겠습니까?")) return;
		
		frm.method = "POST";
		frm.action = "self_write.htm";
		
		waitMsg();
		frm.submit();
	}
	function setUserPhoto(fileObj){
		var userPhoto = document.getElementById("userphoto");
		if (fileObj.value != "") {
			userPhoto.src = fileObj.value;
		} else {
			userPhoto.src = "../common/images/photo_user_default.gif";
		}
		
	}

	function openOrgaTree(){
		var returnValue = window.showModalDialog("../common/department_selector.htm?openmode=1&onlydept=1","","dialogWidth:320px;dialogHeight:450px;center:yes;help:0;status:0;scroll:0");
		if (returnValue != null)
		{
			var frm = document.getElementById("userWebForm");
			var arrayVal = returnValue.split(":");
			frm.elements["user.department.dpId"].value = arrayVal[1];
			frm.elements["user.department.dpName"].value = arrayVal[0];
		}
	}

	// 신 우편번호 검색창
    function execDaumPostcode() {
        new daum.Postcode({
            oncomplete: function(data) {
                // 팝업에서 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.

                // 도로명 주소의 노출 규칙에 따라 주소를 조합한다.
                // 내려오는 변수가 값이 없는 경우엔 공백('')값을 가지므로, 이를 참고하여 분기 한다.
                var fullRoadAddr = data.roadAddress; // 도로명 주소 변수
                var extraRoadAddr = ''; // 도로명 조합형 주소 변수

                // 법정동명이 있을 경우 추가한다. (법정리는 제외)
                // 법정동의 경우 마지막 문자가 "동/로/가"로 끝난다.
                if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)){
                    extraRoadAddr += data.bname;
                }
                // 건물명이 있고, 공동주택일 경우 추가한다.
                if(data.buildingName !== '' && data.apartment === 'Y'){
                   extraRoadAddr += (extraRoadAddr !== '' ? ', ' + data.buildingName : data.buildingName);
                }
                // 도로명, 지번 조합형 주소가 있을 경우, 괄호까지 추가한 최종 문자열을 만든다.
                if(extraRoadAddr !== ''){
                    extraRoadAddr = ' (' + extraRoadAddr + ')';
                }
                // 도로명, 지번 주소의 유무에 따라 해당 조합형 주소를 추가한다.
                if(fullRoadAddr !== ''){
                    fullRoadAddr += extraRoadAddr;
                }

                // 우편번호와 주소 정보를 해당 필드에 넣는다.
                document.getElementById('user.zipCode').value = data.zonecode; //5자리 새우편번호 사용
                document.getElementById('user.address').value = fullRoadAddr; //도로명 주소
                //document.getElementById('user.address2').value = data.jibunAddress; //지번 주소

                // 사용자가 '선택 안함'을 클릭한 경우, 예상 주소라는 표시를 해준다.
                /*
                if(data.autoRoadAddress) {
                    //예상되는 도로명 주소에 조합형 주소를 추가한다.
                    var expRoadAddr = data.autoRoadAddress + extraRoadAddr;
                    document.getElementById('guide').innerHTML = '(예상 도로명 주소 : ' + expRoadAddr + ')';

                } else if(data.autoJibunAddress) {
                    var expJibunAddr = data.autoJibunAddress;
                    document.getElementById('guide').innerHTML = '(예상 지번 주소 : ' + expJibunAddr + ')';

                } else {
                    document.getElementById('guide').innerHTML = '';
                }
                */
            }
        }).open();
    }
	
	// 구 우편번호 검색창
	function fnopenzipcode() {
		url= "../support/zipcode_form.jsp";
		winwidth = "379";
		winheight = "323";
		winleft = (screen.width - winwidth) / 2;
		wintop = (screen.height - winheight) / 2;
		winoptions = 'width=' + winwidth + ', height=' + winheight + ', left=' + winleft + ', top=' + wintop + ', toolbar=no';

		var addrwin=window.open(url,"",winoptions)
	}
	<c:if test="${isAdmin}">
    function gocheckId(varId){
        var frm = document.getElementById("userWebForm");
        var loginid = frm.elements["user.loginId"].value ;
        frm.elements["loginIdCheck"].value = "" ; 
        var popjsp = "../common/user_idcheck.jsp?loginId="+loginid ;
        var loca = "dialogWidth:379px;dialogHeight:180px;center:yes;help:0;status:0;scroll:0" ;
		var returnValue = window.showModalDialog(popjsp,"", loca);
		if (returnValue != null){			
			var arrayVal = returnValue.split("|");
			frm.elements["loginIdCheck"].value = arrayVal[1];
			frm.elements["user.loginId"].value = arrayVal[0];
			frm.elements["user.userName"].value = arrayVal[0];
            //exitloginid() ; 
		}
    }
    </c:if>
</script>
<script type="text/javascript">
var validator = null;
$(document).ready(function(){
	if(window.opener == null) $("#closeBtnArea").hide();
	
	$("#enterDate").datepicker({ 
		dateFormat: 'yy-mm-dd' ,
		monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
		prevText: '이전달',
		nextText: '다음달',
	 	yearRange: 'c-100:c+10', 		
		showOtherMonths: true,
		selectOtherMonths: true,
		changeMonth: true,
		changeYear: true
	});
	$("#retireDate").datepicker({ 
		dateFormat: 'yy-mm-dd' ,
		monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
		prevText: '이전달',
		nextText: '다음달',
	 	yearRange: 'c-100:c+10', 		
		showOtherMonths: true,
		selectOtherMonths: true,
		changeMonth: true,
		changeYear: true
	});
	$("#birthDay").datepicker({ 
		dateFormat: 'yy-mm-dd' ,
		monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
		prevText: '이전달',
		nextText: '다음달',
	 	yearRange: 'c-100:c+10', 		
		showOtherMonths: true,
		selectOtherMonths: true,
		changeMonth: true,
		changeYear: true
	});
	validator = $("#userWebForm").validate({
		rules:{
			<c:if test="${not isModify}">
			"user.loginId":{
				required:true
			},
			"loginIdCheck":{
				required:true
			},
			"user.userName":{
				required:true
			},
			</c:if>
			<c:if test="${isAdmin}">
			"user.nName":{
				required:true
			},
			"user.department.dpId":{
				required:true
			}
			</c:if>
		},
		messages:{
			<c:if test="${not isModify}">
			"user.loginId":{
				required:"<spring:message code='xxx' text='로그인ID를 입력해 주십시요' />"
			},
			"loginIdCheck":{
				required:"<spring:message code='xxx' text='로그인ID중복검사를 실행해 주십시요' />"
			},
			"user.userName":{
				required:"<spring:message code='xxx' text='E-Mail ID를 입력해 주십시요' />"
			},
			</c:if>
			<c:if test="${isAdmin}">
			"user.nName":{
				required:"<spring:message code='xxx' text='이름을 입력해 주십시요' />"
			},
			"user.department.dpId":{
				required:"<spring:message code='xxx' text='부서를 선택해 주십시요' />"
			}
			</c:if>
		},
		focusInvalid:true
	});
	jQuery.validator.addMethod("notEqualTo", function(value, element, params) {
		return value != $(params).val(); 
	});
	<%if(SystemConfig.getInstance().getLoginModule() == 1){%>
	jQuery.validator.addMethod("complexPwd", function(value, element){
		return isAlphaNumeric(value);
	}, "<spring:message code='emp.include.en.kr' text='영문과 숫자, 특수문자가 포함되어야 합니다' />");
	<%}%>
});

</script>

</head>

<body>
<form:form enctype="multipart/form-data" commandName="userWebForm">
	<%-- <form:hidden path="user.userId" /> --%>

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
		<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code="main.option" text="환경설정"/> &gt; <spring:message code="emp.private.info" text="개인정보"/> </span>
	</td>
	<td width="40%" align="right" style="padding:0 20px 0 0;">
	</td>
	</tr>
</table>
<!-- List Title -->

<table><tr><td class=tblspace03></td></tr></table>
<div style="width:90%;margin:auto;">
<!---수행버튼 --->
<table width="100%" cellspacing="0" cellpadding="0" border="0">
	<tr>
		<td align="left"> 
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px">
				<tr> 
					<td width="60" style="text-align: right;">
						<a onclick="goSubmit()" class="button white medium">
						<img src="../common/images/bb02.gif" border="0"> <fmt:message key="t.save"/> </a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<!-- 수행버튼 끝 -->


<table><tr><td class=tblspace03></td></tr></table>

<!-- 기본정보 타이틀 시작 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr height=30>
		<td class=i_body><img src=../common/images/i_body.gif align=absmiddle><B><spring:message code="emp.basic.info" text="기본정보"/></B></td>
	</tr>
</table>
<!-- 기본정보 타이틀 끝 -->

<table width="100%" cellspacing="0" cellpadding="0" border="0">
	<colgroup>
		<col width="15%">
		<col width="*">
	<colgroup>
	<tr>
		<td valign=middle align=center width=120 height=100%  class="td_le2" nowrap>
			<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td valign=middle align=center width=120 height=100% bgcolor="FFFFFF">						
						<img id="userphoto"  src="/userdata/photos/${userWebForm.user.userId }?_=<%=java.util.UUID.randomUUID().toString().replace("-", "") %>" border="0" width="100" height="120" onerror="this.src='../common/images/photo_user_default.gif';"><br>
						<span>(100 X 120)</span>
					</td>
				</tr>
			</table>
		</td>
		<td  valign=top height=100%>

			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="border-collapse:collapse;table-layout:fixed;">
				<colgroup>
					<col width="15%">
					<col width="35%">
					<col width="15%">
					<col width="35%">
				</colgroup>
				<tr>
					<td class="td_le1" nowrap><spring:message code="emp.loginId" text="로그인ID"/> </td>
					<td class="td_le2">
						<c:out value="${userWebForm.user.loginId }" />
						<form:hidden path="user.loginId" />
					</td>
					<td class="td_le1" nowrap>E-Mail</td>
					<td class="td_le2">
						<c:out value="${userWebForm.user.userName }" />@<c:out value="${userWebForm.userConfig.mailDomain}" />
						<form:hidden path="user.userName" />
					</td>
				</tr>
				<tr>
					<td class="td_le1" nowrap>E-MAIL 선택</td>
					<td class="td_le2" colspan=3>
						<form:select path="userConfig.mailDomain" onchange="//javascript:changeEmail();" style="width:38%;" >
							<form:option value="${domain }">${domain}</form:option>
							<c:forEach var="mDomain" items="${multiDomain }">
								<form:option value="${mDomain }">${mDomain}</form:option>
							</c:forEach>
						</form:select>
					</td>
				</tr>
				
				<tr>
					<td class="td_le1" nowrap><spring:message code="emp.password.previous" text="기존 패스워드"/> </td>
					<td class="td_le2">
						<form:password path="user.previousPwdHash" onkeyup="javascript:CheckTextCount(this,40);" class="w90p"/>
					</td>
					<td class="td_le1" nowrap><spring:message code="emp.password.change" text="패스워드 변경"/> </td>
					<td class="td_le2">
						<form:checkbox path="changePasswd" /> <label for="changePasswd1" style="cursor:pointer;"><spring:message code="appr.use" text="사용"/></label>
					</td>
				</tr>
				<tr>
					<td class="td_le1" nowrap><spring:message code="emp.password.new" text="새 패스워드"/></td>
					<td class="td_le2">
						<form:password path="user.pwdHash" onkeyup="javascript:CheckTextCount(this,40);" class="w90p"/>
					</td>
					<td class="td_le1" nowrap><spring:message code="emp.password.new.confirm" text="새 패스워드 확인"/></td>
					<td class="td_le2">
						<input type="password" id="confirmPwdHash" name="confirmPwdHash" onKeyUp="CheckTextCount(this, 40);" size="32" class="w90p">
					</td>
				</tr>
				 
				<tr>
					<td class="td_le1" nowrap><spring:message code="emp.id" text="사번"/></td>
					<td class="td_le2">
						<c:out value="${userWebForm.user.sabun}"/>
					</td>
					<td class="td_le1" nowrap><spring:message code="emp.join.date" text="입사일자"/></td>
					<td class="td_le2">
						<fmt:formatDate value="${userWebForm.user.enterDate}" pattern="yyyy-MM-dd"/>
					</td>
				</tr>
				<tr>
					<td class="td_le1" nowrap><spring:message code="emp.name.korea" text="이름(한글)"/></td>
					<td class="td_le2">
						<c:out value="${userWebForm.user.nName}" />
					</td>
					<td class="td_le1" nowrap><spring:message code="emp.name.english" text="이름(영문)"/></td>
					<td class="td_le2">
						<c:out value="${userWebForm.user.eName}" />
						<%--<form:input path="user.eName" onkeyup="javascript:CheckTextCount(this, 40);" size="32" cssClass="w90p" cssStyle="ime-mode:disabled;"/> --%>
					</td>
				</tr>
				<tr>
					<td class="td_le1" nowrap><spring:message code="t.department" text="부서"/> </td>
					<td class="td_le2" >
							<%-- <form:hidden path="user.department.dpId" /> --%>
							<c:out value="${userWebForm.user.department.dpName}" />
					</td>
					<td class="td_le1" nowrap><spring:message code="t.sercurityLevel" text="보안등급"/></td>
					<td class="td_le2">
						<c:choose>
							<c:when test="${user.securityLevel.title == '관리자'}">
								<spring:message code="t.administrator" text="관리자" />
							</c:when>
							<c:when test="${user.securityLevel.title == '전체사용'}">
								<spring:message code="t.use.full" text="전체사용" />
							</c:when>
							<c:otherwise>
								<c:out value="${user.securityLevel.title }" />
							</c:otherwise>
						</c:choose>
					</td>

				</tr>
				<tr>
					<td class="td_le1" nowrap><spring:message code="addr.positon" text="직급"/></td>
					<td class="td_le2" colspan="3">
						<c:out value="${userWebForm.user.userPosition.upName }" />
					</td>
<%-- 					<td class="td_le1" nowrap><spring:message code="addr.job.title" text="직책"/></td> --%>
<!-- 					<td class="td_le2"> -->
<%-- 						<c:out value="${userWebForm.user.userDuty.udName }" /> --%>
<!-- 					</td> -->
				</tr>
				<tr>
					<td class="td_le1" nowrap><spring:message code="t.mainJob" text="담당업무"/></td>
					<td class="td_le2" colspan="3">
						<c:out value="${userWebForm.user.mainJob }" />
					<%--
						<form:input path="user.mainJob" onkeyup="javascript:CheckTextCount(this, 100);" cssClass="w90p" />
						<form:hidden path="user.addJob" onkeyup="javascript:CheckTextCount(this, 100);" cssClass="w90p" />
					 --%>
					</td>
					<%-- 
					<td class="td_le1" nowrap><spring:message code="emp.adjunct" text="겸직"/></td>
					<td class="td_le2">
					</td>
					 --%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table class=tblspace05><tr><td></td></tr></table>


<!-- 개인정보 타이틀 시작 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr height=30>
		<td class=i_body><img src=../common/images/i_body.gif align=absmiddle><B><spring:message code="emp.private.info" text="개인정보"/></B></td>
	</tr>
</table>
<!-- 개인정보 타이틀 끝 -->

<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<colgroup>
		<col width="15%">
		<col width="35%">
		<col width="15%">
		<col width="35%">
	</colgroup>
	<tr>
		<td class="td_le1" nowrap><spring:message code="emp.phone.office" text="전화(사무실)"/></td>
		<td class="td_le2">
			${userWebForm.user.telNo }
			<%-- <form:input path="user.telNo" maxlength="30" cssClass="w90p" /> --%>
		</td>
		<td class="td_le1" nowrap><spring:message code="emp.email.personal" text="개인 E-Mail"/></td>
		<td class="td_le2">
			${userWebForm.user.internetMail }
			<%-- <form:input path="user.internetMail" cssClass="w90p" cssStyle="ime-mode:disabled"  /> --%>
		</td>
	</tr>
	<tr>
		<td class="td_le1" nowrap><spring:message code="emp.phone.home" text="전화(자택)"/></td>
		<td class="td_le2">
			${userWebForm.user.homeTel }
			<%-- <form:input path="user.homeTel" maxlength="30" cssClass="w90p" /> --%>
		</td>
		<td class="td_le1" nowrap><spring:message code="addr.cellphone" text="휴대폰"/></td>
		<td class="td_le2">
			${userWebForm.user.cellTel }
			<%-- <form:input path="user.cellTel" maxlength="30" cssClass="w90p" /> --%>
		</td>
	</tr>
	<tr>
		<td class="td_le1" nowrap><spring:message code="emp.date.birth" text="생년월일"/></td>
		<td class="td_le2" colspan="3">
			<c:out value="${userWebForm.birthDay }" />
			<%--
            <form:input path="birthDay" maxlength="10"  style="width:50%;"/>	
            &nbsp;&nbsp;&nbsp;<spring:message code="emp.lunar" text="음력"/> <form:checkbox path="user.solBirth" style="vertical-align: middle;" />
             --%>
		</td>
		<%--
		<td class="td_le1" nowrap><spring:message code="emp.photo" text="사진"/></td>
		<td class="td_le2">
			<input type="file" name="userWebForm.photoFile" id="userWebForm.photoFile" style="height:20px;" class="w50p" onchange="javascript:setUserPhoto(this);">
			&nbsp;
			<input type="checkbox" name="delPhoto" id="delPhoto" value="1"><label for="delPhoto" style="cursor:pointer;"><spring:message code="emp.photo.del" text="사진삭제"/></label>
		</td> --%>
	</tr>

	<tr>
		<td class="td_le1" nowrap><spring:message code="addr.zipcode" text="우편번호"/></td>
		<td class="td_le2" colspan="3">
			${userWebForm.user.zipCode }
			<%--
			<form:input path="user.zipCode" style="width:50%;" readonly="true" />
			<span onclick="execDaumPostcode()" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.search" text="검색" /> </span>
			 --%>
		</td>
	</tr>
	<tr>
		<td class="td_le1" nowrap rowspan="2"><spring:message code="addr.address" text="주소"/></td>
		<td class="td_le2" colspan="3">
			${userWebForm.user.address }
			<%-- <form:input path="user.address" cssStyle="width:400px;" readonly="true" /> --%>
		</td>
	</tr>
	<tr>
		<td class="td_le2" colspan="3">
			${userWebForm.user.address2 }
			<%--
			<form:input path="user.address2" cssStyle="width:400px;" />
			<spring:message code="emp.address.enter" text="(※나머지 주소 입력)"/> --%>
		</td>
	</tr>

</table>
<table class=tblspace05><tr><td></td></tr></table>


<!-- 환경정보 타이틀 시작 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr height=30>
		<td class=i_body><img src=../common/images/i_body.gif align=absmiddle><B><spring:message code="emp.environmental.info" text="환경정보"/></B></td>
	</tr>
</table>
<!-- 환경정보 타이틀 끝 -->

<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<colgroup>
		<col width="15%">
		<col width="35%">
		<col width="15%">
		<col width="35%">
	</colgroup>
	<tr>
		<td class="td_le1" nowrap><spring:message code="emp.MailboxCapacity" text="편지함 용량"/></td>
		<td class="td_le2">
			${userWebForm.mailBoxSize } MB					
		</td>
		<td class="td_le1" nowrap><spring:message code="emp.Outgoing.mail.size.limit" text="보내는 메일크기 제한"/></td>
		<td class="td_le2">
			${userWebForm.sendMailSize } MB					
		</td>
	<tr>
		<td class="td_le1" nowrap>list/page</td>
<!-- 		<td class="td_le2"> -->
		<td class="td_le2" colspan="3">
			${userWebForm.userConfig.listPPage }
			<%--
			<form:select path="userConfig.listPPage" style="width:60px;">
				<form:option value="5">5</form:option>
				<form:option value="10">10</form:option>
				<form:option value="15">15</form:option>
				<form:option value="20">20</form:option>
				<form:option value="25">25</form:option>
				<form:option value="30">30</form:option>
				<form:option value="35">35</form:option>
				<form:option value="40">40</form:option>
				<form:option value="45">45</form:option>
				<form:option value="50">50</form:option>
			</form:select> --%>
		</td>
		<%-- <td class="td_le1" nowrap>block/page</td>
		<td class="td_le2">
			<form:select path="userConfig.blockPPage" style="width:54px;">
				<form:option value="5">5</form:option>
				<form:option value="10">10</form:option>
				<form:option value="15">15</form:option>
				<form:option value="20">20</form:option>
			</form:select>
		</td> --%>
	</tr>
	<%--
	<tr>
		<td class="td_le1" nowrap><spring:message code="mail.g.open.window" text="새창으로 열기"/></td>
		<td class="td_le2">
			<form:radiobutton id="windowOpen_F" path="userConfig.windowOpen" value="false" /><label for="windowOpen_F" style="cursor: pointer;"><spring:message code="ope.notuse" text="사용안함" /></label>
			<form:radiobutton id="windowOpen_T" path="userConfig.windowOpen" value="true" /><label for="windowOpen_T" style="cursor: pointer;"><spring:message code="appr.use" text="사용" /></label>
		</td>
		<td class="td_le1" nowrap><spring:message code="t.language" text="언어"/></td>
		<td class="td_le2">
			<form:select path="userConfig.locale">
				<form:option value="ko">한국어</form:option>
				<form:option value="en">English</form:option>
				<form:option value="ja">日本語</form:option>
				<form:option value="zh">中文</form:option>
			</form:select>
		</td>
	</tr>
	<tr>
		<td class="td_le1" nowrap><spring:message code="mail.received.check" text="메일수신확인"/></td>
		<td class="td_le2">
			<form:radiobutton id="mailReceive_F" path="userConfig.mailReceive" value="false" /><label for="mailReceive_F" style="cursor: pointer;"><spring:message code="ope.notuse" text="사용안함" /></label>
			<form:radiobutton id="mailReceive_T" path="userConfig.mailReceive" value="true" /><label for="mailReceive_T" style="cursor: pointer;"><spring:message code="appr.use" text="사용" /></label>
		</td>
		<td class="td_le1" nowrap></td>
		<td class="td_le2"></td>
	</tr>
	 --%>
</table>
</div>
</form:form>
</body>
</html>