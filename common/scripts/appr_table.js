//--------------------------------------------------------------------------------
//결재자 삭제
function tblDelete()
{
    if (selectLineCheck() < 1) {
        alert("삭제할 결재자를 선택하여 주십시오" ) ; 
        return ; 
    }
    if (!confirm("선택한 결재자를 삭제 하시겠습니까?") )
        return ;

    var tbl = this.sharetbl;
    var idx = tbl.rows.length;
    var checker;
    for (var i=idx-1;i>=0;i--)
    {
        checker = tbl.rows(i).getAttribute("checked");
        if(checker) tbl.deleteRow(i);
    }
//    document.mainForm.cmd.focus() ; 
}


//--------------------------------------------------------------------------------
//테이블의 tr선택
function selectRow(obj)
{
    var selTD = event.srcElement;
    var tbl = this.sharetbl;

    if (selTD.tagName == "TD")
    {
        var selTR = selTD.parentElement;
        if(selTR.rowIndex < 0) return;
        var checker = selTR.getAttribute("checked");

        if (!checker)   selTR.bgColor = "#F9E4D0";
        else selTR.bgColor = "#FFFFFF";

        selTR.checked = !selTR.checked;
    }

}

//--------------------------------------------------------------------------------
//두개이상의 라인이 선택되었는지 검사.
function selectLineCheck() 
{
    var tbl = this.sharetbl;
    var idx = tbl.rows.length;
    var checker = 0 ;
    for (var i=idx-1;i>=0;i--)
    {
        if(tbl.rows(i).getAttribute("checked"))
        {
            checker++ ;
        }
    }
    return checker ; 
}

//선택된라인이 한개이거나 한개도 없다면 메세지를 보여주어라. 
function lineCheckNums()
{
    var breturn = false ;
    
    var checker = selectLineCheck() ; 

    if (checker > 1 )
    {
        alert("한개의 라인만 이동 가능합니다.") ;
        breturn = true ;
    }
    if (checker == 0 )
    {
        alert("선택된 라인이 없습니다.");
         breturn = true ;
    }

    return breturn ;
}

//--------------------------------------------------------------------------------
// 현재 check된 line번호
function lineCheckNumFind()
{
    var ireturn = 0 ;
    var tbl = this.sharetbl;
    var idx = tbl.rows.length;
    for (var i=idx-1;i>=0;i--)
    {
        if(tbl.rows(i).getAttribute("checked"))
        {
            ireturn = i ;
             break ;
        }
    }
    return ireturn ;

}

//--------------------------------------------------------------------------------
//라인이 한개 이상인지 검사.
function lineOneMoreCheck()
{
    var breturn = false ;
    var tbl = this.sharetbl;
    var idx = tbl.rows.length;

    if(idx < 2 )
    {
        breturn = true ;
        alert("움직일 라인이 없습니다.");
    }
    return breturn ;
}

//--------------------------------------------------------------------------------
//라인 up
function LineItemUp()
{
    if(lineOneMoreCheck())  return ;
    if(lineCheckNums() ) return ;

    var idx = lineCheckNumFind() ;

    var tbl = this.sharetbl;
    //idx가 가장 위인지 검사.

    if ( idx < 1 )
    {
        alert("가장위 라인입니다.");
        return ;
    }

    tbl.moveRow(idx,idx-1);

}

//--------------------------------------------------------------------------------
//라인 down
function LineItemDown()
{
    if(lineOneMoreCheck()) return ;

    if(lineCheckNums() ) return ;

    var idx = lineCheckNumFind() ;

    var tbl = this.sharetbl;
    var idxlast = tbl.rows.length;
    //idx가 가장 아래 인지 검사.

    if ( idx == (idxlast - 1)  )
    {
        alert("가장 아래 라인입니다.") ;
        return ;
    }

    tbl.moveRow(idx,idx+1);

}

//테이블에 결재 형태가 선택되었는지 검사
function numapprperson(objid)
{    
    var bType = false ; 
    var obj = eval("document.mainForm."+objid) ; 
    var iLen = document.getElementsByName(objid).length;       
    //alert(iLen) ; 
    if (iLen == 1 ) {
        if(obj.value == "") bType = true ; 

    } else if (iLen > 1) {
        for( i = 0 ; i < iLen ; i++)
        {
            if(obj[i].value == "") bType = true ;                  
        }
    }
    return bType ; 
}

//중복 appruid검사        
function checkapprperson(objid, uidvalue)
{ 
/*
    var buid = false ;
    var obj = eval("document.mainForm."+objid) ; 
    var iLen =  document.getElementsByName(objid).length ;         
    if (iLen == 1) {
        if(obj.value == uidvalue)
        {                
            buid = true ;
        }
    } else if (iLen > 1) {
        for( i = 0 ; i < iLen  ; i++)
        {                
            if(obj[i].value == uidvalue)
            {            
                buid = true ;
                break ;
            }
        }
    }
    return buid ;
*/
    var buid = false ;

    var trId = "user_" + uidvalue;
    var exitTR = document.getElementById(trId);
    if (exitTR != null) buid = true;

    return buid ;
    
}

function doClose()
{
    window.returnValue = "" ;
    window.close(); 
}