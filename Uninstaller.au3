#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=UT2004.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=UT2004 Uninstaller
#AutoIt3Wrapper_Res_Description=UT2004 Uninstaller
#AutoIt3Wrapper_Res_Fileversion=0.6.3.0
#AutoIt3Wrapper_Res_ProductVersion=0.6.3
#AutoIt3Wrapper_Res_CompanyName=Community Project
#AutoIt3Wrapper_Res_LegalCopyright=MIT License
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; ============================================================================
; UT2004 Uninstaller
; ============================================================================
;
;	AutoIt Version: 3.3.16.1
;	Author:         EddCase
;	Version:        0.6.3
;	
;	Script Function:
;		Uninstall Unreal Tournament 2004
;		Remove all files, registry entries, shortcuts, and file associations
;
; ============================================================================

#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include <File.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>

; Require admin rights for registry/file operations
#RequireAdmin

; ============================================================================
; CONFIGURATION
; ============================================================================

; UT2004 Color Scheme
Global Const $COLOR_BG_DARK = 0x1a1a1a      ; Very dark gray (main background)
Global Const $COLOR_BG_MID = 0x2a2a2a       ; Mid-dark gray (panels)
Global Const $COLOR_UT_ORANGE = 0xFF8C00    ; UT2004 signature orange
Global Const $COLOR_TEXT = 0xE0E0E0         ; Light gray text
Global Const $COLOR_TEXT_DIM = 0x808080     ; Dimmed text for hints

; ============================================================================
; MAIN
; ============================================================================

Main()

Func Main()
	; Check if we're already running from temp
	; WHAT: Detect if this is the temp copy or original
	; WHY: Avoid infinite loop of copying
	; HOW: Check if script is in temp directory
	Local $bRunningFromTemp = (StringInStr(@ScriptDir, @TempDir) > 0)
	
	If Not $bRunningFromTemp Then
		; We're running from the game directory - copy to temp and restart
		; WHAT: Copy self to temp and execute from there
		; WHY: Can't delete game folder while running from it
		; HOW: FileCopy to temp, Run, Exit
		
		Local $sTempUninstaller = @TempDir & "\UT2004_Uninstaller.exe"
		FileCopy(@ScriptFullPath, $sTempUninstaller, 1)
		
		If FileExists($sTempUninstaller) Then
			Run($sTempUninstaller)
			Exit  ; Exit the original
		Else
			MsgBox($MB_ICONERROR, "Error", "Failed to copy uninstaller to temp directory.")
			Exit 1
		EndIf
	EndIf
	
	; Now we're running from temp - proceed with uninstall
	
	; Get install path from registry
	Local $sInstallPath = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Unreal Technology\Installed Apps\UT2004", "Folder")
	
	If @error Or $sInstallPath = "" Then
		; Try 64-bit location
		$sInstallPath = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Unreal Technology\Installed Apps\UT2004", "Folder")
		
		If @error Or $sInstallPath = "" Then
			MsgBox($MB_ICONERROR, "Uninstaller Error", "Could not find UT2004 installation in registry." & @CRLF & @CRLF & _
					"The game may already be uninstalled.")
			Exit 1
		EndIf
	EndIf
	
	; Verify installation exists
	If Not FileExists($sInstallPath) Then
		MsgBox($MB_ICONWARNING, "Installation Not Found", "UT2004 installation not found at:" & @CRLF & @CRLF & _
				$sInstallPath & @CRLF & @CRLF & _
				"The installation folder has been deleted, but registry entries may remain." & @CRLF & @CRLF & _
				"Click OK to clean up registry and shortcuts.")
	EndIf
	
	; Show uninstall GUI
	Local $aOptions = ShowUninstallGUI($sInstallPath)
	
	If $aOptions[0] = False Then
		; User cancelled
		Exit 0
	EndIf
	
	; Extract options
	Local $bCleanTemp = $aOptions[1]
	Local $bKeepSettings = $aOptions[2]
	
	; Perform uninstallation
	PerformUninstall($sInstallPath, $bCleanTemp, $bKeepSettings)
	
	; Success message
	MsgBox($MB_ICONINFORMATION, "Uninstall Complete", "Unreal Tournament 2004 has been successfully uninstalled!" & @CRLF & @CRLF & _
			"Thank you for playing UT2004!")
	
	; Delete the uninstaller itself
	SelfDelete()
EndFunc

Func ShowUninstallGUI($sInstallPath)
	; WHAT: Show GUI asking user to confirm uninstall and select options
	; WHY: User needs to confirm and choose what to keep
	; HOW: Create themed GUI with checkboxes
	; RETURN: Array [0]=Continue (bool), [1]=CleanTemp (bool), [2]=KeepSettings (bool)
	
	Local $hGUI = GUICreate("Uninstall UT2004", 500, 300, -1, -1, BitOR($WS_CAPTION, $WS_SYSMENU))
	GUISetBkColor($COLOR_BG_DARK, $hGUI)
	GUISetState(@SW_SHOW, $hGUI)
	WinActivate($hGUI)  ; Bring to front but allow other windows on top
	
	; Title
	Local $idTitle = GUICtrlCreateLabel("Uninstall Unreal Tournament 2004", 20, 20, 460, 30, $SS_CENTER)
	GUICtrlSetFont(-1, 14, 800)
	GUICtrlSetColor(-1, $COLOR_UT_ORANGE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	
	; Install path label
	GUICtrlCreateLabel("Installation location:", 20, 65, 460, 20)
	GUICtrlSetColor(-1, $COLOR_TEXT)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	
	; Install path value
	GUICtrlCreateLabel($sInstallPath, 20, 85, 460, 20)
	GUICtrlSetColor(-1, $COLOR_TEXT_DIM)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	
	; Warning message
	GUICtrlCreateLabel("This will remove all game files, registry entries, shortcuts, and file associations.", 20, 115, 460, 40)
	GUICtrlSetColor(-1, $COLOR_TEXT)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	
	; Options section
	GUICtrlCreateLabel("Cleanup Options:", 20, 165, 460, 20)
	GUICtrlSetFont(-1, 10, 600)
	GUICtrlSetColor(-1, $COLOR_UT_ORANGE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	
	; Clean temp folder checkbox
	Local $idCheckCleanTemp = GUICtrlCreateCheckbox("", 40, 190, 20, 20)
	GUICtrlSetState(-1, $GUI_CHECKED)
	
	; Clean temp folder label
	Local $idLabelCleanTemp = GUICtrlCreateLabel("Clean temporary installer files", 65, 192, 415, 20)
	GUICtrlSetColor(-1, $COLOR_TEXT)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	
	; Keep settings checkbox
	Local $idCheckKeepSettings = GUICtrlCreateCheckbox("", 40, 215, 20, 20)
	GUICtrlSetState(-1, $GUI_CHECKED)
	
	; Keep settings label
	Local $idLabelKeepSettings = GUICtrlCreateLabel("Keep user settings and saved games", 65, 217, 415, 20)
	GUICtrlSetColor(-1, $COLOR_TEXT)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	
	; Buttons - RIGHT ALIGNED
	Local $idBtnCancel = GUICtrlCreateButton("Cancel", 360, 250, 120, 35)
	GUICtrlSetFont(-1, 10)
	GUICtrlSetBkColor(-1, $COLOR_BG_MID)
	
	Local $idBtnUninstall = GUICtrlCreateButton("Uninstall", 230, 250, 120, 35)
	GUICtrlSetFont(-1, 10, 600)
	GUICtrlSetColor(-1, $COLOR_BG_DARK)
	GUICtrlSetBkColor(-1, $COLOR_UT_ORANGE)
	
	; Event loop
	Local $bContinue = False
	Local $bCleanTemp = False
	Local $bKeepSettings = False
	
	While True
		Local $iMsg = GUIGetMsg()
		
		Switch $iMsg
			Case $GUI_EVENT_CLOSE, $idBtnCancel
				; User cancelled
				GUIDelete($hGUI)
				Local $aResult[3] = [False, False, False]
				Return $aResult
			
			Case $idLabelCleanTemp
				; Toggle clean temp checkbox when label clicked
				If GUICtrlRead($idCheckCleanTemp) = $GUI_CHECKED Then
					GUICtrlSetState($idCheckCleanTemp, $GUI_UNCHECKED)
				Else
					GUICtrlSetState($idCheckCleanTemp, $GUI_CHECKED)
				EndIf
			
			Case $idLabelKeepSettings
				; Toggle keep settings checkbox when label clicked
				If GUICtrlRead($idCheckKeepSettings) = $GUI_CHECKED Then
					GUICtrlSetState($idCheckKeepSettings, $GUI_UNCHECKED)
				Else
					GUICtrlSetState($idCheckKeepSettings, $GUI_CHECKED)
				EndIf
				
			Case $idBtnUninstall
				; Get checkbox states
				$bCleanTemp = (GUICtrlRead($idCheckCleanTemp) = $GUI_CHECKED)
				$bKeepSettings = (GUICtrlRead($idCheckKeepSettings) = $GUI_CHECKED)
				
				; Confirm
				Local $iConfirm = MsgBox($MB_YESNO + $MB_ICONWARNING, "Confirm Uninstall", _
						"Are you sure you want to uninstall UT2004?" & @CRLF & @CRLF & _
						"This action cannot be undone.")
				
				If $iConfirm = $IDYES Then
					$bContinue = True
					GUIDelete($hGUI)
					Local $aResult[3] = [$bContinue, $bCleanTemp, $bKeepSettings]
					Return $aResult
				EndIf
		EndSwitch
	WEnd
EndFunc

Func PerformUninstall($sInstallPath, $bCleanTemp, $bKeepSettings)
	; WHAT: Perform the actual uninstallation
	; WHY: Remove all traces of UT2004
	; HOW: Delete files, registry, shortcuts, file associations
	
	; Show progress
	ProgressOn("Uninstalling UT2004", "Removing game files...", "0%")
	
	; Step 1: Delete game files
	ProgressSet(10, "Deleting game files...")
	If FileExists($sInstallPath) Then
		DirRemove($sInstallPath, 1)  ; 1 = recursive delete
		
		If FileExists($sInstallPath) Then
			; Files still exist - likely in use
			ProgressOff()
			Local $iRetry = MsgBox($MB_ICONWARNING + $MB_RETRYCANCEL, "Files In Use", _
					"Some files could not be deleted:" & @CRLF & @CRLF & _
					$sInstallPath & @CRLF & @CRLF & _
					"These files may be in use." & @CRLF & @CRLF & _
					"Please close any running UT2004 processes (UT2004.exe, UCC.exe, etc.) and click Retry." & @CRLF & @CRLF & _
					"Click Cancel to skip file deletion and continue with uninstall.")
			
			If $iRetry = $IDRETRY Then
				; User wants to try again
				ProgressOn("Uninstalling UT2004", "Removing game files...", "10%")
				DirRemove($sInstallPath, 1)
				
				If FileExists($sInstallPath) Then
					; Still failed
					ProgressOff()
					MsgBox($MB_ICONWARNING, "Manual Deletion Required", _
							"Files still could not be deleted." & @CRLF & @CRLF & _
							"You will need to manually delete:" & @CRLF & _
							$sInstallPath & @CRLF & @CRLF & _
							"Continuing with registry and shortcut cleanup...")
					ProgressOn("Uninstalling UT2004", "Continuing cleanup...", "10%")
				EndIf
			EndIf
		EndIf
	EndIf
	
	; Step 2: Remove registry entries
	ProgressSet(30, "Removing registry entries...")
	RemoveRegistryEntries()
	
	; Step 3: Remove file associations
	ProgressSet(50, "Removing file associations...")
	RemoveFileAssociations()
	
	; Step 4: Delete shortcuts
	ProgressSet(70, "Deleting shortcuts...")
	DeleteShortcuts()
	
	; Step 5: Clean temp folder
	If $bCleanTemp Then
		ProgressSet(80, "Cleaning temporary files...")
		Local $sTempDir = @TempDir & "\UT2004_Install"
		If FileExists($sTempDir) Then
			DirRemove($sTempDir, 1)
		EndIf
	EndIf
	
	; Step 6: Handle user settings
	If Not $bKeepSettings Then
		ProgressSet(90, "Removing user settings...")
		Local $sSettingsDir = @MyDocumentsDir & "\My Games\UT2004"
		If FileExists($sSettingsDir) Then
			DirRemove($sSettingsDir, 1)
		EndIf
	EndIf
	
	ProgressSet(100, "Complete!", "Uninstall finished")
	Sleep(500)
	ProgressOff()
EndFunc

Func RemoveRegistryEntries()
	; WHAT: Remove all UT2004 registry entries
	; WHY: Clean uninstall
	; HOW: Delete registry keys from both 32-bit and 64-bit locations
	
	; Remove from WOW6432Node (32-bit view on 64-bit Windows)
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Unreal Technology\Installed Apps\UT2004")
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\UT2004_Community")
	
	; Remove from normal location (64-bit view) 
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Unreal Technology\Installed Apps\UT2004")
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\UT2004_Community")
	
	; Try to remove parent keys if empty
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Unreal Technology\Installed Apps")
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Unreal Technology")
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Unreal Technology\Installed Apps")
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Unreal Technology")
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Unreal Technology")
EndFunc

Func RemoveFileAssociations()
	; WHAT: Remove file associations created by installer
	; WHY: Clean uninstall
	; HOW: Delete registry keys for ut2004:// protocol and .ut4mod files
	
	; Remove ut2004:// protocol
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\ut2004")
	
	; Remove .ut4mod file association
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.ut4mod")
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\UT2004.Mod")
EndFunc

Func DeleteShortcuts()
	; WHAT: Delete desktop and start menu shortcuts
	; WHY: Clean uninstall
	; HOW: Delete .lnk files
	
	; Desktop shortcut
	Local $sDesktopShortcut = @DesktopDir & "\UT2004.lnk"
	If FileExists($sDesktopShortcut) Then
		FileDelete($sDesktopShortcut)
	EndIf
	
	; Start Menu folder
	Local $sStartMenuFolder = @StartMenuDir & "\Unreal Tournament 2004"
	If FileExists($sStartMenuFolder) Then
		DirRemove($sStartMenuFolder, 1)
	EndIf
	
	; Also try common start menu location
	Local $sCommonStartMenu = @ProgramsCommonDir & "\Unreal Tournament 2004"
	If FileExists($sCommonStartMenu) Then
		DirRemove($sCommonStartMenu, 1)
	EndIf
EndFunc

Func SelfDelete()
	; WHAT: Delete the uninstaller itself
	; WHY: Complete cleanup - don't leave uninstaller behind
	; HOW: Create batch file that waits for process to end, then deletes
	
	; Create batch file in temp directory
	Local $sBatchFile = @TempDir & "\ut2004_uninstall_cleanup.bat"
	
	Local $sBatchContent = "@echo off" & @CRLF & _
			"echo Cleaning up uninstaller..." & @CRLF & _
			"timeout /t 2 /nobreak >nul" & @CRLF & _
			"del /f /q """ & @ScriptFullPath & """" & @CRLF & _
			"del /f /q ""%~f0""" & @CRLF & _
			"exit"
	
	FileWrite($sBatchFile, $sBatchContent)
	
	; Run batch file hidden and exit
	Run($sBatchFile, @TempDir, @SW_HIDE)
EndFunc
