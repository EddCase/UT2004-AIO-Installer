# Fixes to Apply to UT2004_Installer_v0.3.0-alpha.au3

## 1. Add StringRepeat Helper Function
Add this BEFORE the InitializeLog() function in the Utility Functions region:

```autoit
Func StringRepeat($sChar, $iCount)
	; WHAT: Repeat a character multiple times
	; WHY: AutoIt doesn't have built-in string repeat
	; HOW: Loop and concatenate
	Local $sResult = ""
	For $i = 1 To $iCount
		$sResult &= $sChar
	Next
	Return $sResult
EndFunc
```

## 2. Fix TrayTip Spamming in DownloadFileWithProgress
FIND (around line 740):
```autoit
UpdateStatus("Downloading: " & $sMB & " MB / " & $sTotalMB & " MB (" & $sPercent & "%)")
```

REPLACE WITH:
```autoit
; Update status label only (no TrayTip spam)
GUICtrlSetData($g_idLabelStatus, "Downloading: " & $sMB & " MB / " & $sTotalMB & " MB (" & $sPercent & "%)")
```

ALSO FIND (around line 750):
```autoit
UpdateStatus("Downloading: " & $sMB & " MB...")
```

REPLACE WITH:
```autoit
; Update status label only (no TrayTip spam)
GUICtrlSetData($g_idLabelStatus, "Downloading: " & $sMB & " MB...")
```

## 3. Add TrayTip Only at Milestones
IN Phase2_DownloadISO(), AFTER successful download, ADD:
```autoit
TrayTip("UT2004 Installer", "ISO downloaded successfully", 3, 1)
```

## 4. Update Tool Paths for 7za instead of 7z
FIND in Global Variables:
```autoit
Global $g_s7Zip = @ScriptDir & "\Tools\7z.exe"
```

REPLACE WITH:
```autoit
Global $g_s7Zip = @ScriptDir & "\Tools\7za.exe"
```

## 5. Update FileInstall Section for Correct Tools
FIND in ExtractBundledTools():
```autoit
; FileInstall("Tools\7z.exe", @ScriptDir & "\Tools\7z.exe", 1)
; FileInstall("Tools\7z.dll", @ScriptDir & "\Tools\7z.dll", 1)
```

REPLACE WITH:
```autoit
; FileInstall("Tools\7za.exe", @ScriptDir & "\Tools\7za.exe", 1)
; FileInstall("Tools\7za.dll", @ScriptDir & "\Tools\7za.dll", 1)
```

## 6. Epic Games TOS - Add License Agreement Screen
This needs to be shown BEFORE installation starts. Add a new function and call it from OnInstallClicked() BEFORE validation.

```autoit
Func ShowLicenseAgreement()
	; WHAT: Show Epic Games Terms of Service
	; WHY: Required for legal distribution
	; HOW: Display TOS, require acceptance
	
	Local $sMessage = "Welcome! You are about to install Unreal Tournament 2004 ECE." & @CRLF & @CRLF & _
		"The Epic Games Terms of Service apply to the use and distribution of the game." & @CRLF & _
		"Please read the terms of service carefully:" & @CRLF & _
		"https://legal.epicgames.com/en-US/epicgames/tos" & @CRLF & @CRLF & _
		"This software is provided for personal, non-commercial use only and is distributed free of charge. " & _
		"All game content, trademarks, and intellectual property remain the property of their respective owners, including Epic Games, Inc." & @CRLF & @CRLF & _
		"This game requires approximately 15 GB of disk space." & @CRLF & @CRLF & _
		"Game data and patches will be downloaded from the Internet." & @CRLF & @CRLF & _
		"Do you accept the Epic Games Terms of Service?"
	
	Local $iResponse = MsgBox(36, "Terms of Service", $sMessage)  ; 36 = Yes/No with Question icon
	
	If $iResponse = 7 Then  ; 7 = No
		Return False  ; User declined
	EndIf
	
	Return True  ; User accepted
EndFunc
```

Then in OnInstallClicked(), ADD at the very start (before path validation):
```autoit
; Show and require acceptance of TOS
If Not ShowLicenseAgreement() Then
	Return  ; User declined TOS
EndIf
```

## AutoIt License
You don't NEED to include AutoIt license in your installer because:
- AutoIt itself is freeware
- Compiled AutoIt executables can be distributed freely
- No attribution required (though it's nice to mention)

BUT if you want to credit it, you can add to README or in an About dialog.
