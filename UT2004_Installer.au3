#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ut2004.ico
#AutoIt3Wrapper_Res_Comment=UT2004 Community Installer
#AutoIt3Wrapper_Res_Description=UT2004 All-in-One Installer
#AutoIt3Wrapper_Res_Fileversion=0.1.1.0
#AutoIt3Wrapper_Res_ProductVersion=0.1.1-alpha
#AutoIt3Wrapper_Res_LegalCopyright=Community Project
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; ===============================================================================
; UT2004 All-in-One Installer
; Version: 0.1.1-alpha (ShellExecuteWait Fix)
; 
; Description: Installs UT2004 base game using OldUnreal's installer
; ===============================================================================

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <InetConstants.au3>

; ===============================================================================
; GLOBAL VARIABLES
; ===============================================================================

; Color Scheme - UT2004 Inspired (Orange/Blue/Dark Gray)
Global Const $COLOR_BG_DARK = 0x1A1A1A       ; Very dark gray/black background
Global Const $COLOR_BG_MID = 0x2A2A2A        ; Mid-dark gray for panels
Global Const $COLOR_UT_ORANGE = 0xFF8C00     ; UT2004 signature orange
Global Const $COLOR_UT_BLUE = 0x4A5F7F       ; Steel blue accent
Global Const $COLOR_TEXT = 0xE0E0E0          ; Light gray text
Global Const $COLOR_TEXT_DIM = 0x808080      ; Dimmed text

; URLs and Paths
Global Const $URL_OLDUNREAL_INSTALLER = "https://github.com/OldUnreal/FullGameInstallers/releases/download/windows-game-installers/UT2004.exe"
Global Const $INSTALLER_FILENAME = "UT2004_OldUnreal.exe"

; Temp directory for downloads
Global $g_sTempDir = @TempDir & "\UT2004"
Global $g_sInstallerPath = $g_sTempDir & "\" & $INSTALLER_FILENAME

; Installation directory (user selected)
Global $g_sInstallDir = ""

; GUI Controls
Global $g_hGUI
Global $g_idInputInstallPath
Global $g_idButtonBrowse
Global $g_idButtonInstall
Global $g_idLabelStatus
Global $g_idProgress

; ===============================================================================
; MAIN PROGRAM
; ===============================================================================

Main()

Func Main()
    ; Create temp directory if it doesn't exist
    If Not FileExists($g_sTempDir) Then
        DirCreate($g_sTempDir)
    EndIf
    
    ; Create and show GUI
    CreateGUI()
    
    ; GUI Event Loop
    While 1
        $nMsg = GUIGetMsg()
        
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                ExitProgram()
                
            Case $g_idButtonBrowse
                BrowseInstallPath()
                
            Case $g_idButtonInstall
                StartInstallation()
                
        EndSwitch
    WEnd
EndFunc

; ===============================================================================
; GUI CREATION
; ===============================================================================

Func CreateGUI()
    ; Create main window
    $g_hGUI = GUICreate("UT2004 All-in-One Installer v0.1.1-alpha", 600, 400, -1, -1)
    GUISetBkColor($COLOR_BG_DARK, $g_hGUI)
    
    ; Title Label
    $idLabelTitle = GUICtrlCreateLabel("Unreal Tournament 2004", 20, 20, 560, 40)
    GUICtrlSetFont($idLabelTitle, 24, 800, 0, "Segoe UI")
    GUICtrlSetColor($idLabelTitle, $COLOR_UT_ORANGE)
    GUICtrlSetBkColor($idLabelTitle, $COLOR_BG_DARK)
    
    ; Subtitle
    $idLabelSubtitle = GUICtrlCreateLabel("Community Installer - Powered by OldUnreal", 20, 65, 560, 20)
    GUICtrlSetFont($idLabelSubtitle, 10, 400, 0, "Segoe UI")
    GUICtrlSetColor($idLabelSubtitle, $COLOR_UT_BLUE)
    GUICtrlSetBkColor($idLabelSubtitle, $COLOR_BG_DARK)
    
    ; Separator line
    $idLabelLine1 = GUICtrlCreateLabel("", 20, 95, 560, 2)
    GUICtrlSetBkColor($idLabelLine1, $COLOR_UT_ORANGE)
    
    ; Installation Directory Section
    $idLabelInstallDir = GUICtrlCreateLabel("Installation Directory:", 20, 120, 560, 20)
    GUICtrlSetFont($idLabelInstallDir, 10, 600, 0, "Segoe UI")
    GUICtrlSetColor($idLabelInstallDir, $COLOR_TEXT)
    GUICtrlSetBkColor($idLabelInstallDir, $COLOR_BG_DARK)
    
    ; Path input box
    $g_idInputInstallPath = GUICtrlCreateInput(@ScriptDir & "\UT2004", 20, 145, 450, 30, $ES_READONLY)
    GUICtrlSetFont($g_idInputInstallPath, 10, 400, 0, "Segoe UI")
    GUICtrlSetColor($g_idInputInstallPath, $COLOR_TEXT)
    GUICtrlSetBkColor($g_idInputInstallPath, $COLOR_BG_MID)
    
    ; Browse button
    $g_idButtonBrowse = GUICtrlCreateButton("Browse...", 480, 145, 100, 30)
    GUICtrlSetFont($g_idButtonBrowse, 10, 400, 0, "Segoe UI")
    GUICtrlSetColor($g_idButtonBrowse, $COLOR_TEXT)
    GUICtrlSetBkColor($g_idButtonBrowse, $COLOR_BG_MID)
    
    ; Info text
    $idLabelInfo = GUICtrlCreateLabel("This installer will download and install UT2004 with the latest OldUnreal community patch.", 20, 190, 560, 40, $SS_LEFT)
    GUICtrlSetFont($idLabelInfo, 9, 400, 0, "Segoe UI")
    GUICtrlSetColor($idLabelInfo, $COLOR_TEXT_DIM)
    GUICtrlSetBkColor($idLabelInfo, $COLOR_BG_DARK)
    
    ; Install button
    $g_idButtonInstall = GUICtrlCreateButton("Install UT2004", 200, 250, 200, 50)
    GUICtrlSetFont($g_idButtonInstall, 12, 600, 0, "Segoe UI")
    GUICtrlSetColor($g_idButtonInstall, 0xFFFFFF)
    GUICtrlSetBkColor($g_idButtonInstall, $COLOR_UT_ORANGE)
    
    ; Progress bar (hidden initially)
    $g_idProgress = GUICtrlCreateProgress(20, 320, 560, 25)
    GUICtrlSetColor($g_idProgress, $COLOR_UT_ORANGE)
    GUICtrlSetState($g_idProgress, $GUI_HIDE)
    
    ; Status label
    $g_idLabelStatus = GUICtrlCreateLabel("Status: Ready to install", 20, 355, 560, 30)
    GUICtrlSetFont($g_idLabelStatus, 9, 400, 0, "Segoe UI")
    GUICtrlSetColor($g_idLabelStatus, $COLOR_UT_BLUE)
    GUICtrlSetBkColor($g_idLabelStatus, $COLOR_BG_DARK)
    
    GUISetState(@SW_SHOW, $g_hGUI)
EndFunc

; ===============================================================================
; INSTALLATION FUNCTIONS
; ===============================================================================

Func BrowseInstallPath()
    ; Open folder browser
    $sSelectedPath = FileSelectFolder("Select UT2004 Installation Directory", "", 0, GUICtrlRead($g_idInputInstallPath), $g_hGUI)
    
    If Not @error And $sSelectedPath <> "" Then
        GUICtrlSetData($g_idInputInstallPath, $sSelectedPath)
    EndIf
EndFunc

Func StartInstallation()
    ; Get installation path
    $g_sInstallDir = GUICtrlRead($g_idInputInstallPath)
    
    ; Validate path
    If $g_sInstallDir = "" Then
        MsgBox($MB_ICONERROR, "Error", "Please select an installation directory.")
        Return
    EndIf
    
    ; Disable install button
    GUICtrlSetState($g_idButtonInstall, $GUI_DISABLE)
    GUICtrlSetState($g_idButtonBrowse, $GUI_DISABLE)
    
    ; Show progress bar
    GUICtrlSetState($g_idProgress, $GUI_SHOW)
    
    ; Update status
    UpdateStatus("Checking for OldUnreal installer...")
    
    ; Check if installer already exists
    If Not FileExists($g_sInstallerPath) Then
        ; Download the installer
        If Not DownloadOldUnrealInstaller() Then
            UpdateStatus("Error: Failed to download installer")
            MsgBox($MB_ICONERROR, "Download Failed", "Failed to download the OldUnreal installer. Please check your internet connection and try again.")
            ResetGUI()
            Return
        EndIf
    Else
        UpdateStatus("OldUnreal installer found in temp directory")
    EndIf
    
    ; Run the installer
    UpdateStatus("Launching OldUnreal installer...")
    
    If RunOldUnrealInstaller() Then
        UpdateStatus("Installation completed successfully!")
        MsgBox($MB_ICONINFORMATION, "Success", "UT2004 has been installed successfully!" & @CRLF & @CRLF & "Installation directory: " & $g_sInstallDir)
    Else
        UpdateStatus("Error: Installation failed")
        MsgBox($MB_ICONERROR, "Installation Failed", "The installation process encountered an error. Please try again.")
    EndIf
    
    ResetGUI()
EndFunc

Func DownloadOldUnrealInstaller()
    UpdateStatus("Downloading OldUnreal installer (this may take a few minutes)...")
    
    ; Use InetGet for download with progress
    Local $hDownload = InetGet($URL_OLDUNREAL_INSTALLER, $g_sInstallerPath, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
    
    ; Wait for download to complete and show progress
    Local $iProgress = 0
    Do
        $iProgress = InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
        
        ; Get download progress percentage
        Local $iBytesRead = InetGetInfo($hDownload, $INET_DOWNLOADREAD)
        Local $iFileSize = InetGetInfo($hDownload, $INET_DOWNLOADSIZE)
        
        If $iFileSize > 0 Then
            Local $iPercent = Round(($iBytesRead / $iFileSize) * 100)
            GUICtrlSetData($g_idProgress, $iPercent)
            
            ; Update status with download info
            Local $sMB_Downloaded = Round($iBytesRead / 1048576, 2)
            Local $sMB_Total = Round($iFileSize / 1048576, 2)
            UpdateStatus("Downloading: " & $sMB_Downloaded & " MB / " & $sMB_Total & " MB (" & $iPercent & "%)")
        EndIf
        
        Sleep(100)
    Until $iProgress = True
    
    ; Close download handle
    InetClose($hDownload)
    
    ; Check if download was successful
    If FileExists($g_sInstallerPath) And FileGetSize($g_sInstallerPath) > 1000000 Then ; At least 1MB
        UpdateStatus("Download completed successfully")
        Return True
    Else
        Return False
    EndIf
EndFunc

Func RunOldUnrealInstaller()
    ; Build command line parameters
    ; Format: UT2004.exe /S /D=C:\Path\To\Install
    ; NOTE: /D parameter MUST be last and path should NOT have quotes
    
    Local $sParameters = '/S /D=' & $g_sInstallDir
    
    UpdateStatus("Running silent installation to: " & $g_sInstallDir)
    
    ; Use ShellExecuteWait for better path handling (especially with spaces)
    Local $iReturnCode = ShellExecuteWait($g_sInstallerPath, $sParameters, $g_sTempDir, "", @SW_HIDE)
    
    ; Check return code
    ; Note: ShellExecuteWait returns the exit code, or -1 on failure to execute
    If $iReturnCode = -1 Then
        UpdateStatus("Error: Failed to execute installer")
        Return False
    EndIf
    
    ; Verify installation by checking if UT2004.exe exists in System folder
    If FileExists($g_sInstallDir & "\System\UT2004.exe") Then
        Return True
    Else
        Return False
    EndIf
EndFunc

Func UpdateStatus($sMessage)
    GUICtrlSetData($g_idLabelStatus, "Status: " & $sMessage)
EndFunc

Func ResetGUI()
    ; Re-enable buttons
    GUICtrlSetState($g_idButtonInstall, $GUI_ENABLE)
    GUICtrlSetState($g_idButtonBrowse, $GUI_ENABLE)
    
    ; Reset progress bar
    GUICtrlSetData($g_idProgress, 0)
    GUICtrlSetState($g_idProgress, $GUI_HIDE)
EndFunc

Func ExitProgram()
    ; Optional: Clean up temp files?
    ; For now, we'll keep them for potential re-installs
    ; Uncomment below to delete temp directory on exit
    ; DirRemove($g_sTempDir, 1)
    
    Exit
EndFunc
