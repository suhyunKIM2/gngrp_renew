<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="s"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<link rel="stylesheet" href="/common/css/style.css">
<link rel="stylesheet" type="text/css" href="/resources/css/admin.css">

<%@ include file="/resources/ims.jquery.jsp"%>

<script type="text/javascript">

    $(document).ready(function() {
    	
		$(".ui_select").selectBox();
		
		// text, password 속성 변경 
		$('#contentFormMberTab input:text,#contentFormMberTab input:password')
		  .button().addClass('text','widget-content','ui-corner-all');
		
		// text, password 속성 변경 
		$('#searchFormMberTab input:text,#searchFormMberTab input:password')
		  .button().addClass('text','widget-content','ui-corner-all');
		
		$(".error").hide();

		/***** 회원정보 *****/
		$("#searchFormMberTab").tabs();
		$("#contentFormMberTab").tabs();
		
		var $param = new Object();
		$param.group_cd = 'USEYN';
		getAjaxCodeListSelectBox($("#sel_super_yn"),$param);
		$param.group_cd = 'USEYN';
		getAjaxCodeListSelectBox($("#sel_team_yn"),$param);
		$param.group_cd = 'AUTH_CODE';
		getAjaxCodeListSelectBox($("#sel_auth_yn"),$param);
		$param.group_cd = 'ED_CMPNY_CODE';
		getAjaxCodeListSelectBox($("#sel_cmpny_cd"),$param, '${empl_info.cmpny_cd}','선택',"cmpnyChangeEvent();");
		$param.group_cd  = 'ED_DEPT_CODE_1000';
		getAjaxCodeListSelectBox($("#sel_dept_cd"),$param,'','전체');
		
		// 회사코드 변경시
		$("#sel_cmpny_cd").selectBox().change(function(){cmpnyChangeEvent();});
		
		// submit 했을경우 validation 검사 수행
		$("#contentFormMber").validate({
			rules : {
				empl_cd : "required"
			}
		});
		
		// 검색
		$( "#btn_mber_search" )
			.button({ icons:{ primary : "ui-icon-disk" } ,text: true })
			.click(btnSearchEvent);
		
		// 저장
		$( "#btn_mber_submit" )
			.button({ icons:{ primary : "ui-icon-disk" } ,text: true })
			.click(btnSubmitEvent);
    	
    	// 회원정보 그리드 초기 셋팅
		$("#mber_list").jqGrid({
		  	url:'/selectGroupWrMberList.do',
			datatype: "json",
			jsonReader : { 
				page: "page", 
				total: "total", 
				root: "rows", 
				records: function(obj){	return obj.length;},
				repeatitems: false, 
				id: "userid"
			},
		  	colNames:['회원ID', '로그인ID', '이름', '직책코드', '직책', '부서코드', '부서', 'mber_id','재경부서코드','dept_code'],
		  	colModel:[
		  		{name:'userid'	,index:'userid'     ,width:120  ,align:"center" ,sorttype:"string"},
		  		{name:'loginid'	,index:'loginid'	,width:100	,align:"left"  	,sorttype:"string"},
		  		{name:'nname'	,index:'nname'	 	,width:100  ,align:"left"  	,sorttype:"string"},
		  		{name:'upid'	,index:'upid'	 	,width:50  	,align:"center"	,sorttype:"string", hidden:true},
		  		{name:'upname'	,index:'upname'	 	,width:80  	,align:"left"  	,sorttype:"string"},
		  		{name:'dpid'	,index:'dpid'	 	,width:50  	,align:"center" ,sorttype:"string", hidden:true},
		  		{name:'dpname'	,index:'dpname'	 	,width:100  ,align:"left"  	,sorttype:"string"},
		  		{name:'mber_id'	,index:'mber_id'	,width:50  	,align:"center" ,sorttype:"string", hidden:true},
		  		{name:'ims_dept',index:'ims_dept'	,width:100  ,align:"left"  	,sorttype:"string"},
		  		{name:'ims_dept_code',index:'ims_dept_code'	,width:50  	,align:"center" ,sorttype:"string", hidden:true}
		  	],
		  	rowNum:10000,
		  	pager: '#mber_nav',
		  	sortname: 'nname',
		    sortorder: "asc",
		    cmTemplate: {sortable: true},
		    viewrecords: true,
		    caption:"그룹웨어 회원정보",
		    imgpath:"themes/redmond/images",
		    shrinkToFit:false,
		    altRows: false,
		    autowidth:true,
		    height:'500',
		    gridComplete : jqMberComplete,
		    loadError : jqLoadErr,
		    onSelectRow: jqSelMberRow,
		    afterInsertRow : function(rowid, rowdata, rowelem) {
				if (rowdata.mber_id == 0) {
		    		$("#" + rowid).css("background",'#FAE0D4');
				}
			},
		    rownumbers: true,
		    rownumWidth:20
		});
    	
		// grid 자동 높이 조절
		fn_grid_height($("#mber_list"));
		
		// 그리드 네비게이션 셋팅(추가, 수정 삭제 버튼 기능 포함)
		$("#mber_list").jqGrid('navGrid'
							    ,'#mber_nav'
							    ,{
									edit:false
									,add:false
									,del:false
									,search:false
									,refresh:true
									,beforeRefresh : function(){
										var $obj = $("#mber_search_text");
										$obj.empty();
										$obj.removeClass();
							    	}
								}
								,''
								,''
								,'');
		
		$("#mber_list").jqGrid('bindKeys');
    });

    // 로딩 에러시 이벤트
	jqLoadErr = function(xhr,st,err){
		alert("로딩 에러");
	};
	// 로딩 완료시 이벤트
	jqMberComplete = function(id){
		$("#empl_cd").addClass("ui-state-error");
	};
    
    // 그리드 회원정보 row 선택시 이벤트
	jqSelMberRow = function(id){
		var rowData = $('#mber_list').getRowData(id);
		var $frm = $("#contentFormMber");
    	var frm = document.contentFormMber;
    	
    	frm.p_mber_id.value = rowData.mber_id;
    	frm.userid.value = rowData.userid;
    	frm.mber_nm.value = rowData.nname;
    	frm.login_id.value = rowData.loginid;
    	
    	$("#mber_nm").attr("readonly","readonly");
    	$("#login_id").attr("readonly","readonly");
    	
    	var getUrl = "/selectImsMberInfo.do";
		$.ajax({
			type:'post',
			url	:getUrl,
			data:$frm.serialize(),
			dataType: 'json',
			success: imsMberInfo,
			error:function(msg){
				alert("에러...");
				fn_unLoading();
			}
		});
    	
    	$("label.error").hide();
	};
	imsMberInfo =  function(data){
		var frm = document.contentFormMber;
		var info = data.imsMberInfo.split("|");
		
		$cmpnyCd = info[0];
		$deptCd = info[1];
		$emplCd = info[2];
		$superYn = info[3];
		$teamYn = info[4];
		$authCd = info[5];
		
		if(info[0] == null){
			$("#sel_cmpny_cd").selectBox("value",$cmpnyCd);
			
			var rowData = $('#mber_list').getRowData(data);
			var $cmpny_cd = $cmpnyCd;
			var $dept_cd = $('#sel_dept_cd');
			var $param = new Object();
			$param.group_cd  = 'ED_DEPT_CODE_1000';
			getAjaxCodeListSelectBox($("#sel_dept_cd"),$param,'','전체');
			
			$('#sel_dept_cd').selectBox('value',$deptCd);
	    	frm.empl_cd.value = $emplCd;
	    	
	    	$("#sel_super_yn").selectBox("value",$superYn);
	    	$("#sel_team_yn").selectBox("value",$teamYn);
	    	$("#sel_auth_yn").selectBox("value",$authCd);
		} else{
			$("#sel_cmpny_cd").selectBox("value",$cmpnyCd);
		
			var rowData = $('#mber_list').getRowData(data);
			var $cmpny_cd = $cmpnyCd;
			var $dept_cd = $('#sel_dept_cd');
			var $param = new Object();
			$param.group_cd  = 'ED_DEPT_CODE_'+info[0];
			getAjaxCodeListSelectBox($("#sel_dept_cd"),$param,info[1],'',"선택");
			
			$('#sel_dept_cd').selectBox('value',$deptCd);
	    	frm.empl_cd.value = $emplCd;
	    	
	    	$("#sel_super_yn").selectBox("value",$superYn);
	    	$("#sel_team_yn").selectBox("value",$teamYn);
	    	$("#sel_auth_yn").selectBox("value",$authCd);
		}
	};
	
	/************************ 조회 **************************/
	btnSearchEvent = function(){
		
		var $frm = $("#searchFormMber");
		var frm = document.searchFormMber;
		var getUrl = "/selectGroupWrMberList.do";
		var checkFlag = true;
		
		frm.search_login_id2.value = frm.search_login_id.value;
		frm.search_mber_nm2.value = frm.search_mber_nm.value;

		if(!checkFlag) return false;
		
		$('#mber_list').setGridParam({
			url:getUrl,
			postData:$frm.serialize()
		}).trigger('reloadGrid');
		
		return false;	
	};
	
	
	
	/************************ 저장 **************************/
	btnSubmitEvent = function(){
		
		if(!$("#contentFormMber").valid()) return false;
		
		var $frm = $("#contentFormMber");
		var frm = document.contentFormMber;
		
		frm.cmpny_cd.value = $("#sel_cmpny_cd").selectBox("value");
		frm.dept_code.value = $("#sel_dept_cd").selectBox("value");
		frm.super_yn.value = $("#sel_super_yn").selectBox("value");
		frm.team_yn.value = $("#sel_team_yn").selectBox("value");
		frm.auth_code.value = $("#sel_auth_yn").selectBox("value");
		frm.empl_cd.value = frm.empl_cd.value;
		
		if(!confirm("정말 저장하시겠습니까?")) return false;

		var getUrl = "/ims/mst/mber/mergeImsGroupWrMber.do";
		//fn_loadingView("Loading...");
		$.ajax({
			type:'post',
			url	:getUrl,
			data:$frm.serialize(),
			dataType: 'json',
			success: insertMberRequest,
			error:function(msg){
				alert("에러...");
				fn_unLoading();
			}
		});

		return false;
	};
	// 등록 완료
	insertMberRequest = function(msg){
		fn_unLoading();
		if(msg.status =="SUCCESS"){
			if(msg.checkGW > 0 && msg.checkIMS > 0){
				alert("정상적으로 처리되었습니다.");
				// Grid Reload
				$("#mber_list").trigger('reloadGrid');
			}else{
				alert("오류발생.");
			}
		}else{
			alert(msg.message);
			return;
		}
	};
	
	// 회사코드  변경시
    cmpnyChangeEvent = function(){
		
		var $cmpny_cd = $("#sel_cmpny_cd");
		var $dept_cd = $("#sel_dept_cd");
		
    	var $param = new Object();
    	$param.cmpny_cd = $cmpny_cd.selectBox("value");
    	$param.group_cd  = 'ED_DEPT_CODE_'+$cmpny_cd.selectBox("value");

    	getAjaxCodeListSelectBox($dept_cd,$param,'',"선택");
    };
	
</script>

<style>
<!--
.contentTable {
	padding-right: 10px;
	border: 0;
}
.contentTable tr td{
	padding-right: 20px;
	padding-top: 10px;
}
.contentTable td label{
	font-weight: bold;
}
</style>

<!-- 컨텐츠 시작 -->
<body style="overflow:hidden; ">
	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(/common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
		<tr>
			<td width="60%" style="padding-left:5px; padding-top:5px; ">
				<!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
				<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" />회원 관리</span>
			</td>
			<td width="40%" align="right"><!-- n 개의 읽지않은 문서가 있습니다. --></td>
		</tr>
	</table>
	
	
	<div style="margin: 6.5px;">
		<div id="contents_box" style="width:45%;float:left;">
			<div style="width:100%;float:left;" >
				<div id="mber_search_text"></div>
				<table id="mber_list" class="scroll"></table>
				<div id="mber_nav"></div>
			</div>
		</div>
		<div style="width:2%;float:left;height: 200px;">
			<div class="tpad_10"></div>
		</div>
		<div id="searchFormMberTab" style="width:50%;float:left;border: solid white;    padding-bottom: 1em;">
		    <div style="padding: 0em 1.4em;" id="searchFormDiv" >
		    	<form name="searchFormMber" id="searchFormMber">
		    	<input type="hidden" id="search_login_id2" name="login_id">
		    	<input type="hidden" id="search_mber_nm2" name="mber_nm">
			    	<table class="contentTable" >
			    	<!--<colgroup>
			    		<col width="10%">
			    		<col width="20%">
			    		<col width="10%">
			    		<col width="20%">
			    		<col width="6%">
			    	</colgroup>-->
			    		<tr>
			    			<td>
			    				<label for="search_login_id">로그인 ID</label>
                                <span>
								    <input type="text" id="search_login_id" name="search_login_id" maxlength="32" style="text-align: left; width:125px;" />
						    	</span>
			    			</td>
			    			<td>
			    				<label for="search_mber_nm">이름</label>
                                <span>
								    <input type="text" id="search_mber_nm" name="search_mber_nm" maxlength="32" style="text-align: left; width:125px;" />
						    	</span>
			    			</td>
			    			<td  align="right" >
			    				<button id="btn_mber_search">조회</button>
			    			</td>
			    		</tr>
			    		<!-- <tr><td></td><td></td><td></td><td></td></tr>
			    		<tr>
			    			<td></td>
			    			<td></td>
			    			
			    		</tr> -->
			    	</table>
		    	</form>
		    </div>
	    </div>
		<div id="contentFormMberTab" style="width:50%;float:left;">
			<ul>
				<li><a href="#contentFormDiv">회원 정보</a></li>
			</ul>
		    <div id="contentFormDiv" >
		    	<form name="contentFormMber" id="contentFormMber">
		    		<input type="hidden" name="p_mber_id" id="p_mber_id" value="0">
		    		<input type="hidden" name="userid" id="userid"><!-- 그룹웨어 사용자테이블 PK -->
		    		<input type="hidden" name="cmpny_cd" id="cmpny_cd">
		    		<input type="hidden" name="dept_code" id="dept_code">
		    		<input type="hidden" name="super_yn" id="super_yn">
		    		<input type="hidden" name="team_yn" id="team_yn">
		    		<input type="hidden" name="auth_code" id="auth_code">
		    		
			    	<table class="contentTable" >
			    	<colgroup>
			    		<col width="13%">
			    		<col width="20%">
			    		<col width="18%">
			    		<col width="20%">
			    	</colgroup>
			    		<tr>
			    			<td>
			    				<label for="mber_nm">이름</label>
			    			</td>
			    			<td>
								<span>
								    <input type="text" id="mber_nm" name="mber_nm" maxlength="32" style="text-align: left; width:125px;" readonly />
						    	</span>
			    			</td>
			    			<td>
			    				<label for="login_id">로그인 ID</label>
			    			</td>
			    			<td>
			    				<span>
								    <input type="text" id="login_id" name="login_id" maxlength="32" style="text-align: left; width:125px;" readonly />
						    	</span>
			    			</td>	
			    		</tr>
			    		<tr>
			    			<td>		
							<label for="sel_cmpny_cd">회사코드</label>
				    		</td>
			    			<td>
								<select id="sel_cmpny_cd" class="ui_select"></select>
			    			</td>
			    			<td>
							<label for="sel_dept_cd">재경부서코드</label>
				    		</td>
			    			<td>
								<select id="sel_dept_cd" class="ui_select"></select>
			    			</td>
			    		</tr>
			    		<tr>
			    			<td>
			    				<label for="empl_cd">사원코드</label>
			    			</td>
			    			<td>
			    				<span>
								    <input type="text" id="empl_cd" name="empl_cd" maxlength="5" style="text-align: left; width:125px;"/>
						    	</span>
			    			</td>
			    			<td>
			    				<label for="sel_super_yn">유류대 지원 대상자</label>
			    			</td>
			    			<td>
			    				<select id="sel_super_yn" class="ui_select"></select>
			    			</td> 
			    		</tr>
			    		<tr>
			    			<td>
			    				<label for="sel_team_yn">팀장 여부</label>
			    			</td>
			    			<td>
			    				<select id="sel_team_yn" class="ui_select"></select>
			    			</td>
			    			<td>
			    				<label for="sel_team_yn">권한 여부</label>
			    			</td>
			    			<td>
			    				<select id="sel_auth_yn" class="ui_select"></select>
			    			</td>
			    		</tr>
			    		<tr><td></td><td></td><td></td><td></td></tr>
			    		<tr>
			    			<td></td>
			    			<td></td>
			    			<td colspan="2" align="right" >
			    				<button id="btn_mber_submit">저장</button>
			    			</td>
			    		</tr>
			    	</table>
		    	</form>
		    </div>
	    </div>
	</div>
</body>