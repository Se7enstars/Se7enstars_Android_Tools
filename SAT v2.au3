#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <String.au3>
;Declare the variables
Global $quot = Chr(34), $gaDropFiles[1], $toInstall[1], $data2show = ""
Global $iItemIndex = 0, $ListView

$GUI_W = 800
$GUI_H = 518
$Form1 = GUICreate("SAT v2.0", $GUI_W, $GUI_H, -1, -1, -1, $WS_EX_ACCEPTFILES)
GUISetBkColor(0xFFFFFF)
$Logo = GUICtrlCreatePic("Data\Logo.jpg", 0, 0, 800, 80, 0x80);, -1, $GUI_WS_EX_PARENTDRAG)
$lSe7enMarket = GUICtrlCreateLabel("Se7en market", 800-93, 62, 100)
GUICtrlSetFont(-1, 10, 5, Default, "Century Gothic")
GUICtrlSetColor(-1, 0x1b1f0e)
GUICtrlSetCursor(-1, 0)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)


$HandleListView = GUICtrlCreateListView("", 0, 80, 800, 271, BitOR($LVS_REPORT, $LVS_SHOWSELALWAYS), $WS_EX_WINDOWEDGE)
GUICtrlSetState($HandleListView, $GUI_DROPACCEPTED)
$ListView = GUICtrlGetHandle($HandleListView)
_GUICtrlListView_SetExtendedListViewStyle($ListView, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES, $LVS_EX_SUBITEMIMAGES, $LVS_EX_DOUBLEBUFFER))
$hImage = _GUIImageList_Create(16, 16, 5, 3)
	_GUIImageList_AddIcon($hImage, "Data\app.ico")
	_GUIImageList_AddIcon($hImage, "Data\storage.ico")
	_GUIImageList_AddIcon($hImage, "Data\version.ico")
	_GUIImageList_AddIcon($hImage, "Data\updated.ico")
	_GUIImageList_AddIcon($hImage, "Data\path.ico")
	_GUICtrlListView_SetImageList($ListView, $hImage, 1)
	; Add columns
	_GUICtrlListView_AddColumn($ListView, "Application", 255)
	_GUICtrlListView_AddColumn($ListView, "Size", 90)
	_GUICtrlListView_AddColumn($ListView, "Version", 75)
	_GUICtrlListView_AddColumn($ListView, "Updated", 100)
	_GUICtrlListView_AddColumn($ListView, "Location", (800-250-90-60-120))
_GUICtrlListView_RegisterSortCallBack($HandleListView)

$bSelect = GUICtrlCreateIcon("Data\check.ico", 0, 0, (271+80+2), 24, 24)
$bSelectState = 0
GUICtrlSetCursor(-1, 0)
$bAdd = GUICtrlCreateIcon("Data\add.ico", 0, 26, (271+80+2), 24, 24)
GUICtrlSetCursor(-1, 0)
GUICtrlSetTip(-1, "Add files to list")
$bClear = GUICtrlCreateIcon("Data\clear.ico", 0, 52, (271+80+2), 24, 24)
GUICtrlSetTip(-1, "Clear checked files from list")
GUICtrlSetCursor(-1, 0)
$bInstall = GUICtrlCreateIcon("Data\install.ico", 0, ($GUI_W/2)-24, $GUI_H-62, 48, 48)
GUICtrlSetTip(-1, "Install selected apps")
GUICtrlSetCursor(-1, 0)

$Progress = GUICtrlCreatePic("Data\progress5.jpg", 0, $GUI_H-10, $GUI_W, 10, 0x80)
$ProgressLable = GUICtrlCreateLabel("100%", $GUI_W/2-15, $GUI_H-12, 30, 11)
GUICtrlSetFont(-1, 8, 500, Default)
GUICtrlSetColor(-1, 0x1b1f0e)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
_Progress($Progress, 25)

GUIRegisterMsg($WM_DROPFILES, "WM_DROPFILES_FUNC")
GUISetState(@SW_SHOW)

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case $bSelect
			If $bSelectState = 0 Then
				GUICtrlSetImage($bSelect, "Data\uncheck.ico")
				$bSelectState = 1
			Else
				GUICtrlSetImage($bSelect, "Data\check.ico")
				$bSelectState = 0
			EndIf
		Case $GUI_EVENT_CLOSE
			_GUICtrlListView_UnRegisterSortCallBack($HandleListView)
			GUIDelete()
			Exit
		Case $HandleListView
			_GUICtrlListView_SortItems($HandleListView, GUICtrlGetState($HandleListView))
		Case $GUI_EVENT_DROPPED
            ;Check if the Array have an empty value and delete it, otherwise I got empty string in position [0] of the array.
            If $toInstall[0] == "" Then
                _ArrayDelete($toInstall, 0)
            EndIf
            ;StringExplode and ArrayPop here is to get Filename only, because DllStructGetData() return a full path of the droped file.
            For $i = 0 To UBound($gaDropFiles) - 1
                $splo = _StringExplode($gaDropFiles[$i], "\", 0)
                $endrray = _ArrayPop($splo)
                $filename = $endrray
                $data2show &= "|" & $filename ; Populate $data2show with FileNames only because that is what I want to show.
				$tFileSize = Round((FileGetSize($gaDropFiles[$i])/1024)/1024, 1) & "MB"
				$tFileVer = FileGetVersion($gaDropFiles[$i])
				$tFileDate = FileGetTime($gaDropFiles[$i], 1, 0)
				$tFilePath = $gaDropFiles[$i]
				_AddItemToList($filename, $tFileSize, $tFileVer, $tFileDate[2]&'.'&$tFileDate[1]&'.'&$tFileDate[0], $tFilePath, $iItemIndex)
				$iItemIndex +=1
                _ArrayAdd($toInstall, $gaDropFiles[$i])
            Next
	EndSwitch
WEnd

Func _Progress($hWnd, $hData)
	GUICtrlSetPos($hWnd, Default, Default, $hData*$GUI_W/100)
EndFunc

Func _AddItemToList($iApp, $iSize, $iVer, $iDate, $iPath, $iIndex)
	_GUICtrlListView_AddItem($ListView, $iApp, 0); hWnd, Text, Icon
	_GUICtrlListView_AddSubItem($ListView, $iIndex, $iSize, 1, 1); hWnd, Index, Text, SubItem_Index, Icon
	_GUICtrlListView_AddSubItem($ListView, $iIndex, $iVer, 2, 2)
	_GUICtrlListView_AddSubItem($ListView, $iIndex, $iDate, 3, 3)
	_GUICtrlListView_AddSubItem($ListView, $iIndex, $iPath, 4, 4)
	_GUICtrlListView_SetItemChecked($ListView, $iIndex)
EndFunc


Func WM_DROPFILES_FUNC($hWnd, $msgID, $wParam, $lParam)
    Local $nSize, $pFileName
    Local $nAmt = DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $wParam, "int", 0xFFFFFFFF, "ptr", 0, "int", 255)
    For $i = 0 To $nAmt[0] - 1
        $nSize = DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $wParam, "int", $i, "ptr", 0, "int", 0)
        $nSize = $nSize[0] + 1
        $pFileName = DllStructCreate("char[" & $nSize & "]")
        DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $wParam, "int", $i, "ptr", DllStructGetPtr($pFileName), "int", $nSize)
        ReDim $gaDropFiles[$i + 1]
        $gaDropFiles[$i] = DllStructGetData($pFileName, 1)
        $pFileName = 0
    Next
EndFunc   ;==>WM_DROPFILES_FUNC
