<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
	String daum_editor_uri = request.getRequestURI();
	int height = 255;
	String homeURL = "http://" + request.getServerName();
	String userAgent = request.getHeader("User-Agent");
	boolean isIE = nek.common.util.Convert.isIE(request);
	String ieEditor = (String)session.getAttribute("ieEditor");
	
	// 웹에디터 사용 체크
	List<String> jspPage = new ArrayList<String>(0);
	jspPage.add("mail/mail_form");
	jspPage.add("mail/mail_paper_form");
	jspPage.add("mail/mail_signature");
	jspPage.add("noticeticker/noticeticker_edit_form");
	jspPage.add("noticeticker/noticeticker_form");
	jspPage.add("approval/apprdoc_edit");
	jspPage.add("approval/formdoc");
	jspPage.add("approval/imsidoc");
// 	jspPage.add("bbs/form");
// 	jspPage.add("bbswork/form");
	jspPage.add("notification/form");
// 	jspPage.add("todo/edit");
// 	jspPage.add("todo/form");
// 	jspPage.add("todo/read");


// 	for(String jsp : jspPage) {
// 		if (daum_editor_uri.indexOf(jsp) > -1) ieEditor = "none";
// 	}

	try { height = Integer.parseInt(request.getParameter("height")); } catch (Exception e) {}
%>

<div id="ExternalEditorArea">
<%	if (isIE && "tagfree".equals(ieEditor)) { %>
	<script language="javascript" src="/common/active-x/tagfree/tweditor.js?url=<%=daum_editor_uri%>"></script>
	<!-- 태그프리에디터 로딩 이후 함수 수행 -->
	<script language="JScript" FOR="twe" EVENT="OnControlInit()">
		SetEditorData(this);
	</script>
<%	} else if ( "xfree".equals(ieEditor) ) { %>
	<script src="/common/libs/xfe2.0/js/xfe_main.js" type="text/javascript" ></script>
	<script type="text/javascript">
	function xfreeDataSet() {
		setTimeout( function() {
			SetEditorData( xfe );	
		}, 300);
	}
	var eMode = 0;
	var eHeight = "400px";
	var cUrl = self.location.href.toUpperCase();
	if ( cUrl.indexOf("APPROVAL/IMSIDOC.HTM") > -1 ) {
 		eMode = 1;
	} else if ( cUrl.indexOf("APPROVAL/FORMDOC.HTM") > -1 ) {
 		eMode = 2;
	}
	if (cUrl.indexOf("APPROVAL/FORMDOC.HTM") > -1) {
		eHeight = "800px";
	}
	
	eMode = 0;	
	xfe = new XFE({
		   basePath : '/common/libs/xfe2.0',
		   width : '100%',
		   height : eHeight,
		   editMode : eMode,
		   rootId : 'xfe',
		   onLoad : xfreeDataSet
	});
	xfe.render('ExternalEditorArea');
	</script>
<%	} else { %>
<style type="text/css">
#tx_trex_container { z-index: 0; }	/* 2013.07.01 편집기 위 레이어 숨는 현상 처리 */
#tx_image { position: relative; overflow: hidden; }
#fileupload_image {
	position: absolute;
	top: 0; right: 0; margin: 0;
	border: solid transparent;
	border-width: 0 0 100px 200px;
	opacity: 0; filter: alpha(opacity=0);
	-moz-transform: translate(-300px, 0) scale(4);
	direction: ltr; cursor: pointer;
}
</style>

<div style="width:100%; min-height:<%=height + 35 %>px; border:0px; vertical-align:top;">

	<link href="/common/libs/daumeditor/7.5.11/css/editor.css" rel="stylesheet" type="text/css" charset="utf-8"/>
	<script src="/common/libs/daumeditor/7.5.11/js/editor_loader.js" type="text/javascript" charset="utf-8"></script>

	<script src="/common/libs/jquery-ui-file-upload/js/jquery.iframe-transport.js"></script>
	<script src="/common/libs/jquery-ui-file-upload/js/jquery.fileupload.js"></script>
	<script src="/common/libs/jquery-ui-file-upload/js/jquery.fileupload-fp.js"></script>
	<script src="/common/libs/jquery-ui-file-upload/js/jquery.fileupload-ui.js"></script>
	<script src="/common/libs/jquery-ui-file-upload/js/jquery.fileupload-jui.js"></script>
	<script src="/common/libs/jquery-ui-file-upload/js/locale.js"></script>
	<script src="/common/scripts/fileupload.js"></script>
			
	<!-- 에디터 컨테이너 시작 -->
	<div id="tx_trex_container" class="tx-editor-container">
		<!-- 사이드바
		<div id="tx_sidebar" class="tx-sidebar">
			<div class="tx-sidebar-boundary">
			</div>
		</div> -->

		<!-- 툴바 - 기본 시작 -->
		<!--
			@decsription
			툴바 버튼의 그룹핑의 변경이 필요할 때는 위치(왼쪽, 가운데, 오른쪽) 에 따라 <li> 아래의 <div>의 클래스명을 변경하면 된다.
			tx-btn-lbg: 왼쪽, tx-btn-bg: 가운데, tx-btn-rbg: 오른쪽, tx-btn-lrbg: 독립적인 그룹
		
			드롭다운 버튼의 크기를 변경하고자 할 경우에는 넓이에 따라 <li> 아래의 <div>의 클래스명을 변경하면 된다.
			tx-slt-70bg, tx-slt-59bg, tx-slt-42bg, tx-btn-43lrbg, tx-btn-52lrbg, tx-btn-57lrbg, tx-btn-71lrbg
			tx-btn-48lbg, tx-btn-48rbg, tx-btn-30lrbg, tx-btn-46lrbg, tx-btn-67lrbg, tx-btn-49lbg, tx-btn-58bg, tx-btn-46bg, tx-btn-49rbg
		-->
		<div id="tx_toolbar_basic" class="tx-toolbar tx-toolbar-basic">
		<div class="tx-toolbar-boundary">
			<ul class="tx-bar tx-bar-left">
				<li class="tx-list">
					<div id="tx_fontfamily" unselectable="on" class="tx-slt-70bg tx-fontfamily">
						<a href="javascript:;" title="글꼴">굴림</a>
					</div>
					<div id="tx_fontfamily_menu" class="tx-fontfamily-menu tx-menu" unselectable="on"></div>
				</li>
			</ul>
			<ul class="tx-bar tx-bar-left">
				<li class="tx-list">
					<div unselectable="on" class="tx-slt-42bg tx-fontsize" id="tx_fontsize">
						<a href="javascript:;" title="글자크기">9pt</a>
					</div>
					<div id="tx_fontsize_menu" class="tx-fontsize-menu tx-menu" unselectable="on"></div>
				</li>
			</ul>
			<ul class="tx-bar tx-bar-left tx-group-font">
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-lbg 	tx-bold" id="tx_bold">
						<a href="javascript:;" class="tx-icon" title="굵게 (Ctrl+B)">굵게</a>
					</div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-bg 	tx-underline" id="tx_underline">
						<a href="javascript:;" class="tx-icon" title="밑줄 (Ctrl+U)">밑줄</a>
					</div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-bg 	tx-italic" id="tx_italic">
						<a href="javascript:;" class="tx-icon" title="기울임 (Ctrl+I)">기울임</a>
					</div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-bg 	tx-strike" id="tx_strike">
						<a href="javascript:;" class="tx-icon" title="취소선 (Ctrl+D)">취소선</a>
					</div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="		 tx-slt-tbg 	tx-forecolor" id="tx_forecolor">
						<a href="javascript:;" class="tx-icon" title="글자색">글자색</a>
						<a href="javascript:;" class="tx-arrow" title="글자색 선택">글자색 선택</a>
					</div>
					<div id="tx_forecolor_menu" class="tx-menu tx-forecolor-menu tx-colorpallete"
						 unselectable="on"></div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="		 tx-slt-brbg 	tx-backcolor" id="tx_backcolor">
						<a href="javascript:;" class="tx-icon" title="글자 배경색">글자 배경색</a>
						<a href="javascript:;" class="tx-arrow" title="글자 배경색 선택">글자 배경색 선택</a>
					</div>
					<div id="tx_backcolor_menu" class="tx-menu tx-backcolor-menu tx-colorpallete"
						 unselectable="on"></div>
				</li>
			</ul>
			<ul class="tx-bar tx-bar-left tx-group-align">
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-lbg 	tx-alignleft" id="tx_alignleft">
						<a href="javascript:;" class="tx-icon" title="왼쪽정렬 (Ctrl+,)">왼쪽정렬</a>
					</div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-bg 	tx-aligncenter" id="tx_aligncenter">
						<a href="javascript:;" class="tx-icon" title="가운데정렬 (Ctrl+.)">가운데정렬</a>
					</div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-bg 	tx-alignright" id="tx_alignright">
						<a href="javascript:;" class="tx-icon" title="오른쪽정렬 (Ctrl+/)">오른쪽정렬</a>
					</div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-rbg 	tx-alignfull" id="tx_alignfull">
						<a href="javascript:;" class="tx-icon" title="양쪽정렬">양쪽정렬</a>
					</div>
				</li>
			</ul>
			<ul class="tx-bar tx-bar-left tx-group-tab">
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-lbg 	tx-indent" id="tx_indent">
						<a href="javascript:;" title="들여쓰기 (Tab)" class="tx-icon">들여쓰기</a>
					</div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-rbg 	tx-outdent" id="tx_outdent">
						<a href="javascript:;" title="내어쓰기 (Shift+Tab)" class="tx-icon">내어쓰기</a>
					</div>
				</li>
			</ul>
			<ul class="tx-bar tx-bar-left tx-group-list">
				<li class="tx-list">
					<div unselectable="on" class="tx-slt-31lbg tx-lineheight" id="tx_lineheight">
						<a href="javascript:;" class="tx-icon" title="줄간격">줄간격</a>
						<a href="javascript:;" class="tx-arrow" title="줄간격">줄간격 선택</a>
					</div>
					<div id="tx_lineheight_menu" class="tx-lineheight-menu tx-menu" unselectable="on"></div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="tx-slt-31rbg tx-styledlist" id="tx_styledlist">
						<a href="javascript:;" class="tx-icon" title="리스트">리스트</a>
						<a href="javascript:;" class="tx-arrow" title="리스트">리스트 선택</a>
					</div>
					<div id="tx_styledlist_menu" class="tx-styledlist-menu tx-menu" unselectable="on"></div>
				</li>
			</ul>
			<ul class="tx-bar tx-bar-left tx-group-etc">
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-lbg 	tx-emoticon" id="tx_emoticon">
						<a href="javascript:;" class="tx-icon" title="이모티콘">이모티콘</a>
					</div>
					<div id="tx_emoticon_menu" class="tx-emoticon-menu tx-menu" unselectable="on"></div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-bg 	tx-table" id="tx_table">
						<a href="javascript:;" class="tx-icon" title="표만들기">표만들기</a>
					</div>
					<div id="tx_table_menu" class="tx-table-menu tx-menu" unselectable="on">
						<div class="tx-menu-inner">
							<div class="tx-menu-preview"></div>
							<div class="tx-menu-rowcol"></div>
							<div class="tx-menu-deco"></div>
							<div class="tx-menu-enter"></div>
						</div>
					</div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-rbg 	tx-link" id="tx_link">
						<a href="javascript:;" class="tx-icon" title="링크 (Ctrl+K)">링크</a>
					</div>
					<div id="tx_link_menu" class="tx-link-menu tx-menu"></div>
				</li>
			</ul>
			<ul class="tx-bar tx-bar-left tx-group-undo">
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-lbg 	tx-undo" id="tx_undo">
						<a href="javascript:;" class="tx-icon" title="실행취소 (Ctrl+Z)">실행취소</a>
					</div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-rbg 	tx-redo" id="tx_redo">
						<a href="javascript:;" class="tx-icon" title="다시실행 (Ctrl+Y)">다시실행</a>
					</div>
				</li>
			</ul>
			<ul class="tx-bar tx-bar-right">
				<li class="tx-list">
					<div unselectable="on" class="tx-btn-lrbg tx-fullscreen" id="tx_fullscreen" style="margin-top: -5px; margin-right: -1px;">
						<a href="javascript:;" class="tx-icon" title="넓게쓰기 (Ctrl+M)">넓게쓰기</a>
					</div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="tx-btn-nlrbg tx-advanced" id="tx_advanced">
						<a href="javascript:;" class="tx-icon" title="툴바 더보기">툴바 더보기</a>
					</div>
				</li>
			</ul>
				<!-- 사이드바 / 첨부 -->
				<ul class="tx-bar tx-bar-left tx-nav-attach">
					<%	if (daum_editor_uri.indexOf("noticeticker") == -1) { %>
					<!-- 이미지 첨부 버튼 시작 -->
					<li class="tx-list">
						<div unselectable="on" id="tx_image" class="tx-image tx-btn-trans" style="margin-top: 4px;">
							<a href="javascript:" title="사진" class="tx-text" style="height:16px;">사진</a>
							<input id="fileupload_image" type="file" name="files[]" data-url="/imageupload" accept="image/*" multiple style="border-width: 0px;">
						</div>
					</li>
					<!-- 이미지 첨부 버튼 끝 -->
					<%	} %>
				</ul>
				<!-- 사이드바 / 우측영역 -->
				<ul class="tx-bar tx-bar-right">
				</ul>
				<ul class="tx-bar tx-bar-right tx-nav-opt">
					<li class="tx-list">
						<div unselectable="on" class="tx-switchtoggle" id="tx_switchertoggle" style="margin-top: -4px; margin-right: 9px;">
							<a href="javascript:;" title="에디터 타입">에디터</a>
						</div>
					</li>
				</ul>
		</div>
		</div>
		<!-- 툴바 - 기본 끝 -->

		<!-- 툴바 - 더보기 시작 -->
		<div id="tx_toolbar_advanced" class="tx-toolbar tx-toolbar-advanced">
		<div class="tx-toolbar-boundary">
			<ul class="tx-bar tx-bar-left">
				<li class="tx-list">
					<div class="tx-tableedit-title"></div>
				</li>
			</ul>
			<ul class="tx-bar tx-bar-left tx-group-align">
				<li class="tx-list">
					<div unselectable="on" class="tx-btn-lbg tx-mergecells" id="tx_mergecells">
						<a href="javascript:;" class="tx-icon2" title="병합">병합</a>
					</div>
					<div id="tx_mergecells_menu" class="tx-mergecells-menu tx-menu" unselectable="on"></div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="tx-btn-bg tx-insertcells" id="tx_insertcells">
						<a href="javascript:;" class="tx-icon2" title="삽입">삽입</a>
					</div>
					<div id="tx_insertcells_menu" class="tx-insertcells-menu tx-menu" unselectable="on"></div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="tx-btn-rbg tx-deletecells" id="tx_deletecells">
						<a href="javascript:;" class="tx-icon2" title="삭제">삭제</a>
					</div>
					<div id="tx_deletecells_menu" class="tx-deletecells-menu tx-menu" unselectable="on"></div>
				</li>
			</ul>
			<ul class="tx-bar tx-bar-left tx-group-align">
				<li class="tx-list">
					<div id="tx_cellslinepreview" unselectable="on" class="tx-slt-70lbg tx-cellslinepreview">
						<a href="javascript:;" title="선 미리보기"></a>
					</div>
					<div id="tx_cellslinepreview_menu" class="tx-cellslinepreview-menu tx-menu" unselectable="on"></div>
				</li>
				<li class="tx-list">
					<div id="tx_cellslinecolor" unselectable="on" class="tx-slt-tbg tx-cellslinecolor">
						<a href="javascript:;" class="tx-icon2" title="선색">선색</a>
						<div class="tx-colorpallete" unselectable="on"></div>
					</div>
					<div id="tx_cellslinecolor_menu" class="tx-cellslinecolor-menu tx-menu tx-colorpallete" unselectable="on"></div>
				</li>
				<li class="tx-list">
					<div id="tx_cellslineheight" unselectable="on" class="tx-btn-bg tx-cellslineheight">
						<a href="javascript:;" class="tx-icon2" title="두께">두께</a>
					</div>
					<div id="tx_cellslineheight_menu" class="tx-cellslineheight-menu tx-menu" unselectable="on"></div>
				</li>
				<li class="tx-list">
					<div id="tx_cellslinestyle" unselectable="on" class="tx-btn-bg tx-cellslinestyle">
						<a href="javascript:;" class="tx-icon2" title="스타일">스타일</a>
					</div>
					<div id="tx_cellslinestyle_menu" class="tx-cellslinestyle-menu tx-menu" unselectable="on"></div>
				</li>
				<li class="tx-list">
					<div id="tx_cellsoutline" unselectable="on" class="tx-btn-rbg tx-cellsoutline">
						<a href="javascript:;" class="tx-icon2" title="테두리">테두리</a>
					</div>
					<div id="tx_cellsoutline_menu" class="tx-cellsoutline-menu tx-menu" unselectable="on"></div>
				</li>
			</ul>
			<ul class="tx-bar tx-bar-left">
				<li class="tx-list">
					<div id="tx_tablebackcolor" unselectable="on" class="tx-btn-lrbg tx-tablebackcolor" style="background-color:#9aa5ea;">
						<a href="javascript:;" class="tx-icon2" title="테이블 배경색">테이블 배경색</a>
					</div>
					<div id="tx_tablebackcolor_menu" class="tx-tablebackcolor-menu tx-menu tx-colorpallete" unselectable="on"></div>
				</li>
			</ul>
			<ul class="tx-bar tx-bar-left">
				<li class="tx-list">
					<div id="tx_tabletemplate" unselectable="on" class="tx-btn-lrbg tx-tabletemplate">
						<a href="javascript:;" class="tx-icon2" title="테이블 서식">테이블 서식</a>
					</div>
					<div id="tx_tabletemplate_menu" class="tx-tabletemplate-menu tx-menu tx-colorpallete" unselectable="on"></div>
				</li>
			</ul>
			<ul class="tx-bar tx-bar-left">
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-bg 	tx-specialchar" id="tx_specialchar">
						<a href="javascript:;" class="tx-icon" title="특수문자">특수문자</a>
					</div>
					<div id="tx_specialchar_menu" class="tx-specialchar-menu tx-menu"></div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-rbg 	tx-horizontalrule" id="tx_horizontalrule">
						<a href="javascript:;" class="tx-icon" title="구분선">구분선</a>
					</div>
					<div id="tx_horizontalrule_menu" class="tx-horizontalrule-menu tx-menu" unselectable="on"></div>
				</li>
			</ul>
			<ul class="tx-bar tx-bar-left">
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-lbg 	tx-richtextbox" id="tx_richtextbox">
						<a href="javascript:;" class="tx-icon" title="글상자">글상자</a>
					</div>
					<div id="tx_richtextbox_menu" class="tx-richtextbox-menu tx-menu">
						<div class="tx-menu-header">
							<div class="tx-menu-preview-area">
								<div class="tx-menu-preview"></div>
							</div>
							<div class="tx-menu-switch">
								<div class="tx-menu-simple tx-selected"><a><span>간단 선택</span></a></div>
								<div class="tx-menu-advanced"><a><span>직접 선택</span></a></div>
							</div>
						</div>
						<div class="tx-menu-inner">
						</div>
						<div class="tx-menu-footer">
							<img class="tx-menu-confirm"
								 src="/common/libs/daumeditor/7.5.11/images/icon/editor/btn_confirm.gif?rv=1.0.1" alt=""/>
							<img class="tx-menu-cancel" hspace="3"
								 src="/common/libs/daumeditor/7.5.11/images/icon/editor/btn_cancel.gif?rv=1.0.1" alt=""/>
						</div>
					</div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-bg 	tx-quote" id="tx_quote">
						<a href="javascript:;" class="tx-icon" title="인용구 (Ctrl+Q)">인용구</a>
					</div>
					<div id="tx_quote_menu" class="tx-quote-menu tx-menu" unselectable="on"></div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-bg 	tx-background" id="tx_background">
						<a href="javascript:;" class="tx-icon" title="배경색">배경색</a>
					</div>
					<div id="tx_background_menu" class="tx-menu tx-background-menu tx-colorpallete"
						 unselectable="on"></div>
				</li>
				<li class="tx-list">
					<div unselectable="on" class="		 tx-btn-rbg 	tx-dictionary" id="tx_dictionary">
						<a href="javascript:;" class="tx-icon" title="사전">사전</a>
					</div>
				</li>
			</ul>
		</div>
		</div>
		<!-- 툴바 - 더보기 끝 -->
				
		<!-- 편집영역 시작 -->
		<!-- 에디터 Start -->
		<div id="tx_canvas" class="tx-canvas">
			<div id="tx_loading" class="tx-loading">
				<div><img src="/common/libs/daumeditor/7.5.11/images/icon/editor/loading2.png" width="113" height="21" align="absmiddle"/></div>
			</div>
			<div id="tx_canvas_wysiwyg_holder" class="tx-holder" style="display:block;">
				<iframe id="tx_canvas_wysiwyg" name="tx_canvas_wysiwyg" allowtransparency="true" frameborder="0"></iframe>
			</div>
			<div class="tx-source-deco">
				<div id="tx_canvas_source_holder" class="tx-holder">
					<textarea id="tx_canvas_source" rows="30" cols="30"></textarea>
				</div>
			</div>
			<div id="tx_canvas_text_holder" class="tx-holder">
				<textarea id="tx_canvas_text" rows="30" cols="30"></textarea>
			</div>
		</div>
		<!-- 에디터 End -->
				
		<!-- 높이조절 Start -->
		<div id="tx_resizer" class="tx-resize-bar">
			<div class="tx-resize-bar-bg"></div>
			<img id="tx_resize_holder" src="/common/libs/daumeditor/7.5.11/images/icon/editor/skin/01/btn_drag01.gif" width="58" height="12" unselectable="on" alt="" />
		</div>
		<!-- 높이조절 End -->
		
		<!-- 편집영역 끝 -->
	</div>
	<!-- 에디터 컨테이너 끝 -->
	<style>
	.br {font-size:15pt;}
	</style>
	<script type="text/javascript">
		var canvasHeight = <%=height %>;
		var homeUrl = "<%=homeURL %>";
		var isEditorFocus = false;
		EditorJSLoader.ready(function(Editor) {
			TrexMessage.addMsg({'@fontfamily.malgungothic': '맑은고딕'});
// 			TrexMessage.addMsg({'@fontfamily.gulimche': '굴림체'});
// 			TrexMessage.addMsg({'@fontfamily.batangche': '바탕체'});
// 			TrexMessage.addMsg({'@fontfamily.dotumche': '돋움체'});
// 			TrexMessage.addMsg({'@fontfamily.nanumgothic': '나눔고딕'});
			var formName = $('form').eq(0).attr('id') || $('form').eq(0).attr('name');
			var config = { 
				txHost: '', /* 런타임 시 리소스들을 로딩할 때 필요한 부분으로, 경로가 변경되면 이 부분 수정이 필요. ex) http://xxx.xxx.com */
				txPath: '/common/libs/daumeditor/7.5.11/', /* 런타임 시 리소스들을 로딩할 때 필요한 부분으로, 경로가 변경되면 이 부분 수정이 필요. ex) /xxx/xxx/ */
				txService: 'sample', /* 수정필요없음. */
				txProject: 'sample', /* 수정필요없음. 프로젝트가 여러개일 경우만 수정한다. */
				initializedId: "", /* 대부분의 경우에 빈문자열 */
				wrapper: "tx_trex_container", /* 에디터를 둘러싸고 있는 레이어 이름(에디터 컨테이너) */
				form: formName+"", /* 등록하기 위한 Form 이름 */
				txIconPath: "/common/libs/daumeditor/7.5.11/images/icon/editor/", /*에디터에 사용되는 이미지 디렉터리, 필요에 따라 수정한다. */
				txDecoPath: homeUrl + "/common/libs/daumeditor/7.5.11/images/deco/contents/", /*본문에 사용되는 이미지 디렉터리, 서비스에서 사용할 때는 완성된 컨텐츠로 배포되기 위해 절대경로로 수정한다. */
				canvas: {
					styles: {
						color: "#000000", /* 기본 글자색 */
						fontFamily: "gulim", /* 기본 글자체 */
						fontSize: "9pt", /* 기본 글자크기 */
						backgroundColor: "#fff", /*기본 배경색 */
						lineHeight: "1.5", /*기본 줄간격 */
						padding: "8px" /* 위지윅 영역의 여백 */
					},
//					customCssText: "p{margin:5px 3px; padding:0px;}",
//					bogus_html: ( ($tx.msie) ? '<p class="br">&nbsp;</p>' : '<p class="br"><br/></p>' ),
					showGuideArea: false
					
				},
				
				toolbar: {
		            fontfamily: {
		                options : [
		                    { label: TXMSG('@fontfamily.gulim')+' (<span class="tx-txt">가나다라</span>)', title: TXMSG('@fontfamily.gulim'), data: 'Gulim,굴림,AppleGothic,sans-serif', klass: 'tx-gulim' },
// 		                    { label: TXMSG('@fontfamily.gulimche')+' (<span class="tx-txt">가나다라</span>)', title: TXMSG('@fontfamily.gulimche'), data: 'Gulimche,굴림체,AppleGothic,sans-serif', klass: 'tx-gulimche' },
		                    { label: TXMSG('@fontfamily.batang')+' (<span class="tx-txt">가나다라</span>)', title: TXMSG('@fontfamily.batang'), data: 'Batang,바탕,serif', klass: 'tx-batang' },
// 		                    { label: TXMSG('@fontfamily.batangche')+' (<span class="tx-txt">가나다라</span>)', title: TXMSG('@fontfamily.batangche'), data: 'Batang,바탕체,serif', klass: 'tx-batang' },
		                    { label: TXMSG('@fontfamily.dotum')+' (<span class="tx-txt">가나다라</span>)', title: TXMSG('@fontfamily.dotum'), data: 'Dotum,돋움,sans-serif', klass: 'tx-dotum' },
// 		                    { label: TXMSG('@fontfamily.dotumche')+' (<span class="tx-txt">가나다라</span>)', title: TXMSG('@fontfamily.dotumche'), data: 'Dotum,돋움체,sans-serif', klass: 'tx-dotum' },
		                    { label: TXMSG('@fontfamily.gungsuh')+' (<span class="tx-txt">가나다라</span>)', title: TXMSG('@fontfamily.gungsuh'), data: 'Gungsuh,궁서,serif', klass: 'tx-gungseo' },
							{ label: TXMSG('@fontfamily.malgungothic')+' (<span class="tx-txt">가나다라</span>)', title: TXMSG('@fontfamily.malgungothic'), data: 'Malgun Gothic', klass: 'tx-malgungothic' },
// 		                    { label: TXMSG('@fontfamily.nanumgothic')+' (<span class="tx-txt">가나다라</span>)', title: TXMSG('@fontfamily.nanumgothic'), data: 'Nanum Gothic', klass: 'tx-nanumgothic' },
		                    { label: 'Arial (<span class="tx-txt">abcde</span>)', title: 'Arial', data: 'Arial,sans-serif', klass: 'tx-arial' },
		                    { label: 'Verdana (<span class="tx-txt">abcde</span>)', title: 'Verdana', data: 'Verdana,sans-serif', klass: 'tx-verdana' },
		                    { label: 'Courier New (<span class="tx-txt">abcde</span>)', title: 'Courier New', data: 'Courier New,monspace', klass: 'tx-courier-new' },
		                    { label: 'MS Gothic (<span class="tx-txt">ゴシック</span>)', title: 'MS Gothic', data: 'MS Gothic,monspace', klass: 'tx-ms-gothic' },
		                    { label: 'MS Mincho (<span class="tx-txt">明朝</span>)', title: 'MS Mincho', data: 'MS Mincho,serif', klass: 'tx-ms-mincho' }
// 		                    { label: 'MS UI Gothic (<span class="tx-txt">abcde</span>)', title: 'MS UI Gothic', data: 'MS UI Gothic', klass: 'tx-ms-ui-gothic' }
		                ]
		            }
		        },
		        
				events: {
					preventUnload: false
				},
				sidebar: {
					//attachbox: { show: true }
				}
				//,size: {
//					contentWidth: 756 /* 지정된 본문영역의 넓이가 있을 경우에 설정 */
	//			}
			};
			
			daumOpenEditor = new Editor(config);
			if( self.location.href.toLowerCase().indexOf("/approval/") > -1 ) {
				Editor.getCanvas().setCanvasSize({height:512});
			} else {
				Editor.getCanvas().setCanvasSize({height:canvasHeight});
			}

			Editor.getCanvas().observeJob(Trex.Ev.__IFRAME_LOAD_COMPLETE, function(ev) {
				SetEditorData( Editor );
				//objEditor.modify({ content: contents });
			});
			
			var fail = new Array();
			var $dialog = $('<div></div>')
				.html('<p>잠시 기다려주세요.</p><p>이미지파일을 서버에 업로드중입니다.</p><p>네트워크 연결 상태에 따라 시간이 걸릴 수 있습니다.</p>')
				.dialog({ autoOpen: false, title: 'Uploading Image File...' });
			
			// 에디터에서 포커스가 사라지고 0.5초동안 `isEditorFocus`값을 `true`로 설정
			$('#tx_canvas_wysiwyg')
			.bind("blur", function() {
				isEditorFocus = true;
				window.setTimeout(function() {
					isEditorFocus = false;
				}, 500);
			});
			
			$('#fileupload_image')
// 				.bind("fileuploadadd fileuploadsubmit fileuploadsend fileuploaddone fileuploadfail fileuploadalways fileuploadprogress fileuploadprogressall fileuploadstart fileuploadstop fileuploadchange fileuploadpaste fileuploaddrop fileuploaddragover fileuploaddestroy fileuploaddestroyed fileuploadadded fileuploadsent fileuploadcompleted fileuploadfailed fileuploadstarted fileuploadstopped", function(e) { 
// 					console.log(e.type);
// 				})
			    .bind('fileuploadstart', function (e, data) {
			    	// IE 에서 포커스가 없는 경우 이미지가 삽입이 않되서 추가한 코드
			    	if (document.selection && !isEditorFocus)
			    		Editor.focusOnTop();
			    })
				.bind('fileuploadstop', function (e, data) {
					if ($dialog.dialog("isOpen")) $dialog.dialog('close');
					if (fail.length > 0) {
						var sError = "";
						var error = $('<div></div>');
						error.dialog({ autoOpen: false, title: 'Failed image uploads' });
						error.dialog({ buttons: [ { text: "Ok", click: function() { $(this).dialog("close"); } } ] });
						
						for(var i = 0, len = fail.length; i < len; i++) {
							var file = fail.shift();
							switch(file.error) {
								case "1" : sError = ": 파일크기 초과하였습니다.<br/>(파일크기: 5MB미만으로 제한)"; break;
								case "2" : sError = ": 이미지 파일이 아닙니다."; break;
								default : sError = "";
							}
							var html = '<p style="line-height:130%;">'
									 + '파일명: '+file.name+'<br/>'
									 + '파일크기: '+file.size+'<br/>'
									 + '파일종류: '+file.type+'<br/>'
									 + '<span style="color:red;font-weight:bold;">업로드  실패</span>'
									 + '<span style="font-weight:bold;">'+sError+'</span></p>';
							error.append(html);
						}
						error.dialog('open');
					}
				})
				.fileupload({
					dropZone: null,
					dataType: 'json',
					add: function (e, data) {
						if (!$dialog.dialog("isOpen")) $dialog.dialog('open');
						data.submit();
					},
					done: function (e, data) {
						$.each(data.result, function (index, file) {
							if (file.error == "0") {
								Editor.getSidebar().getAttacher("image").attachHandler({
									'imageurl': file.url,
									'filename': file.name,
									'filesize': file.size,
									'imagealign': 'L',
									'originalurl': file.url,
									'thumburl': file.url
								});
							} else {
								fail.push(file);
							}
						});
					},
					maxFileSize: 5000000,
					minFileSize: 1,
					acceptFileTypes: /(\.|\/)(gif|jpe?g|png|bmp)$/i
				});
		});
	
		function setEditorForm() {
			try { $("#txtContent").remove(); } catch(e) {}
			var formGenerator = Editor.getForm();
			var content = Editor.getContent();
			formGenerator.createField(
					tx.textarea({
						'name': "tx_content", // 본문 내용을 필드를 생성하여 값을 할당하는 부분
						'id': "txtContent",
						'style': { 'display': "none" }
					}, content)
			);
		}
	</script>
</div>
<%	} %>
</div>