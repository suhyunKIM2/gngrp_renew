<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="s"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<link rel="stylesheet" href="/common/css/style.css">
<link rel="stylesheet" type="text/css" href="/resources/css/admin.css">

<%@ include file="/resources/ims.jquery.jsp"%>
<style>
<!--
	.columnColor {background-color: #FFFFB3 !important;}
	table.ui-datepicker-calendar { display:none; }
-->
</style>
<script type="text/javascript">
$.jgrid.nav.addtext = "추가";
$.jgrid.nav.edittext = "수정";
$.jgrid.nav.deltext = "삭제";
$.jgrid.edit.addCaption = "추가";
$.jgrid.edit.editCaption = "수정";
$.jgrid.del.caption = "삭제";
$.jgrid.del.msg = "삭제 하시겠습니까?";

var $selIRow = 0;
var actionFlag = "";
var insFlag = "";
var lastsel2 ;
var g_work_seq;
var f_work_seq;
var save_type = "";
var b_acnt_nm = "";
var b_card_no = "";
var super_yn = "N";
var $setle = "";
var main_params = new Object();

    $(document).ready(function() {
    	
    	$("#contentFormSearchTab").tabs();
		$(".ui_select").selectBox();
		
		// text, password 속성 변경 
		$('#contentFormSearchTab input:text,#contentFormSearchTab input:password')
		  .button().addClass('text','widget-content','ui-corner-all');
		
		$(".error").hide();
		actionFlag = "insert";
        
        // form 이동 시 숫자 천단위 표시
        $(".contentTable").click(function(){
        });
        
		$("#contentFormSearchTab ul li a").click(function(){

			var s_href = $(this).attr("href");
			if(s_href == "#contentFormDiv"){
				$("#gbox_spendUploadList").hide();
				<c:if test="${empl_info.auth_code eq '02'}" >
					$("#i_cmpny_cd").selectBox("enable");
					$("#i_dept_cd").selectBox("enable");
				</c:if>
				<c:if test="${empl_info.multi_dept eq 'Y'}" >
					$("#i_dept_cd").selectBox("enable");
				</c:if>
				
				$("#de").datepicker(datepicker_month).attr("readonly", "readonly");
				fn_update_grid_setting();
			}else if(s_href == "#contentDuzonFormDiv" || s_href == "#contentSearchFormDiv"){
				$("#gbox_spendHeaderList").hide();
				fn_upload_grid_setting();
			}else if(s_href == "#contentFinFormDiv"){
				$("#gbox_spendUploadList").hide();
				fn_update_grid_setting();
			}
			
		}).each(function(){
			
		<c:if test="${empl_info.auth_code ne '02'}" >
			if("#contentDuzonFormDiv" == $(this).attr("href")){
				$(this).hide();	
			}
			if("#contentFinFormDiv" == $(this).attr("href")){
				$(this).hide();	
			}
		</c:if>
		<c:if test="${empl_info.team_yn ne 'Y' && empl_info.auth_code ne '02' }" >
			$("#bth_sch_excel").hide();	
		</c:if>
			
		});
		
		search_tab_init();
		insert_tab_init();
		upload_tab_init();
		fin_tab_init();
		
		var frm = document.contentForm;
		
		frm.de.value = "";
		//frm.empl_cd.value = "";
		//frm.empl_nm.value = "";
		frm.fileTxt.value = "";
		frm.fileNm.value = "";
		
		$("#i_dept_cd").selectBox("value","");
		
		fn_update_grid_setting();
    });
    
    // 숫자만 허용하도록 변경
    testRock = function(){
	};
    
    // mask 
    testRock2 = function(){
    	$(this).mask("9999-99-99").focus();
	};
	
    // mask 
    testRock3 = function(){
    	//$(this).mask("9999-99-99");
    	// $(this).val(fn_onlyNumber($(this)));
	};
	
	// 콤마 제거
    fnRemoveComma = function(str){
    	return parseInt(str.replace(/,/g,""));
    };
    
	isNumMask = function(){
    	$(this).mask("9,999");
	};
	
    var $loadCheck = true;
	// 회사코드 셀렉트 박스 변경시
    cmpnyChangeEvent = function(tabName){
		
		var $cmpny_cd = "";
		var $dept_cd = "";
		var $empl_cd = "";
		var $anct_cd = "";
		
		if(tabName == "searchForm"){
			$cmpny_cd = $("#sch_cmpny_cd");
			$dept_cd = $("#sch_dept_cd");
			$anct_cd = $("#sch_acnt_cd");
			$empl_cd = $("#searchForm input[name=empl_cd]").val();
			//$empl_cd = $("#sch_empl_cd");
		}else if(tabName == "insForm"){
			$cmpny_cd = $("#i_cmpny_cd");
			$dept_cd = $("#i_dept_cd");
			$empl_cd = $("#contentForm input[name=empl_cd]").val();
			//$empl_cd = $("#i_empl_cd");
		}else if(tabName == "uploadForm"){
			$cmpny_cd = $("#duzon_cmpny_cd");
			$dept_cd = $("#duzon_dept_cd");
			$empl_cd = $("#duzonForm input[name=empl_cd]").val();
			//$empl_cd = $("#duzon_empl_cd");
		}
		
		<c:if test="${empl_info.auth_code ne '02'}" >
			<c:if test="${empl_info.multi_dept eq 'Y'}" >
			$dept_cd.selectBox("enable");
			</c:if>
			<c:if test="${empl_info.multi_dept ne 'Y'}" >
			$dept_cd.selectBox("disable");
			</c:if>
		</c:if>
		
    	var $param = new Object();
    	$param.cmpny_cd = $cmpny_cd.selectBox("value");
    	$param.group_cd  = 'ED_DEPT_CODE_'+$cmpny_cd.selectBox("value");
    	<c:if test="${empl_info.multi_dept eq 'Y'}" >
    	$param.multi_dept = '${empl_info.multi_dept}';
    	$param.empl_cd = $empl_cd;
    	$param.auth_code = '${empl_info.auth_code}';
		</c:if>
    	
    	if(tabName == "searchForm"){
	    	getAjaxCodeListSelectBox($dept_cd,$param,'${empl_info.dept_cd}','전체');
    		getAjaxAcntListSelectBox($anct_cd,$param,'','전체');
    	}else{
	    	getAjaxCodeListSelectBox($dept_cd,$param,'${empl_info.dept_cd}',"선택");
    	}
    };

	fn_checkCellHidden = function(){
		// $('#spendHeaderList').setColProp('dept_nm',{hidden:true});
		// 이 함수 어디선가 모르게 타는것 같음... 확인필요.
		
		/* 하단 총 합계 변경 */
		spendHeaderComplete();
		
		if(save_type == 'excel'){
			$('#spendReset').show();
			$('#spendSearch').hide();
			$('#spendListIns').hide();
			$('#SpendHeaderDel').hide();
		}else {
			$('#spendReset').hide();
			$('#spendSearch').show();
			$('#spendListIns').show();
			$('#SpendHeaderDel').show();
		}
			
		return false;
		$("td[describedby=spendHeaderList_cb]").each(
			function(){
				//alert();
				$(this).css("display","none");
			}
		);
	};
	
	// round function
	fnRoundPrecision = function(val,precision){
		var p = Math.pow(10,precision);
		return Math.round(val*p) / p;
	}
	
	// 리스트 row 추가
	btnSpendListInsEvent = function(){
		fnCellEditClose($("#spendHeaderList"),18);
		
		var frm = document.contentForm;
		frm.cmpny_cd.value  = $("#i_cmpny_cd").selectBox("value");
		frm.dept_cd.value   = $("#i_dept_cd").selectBox("value");
		frm.excclc_mt.value = frm.de.value;
		
		if(frm.empl_cd.value == ""){
			alert("사원을 선택 해 주세요.");
			return false;
		}
		if(frm.dept_cd.value == ""){
			alert("부서를 선택 해 주세요.");
			return false;
		}
		if(frm.excclc_mt.value == ""){
			alert("정산 월을 입력 해 주세요.");
			return false;
		}
		
		$("#i_cmpny_cd").selectBox("disable");
		$("#i_dept_cd").selectBox("disable");
		$("#empl_nm").attr("readonly", "readonly");
		$("#de").datepicker("destroy");
		
		// 추가하기 이전(제일 마지막 row)
		var copyRowNum = $("#spendHeaderList tr:last .jqgrid-rownum").text();
		var copyRow = $("#spendHeaderList tr:last");
		
		addParams = new Object();
 		
 		addParams.excclc_mt = $("#de").val();
 		addParams.cmpny_cd = $("#i_cmpny_cd").val();
 		addParams.cmpny_nm = $("#i_cmpny_cd option[value="+$("#i_cmpny_cd").val()+"]").text();
 		addParams.empl_cd = $("#empl_cd").val();
 		addParams.empl_nm = $("#empl_nm").val();
 		addParams.dept_cd = $("#i_dept_cd").val();
 		addParams.dept_nm = $("#i_dept_cd option[value="+$("#i_dept_cd").val()+"]").text();
		addParams.vhcle_opratdstnc = frm.vhcle_opratdstnc.value;
		
		// 복사할 row가 있으면 값 셋팅
		if(copyRowNum != ""){
			addParams.acnt_cd = copyRow.find("td[aria-describedby=spendHeaderList_acnt_cd]").text();
			addParams.acnt_nm = copyRow.find("td[aria-describedby=spendHeaderList_acnt_nm]").text();
			addParams.sumry = copyRow.find("td[aria-describedby=spendHeaderList_sumry]").text();
			addParams.setle_mn_nm = copyRow.find("td[aria-describedby=spendHeaderList_setle_mn_nm]").text();
			addParams.setle_mn = copyRow.find("td[aria-describedby=spendHeaderList_setle_mn]").text();
			addParams.card_no = copyRow.find("td[aria-describedby=spendHeaderList_card_no]").text();
			addParams.super_yn = copyRow.find("td[aria-describedby=spendHeaderList_super_yn]").text();
		}else {
			addParams.setle_mn = "1";
		}
		
		addParams.addchk = "Y";
		
		fnSpendListAddRow(copyRowNum);
		return false;
		
	};
	// 리스트  1건 추가.
	fnSpendListAddRow = function(copyRowNum){
		var frm = document.contentForm;
		var totalRecord = $("#spendHeaderList").jqGrid("getGridParam","reloadGrid");
		//frm.cmpny_cd.value = totalRecord+1;
		//frm.seq.value
		var $guid =  $.guid++;
		
		var testData ={
				seq:$guid
				,excclc_mt:frm.de.value
				,cmpny_cd:$("#i_cmpny_cd").selectBox("value")
				,empl_cd:frm.empl_cd.value
				,empl_nm:frm.empl_nm.value
				,dept_cd:$("#i_dept_cd").selectBox("value")
				,dept_nm:$("#i_dept_cd").selectBox("label")
			};
		
		addParams.seq = $guid;
		$("#spendHeaderList").jqGrid('addRowData',addParams.seq,addParams);
		
		// focus 이동
		$selIRow = $("#spendHeaderList").jqGrid('getInd', $guid);
		//console.log($selIRow);
		//console.log($guid);
		// cell Edit으로 변경
		
		if(copyRowNum == ""){
		
			setTimeout("$('#spendHeaderList').editCell('"+$selIRow+"', 10, true);", 100);
		}else {
			
			setTimeout("$('#spendHeaderList').editCell('"+$selIRow+"', 11, true);", 100);
		}
		
		// cell focus
		//setTimeout("$('#"+$guid+"_acnt_nm').focus();", 300);
	};
	// 지출결의서 list row 선택 시
	jqSpendListSelRow = function(id){
		if(id && id!==lastsel2){
			jQuery('#rowed16').jqGrid('restoreRow',lastsel2);
			jQuery('#rowed16').jqGrid('editRow',id,true);
			lastsel2=id;
		}
		return false;
	};
	//카드번호 select Box setting
	sendListCard_NoList = function(){
		var $optionTxt = "";
		
		var rowId = $(this).parent().parent().attr("id");
		
		//$("#grid").getCell(id,"userID");
		/*
		var rowData = $("#spendHeaderList").getCell(rowId,"setle_mn"); 
        var temp= rowData['setle_mn'];
        
        
        alert(temp);
        */
        
		var rowId2 =$("#spendHeaderList").jqGrid('getGridParam','selrow');
		var $setle_mn = $("#spendHeaderList").jqGrid('getCell', rowId2, 'setle_mn');
		var $empl_cd = $("#spendHeaderList").jqGrid('getCell', rowId2, 'empl_cd');
		
		var param = new Object();
		
		param.setle_mn = $setle_mn;
		param.empl_cd = $empl_cd;
		
		var rowidx = 0;
		$.ajax({
			type:'post',
			url	:'/autoCompleteCardNoList.do',
			data:param,
			async:false,
			dataType: 'json',
			success:function(data){
				$.map(data.rows,function(item) {
					if(rowidx > 0) $optionTxt += ";";
					rowidx ++;
					
					$optionTxt += item.seq+":"+item.card_no;
                });
			}
		});
		
		if(rowidx == 0){
			$optionTxt += ":";
		}
		return $optionTxt ;
	};
	//결제수단 select Box setting
	sendListSetle_MnList = function(){
		var $optionTxt = "";
		var $frm = $("#contentForm");
		var rowidx = 0;
		$.ajax({
			type:'post',
			url	:'/sendListSetle_MnList.do',
			data:$frm.serialize(),
			async:false,
			dataType: 'json',
			success:function(data){
				$.map(data.rows,function(item) {
					if(rowidx > 0) $optionTxt += ";";
					rowidx ++;
					
					$optionTxt += item.setle_mn+":"+item.setle_mn_nm;
                });
			}
		});
		
		// 처음 클릭해서 selectbox 그릴 때 default 1(법인카드)로 셋팅
		var rowId = $("#spendHeaderList").jqGrid('getGridParam', 'selrow');
		$("#spendHeaderList").jqGrid('setCell', rowId, 'setle_mn', '1', '');
		
		return $optionTxt ;
	};
	// select Box Setting 
	sendListAcntCdList = function(){
		var $optionTxt = "";
		
		var param = {};
		param.cmpny_cd = $("#i_cmpny_cd").selectBox("value");
		
		var rowidx = 0;
		$.ajax({
			type:'post',
			url	:'/autoCompleteSpendList.do',
			data:param,
			async:false,
			dataType: 'json',
			success:function(data){
				$.map(data.rows,function(item) {
					if(rowidx > 0) $optionTxt += ";";
					rowidx ++;
					
					$optionTxt += item.acnt_cd+":"+item.acnt_nm;
                });
			}
		});
		
		return $optionTxt ;
	};
	
	// select Box Change Event 
	sendListAcntCdChangeEvent = function(e){
		//var rowId = $("#spendHeaderList").jqGrid('getGridParam', 'selrow');
		var rowId = $(this).parent().parent().attr("id");
		$("#spendHeaderList").jqGrid('setCell', rowId, 'acnt_cd', $(this).val(), '');
	};
	// 결제수단 변경
	sendListSetle_MnChangeEvent = function(e){
		var rowId = $(this).parent().parent().attr("id");
		
		$("#spendHeaderList").jqGrid('setCell', rowId, 'setle_mn', $(this).val(), '');
		
		if($(this).val() == 1 || $(this).val() == 2){
			autoCardNo(rowId);
		}else{
			$("#spendHeaderList").jqGrid('setCell', rowId, 'card_no', ' ', '');
		}
		
		// 결제수단 코드
		var $setle_mn = $(this).val();
		// 공급가액
		var $amt = $("#spendHeaderList").jqGrid('getCell',rowId,'amt');
		// 부가세
		var $vat = $("#spendHeaderList").jqGrid('getCell',rowId,'vat');
		// 합계
		var $sum = $("#spendHeaderList").jqGrid('getCell',rowId,'sum');
		
		// 회사코드
		var $cmpny_cd = $("#spendHeaderList").jqGrid('getCell',rowId,'cmpny_cd');
		// 계정코드
		var $acnt_cd = $("#spendHeaderList").jqGrid('getCell',rowId,'acnt_cd');
		var $setle_mn_nm = "";
		
		var flag = "N";
		
		// 공급가액,부가세,합계 설정...
		fn_vatSum_setting($cmpny_cd, $acnt_cd, $setle_mn, $setle_mn_nm, $amt, $vat, $sum, rowId, flag);
	};
	
	// 사원코드 자동완성(등록/수정)
    autocomplete_empl_cd = function(){
    	var $ac = $(".autoEmpl input");
    	var frm = document.contentForm;
    	
    	autocompete_empl_cd_ajax(frm,$("#i_cmpny_cd").selectBox("value"),$("#i_dept_cd").selectBox("value"),$ac);
    };
    
 	// 사원코드 자동완성(조회)
    autocomplete_empl_cd_search = function(){
    	var $ac = $("#sch_empl_nm");
    	var $frm = document.searchForm;
    	autocompete_empl_cd_ajax($frm,$("#sch_cmpny_cd").selectBox("value"),$("#sch_dept_cd").selectBox("value"),$ac);
 	};
 	
 	// 사원코드 자동완성(더존업로드)
    autocomplete_empl_cd_upload = function(){
    	var $ac = $("#duzon_empl_nm");
    	var $frm = document.duzonForm;
    	
    	autocompete_empl_cd_ajax($frm,$("#duzon_cmpny_cd").selectBox("value"),$("#duzon_dept_cd").selectBox("value"),$ac);
 	};
    
    autocompete_empl_cd_ajax = function($frm,$cmpny_cd,$dept_cd,$ac){
		var $obj = new Object();
    	
    	$obj.cmpny_cd = $cmpny_cd;
    	$obj.dept_cd = $dept_cd;
    	
    	$ac.autocomplete({
    		source:function(request,response){
    			$obj.srchPrd =request.term;
    			$.ajax({
    				type:'post',
    				url	:'/autoCompleteEmplCdList.do',
    				data:$obj,
    				dataType: 'json',
    				//async:false,
					success:function(data){
						response($.map(data.rows,function(item) {
                            return {
                                value : item.mber_nm,
                                key : item.empl_cd,
                                nm : item.mber_nm
                            };
                        }));
    				}
    			});
    		},
    		delay:500,
      		minLength:1,
      		autoFocus: true, 
    		select:function(event, ui){
    			// $searchForm[emplCd].val(ui.item.key);
    			$frm.empl_cd.value = ui.item.key;
    			$frm.empl_nm.value = ui.item.nm;
    		}
    	});
    };
	
	// 자동완성
    autocomplete_element = function(value, options){
		var $ac = $('<input type="text" class="element_focus" />');
    	$ac.val(value);
    	b_acnt_nm = value;
    	var $frm = $("#contentForm");
    	var frm = document.contentForm;
    	var srchFrm = document.searchForm;
    	frm.cmpny_cd.value = $("#i_cmpny_cd").selectBox("value");
    	srchFrm.acntNm.value = "";
    	$ac.autocomplete({
    		source:function(request,response){
				frm.srchPrd.value = request.term;
    			$.ajax({
    				type:'post',
    				url	:'/autoCompleteSpendList.do',
    				data:$frm.serialize(),
    				dataType: 'json',
    				//async:false,
					success:function(data){
						response($.map(data.rows,function(item) {
                            return {
                                value : item.acnt_nm + " , Code : " + item.acnt_cd,
                                key : item.acnt_cd,
                                nm : item.acnt_nm
                            };
                        }));
    				}
    			});
    		},
    		delay:500,
      		minLength:2,
      		autoFocus: true, 
    		select:function(event, ui){
    			//alert(event.keyCode);
    			var rowId = $("#spendHeaderList").jqGrid('getGridParam', 'selrow');
    			srchFrm.acntNm.value = ui.item.nm;
    			if(ui.item){
                    $("#spendHeaderList").jqGrid('setCell', rowId, 'acnt_nm', ui.item.nm, '');
                    $("#spendHeaderList").jqGrid('setCell', rowId, 'acnt_cd', ui.item.key, '');
                }
    		}
    	}).keydown(function(e){
    		var key = e.charCode || e.keyCode;
    		
    		if(e.shiftKey){
    			if(key == 13 || key == 9){
    				var firstRowNum =$("#spendHeaderList .jqgrow:first .jqgrid-rownum").text();
	    			var selRowNum =$("#spendHeaderList .selected-row .jqgrid-rownum").text();
	    			
	    			if ( firstRowNum != selRowNum ){
	    				var prevRowNum = $("#spendHeaderList .selected-row").prev().find(".jqgrid-rownum").text();
	    				setTimeout("$('#spendHeaderList').editCell('"+prevRowNum+"', 18, true);", 100);
	    			}
	    			
	    			return false;
    			}
    			//return false;
    		}else if(key == 13 || key == 9){
				setTimeout("$('#spendHeaderList').editCell('"+$selIRow+"', 11, true);", 100);
				return false;
			}
    		/*
    		if(key == 38 || key == 40){
    			alert($(this).html());
				//$(this).autocomplete.delay = 5000;
//			}else{
				//$(this).autocomplete.delay = 500;
			}*/
    	});
    	
    	var $span = $("<span />");
    	var $script = $("<script type='text\/javascript'>autocomplete_focus();<\/script>");
    	$span.append($script);
    	$span.append($ac);
    	
    	return $span;
    };
    
    // 자동완성 포커스 인.
    autocomplete_focus = function(){
    	setTimeout("$('.element_focus').focus();", 200);
    }
    // 자동완성 값 반환
    autocomplete_value = function(elem, op, value){
        var srchFrm = document.searchForm;
        // 자동완성으로 선택하지 않아서 값이 없을 경우 이전 값으로 셋팅
		if(srchFrm.acntNm.value == ""){
			srchFrm.acntNm.value = b_acnt_nm;
		}
        return srchFrm.acntNm.value;
    }; 
    
    autoCardNo = function(rowid){
    	var srchFrm = document.searchForm;
    	if(b_card_no == "" && ($("#spendHeaderList").jqGrid('getCell',rowid,'card_no') == "" || $("#spendHeaderList").jqGrid('getCell',rowid,'card_no') == " ")){
    		var $frm = $("#contentForm");
        	var frm = document.contentForm;
        	frm.setle_mn.value = $("#spendHeaderList").jqGrid('getCell',rowid,'setle_mn');
        	$.ajax({
    			type:'post',
    			url	:'/autoCompleteCardNo.do',
    			data:$frm.serialize(),
    			dataType: 'json',
    			//async:false,
    			success:function(data){
    				// srchFrm.cardNo.value = data.autoCardNo;
    				$("#spendHeaderList").jqGrid('setCell',rowid,'card_no',data.autoCardNo,'');
    			}
    		});
    	}
    };
 	// 자동완성
    autocomplete_element_card = function(value, options){
    	var $ac = $('<input type="text" class="element_focus" />');
    	$ac.val(value);
    	b_card_no = value;
    	var $frm = $("#contentForm");
    	var frm = document.contentForm;
    	var srchFrm = document.searchForm;
    	
    	var rowId = $("#spendHeaderList").jqGrid('getGridParam', 'selrow');
    	var setle_mn = $("#spendHeaderList").jqGrid('getCell',rowId,'setle_mn');
    	
    	
    	
    	frm.setle_mn.value = setle_mn;
    	// 법인카드, 법인체크카드만 카드번호 input 활성화
    	if(!(setle_mn == '1' || setle_mn == '2')){
    		return $('<label />');
    	}else {
    		srchFrm.cardNo.value = "";
        	$ac.autocomplete({
        		source:function(request,response){
    				frm.srchPrd.value = request.term;
        			$.ajax({
        				type:'post',
        				url	:'/autoCompleteCardNoList.do',
        				data:$frm.serialize(),
        				dataType: 'json',
        				//async:false,
    					success:function(data){
    						response($.map(data.rows,function(item) {
                                return {
                                    value : item.card_no + " , 사원명 : " + item.mber_nm,
                                    key : item.card_no,
                                    nm : item.card_no
                                };
                            }));
        				}
        			});
        		},
        		delay:500,
          		minLength:4,
          		autoFocus: true, 
        		select:function(event, ui){
        			var rowId = $("#spendHeaderList").jqGrid('getGridParam', 'selrow');
        			srchFrm.cardNo.value = ui.item.nm;
        			if(ui.item){
                        $("#spendHeaderList").jqGrid('setCell', rowId, 'card_no', ui.item.nm, '');
                    }
        		}
        	}).keydown(function(e){
        		var key = e.charCode || e.keyCode;
        		
        		if(e.shiftKey){
        			if(key == 13 || key == 9){
    	    			//setTimeout("$('#spendHeaderList').editCell('"+$selIRow+"', 16, true);", 300);
        			}
        			return false;
        		}else if(key == 13 || key == 9){
    				setTimeout("$('#spendHeaderList').editCell('"+$selIRow+"', 18, true);", 100);
    				return false;
    			}
        	});
        	
        	var $span = $("<span />");
        	var $script = $("<script type='text\/javascript'>autocomplete_focus();<\/script>");
        	$span.append($script);
        	$span.append($ac);
        	
        	return $span;
    	}
    };
    // 자동완성 값 반환
    autocomplete_value_card = function(elem, op, value){
        var srchFrm = document.searchForm;
        var returnValue = "";
        
        // 자동완성으로 선택하지 않아서 값이 없을 경우 이전 값으로 셋팅
		if(srchFrm.cardNo.value == ""){
			returnValue = b_card_no;
		}else{
			returnValue = srchFrm.cardNo.value;
		}
        
        b_card_no = "";
        srchFrm.cardNo.value = "";
        
        return returnValue;
    }; 
    
 	// cell edit 닫기
 	fnCellEditClose = function ($obj,cell){
 		var len = $obj.jqGrid("getGridParam","records");
		
 		for(var i = 0 ; i < len ; i++){
 			$obj.editCell(i, cell, false); //row,col,false
 		}
 	};
 	
 	// 공급가액,부가세,합계 설정... 
 	fn_vatSum_setting = function($cmpny_cd, $acnt_cd, $setle_mn, $setle_mn_nm, $amt, $vat, $sum, rowid, flag){
 		console.log("setting cmpny_cd:" + $cmpny_cd);
 		//1000 : 지앤푸드 
 		if($cmpny_cd == '1000'){
 			
 			if(flag == "Y"){
 			
 				if($acnt_cd != "" && $setle_mn_nm != "" && $sum != 0){
 		 			
 	 				//if (!(($acnt_cd == '83305' && $setle_mn == '1') || $setle_mn == '5')){
 	 				//	setle_mn :1 (법인카드) ,5(세금계산서) 아닌 항목은 부가세 0표시, 부가세는 공급가액에 합해짐
 	 				if (!($setle_mn == '1' || $setle_mn == '5')){
 	 					
 	 					var $sum = Number(parseFloat($amt)) + Number(parseFloat($vat)); 					

 	 					$vat = 0;
 	 					$amt = $sum;
 	 					
 	 					$("#spendHeaderList").jqGrid('setCell',rowid,'amt',$amt,'');
 	 					$("#spendHeaderList").jqGrid('setCell',rowid,'vat',$vat,'');
 	 				}else {
 	 					
 	 					//if($vat == 0 && $selIRow != 1 && !($acnt_cd == '83305' && $setle_mn == '1')){
 	 					if($vat == 0 && $selIRow != 1 && $setle_mn == '5'){
 	 						
 	 						alert("부가세를 입력 해 주세요.");
 	 						setTimeout("$('#spendHeaderList').editCell('"+$selIRow+"', 13, true);", 100);
 	 						return false;
 	 					}
 	 				}
 	 			}
 			} else {
 				
 				//if (!(($acnt_cd == '83305' && $setle_mn == '1') || $setle_mn == '5')){
 				if (!($setle_mn == '1' || $setle_mn == '5')){
	 					
 					var $sum = Number(parseFloat($amt)) + Number(parseFloat($vat));

 					$vat = 0;
 					$amt = $sum;
 					
 					$("#spendHeaderList").jqGrid('setCell',rowid,'amt',$amt,'');
 					$("#spendHeaderList").jqGrid('setCell',rowid,'vat',$vat,'');
 				}else {
 					
 					if($vat == 0 && $setle_mn == '5'){
 						
 						alert("부가세를 입력 해 주세요.");
						setTimeout("$('#spendHeaderList').editCell('"+$selIRow+"', 13, true);", 100);
						return false;
					}
 				}
 			}
		}else if($cmpny_cd == '3600' || $cmpny_cd == '3030' ){ //리틀스타, 샘마케팅 도 결제수단 법인카드,세금계산서의 경우 부가세입력가능  (2020-11-02일에 추가)
			 	//개인카드, 현금시 부가세 0
				if (!($setle_mn == '1' || $setle_mn == '5')){
 					
					var $sum = Number(parseFloat($amt)) + Number(parseFloat($vat));

					$vat = 0;
					$amt = $sum;
					
					$("#spendHeaderList").jqGrid('setCell',rowid,'amt',$amt,'');
					$("#spendHeaderList").jqGrid('setCell',rowid,'vat',$vat,'');
				}else {//법인카드,세금계산서
				
					if($vat == 0 && $setle_mn == '5'){
						
						alert("부가세를 입력 해 주세요.");
					setTimeout("$('#spendHeaderList').editCell('"+$selIRow+"', 13, true);", 100);
					return false;
				}
				}
		}else { //지앤푸드, 샘마케팅|리틀스타(빅밴드) 제외 회사
			
			if(flag == "Y"){
				
				if($acnt_cd != "" && $setle_mn_nm != "" && $sum != 0){ 
					
					// 법인카드, 세금계산서, 전자세금계산서 체크
					//if(!($setle_mn == '1' || $setle_mn == '5' || $setle_mn == '6' || $setle_mn == '') && $vat > 0){
		    			
						var $sum = Number(parseFloat($amt)) + Number(parseFloat($vat)); 
						
		    			// 부가세 0
		    			$vat = 0;
		    			$amt = $sum;
		    			
		    			$("#spendHeaderList").jqGrid('setCell',rowid,'amt',$amt,'');
		    			$("#spendHeaderList").jqGrid('setCell',rowid,'vat',$vat,'');
		    		//}
				}
			}else {
				
				var $sum = Number(parseFloat($amt)) + Number(parseFloat($vat)); 
			
				$vat = 0;
    			$amt = $sum;
    			
    			$("#spendHeaderList").jqGrid('setCell',rowid,'amt',$amt,'');
    			$("#spendHeaderList").jqGrid('setCell',rowid,'vat',$vat,'');
			}
			
		}
		// 수정된 공급가액 + 수정된 부가세 = 합계
		var $sum = Number(parseFloat($amt)) + Number(parseFloat($vat));
		// 합계 셋팅
		$("#spendHeaderList").jqGrid('setCell',rowid,'sum',$sum,'');
		
		/* 하단 총 합계 변경 */
		spendHeaderComplete();
 	}
</script>
<script type="text/javascript">

//사원코드 조회
getAjaxEmplListSelectBox = function($obj,$param,$cd,$firstOption){
	$.ajax({
			type:"POST",
			url : "/getAjaxEmplList.do",
			data:$param,
			dataType:"json",
			success:function(data){fnEmplListViewSelectBox(data,$obj,$cd,$firstOption);},
			error:function(msg){
				fn_unLoading();
				alert("전송실패!!");
				return;
			}
	});
};
//사원코드 값 세팅
fnEmplListViewSelectBox = function(data,$obj,$cd,$firstOption){
	var cdCheck = false;
	var optionObj = "";
	$obj.empty();
	if($firstOption){
		optionObj = '<option value="">' + $firstOption+'</option>';
	}
	
	$.each(data.rows,function(){
		optionObj += '<option value="'+ this.empl_cd + '">' + this.mber_nm+'</option>';
		
		if($cd == this.empl_cd) cdCheck = true;
	});
	
	$obj.selectBox("options",optionObj);
	
	if(cdCheck) $obj.selectBox("value",$cd);
};
</script>
<script type="text/javascript">
/*
 * 
 	Insert Tab Event
 */
// update grid setting
fn_update_grid_setting = function(){
	
	$("#gbox_spendHeaderList").show();
	
	if(save_type != 'excel'){
		
		//그리드 초기 셋팅
		$("#spendHeaderList").jqGrid({
		  	url:'/selectSpendSearchList.do',
			datatype: "json",
			jsonReader : { 
				page: "page", 
				total: "total", 
				root: "rows", 
				records: function(obj){	return obj.length;},
				repeatitems: false, 
				id: "grid_key",
				cell: 'cell'
			},
		  	colNames:[
		  	          '정산 월','회사 코드','회사 명','부서 코드','부서 명', '사원 코드','사원 명','계정코드', '계정 명', '발생 일자', '공급가액', '부가세',
		  	          '합계', '결제 수단','결제 수단 코드', '카드 번호', '적요', '상점명', '등록자ID', '등록일시','계정일치여부','합계일치','카드번호일치','업로드체크', '카드사',
		  	          '순서','추가여부', '슈퍼바이저여부', '차량운행거리', '키', '승인번호'],
		  	colModel:[
		  		{name:'excclc_mt'	,index:'excclc_mt'			,width:100	,align:"center" ,sorttype:"string"  ,hidden:true},
		  		{name:'cmpny_cd'	,index:'cmpny_cd'			,width:100	,align:"left" ,sorttype:"string"    ,hidden:true},
		  		{name:'cmpny_nm'	,index:'cmpny_nm'			,width:100	,align:"center" ,sorttype:"string"  ,hidden:true},
		  		{name:'dept_cd'		,index:'dept_cd'			,width:100	,align:"left" ,sorttype:"string"        ,hidden:true},
		  		{name:'dept_nm'		,index:'dept_nm'			,width:100	,align:"center" ,sorttype:"string"      },
		  		{name:'empl_cd'		,index:'empl_cd'			,width:100	,align:"left" ,sorttype:"string"        ,hidden:true},
		  		{name:'empl_nm'		,index:'empl_nm'			,width:80	,align:"center" ,sorttype:"string"      ,hidden:false},
				{name:'acnt_cd'		,index:'acnt_cd'			,width:100	,align:"center" ,sorttype:"string",editable:false },
		  		{name:'acnt_nm'		,index:'acnt_nm'			,width:130	,align:"center" ,sorttype:"string",editable:true,edittype:'custom', 
						//editoptions:{value:sendListAcntCdList,dataEvents:[{type:"change",fn:sendListAcntCdChangeEvent}]}, 
						editoptions:{custom_element:autocomplete_element, custom_value:autocomplete_value
							,dataInit:function(el){ alert($(el)); }	
						}, 
						editrules: {edithidden: true}},
		  		{name:'occrrnc_de'		,index:'occrrnc_de'			,width:100	,align:"center" ,sorttype:"string",editable:true
				  	 ,editoptions:  {dataInit: function (elem) {
				  						var today = new Date();
			                            //$(elem).mask(today.getFullYear()+"-99-99");
				  						$(elem).mask("9999-99-99");
			                        },
				  		 			dataEvents:[{type:'keydown', fn:function(e){
								  					var key = e.charCode || e.keyCode;
								  					if(e.shiftKey){
			 					  		    			return false;
			 					  		    		}else if(key == 13 || key == 9){
						 		  						setTimeout("$('#spendHeaderList').editCell('"+$selIRow+"', 12, true);", 100);
								  						return false;
								  					}
								  				}}
				  		 		           ]
		 						  	}
		  		},
		  		{name:'amt'		,index:'amt'			,width:80	,align:"right" ,sorttype:"number",editable:true, formatter:"number", summaryType: 'sum'
		  			,editoptions:  {dataInit:tabKeyNumInit, 
		  							dataEvents:[{type:'keydown', fn:function(e){
			 					  					var key = e.charCode || e.keyCode;
			 					  					if(e.shiftKey){
			 					  		    			return false;
			 					  		    		}else if(key == 13 || key == 9){
			 			 		  						setTimeout("$('#spendHeaderList').editCell('"+$selIRow+"', 13, true);", 100);
			 					  						return false;
			 					  					}
			 					  				}}
 					  				]}
		  		},
		  		{name:'vat'		,index:'vat'			,width:80	,align:"right" ,sorttype:"number",editable:true, formatter:"number", summaryType: 'sum'
		  			,editoptions:  {dataInit:tabKeyNumInit, 
							dataEvents:[{type:'keydown', fn:function(e){
	 					  					var key = e.charCode || e.keyCode;
	 					  					if(e.shiftKey){
	 					  		    			return false;
	 					  		    		}else if(key == 13 || key == 9){
	 			 		  						setTimeout("$('#spendHeaderList').editCell('"+$selIRow+"', 15, true);", 100);
	 					  						return false;
	 					  					}
	 					  				}}
			  				]}
		  		},
		  		{name:'sum'		,index:'sum'			,width:80	,align:"right" ,sorttype:"number",editable:false, formatter:"number", summaryType: 'sum'
		  			,editoptions:{dataEvents:[{type:"keydown",fn:fn_onlyNumber},{type:"focus",fn:fn_onlyNumberStyle}]}
		  		},
		  		{name:'setle_mn_nm'		,index:'setle_mn_nm'			,width:100	,align:"center" ,sorttype:"string",editable:true,edittype:'select', 
		  			 editoptions:{
						 	value:sendListSetle_MnList
						 	,dataEvents:[{type:"change",fn:sendListSetle_MnChangeEvent},
						 	            {type:'keydown', fn:function(e){
	 					  					var key = e.charCode || e.keyCode;
	 					  					if(e.shiftKey){
	 					  		    			return false;
	 					  		    		}else if(key == 13 || key == 9){
	 			 		  						setTimeout("$('#spendHeaderList').editCell('"+$selIRow+"', 17, true);", 100);
	 					  						return false;
	 					  					}
	 					  				}}]
		  			}, editrules: {edithidden: true}},
		  		{name:'setle_mn'		,index:'setle_mn',width:30 ,hidden:true},
		  		{name:'card_no'		,index:'card_no'			,width:150	,align:"center" ,sorttype:"string"
		  				 ,editable:true, editrules: {edithidden: true}, edittype:'custom', 
		  				 //editoptions:{value:sendListCard_NoList}
		  				editoptions:{custom_element:autocomplete_element_card, custom_value:autocomplete_value_card} 
		  			 },
	  			{name:'sumry'		,index:'sumry'			,width:200	,align:"center" ,sorttype:"string",editable:true,
			  			editoptions:{
			  				dataInit:tabKeyInit,
			  				dataEvents:[{type:'keydown', fn:function(e){
			  					var key = e.charCode || e.keyCode;
			  					if(e.shiftKey){
			  		    			//return false;
			  		    		}else if(key == 13 || key == 9){
			  		    			
			  		    			var lastRowNum =$("#spendHeaderList .jqgrow:last .jqgrid-rownum").text();
			  		    			var selRowNum =$("#spendHeaderList .selected-row .jqgrid-rownum").text();
			  		    			
			  		    			if ( lastRowNum == selRowNum ){
			  		    				btnSpendListInsEvent();
			  		    			}else{
			  		    				var nextRowNum = $("#spendHeaderList .selected-row").next().find(".jqgrid-rownum").text();
			  		    				setTimeout("$('#spendHeaderList').editCell('"+nextRowNum+"', 10, true);", 100);
			  		    			}
			  						return false;
			  					}
			  				}}]}},
			  	{name:'cust_nm'		,index:'cust_nm'		,width:200	,align:"left"	,sorttype:"string", editable:true},			
		  		{name:'reg_id'		,index:'reg_id'			,width:100	,align:"center" ,sorttype:"string" ,hidden:true},
		  		{name:'reg_dt'		,index:'reg_dt'			,width:100	,align:"center" ,sorttype:"string" ,hidden:true},
		  		{name:'con_yn'		,index:'con_yn'			,width:100	,align:"left" ,sorttype:"string" ,hidden:true},
		  		{name:'sum_yn'		,index:'sum_yn'			,width:100	,align:"left" ,sorttype:"number" ,hidden:true},
		  		{name:'card_yn'		,index:'card_yn'		,width:100	,align:"left" ,sorttype:"string" ,hidden:true},
		  		{name:'upload_chk'	,index:'upload_chk'		,width:200	,align:"left" ,sorttype:"string"},
		  		{name:'card_se'		,index:'card_se'		,width:60	,align:"left" ,sorttype:"string"},
		  		{name:'seq'			,index:'seq'			,hidden:true },
		  		{name:'addchk'		,index:'addchk'			,hidden:true },
		  		{name:'super_yn'	,index:'super_yn'		,hidden:true },
		  		{name:'vhcle_opratdstnc'	,index:'vhcle_opratdstnc'		,hidden:true },
		  		{name:'grid_key'	,index:'grid_key'		,hidden:true },
		  		{name:'approval_no'	,index:'approval_no'		,hidden:true }
		  	],
		  	rowNum:10000,
		  	pager: '#spendHeaderNav',
		  	//sortname: 'seq',
		    //sortorder: "asc",
		    cmTemplate: {sortable: false},
		    viewrecords: true,
		    caption:"개인경비list",
		    imgpath:"themes/${userVO.grid_style}/images",
		    shrinkToFit:false,
		    altRows: false,
		    autowidth:true,
		    height:'400',
		    cellEdit: true,
		    cellsubmit: 'clientArray',
		    gridComplete : spendHeaderComplete,
		    loadError : jqLoadErr,
		    rownumbers: true,
		    onSelectRow: function(id){
				if(id && id!==lastsel2){
					jQuery('#rowed16').jqGrid('restoreRow',lastsel2);
					jQuery('#rowed16').jqGrid('editRow',id,true);
					lastsel2=id;
				}
		    },
		    hiddengrid:false,
		    rownumWidth:20,
		    beforeSelectRow : function(rowid, e){
		    	// 승인번호
		    	var $approvalNo = $("#spendHeaderList").jqGrid('getCell',rowid,'approval_no');
		    	var $cardNo = $("#spendHeaderList").jqGrid('getCell',rowid,'card_no').right(4);
		    	
		    	// 승인번호가 있으면 edit 셀 막아놓기
		    	if($approvalNo != ''){
		    		
		    		// 발생일자
		    		$("#spendHeaderList").jqGrid('setCell',rowid,'occrrnc_de','','not-editable-cell');
		    		// 결제수단
		    		$("#spendHeaderList").jqGrid('setCell',rowid,'setle_mn_nm','','not-editable-cell');
		    		// 카드번호
		    		$("#spendHeaderList").jqGrid('setCell',rowid,'card_no','','not-editable-cell');
		    		// 상점명
		    		$("#spendHeaderList").jqGrid('setCell',rowid,'cust_nm','','not-editable-cell');
		    	}
		 
				return true; // false를 리턴하면 로우 셀렉트가 안 되니까.. 주의!
		    },
		    beforeEditCell : function(rowid, cellname, value, iRow, iCol){
		    	selICol = iCol;
			    $selIRow = iRow;
		    	// edit할수있는 cell 선택 시 해당 row 자동 체크
			    $("#" + rowid).find('input[type=checkbox]').attr('checked', true);
		    	
		    	// 결제수단 처음 법인카드 선택했을 때 카드번호 셋팅
		    	if(cellname == "setle_mn_nm" ){
		    		
			    	var setle = $("#spendHeaderList").jqGrid('getCell',rowid,'setle_mn');
		    		if(setle == "1" || setle == "2"){
			    		autoCardNo(rowid);
		    		}
		    		
		    		// 공급가액
		    		var $amt = $("#spendHeaderList").jqGrid('getCell',rowid,'amt');
		    		// 부가세
		    		var $vat = $("#spendHeaderList").jqGrid('getCell',rowid,'vat');
		    		// 합계
		    		var $sum = $("#spendHeaderList").jqGrid('getCell',rowid,'sum');
		    		// 결제 수단 코드
		    		var $setle_mn = $("#spendHeaderList").jqGrid('getCell',rowid,'setle_mn');
		    		
		    		// 회사코드
		    		var $cmpny_cd = $("#spendHeaderList").jqGrid('getCell',rowid,'cmpny_cd');
		    		// 계정코드
		    		var $acnt_cd = $("#spendHeaderList").jqGrid('getCell',rowid,'acnt_cd');
		    		// 결제수단
		    		var $setle_mn_nm = $("#spendHeaderList").jqGrid('getCell',rowid,'setle_mn_nm');
		    		
		    		var flag = "N";
		    		
		    		// 공급가액,부가세,합계 설정...
		    		fn_vatSum_setting($cmpny_cd, $acnt_cd, $setle_mn, $setle_mn_nm, $amt, $vat, $sum, rowid, flag);
		    	}
			},
			afterEditCell : function(rowid, cellname, value, iRow, iCol){
				/*
				if(cellname == "acnt_nm"){
					//alert($("#"+rowid+"_"+cellname).parent().html());
					$("#"+rowid+"_"+cellname).focus();
				}*/
				if(cellname == 'setle_mn_nm'){
		    		//alert(1);
		    		//$("#lossMngList").jqGrid('setCell',rowid,'loss_resn_cd',value,'');
		    		//var $aa = $("#spendHeaderList").jqGrid('getCell',rowid,'setle_mn_nm');
		    		//alert($aa);
			    	//alert($('#'+rowid+'_'+cellname).val());
		    		//alert($('#7_setle_mn_nm').val());
		    	}
			},
		    afterSaveCell:function (rowid, cellname, value, iRow, iCol){
		    	// 공급가액
	    		var $amt = $("#spendHeaderList").jqGrid('getCell',rowid,'amt');
	    		// 부가세
	    		var $vat = $("#spendHeaderList").jqGrid('getCell',rowid,'vat');
	    		// 합계
	    		var $sum = $("#spendHeaderList").jqGrid('getCell',rowid,'sum');
	    		// 결제 수단 코드
	    		var $setle_mn = $("#spendHeaderList").jqGrid('getCell',rowid,'setle_mn');
	    		
	    		// 회사코드
	    		var $cmpny_cd = $("#spendHeaderList").jqGrid('getCell',rowid,'cmpny_cd');
	    		// 계정코드
	    		var $acnt_cd = $("#spendHeaderList").jqGrid('getCell',rowid,'acnt_cd');
	    		// 결제수단
	    		var $setle_mn_nm = $("#spendHeaderList").jqGrid('getCell',rowid,'setle_mn_nm');
	    		
	    		var flag = "Y";
	    		
	    		// 공급가액,부가세,합계 설정...
	    		fn_vatSum_setting($cmpny_cd, $acnt_cd, $setle_mn, $setle_mn_nm, $amt, $vat, $sum, rowid, flag);
	    		
		    	if(cellname == 'setle_mn_nm'){
		    		$setle = $("#spendHeaderList").jqGrid('getCell',rowid,'setle_mn');
		    	}
		    },
		    afterInsertRow : 	function(rowid, rowdata, rowelem) {
			}
		    ,multiselect: true
		    ,multikey: "seq"
		    ,footerrow: true
		});
	}
	
	// Key 로 움직일 수 있도록 key binding
	$("#spendHeaderList").jqGrid('bindKeys');
	
	fn_grid_height($("#spendHeaderList"));
};

//tab 키 init 
tabKeyInit = function(elem){
	$(elem).focus(function(){
		this.select();
	});
};
tabKeyNumInit = function(elem){
	$(elem).focus(function(){
		this.select();
	});
	$(elem).numeric();
};

insert_tab_init = function(){
	
	// 엑셀 업로드
	$( "#spendExl" )
		.button({ icons:{ primary : "ui-icon-folder-collapsed" } ,text: true })
		.click(btnSpendExlEvent);
	// 리스트추가
	$( "#spendListIns" )
		.button({ icons:{ primary : "ui-icon-plus" } ,text: true })
		.click(btnSpendListInsEvent);
	// 초기화
	$( "#spendReset" )
		.button({ icons:{ primary : "ui-icon-plus" } ,text: true })
		.click(btnSpendResetEvent);
	// 조회
	$( "#spendSearch" )
		.button({ icons:{ primary : "ui-icon-search" } ,text: true })
		.click(btnSpendSearchEvent);
	// 저장
	$( "#spendHeaderSub" )
		.button({ icons:{ primary : "ui-icon-disk" } ,text: true })
		.click(btnSpendListSaveEvent);
	// 전표삭제
	$( "#SpendHeaderDel" )
		.button({ icons:{ primary : "ui-icon-minus" } ,text: true })
		.click(btnSpendHeaderDelEvent);

	$("#fileInput").change(function(){$("#fileTxt").val($(this).val());});
	
 	// 날짜 형식 셋팅(월달력)
	$("#de").datepicker(datepicker_month).attr("readonly", "readonly");
 	
 	// 날짜 버튼 셋팅
	$( "#btn_spendDe_search" )
		.button({ icons:{ primary : "ui-icon-calendar" } ,text: false })
		.click(function(){$("#de").focus(); return false;});

 	// 회사코드 변경시 이벤트 바인딩.
	$("#i_cmpny_cd").selectBox().change(function(){cmpnyChangeEvent("insForm");})
	<c:if test="${empl_info.auth_code ne '02'}" >
		.selectBox("disable")
	</c:if>
	;
 	
	// 회사코드 셋팅
	var $param = new Object();
	$param.group_cd = 'ED_CMPNY_CODE';
	getAjaxCodeListSelectBox($("#i_cmpny_cd"),$param,'${empl_info.cmpny_cd}',null,"cmpnyChangeEvent('insForm');");
};
// 개인경비 등록/수정 complete
spendHeaderComplete = function(ids){
	p_amt	= $("#spendHeaderList").jqGrid('getCol', 'amt', false, 'sum');
	p_vat 	= $("#spendHeaderList").jqGrid('getCol', 'vat', false, 'sum');
	p_sum 	= $("#spendHeaderList").jqGrid('getCol', 'sum', false, 'sum');
	
	$("#spendHeaderList").jqGrid('footerData','set', {dept_nm: '총 합계'
									 , amt	: p_amt 	 
									 , vat	: p_vat      
									 , sum	: p_sum 
									 });
};
//로딩 에러
jqLoadErr = function(xhr,st,err){
	/*
	alert('HTTP status code: ' + xhr.status + '\n' +
            'textStatus: ' + st + '\n' +
            'errorThrown: ' + err);
    alert('HTTP message body (jqXHR.responseText): ' + '\n' + xhr.responseText);
	*/
	alert("로딩 에러");
};

//엑셀 업로드
btnSpendExlEvent = function(){
	var frm = document.contentForm;
	
	frm.cmpny_cd.value = $("#i_cmpny_cd").selectBox("value");
	frm.dept_cd.value = $("#i_dept_cd").selectBox("value");

	if($("#de").val() == "" ){
		alert("정산월을 선택 해 주세요!!!");
		$("#de").focus();
		return false;
	}
	if($("#i_dept_cd").selectBox("value") == "" ){
		alert("부서를 선택 해 주세요!!!");
		$("#i_dept_cd").focus();
		return false;
	}
	if($("#empl_cd").val() == "" ){
		alert("사원을 선택 해 주세요!!!");
		$("#empl_nm").focus();
		return false;
	}
	
	if(frm.fileNm.value == ""){
		alert("엑셀 파일을 선택 해 주세요!!!");
		return false;
	}
	
	if(!confirm("실행 하시겠습니까?")) return;
	
	fn_loadingView("업로드 중입니다. <br>잠시만 기다려 주세요.");
	
	frm.action = "/ims/inv/spend/spendExcelUpload.do";
	frm.method = "post";
	frm.encoding = 'multipart/form-data';
	frm.target = 'hiddenFrame';
	frm.submit(); 
	return false;
};
//
fnExcelUploadAfter = function($work_seq){
	var frm = document.contentForm;
	var params = new Object();
	params.work_seq = $work_seq;
	params.cmpny_cd = $("#i_cmpny_cd").selectBox("value");
	params.dept_cd = $("#i_dept_cd").selectBox("value");
	params.empl_cd = frm.empl_cd.value;
	g_work_seq = $work_seq;
	
	$('#spendHeaderList').setGridParam({
		url:'/selectSpendHeaderUploadList.do',
		postData:params,
		cellEdit: false,
		gridComplete : fn_checkCellHidden,
		afterInsertRow : function(rowid, rowdata, rowelem) {
			if (rowdata.con_yn == 'N' || rowdata.sum_yn == 'N' || rowdata.card_yn == 'N') {
	    		$("#" + rowid).css("background",'#FAE0D4');
			}
			// (지엔푸드)법인카드이면서 시식차량, 계정에 상관없이 세금계산서 가 아닐 경우 부가세를 0으로 셋팅하고 공급가액을 합계로 셋팅해준다. 
			if(rowdata.cmpny_cd == '1000'){
			
				//if (!((rowdata.acnt_cd == '83305' && rowdata.setle_mn == '1') || rowdata.setle_mn == '5')){
				if (!(rowdata.setle_mn == '1' || rowdata.setle_mn == '5')){	
					
					$("#spendHeaderList").jqGrid('setCell',rowid,'amt',rowdata.sum,'');
					$("#spendHeaderList").jqGrid('setCell',rowid,'vat',0,'');
				}
			}
		}
	}).trigger('reloadGrid');
};
// 엑셀업로드 후 초기화
btnSpendResetEvent = function(){
	var $frm = $("#contentForm");
	var frm = document.contentForm;
	
	frm.de.value = "";
	frm.excclc_mt.value = "";
	frm.fileTxt.value = "";
	frm.fileNm.value = "";
	
	var $param = new Object();
	$param.cmpny_cd = $("#i_cmpny_cd").selectBox("value");
	$param.group_cd  = 'ED_DEPT_CODE_'+$("#i_cmpny_cd").selectBox("value");
	
	<c:if test="${empl_info.multi_dept eq 'Y'}" >
	$param.multi_dept = '${empl_info.multi_dept}';
	$param.empl_cd = $("#contentForm input[name=empl_cd]").val();
	$param.auth_code = '${empl_info.auth_code}';
	</c:if>
	
	getAjaxCodeListSelectBox($("#i_dept_cd"),$param,'${empl_info.dept_cd}','전체');
	
	$('#spendHeaderList').setGridParam({
		url:"/selectSpendSearchList.do",
		cellEdit: true,
		postData:$frm.serialize(),
		gridComplete:function(){
			$('#spendReset').hide();
			$('#spendSearch').show();
			$('#spendListIns').show();
			$('#SpendHeaderDel').show();
		}
	}).trigger('reloadGrid');
	return false;
};
// 조회
btnSpendSearchEvent = function(){
	
	var $frm = $("#contentForm");
	var frm = document.contentForm;
	var getUrl = "/selectSpendSearchList.do";
	var checkFlag = true;
	save_type = "search";
	
	var params = new Object();
	
	frm.excclc_mt.value = frm.de.value;
	frm.cmpny_cd.value = $("#i_cmpny_cd").selectBox("value");
	frm.dept_cd.value = $("#i_dept_cd").selectBox("value");
	frm.setle_mn.value = "";
	frm.fileTxt.value = "";
	frm.fileNm.value = "";
	frm.vhcle_opratdstnc.value = "";
	
	params.excclc_mt = frm.excclc_mt.value;
	params.cmpny_cd = frm.cmpny_cd.value;
	params.dept_cd = frm.dept_cd.value;
	params.setle_mn = frm.setle_mn.value;
	params.fileTxt = frm.fileTxt.value;
	params.fileNm = frm.fileNm.value;
	params.vhcle_opratdstnc = frm.vhcle_opratdstnc.value;
	
	if(frm.excclc_mt.value == ""){
		alert("정산 월을 선택 해 주세요.");
		return false;
	}
	if(frm.empl_nm.value == ""){
		frm.empl_cd.value = "";
	}
	
	// 170502 부서코드가 null인 분들 체크해서 조회안되게 수정 by.김현식
	if(frm.cmpny_cd.value != "9100"){
		if(frm.dept_cd.value == ""){
			alert("부서코드를 선택 해 주세요.");
			return false;
		}
	}
	
	if(frm.empl_cd.value == ""){
		$(".vhcle").hide();
	}else {
		$(".vhcle").show();
	}
	
	params.empl_nm = frm.empl_nm.value;
	params.empl_cd = frm.empl_cd.value;
	params.acnt_cd = frm.acnt_cd.value;
	params.setle_mn = frm.setle_mn.value;
	
	if(!checkFlag) return false;
	
	<c:if test="${empl_info.multi_dept eq 'Y'}" >
		$("#i_dept_cd").selectBox("enable");
	</c:if>
	<c:if test="${empl_info.multi_dept ne 'Y'}" >
		$("#i_dept_cd").selectBox("disable");
	</c:if>
	<c:if test="${empl_info.auth_code eq '02'}" >
		$("#i_cmpny_cd").selectBox("enable");
		$("#i_dept_cd").selectBox("enable");
		$("#empl_nm").removeAttr("readonly");
	</c:if>
	<c:if test="${empl_info.team_yn eq 'Y'}" >
		$("#empl_nm").removeAttr("readonly");
	</c:if>

	$("#de").datepicker(datepicker_month).attr("readonly", "readonly");
	
	$('#spendHeaderList').setGridParam({
		url:getUrl,
		cellEdit: true,
		postData:params,
		afterInsertRow : 	function(rowid, rowdata, rowelem) {
	    	var frm = document.contentForm;
	    	if(frm.empl_cd.value == "" || frm.empl_nm.value == ""){
	    		frm.vhcle_opratdstnc.value = "";
	    	}else {
		    	frm.vhcle_opratdstnc.value = $("#spendHeaderList").jqGrid('getCell',rowid,'vhcle_opratdstnc');
	    	}
		}
	}).trigger('reloadGrid');
	
	$('#spendSearch').show();
	$('#spendListIns').show();
	$('#SpendHeaderDel').show();
	
	return false;
};
// 저장
btnSpendListSaveEvent = function(){
	var $frm = $("#contentForm"); 
	var frm = document.contentForm;
	var checkFlag = true;
	var vatFlag = true;
	var siFlag = true;
	var saveCnt = 0;
	
	var $obj = $("#spend_list");
	$obj.empty();
	
	// 슈퍼바이저여부 
	$.ajax({
		type:'post',
		url	:"/selectSuperYn.do",
		async:false,
		data:$frm.serialize(),
		dataType: 'json',
		error:function(jqXHR,status,err){
			alert("추가 중 에러...\n\n"+status+"\n\n"+err);
			fn_unLoading();
			checkFlag = false;
		},
		success:function(data){ super_yn = data.superYn; }
	});
	
	frm.vhcle_empl_cd.value = "";
	
	// cell edit 닫기
	fnCellEditClose($("#spendHeaderList"),18);
	
	if(save_type != 'excel'){ 
	
		// 엑셀 업로드 제외 저장시 url
		var getUrl = "/ims/inv/spend/saveSpendList.do";
		
		frm.vhcle_empl_cd.value = frm.empl_cd.value;
		
		$("#spendHeaderList").find('input[type=checkbox]:checked').each(function(){
			
			saveCnt++;
			if(!checkFlag) return;
				
			$("#" + $(this).parent().parent().attr('id')).css("background",'#FFFFFF');
			
			console.log("frm.cmpny_cd.value :" + frm.cmpny_cd.value);
			// 법인카드이면서 시식차량, 계정에 상관없이 세금계산서 가 아닐 경우 부가세를 0으로 셋팅하고 공급가액을 합계로 셋팅해준다.
			// 법인카드-시식차량도 부가세 0 입력할 수 있도록 수정.2014.10.28
			// 법인카드 부가세 0 상관없이 입력 가능하게 수정.2014.10.30
			//cmpny_cd 1000은 지앤푸드 
			if(frm.cmpny_cd.value == '1000'){
				/*
				if(!(($(this).parent().parent().find('td[aria-describedby=spendHeaderList_setle_mn]').text() == '1' 
					&& $(this).parent().parent().find('td[aria-describedby=spendHeaderList_acnt_cd]').text() == '83305')
				|| $(this).parent().parent().find('td[aria-describedby=spendHeaderList_setle_mn]').text() == '5')) {}
				*/
				//결제수단을 개인카드,현금으로 선택후 부가세 입력시 부가세가 0으로 바뀌며 공급가액 에 합산
				//결제수단 법인카드, 세금계산서이 경우 부가세 필수입력, 1=법인카드, 5=세금계산서 
				if(!($(this).parent().parent().find('td[aria-describedby=spendHeaderList_setle_mn]').text() == '1' 
				|| $(this).parent().parent().find('td[aria-describedby=spendHeaderList_setle_mn]').text() == '5')) {
					
					// 해당 row의 부가세가 있으면
					if($(this).parent().parent().find('td[aria-describedby=spendHeaderList_vat]').text() > 0){
	
						$("#" + $(this).parent().parent().attr('id')).css("background",'#FAE0D4');
						siFlag = false;
						checkFlag = false;
					}
				}
				
			}else if(frm.cmpny_cd.value == '3030' || frm.cmpny_cd.value == '3600'){ //빅밴드(리틀스타,셈마케팅) (2020-11-02일에 추가)
				 console.log("리틀수ㅡ타타ㅏ"); 
				//결제수단 법인카드, 세금계산서이 경우 부가세 필수입력, 1=법인카드, 5=세금계산서 
				if(!($(this).parent().parent().find('td[aria-describedby=spendHeaderList_setle_mn]').text() == '1' 
				|| $(this).parent().parent().find('td[aria-describedby=spendHeaderList_setle_mn]').text() == '5')) {
					
					// 해당 row의 부가세가 있으면
					if($(this).parent().parent().find('td[aria-describedby=spendHeaderList_vat]').text() > 0){
	
						$("#" + $(this).parent().parent().attr('id')).css("background",'#FAE0D4');
						siFlag = false;
						checkFlag = false;
					}
				}
				
			} else {
				/*
				// 법인카드, 세금계산서, 전자세금계산서 체크
				if(!($(this).parent().parent().find('td[aria-describedby=spendHeaderList_setle_mn]').text() == '1' || 
						$(this).parent().parent().find('td[aria-describedby=spendHeaderList_setle_mn]').text() == '5' || 
						$(this).parent().parent().find('td[aria-describedby=spendHeaderList_setle_mn]').text() == '6')){
				}
				*/
				// GNFOOD를 제외한 회사는 부가세 전부 0
				// 해당 row의 부가세가 있으면
				if($(this).parent().parent().find('td[aria-describedby=spendHeaderList_vat]').text() > 0){

					$("#" + $(this).parent().parent().attr('id')).css("background",'#FAE0D4');
					vatFlag = false;
					checkFlag = false;
				}
			}
			
			// 슈퍼바이저이고 유류비 계정코드가 있을 경우에 차량운행거리 무조건 입력(소수점 한자리까지)
			if($(this).parent().parent().find('td[aria-describedby=spendHeaderList_acnt_cd]').text() == '82201' &&
					super_yn == 'Y' && frm.vhcle_opratdstnc.value == ''){
				alert("차량 운행거리를 입력 해 주세요.");
				checkFlag = false;
			}
			
			if(!siFlag){
				
				alert("[법인카드, 세금계산서] \n\n만 부가세를 입력할 수 있습니다.");
			}else if(!vatFlag){
				
				alert("부가세를 입력할 수 없습니다.");
			}else if(!vatFlag && !siFlag){
				
				alert("[법인카드, 세금계산서] \n\n만 부가세를 입력할 수 있습니다.");
			}
			
			if(!checkFlag) return false;
			
			if(checkFlag){
				
				var $excclc_mts = $("<input type='hidden' name='excclc_mts' />");
				var $cmpny_cds = $("<input type='hidden' name='cmpny_cds' />");
				var $empl_cds = $("<input type='hidden' name='empl_cds' />");
				var $seqs = $("<input type='hidden' name='seqs' />");
				var $dept_cds = $("<input type='hidden' name='dept_cds' />");
				var $acnt_cds = $("<input type='hidden' name='acnt_cds' />");
				var $occrrnc_des = $("<input type='hidden' name='occrrnc_des' />");
				var $sumrys = $("<input type='hidden' name='sumrys' />");
				var $amts = $("<input type='hidden' name='amts' />");
				var $vats = $("<input type='hidden' name='vats' />");
				var $sums = $("<input type='hidden' name='sums' />");
				var $setle_mns = $("<input type='hidden' name='setle_mns' />");
				var $card_nos = $("<input type='hidden' name='card_nos' />");
				var $addchks = $("<input type='hidden' name='addchks' />");
				var $cust_nms = $("<input type='hidden' name='cust_nms' />");
				
				$excclc_mts.val($(this).parent().parent().find('td[aria-describedby=spendHeaderList_excclc_mt]').text());
				$cmpny_cds.val($(this).parent().parent().find('td[aria-describedby=spendHeaderList_cmpny_cd]').text());
				$empl_cds.val($(this).parent().parent().find('td[aria-describedby=spendHeaderList_empl_cd]').text());
				$seqs.val($(this).parent().parent().find('td[aria-describedby=spendHeaderList_seq]').text());
				$dept_cds.val($(this).parent().parent().find('td[aria-describedby=spendHeaderList_dept_cd]').text());
				$acnt_cds.val($(this).parent().parent().find('td[aria-describedby=spendHeaderList_acnt_cd]').text());
				$occrrnc_des.val($(this).parent().parent().find('td[aria-describedby=spendHeaderList_occrrnc_de]').text());
				$sumrys.val($(this).parent().parent().find('td[aria-describedby=spendHeaderList_sumry]').text());
				$amts.val(fnRemoveComma($(this).parent().parent().find('td[aria-describedby=spendHeaderList_amt]').text()));
				$vats.val(fnRemoveComma($(this).parent().parent().find('td[aria-describedby=spendHeaderList_vat]').text()));
				$sums.val(fnRemoveComma($(this).parent().parent().find('td[aria-describedby=spendHeaderList_sum]').text()));
				$setle_mns.val($(this).parent().parent().find('td[aria-describedby=spendHeaderList_setle_mn]').text());
				$card_nos.val($(this).parent().parent().find('td[aria-describedby=spendHeaderList_card_no]').text());
				$addchks.val($(this).parent().parent().find('td[aria-describedby=spendHeaderList_addchk]').text());
				$cust_nms.val($(this).parent().parent().find('td[aria-describedby=spendHeaderList_cust_nm]').text());
				
				$obj.append($excclc_mts);
				$obj.append($cmpny_cds);
				$obj.append($empl_cds);
				$obj.append($seqs);
				$obj.append($dept_cds);
				$obj.append($acnt_cds);
				$obj.append($occrrnc_des);
				$obj.append($sumrys);
				$obj.append($amts);
				$obj.append($vats);
				$obj.append($sums);
				$obj.append($setle_mns);
				$obj.append($card_nos);
				$obj.append($addchks);
				$obj.append($cust_nms);
			}else {
				return false;
			}
			
		});
		
		var b_occrrnc = true;
		
		var regExp = /^20[1-9][0-9]-[0-1][0-9]-[0-3][0-9]$/;
		$obj.find("input[name=occrrnc_des]").each(function(){
			if(!regExp.test($(this).val())){
				b_occrrnc = false;
			}
		});
		
		if(!b_occrrnc) {
			alert("발생일자 날짜형식이 맞지 않습니다.");
			return false;
		}
		
		if(saveCnt == 0){
			alert("저장할 내역이 없습니다.");
			return false;
		}
		
	} else { 
		
		// 엑셀 업로드 후 url
		var getUrl = "/ims/inv/spend/saveSpendExcelList.do";
		
		frm.excclc_mt.value = frm.de.value;
		
		$("#spendHeaderList tr td[aria-describedby=spendHeaderList_con_yn]").each(function(){
			
			if(!checkFlag) return;
			
			if($(this).text() == 'N'){
				alert("계정명이 잘못되었습니다. \n\n 확인 해 주세요.");
				checkFlag = false;
			}
		});
		
		$("#spendHeaderList tr td[aria-describedby=spendHeaderList_card_yn]").each(function(){
			
			if(!checkFlag) return;
			
			if($(this).text() == 'N'){
				alert("카드번호가 잘못되었습니다. \n\n 확인 해 주세요.");
				checkFlag = false;
			}
		});
		/*
		$("#spendHeaderList tr td[aria-describedby=spendHeaderList_setle_mn]").each(function(){
			
			$("#" + $(this).parent().attr('id')).css("background",'#FFFFFF');
			// 법인카드, 세금계산서, 전자세금계산서 체크
			if(!($(this).text() == '1' || $(this).text() == '5' || $(this).text() == '6')){
				
				// 해당 row의 부가세가 있으면
				if($(this).siblings("[aria-describedby=spendHeaderList_vat]").text() > 0){
					
					$("#" + $(this).parent().attr('id')).css("background",'#FAE0D4');
					vatFlag = false;
					checkFlag = false;
				}
			}
		});
		*/
		$("#spendHeaderList tr td[aria-describedby=spendHeaderList_acnt_cd]").each(function(){
			
			if($(this).text() == '82201' && frm.vhcle_opratdstnc.value == '' && super_yn == 'Y'){
				alert("차량 운행거리를 입력 해 주세요.");
				checkFlag = false;
			}
		});
		if(!vatFlag) alert("[개인카드, 현금] \n\n은 부가세를 입력할 수 없습니다.");
		
		if(!checkFlag) return false;
	}
	
	if(!checkFlag) return false;
	
	if(!confirm("정말 저장하시겠습니까?")) return false;
	
	if(checkFlag){
		frm.work_seq.value = g_work_seq;
		$.ajax({
			type:'post',
			url	:getUrl,
			data:$frm.serialize(),
			dataType: 'json',
			error:function(jqXHR,status,err){
				alert("추가 중 에러...\n\n"+status+"\n\n"+err);
				fn_unLoading();
			},
			complete: function(){	
				frm.work_seq.value = "";
				g_work_seq = "";
				/*
				$('#spendSearch').show();
				$('#spendListIns').show();
				$('#SpendHeaderDel').show();
				*/
				alert("정상적으로 저장 되었습니다.");
				//btnSpendSearchEvent();
				
				$('#spendHeaderList').trigger('reloadGrid');
			}
		});
	}
	return false;	
};

//지출결의서 전표 삭제
btnSpendHeaderDelEvent = function(){
	var frm = document.contentForm;
	var $frm = $("#contentForm");
	var getUrl = "";
	var delCnt = 0;
	
	var $obj = $("#spend_list");
	$obj.empty();
	
	alert("정상적인 삭제가 되지 않을 경우에는 \n인터넷 옵션 > 검색기록 설정 > '웹 페이지를 열 때마다'로 \n설정해주시면 정상적으로 삭제됩니다.");
	
	fn_loadingView("삭제 중입니다. <br>잠시만 기다려 주세요.");
	
	if(!confirm("정말 삭제하시겠습니까?")) {
		fn_unLoading();
		return false;
	}
	
	if(save_type != 'excel'){
		
		// 엑셀업로드 아니고 조회 후 전표삭제 url
		getUrl = '/ims/inv/spend/deleteSpendList.do';
		
		$("#spendHeaderList").find('input[type=checkbox]:checked').each(function(){
			
			delCnt++;
			
			var $param = new Object();
			
			$param.excclc_mt = $(this).parent().parent().find('td[aria-describedby=spendHeaderList_excclc_mt]').text();
			$param.cmpny_cd = $(this).parent().parent().find('td[aria-describedby=spendHeaderList_cmpny_cd]').text();
			$param.empl_cd = $(this).parent().parent().find('td[aria-describedby=spendHeaderList_empl_cd]').text();
			$param.seq = $(this).parent().parent().find('td[aria-describedby=spendHeaderList_seq]').text();
			
			// 상세추가건으로 추가된 row
			var addChk = $(this).parent().parent().find('td[aria-describedby=spendHeaderList_addchk]').text();
			// 해당 row의 id
			var delRowId = $(this).parent().parent().attr('id');
			
			if(addChk == 'Y'){
				
				$('#spendHeaderList').jqGrid('delRowData',delRowId);
				fn_unLoading();
			}else {
			
				$.ajax({
					type:'post',
					url	:getUrl,
//					data:$frm.serialize(),
					data:$param,
					dataType: 'json',
					async:false,
					success: function(data){
						data.delRowId = delRowId;
						deleteSpendHeaderRequest(data);
					},
					error:function(msg){
						alert("에러...");
						//fn_unLoading();
					},
					complete:function(){
						fn_unLoading();
					}
				});
			}
			
			//alert("정상적으로 삭제 되었습니다.");
			
		});
		
	}else {
		alert("엑셀 업로드 한 자료는 삭제할 수 없습니다.");
		return false;
	}
	
	if(delCnt == 0){
		alert("삭제할 내역이 없습니다.");
		return false;
	}
	
	return false;
};
deleteSpendHeaderRequest = function(msg){
	//fn_unLoading();
	if(msg.status =="SUCCESS"){
		if(msg.checkValue >= 0){
			//btnSpendSearchEvent();
			// row 삭제(tr의id)
			$('#spendHeaderList').jqGrid('delRowData',msg.delRowId);
			
		}else{
			alert("오류발생...");
		}
	}else{
		alert(msg.message);
		return;
	}
};

</script>
<script type="text/javascript">
/*
 * 
 	Upload Tab Event
 */
upload_tab_init = function(){
	
	// 회사코드 변경시 이벤트 바인딩.
	$("#duzon_cmpny_cd").selectBox().change(function(){cmpnyChangeEvent("uploadForm");});
    
    // 날짜 형식 셋팅(월달력)
	$("#upload_de").datepicker(datepicker_month).attr("readonly", "readonly");
 	
 	// 날짜 버튼 셋팅
	$( "#btn_upload_de_search" )
		.button({ icons:{ primary : "ui-icon-calendar" } ,text: false })
		.click(function(){$("#upload_de").focus(); return false;});
 	
 	
	// 조회 버튼
	$( "#bth_duzon_search" )
		.button({ icons:{ primary : "ui-icon-search" } ,text: true })
		.click(btnDuzonSearchEvent);
	
		// 더존 업로드 버튼
	$( "#btn_duzon_upload" )
		.button({ icons:{ primary : "ui-icon-disk" } ,text: true })
		.click(btnDuzonUploadEvent);
	
	// 회사코드 셋팅
	var $param = new Object();
	$param.group_cd = 'ED_CMPNY_CODE';

	getAjaxCodeListSelectBox($("#duzon_cmpny_cd"),$param,'${empl_info.dept_cd}',null,'cmpnyChangeEvent("uploadForm");');
 	
};

// upload grid setting
fn_upload_grid_setting = function(){
	
	$("#gbox_spendUploadList").show();
	
	//그리드 초기 셋팅
	$("#spendUploadList").jqGrid({
	  	url:'/selectSpendSearchList.do',
		datatype: "json",
		jsonReader : { 
			page: "page", 
			total: "total", 
			root: "rows", 
			records: function(obj){	return obj.length;},
			repeatitems: false, 
			id: "seq",
			cell: 'cell'
		},
	  	colNames:[
	  	          '정산 월','회사 코드','회사 명','부서 코드','부서 명', '사원 코드','사원 명','계정코드', '계정 명', '발생 일자', '적요', '공급가액', '부가세',
	  	          '합계', '결제 수단','결제 수단 코드', '카드 번호', '상점명', '카드사', '등록자ID', '등록일시','계정일치여부','합계일치','카드번호일치','순서', '더존업로드 구분'],
	  	colModel:[
	  		{name:'excclc_mt'	,index:'excclc_mt'		,width:100	,align:"center" ,sorttype:"string" 	,hidden:true},
	  		{name:'cmpny_cd'	,index:'cmpny_cd'		,width:100	,align:"center" ,sorttype:"string" 	,hidden:true},
	  		{name:'cmpny_nm'	,index:'cmpny_nm'		,width:100	,align:"center" ,sorttype:"string" 	,hidden:true},
	  		{name:'dept_cd'		,index:'dept_cd'		,width:100	,align:"left" 	,sorttype:"string" 	,hidden:true },
	  		{name:'dept_nm'		,index:'dept_nm'		,width:100	,align:"center" ,sorttype:"string"},
	  		{name:'empl_cd'		,index:'empl_cd'		,width:100	,align:"left" 	,sorttype:"string" 	,hidden:true       },
	  		{name:'empl_nm'		,index:'empl_nm'		,width:80	,align:"center" ,sorttype:"string"},
			{name:'acnt_cd'		,index:'acnt_cd'		,width:100	,align:"center" ,sorttype:"string"	,editable:false },
	  		{name:'acnt_nm'		,index:'acnt_nm'		,width:130	,align:"center" ,sorttype:"string"	,editable:true,edittype:'select', 
					editoptions:{value:sendListAcntCdList,dataEvents:[{type:"change",fn:sendListAcntCdChangeEvent}]}, editrules: {edithidden: true}},
		  	{name:'occrrnc_de'		,index:'occrrnc_de'			,width:100	,align:"center" ,sorttype:"string",editable:true
				  	 ,editoptions:	{
				  		 			dataEvents:[
				  		 		            {type:"keyup",fn:testRock3},
				  		 		         	{type:"focus",fn:testRock2}
				  		 		           ]
		 						  	}			 
	  		},
	  		{name:'sumry'		,index:'sumry'			,width:200	,align:"center" ,sorttype:"string",editable:true},
	  		{name:'amt'		,index:'amt'			,width:80	,align:"right" ,sorttype:"number",editable:true, formatter:"number"
	  			,editoptions:{dataEvents:[{type:"keydown",fn:fn_onlyNumber},{type:"focus",fn:fn_onlyNumberStyle}]}
	  		},
	  		{name:'vat'		,index:'vat'			,width:80	,align:"right" ,sorttype:"number",editable:true, formatter:"number"
	  			,editoptions:{dataEvents:[{type:"keydown",fn:fn_onlyNumber},{type:"focus",fn:fn_onlyNumberStyle}]}
	  		},
	  		{name:'sum'		,index:'sum'			,width:80	,align:"right" ,sorttype:"number",editable:false, formatter:"number"
	  			,editoptions:{dataEvents:[{type:"keydown",fn:fn_onlyNumber},{type:"focus",fn:fn_onlyNumberStyle}]}
	  		},
	  		{name:'setle_mn_nm'	,index:'setle_mn_nm'	,width:100	,align:"center" ,sorttype:"string",editable:true,edittype:'select', 
	  			 editoptions:{
					 	value:sendListSetle_MnList
					 	,dataEvents:[{type:"change",fn:sendListSetle_MnChangeEvent}]
	  			}, editrules: {edithidden: true}},
	  		{name:'setle_mn'	,index:'setle_mn', hidden:true},
	  		{name:'card_no'		,index:'card_no'			,width:150	,align:"center" ,sorttype:"string"
	  				 ,editable:true,edittype:'select', editoptions:{value:sendListCard_NoList}, editrules: {edithidden: true}
	  			 },
	  		{name:'cust_nm'		,index:'cust_nm'		,width:200	,align:"left" 	,sorttype:"string", editable:true},	 
	  		{name:'card_se'		,index:'card_se'		,width:60	,align:"left" 	,sorttype:"string"},	 
	  		{name:'reg_id'		,index:'reg_id'			,width:100	,align:"center" ,sorttype:"string" ,hidden:true},
	  		{name:'reg_dt'		,index:'reg_dt'			,width:100	,align:"center" ,sorttype:"string" ,hidden:true},
	  		{name:'con_yn'		,index:'con_yn'			,width:100	,align:"left" ,sorttype:"string",hidden:true},
	  		{name:'sum_yn'		,index:'sum_yn'			,width:100	,align:"left" ,sorttype:"number",hidden:true},
	  		{name:'card_yn'		,index:'card'			,width:100	,align:"left" ,sorttype:"string",hidden:true},
	  		{name:'seq'			,index:'seq'			,hidden:true },
	  		{name:'duzon_upload_se'		,index:'duzon_upload_se'			    ,hidden:true },
	  	],
	  	rowNum:10000,
	  	pager: '#spendUploadNav',
	  	//sortname: 'seq',
	    //sortorder: "asc",
	    cmTemplate: {sortable: false},
	    viewrecords: true,
	    caption:"개인경비View",
	    imgpath:"themes/${userVO.grid_style}/images",
	    shrinkToFit:false,
	    altRows: false,
	    autowidth:true,
	    height:'400',
	    cellEdit: false,
	    cellsubmit: 'clientArray',
	    gridComplete : spendUploadComplete,
	    loadError : jqLoadErr,
	    rownumbers: true,
	    onSelectRow: function(id){
			if(id && id!==lastsel2){
				jQuery('#rowed16').jqGrid('restoreRow',lastsel2);
				jQuery('#rowed16').jqGrid('editRow',id,true);
				lastsel2=id;
			}
	    },
	    hiddengrid:false,
	    rownumWidth:20,
	    afterInsertRow : 	function(rowid, rowdata, rowelem) {
			if (rowdata.con_yn == "Y") {
				//$("#" + rowid).css("background",'#FF5050');
			} else {
				$("#" + rowid).css("bgcolor",'#FAE0D4');
			}
			if(rowdata.duzon_upload_se == "Y"){
				$("#" + rowid).css("background",'#FCFFC6');
			}
		},
	    footerrow: true
	});
	
	// Key 로 움직일 수 있도록 key binding
	$("#spendUploadList").jqGrid('bindKeys');
	
	fn_grid_height($("#spendUploadList"));
};

// upload grid Complete
spendUploadComplete = function(ids){
	p_amt	= $("#spendUploadList").jqGrid('getCol', 'amt', false, 'sum');
	p_vat 	= $("#spendUploadList").jqGrid('getCol', 'vat', false, 'sum');
	p_sum 	= $("#spendUploadList").jqGrid('getCol', 'sum', false, 'sum');
	
	$("#spendUploadList").jqGrid('footerData','set', {dept_nm: '총 합계'
									 , amt	: p_amt 	 
									 , vat	: p_vat      
									 , sum	: p_sum 
									 });
};

//조회
btnDuzonSearchEvent = function(){
	var $frm = $("#duzonForm");
	var frm = document.duzonForm;
	var getUrl = "/selectSpendSearchList.do";
	var checkFlag = true;
	
	if(frm.empl_nm.value == ""){
		frm.empl_cd.value = "";
	}
	
	if(!checkFlag) return false;
	
	$('#spendUploadList').setGridParam({
		url:getUrl,
		postData:$frm.serialize()
	}).trigger('reloadGrid');
	
	return false;	
};

// 더존 업로드
btnDuzonUploadEvent = function(){
	var $frm = $("#duzonForm"); 
	var sendUrl = "/inv/spend/spendChitDuzonUpload.do";
	var checkFlag = true;
	
	if(!checkFlag) return false;
	
	var param = new Object();
	var $excclc_mt = $frm.find("[name=excclc_mt]");
	var $cmpny_cd = $frm.find("[name=cmpny_cd] option:selected");
	var $dept_cd = $frm.find("[name=dept_cd] option:selected");
	var $empl_cd = $frm.find("[name=empl_cd] option:selected");
	var $duzon_upload_se = $frm.find("[name=duzon_upload_se] option:selected");
	var $str_message = "";
	
	$str_message += "정산 월 : "+$excclc_mt.val();
	$str_message += "\n회사 : "+$cmpny_cd.text();
	$str_message += "\n부서 : "+$dept_cd.text();
	$str_message += "\n사원 : "+$empl_cd.text();
	$str_message += "\n업로드여부 : "+$duzon_upload_se.text();
	$str_message += "\n\n위 조건에 해당하는 내역을 더존에 업로드 합니다. 진행 하시겠습니까?";
	
	/*
	if($dept_cd.val() == "" ){
		alert("부서코드를 선택 해 주세요!!");
		return false;
	}
	if($empl_cd.val() == "" ){
		alert("사원코드를 선택 해 주세요!!");
		return false;
	}
	*/
	
	if(!confirm($str_message)) return false;
	
	/*
	// send Data 생성
	param.excclc_mt       = $excclc_mt.val();      
	param.cmpny_cd        = $cmpny_cd.val();       
	param.dept_cd         = $dept_cd.val();        
	param.empl_cd         = $empl_cd.val();        
	param.duzon_upload_se = $duzon_upload_se.val();
	*/
	$.ajax({
		type:"POST",
		url : sendUrl,
		data:$frm.serialize(),
		dataType:"json",
		success:function(data){
			if(data.success == 'Y'){
				alert(data.msg+"건이 정상처리 되었습니다.");
			}else {
				alert("에러발생!!");
			}
		},
		error:function(msg){
			fn_unLoading();
			alert("전송실패!!");
			return;
		}
	});
	
	return false;
	$('#spendUploadList').setGridParam({
		url:getUrl,
		postData:$frm.serialize()
	}).trigger('reloadGrid');
	
	return false;	
};
</script>

<script type="text/javascript">
/*
 * 
 	Search Tab Event
 */
search_tab_init = function(){
	
	// 회사코드 변경시 이벤트 바인딩.
	$("#sch_cmpny_cd").selectBox().change(function(){cmpnyChangeEvent("searchForm");})
	<c:if test="${empl_info.auth_code ne '02'}" >
		.selectBox("disable")
	</c:if>
	;
    
    // 날짜 형식 셋팅(월달력)
	$("#sch_de").datepicker(datepicker_month).attr("readonly", "readonly");

 	// 날짜 버튼 셋팅
	$( "#btn_sch_de" )
		.button({ icons:{ primary : "ui-icon-calendar" } ,text: false })
		.click(function(){$("#sch_de").focus(); return false;});
 	
	// 조회 버튼
	$( "#bth_sch_search" )
		.button({ icons:{ primary : "ui-icon-search" } ,text: true })
		.click(btnSchSearchEvent);
	
	// 엑셀 다운로드(개인경비)
	$( "#bth_sch_spend_excel" )
		.button({ icons:{ primary : "ui-icon-document" } ,text: true })
		.click(btnSchSpendExcelEvent);
	
	// 엑셀 다운로드(부서)
	$( "#bth_sch_excel" )
		.button({ icons:{ primary : "ui-icon-document" } ,text: true })
		.click(btnSchExcelEvent);
	
	// 엑셀 다운로드(사원)
	$( "#bth_sch_excel_empl" )
		.button({ icons:{ primary : "ui-icon-document" } ,text: true })
		.click(btnSchExcelEmplEvent);
	
	// 엑셀 다운로드(영수증 양식다운)
	$( "#bth_sch_excel_form_down" )
		.button({ icons:{ primary : "ui-icon-document" } ,text: true });
	
	// 회사코드 셋팅
	var $param = new Object();
	$param.group_cd = 'ED_CMPNY_CODE';
	$param.use_yn = 'Y';
	getAjaxCodeListSelectBox($("#sch_cmpny_cd"),$param,'${empl_info.cmpny_cd}',null,"cmpnyChangeEvent('searchForm');");
 	
	$param.group_cd  = 'SETLE_MN';
	
   	getAjaxCodeListSelectBox($("#sch_setle_mn"),$param,'','전체');
};

//조회
btnSchSearchEvent = function(){
	var $frm = $("#searchForm"); 
	var frm = document.searchForm;
	var getUrl = "/selectSpendSearchList.do";
	var checkFlag = true;
	
	frm.cmpny_cd.value = $("#sch_cmpny_cd").selectBox("value");
	frm.dept_cd.value = $("#sch_dept_cd").selectBox("value");
	
	if(frm.empl_nm.value == ""){
		frm.empl_cd.value = "";
	}
	
	// 170502 부서코드가 null인 분들 체크해서 조회안되게 수정 by.김현식
	if(frm.cmpny_cd.value != "9100"){
		if(frm.dept_cd.value == ""){
			alert("부서코드를 선택 해 주세요.");
			return false;
		}
	}
	
	if(!checkFlag) return false;
	
	fnGlobalParamSetting($frm);
	
	$('#spendUploadList').setGridParam({
		url:getUrl,
		postData:$frm.serialize()
	}).trigger('reloadGrid');
	
	return false;	
	
};

//계정코드 조회
getAjaxAcntListSelectBox = function($obj,$param,$cd,$firstOption){
	$.ajax({
			type:"POST",
			url : "/autoCompleteSpendList.do",
			data:$param,
			dataType:"json",
			success:function(data){fnAcntListViewSelectBox(data,$obj,$cd,$firstOption);},
			error:function(msg){
				fn_unLoading();
				alert("전송실패!!");
				return;
			}
	});
};
//계정코드 값 세팅
fnAcntListViewSelectBox = function(data,$obj,$cd,$firstOption){
	var cdCheck = false;
	var optionObj = "";
	$obj.empty();
	if($firstOption){
		optionObj = '<option value="">' + $firstOption+'</option>';
	}
	
	$.each(data.rows,function(){
		optionObj += '<option value="'+ this.acnt_cd + '">' + this.acnt_nm+'</option>';
		
		if($cd == this.acnt_cd) cdCheck = true;
	});
	
	$obj.selectBox("options",optionObj);
	
	if(cdCheck) $obj.selectBox("value",$cd);
};

// global param setting
fnGlobalParamSetting = function($obj){
	
	main_params = new Object();
	
	var $cmpny_cd = $obj.find("[name=cmpny_cd]").val();
	var $dept_cd = $obj.find("[name=dept_cd]").val();
	var $empl_cd = $obj.find("[name=empl_cd]").val();
	var $excclc_mt = $obj.find("[name=excclc_mt]").val();
	
	if($cmpny_cd){
		main_params.cmpny_cd = $cmpny_cd;
		main_params.dept_cd = $dept_cd;
		main_params.empl_cd = $empl_cd;
		main_params.excclc_mt = $excclc_mt;
	}
}
</script>
<script type="text/javascript">
/*
 * 
 	fin Search Tab Event
 */
fin_tab_init = function(){
	
    // 날짜 형식 셋팅(월달력)
	$("#fin_de").datepicker(datepicker_month).attr("readonly", "readonly");
	// 엑셀 업로드
	$("#finFileInput").change(function(){$("#finFileTxt").val($(this).val());});
    
    // 날짜 버튼 셋팅
	$( "#btn_fin_de" )
		.button({ icons:{ primary : "ui-icon-calendar" } ,text: false })
		.click(function(){$("#fin_de").focus(); return false;});
 	
	// 엑셀 업로드
	$( "#finSpendExl" )
		.button({ icons:{ primary : "ui-icon-folder-collapsed" } ,text: true })
		.click(btnFinSpendExlEvent);
	// 저장
	$( "#bth_fin_search" )
		.button({ icons:{ primary : "ui-icon-disk" } ,text: true })
		.click(btnFinSpendListSaveEvent);
};

//엑셀 업로드
btnFinSpendExlEvent = function(){
	var frm = document.finForm;
	
	frm.card_se.value = $("#card_se").selectBox("value");
	
	if($("#fin_de").val() == "" ){
		alert("정산월을 선택 해 주세요!!!");
		$("#fin_de").focus();
		return false;
	}
	if($("#card_se").selectBox("value") == "" ){
		alert("카드사를 선택 해 주세요!!!");
		$("#card_se").focus();
		return false;
	}
	
	if(frm.fileNm.value == ""){
		alert("엑셀 파일을 선택 해 주세요!!!");
		return false;
	}
	
	if(!confirm("실행 하시겠습니까?")) return;
	
	fn_loadingView("업로드 중입니다. <br>잠시만 기다려 주세요.");
	
	frm.action = "/ims/inv/spend/spendFinExcelUpload.do";
	frm.method = "post";
	frm.encoding = 'multipart/form-data';
	frm.target = 'hiddenFrame';
	frm.submit(); 
	return false;
};

// 재경팀 개인경비 엑셀 업로드 후 리스트
fnFinExcelUploadAfter = function($work_seq, $card_se){
	var frm = document.finForm;
	var params = new Object();
	params.work_seq = $work_seq;
	params.card_se = $card_se;
	params.excclc_mt = $("#fin_de").selectBox("value");
	f_work_seq = $work_seq;
	
	$('#spendHeaderList').setGridParam({
		url:'/selectSpendFinHeaderUploadList.do',
		postData:params,
		cellEdit: false,
		gridComplete : fn_checkCardSeList,
		afterInsertRow : function(rowid, rowdata, rowelem) {
			if (rowdata.con_yn == 'N' || rowdata.sum_yn == 'N' || rowdata.card_yn == 'X') {
	    		$("#" + rowid).css("background",'#FAE0D4');
			}
			
		}
	}).trigger('reloadGrid');
	
	// 저장버튼
	if(f_work_seq != ''){
		$("#bth_fin_search").show();
		$("#bth_fin_reset").show();
	}else {
		$("#bth_fin_search").hide();
		$("#bth_fin_reset").hide();
	}
};

// 엑셀 업로드 후 리스트 합계
fn_checkCardSeList = function(){
	
	/* 하단 총 합계 변경 */
	spendHeaderComplete();
};

// 엑셀 업로드 후 저장
btnFinSpendListSaveEvent = function(){
	
	var $frm = $("#finForm"); 
	var frm = document.finForm;
	var checkFlag = true;
	
	// 엑셀 업로드 후 url
	var getUrl = "/ims/inv/spend/saveFinSpendExcelList.do";
	
	$("#spendHeaderList tr td[aria-describedby=spendHeaderList_sum_yn]").each(function(){
		
		if(!checkFlag) return;
		
		if($(this).text() == 'N'){
			alert("합계가 잘못되었습니다. \n\n 확인 해 주세요.");
			checkFlag = false;
		}
	});
	
	$("#spendHeaderList tr td[aria-describedby=spendHeaderList_card_yn]").each(function(){
		
		if(!checkFlag) return;
		
		if($(this).text() == 'X'){
			alert("등록되지 않은 카드가 있습니다. \n\n 확인 해 주세요.");
			checkFlag = false;
		}
	});
	
	if(!checkFlag) return false;
	
	if(!confirm("정말 저장하시겠습니까?")) return false;
	
	if(checkFlag){
		frm.work_seq.value = f_work_seq;
		$.ajax({
			type:'post',
			url	:getUrl,
			data:$frm.serialize(),
			dataType: 'json',
			error:function(jqXHR,status,err){
				alert("추가 중 에러...\n\n"+status+"\n\n"+err);
				fn_unLoading();
			},
			complete: function(){	
				frm.work_seq.value = "";
				//frm.fileTxt.value = "";
				frm.fileNm.value = "";
				f_work_seq = "";
				alert("정상적으로 저장 되었습니다.");
				fnFinExcelUploadAfter('', '');
			}
		});
	}
	return false;	
}

</script>
<script type="text/javascript">

// 엑셀 다운로드(개인경비)
btnSchSpendExcelEvent = function(){
	var frm = document.searchForm;
	
	frm.cmpny_cd.value = $("#sch_cmpny_cd").selectBox("value");
	frm.dept_cd.value  = $("#sch_dept_cd").selectBox("value");
	
	if(frm.dept_cd.value == ""){
		alert("부서를 선택 해 주세요.");
		return false;
	}
	
	if(frm.empl_cd.value == ""){
		alert("사원을 선택 해 주세요.");
		return false;
	}
	frm.target = "hiddenFrame";
	frm.action = "/ims/inv/spend/spendBaseExcelList.do";
	frm.submit();
	return false;
};

//엑셀 다운로드(부서)
btnSchExcelEvent = function(){
	var frm = document.searchForm;
	
	frm.cmpny_cd.value = $("#sch_cmpny_cd").selectBox("value");
	frm.dept_cd.value = $("#sch_dept_cd").selectBox("value");
	frm.target = "hiddenFrame";
	
	if(frm.cmpny_cd.value =='9100'){
		frm.action = "/ims/inv/spend/spendExcelList.do";
		frm.submit();
		return false;	
	}
	
	if(frm.dept_cd.value == ""){
		alert("부서를 선택 해 주세요.");
		return false;
	}
	
	frm.action = "/ims/inv/spend/spendExcelList.do";
	frm.submit();
	return false;
};
//엑셀 다운로드(개인)
btnSchExcelEmplEvent = function(){
	var frm = document.searchForm;
	
	frm.cmpny_cd.value = $("#sch_cmpny_cd").selectBox("value");
	frm.dept_cd.value  = $("#sch_dept_cd").selectBox("value");
	
	if(frm.dept_cd.value == ""){
		alert("부서를 선택 해 주세요.");
		return false;
	}
	
	if(frm.empl_cd.value == ""){
		alert("사원을 선택 해 주세요.");
		return false;
	}
	frm.target = "hiddenFrame";
	frm.action = "/ims/inv/spend/spendExcelEmplList.do";
	frm.submit();
	return false;	
};

$(document).on("focusout",".autoEmpl input",function(){
    var $obj = new Object();
    var frm = document.contentForm;
    
    $obj.cmpny_cd = $("#i_cmpny_cd").selectBox("value");
    $obj.dept_cd = $("#i_dept_cd").selectBox("value");
    $obj.srchPrd = frm.empl_nm.value;
    
    $.ajax({
		type:'post',
		url	:'/autoCompleteEmplCdList.do',
		data:$obj,
		dataType: 'json',
		async:false,
		success:function(data){
			if(data.rows == ""){
				frm.empl_cd.value = "";
				frm.empl_nm.value = "";
			}else {
				frm.empl_cd.value = data.rows[0].empl_cd;
			}
		}
	});
});
$(document).on("focusout",".sch_autoEmpl input",function(){
    var $obj = new Object();
    var frm = document.searchForm;
    
    $obj.cmpny_cd = $("#sch_cmpny_cd").selectBox("value");
    $obj.dept_cd = $("#sch_dept_cd").selectBox("value");
    $obj.srchPrd = frm.empl_nm.value;
    
    $.ajax({
		type:'post',
		url	:'/autoCompleteEmplCdList.do',
		data:$obj,
		dataType: 'json',
		async:false,
		success:function(data){
			if(data.rows == ""){
				frm.empl_cd.value = "";
				frm.empl_nm.value = "";
			}else {
				frm.empl_cd.value = data.rows[0].empl_cd;
			}
		}
	});
});
$(document).on("focusout",".duzon_autoEmpl input",function(){
    var $obj = new Object();
    var frm = document.duzonForm;
    
    $obj.cmpny_cd = $("#duzon_cmpny_cd").selectBox("value");
    $obj.dept_cd = $("#duzon_dept_cd").selectBox("value");
    $obj.srchPrd = frm.empl_nm.value;
    
    $.ajax({
		type:'post',
		url	:'/autoCompleteEmplCdList.do',
		data:$obj,
		dataType: 'json',
		async:false,
		success:function(data){
			if(data.rows == ""){
				frm.empl_cd.value = "";
				frm.empl_nm.value = "";
			}else {
				frm.empl_cd.value = data.rows[0].empl_cd;
			}
		}
	});
});

</script>
<!-- 컨텐츠 시작 -->
<body style="overflow:hidden; ">

	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(/common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
		<tr>
			<td width="60%" style="padding-left:5px; padding-top:5px; ">
				<!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
				<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" />개인경비</span>
			</td>
			<td width="40%" align="right"><!-- n 개의 읽지않은 문서가 있습니다. --></td>
		</tr>
	</table>
	
   	<div id="contentFormSearchTab" style="margin:6.5px;">
		<ul>
			<li><a href="#contentFormDiv">등록/수정</a></li>
			<li><a href="#contentSearchFormDiv">조회</a></li>
			<li><a href="#contentFinFormDiv">법인카드 엑셀업로드</a></li>
			<li><a href="#contentDuzonFormDiv">더존 업로드</a></li>
		</ul>
	    <div id="contentFormDiv">
	    	<form name="contentForm" id="contentForm">
	    		<input type="hidden" name="work_seq" />
	    		<input type="hidden" name="seq" id="seq">
	    		<input type="hidden" name="card_yn" id="card_yn">
	    		<input type="hidden" name="acnt_cd" id="acnt_cd">
	    		<input type="hidden" name="occrrnc_de" id="occrrnc_de">
	    		<input type="hidden" name="sumry" id="sumry">
	    		<input type="hidden" name="amt" id="amt">
	    		<input type="hidden" name="vat" id="vat">
	    		<input type="hidden" name="sum" id="sum">
	    		<input type="hidden" name="setle_mn" id="setle_mn">
	    		<input type="hidden" name="card_no" id="card_no">
	    		<input type="hidden" name="reg_id" id="reg_id">
	    		<input type="hidden" name="reg_dt" id="reg_dt">
	    		<input type="hidden" name="excclc_mt" id="excclc_mt">
	    		<input type="hidden" name="srchPrd" id="srchPrd">
	    		<input type="hidden" name="cmpny_cd" id="cmpny_cd">
	    		<input type="hidden" name="dept_cd" >
	    		<input type="hidden" name="empl_cd" id="empl_cd" value="${empl_info.empl_cd}">
	    		<input type="hidden" name="vhcle_empl_cd" id="frm.vhcle_empl_cd.value"> <!-- 차량운행거리 체크용 -->
	    		<div id="spend_list" style="display:none;"></div>
	    		<table class="contentTable" width="100%">
			    	<colgroup>
			    		<col width="7%">
			    		<col width="18%">
			    		<col width="7%">
			    		<col width="18%">
			    		<col width="7%">
			    		<col width="18%">
			    		<col width="7%">
			    		<col width="18%">
			    	</colgroup>
					<tr>
						<td>
							<label for="de">정산 월</label>
				    	</td>
		    			<td>
							<input type="text" name="de" id="de" value="${spendCommand.excclc_mt}">
							<button id="btn_spendDe_search">정산 월</button>
		    			</td>
				    	<td>		
						<label for="i_cmpny_cd">회사코드</label>
			    		</td>
		    			<td>
							<select id="i_cmpny_cd" name="i_cmpny_cd" class="ui_select"><%-- ${brandOption} --%></select>
		    			</td>
		    			<td>
						<label for="dept_cd">부서코드</label>
			    		</td>
		    			<td>
							<select id="i_dept_cd" name="i_dept_cd" class="ui_select"></select>
		    			</td>
		    			<td>
							<label for="i_empl_nm">사원명</label>
			    		</td>
		    			<td class="autoEmpl">
		    				<input type="text" name="empl_nm" id="empl_nm" value="${empl_info.mber_nm}" onkeyup="autocomplete_empl_cd();" onkeypress="autocomplete_empl_cd();"
		    					<c:if test="${empl_info.team_yn ne 'Y' && empl_info.auth_code ne '02'}" >readonly="readonly"</c:if>
		    				/>
		    			</td>
			    	</tr>
			    	<tr>
			    		<td>	
						<label for="spendExcel" >엑셀 업로드</label>
						</td>
		    			<td colspan="5">
		    				<input type="text" class="hp" style="width:150px;" id="fileTxt" readonly="readonly" name="fileTxt" style="text-align: left;"> 
		    				<span style="position: absolute; height: 32; width: 29; background-image: url(/resources/images/cmmn/excel_search.png); clip: rect(0, 32, 29, 0);">
		                    <input type="file" name="fileNm" id="fileInput" style="width: 29px; height: 32px;  opacity: 0;cursor:pointer;">
			                </span>
			                <span style="padding-left:50px;" ><button id="spendExl">엑셀 업로드</button></span>
		    			</td>
		    			<td class="vhcle">
							<label for="vhcle_opratdstnc">차량운행거리</label>
			    		</td>
		    			<td class="vhcle">
							<input type="text" name="vhcle_opratdstnc" id="vhcle_opratdstnc" value="" onkeyup="decimalChk(this);" onkeypress="decimalChk(this);">
		    			</td>
		    		</tr>
		    		<tr>
		    			<td colspan="8" align="right" >
		    				<span style="float:left;color:#CC3D3D">※ 법인카드 사용내역 중 해외결제분은 미매입 또는 환가료 미포함되므로 카드사 고객센터에 금액확인하여 입력해주시길 바랍니다.</span>
		    				<button id="spendReset" style="display:none;">초기화</button>
		    				<button id="spendSearch">조회</button>
		    				<button id="spendHeaderSub">저장</button>
		    				<button id="spendListIns">상세추가</button> 
		    				<button id="SpendHeaderDel" >전표삭제</button>
		    				<!-- <button id="procReflectWrh">입고전표 확정</button>  -->
		    			</td>
		    		</tr>
		    	</table>
   			</form>
	    </div>
	    <div id="contentSearchFormDiv">
	    	<form name="searchForm" id="searchForm">
	    		<input type="hidden" name="acntNm" id="acntNm"><!-- 자동완성용.-->
	    		<input type="hidden" name="cardNo" id="cardNo"><!-- 자동완성용.-->
	    		<input type="hidden" name="emplCd" id="emplCd"><!-- 자동완성용.-->
	    		<input type="hidden" name="empl_cd" value="${empl_info.empl_cd}">
	    		<input type="hidden" name="seq" id="sch_seq">
	    		<input type="hidden" name="cmpny_cd" id="cmpny_cd">
	    		<input type="hidden" name="dept_cd" >
	    		<input type="hidden" name="srchPrd" />
	    		<table class="contentTable" width="100%">
			    	<colgroup>
			    		<col width="7%">
			    		<col width="18%">
			    		<col width="7%">
			    		<col width="18%">
			    		<col width="7%">
			    		<col width="18%">
			    		<col width="7%">
			    		<col width="18%">
			    	</colgroup>
				<tr><td>
						<label for="sch_de">정산 월</label>
			    	</td>
	    			<td>
						<input type="text" name="excclc_mt" id="sch_de" value="${spendCommand.excclc_mt}">
						<button id="btn_sch_de">정산 월</button>
	    			</td>
			    	<td>		
						<label for="sch_cmpny_cd">회사코드</label>
		    		</td>
	    			<td>
						<select id="sch_cmpny_cd" name="sch_cmpny_cd" class="ui_select"><%-- ${brandOption} --%></select>
	    			</td>
	    			<td>
						<label for="sch_dept_cd">부서코드</label>
		    		</td>
	    			<td>
						<select id="sch_dept_cd" name="sch_dept_cd" class="ui_select"></select>
	    			</td>
	    			<td>
						<label for="sch_empl_nm">사원명</label>
					</td>
		    		<td class="sch_autoEmpl">
	    				<input type="text" name="empl_nm" id="sch_empl_nm" value="${empl_info.mber_nm}" onkeyup="autocomplete_empl_cd_search();" onkeypress="autocomplete_empl_cd_search();" 
	    					<c:if test="${empl_info.team_yn ne 'Y' && empl_info.auth_code ne '02'}" >readonly="readonly"</c:if>
	    				/>
	    			</td>
		    	</tr>
		    	<tr>
		    		<td>	
						<label for="sch_acnt_cd" >계정</label>
					</td>
	    			<td>
	    				<select id="sch_acnt_cd" name="acnt_cd" class="ui_select"></select>
	    			</td>
		    		<td>	
						<label for="sch_setle_mn" >결제수단</label>
					</td>
	    			<td>
	    				<select id="sch_setle_mn" name="setle_mn" class="ui_select"></select>
	    			</td>
	    		</tr>
	    		<tr>
		    			<td colspan="8" align="right" >
		    				<button id="bth_sch_search" >조회</button>
		    				<button id="bth_sch_spend_excel" >사용내역 출력</button>
		    				<button id="bth_sch_excel" >팀별 합계 다운로드</button>
		    				<button id="bth_sch_excel_empl" >개인경비내역서 다운로드</button>
		    				<button id="bth_sch_excel_form_down" onclick="location.href='http://mail.gngrp.com/uploadTempDir/ims/경비영수증파일.xlsx'; return false;">경비 영수증 다운로드</button>
		    			</td>
		    		</tr>	
		    	</table>
   			</form>
	    </div>
	    <div id="contentFinFormDiv">
	    	<form name="finForm" id="finForm">
	    		<input type="hidden" name="work_seq" />
		    	<table class="contentTable" width="100%">
			    	<colgroup>
			    		<col width="7%">
			    		<col width="18%">
			    		<col width="7%">
			    		<col width="18%">
			    		<col width="7%">
			    		<col width="18%">
			    		<col width="7%">
			    		<col width="18%">
			    	</colgroup>
					<tr>
						<td>
							<label for="fin_de">정산 월</label>
				    	</td>
		    			<td>
							<input type="text" name="excclc_mt" id="fin_de" value="${spendCommand.excclc_mt}">
							<button id="btn_fin_de">정산 월</button>
		    			</td>
		    			<td>
							<label for="card_list">카드사</label>
				    	</td>
		    			<td>
							<select id="card_se" name="card_se" class="ui_select">
								<option value="BC">비씨카드</option>
								<option value="SH">신한카드</option>
								<option value="HN">하나카드</option>
								<option value="KB">국민카드</option>
								<option value="NH">농협카드</option>
							</select>
		    			</td>
		    			<td>	
							<label for="finSpendExcel" >엑셀 업로드</label>
						</td>
		    			<td colspan="5">
		    				<input type="text" class="hp" style="width:150px;" id="finFileTxt" readonly="readonly" name="fileTxt" style="text-align: left;"> 
		    				<span style="position: absolute; height: 32; width: 29; background-image: url(/resources/images/cmmn/excel_search.png); clip: rect(0, 32, 29, 0);">
		                    <input type="file" name="fileNm" id="finFileInput" style="width: 29px; height: 32px;  opacity: 0;cursor:pointer;">
			                </span>
			                <span style="padding-left:50px;" ><button id="finSpendExl">엑셀 업로드</button></span>
		    			</td>
			    	</tr>
		    		<tr>
		    			<td colspan="8" align="right" >
		    				 <button id="bth_fin_search" style="display:none;">저장</button>
		    			</td>
		    		</tr>	
		    	</table>
	    	</form>
	    </div>
	    <div id="contentDuzonFormDiv">
	    	<form name="duzonForm" id="duzonForm">
	    		<input type="hidden" name="empl_cd" value="${empl_info.empl_cd}">
		    	<table class="contentTable" width="100%">
			    	<colgroup>
			    		<col width="7%">
			    		<col width="18%">
			    		<col width="7%">
			    		<col width="18%">
			    		<col width="7%">
			    		<col width="18%">
			    		<col width="7%">
			    		<col width="18%">
			    	</colgroup>
					<tr><td>
							<label for="upload_de">정산 월</label>
				    	</td>
		    			<td>
							<input type="text" name="excclc_mt" id="upload_de" value="${spendCommand.excclc_mt}">
							<button id="btn_upload_de_search">정산 월</button>
		    			</td>
				    	<td>		
							<label for="duzon_cmpny_cd">회사코드</label>
			    		</td>
		    			<td>
							<select id="duzon_cmpny_cd" name="cmpny_cd" class="ui_select"><%-- ${brandOption} --%></select>
		    			</td>
		    			<td>
							<label for="duzon_dept_cd">부서코드</label>
			    		</td>
		    			<td>
							<select id="duzon_dept_cd" name="dept_cd" class="ui_select"></select>
		    			</td>
		    			<td>
							<label for="duzon_empl_nm">사원명</label>
			    		</td>
		    			<td class="duzon_autoEmpl">
		    				<input type="text" name="empl_nm" id="duzon_empl_nm" value="${empl_info.mber_nm}" onkeyup="autocomplete_empl_cd_upload();" onkeypress="autocomplete_empl_cd_upload();" 
		    					<c:if test="${empl_info.auth_code ne '02'}" >readonly="readonly"</c:if>
		    				/>
		    			</td>
			    	</tr>
			    	<tr>
			    		<td>
						<label for="duzon_upload_se" >더존 업로드 여부</label>
						</td>
		    			<td colspan="3">
		    				<select id="duzon_upload_se" name="duzon_upload_se"  class="ui_select">
		    					<option value="">--전체--</option>
		    					<option value="N">미 업로드</option>
		    					<option value="Y">업로드</option>
		    				</select>
		    			</td>
		    		</tr>
		    		<tr>
		    			<td colspan="8" align="right" >
		    				 <button id="bth_duzon_search">조회</button>
		    				 <button id="btn_duzon_upload">더존 업로드</button> 
		    			</td>
		    		</tr>	
		    	</table>
	    	</form>
	    </div>
    </div>
	<div style="margin:6.5px;">
		<table id="spendHeaderList" class="scroll"></table>
   		<div id="spendHeaderNav"></div>
			<table id="spendUploadList" class="scroll"></table>
   		<div id="spendUploadNav"></div>
    </div>
    <div class="tpad_10"></div>
<iframe name="hiddenFrame" id="hiddenFrame" style="display: none;visibility: hidden;"></iframe>
</body>
<!-- 컨텐츠 끝 -->