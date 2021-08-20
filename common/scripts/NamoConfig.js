// 	Install File URL on Server
//	[SAMPLE] var g_strSetupUrl = "http://2xx.xx.xx.xx/NamoActiveSquare6_Install.exe";

var g_strSetupUrl	= "http://" + document.domain + "/common/active-x/namo/NamoActiveSquare6_Install.exe";

//	Check For Version File URL on Server
//	[SAMPLE] var g_strIniUrl = "http://2xx.xx.xx.xx/Version.ini";
var g_strIniUrl		= "http://" + document.domain + "/common/active-x/namo/Version.ini";

//	Set Register Trusted Site, Delimeter By ";"
//	[SAMPLE] var g_strTrustSite = "http://www.namo.co.kr;http://www.namo.com;http://www.namostores.com";
var g_strTrustSite	= "";

//	Message For Already Install ActiveSquare6
var g_strAlreadyMsg	= "Already Installed ActiveSquare 6";

//	Message For Updating ActiveSquare6
var g_strUpdate		= "A new version of ActiveSquare 6 has been released.\nThe ActiveSquare 6 Update will start now.";


//	Message For Updating NamoInstaller
var g_strInstallerUpdate = "A new version of NamoInstaller has been released. Please Update NamoInstaller!!";


//	PopUp File Path
var strPopupFile	= "/common/active-x/namo/As6SetUpInfo.htm";



//////////////////////////////////////////////////////
//Do Not Change This Value
//////////////////////////////////////////////////////
var NamoWecGuid = "F1F33E02-DD6B-4a7c-9C29-D02A95500CB0";
//////////////////////////////////////////////////////