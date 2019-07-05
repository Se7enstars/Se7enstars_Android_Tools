#Region
#AutoIt3Wrapper_Icon=drmobileico.ico
#EndRegion

#NoTrayIcon
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <String.au3>
#include <ProgressConstants.au3>
#include <Constants.au3>
#include <ComboConstants.au3>

; Adding Files inside final EXE and Copy that files to Windows Temp Dir if Needed.
If Not FileExists(@TempDir & "\adb.exe") Then
    FileCopy("adb.exe", @TempDir & "\adb.exe", 1)
EndIf
If Not FileExists(@TempDir & "\AdbWinApi.dll") Then
    FileCopy("AdbWinApi.dll", @TempDir & "\AdbWinApi.dll", 1)
EndIf
If Not FileExists(@TempDir & "\AdbWinUsbApi.dll") Then
    FileCopy("AdbWinUsbApi.dll", @TempDir & "\AdbWinUsbApi.dll", 1)
EndIf
;~ If Not FileExists(@TempDir & "\logo.jpg") Then
    FileCopy("logo.jpg", @TempDir & "\logo.jpg", 1)
;~ EndIf

;Declare the variables I will use with global scope
Global $quot = Chr(34), $gaDropFiles[1], $toInstall[1], $data2show = ""
Global $KillADB = 1, $Light = 0, $GrWait[3]
;Declare a Constant for FileOpenDialog Func.
Global Const $sMessage = "Select the APK files you want to install"

; The GUI Stuff
#Region ### START Koda GUI section ###
$Form1_1 = GUICreate("Se7enstars Android Tools", 500, 320, -1, -1, -1, $WS_EX_ACCEPTFILES)
GUISetBkColor(0xFFFFFF)
GUISetIcon(@SystemDir&'\shell32.dll', 44)
$Pic1 = GUICtrlCreatePic(@TempDir & "\logo.jpg", 0, 0, 500, 50)
$Devlist = GUICtrlCreateCombo("List of devices attached", 5, 55, 180, 20, $CBS_DROPDOWNLIST + $WS_VSCROLL)
$DevUpButton = GUICtrlCreateButton("Check Devices", 200, 54, 85, 22)
$WithAdbKill = GUICtrlCreateCheckbox("Kill ADB", 300, 55, 70, 20)
GUICtrlSetTip($WithAdbKill, "Kill all ADB connected devices!!!")
GUICtrlSetState($WithAdbKill, 1)

$GrWait[0] = GUICtrlCreateGraphic(380, 59, 12, 12, 0) ; квадрат
GUICtrlSetBkColor($GrWait[0], 0xff0000)

$GrWait[1] = GUICtrlCreateGraphic(398, 59, 12, 12, 0) ; квадрат
GUICtrlSetBkColor($GrWait[1], 0xffcc00)

$GrWait[2] = GUICtrlCreateGraphic(416, 59, 12, 12, 0) ; квадрат
GUICtrlSetBkColor($GrWait[2], 0x00ff00)

$List1 = GUICtrlCreateList("", 16, 120, 340, 170)
GUICtrlSetState($List1, $GUI_DROPACCEPTED)
GUIRegisterMsg($WM_DROPFILES, "WM_DROPFILES_FUNC")
$Button1 = GUICtrlCreateButton("Install", 368, 240, 100, 40)
$Button2 = GUICtrlCreateButton("Add Files", 368, 120, 100, 40)
$Button3 = GUICtrlCreateButton("Delete All", 368, 165, 100, 40)
$Label1 = GUICtrlCreateLabel("Add or Drop the files you want to install", 17, 101, 327, 17)

$Label2 = GUICtrlCreateLabel("Progress:", 16, 293, 327, 17)
$pgres = GUICtrlCreateProgress(66, 290, 290, 20, $PBS_SMOOTH)

GUICtrlSetBkColor(-1, 0xFFFBF0)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
    $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $GUI_EVENT_CLOSE
            ;Check if this File exist what means server probably running so I shutdown the server.
            ;I do this because if you have another instance of ADB running sometime when ADB try to start again cant kill the old server instance.
            If FileExists(@TempDir & "\adb.exe") Then
                    Run(@ComSpec & " /c " & @TempDir & "\adb.exe " & "kill-server", "", @SW_HIDE)
                Exit
            Else
                Exit
            EndIf

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
                _ArrayAdd($toInstall, $gaDropFiles[$i])
            Next
            GUICtrlSetData($List1, $data2show)

        Case $Button1 ; Button "Install"
            If $data2show == "" Then
                MsgBox($MB_ICONERROR, "Error", "The list is empty, please add files to install")
            Else
				GUICtrlSetData($Label2, "Instaling...")
                $installcount = UBound($toInstall)
                For $i = 0 To UBound($toInstall) - 1
                    If StringInStr($toInstall[$i], " ") Then
                        ;Using Run here and not RunWait because I will use $STDOUT_CHILD in the future for error handling base on the final output.
                        $instpid = Run(@ComSpec & " /c " & @TempDir & "\adb.exe install -r " & $quot & $toInstall[$i] & $quot, "", @SW_HIDE)
                        ;Here The Progress Bar, I want to improve this, maybe: (100 / $installcount) then that result will be 100 for that cycle and then
                        ;increment that with base 10 so the Progress dont stop moving during one element install.
                        While ProcessExists($instpid)
                            Sleep(500)
                        WEnd
                        GUICtrlSetData($pgres, GUICtrlRead($pgres) + (100 / $installcount))
                    Else
                        $instpid = Run(@ComSpec & " /c " & @TempDir & "\adb.exe install -r " & $toInstall[$i], "", @SW_HIDE)
                        While ProcessExists($instpid)
                            Sleep(500)
                        WEnd
                        GUICtrlSetData($pgres, GUICtrlRead($pgres) + (100 / $installcount))
                    EndIf
					GUICtrlSetData($Label2, "Progress...")
                Next
					SoundPlay(@ScriptDir & "\Ready.wav")
                    MsgBox($MB_ICONINFORMATION, "GOOD", "Process Done")
            EndIf

        Case $Button2 ; Button "Add Files":
            Local $sFileOpenDialog = FileOpenDialog($sMessage, @WindowsDir & "\", "APK Files (*.apk)", $FD_FILEMUSTEXIST + $FD_MULTISELECT)
            $split = StringSplit($sFileOpenDialog,"|")
            ;Here I check if the Array only have two element because that mean we only add one file
            ;Array[0] have number of element on the array,Array[1] Full path to file so I need to do StringExplode and ArrayPop again to get FileName
            If UBound($split) == 2 Then
                If $toInstall[0] == "" Then
                    _ArrayDelete($toInstall, 0)
                    _ArrayAdd($toInstall,$split[1])
                    $split2 = _StringExplode($split[1],"\")
                    $endarray = _ArrayPop($split2)
                    $data2show &= "|" & $endarray
                Else
                    _ArrayAdd($toInstall,$split[1])
                    $split2 = _StringExplode($split[1],"\")
                    $endarray = _ArrayPop($split2)
                    $data2show &= "|" & $endarray
                EndIf

            Else
                ; Here I only need to get FullPath because the file names come in next elements is how FileOpenDialog() do it.
                $tpath = $split[1]
                If $toInstall[0] == "" Then
                    _ArrayDelete($toInstall, 0)
                EndIf

            EndIf
            ; Like I said from array[2] to the end are the File names.
            For $i = 2 to UBound($split) -1
                _ArrayAdd($toInstall, $tpath & "\" & $split[$i])
                $data2show &= "|" & $split[$i]
            Next
                GUICtrlSetData($List1, $data2show)

        Case $Button3 ;Button "Delete All"
            ; I clear all the Variables and the List in the Gui too
            $toInstall = 0
            Global $toInstall[1]
            $data2show = ""
            GUICtrlSetData($pgres,0)
            GUICtrlSetData($List1, $data2show)
		Case $WithAdbKill
			If GUICtrlRead($WithAdbKill) = $GUI_CHECKED Then
				$KillADB = 1
			Else
				$KillADB = 0
			EndIf
		Case $DevUpButton
			$ti = TimerInit()
			AdlibRegister("_Waiting", 250)
			GUICtrlSetData($DevUpButton, "Checking...")
			If $KillADB = 1 Then
				Run(@ComSpec & " /c " & @TempDir & "\adb.exe " & "kill-server", "", @SW_HIDE)
				Sleep(50)
				GUICtrlSetData($Label2, "Updating...")
				_UpdateDeviceList()
				GUICtrlSetData($Label2, "Progress...")
			Else
				GUICtrlSetData($Label2, "Updating...")
				_UpdateDeviceList()
				GUICtrlSetData($Label2, "Progress...")
            EndIf
			GUICtrlSetData($DevUpButton, "Check Devices")
			AdlibUnRegister("_Waiting")
			$ti = 0
			For $i = 0 To UBound($GrWait)-1
				GUICtrlSetBkColor($GrWait[$i], 0x00ff00)
			Next
		Case $Pic1
			MsgBox(64, "Info", "Se7enstars Android Tools  v.1.10"&@LF&"Created by O'SRB - Se7enstars™ Inc."&@LF&"Updated: 25.02.2018"&@LF&"Tajikistan, Gissar, Saydiyon", 0, $Form1_1)
    EndSwitch
WEnd

Func _UpdateDeviceList()
	Local $nDevList = ""
	$pid =  Run(@ComSpec & " /c " & @TempDir & "\adb.exe devices", "", @SW_HIDE, $STDOUT_CHILD)
	ProcessWaitClose($pid)
	$text = StringSplit(StdoutRead($pid), @LF)
	For $i=4 To $text[0]
		$nDevList &= $text[$i] & "|"
	Next
	GUICtrlSetData($Devlist, "|")
	GUICtrlSetData($Devlist, "List of devices attached...")
	GUICtrlSetData($Devlist, $nDevList, "List of devices attached...")
EndFunc

Func _Waiting()
	If TimerDiff($ti) >= 1000 Then
		If $Light = 1 Then
			$Light = 0
			$ti = 1
			For $i = 0 To UBound($GrWait)-1
				GUICtrlSetBkColor($GrWait[$i], 0xff0000)
			Next
		Else
			$Light = 1
			$ti = 0
			For $i = 0 To UBound($GrWait)-1
				GUICtrlSetBkColor($GrWait[$i], 0x00ff00)
			Next
		EndIf
	EndIf
EndFunc

;Func _IsValidExt($sPath)
;   For $i = 1 To $FilesAllowedMask[0]
;      If StringRight($sPath, 4) = $FilesAllowedMask[$i] And _
;          Not StringInStr(FileGetAttrib($sPath), $FilesAllowedMask[$i]) Then Return True
; Next
;Return False
;EndFunc

; This Func is from the Forum and I need to improve it to support Unicode Char for example file names with Accute,
; I think there is another func arround the forum that support Unicode characters.
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