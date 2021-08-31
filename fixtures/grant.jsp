<%@ page contentType="text/html;charset=utf-8"%>
<%@ page errorPage="/error.jsp"%>
<%@ page import="nek.fixtures.*"%>
<%@ page import="java.util.*"%>
<%@ page import="net.sf.json.*"%>
<%@ page import="nek.common.*,nek.common.util.Convert"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%	request.setCharacterEncoding("utf-8");%>
<%@ include file="/common/usersession.jsp"%>


<%
int logLevel = 0; //접속자 레벨설정
boolean isAdmin = false;
if (loginuser.securityId > 8)	{ isAdmin = true;	logLevel = 3; } //전체 관리자

if(logLevel < 3) response.sendRedirect("./grant_error.jsp"); //전체관리자가 아닐경우 페이지 이동하기

%>
<!DOCTYPE html>
<html>
<head>
<title></title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.jqgrid.jsp"%>
<%@ include file="/WEB-INF/common/include.common.jsp" %>
<style type="text/css">
label {	margin: 0px 3px 0px 12px;}
.btn {cursor:pointer;}

#search_dataGrid .ui-pg-div {	display: none;} /* jqgrid search hidden */
#dataGridPager {	height: 30px;} /* jqgrid pager height */
.ui-jqgrid .ui-pg-selbox {	height: 23px;	line-height: 23px;} /* jqgrid pager select height */
</style>
<script type="text/javascript">
function goSubmit(cmd)
{
	var frm = document.submitForm;
	if(frm.manageDeptName.value =="") return;
	if(frm.manageUserName.value =="") return;
	var delStr = "<%=msglang.getString("c.delete") %>";				//삭제 하시겠습니까?
	var closeStr = "<%=msglang.getString("c.unsaveClose") %>";	//편집중인 문서는 저장되지 않습니다 \!\\n창을 닫으시겠습니까 ?
	
	switch(cmd)
	{
		case "insert" :
			if(!grantControl("checkDate")) return;
			break;
		case "delete" :
			if(!confirm(delStr)) return;
			if(!grantControl("delete")) return;
			break;
		case "update" :
			if(!grantControl("checkDateUp")) return;
			break;
			
		case "close":
			if(confirm(closeStr))	self.close();
			break;
	}
	 frm.submit();
}

</script>


<script type="text/javascript">

//(window.showModalDialog Version)
function openDeptSelectorModal(sVal)
{
	if(!sVal)
	{
		var returnValue = window.showModalDialog("../../common/department_selector.jsp?openmode=1&onlyuser=1","","dialogWidth:280px;dialogHeight:450px;center:yes;help:0;status:0;scroll:0");
		if (returnValue != null)
		{
			var arrayVal = returnValue.split(":");
			
		var manageUserName = document.getElementsByName("manageUserName")[0];
		var manageUserId = document.getElementsByName("manageUserId")[0];
		
		manageUserName.value = arrayVal[0];
		manageUserId.value= arrayVal[1];
		}
		return;
	}
		
	var returnValue = window.showModalDialog("../../common/department_selector.jsp?openmode=1&onlydept=1","","dialogWidth:280px;dialogHeight:450px;center:yes;help:0;status:0;scroll:0");
	if (returnValue != null)
	{
		var arrayVal = returnValue.split(":");
		
	var manageDeptName = document.getElementsByName("manageDeptName")[0];
	var manageDeptId = document.getElementsByName("manageDeptId")[0];
	
	manageDeptName.value = arrayVal[0];
	manageDeptId.value= arrayVal[1];
		
	}
}

//(dhtmlmodal Version)
function openDeptSelector(sVal) {
	var url = "../../common/department_selector.jsp?openmode=1&onlydept=1";
	var title = "<%=msglang.getString("book.manage") %>";	//대여관리
			
	if (!sVal) {
		url = "../../common/department_selector.jsp?openmode=1&onlyuser=1";
	}
	window.modalwindow = window.dhtmlmodal.open(
		"_CHILDWINDOW_COMM1002", "iframe", url, title, 
		"width=280px,height=450px,resize=0,scrolling=1,center=1", "recal"
	);
	TempSaveVal = sVal;
}

TempSaveVal = null;

function setDeptSelector(returnValue) {
	var sVal = TempSaveVal;
	if (returnValue != null) {
		var arrayVal = returnValue.split(":");
		if (!sVal) {
			var manageUserName = document.getElementsByName("manageUserName")[0];
			var manageUserId = document.getElementsByName("manageUserId")[0];
			manageUserName.value = arrayVal[0];
			manageUserId.value= arrayVal[1];
		} else {
			var manageDeptName = document.getElementsByName("manageDeptName")[0];
			var manageDeptId = document.getElementsByName("manageDeptId")[0];
			manageDeptName.value = arrayVal[0];
			manageDeptId.value= arrayVal[1];
		}
	}
}

</script>

<script type="text/javascript">
		$.jgrid.no_legacy_api = true;
		$.jgrid.useJSON = true;
		
		$(document).ready(function(){
			$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});
			var grid = $("#dataGrid");
			var emptyMsgDiv = $("<div style='width:100%;height:100%;position:relative;'><div style='position:absolute;top:50%;margin-top:-5em;width:100%;text-align:center;'>등록된 자료가 없습니다.</div></div>");
			$("#resetSearch").hide();
			$("img").attr("align", "absmiddle");
			$("#viewList").attr("onpropertychanges", "div_resize()");
			
	
		$("#dataGrid").jqGrid({    

		    scroll: true,
		   	url:"/fixtures/data/grantList_json.jsp"
			   		+ "?search_id="+$("#search_id").val()
					+ "&search_value=" + encodeURI($("#search_value").val(),"UTF-8"),
			datatype: "json",
			width: '100%',
			height:'100%',
// 			부서, 관리부서, 담당자ID, 담당자, 권한등급, 삭제코드
			colNames:['<%=msglang.getString("t.dpName") %> ID',
			          		'<%=msglang.getString("src.mngdp") %>',
			          		'<%=msglang.getString("src.charger") %>ID',
			          		'<%=msglang.getString("src.charger") %>',
			          		'<%=msglang.getString("src.auth.level") %>',
			          		'<%=msglang.getString("src.delete.code") %>'
			],						
			colModel:[
				{name:'manageDeptId',index:'manageDeptId', width:38, align:"center",hidden:true},
				{name:'manageDeptName',index:'manageDeptName', width:38, align:"center"},
				{name:'manageUserId',index:'manageUserId', width:38, align:"center",hidden:true},
				{name:'manageUserName',index:'manageUserName', width:38, align:"center"},
				{name:'manageLevel',index:'manageLevel', width:38, align:"center",hidden:true},
				{name:'fixed',index:'fixed', width:38, align:"center",hidden:true}
			],
		   	rowNum: 10,
		   	rowList: [10,20,30],
		   	mtype: "GET",
			prmNames: {search:null, nd: null, rows: "rowsNum", page: "pageNo", sort: "sortColumn", order: "sortType" },  
		   	pager: '#dataGridPager',
		    viewrecords: true,
		    sortname: 'manageDeptName',
		    sortorder: 'desc',
		    caption: '<%=msglang.getString("src.mngdp") %> & <%=msglang.getString("src.charger") %> ',
		    scroll:false,
		    onCellSelect: function(rowid, iCol){   //grid ROW 클릭할 경우.   
		         var list = jQuery("#dataGrid").getRowData(rowid);
		 		
		        $('input[name=manageDeptId]').val(list.manageDeptId);
		        $('input[name=manageUserId]').val(list.manageUserId);
		        $('input[name=manageDeptName]').val(list.manageDeptName);
		        $('input[name=manageUserName]').val(list.manageUserName);
		        
		        $('input[name=dId]').val(list.manageDeptId);
		        $('input[name=uId]').val(list.manageUserId);
		         
	 			$("#saveBtn").hide();
	 			$("#updateBtn").show();
	 			$("#deleteBtn").show();
			},
			loadError:function(xhr,st,err) {
		    	$("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText);
		    },
		    loadComplete:function(data){
		    	
		    	/* jqGrid PageNumbering Trick */
		    	var i, myPageRefresh = function(e) {
		            var newPage = $(e.target).text();
		            grid.trigger("reloadGrid",[{page:newPage}]);
		            e.preventDefault();
		        };
		        
		    	/* MAX_PAGERS is Numbering Count. Public Variable : ex) 5 */
		        jqGridNumbering( $("#dataGrid"), this, i, myPageRefresh );
		
	            var ids = grid.jqGrid('getDataIDs');
	            if (ids.length == 0) {
	            	grid.hide(); emptyMsgDiv.show();
	            } else {
	            	grid.show(); emptyMsgDiv.hide();
	            }

		    }
		});
		$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:true,edit:false,add:false,del:false});
		$("#dataGrid").setGridWidth(450);	//좌측 리스트의 가로길이 설정
		$("#dataGrid").setGridHeight($(window).height()-250);
	
		$(window).bind('resize', function() {
			$("#dataGrid").setGridWidth(450);	//좌측 리스트의 가로길이 설정
			$("#dataGrid").setGridHeight($(window).height()-250);
		}).trigger('resize');
	});

		
	function gridReload(){
		var search_id = $("#search_id").val();
		var search_value = encodeURI($("#search_value").val(),"UTF-8");
		
		var reqUrl = "/fixtures/data/grantList_json.jsp"
			   		+ "?search_id="+$("#search_id").val()
					+ "&search_value="+search_value;
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");	// 데이터만 받아오고, 페이징은 그대로 임.
		$("#resetSearch").css('display', '');
	}
	
	
</script>	

<script type="text/javascript">
function grantControl(cmd)
{
	var frm = document.submitForm;
		frm.cmd.value = cmd;
		
	var regiStr = "<%=msglang.getString("v.registered.admin") %>";		//등록되어 있는 관리자 입니다.
	var saveStr = "<%=msglang.getString("c.dept.admin.add") %>";		//부서 비품관리자로 등록 하시겠습니까?
	var chaStr = "<%=msglang.getString("c.dept.admin.change") %>";	//부서 비품관리자를 변경 하시겠습니까?
	
	$.ajax
		({			
			type : "Get",
			url : "/fixtures/data/grantControl_json.jsp"
		   		+ "?cmd=" + cmd
				+ "&manageDeptId=" + $("#manageDeptId").val()
				+ "&manageDeptName=" + encodeURI($("#manageDeptName").val(),"UTF-8")
				+ "&manageUserId=" + $("#manageUserId").val()
				+ "&manageUserName=" + encodeURI($("#manageUserName").val(),"UTF-8")
				+ "&dId=" + $("#dId").val()
				+ "&uId=" + $("#uId").val(),
			datas : "html",
			success : function(datas, textStatus, jqXHR)
			{
				result = eval("("+datas+")");
				
					switch(result.flag)
					{
					case "no_check":
						alert(regiStr);
						return false;
					break;
					
					case "yes_check":
						if(!confirm(saveStr)) return false;
						grantControl("insert"); 
						return false;
					break;
					case "yes_checkup":
						if(!confirm(chaStr)) return false;
						grantControl("update"); 
						return false;
					break;
					
					case "yes_insert":
						gridReload();
					break;
					case "yes_delete":
						gridReload();
					break;
					case "yes_update":
						gridReload();
					break;
					}
				
			},
			error :function(jqXHR, textStatus, errorThrown){
				alert(textStatus + ":" + errorThrown);
			},
			async : false
		});
}
</script>	
<style>
.ui-jqgrid .ui-jqgrid-htable{min-width: auto !important;}
.save_btn{height: 30px;line-height: 30px;width: 13%;background: #266fb5;color: #fff;border: 1px solid #266fb5;}
.save_btn:hover{background: #266fb5;color: #fff;}
.delete_btn{background:#999;border-color:#999;}
.delete_btn:hover{background:#999;}
.td_le2{height:50px;}
INPUT[type=text]{height:25px;}
.white{height:25px;line-height: 25px;}
SELECT{height:35px;}
</style>
</HEAD>
<BODY>
<form id="submitForm" name="submitForm" autocomplete="off" method="get" action="" enctype="multipart/form-data">
	<input type="hidden" name="cmd" id="cmd" value="">
	<input type="hidden" name="manageDeptId" id="manageDeptId" value="">
	<input type="hidden" name="manageUserId" id="manageUserId" value="">
	<input type="hidden" name="dId" id="dId" value="">
	<input type="hidden" name="uId" id="uId" value="">
	<input type="hidden" name="manageLevel" id="manageLevel" value="">

<!-- List Title -->	
<!-- <table width="100%" border="0" cellspacing="0" cellpadding="0" height="27"> -->
<!-- <tr>  -->
<%-- 	<td width="35"><img src="<%=imagePath %>/sub_img/sub_title_schedule.jpg" width="27" height="27"></td> --%>
<!-- 		<td class="SubTitle"><b>부서 비품관리자 설정</b></td> -->
<!-- 		<td valign="bottom" width="250" align="right">  -->
<!-- 			<table border="0" cellspacing="0" cellpadding="0" height="17"> -->
<!-- 				<tr> -->
<!-- 					<td valign="top" class="SubLocation">비품관리 &gt; <b>부서비품관리자</b></td> -->
<!-- 				</tr> -->
<!-- 			</table> -->
<!-- 		</td> -->
<!-- 	</tr> -->
<!-- </table> -->

<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
		<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <b>
			<%=msglang.getString("src.manage.set") %><!-- 부서 비품관리자 설정 -->
		</b> </span>
	</td>
	<td width="40%" align="right">
<!-- 	n 개의 읽지않은 문서가 있습니다. -->
	</td>
	</tr>
	</table>
<!-- List Title -->	
<!-- <table width="100%" border="0" cellspacing="0" cellpadding="0" height="3"> -->
<!-- <tr>  -->
<%-- 	<td width="200" bgcolor="eaeaea"><img src="<%=imagePath %>/sub_img/sub_title_line.jpg" width="200" height="3"></td> --%>
<!-- 		<td bgcolor="eaeaea"></td> -->
<!-- </tr> -->
<!-- </table> -->


<div class="space" style="width:400px;">&nbsp;</div>
<div class="space" style="width:400px;">&nbsp;</div>



		<div style="float: left; width: 400px;padding: 5px 0 0 10px;">
			<!-- List -->
			<div id="viewList" class="div-view" >
				<table id="dataGrid"></table>
				<div id="dataGridPager"></div>
				<span id="errorDisplayer" style="color: red"></span>
			</div>
			<!-- List -->
			
			<div class="space">&nbsp;</div>
			<div class="space">&nbsp;</div>
				<select name="search_id" id="search_id" >
					<option value="manageDeptName"><%=msglang.getString("src.mngdp") %></option>
					<option value="manageUserName"><%=msglang.getString("src.charger") %></option>
				</select>
				<input type="text" name="search_value" id="search_value" value="" style="width:100px;"/>
				<a onclick="gridReload()" id="submitButton" class="button white medium">
				<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.search") %> </a>
				<a onclick="location.reload()" id="resetSearch" style="display:none;" class="button white medium">
				<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.search.del") %> </a> 	
		</div>
		
		
		<div style="float: left; padding-left:15px; width: 40%;">
			
			<div class="space">&nbsp;</div>
			<div class="space">&nbsp;</div>
			<table width="100%" cellspacing=0 cellpadding=0  style="border:1px solid #90B9CB; padding:2 2 2 4; background-color:#EDF2F5;">
				<tr>
					<td class="td_le1" colspan="2"  NOWRAP >
						<label class="btn" onclick="javascript:self.location.reload(true)" >|| <%=msglang.getString("src.mngdp") %> & <%=msglang.getString("src.charger") %> Management<!-- 부서 비품관리자 등록하기--> ||</label>
					</td>
				</tr>
				<tr>
					<td class="td_le1" NOWRAP><%=msglang.getString("src.mngdp") %><!-- 부서--></td>
					<td class="td_le2" >
						<input type=text name="manageDeptName" id="manageDeptName" class="w60p" value="" maxlength="30" onclick="javascript:openDeptSelector(1);" readonly>
						<a onclick="javascript:openDeptSelector(1);" class="button white small">
						<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.search") %> </a>
					</td>
				</tr>
				<tr>
					<td class="td_le1" NOWRAP ><%=msglang.getString("src.charger") %><!-- 담당자--></td>
					<td class="td_le2" >
						<input type=text name="manageUserName" id="manageUserName" class="w60p" value="" maxlength="30" onclick="javascript:openDeptSelector(0);" readonly>
						<a onclick="javascript:openDeptSelector(0);" class="button white small" >
						<img src="../common/images/bb02.gif" border="0" > <%=msglang.getString("t.search") %> </a>
					</td>
				</tr>
			</table>
			
			<div class="space">&nbsp;</div>
			<div class="space">&nbsp;</div>
			<div style="text-align: right;">
                <a id="saveBtn" onclick="javascript:goSubmit('insert');" class="button white medium save_btn">
                <!--<img src="../common/images/bb02.gif" border="0">--> <%=msglang.getString("t.save") %> </a>		
                <a style="display: none;" id="updateBtn" onclick="javascript:goSubmit('update');" class="button white medium save_btn">
                <!--<img src="../common/images/bb02.gif" border="0">--> <%=msglang.getString("t.modify") %> </a>
                <a style="display: none;" id="deleteBtn" onclick="javascript:goSubmit('delete');" class="button white medium save_btn delete_btn">
                <!--<img src="../common/images/bb02.gif" border="0">--> <%=msglang.getString("t.delete") %> </a>
			</div>	
<%-- 			<table id="saveBtn" border="0" cellspacing="0" cellpadding="0" class="ActBtn" OnMouseOut="ch_btn01.src='<%=imagePath %>/btn1_left.jpg'" OnMouseOver="ch_btn01.src='<%=imagePath %>/btn2_left.jpg'" style="float:left; margin:0 5px 0 0px;"> --%>
<!-- 			<tr> -->
<%-- 				<td width="23"><img id="btnIma01" name="ch_btn01" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td> --%>
<!-- 				<td background="../common/images/blue/btn1_bg.jpg"> -->
<!-- 				<span class="btntext" style="line-height:20px;">&nbsp;<a href="javascript:goSubmit('insert')">등록</a></span> -->
				
<!-- 				</td> -->
<!-- 				<td width="3"><img src="../common/images/blue/btn1_right.jpg" width="3" height="22"></td> -->
<!-- 			</tr> -->
<!-- 			</table> -->
			
<%-- 			<table id="updateBtn" border="0" cellspacing="0" cellpadding="0" class="ActBtn" OnMouseOut="ch_btn02.src='<%=imagePath %>/btn1_left.jpg'" OnMouseOver="ch_btn02.src='<%=imagePath %>/btn2_left.jpg'" style="float:left; margin:0 5px 0 0px; display: none;"> --%>
<!-- 			<tr> -->
<%-- 				<td width="23"><img id="btnIma02" name="ch_btn02" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td> --%>
<!-- 				<td background="../common/images/blue/btn1_bg.jpg"> -->
<!-- 				<span class="btntext" style="line-height:20px;">&nbsp;<a href="javascript:goSubmit('update')">편집</a></span> -->
				
<!-- 				</td> -->
<!-- 				<td width="3"><img src="../common/images/blue/btn1_right.jpg" width="3" height="22"></td> -->
<!-- 			</tr> -->
<!-- 			</table> -->
			
<%-- 			<table id="deleteBtn" border="0" cellspacing="0" cellpadding="0" class="ActBtn" OnMouseOut="ch_btn03.src='<%=imagePath %>/btn1_left.jpg'" OnMouseOver="ch_btn03.src='<%=imagePath %>/btn2_left.jpg'" style="float:left; margin:0 5px 0 0px; display: none;"> --%>
<!-- 			<tr> -->
<%-- 				<td width="23"><img id="btnIma03" name="ch_btn03" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td> --%>
<!-- 				<td background="../common/images/blue/btn1_bg.jpg"> -->
				
<!-- 				<span class="btntext" style="line-height:20px;">&nbsp;<a href="javascript:goSubmit('delete')">삭제</a></span> -->
<!-- 				</td> -->
<!-- 				<td width="3"><img src="../common/images/blue/btn1_right.jpg" width="3" height="22"></td> -->
<!-- 			</tr> -->
<!-- 			</table> -->
		</div>


</form>
</BODY>

</HTML>


