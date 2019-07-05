#include <EditConstants.au3>
#include <SendMessage.au3>
#include <Constants.au3>
#include <GUIConstants.au3>
#include <ScrollBarsConstants.au3>






$vBrand = _ADB("shell getprop ro.product.brand")
$vModel = _ADB("shell getprop ro.product.model")
$vAdndroid_Version = _ADB("shell getprop ro.build.version.release")

$form = StringUpper(StringLeft($vBrand, 1)) & StringTrimLeft($vBrand, 1)

;~ MsgBox(64, '' , "Phone connected: " & $form & " " & $vModel & @CRLF & "Android version: " & $vAdndroid_Version )



$vGetSize = _ADB("shell df /system")




#include<Array.au3>

$re = StringRegExp($vGetSize, '\n', 3)
_ArrayDisplay($re)

Exit



MsgBox(64, '' , '')

Func _ADB($vCommand)
	Local $vProcess = "adb.exe"
	$iPID = Run($vProcess & " " & $vCommand, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	$vOutput = ProcessWaitClose($iPID)
	$sOutput = StringStripWS(StdoutRead($iPID), $STR_STRIPLEADING + $STR_STRIPTRAILING)
	ConsoleWrite($sOutput & @CRLF)
	Return $sOutput
EndFunc





#cs
	adb shell df
	adb shell df /system



#ce
