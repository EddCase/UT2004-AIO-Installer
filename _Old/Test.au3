#cs ----------------------------------------------------------------------------

	 AutoIt Version: 3.3.18.0
	 Author:         Edd

	 Script Function:
		Get Required Files for MyUT2004 AIO Installer

#ce ----------------------------------------------------------------------------


#cs ----------------------------------------------------------------------------
;Needed Tools, Grabbed compiled binaries from OLDUnreal Installer Files Saved in
_Tools

7zip
UnSheild

7Zip Extract ISO


UnShield Cab Extraction


#ce ----------------------------------------------------------------------------
#include <File.au3>

$ISO = @ScriptDir & "\_ISO\UT2004.iso"
$ISO_TEMP = @ScriptDir & "\ISO_Extracted"
$7zip = @ScriptDir & "\_Tools\7z.exe"
$Unshield = @ScriptDir & "\_Tools\unshield.exe"
$UT2004_Temp = @ScriptDir & "\UT2004_Temp"



If FileExists ($ISO) = 1 Then
	Extract()
Else
	TrayTip ("Unreal Tournament 2004", "UT2004.ISO Downloading", 10, 1)
	InetGet ("https://files.oldunreal.net/UT2004.ISO", $ISO, 0, 0)
	Extract()
EndIf


Func Extract()
	If FileExists ($ISO) = 1 Then
		Local $7zipParameters = 'x "' & $ISO & '" -o"' & $ISO_TEMP & '"'
		ShellExecuteWait ($7zip, $7zipParameters)
	Else
		MsgBox (0, "Error", "UT2004.iso Missing Cannot Continue")
		Exit
	EndIf

	If FileExists ($ISO_TEMP & "\AutoRun.exe") = 1 Then
		CabExpand()
	EndIf
EndFunc

Func CabExpand()
	Local $aDirs = _FileListToArray ($ISO_TEMP, "*", 2, 1)
	;_ArrayDisplay ($aDirs)

	;Find the CabFiles and extract the contents
	Local $n = 1
	Do
		;Search Dirs for Cab files to extract, give them the full path
		Local $Cab = FileFindFirstFile ($aDirs[$n] & "\*.cab")
		$Cab = FileFindNextFile ($Cab)
		$Cab = $aDirs[$n] & "\" & $Cab
		Local $UnShieldParameters = '-d "' & $UT2004_Temp & '" x "' & $Cab & '"'
		ShellExecuteWait ($Unshield, $UnShieldParameters)

		$n = $n + 1
		FileClose ($Cab)
	Until $aDirs[0] = $n - 1



EndFunc
