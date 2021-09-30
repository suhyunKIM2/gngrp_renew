
var sessionMsg = "오랜시간사용하지 않아 세션이 종료되었습니다\n\n다시 로그인 해주십시오";

function sessionChk(data) {
	var data = data + "";
	if (data.indexOf("logout.jsp") > -1) {
		alert(sessionMsg);
		location.href = "/";
		return;
	}
}
