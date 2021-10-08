// 라인을 늘일 변수
var uf = '';
// sw_file_add_form div에 input 태그를 추가하는 함수
function sw_file_add(size, ext) {
    // 최초 sw_file_add_form에 추가하고 다음부터는 sw_file_add_form1, 2, 3, 4, ... 로 계속 추가가 된다.
    // 물론 그에 맞는 div도 계속 생성한다. 차후에 추가한 div를 제거하는 것도 필요하다.
    eval('sw_file_add_form' + uf).innerHTML += "<input type=file name=file[] size='" + size + "' " + ext + "><div id='sw_file_add_form" + (uf+1) + "'></div>";
    uf++;
}
//input file의 인덱스번호로 쓰임(전역변수)
var fileIndex = 0;	


//업로드 파일 지정
var makeUploadElem = function(fileElemObj){
	fileIndex++;	//global var	
	var addAttachFileSectionElem = $("div").filter(".addAttachFileSection");
	var attachFileListElem = $(addAttachFileSectionElem).find("ul");	
	
	var targetElem=$("div#fileUpBtnWrapper");
	var fileElem=$("<input id='file"+fileIndex+"' class='file' type='file' value='' data-mini='true' name='file"+fileIndex+"' style='width:94px;position: absolute;right:0px;top:0px; opacity:0; filter: alpha(opacity=0);cursor: pointer;outline:none;'/>");
	//var fileUpBtnElem = $("<span class='fileUp' style='font-size:0;'>&nbsp;파일</span>");
	
	$(fileElem).change(function(){
		makeUploadElem(this);	//recursive				
	});
	
	$(targetElem).append(fileElem);
	//$(targetElem).append(fileUpBtnElem);
	$(fileElemObj).hide();	
	
	//파일 목록 추가 / 삭제
	var fileElemObjVal = $(fileElemObj).val();	
	$(attachFileListElem).append(
		"<li>" +			
			"<span class='removeAttach' onClick='deleteFileList(this,"+fileIndex+");'>x</span>" +
			"<span class='attachFileName'>"+fileElemObjVal+"</span>" +
		"</li>"
	);			
	
	//$("div#debug").text($("div.fileUploadSection").html());
};
//업로드 파일 리스트 삭제
var deleteFileList = function(fileListElem,fileElemIndex){
	//기본으로 마크업된 input file의 인덱스 번호가 0으로 시작되는데
	//전역변수로 증가 시킨 상태이므로 -1을 시켜서 인덱스 번호를 맞춰준다.
	var fileElemIdx = fileElemIndex - 1;
	var fileUpBtnWrapElem = $("div").filter("#fileUpBtnWrapper");
	
	$(fileUpBtnWrapElem).find("input:file").filter("input[name=file"+fileElemIdx+"]").remove();	
	$(fileListElem).parent().remove();
	
	//$("div#debug").text($("div.fileUploadSection").html());
};

//전송이 완료되거나 실패시에도 input file과 li를 모두삭제 시켜주고
//전역변수로 사용된 인덱스를 초기화 시켜준다.
var deleteFileListAndFileElems = function(){
	var fileUploadSectionElem = $("div").filter(".fileUpWrapper");
	var addAttachFileSectionElem = $("div").filter(".addAttachFileSection").find("ul");
	$(fileUploadSectionElem).children().remove();
	$(addAttachFileSectionElem).children().remove();
	fileIndex = 0;
};