 #Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=UT2004.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=UT2004 All-In-One Community Installer
#AutoIt3Wrapper_Res_Description=UT2004 All-In-One Community Installer
#AutoIt3Wrapper_Res_Fileversion=0.6.8.0
#AutoIt3Wrapper_Res_ProductVersion=0.6.8
#AutoIt3Wrapper_Res_CompanyName=Community Project
#AutoIt3Wrapper_Res_LegalCopyright=MIT License
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.16.1
	Author:         EddCase
	Version:        0.6.8

	Script Function:
		UT2004 All-In-One Installer
		Custom installation with full control over the process

	COMPLETE - Core Installation:
		✓ GUI with UT2004 Theme (Tabbed Interface)
		✓ ISO Download with caching
		✓ CAB Extraction
		✓ File Installation
		✓ OldUnreal Patch (auto-download from GitHub)
		✓ Registry (full compatibility set)
		✓ Shortcuts (Desktop + Start Menu)
		✓ Cleanup & Keep Files option
		✓ File Associations (ut2004://, .ut4mod)
		✓ MegaPack (ECE + Bonus Maps) - Optional
		✓ Community Bonus Pack 1 (19 maps)
		✓ Community Bonus Pack 2 Volume 1 (21 maps)
		✓ Community Bonus Pack 2 Volume 2 (20 maps)
		✓ Uninstaller (separate Uninstaller.exe)
		✓ INI Settings persistence
		✓ Bonus Pack caching (skip re-download if already kept)
		✓ Portable _Downloads cache (moved next to exe when Keep Files checked)
		✓ Windows Firewall rules for online play
		- Game settings configuration (resolution, refresh rate)
		- Better error recovery

#ce ----------------------------------------------------------------------------

#Region Includes and Options
	; WHAT: Include AutoIt libraries we need
	; WHY: These provide GUI functions, file operations, constants
	; HOW:
	;   - GUIConstantsEx: GUI creation, button constants, window styles
	;   - StaticConstants: Label/text styles
	;   - EditConstants: Text input box styles
	;   - WindowsConstants: Window positioning
	;   - File: File operations like _PathFull

	#include <GUIConstantsEx.au3>
	#include <StaticConstants.au3>
	#include <EditConstants.au3>
	#include <WindowsConstants.au3>
	#include <ButtonConstants.au3>
	#include <ProgressConstants.au3>
	#include <InetConstants.au3>
	#include <File.au3>
	#include <String.au3>

	; WHAT: Set AutoIt options for better behavior
	; WHY:
	;   - MustDeclareVars: Prevents typos, forces us to declare all variables
	;   - TrayIconDebug: Shows line number in tray tooltip (helpful for debugging)
	; HOW: Opt() function sets AutoIt engine options

	Opt("MustDeclareVars", 1)
	Opt("TrayIconDebug", 1)

	; WHAT: Require administrator privileges
	; WHY: Need admin rights to write to HKEY_LOCAL_MACHINE registry
	; HOW: #RequireAdmin forces UAC prompt if not already elevated
	#RequireAdmin
#EndRegion

#Region Global Variables - Paths
	; WHAT: Define all the paths we'll use throughout the installer
	; WHY: Centralized path management makes it easy to change locations
	; HOW:
	;   - @ScriptDir: Where this script/exe is located
	;   - @TempDir: Windows temp folder (C:\Users\Name\AppData\Local\Temp)
	;   - These are set as globals so all functions can access them

	; Installation paths
	Global $g_sInstallPath = @ProgramFilesDir & "\UT2004"  ; Default install location

	; Patch Version Fallback
	Global $aVersion = ""
	Global $sPatchVersion = ""

	; Working directories (temporary)
	Global $g_sTempDir = @TempDir & "\UT2004_Install"      ; Main temp folder
	Global $g_sDownloadDir = $g_sTempDir & "\_Downloads"   ; Where we download (always temp)
	Global $g_sPortableDir = @ScriptDir & "\_Downloads"    ; Portable cache next to exe
	Global $g_sTempCABs = $g_sTempDir & "\_Temp_CABs"      ; Extracted CAB files

	; Tool paths (bundled with installer)
	Global $g_s7Zip = @TempDir & "\UT2004_Install_Tools\7z.exe"
	Global $g_sUnshield = @TempDir & "\UT2004_Install_Tools\unshield.exe"

	; Download URLs - loaded from installer_settings.ini, with hardcoded fallbacks
	Global $g_sURL_ISO = "https://files.oldunreal.net/UT2004.ISO"  ; Loaded by LoadDownloadURLs()
	Global $g_sPatchUrl = "https://github.com/OldUnreal/UT2004Patches/releases/latest"  ; We'll parse this for actual download

	; Installation log
	Global $g_hLogFile = 0  ; File handle for install.log
	Global $g_sCDKey = ""   ; CD Key (optional, stored for registry writing)
#EndRegion

#Region Global Variables - GUI Elements
	; WHAT: References to GUI controls we'll manipulate later
	; WHY: We need to update these controls (change text, enable/disable, etc.)
	; HOW: Assigned when we create the GUI, used in event handlers

	Global $g_hGUI                  ; Main window handle
	Global $g_idInputInstallPath    ; Installation path text box
	Global $g_idInputCDKey          ; CD Key input (optional)
	Global $g_idBtnBrowse           ; Browse button
	Global $g_idBtnInstall          ; Install button
	Global $g_idProgressBar         ; Progress bar
	Global $g_idLabelStatus         ; Status message label
	Global $g_idCheckboxKeepFiles   ; "Keep installer files" checkbox
	Global $g_idLabelKeepFiles      ; Label for checkbox (clickable)
	Global $g_idCheckboxFileAssoc   ; "Register file associations" checkbox
	Global $g_idLabelFileAssoc      ; Label for file associations checkbox
	Global $g_idCheckboxFirewall    ; "Add Windows Firewall exception" checkbox
	Global $g_idLabelFirewall       ; Label for firewall checkbox
	Global $g_idCheckboxMegaPack    ; "Install MegaPack" checkbox
	Global $g_idLabelMegaPack       ; Label for MegaPack checkbox
	Global $g_idCheckboxCBP1        ; "Install CBP1" checkbox
	Global $g_idLabelCBP1           ; Label for CBP1 checkbox
	Global $g_idCheckboxCBP2V1      ; "Install CBP2 Vol 1" checkbox
	Global $g_idLabelCBP2V1         ; Label for CBP2 Vol 1 checkbox
	Global $g_idCheckboxCBP2V2          ; "Install CBP2 Vol 2" checkbox
	Global $g_idLabelCBP2V2             ; Label for CBP2 Vol 2 checkbox
	Global $g_idCheckboxAutoRes         ; "Set default resolution" checkbox
	Global $g_idLabelAutoRes            ; Label for auto resolution checkbox
	Global $g_idCheckboxMaxDetail       ; "Set Holy S**t! (Maximum detail settings)" checkbox
	Global $g_idLabelMaxDetail          ; Label for max detail checkbox
	Global $g_iDetectedWidth = 0        ; Detected monitor width
	Global $g_iDetectedHeight = 0       ; Detected monitor height
	Global $g_iDetectedRefresh = 0      ; Detected monitor refresh rate

	; Tab system
	; WHAT: Variables for tabbed interface
	; WHY: Organize UI into logical sections, reduce clutter
	; HOW: Track current tab, store control IDs per tab for show/hide
	Global $g_iCurrentTab = 1       ; Currently displayed tab (1=Installation, 2=Official Content, 3=Options)
	Global $g_idTabBtn1             ; Installation tab button
	Global $g_idTabBtn2             ; Official Content tab button
	Global $g_idTabBtn3             ; Options tab button
	Global $g_aTab1Controls[10]     ; Array of controls for Installation tab
	Global $g_aTab2Controls[20]     ; Array of controls for Official Content tab
	Global $g_aTab3Controls[20]     ; Array of controls for Options tab

	; WHAT: Mapping between clickable labels and their checkboxes
	; WHY: Generic system - one function handles all label clicks
	; HOW: When we create a label+checkbox pair, we store the mapping
	;      Format: "LabelID|CheckboxID" separated by pipes
	;      Later we can look up which checkbox to toggle
	Global $g_aLabelToCheckboxMap[100][2]  ; Max 100 label/checkbox pairs (plenty for future)
	Global $g_iLabelCheckboxCount = 0       ; How many pairs we've registered
#EndRegion

#Region Global Variables - UI Colors (UT2004 Theme)
	; WHAT: Color scheme matching Unreal Tournament 2004's aesthetic
	; WHY: Makes the installer feel like part of UT2004, professional look
	; HOW: Colors in hex format (0xRRGGBB)
	;   - These match the original v0.1.1 installer colors

	; WHAT: Installer version string - single source of truth for runtime displays
	; WHY: Avoids version mismatches across window title, log, and UI label
	; NOTE: AutoIt3Wrapper compile-time directives (lines 7-8) and header comment (line 18)
	;       must still be updated manually as they cannot use runtime constants
	Global Const $INSTALLER_VERSION = "0.6.8"

	Global Const $COLOR_BG_DARK = 0x1a1a1a      ; Very dark gray (main background)
	Global Const $COLOR_BG_MID = 0x2a2a2a       ; Mid-dark gray (panels)
	Global Const $COLOR_UT_ORANGE = 0xFF8C00    ; UT2004 signature orange
	Global Const $COLOR_UT_BLUE = 0x4A5F7F      ; Steel blue accent
	Global Const $COLOR_TEXT = 0xE0E0E0         ; Light gray text
	Global Const $COLOR_TEXT_DIM = 0x808080     ; Dimmed text for hints
#EndRegion

#Region Main Program Flow
	; WHAT: The main entry point of our installer
	; WHY: This is where execution starts
	; HOW:
	;   1. Extract bundled tools (7z.exe, unshield.exe)
	;   2. Create the GUI
	;   3. Enter message loop (wait for user interaction)

	Main()

	Func Main()
		; Extract bundled tools first
		; WHAT: Extract 7z.exe and unshield.exe from compiled installer
		; WHY: We need these tools available before we can use them
		; HOW: FileInstall embeds files at compile time, extracts at runtime
		;      This happens in ExtractBundledTools() function
		ExtractBundledTools()

		; Check for portable downloads cache next to installer
		; WHAT: See if a _Downloads folder exists next to the exe
		; WHY: If user kept files from a previous install (portable mode),
		;      we can use those cached files and skip downloading
		; HOW: If @ScriptDir\_Downloads exists, point cache checks there
		;      We still always DOWNLOAD to temp - this is just for cache detection
		If FileExists($g_sPortableDir) Then
			LogMessage("Portable cache found: " & $g_sPortableDir)
			LogMessage("Cache files will be used to skip downloads where possible")
		Else
			LogMessage("No portable cache found - will download fresh to temp")
		EndIf

		; Create and show the GUI
		; WHAT: Build the installer window with all controls
		; WHY: User needs interface to choose install location and start installation
		; HOW: CreateGUI() function creates window and all controls
		CreateGUI()

		; Load saved settings (if any)
		; WHAT: Restore user preferences from installer_settings.ini
		; WHY: Convenience for repeat testers/users
		; HOW: LoadSettings() reads INI and sets checkbox states
		LoadSettings()

		; Load configurable download URLs from installer_settings.ini
		; WHAT: Read custom download URLs (e.g. Cloudflare R2) from INI
		; WHY: Allows hosting files anywhere without recompiling
		; HOW: LoadDownloadURLs() reads [DownloadURLs_*] sections, falls back to GitHub
		LoadDownloadURLs()

		; Message loop
		; WHAT: Wait for and process user interactions (button clicks, window close, etc.)
		; WHY: GUI needs to respond to user actions
		; HOW: GUIGetMsg() checks for events, we handle them in a loop
		;      This is standard AutoIt GUI programming pattern
		While True
			Local $iMsg = GUIGetMsg()  ; Check for GUI events

			Switch $iMsg
				Case $GUI_EVENT_CLOSE
					; WHAT: User clicked X button or pressed Alt+F4
					; WHY: Need to clean up and exit gracefully
					; HOW: ExitApplication() closes log, cleans temp, exits
					ExitApplication()

				Case $g_idBtnBrowse
					; WHAT: User clicked Browse button
					; WHY: Let user choose custom install location
					; HOW: Show folder picker dialog
					OnBrowseClicked()

				Case $g_idBtnInstall
					; WHAT: User clicked Install button
					; WHY: Start the installation process
					; HOW: Validate inputs, then begin installation phases
					OnInstallClicked()

				Case $g_idTabBtn1
					; WHAT: User clicked Installation tab button
					; WHY: Switch to Installation tab
					; HOW: Call SwitchToTab with tab number 1
					SwitchToTab(1)

				Case $g_idTabBtn2
					; WHAT: User clicked Official Content tab button
					; WHY: Switch to Official Content tab
					; HOW: Call SwitchToTab with tab number 2
					SwitchToTab(2)

				Case $g_idTabBtn3
					; WHAT: User clicked Options tab button
					; WHY: Switch to Options tab
					; HOW: Call SwitchToTab with tab number 3
					SwitchToTab(3)

				Case Else
					; WHAT: Check if a checkbox label was clicked
					; WHY: Generic system - handles all label clicks in one place
					; HOW: Look up the clicked control in our mapping array
					;      If it's a registered label, toggle its checkbox
					OnGenericLabelClicked($iMsg)
			EndSwitch
		WEnd
	EndFunc
#EndRegion

#Region Tool Extraction
	Func ExtractBundledTools()
		; WHAT: Extract 7-Zip and unshield from compiled installer
		; WHY: These tools are embedded in the .exe, need to extract before use
		; HOW: FileInstall() extracts files that were embedded at compile time
		;      Extracts to TEMP directory for cleaner installation

		; Create Tools directory in temp if it doesn't exist
		Local $sToolsDir = @TempDir & "\UT2004_Install_Tools"
		If Not FileExists($sToolsDir) Then
			DirCreate($sToolsDir)
		EndIf

		; Extract tools to temp directory
		FileInstall("Tools\7z.exe", $sToolsDir & "\7z.exe", 1)
		FileInstall("Tools\7z.dll", $sToolsDir & "\7z.dll", 1)
		FileInstall("Tools\unshield.exe", $sToolsDir & "\unshield.exe", 1)
		FileInstall("Tools\zlib1.dll", $sToolsDir & "\zlib1.dll", 1)
		FileInstall("Tools\Uninstaller.exe", $sToolsDir & "\Uninstaller.exe", 1)

		; Create installer_settings.ini next to exe if it doesn't already exist
		; WHAT: Extract the example INI as installer_settings.ini
		; WHY: Gives users a ready-made template with all available sections and options
		;      so they know exactly what they can customise (e.g. Cloudflare R2 URLs)
		; HOW: FileInstall embeds installer_settings_EXAMPLE.ini at compile time
		;      We only create it if missing - never overwrite an existing customised file
		Local $sINIFile = @ScriptDir & "\installer_settings.ini"
		If Not FileExists($sINIFile) Then
			FileInstall("installer_settings_EXAMPLE.ini", $sINIFile, 0)  ; 0 = don't overwrite
		EndIf

		; Verify tools extracted successfully
		If Not FileExists($sToolsDir & "\7z.exe") Then
		    MsgBox(16, "Missing Tool", "Failed to extract 7z.exe" & @CRLF & "Installer may be corrupt.")
		    Exit
		EndIf

		If Not FileExists($sToolsDir & "\unshield.exe") Then
		    MsgBox(16, "Missing Tool", "Failed to extract unshield.exe" & @CRLF & "Installer may be corrupt.")
		    Exit
		EndIf

		If Not FileExists($sToolsDir & "\Uninstaller.exe") Then
		    MsgBox(16, "Missing Tool", "Failed to extract Uninstaller.exe" & @CRLF & "Installer may be corrupt.")
		    Exit
		EndIf

	EndFunc
#EndRegion

#Region GUI Creation
	Func CreateGUI()
		; WHAT: Create the main installer window with tabbed interface
		; WHY: User needs a clean, organized GUI
		; HOW: Create window, tab buttons, tab content areas, always-visible progress section

		; Create main window - 640x480 old-school size!
		$g_hGUI = GUICreate("UT2004 Community Installer v" & $INSTALLER_VERSION, 640, 480, -1, -1, _
				BitOR($WS_CAPTION, $WS_SYSMENU))

		; Set UT2004 dark theme background
		GUISetBkColor($COLOR_BG_DARK, $g_hGUI)

		; Create tab buttons at top
		CreateTabButtons()

		; Create all three tab content areas
		; Each function returns an array of control IDs
		$g_aTab1Controls = CreateTab1_Installation()
		$g_aTab2Controls = CreateTab2_OfficialContent()
		$g_aTab3Controls = CreateTab3_Options()

		; === ALWAYS VISIBLE SECTION (Bottom) ===
		; This section never changes regardless of tab

		; Separator line (visual only)
		Local $idSeparator = GUICtrlCreateLabel("", 10, 350, 620, 2)
		GUICtrlSetBkColor(-1, $COLOR_BG_MID)

		; Progress Bar
		$g_idProgressBar = GUICtrlCreateProgress(20, 360, 600, 25)
		GUICtrlSetColor(-1, $COLOR_UT_ORANGE)

		; Status Label
		$g_idLabelStatus = GUICtrlCreateLabel("Ready to install", 20, 395, 600, 20, $SS_CENTER)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

		; Install Button
		$g_idBtnInstall = GUICtrlCreateButton("Install UT2004", 220, 425, 200, 40)
		GUICtrlSetFont(-1, 12, 600)
		GUICtrlSetColor(-1, $COLOR_BG_DARK)
		GUICtrlSetBkColor(-1, $COLOR_UT_ORANGE)

		; Show the window
		GUISetState(@SW_SHOW, $g_hGUI)
	EndFunc
#EndRegion

#Region Event Handlers
	Func ShowLicenseAgreement()
		; WHAT: Show Epic Games Terms of Service and require acceptance
		; WHY: Legal requirement for distributing UT2004
		; HOW: Display TOS in MsgBox, require Yes to continue
		;
		; RETURN: True if user accepts, False if declined

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

	Func OnBrowseClicked()
		; WHAT: Handle Browse button click
		; WHY: User wants to choose a different install location
		; HOW: Show folder picker dialog, update input box if user selects a folder

		; Show folder selection dialog
		; WHAT: Windows folder picker dialog
		; WHY: Easier than typing a path
		; HOW: FileSelectFolder(message, root_folder, flag, default_path)
		;   - Flag 1: Show "Make New Folder" button
		;   - Returns empty string if cancelled
		Local $sSelectedPath = FileSelectFolder("Select Installation Directory", "", 1, $g_sInstallPath)

		; Update if user selected a folder (didn't cancel)
		; WHAT: Check if user clicked OK (not Cancel)
		; WHY: Empty string means user cancelled, don't update
		; HOW: If not empty, update the input box and global variable
		If $sSelectedPath <> "" Then
			$g_sInstallPath = $sSelectedPath
			GUICtrlSetData($g_idInputInstallPath, $g_sInstallPath)
		EndIf
	EndFunc

	Func RegisterLabelCheckboxPair($idLabel, $idCheckbox)
		; WHAT: Register a label/checkbox pair for click handling
		; WHY: Reusable system - works for any number of checkboxes
		; HOW: Store in our mapping array, increment counter
		;      When a label is clicked, we'll look it up and toggle its checkbox

		; Add to mapping array
		; WHAT: Store label ID and checkbox ID together
		; WHY: So we can find which checkbox to toggle when label is clicked
		; HOW: Use next available slot in array
		$g_aLabelToCheckboxMap[$g_iLabelCheckboxCount][0] = $idLabel
		$g_aLabelToCheckboxMap[$g_iLabelCheckboxCount][1] = $idCheckbox

		; Increment counter for next registration
		$g_iLabelCheckboxCount += 1
	EndFunc

	Func OnGenericLabelClicked($idControl)
		; WHAT: Handle any checkbox label click
		; WHY: Generic function - handles all current and future checkbox labels
		; HOW: Look up the clicked control ID in our mapping array
		;      If found, toggle the associated checkbox

		; Search through registered label/checkbox pairs
		; WHAT: Check if this control is a registered checkbox label
		; WHY: Only toggle if it's one of our checkbox labels
		; HOW: Loop through mapping array, compare control IDs
		For $i = 0 To $g_iLabelCheckboxCount - 1
			If $g_aLabelToCheckboxMap[$i][0] = $idControl Then
				; Found it! This is a checkbox label
				; WHAT: Toggle the associated checkbox
				; WHY: User clicked the label text
				; HOW: Read current state, set opposite state

				Local $idCheckbox = $g_aLabelToCheckboxMap[$i][1]
				Local $iCurrentState = GUICtrlRead($idCheckbox)

				If $iCurrentState = $GUI_CHECKED Then
					GUICtrlSetState($idCheckbox, $GUI_UNCHECKED)
				Else
					GUICtrlSetState($idCheckbox, $GUI_CHECKED)
				EndIf

				; Exit loop - we found and handled it
				ExitLoop
			EndIf
		Next
	EndFunc

	Func OnInstallClicked()
		; WHAT: Handle Install button click - start installation process
		; WHY: User wants to start the installation
		; HOW: Validate inputs, initialize logging, begin installation phases

		; Show and require acceptance of Epic Games Terms of Service
		; WHAT: Display TOS and get user acceptance
		; WHY: Legal requirement for distributing UT2004
		; HOW: Show dialog, exit if user declines
		If Not ShowLicenseAgreement() Then
			Return  ; User declined TOS
		EndIf

		; Get current install path from input box
		; WHAT: Read what's in the installation path text box
		; WHY: User might have typed a path instead of browsing
		; HOW: GUICtrlRead gets text from input control
		$g_sInstallPath = GUICtrlRead($g_idInputInstallPath)

		; Get CD Key if provided
		; WHAT: Read optional CD key from input box
		; WHY: User may have entered a key for server stats
		; HOW: GUICtrlRead gets text, validate format
		Local $sCDKey = StringStripWS(GUICtrlRead($g_idInputCDKey), 3)  ; Remove leading/trailing spaces

		; Validate CD Key format if provided
		If $sCDKey <> "" Then
			If Not ValidateCDKey($sCDKey) Then
				MsgBox(48, "Invalid CD Key", "CD Key must be in format: XXXXX-XXXXX-XXXXX-XXXXX" & @CRLF & _
						"(5 groups of 5 alphanumeric characters separated by hyphens)" & @CRLF & @CRLF & _
						"Leave blank if you don't have a key.")
				Return
			EndIf
			; Convert to uppercase for consistency and store globally
			$g_sCDKey = StringUpper($sCDKey)
		Else
			$g_sCDKey = ""  ; No CD key provided
		EndIf

		; Validate install path
		; WHAT: Make sure the path is valid
		; WHY: Can't install to invalid or inaccessible location
		; HOW: Check for empty, check if path can be created
		If $g_sInstallPath = "" Then
			MsgBox(48, "Invalid Path", "Please enter an installation directory.")  ; 48 = Warning icon
			Return
		EndIf

		; Check if we can create the directory
		; WHAT: Try to create install directory
		; WHY: Verify we have write permissions before starting
		; HOW: DirCreate, check @error
		If Not FileExists($g_sInstallPath) Then
			DirCreate($g_sInstallPath)
			If @error Then
				MsgBox(16, "Error", "Cannot create installation directory." & @CRLF & _
						"Check permissions or choose a different location.")
				Return
			EndIf
		EndIf

		; Save current settings for next run
		; WHAT: Store checkbox states to INI file
		; WHY: Convenience for repeat installations (especially testing)
		; HOW: SaveSettings() writes to installer_settings.ini
		SaveSettings()

		; Disable UI during installation
		; WHAT: Prevent user from changing things mid-install
		; WHY: Changing paths/keys during installation would cause problems
		; HOW: Disable input, browse, and install buttons
		GUICtrlSetState($g_idInputInstallPath, $GUI_DISABLE)
		GUICtrlSetState($g_idInputCDKey, $GUI_DISABLE)
		GUICtrlSetState($g_idBtnBrowse, $GUI_DISABLE)
		GUICtrlSetState($g_idBtnInstall, $GUI_DISABLE)
		GUICtrlSetState($g_idCheckboxKeepFiles, $GUI_DISABLE)
		GUICtrlSetState($g_idCheckboxFileAssoc, $GUI_DISABLE)
		GUICtrlSetState($g_idCheckboxFirewall, $GUI_DISABLE)
		GUICtrlSetState($g_idCheckboxMegaPack, $GUI_DISABLE)
		GUICtrlSetState($g_idCheckboxCBP1, $GUI_DISABLE)
		GUICtrlSetState($g_idCheckboxCBP2V1, $GUI_DISABLE)
		GUICtrlSetState($g_idCheckboxCBP2V2, $GUI_DISABLE)
		GUICtrlSetState($g_idCheckboxAutoRes, $GUI_DISABLE)
		GUICtrlSetState($g_idCheckboxMaxDetail, $GUI_DISABLE)
		GUICtrlSetState($g_idTabBtn1, $GUI_DISABLE)
		GUICtrlSetState($g_idTabBtn2, $GUI_DISABLE)
		GUICtrlSetState($g_idTabBtn3, $GUI_DISABLE)

		; Initialize installation log
		; WHAT: Create install.log file
		; WHY: Track installation for troubleshooting
		; HOW: Call InitializeLog function
		InitializeLog()

		; Begin installation process
		; WHAT: Start the multi-phase installation
		; WHY: This is what the user clicked Install for
		; HOW: Call BeginInstallation which coordinates all phases
		BeginInstallation()
	EndFunc
#EndRegion

#Region Installation Process
	Func BeginInstallation()
		; WHAT: Coordinate all installation phases
		; WHY: Central function that calls each phase in order
		; HOW: Call phase functions sequentially, handle errors
		;
		; PHASES:
		;   Phase 1: GUI (complete)
		;   Phase 2: Download ISO (complete)
		;   Phase 3: Extract ISO (current)
		;   Phase 4: Extract CABs
		;   Phase 5: Apply patch & finalize

		UpdateStatus("Starting installation...")

		; Phase 2: Download UT2004 ISO
		; WHAT: Download or verify ISO file
		; WHY: Need the game files
		; HOW: Check if exists, download if needed, verify
		If Not Phase2_DownloadISO() Then
			; Download failed
			UpdateStatus("Installation failed: Could not download ISO")
			InstallationFailed("Failed to download UT2004.ISO")
			Return False
		EndIf

		; Phase 3: Extract CAB files from ISO
		; WHAT: Extract CAB files from ISO
		; WHY: Need CABs to extract game files
		; HOW: Use 7z.exe to extract, flatten structure
		If Not Phase3_ExtractISO() Then
			; Extraction failed
			UpdateStatus("Installation failed: Could not extract ISO")
			InstallationFailed("Failed to extract CAB files from ISO")
			Return False
		EndIf

		; Phase 4: Extract game files from CABs
		; WHAT: Extract game files from CAB files using unshield
		; WHY: Need actual game files to install
		; HOW: Run unshield on each CAB, extract to temp
		If Not Phase4_ExtractCABs() Then
			; Extraction failed
			UpdateStatus("Installation failed: Could not extract CAB files")
			InstallationFailed("Failed to extract game files from CAB files")
			Return False
		EndIf

		; Phase 5: Copy files to installation directory
		; WHAT: Copy extracted files to user's install location
		; WHY: Move files from temp to final location
		; HOW: Copy and rename folders according to mapping
		If Not Phase5_CopyFiles() Then
			; Copy failed
			UpdateStatus("Installation failed: Could not copy files")
			InstallationFailed("Failed to copy game files to installation directory")
			Return False
		EndIf

		; Phase 5c: Create shortcuts
		; WHAT: Create desktop, start menu and install root shortcuts
		; WHY: User needs easy access to game
		; HOW: Create shortcuts in all three locations
		If Not Phase5c_Shortcuts() Then
			; Phase 5c failed (non-critical)
			LogMessage("WARNING: Phase 5c failed, but installation is complete")
		EndIf

		; Phase 6: Install MegaPack (optional)
		; WHAT: Install ECE content and 9 bonus maps
		; WHY: User wants additional official content
		; HOW: Download multi-part ZIP, extract, copy to game
		Local $bInstallMegaPack = (GUICtrlRead($g_idCheckboxMegaPack) = $GUI_CHECKED)

		If $bInstallMegaPack Then
			If Not Phase6_InstallMegaPack() Then
				; Phase 6 failed (non-critical, user still has base game)
				LogMessage("WARNING: Phase 6 failed - MegaPack not installed")
				MsgBox(48, "MegaPack Installation Failed", "The base game installed successfully, but the MegaPack (bonus content) failed to install." & @CRLF & @CRLF & _
						"You can try installing the MegaPack manually later." & @CRLF & @CRLF & _
						"Check install.log for details.")
			EndIf
		Else
			LogMessage("MegaPack installation skipped (user choice)")
		EndIf

		; Phase 7: Install CBP1 (optional)
		; WHAT: Install Community Bonus Pack 1 (19 maps)
		; WHY: User wants additional community content
		; HOW: Download multi-part ZIP, extract, copy to game
		Local $bInstallCBP1 = (GUICtrlRead($g_idCheckboxCBP1) = $GUI_CHECKED)

		If $bInstallCBP1 Then
			If Not Phase7_InstallCBP1() Then
				; Phase 7 failed (non-critical, user still has base game)
				LogMessage("WARNING: Phase 7 failed - CBP1 not installed")
				MsgBox(48, "CBP1 Installation Failed", "The base game installed successfully, but Community Bonus Pack 1 failed to install." & @CRLF & @CRLF & _
						"You can try installing CBP1 manually later." & @CRLF & @CRLF & _
						"Check install.log for details.")
			EndIf
		Else
			LogMessage("CBP1 installation skipped (user choice)")
		EndIf

		; Phase 8: Install CBP2 Volume 1 (optional)
		; WHAT: Install Community Bonus Pack 2 Volume 1 (21 maps)
		; WHY: User wants additional community content
		; HOW: Download multi-part ZIP, extract, copy to game
		Local $bInstallCBP2V1 = (GUICtrlRead($g_idCheckboxCBP2V1) = $GUI_CHECKED)

		If $bInstallCBP2V1 Then
			If Not Phase8_InstallCBP2V1() Then
				; Phase 8 failed (non-critical, user still has base game)
				LogMessage("WARNING: Phase 8 failed - CBP2 Volume 1 not installed")
				MsgBox(48, "CBP2 Volume 1 Installation Failed", "The base game installed successfully, but Community Bonus Pack 2 Volume 1 failed to install." & @CRLF & @CRLF & _
						"You can try installing CBP2 Volume 1 manually later." & @CRLF & @CRLF & _
						"Check install.log for details.")
			EndIf
		Else
			LogMessage("CBP2 Volume 1 installation skipped (user choice)")
		EndIf

		; Phase 9: Install CBP2 Volume 2 (optional)
		; WHAT: Install Community Bonus Pack 2 Volume 2 (20 maps)
		; WHY: User wants additional community content
		; HOW: Download multi-part ZIP, extract, copy to game
		Local $bInstallCBP2V2 = (GUICtrlRead($g_idCheckboxCBP2V2) = $GUI_CHECKED)

		If $bInstallCBP2V2 Then
			If Not Phase9_InstallCBP2V2() Then
				; Phase 9 failed (non-critical, user still has base game)
				LogMessage("WARNING: Phase 9 failed - CBP2 Volume 2 not installed")
				MsgBox(48, "CBP2 Volume 2 Installation Failed", "The base game installed successfully, but Community Bonus Pack 2 Volume 2 failed to install." & @CRLF & @CRLF & _
						"You can try installing CBP2 Volume 2 manually later." & @CRLF & @CRLF & _
						"Check install.log for details.")
			EndIf
		Else
			LogMessage("CBP2 Volume 2 installation skipped (user choice)")
		EndIf

		; Phase 5b: Apply patch and write registry (ALWAYS LAST!)
		; WHAT: Apply OldUnreal patch and finalize system integration
		; WHY: Patch must overwrite any outdated files from base game or bonus packs
		; HOW: Download patch, extract, write registry
		; NOTE: This is run AFTER Phase 6 to ensure patch overwrites everything
		If Not Phase5b_PatchAndRegistry() Then
			; Phase 5b failed
			UpdateStatus("Installation failed: Could not apply patch or write registry")
			InstallationFailed("Failed to apply patch and write registry entries")
			Return False
		EndIf

		; Phase ConfigureGame: Patch UT2004.ini with resolution and detail settings
		; WHAT: Copy Default.ini to UT2004.ini and patch with user's chosen settings
		; WHY: Gives the user correct resolution and max detail on first launch
		; HOW: FileCopy Default.ini, then IniWrite detected resolution / max detail values
		Phase_ConfigureGame()

		; Phase Finalise: Move _Downloads cache and cleanup temp
		; WHAT: Move _Downloads to portable cache or clean up temp
		; WHY: Must run AFTER all downloads are complete (bonus packs + patch)
		; HOW: DirMove _Downloads if Keep Files checked, else DirRemove temp
		Phase_Finalise()

		; Installation complete!
		InstallationComplete()

		Return True
	EndFunc

	Func Phase2_DownloadISO()
		; WHAT: Download UT2004.ISO if needed
		; WHY: Can't install without the ISO
		; HOW: Check if exists and valid, download if needed
		;
		; RETURN: True if ISO is ready, False if failed

		UpdateStatus("Checking for UT2004.ISO...")

		; Define ISO path - derive filename from URL so it works with any hosting
		; WHAT: Get the filename from whatever URL is configured
		; WHY: Custom hosting might use a different filename than UT2004.ISO
		; HOW: Extract everything after the last / in the URL
		Local $sISOFilename = StringRegExpReplace($g_sURL_ISO, "^.*/", "")
		If $sISOFilename = "" Then $sISOFilename = "UT2004.ISO"  ; Fallback just in case
		Local $sISOPath = $g_sDownloadDir & "\" & $sISOFilename

		; Create download directory if needed
		; WHAT: Make sure download folder exists
		; WHY: Can't save file if directory doesn't exist
		; HOW: DirCreate creates nested folders automatically
		If Not FileExists($g_sDownloadDir) Then
			DirCreate($g_sDownloadDir)
			LogMessage("Created download directory: " & $g_sDownloadDir, True)
		EndIf

		; Get expected file size from server
		; WHAT: Query the server for the actual file size
		; WHY: Don't rely on hardcoded size - file might be updated
		; HOW: Use InetGetSize to query Content-Length header
		UpdateStatus("Checking file size on server...")
		Local $iExpectedSize = InetGetSize($g_sURL_ISO)

		If $iExpectedSize <= 0 Then
			; Couldn't get size from server
			; WHAT: Server didn't provide file size
			; WHY: Some servers don't send Content-Length, or network issue
			; HOW: Use a reasonable minimum as fallback (2.5 GB)
			LogMessage("WARNING: Could not determine file size from server, using fallback minimum")
			$iExpectedSize = 2500000000  ; 2.5 GB minimum fallback
		Else
			; Got size from server
			; WHAT: Server told us the file size
			; WHY: We can verify downloads against actual size
			; HOW: Log it for reference
			Local $sSizeMB = Round($iExpectedSize / 1048576, 1)
			UpdateStatus("Server reports file size: " & $sSizeMB & " MB")
			LogMessage("Remote file size: " & $iExpectedSize & " bytes (" & $sSizeMB & " MB)")
		EndIf

		; Check if ISO already exists
		; WHAT: See if we have the ISO from a previous download
		; WHY: Don't re-download if we already have it
		; HOW: Check portable cache first, then temp download dir

		; Check portable cache first (@ScriptDir\_Downloads)
		; WHAT: Look for ISO by its actual filename (derived from URL) in the portable cache
		; WHY: Custom hosting might use a different filename - match on what we'd actually download
		Local $sPortableISO = $g_sPortableDir & "\" & $sISOFilename
		If FileExists($sPortableISO) Then
			Local $iPortableSize = FileGetSize($sPortableISO)
			Local $iSizeDiff = Abs($iPortableSize - $iExpectedSize)
			Local $fPercentDiff = ($iSizeDiff / $iExpectedSize) * 100
			If $fPercentDiff <= 1 Then
				UpdateStatus("ISO found in portable cache: " & Round($iPortableSize / 1073741824, 2) & " GB")
				LogMessage("Using portable cache ISO: " & $sPortableISO)
				; Copy to temp download dir so rest of installer finds it
				FileCopy($sPortableISO, $sISOPath, 1)
				Return True
			EndIf
		EndIf

		; Check temp download dir
		If FileExists($sISOPath) Then
			Local $iFileSize = FileGetSize($sISOPath)

			; Compare with expected size
			; WHAT: Is our cached file the right size?
			; WHY: Could be incomplete download or outdated version
			; HOW: Check if within 1% of expected size (allows for minor variations)
			Local $iSizeDiff = Abs($iFileSize - $iExpectedSize)
			Local $fPercentDiff = ($iSizeDiff / $iExpectedSize) * 100

			If $fPercentDiff <= 1 Then
				; File size matches (within 1% tolerance)
				; WHAT: Cached file appears valid
				; WHY: Size matches server's reported size
				; HOW: Use existing file, skip download
				UpdateStatus("ISO found: " & Round($iFileSize / 1073741824, 2) & " GB")
				LogMessage("Using existing ISO: " & $sISOPath & " (" & $iFileSize & " bytes)")
				Return True
			Else
				; File size doesn't match
				; WHAT: Cached file is wrong size
				; WHY: Could be incomplete or outdated version
				; HOW: Delete and re-download
				UpdateStatus("ISO size mismatch, re-downloading...")
				LogMessage("Existing ISO size mismatch: " & $iFileSize & " vs " & $iExpectedSize & " (diff: " & Round($fPercentDiff, 2) & "%)")
				FileDelete($sISOPath)  ; Delete incorrect file
			EndIf
		EndIf

		; Download the ISO
		; WHAT: Download UT2004.ISO from configured URL
		; WHY: We need it and don't have it (or it was wrong size)
		; HOW: Call DownloadFileWithProgress function
		UpdateStatus("Downloading UT2004.ISO...")
		LogMessage("Starting ISO download from: " & $g_sURL_ISO)

		If Not DownloadFileWithProgress($g_sURL_ISO, $sISOPath, 0, 50) Then
			; Download failed
			UpdateStatus("Download failed")
			Return False
		EndIf

		; Verify downloaded file
		; WHAT: Make sure download completed successfully
		; WHY: Partial download would cause installation to fail
		; HOW: Check file exists and compare size with server's reported size
		If Not FileExists($sISOPath) Then
			UpdateStatus("Download verification failed: File not found")
			LogMessage("ERROR: Downloaded file not found: " & $sISOPath)
			Return False
		EndIf

		Local $iDownloadedSize = FileGetSize($sISOPath)
		Local $iSizeDiff = Abs($iDownloadedSize - $iExpectedSize)
		Local $fPercentDiff = ($iSizeDiff / $iExpectedSize) * 100

		If $fPercentDiff > 1 Then
			; Downloaded file size doesn't match expected (more than 1% difference)
			; WHAT: File size is significantly different
			; WHY: Download may have failed or been corrupted
			; HOW: Report error, delete bad file
			UpdateStatus("Download verification failed: Size mismatch")
			LogMessage("ERROR: Downloaded size " & $iDownloadedSize & " doesn't match expected " & $iExpectedSize & " (diff: " & Round($fPercentDiff, 2) & "%)")
			FileDelete($sISOPath)
			Return False
		EndIf

		UpdateStatus("ISO downloaded successfully: " & Round($iDownloadedSize / 1073741824, 2) & " GB")
		LogMessage("ISO download complete and verified: " & $iDownloadedSize & " bytes")

		Return True
	EndFunc

	Func Phase3_ExtractISO()
		; WHAT: Extract CAB files from UT2004.ISO
		; WHY: Need CAB files to extract game files
		; HOW: Use 7z.exe to extract only CAB files, flatten structure
		;
		; RETURN: True if extraction successful, False if failed

		UpdateStatus("Extracting CAB files from ISO...")
		LogMessage("Starting ISO extraction")

		; Define paths
		Local $sISOPath = $g_sDownloadDir & "\UT2004.ISO"
		Local $sCABOutputDir = $g_sTempCABs

		; Verify ISO exists
		; WHAT: Make sure we have the ISO to extract
		; WHY: Can't extract if ISO is missing
		; HOW: Check file exists
		If Not FileExists($sISOPath) Then
			UpdateStatus("Error: ISO file not found")
			LogMessage("ERROR: ISO not found at: " & $sISOPath)
			Return False
		EndIf

		; Create CAB output directory
		; WHAT: Make folder to store extracted CAB files
		; WHY: 7z needs output directory to exist
		; HOW: DirCreate (will clean if exists)
		If FileExists($sCABOutputDir) Then
			; Clean existing CABs from previous run
			DirRemove($sCABOutputDir, 1)  ; 1 = recursive delete
			LogMessage("Cleaned existing CAB directory")
		EndIf
		DirCreate($sCABOutputDir)
		LogMessage("Created CAB output directory: " & $sCABOutputDir)

		; Build 7z command
		; WHAT: Construct command to extract CAB and HDR files
		; WHY: We need both - HDR files are headers for InstallShield CAB groups
		; HOW: 7z.exe e (extract without paths) with multiple file patterns
		;
		; COMMAND BREAKDOWN:
		;   e           = Extract without directory structure (flatten)
		;   "ISO"       = Source ISO file (in quotes for spaces)
		;   -o"output"  = Output directory (no space between -o and path!)
		;   *.cab       = Extract CAB files
		;   *.hdr       = Extract HDR (header) files - needed for InstallShield CABs!
		;   -r          = Recursive (search all folders in ISO)
		;   -y          = Yes to all prompts (non-interactive)

		Local $s7zCommand = '"' & $g_s7Zip & '" e "' & $sISOPath & '" -o"' & $sCABOutputDir & '" *.cab *.hdr -r -y'

		LogMessage("Executing: " & $s7zCommand)
		UpdateStatus("Extracting CAB files (this may take a minute)...")

		; Update progress to 50% (start of extraction)
		GUICtrlSetData($g_idProgressBar, 50)

		; Run 7z extraction
		; WHAT: Execute 7-Zip to extract CABs
		; WHY: Need CABs extracted for next phase
		; HOW: RunWait executes and waits, returns exit code
		Local $iExitCode = RunWait($s7zCommand, @ScriptDir, @SW_HIDE)

		If $iExitCode <> 0 Then
			UpdateStatus("Error: 7-Zip extraction failed (exit code: " & $iExitCode & ")")
			LogMessage("ERROR: 7z.exe exit code: " & $iExitCode)

			; Try to see what's in the directory anyway for debugging
			Local $aDebug = _FileListToArray($sCABOutputDir, "*.*", $FLTA_FILES)
			If Not @error And $aDebug[0] > 0 Then
				LogMessage("Files found in output directory:")
				For $i = 1 To $aDebug[0]
					LogMessage("  - " & $aDebug[$i], True)
				Next
			Else
				LogMessage("Output directory is empty")
			EndIf

			Return False
		EndIf

		; Update progress to 60% (extraction complete)
		GUICtrlSetData($g_idProgressBar, 60)

		; Verify CABs were extracted
		; WHAT: Make sure we got some CAB files
		; WHY: Extraction might succeed but produce no files
		; HOW: Count CAB files in output directory
		Local $aCABs = _FileListToArray($sCABOutputDir, "*.cab", $FLTA_FILES)

		If @error Or $aCABs[0] = 0 Then
			UpdateStatus("Error: No CAB files found after extraction")
			LogMessage("ERROR: No CAB files in: " & $sCABOutputDir)
			Return False
		EndIf

		; Success!
		UpdateStatus("Extracted " & $aCABs[0] & " CAB files")
		LogMessage("Successfully extracted " & $aCABs[0] & " CAB files")

		; Log CAB filenames
		For $i = 1 To $aCABs[0]
			LogMessage("  - " & $aCABs[$i], True)  ; Log only, no GUI update
		Next

		Return True
	EndFunc

	Func Phase4_ExtractCABs()
		; WHAT: Extract game files from CAB files
		; WHY: CABs contain the actual game files we need
		; HOW: Use unshield.exe to extract each CAB to temp directory
		;
		; RETURN: True if extraction successful, False if failed

		UpdateStatus("Preparing to extract game files...")
		LogMessage("Starting CAB extraction (Phase 4)")

		; Define paths
		Local $sCABDir = $g_sTempCABs
		Local $sExtractDir = $g_sTempDir & "\_Temp_Extracted"

		; Create extraction directory
		; WHAT: Make folder to store extracted game files
		; WHY: Need somewhere to put the files
		; HOW: DirCreate (clean if exists)
		If FileExists($sExtractDir) Then
			DirRemove($sExtractDir, 1)  ; Clean existing
			LogMessage("Cleaned existing extraction directory")
		EndIf
		DirCreate($sExtractDir)
		LogMessage("Created extraction directory: " & $sExtractDir)

		; Get list of CAB files
		; WHAT: Find all CAB files to extract
		; WHY: Need to process each one
		; HOW: _FileListToArray gets all *.cab files
		Local $aCABs = _FileListToArray($sCABDir, "*.cab", $FLTA_FILES)

		If @error Or $aCABs[0] = 0 Then
			UpdateStatus("Error: No CAB files found")
			LogMessage("ERROR: No CAB files in: " & $sCABDir)
			Return False
		EndIf

		LogMessage("Found " & $aCABs[0] & " CAB files to extract")

		; Find the HDR file
		; WHAT: Look for data1.hdr (InstallShield header file)
		; WHY: unshield needs the HDR file to extract the CAB group
		; HOW: Check if data1.hdr exists
		Local $sHDRFile = $sCABDir & "\data1.hdr"

		If Not FileExists($sHDRFile) Then
			UpdateStatus("Error: data1.hdr not found")
			LogMessage("ERROR: InstallShield header file not found: " & $sHDRFile)
			LogMessage("NOTE: InstallShield CABs require the .hdr file to extract")
			Return False
		EndIf

		LogMessage("Found InstallShield header: data1.hdr")

		; Update progress to 60% (start of CAB extraction)
		GUICtrlSetData($g_idProgressBar, 60)

		; Extract the InstallShield cabinet group
		; WHAT: Use unshield to extract all CABs in the group
		; WHY: InstallShield CABs work as a group, not individually
		; HOW: Run unshield with the HDR file - it will extract all related CABs

		UpdateStatus("Extracting game files from InstallShield cabinets...")
		LogMessage("Extracting InstallShield cabinet group")

		; Build unshield command
		; WHAT: Construct command to extract InstallShield cabinet group
		; WHY: unshield uses the HDR file to know about all CABs in the group
		; HOW: unshield x "data1.hdr" -d "outputdir"
		;
		; COMMAND BREAKDOWN:
		;   x             = Extract mode
		;   "data1.hdr"   = Header file (describes the cabinet group)
		;   -d "dir"      = Destination directory

		Local $sUnshieldCommand = '"' & $g_sUnshield & '" x "' & $sHDRFile & '" -d "' & $sExtractDir & '"'

		LogMessage("Executing: " & $sUnshieldCommand)

		; Run unshield
		; WHAT: Execute unshield to extract all CABs
		; WHY: Get all the game files
		; HOW: RunWait executes and returns exit code
		Local $iExitCode = RunWait($sUnshieldCommand, @ScriptDir, @SW_HIDE)

		If $iExitCode <> 0 Then
			LogMessage("WARNING: unshield returned exit code: " & $iExitCode)
			; Continue anyway - unshield often returns non-zero even on success
		EndIf

		; Update progress to 70% (extraction in progress)
		GUICtrlSetData($g_idProgressBar, 70)

		; Verify extraction
		; WHAT: Make sure we got some files
		; WHY: Extraction might fail silently
		; HOW: Check if extraction directory has subdirectories
		Local $aDirs = _FileListToArray($sExtractDir, "*", $FLTA_FOLDERS)

		If @error Or $aDirs[0] = 0 Then
			UpdateStatus("Error: No files extracted from CABs")
			LogMessage("ERROR: Extraction directory is empty: " & $sExtractDir)
			Return False
		EndIf

		; Success!
		UpdateStatus("Extracted " & $aCABs[0] & " CAB files successfully")
		LogMessage("CAB extraction complete. Found " & $aDirs[0] & " directories in extraction folder")

		; Log directory structure
		LogMessage("Extracted directories:")
		For $i = 1 To $aDirs[0]
			LogMessage("  - " & $aDirs[$i], True)
		Next

		; Update progress to 75% (CAB extraction complete)
		GUICtrlSetData($g_idProgressBar, 75)

		Return True
	EndFunc

	Func Phase5_CopyFiles()
		; WHAT: Copy extracted game files to installation directory
		; WHY: Move files from temp extraction to final install location
		; HOW: Copy folders with proper naming, skip unwanted folders
		;
		; RETURN: True if copy successful, False if failed

		UpdateStatus("Copying game files to installation directory...")
		LogMessage("Starting file copy (Phase 5)")

		; Define paths
		Local $sExtractDir = $g_sTempDir & "\_Temp_Extracted"
		Local $sInstallDir = $g_sInstallPath

		; Update progress to 75% (start of copy)
		GUICtrlSetData($g_idProgressBar, 75)

		; Copy All_* folders (simple rename)
		; WHAT: Copy folders that start with "All_"
		; WHY: These contain main game files
		; HOW: Loop through, remove "All_" prefix, copy
		Local $aFolders = _FileListToArray($sExtractDir, "All_*", $FLTA_FOLDERS)

		If Not @error And $aFolders[0] > 0 Then
			LogMessage("Copying " & $aFolders[0] & " 'All_*' folders")

			For $i = 1 To $aFolders[0]
				Local $sSrcFolder = $sExtractDir & "\" & $aFolders[$i]
				Local $sDestName = StringReplace($aFolders[$i], "All_", "")  ; Remove "All_" prefix

				; Special handling for All_UT2004.EXE → System
				If $aFolders[$i] = "All_UT2004.EXE" Then
					$sDestName = "System"
				EndIf

				Local $sDestFolder = $sInstallDir & "\" & $sDestName

				UpdateStatus("Copying " & $sDestName & "...")
				LogMessage("Copying: " & $aFolders[$i] & " → " & $sDestName)

				; Copy folder
				If Not DirCopy($sSrcFolder, $sDestFolder, 1) Then  ; 1 = overwrite
					LogMessage("ERROR: Failed to copy " & $aFolders[$i])
					Return False
				EndIf
			Next
		EndIf

		; Update progress to 80%
		GUICtrlSetData($g_idProgressBar, 80)

		; Copy English_Manual → Manual
		UpdateStatus("Copying manual...")
		If FileExists($sExtractDir & "\English_Manual") Then
			LogMessage("Copying: English_Manual → Manual")
			If Not DirCopy($sExtractDir & "\English_Manual", $sInstallDir & "\Manual", 1) Then
				LogMessage("WARNING: Failed to copy Manual")
			EndIf
		EndIf

		; Update progress to 82%
		GUICtrlSetData($g_idProgressBar, 82)

		; Handle English_Sounds_Speech_System_Help (complex merge)
		; WHAT: Copy subfolders to different locations
		; WHY: This folder contains files for Help, Sounds, Speech, and System
		; HOW: Copy each subfolder separately
		Local $sEnglishBase = $sExtractDir & "\English_Sounds_Speech_System_Help"

		If FileExists($sEnglishBase) Then
			LogMessage("Processing English_Sounds_Speech_System_Help folder")

			; Copy Help subfolder (merge with existing Help)
			If FileExists($sEnglishBase & "\Help") Then
				UpdateStatus("Copying Help files...")
				LogMessage("Copying: English_...\Help → Help (merge)")
				FileCopy($sEnglishBase & "\Help\*.*", $sInstallDir & "\Help\", 1)  ; 1 = overwrite
			EndIf

			; Copy Sounds subfolder (new folder)
			If FileExists($sEnglishBase & "\Sounds") Then
				UpdateStatus("Copying Sounds...")
				LogMessage("Copying: English_...\Sounds → Sounds")
				DirCopy($sEnglishBase & "\Sounds", $sInstallDir & "\Sounds", 1)
			EndIf

			; Copy Speech subfolder (new folder)
			If FileExists($sEnglishBase & "\Speech") Then
				UpdateStatus("Copying Speech...")
				LogMessage("Copying: English_...\Speech → Speech")
				DirCopy($sEnglishBase & "\Speech", $sInstallDir & "\Speech", 1)
			EndIf

			; Copy System subfolder (merge with existing System)
			If FileExists($sEnglishBase & "\System") Then
				UpdateStatus("Copying System files...")
				LogMessage("Copying: English_...\System → System (merge)")
				FileCopy($sEnglishBase & "\System\*.*", $sInstallDir & "\System\", 1)

				; Copy System\editorres subfolder if exists
				If FileExists($sEnglishBase & "\System\editorres") Then
					LogMessage("Copying: System\editorres subfolder")
					DirCopy($sEnglishBase & "\System\editorres", $sInstallDir & "\System\editorres", 1)
				EndIf
			EndIf
		EndIf

		; Update progress to 85%
		GUICtrlSetData($g_idProgressBar, 85)

		; Verify critical files exist
		; WHAT: Make sure essential game files were copied
		; WHY: Installation is useless without these
		; HOW: Check for UT2004.exe and other critical files
		UpdateStatus("Verifying installation...")
		LogMessage("Verifying critical files")

		Local $bValid = True

		If Not FileExists($sInstallDir & "\System\UT2004.exe") Then
			LogMessage("ERROR: UT2004.exe not found!")
			$bValid = False
		EndIf

		If Not FileExists($sInstallDir & "\System\Core.dll") Then
			LogMessage("WARNING: Core.dll not found")
		EndIf

		If Not FileExists($sInstallDir & "\System\Engine.dll") Then
			LogMessage("WARNING: Engine.dll not found")
		EndIf

		; Check for at least some map files
		Local $aMaps = _FileListToArray($sInstallDir & "\Maps", "*.ut2", $FLTA_FILES)
		If @error Or $aMaps[0] = 0 Then
			LogMessage("WARNING: No map files found")
		Else
			LogMessage("Found " & $aMaps[0] & " map files")
		EndIf

		If Not $bValid Then
			UpdateStatus("Installation verification failed")
			Return False
		EndIf

		; Update progress to 90%
		GUICtrlSetData($g_idProgressBar, 90)

		; Copy Uninstaller.exe to System folder
		UpdateStatus("Installing uninstaller...")
		LogMessage("Copying Uninstaller.exe to System folder")
		Local $sUninstallSource = @TempDir & "\UT2004_Install_Tools\Uninstaller.exe"
		Local $sUninstallDest = $sInstallDir & "\System\Uninstaller.exe"

		If FileExists($sUninstallSource) Then
			FileCopy($sUninstallSource, $sUninstallDest, 1)
			If FileExists($sUninstallDest) Then
				LogMessage("Uninstaller.exe copied successfully")
			Else
				LogMessage("WARNING: Failed to copy Uninstaller.exe")
			EndIf
		Else
			LogMessage("WARNING: Uninstaller.exe not found in tools directory")
		EndIf

		UpdateStatus("Files copied successfully")
		LogMessage("File copy complete - all game files installed")

		Return True
	EndFunc

	Func Phase5b_PatchAndRegistry()
		; WHAT: Apply OldUnreal patch and write registry entries
		; WHY: Game needs latest patch and registry integration
		; HOW: Download patch from GitHub, extract, write full registry set
		;
		; RETURN: True if successful, False if failed

		UpdateStatus("Applying OldUnreal patch...")
		LogMessage("Starting Phase 5b: Patch and Registry")

		; Update progress to 90%
		GUICtrlSetData($g_idProgressBar, 90)

		; Step 1: Query GitHub for latest patch
		UpdateStatus("Checking for latest OldUnreal patch...")
		LogMessage("Querying GitHub API for latest patch")

		Local $sAPIUrl = "https://api.github.com/repos/OldUnreal/UT2004Patches/releases/latest"
		Local $sAPIResponse = InetRead($sAPIUrl, $INET_FORCERELOAD)

		If @error Then
			LogMessage("ERROR: Failed to query GitHub API")
			Return False
		EndIf

		; Convert binary response to string
		Local $sJSON = BinaryToString($sAPIResponse)

		; Parse JSON to find Windows patch
		; WHAT: Extract download URL for Windows patch
		; WHY: Need the correct platform-specific patch
		; HOW: Find asset with "Windows" and ".zip" in name
		Local $sDownloadURL = ""

		; Extract tag_name (version)
		$aVersion = StringRegExp($sJSON, '"tag_name"\s*:\s*"([^"]+)"', 1)
		If Not @error And UBound($aVersion) > 0 Then
			$sPatchVersion = $aVersion[0]
			LogMessage("Latest patch version: " & $sPatchVersion)
		EndIf

		; Find Windows patch download URL
		Local $aAssets = StringRegExp($sJSON, '"browser_download_url"\s*:\s*"([^"]+Windows[^"]+\.zip)"', 3)
		If Not @error And UBound($aAssets) > 0 Then
			$sDownloadURL = $aAssets[0]
			LogMessage("Windows patch URL: " & $sDownloadURL)
		Else
			LogMessage("ERROR: Could not find Windows patch in release")
			Return False
		EndIf

		; Step 2: Download patch
		Local $sPatchFile = $g_sDownloadDir & "\OldUnreal-Patch.zip"

		; Check portable cache first
		Local $sPortablePatch = $g_sPortableDir & "\OldUnreal-Patch.zip"
		If FileExists($sPortablePatch) Then
			UpdateStatus("Patch found in portable cache, skipping download...")
			LogMessage("Using portable cache patch: " & $sPortablePatch)
			FileCopy($sPortablePatch, $sPatchFile, 1)
		ElseIf FileExists($sPatchFile) Then
			UpdateStatus("Patch found in temp cache, skipping download...")
			LogMessage("Using temp cache patch: " & $sPatchFile)
		Else
			UpdateStatus("Downloading OldUnreal patch...")
			LogMessage("Downloading patch to: " & $sPatchFile)

			; Use InetGet to download (90% → 92%)
			Local $hDownload = InetGet($sDownloadURL, $sPatchFile, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)

			; Wait for download with progress
			While Not InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
				Local $iBytesRead = InetGetInfo($hDownload, $INET_DOWNLOADREAD)
				Local $iTotalSize = InetGetInfo($hDownload, $INET_DOWNLOADSIZE)

				If $iTotalSize > 0 Then
					Local $sMB = Round($iBytesRead / 1048576, 1)
					Local $sTotalMB = Round($iTotalSize / 1048576, 1)
					GUICtrlSetData($g_idLabelStatus, "Downloading patch: " & $sMB & " MB / " & $sTotalMB & " MB")
				EndIf

				Sleep(100)
			WEnd
			InetClose($hDownload)
		EndIf

		If Not FileExists($sPatchFile) Then
			LogMessage("ERROR: Patch download failed")
			Return False
		EndIf

		LogMessage("Patch downloaded: " & FileGetSize($sPatchFile) & " bytes")
		GUICtrlSetData($g_idProgressBar, 92)

		; Step 3: Extract patch to install directory
		UpdateStatus("Extracting patch...")
		LogMessage("Extracting patch to: " & $g_sInstallPath)

		Local $s7zCommand = '"' & $g_s7Zip & '" x "' & $sPatchFile & '" -o"' & $g_sInstallPath & '" -y'
		LogMessage("Executing: " & $s7zCommand)

		Local $iExitCode = RunWait($s7zCommand, @ScriptDir, @SW_HIDE)

		If $iExitCode <> 0 Then
			LogMessage("ERROR: Patch extraction failed with exit code: " & $iExitCode)
			Return False
		EndIf

		LogMessage("Patch extracted successfully")
		GUICtrlSetData($g_idProgressBar, 94)

		; Step 4: Write registry entries
		UpdateStatus("Writing registry entries...")
		LogMessage("Writing registry entries")

		; WHAT: Write full registry set for maximum compatibility
		; WHY: Some tools/mods might check these values
		; HOW: Write all 9 values like official installer to BOTH locations

		; Write to both registry locations for compatibility
		; WHAT: Write to 64-bit and 32-bit registry views
		; WHY: OldUnreal installer writes to both, some tools check different locations
		; HOW: Write to WOW6432Node (32-bit view) and normal (64-bit view)
		Local $aRegKeys[2]
		$aRegKeys[0] = "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Unreal Technology\Installed Apps\UT2004"
		$aRegKeys[1] = "HKEY_LOCAL_MACHINE\SOFTWARE\Unreal Technology\Installed Apps\UT2004"

		For $i = 0 To 1
			Local $sRegKey = $aRegKeys[$i]

			; Required - Install folder
			RegWrite($sRegKey, "Folder", "REG_SZ", $g_sInstallPath)

			; Optional - CD Key (blank if not provided)
			RegWrite($sRegKey, "CDKey", "REG_SZ", $g_sCDKey)

			; Compatibility values (same as official installer)
			RegWrite($sRegKey, "Version", "REG_SZ", "3369")
			RegWrite($sRegKey, "YEAR", "REG_SZ", "2004")
			RegWrite($sRegKey, "TITLEBAR", "REG_SZ", "Unreal Tournament 2004")
			RegWrite($sRegKey, "ADMIN_RIGHTS", "REG_SZ", "You need to run this program as an administrator, not as a guest or limited user account.")
			RegWrite($sRegKey, "NO_DISC", "REG_SZ", "No disc in drive.  Please insert the disc labelled Unreal Tournament 2004 Play Disc to continue.")
			RegWrite($sRegKey, "NO_DRIVE", "REG_SZ", "No CD-ROM or DVD-ROM drive detected.")
			RegWrite($sRegKey, "WRONG_DISC", "REG_SZ", "Wrong disc in drive.  Please insert the disc labelled Unreal Tournament 2004 Play Disc to continue.")

			If $i = 0 Then
				LogMessage("Registry written to: WOW6432Node (32-bit view)")
			Else
				LogMessage("Registry written to: Normal (64-bit view)")
			EndIf
		Next

		LogMessage("Registry: Folder = " & $g_sInstallPath)
		If $g_sCDKey <> "" Then
			LogMessage("Registry: CDKey = " & $g_sCDKey)
		Else
			LogMessage("Registry: CDKey = (blank)")
		EndIf
		LogMessage("Registry: All compatibility values written to both locations")

		; Step 5: Create uninstall entry (also write to both locations)
		UpdateStatus("Creating uninstall entry...")
		LogMessage("Creating uninstall entry")

		; Create uninstall entry (only in WOW6432Node for 32-bit app)
		Local $sUninstallKey = "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\UT2004_Community"

		RegWrite($sUninstallKey, "DisplayName", "REG_SZ", "Unreal Tournament 2004")
		RegWrite($sUninstallKey, "DisplayVersion", "REG_SZ", $sPatchVersion)
		RegWrite($sUninstallKey, "Publisher", "REG_SZ", "Epic Games / Community Installer")
		RegWrite($sUninstallKey, "DisplayIcon", "REG_SZ", $g_sInstallPath & "\System\UT2004.exe")
		RegWrite($sUninstallKey, "InstallLocation", "REG_SZ", $g_sInstallPath)
		RegWrite($sUninstallKey, "UninstallString", "REG_SZ", '"' & $g_sInstallPath & '\System\Uninstaller.exe"')
		RegWrite($sUninstallKey, "NoModify", "REG_DWORD", 1)
		RegWrite($sUninstallKey, "NoRepair", "REG_DWORD", 1)

		LogMessage("Uninstall entry created in WOW6432Node registry")
		GUICtrlSetData($g_idProgressBar, 95)

		; Step 6: Register file associations (if checkbox checked)
		; WHAT: Register ut2004:// protocol and .ut4mod extension
		; WHY: Allows launching from browsers and opening mod files
		; HOW: Write to HKEY_LOCAL_MACHINE\SOFTWARE\Classes
		Local $bRegisterFileAssoc = (GUICtrlRead($g_idCheckboxFileAssoc) = $GUI_CHECKED)

		If $bRegisterFileAssoc Then
			UpdateStatus("Registering file associations...")
			LogMessage("Registering file associations")

			; Register ut2004:// URL protocol
			; WHAT: Allow ut2004:// URLs to launch the game
			; WHY: Server browsers and websites can use ut2004://join/server links
			; HOW: Create protocol handler in registry
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\ut2004", "", "REG_SZ", "URL:UT2004 Protocol")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\ut2004", "URL Protocol", "REG_SZ", "")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\ut2004\shell\open\command", "", "REG_SZ", '"' & $g_sInstallPath & '\System\UT2004.exe" "%1"')
			LogMessage("Registered ut2004:// protocol handler")

			; Register .ut4mod file extension
			; WHAT: Associate .ut4mod files with UT2004
			; WHY: Double-clicking mod files opens them with the game
			; HOW: Create file extension association
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.ut4mod", "", "REG_SZ", "UT2004.Mod")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\UT2004.Mod", "", "REG_SZ", "UT2004 Mod File")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\UT2004.Mod\DefaultIcon", "", "REG_SZ", $g_sInstallPath & "\System\UT2004.exe,0")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\UT2004.Mod\shell\open\command", "", "REG_SZ", '"' & $g_sInstallPath & '\System\UT2004.exe" "%1"')
			LogMessage("Registered .ut4mod file association")

			LogMessage("File associations registered successfully")
		Else
			LogMessage("File associations not registered (user choice)")
		EndIf

		; Step 7: Add Windows Firewall exception (if checkbox checked)
		Local $bAddFirewall = (GUICtrlRead($g_idCheckboxFirewall) = $GUI_CHECKED)

		If $bAddFirewall Then
			UpdateStatus("Adding Windows Firewall exception...")
			LogMessage("Adding Windows Firewall exception for UT2004")
			AddFirewallRules()
		Else
			LogMessage("Firewall exception not added (user choice)")
		EndIf

		UpdateStatus("Patch and registry complete")
		LogMessage("Phase 5b complete")

		Return True
	EndFunc

	Func Phase5c_Shortcuts()
		; WHAT: Create desktop, start menu and install root shortcuts
		; WHY: User needs easy access to game from multiple locations
		; HOW: FileCreateShortcut to each location
		; NOTE: Keep Files and temp cleanup are handled in Phase_Finalise()
		;       which runs after all bonus packs and the patch are installed
		;
		; RETURN: True if successful, False if failed (non-critical)

		UpdateStatus("Creating shortcuts...")
		LogMessage("Starting Phase 5c: Shortcuts")

		; Update progress to 96%
		GUICtrlSetData($g_idProgressBar, 96)

		Local $sExePath = $g_sInstallPath & "\System\UT2004.exe"
		Local $sUnrealEdExe = $g_sInstallPath & "\System\UnrealEd.exe"
		Local $sManualPath = $g_sInstallPath & "\Manual\Manual.pdf"

		; Step 1: Create Desktop shortcut
		; WHAT: Create UT2004.lnk on desktop
		; WHY: Easy access to launch game
		; HOW: FileCreateShortcut to desktop
		Local $sDesktopPath = @DesktopDir & "\UT2004.lnk"
		LogMessage("Creating desktop shortcut: " & $sDesktopPath)
		FileCreateShortcut($sExePath, $sDesktopPath, $g_sInstallPath & "\System", "", "Unreal Tournament 2004", $sExePath, "", "0")

		If FileExists($sDesktopPath) Then
			LogMessage("Desktop shortcut created successfully")
		Else
			LogMessage("WARNING: Failed to create desktop shortcut")
		EndIf

		; Step 2: Create Start Menu shortcut
		; WHAT: Create UT2004.lnk in Start Menu
		; WHY: Standard location for program shortcuts
		; HOW: FileCreateShortcut to Start Menu Programs folder
		Local $sStartMenuPath = @ProgramsDir & "\Unreal Tournament 2004"
		If Not FileExists($sStartMenuPath) Then DirCreate($sStartMenuPath)

		Local $sStartMenuShortcut = $sStartMenuPath & "\UT2004.lnk"
		LogMessage("Creating Start Menu shortcut: " & $sStartMenuShortcut)
		FileCreateShortcut($sExePath, $sStartMenuShortcut, $g_sInstallPath & "\System", "", "Unreal Tournament 2004", $sExePath, "", "0")

		If FileExists($sStartMenuShortcut) Then
			LogMessage("Start Menu shortcut created successfully")
		Else
			LogMessage("WARNING: Failed to create Start Menu shortcut")
		EndIf

		; Step 2b: Create Start Menu UnrealEd shortcut
		; WHAT: Create UnrealEd.lnk in Start Menu
		; WHY: Easy access to Unreal Editor from Start Menu
		; HOW: FileCreateShortcut to Start Menu Programs folder
		Local $sStartMenuUnrealEd = $sStartMenuPath & "\UnrealEd.lnk"
		LogMessage("Creating Start Menu UnrealEd shortcut: " & $sStartMenuUnrealEd)
		FileCreateShortcut($sUnrealEdExe, $sStartMenuUnrealEd, $g_sInstallPath & "\System", "", "UnrealEd", $sUnrealEdExe, "", "0")

		If FileExists($sStartMenuUnrealEd) Then
			LogMessage("Start Menu UnrealEd shortcut created successfully")
		Else
			LogMessage("WARNING: Failed to create Start Menu UnrealEd shortcut")
		EndIf

		; Step 2c: Create Start Menu Manual shortcut
		; WHAT: Create Manual.lnk in Start Menu
		; WHY: Easy access to UT2004 manual from Start Menu
		; HOW: FileCreateShortcut pointing to Manual\Manual.pdf
		Local $sStartMenuManual = $sStartMenuPath & "\Manual.lnk"
		LogMessage("Creating Start Menu Manual shortcut: " & $sStartMenuManual)
		FileCreateShortcut($sManualPath, $sStartMenuManual, $g_sInstallPath & "\Manual", "", "UT2004 Manual", "", "", "0")

		If FileExists($sStartMenuManual) Then
			LogMessage("Start Menu Manual shortcut created successfully")
		Else
			LogMessage("WARNING: Failed to create Start Menu Manual shortcut")
		EndIf

		; Step 3: Create install root shortcut
		; WHAT: Create UT2004.lnk in the game's root install folder
		; WHY: Convenient launch point when browsing install directory
		; HOW: FileCreateShortcut to install root
		Local $sRootShortcut = $g_sInstallPath & "\UT2004.lnk"
		LogMessage("Creating install root shortcut: " & $sRootShortcut)
		FileCreateShortcut($sExePath, $sRootShortcut, $g_sInstallPath & "\System", "", "Unreal Tournament 2004", $sExePath, "", "0")

		If FileExists($sRootShortcut) Then
			LogMessage("Install root shortcut created successfully")
		Else
			LogMessage("WARNING: Failed to create install root shortcut")
		EndIf

		; Step 4: Create UnrealEd shortcut in install root
		; WHAT: Create UnrealEd.lnk in the game's root install folder
		; WHY: Convenient access to the Unreal Editor from the install directory
		; HOW: FileCreateShortcut pointing to System\UnrealEd.exe
		Local $sUnrealEdShortcut = $g_sInstallPath & "\UnrealEd.lnk"
		LogMessage("Creating UnrealEd shortcut: " & $sUnrealEdShortcut)
		FileCreateShortcut($sUnrealEdExe, $sUnrealEdShortcut, $g_sInstallPath & "\System", "", "UnrealEd", $sUnrealEdExe, "", "0")

		If FileExists($sUnrealEdShortcut) Then
			LogMessage("UnrealEd shortcut created successfully")
		Else
			LogMessage("WARNING: Failed to create UnrealEd shortcut")
		EndIf

		; Update progress to 97%
		GUICtrlSetData($g_idProgressBar, 97)

		UpdateStatus("Shortcuts created")
		LogMessage("Phase 5c complete")

		Return True
	EndFunc

	Func Phase_ConfigureGame()
		; WHAT: Copy Default.ini to UT2004.ini and patch with user's chosen settings
		; WHY: Gives user correct resolution and max detail on first launch
		;      without waiting for the game's auto-detect to lower everything
		; HOW: FileCopy Default.ini → UT2004.ini, then IniWrite chosen values
		;
		; RETURN: True always (non-critical)

		LogMessage("Starting Phase ConfigureGame: INI patching")

		Local $sSystemDir  = $g_sInstallPath & "\System"
		Local $sDefaultIni = $sSystemDir & "\Default.ini"
		Local $sUT2004Ini  = $sSystemDir & "\UT2004.ini"
		Local $sSection    = "WinDrv.WindowsClient"

		; Copy Default.ini to UT2004.ini as clean base
		; WHAT: Use Default.ini as the source rather than an existing UT2004.ini
		; WHY: Ensures consistent clean base regardless of any previous install state
		If Not FileExists($sDefaultIni) Then
			LogMessage("WARNING: Default.ini not found - skipping INI configuration")
			Return True
		EndIf

		UpdateStatus("Configuring game settings...")
		FileCopy($sDefaultIni, $sUT2004Ini, 1)  ; 1 = overwrite
		LogMessage("Copied Default.ini to UT2004.ini")

		; === AUTO RESOLUTION ===
		Local $bAutoRes = (GUICtrlRead($g_idCheckboxAutoRes) = $GUI_CHECKED)

		If $bAutoRes And $g_iDetectedWidth > 0 Then
			LogMessage("Applying auto resolution: " & $g_iDetectedWidth & "x" & $g_iDetectedHeight & " @ " & $g_iDetectedRefresh & "Hz")

			IniWrite($sUT2004Ini, $sSection, "FullscreenViewportX", $g_iDetectedWidth)
			IniWrite($sUT2004Ini, $sSection, "FullscreenViewportY", $g_iDetectedHeight)
			IniWrite($sUT2004Ini, $sSection, "WindowedViewportX",   $g_iDetectedWidth)
			IniWrite($sUT2004Ini, $sSection, "WindowedViewportY",   $g_iDetectedHeight)
			IniWrite($sUT2004Ini, $sSection, "MaxMenuFrameRate",    $g_iDetectedRefresh)
			IniWrite($sUT2004Ini, $sSection, "MaxOfflineFrameRate", $g_iDetectedRefresh)
			IniWrite($sUT2004Ini, $sSection, "MaxOnlineFrameRate",  $g_iDetectedRefresh)

			LogMessage("Resolution patched successfully")
		Else
			LogMessage("Auto resolution skipped (unchecked or detection failed)")
		EndIf

		; === MAX DETAIL ===
		Local $bMaxDetail = (GUICtrlRead($g_idCheckboxMaxDetail) = $GUI_CHECKED)

		If $bMaxDetail Then
			LogMessage("Applying maximum detail settings")

			; [WinDrv.WindowsClient] detail settings
			IniWrite($sUT2004Ini, $sSection, "Decals",                  "True")
			IniWrite($sUT2004Ini, $sSection, "Coronas",                 "True")
			IniWrite($sUT2004Ini, $sSection, "DecoLayers",              "True")
			IniWrite($sUT2004Ini, $sSection, "NoDynamicLights",         "False")
			IniWrite($sUT2004Ini, $sSection, "TextureDetailTerrain",    "UltraHigh")
			IniWrite($sUT2004Ini, $sSection, "TextureDetailWeaponSkin", "UltraHigh")
			IniWrite($sUT2004Ini, $sSection, "TextureDetailPlayerSkin", "UltraHigh")
			IniWrite($sUT2004Ini, $sSection, "TextureDetailWorld",      "UltraHigh")
			IniWrite($sUT2004Ini, $sSection, "TextureDetailRenderMap",  "UltraHigh")
			IniWrite($sUT2004Ini, $sSection, "TextureDetailLightmap",   "UltraHigh")
			IniWrite($sUT2004Ini, $sSection, "NoFractalAnim",           "False")

			; Physics and mesh detail
			IniWrite($sUT2004Ini, "Engine.GameEngine", "PhysicsDetailLevel",    "PDL_High")
			IniWrite($sUT2004Ini, "Engine.GameEngine", "MeshLODDetailLevel",    "MDL_Ultra")
			IniWrite($sUT2004Ini, "Engine.GameEngine", "HighDetailActors",      "True")
			IniWrite($sUT2004Ini, "Engine.GameEngine", "SuperHighDetailActors", "True")
			IniWrite($sUT2004Ini, "Engine.GameEngine", "DecalStayScale",        "2.000000")

			; Protect Max Detail on First Run

			Local $iVersion = StringLeft (StringRegExpReplace($aVersion[0], "[^0-9]", ""), 4)
			IniWrite($sUT2004Ini, "FirstRun", "FirstRun", $iVersion)

			LogMessage("Maximum detail settings patched successfully")
		Else
			LogMessage("Maximum detail skipped (unchecked)")
		EndIf

		LogMessage("Phase ConfigureGame complete")
		Return True
	EndFunc

	Func Phase_Finalise()
		; WHAT: Clean up temp working folders, move or delete _Downloads
		; WHY: Must run AFTER all bonus packs and patch so all downloads are present
		;      Extracted folders are large and never needed after install
		;      install.log is always preserved in @TempDir\UT2004_Install
		; HOW:
		;   Both branches: delete all extracted/working folders
		;   Keep Files checked:   DirMove _Downloads → @ScriptDir\_Downloads
		;   Keep Files unchecked: DirRemove _Downloads
		;
		; RETURN: True always (non-critical)

		LogMessage("Starting Phase Finalise: Cleanup and Keep Files")

		UpdateStatus("Cleaning up temporary files...")

		; === ALWAYS: Delete extracted/working folders ===
		; WHAT: Remove all large working folders that are no longer needed
		; WHY:  These can be several GB - no reason to keep them regardless of Keep Files setting
		; HOW:  DirRemove each folder individually, leaving install.log untouched
		Local $aCleanupDirs[6] = [ _
			$g_sTempDir & "\_MegaPack_Extracted", _
			$g_sTempDir & "\_CBP1_Extracted", _
			$g_sTempDir & "\_CBP2V1_Extracted", _
			$g_sTempDir & "\_CBP2V2_Extracted", _
			$g_sTempDir & "\_Temp_CABs", _
			$g_sTempDir & "\_Temp_Extracted" _
		]

		For $sDir In $aCleanupDirs
			If FileExists($sDir) Then
				DirRemove($sDir, 1)
				If Not FileExists($sDir) Then
					LogMessage("Deleted: " & $sDir)
				Else
					LogMessage("WARNING: Could not delete: " & $sDir)
				EndIf
			EndIf
		Next

		; === BRANCH: Handle _Downloads based on Keep Files setting ===
		Local $bKeepFiles = (GUICtrlRead($g_idCheckboxKeepFiles) = $GUI_CHECKED)

		If $bKeepFiles Then
			; Move _Downloads to @ScriptDir\_Downloads (portable cache)
			UpdateStatus("Saving installer files...")
			LogMessage("'Keep installer files' is checked - moving downloads to portable cache")

			If FileExists($g_sDownloadDir) Then
				; Remove existing portable cache if present (clean slate)
				If FileExists($g_sPortableDir) Then
					DirRemove($g_sPortableDir, 1)
				EndIf

				; Move _Downloads from temp to script dir
				; WHAT: Move entire _Downloads folder (archives only - extracted content already deleted above)
				; WHY: Makes install portable - next install finds cached files next to exe
				; HOW: DirMove works same-drive (instant) and cross-drive (file copy + delete)
				If DirMove($g_sDownloadDir, $g_sPortableDir) Then
					LogMessage("Downloads moved to portable cache: " & $g_sPortableDir)
				Else
					LogMessage("WARNING: DirMove failed - portable cache not saved")
				EndIf
			EndIf

			; Save install log to game's Installer folder for reference
			Local $sInstallerDir = $g_sInstallPath & "\Installer"
			If Not FileExists($sInstallerDir) Then DirCreate($sInstallerDir)
			If $g_hLogFile <> 0 And $g_hLogFile <> -1 Then FileFlush($g_hLogFile)
			Local $sLogSource = $g_sTempDir & "\install.log"
			If FileExists($sLogSource) Then
				FileCopy($sLogSource, $sInstallerDir & "\install.log", 1)
				LogMessage("Install log saved to: " & $sInstallerDir)
			EndIf

			LogMessage("Portable cache ready at: " & $g_sPortableDir)
		Else
			; Delete _Downloads - user doesn't want to keep files
			LogMessage("'Keep installer files' is unchecked - deleting downloads")

			If FileExists($g_sDownloadDir) Then
				DirRemove($g_sDownloadDir, 1)
				If Not FileExists($g_sDownloadDir) Then
					LogMessage("Downloads deleted successfully")
				Else
					LogMessage("WARNING: Could not fully delete downloads folder")
				EndIf
			EndIf
		EndIf

		; install.log remains at $g_sTempDir\install.log
		LogMessage("install.log preserved at: " & $g_sTempDir & "\install.log")

		; Update progress to 99%
		GUICtrlSetData($g_idProgressBar, 99)

		LogMessage("Phase Finalise complete")
		Return True
	EndFunc

	Func Phase6_InstallMegaPack()
		; WHAT: Download and install MegaPack (ECE + 9 bonus maps)
		; WHY: User wants official bonus content
		; HOW: Load URLs from INI (or fallback to GitHub), download all parts,
		;      extract with 7z, copy to game
		;
		; RETURN: True if successful, False if failed

		UpdateStatus("Installing MegaPack...")
		LogMessage("Starting Phase 6: MegaPack Installation")
		LogMessage("MegaPack includes: ECE content + 9 bonus maps")

		; Create temp directory for MegaPack download
		Local $sMegaPackDir = $g_sDownloadDir & "\_MegaPack"
		If Not FileExists($sMegaPackDir) Then
			DirCreate($sMegaPackDir)
		EndIf

		; Load URLs from INI section (falls back to hardcoded GitHub URLs if not set)
		Local $aPartURLs = GetDownloadURLs("DownloadURLs_MegaPack")

		; Fallback if somehow empty
		If UBound($aPartURLs) = 0 Then
			ReDim $aPartURLs[4]
			$aPartURLs[0] = "https://github.com/EddCase/UT2004-AIO-Installer/raw/main/BonusPacks/UT2004MegaPack.z01"
			$aPartURLs[1] = "https://github.com/EddCase/UT2004-AIO-Installer/raw/main/BonusPacks/UT2004MegaPack.z02"
			$aPartURLs[2] = "https://github.com/EddCase/UT2004-AIO-Installer/raw/main/BonusPacks/UT2004MegaPack.z03"
			$aPartURLs[3] = "https://github.com/EddCase/UT2004-AIO-Installer/raw/main/BonusPacks/UT2004MegaPack.zip"
		EndIf

		; Download all parts using generic downloader
		; Returns array of local file paths that were downloaded
		Local $aPartFiles = DownloadPackFiles($aPartURLs, $sMegaPackDir, "MegaPack")
		If UBound($aPartFiles) = 0 Then
			LogMessage("ERROR: MegaPack download failed")
			Return False
		EndIf

		GUICtrlSetData($g_idProgressBar, 96)

		; Extract MegaPack
		; WHAT: Extract the archive (7z handles both single-file and multi-part automatically)
		; WHY: Need to get the game files out of the archive
		; HOW: 7z.exe x on the last file - for multi-part ZIPs it auto-combines .z01, .z02 etc.
		;      For a single complete archive, it just extracts it directly.
		UpdateStatus("Extracting MegaPack...")
		LogMessage("Extracting MegaPack archive")

		Local $sMegaPackExtracted = $g_sTempDir & "\_MegaPack_Extracted"
		Local $sExtractFrom = $aPartFiles[UBound($aPartFiles) - 1]  ; Always extract from last file in set
		Local $s7zCommand = '"' & $g_s7Zip & '" x "' & $sExtractFrom & '" -o"' & $sMegaPackExtracted & '" -y'
		LogMessage("Executing: " & $s7zCommand)

		Local $iExitCode = RunWait($s7zCommand, @ScriptDir, @SW_HIDE)

		If $iExitCode <> 0 Then
			LogMessage("ERROR: MegaPack extraction failed with exit code: " & $iExitCode)
			Return False
		EndIf

		LogMessage("MegaPack extracted successfully")
		GUICtrlSetData($g_idProgressBar, 97)

		; Copy MegaPack contents to game directory
		; WHAT: Copy extracted files to install directory
		; WHY: Merge MegaPack content with base game
		; HOW: Copy each folder, merging with existing folders
		UpdateStatus("Installing MegaPack files...")
		LogMessage("Copying MegaPack files to: " & $g_sInstallPath)

		; MegaPack files are directly in _Extracted folder
		Local $sMegaPackSource = $sMegaPackExtracted

		If Not FileExists($sMegaPackSource) Then
			LogMessage("ERROR: MegaPack source folder not found: " & $sMegaPackSource)
			Return False
		EndIf

		; Copy each folder
		Local $aFolders[9] = ["Animations", "Maps", "Music", "Sounds", "Speech", "StaticMeshes", "System", "Textures", "Web"]

		For $sFolder In $aFolders
			Local $sSource = $sMegaPackSource & "\" & $sFolder
			Local $sDest = $g_sInstallPath & "\" & $sFolder

			If FileExists($sSource) Then
				LogMessage("Copying: " & $sFolder)

				; Copy folder contents (merge with existing)
				DirCopy($sSource, $sDest, 1)  ; 1 = overwrite

				If @error Then
					LogMessage("WARNING: Error copying " & $sFolder)
				Else
					LogMessage($sFolder & " copied successfully")
				EndIf
			Else
				LogMessage("WARNING: " & $sFolder & " not found in MegaPack")
			EndIf
		Next

		LogMessage("MegaPack files copied to game directory")
		GUICtrlSetData($g_idProgressBar, 98)

		; Verify installation
		; WHAT: Check that some key MegaPack files were installed
		; WHY: Make sure installation actually worked
		; HOW: Check for a few key map files
		Local $bVerified = False
		If FileExists($g_sInstallPath & "\Maps\AS-BP2-Acatana.ut2") And _
		   FileExists($g_sInstallPath & "\Maps\DM-BP2-GoopGod.ut2") Then
			$bVerified = True
			LogMessage("MegaPack installation verified (maps found)")
		Else
			LogMessage("WARNING: MegaPack verification failed (maps not found)")
		EndIf

		UpdateStatus("MegaPack installation complete")
		LogMessage("Phase 6 complete")

		Return $bVerified
	EndFunc

	Func Phase7_InstallCBP1()
		; WHAT: Download and install Community Bonus Pack 1 (19 maps)
		; WHY: User wants additional community maps
		; HOW: Load URLs from INI (or fallback to GitHub), download all parts,
		;      extract with 7z, copy to game
		;
		; RETURN: True if successful, False if failed

		UpdateStatus("Installing Community Bonus Pack 1...")
		LogMessage("Starting Phase 7: CBP1 Installation")
		LogMessage("CBP1 includes: 19 community maps")

		; Create temp directory for CBP1 download
		Local $sCBP1Dir = $g_sDownloadDir & "\_CBP1"
		If Not FileExists($sCBP1Dir) Then
			DirCreate($sCBP1Dir)
		EndIf

		; Load URLs from INI section (falls back to hardcoded GitHub URLs if not set)
		Local $aPartURLs = GetDownloadURLs("DownloadURLs_CBP1")

		; Fallback if somehow empty
		If UBound($aPartURLs) = 0 Then
			ReDim $aPartURLs[3]
			$aPartURLs[0] = "https://github.com/EddCase/UT2004-AIO-Installer/raw/main/BonusPacks/CBP1.z01"
			$aPartURLs[1] = "https://github.com/EddCase/UT2004-AIO-Installer/raw/main/BonusPacks/CBP1.z02"
			$aPartURLs[2] = "https://github.com/EddCase/UT2004-AIO-Installer/raw/main/BonusPacks/CBP1.zip"
		EndIf

		; Download all parts using generic downloader
		Local $aPartFiles = DownloadPackFiles($aPartURLs, $sCBP1Dir, "CBP1")
		If UBound($aPartFiles) = 0 Then
			LogMessage("ERROR: CBP1 download failed")
			Return False
		EndIf

		GUICtrlSetData($g_idProgressBar, 96)

		; Extract CBP1
		UpdateStatus("Extracting CBP1...")
		LogMessage("Extracting CBP1 archive")

		Local $sCBP1Extracted = $g_sTempDir & "\_CBP1_Extracted"
		Local $sExtractFrom = $aPartFiles[UBound($aPartFiles) - 1]  ; Always extract from last file in set
		Local $s7zCommand = '"' & $g_s7Zip & '" x "' & $sExtractFrom & '" -o"' & $sCBP1Extracted & '" -y'
		LogMessage("Executing: " & $s7zCommand)

		Local $iExitCode = RunWait($s7zCommand, @ScriptDir, @SW_HIDE)

		If $iExitCode <> 0 Then
			LogMessage("ERROR: CBP1 extraction failed with exit code: " & $iExitCode)
			Return False
		EndIf

		LogMessage("CBP1 extracted successfully")
		GUICtrlSetData($g_idProgressBar, 97)

		; Copy CBP1 contents to game directory
		UpdateStatus("Installing CBP1 files...")
		LogMessage("Copying CBP1 files to: " & $g_sInstallPath)

		Local $sCBP1Source = $sCBP1Extracted

		If Not FileExists($sCBP1Source) Then
			LogMessage("ERROR: CBP1 source folder not found: " & $sCBP1Source)
			Return False
		EndIf

		; Copy each folder
		Local $aFolders[5] = ["Help", "Maps", "Music", "StaticMeshes", "Textures"]

		For $sFolder In $aFolders
			Local $sSource = $sCBP1Source & "\" & $sFolder
			Local $sDest = $g_sInstallPath & "\" & $sFolder

			If FileExists($sSource) Then
				LogMessage("Copying: " & $sFolder)
				DirCopy($sSource, $sDest, 1)

				If @error Then
					LogMessage("WARNING: Error copying " & $sFolder)
				Else
					LogMessage($sFolder & " copied successfully")
				EndIf
			Else
				LogMessage("WARNING: " & $sFolder & " not found in CBP1")
			EndIf
		Next

		LogMessage("CBP1 files copied to game directory")
		GUICtrlSetData($g_idProgressBar, 98)

		; Verify installation
		Local $bVerified = False
		If FileExists($g_sInstallPath & "\Maps\DM-CBP1-Finale.ut2") And _
		   FileExists($g_sInstallPath & "\Maps\CTF-CBP1-Concentrate.ut2") Then
			$bVerified = True
			LogMessage("CBP1 installation verified (maps found)")
		Else
			LogMessage("WARNING: CBP1 verification failed (maps not found)")
		EndIf

		UpdateStatus("CBP1 installation complete")
		LogMessage("Phase 7 complete")

		Return $bVerified
	EndFunc

	Func Phase8_InstallCBP2V1()
		; WHAT: Download and install Community Bonus Pack 2 Volume 1 (21 maps)
		; WHY: User wants additional community maps
		; HOW: Load URLs from INI (or fallback to GitHub), download all parts,
		;      extract with 7z, copy to game
		;
		; RETURN: True if successful, False if failed

		UpdateStatus("Installing Community Bonus Pack 2 Volume 1...")
		LogMessage("Starting Phase 8: CBP2 Volume 1 Installation")
		LogMessage("CBP2 Vol 1 includes: 21 community maps")

		; Create temp directory for CBP2V1 download
		Local $sCBP2V1Dir = $g_sDownloadDir & "\_CBP2V1"
		If Not FileExists($sCBP2V1Dir) Then
			DirCreate($sCBP2V1Dir)
		EndIf

		; Load URLs from INI section (falls back to hardcoded GitHub URLs if not set)
		Local $aPartURLs = GetDownloadURLs("DownloadURLs_CBP2V1")

		; Fallback if somehow empty
		If UBound($aPartURLs) = 0 Then
			ReDim $aPartURLs[4]
			$aPartURLs[0] = "https://github.com/EddCase/UT2004-AIO-Installer/raw/main/BonusPacks/cbp2_volume1.z01"
			$aPartURLs[1] = "https://github.com/EddCase/UT2004-AIO-Installer/raw/main/BonusPacks/cbp2_volume1.z02"
			$aPartURLs[2] = "https://github.com/EddCase/UT2004-AIO-Installer/raw/main/BonusPacks/cbp2_volume1.z03"
			$aPartURLs[3] = "https://github.com/EddCase/UT2004-AIO-Installer/raw/main/BonusPacks/cbp2_volume1.zip"
		EndIf

		; Download all parts using generic downloader
		Local $aPartFiles = DownloadPackFiles($aPartURLs, $sCBP2V1Dir, "CBP2 Volume 1")
		If UBound($aPartFiles) = 0 Then
			LogMessage("ERROR: CBP2 Volume 1 download failed")
			Return False
		EndIf

		GUICtrlSetData($g_idProgressBar, 96)

		; Extract CBP2 Vol 1
		UpdateStatus("Extracting CBP2 Volume 1...")
		LogMessage("Extracting CBP2 Volume 1 archive")

		Local $sCBP2V1Extracted = $g_sTempDir & "\_CBP2V1_Extracted"
		Local $sExtractFrom = $aPartFiles[UBound($aPartFiles) - 1]  ; Always extract from last file in set
		Local $s7zCommand = '"' & $g_s7Zip & '" x "' & $sExtractFrom & '" -o"' & $sCBP2V1Extracted & '" -y'
		LogMessage("Executing: " & $s7zCommand)

		Local $iExitCode = RunWait($s7zCommand, @ScriptDir, @SW_HIDE)

		If $iExitCode <> 0 Then
			LogMessage("ERROR: CBP2 Volume 1 extraction failed with exit code: " & $iExitCode)
			Return False
		EndIf

		LogMessage("CBP2 Volume 1 extracted successfully")
		GUICtrlSetData($g_idProgressBar, 97)

		; Copy CBP2 Vol 1 contents to game directory
		UpdateStatus("Installing CBP2 Volume 1 files...")
		LogMessage("Copying CBP2 Volume 1 files to: " & $g_sInstallPath)

		Local $sCBP2V1Source = $sCBP2V1Extracted

		If Not FileExists($sCBP2V1Source) Then
			LogMessage("ERROR: CBP2 Volume 1 source folder not found: " & $sCBP2V1Source)
			Return False
		EndIf

		; Copy each folder
		Local $aFolders[7] = ["Animations", "Help", "Maps", "Music", "StaticMeshes", "System", "Textures"]

		For $sFolder In $aFolders
			Local $sSource = $sCBP2V1Source & "\" & $sFolder
			Local $sDest = $g_sInstallPath & "\" & $sFolder

			If FileExists($sSource) Then
				LogMessage("Copying: " & $sFolder)
				DirCopy($sSource, $sDest, 1)

				If @error Then
					LogMessage("WARNING: Error copying " & $sFolder)
				Else
					LogMessage($sFolder & " copied successfully")
				EndIf
			Else
				LogMessage("WARNING: " & $sFolder & " not found in CBP2 Volume 1")
			EndIf
		Next

		LogMessage("CBP2 Volume 1 files copied to game directory")
		GUICtrlSetData($g_idProgressBar, 98)

		; Verify installation
		Local $bVerified = False
		If FileExists($g_sInstallPath & "\Maps\AS-CBP2-Thrust.ut2") And _
		   FileExists($g_sInstallPath & "\Maps\DM-CBP2-Achilles.ut2") Then
			$bVerified = True
			LogMessage("CBP2 Volume 1 installation verified (maps found)")
		Else
			LogMessage("WARNING: CBP2 Volume 1 verification failed (maps not found)")
		EndIf

		UpdateStatus("CBP2 Volume 1 installation complete")
		LogMessage("Phase 8 complete")

		Return $bVerified
	EndFunc

	Func Phase9_InstallCBP2V2()
		; WHAT: Download and install Community Bonus Pack 2 Volume 2 (20 maps)
		; WHY: User wants additional community maps
		; HOW: Load URLs from INI (or fallback to GitHub), download all parts,
		;      extract with 7z, copy to game
		;
		; RETURN: True if successful, False if failed

		UpdateStatus("Installing Community Bonus Pack 2 Volume 2...")
		LogMessage("Starting Phase 9: CBP2 Volume 2 Installation")
		LogMessage("CBP2 Vol 2 includes: 20 community maps")

		; Create temp directory for CBP2V2 download
		Local $sCBP2V2Dir = $g_sDownloadDir & "\_CBP2V2"
		If Not FileExists($sCBP2V2Dir) Then
			DirCreate($sCBP2V2Dir)
		EndIf

		; Load URLs from INI section (falls back to hardcoded GitHub URLs if not set)
		Local $aPartURLs = GetDownloadURLs("DownloadURLs_CBP2V2")

		; Fallback if somehow empty
		If UBound($aPartURLs) = 0 Then
			ReDim $aPartURLs[4]
			$aPartURLs[0] = "https://github.com/EddCase/UT2004-AIO-Installer/raw/main/BonusPacks/cbp2_volume2.z01"
			$aPartURLs[1] = "https://github.com/EddCase/UT2004-AIO-Installer/raw/main/BonusPacks/cbp2_volume2.z02"
			$aPartURLs[2] = "https://github.com/EddCase/UT2004-AIO-Installer/raw/main/BonusPacks/cbp2_volume2.z03"
			$aPartURLs[3] = "https://github.com/EddCase/UT2004-AIO-Installer/raw/main/BonusPacks/cbp2_volume2.zip"
		EndIf

		; Download all parts using generic downloader
		Local $aPartFiles = DownloadPackFiles($aPartURLs, $sCBP2V2Dir, "CBP2 Volume 2")
		If UBound($aPartFiles) = 0 Then
			LogMessage("ERROR: CBP2 Volume 2 download failed")
			Return False
		EndIf

		GUICtrlSetData($g_idProgressBar, 96)

		; Extract CBP2 Vol 2
		UpdateStatus("Extracting CBP2 Volume 2...")
		LogMessage("Extracting CBP2 Volume 2 archive")

		Local $sCBP2V2Extracted = $g_sTempDir & "\_CBP2V2_Extracted"
		Local $sExtractFrom = $aPartFiles[UBound($aPartFiles) - 1]  ; Always extract from last file in set
		Local $s7zCommand = '"' & $g_s7Zip & '" x "' & $sExtractFrom & '" -o"' & $sCBP2V2Extracted & '" -y'
		LogMessage("Executing: " & $s7zCommand)

		Local $iExitCode = RunWait($s7zCommand, @ScriptDir, @SW_HIDE)

		If $iExitCode <> 0 Then
			LogMessage("ERROR: CBP2 Volume 2 extraction failed with exit code: " & $iExitCode)
			Return False
		EndIf

		LogMessage("CBP2 Volume 2 extracted successfully")
		GUICtrlSetData($g_idProgressBar, 97)

		; Copy CBP2 Vol 2 contents to game directory
		UpdateStatus("Installing CBP2 Volume 2 files...")
		LogMessage("Copying CBP2 Volume 2 files to: " & $g_sInstallPath)

		Local $sCBP2V2Source = $sCBP2V2Extracted

		If Not FileExists($sCBP2V2Source) Then
			LogMessage("ERROR: CBP2 Volume 2 source folder not found: " & $sCBP2V2Source)
			Return False
		EndIf

		; Copy each folder
		Local $aFolders[7] = ["Animations", "Help", "Maps", "Music", "StaticMeshes", "System", "Textures"]

		For $sFolder In $aFolders
			Local $sSource = $sCBP2V2Source & "\" & $sFolder
			Local $sDest = $g_sInstallPath & "\" & $sFolder

			If FileExists($sSource) Then
				LogMessage("Copying: " & $sFolder)
				DirCopy($sSource, $sDest, 1)

				If @error Then
					LogMessage("WARNING: Error copying " & $sFolder)
				Else
					LogMessage($sFolder & " copied successfully")
				EndIf
			Else
				LogMessage("WARNING: " & $sFolder & " not found in CBP2 Volume 2")
			EndIf
		Next

		LogMessage("CBP2 Volume 2 files copied to game directory")
		GUICtrlSetData($g_idProgressBar, 98)

		; Verify installation
		Local $bVerified = False
		If FileExists($g_sInstallPath & "\Maps\BR-CBP2-Bahera.ut2") And _
		   FileExists($g_sInstallPath & "\Maps\DM-CBP2-Buliwyf.ut2") Then
			$bVerified = True
			LogMessage("CBP2 Volume 2 installation verified (maps found)")
		Else
			LogMessage("WARNING: CBP2 Volume 2 verification failed (maps not found)")
		EndIf

		UpdateStatus("CBP2 Volume 2 installation complete")
		LogMessage("Phase 9 complete")

		Return $bVerified
	EndFunc

	Func GetDownloadURLs($sINISection)
		; WHAT: Load download URLs from a named section in installer_settings.ini
		; WHY: Allows user to configure any hosting (Cloudflare R2, custom server, etc.)
		;      without recompiling. Any number of parts, any key names.
		; HOW: Use IniReadSection() to read all key=value pairs from the section.
		;      Returns an array of URL strings in the order they appear in the INI.
		;      Returns empty array if section missing or INI not found.
		;
		; PARAMETERS:
		;   $sINISection - Section name, e.g. "DownloadURLs_MegaPack"
		;
		; RETURN: Array of URL strings (may be empty if section not found)

		Local $sINIFile = @ScriptDir & "\installer_settings.ini"
		Local $aURLs[0]  ; Start with empty array

		If Not FileExists($sINIFile) Then
			LogMessage("No installer_settings.ini found - using default URLs for: " & $sINISection)
			Return $aURLs
		EndIf

		; IniReadSection returns a 2D array: [0][0] = count, [n][0] = key, [n][1] = value
		Local $aSection = IniReadSection($sINIFile, $sINISection)

		If @error Or $aSection[0][0] = 0 Then
			LogMessage("No URLs found in [" & $sINISection & "] - using default URLs")
			Return $aURLs
		EndIf

		; Build flat array of URL values (we don't care about key names)
		ReDim $aURLs[$aSection[0][0]]
		For $i = 1 To $aSection[0][0]
			$aURLs[$i - 1] = $aSection[$i][1]
			LogMessage("Loaded URL from [" & $sINISection & "]: " & $aSection[$i][0] & " = " & $aSection[$i][1])
		Next

		LogMessage("Loaded " & $aSection[0][0] & " URL(s) from [" & $sINISection & "]")
		Return $aURLs
	EndFunc

	Func DownloadPackFiles($aURLs, $sWorkDir, $sPackName)
		; WHAT: Download all files from a URL array into a working directory
		; WHY: Generic reusable downloader for any pack - works regardless of
		;      how many parts or what they're named in the INI
		; HOW:
		;   - If ONE URL: download it, then run "7z t" to test if it's a complete archive.
		;     If the test passes it's a valid single-file archive and we're done.
		;     If it fails, something went wrong with the download.
		;   - If MULTIPLE URLs: just download them all (they're clearly meant to be
		;     used together as a multi-part set, no point testing each one).
		;   - Each file is saved with its original filename from the URL.
		;
		; PARAMETERS:
		;   $aURLs     - Array of URLs to download
		;   $sWorkDir  - Directory to save downloaded files into
		;   $sPackName - User-friendly name for status messages (e.g. "MegaPack")
		;
		; RETURN: Array of local file paths that were downloaded.
		;         Returns empty array on failure.

		Local $iCount = UBound($aURLs)
		Local $aLocalFiles[$iCount]
		Local $aEmpty[0]

		If $iCount = 0 Then
			LogMessage("ERROR: No URLs provided for " & $sPackName)
			Return $aEmpty
		EndIf

		LogMessage("Downloading " & $sPackName & " (" & $iCount & " file(s))")

		; Download each file
		For $i = 0 To $iCount - 1
			Local $sURL = $aURLs[$i]

			; Derive filename from URL (everything after the last /)
			Local $sFilename = StringRegExpReplace($sURL, "^.*/", "")
			If $sFilename = "" Then $sFilename = "part_" & ($i + 1)

			Local $sDestPath = $sWorkDir & "\" & $sFilename
			$aLocalFiles[$i] = $sDestPath

			; Check portable cache first (@ScriptDir\_Downloads)
			; WHAT: Look for this exact filename in the portable cache
			; WHY: User may have kept files from a previous install - no need to re-download
			; HOW: Filename is derived from the URL so it matches whatever was saved last time
			Local $sPortableCached = $g_sPortableDir & "\" & $sFilename
			If FileExists($sPortableCached) And FileGetSize($sPortableCached) > 0 Then
				UpdateStatus($sPackName & " - file " & ($i + 1) & " of " & $iCount & " found in portable cache")
				LogMessage("Using portable cache: " & $sPortableCached & " (" & FileGetSize($sPortableCached) & " bytes)")
				FileCopy($sPortableCached, $sDestPath, 1)
				ContinueLoop
			EndIf

			; Check temp cache from this session
			If FileExists($sDestPath) And FileGetSize($sDestPath) > 0 Then
				UpdateStatus($sPackName & " - file " & ($i + 1) & " of " & $iCount & " found in temp cache")
				LogMessage("Using temp cache: " & $sFilename & " (" & FileGetSize($sDestPath) & " bytes)")
				ContinueLoop
			EndIf

			; Download with progress
			UpdateStatus("Downloading " & $sPackName & " - file " & ($i + 1) & " of " & $iCount & "...")
			LogMessage("Downloading: " & $sURL)
			LogMessage("Saving to: " & $sDestPath)

			Local $hDownload = InetGet($sURL, $sDestPath, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)

			If $hDownload = 0 Then
				LogMessage("ERROR: Failed to start download for " & $sFilename)
				Return $aEmpty
			EndIf

			While Not InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
				Local $iBytesRead = InetGetInfo($hDownload, $INET_DOWNLOADREAD)
				Local $iTotalSize = InetGetInfo($hDownload, $INET_DOWNLOADSIZE)

				If $iTotalSize > 0 Then
					Local $sMB = Round($iBytesRead / 1048576, 1)
					Local $sTotalMB = Round($iTotalSize / 1048576, 1)
					Local $sPercent = Round(($iBytesRead / $iTotalSize) * 100, 0)
					GUICtrlSetData($g_idLabelStatus, "Downloading " & $sPackName & " (" & ($i + 1) & "/" & $iCount & "): " & $sMB & " MB / " & $sTotalMB & " MB (" & $sPercent & "%)")
				Else
					Local $sMB = Round($iBytesRead / 1048576, 1)
					GUICtrlSetData($g_idLabelStatus, "Downloading " & $sPackName & " (" & ($i + 1) & "/" & $iCount & "): " & $sMB & " MB...")
				EndIf

				Sleep(500)
			WEnd

			InetClose($hDownload)

			If Not FileExists($sDestPath) Or FileGetSize($sDestPath) = 0 Then
				LogMessage("ERROR: Download failed or produced empty file: " & $sFilename)
				Return $aEmpty
			EndIf

			LogMessage("Downloaded: " & $sFilename & " (" & FileGetSize($sDestPath) & " bytes)")
		Next

		; Single-file check: if only one URL was provided, test the archive with 7z
		; WHY: If someone provides a single pre-merged archive instead of split parts,
		;      we verify it's actually a valid complete archive before proceeding.
		;      We skip this for multi-part sets since they're obviously meant to be split.
		If $iCount = 1 Then
			UpdateStatus("Verifying " & $sPackName & " archive...")
			LogMessage("Single file detected - running 7z integrity test")

			Local $sTestCmd = '"' & $g_s7Zip & '" t "' & $aLocalFiles[0] & '" -y'
			LogMessage("Executing: " & $sTestCmd)

			Local $iExitCode = RunWait($sTestCmd, @ScriptDir, @SW_HIDE)

			If $iExitCode <> 0 Then
				LogMessage("ERROR: Archive integrity test failed (exit code: " & $iExitCode & ") - file may be corrupt or incomplete")
				Return $aEmpty
			EndIf

			LogMessage("Archive integrity test passed")
		EndIf

		LogMessage("All " & $iCount & " file(s) downloaded successfully for " & $sPackName)
		Return $aLocalFiles
	EndFunc

	Func LoadDownloadURLs()
		; WHAT: Pre-load ISO URL from INI into $g_sURL_ISO global
		; WHY: Phase2_DownloadISO needs the URL before it calls GetDownloadURLs()
		;      Bonus packs call GetDownloadURLs() inline so don't need pre-loading.
		; HOW: Read [DownloadURLs_ISO] from INI, fall back to hardcoded default

		Local $aISOURLs = GetDownloadURLs("DownloadURLs_ISO")

		If UBound($aISOURLs) > 0 Then
			$g_sURL_ISO = $aISOURLs[0]  ; ISO is always a single URL
			LogMessage("Custom ISO URL loaded: " & $g_sURL_ISO)
		Else
			; Keep the hardcoded default already set in globals
			LogMessage("Using default ISO URL: " & $g_sURL_ISO)
		EndIf
	EndFunc

	Func DownloadFileWithProgress($sURL, $sDestination, $iProgressStart, $iProgressEnd)
		; WHAT: Download a file with progress bar updates
		; WHY: User needs to see download progress
		; HOW: Use InetGet background download, poll progress in loop
		;
		; PARAMETERS:
		;   $sURL            - URL to download from
		;   $sDestination    - Where to save the file
		;   $iProgressStart  - Starting progress % (e.g., 0)
		;   $iProgressEnd    - Ending progress % (e.g., 50)
		;
		; RETURN: True if successful, False if failed
		;
		; EXAMPLE: DownloadFileWithProgress("http://...", "file.iso", 0, 50)
		;          Downloads and updates progress bar from 0% to 50%

		; Start background download
		; WHAT: Begin downloading in background
		; WHY: Allows us to update GUI while downloading
		; HOW: InetGet with $INET_DOWNLOADBACKGROUND flag
		;      Returns a handle we can query for progress
		Local $hDownload = InetGet($sURL, $sDestination, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)

		If $hDownload = 0 Then
			UpdateStatus("Failed to start download")
			LogMessage("ERROR: InetGet failed to start download")
			Return False
		EndIf

		; Track retries
		; WHAT: Count how many times we retry
		; WHY: Don't retry forever, give up after 3 attempts
		; HOW: Increment counter on failures
		Local $iRetries = 0
		Local $iMaxRetries = 3

		; Download progress loop
		; WHAT: Monitor download progress until complete
		; WHY: Update progress bar and status
		; HOW: Poll InetGetInfo in loop until download finishes
		While True
			; Check if download is complete
			; WHAT: Has the download finished?
			; WHY: Need to know when to exit loop
			; HOW: InetGetInfo with $INET_DOWNLOADCOMPLETE flag
			Local $iComplete = InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)

			If $iComplete Then
				; Download finished!
				ExitLoop
			EndIf

			; Get download progress
			; WHAT: How much has been downloaded?
			; WHY: Update progress bar and status
			; HOW: InetGetInfo returns bytes downloaded and total size
			Local $iBytesRead = InetGetInfo($hDownload, $INET_DOWNLOADREAD)
			Local $iTotalSize = InetGetInfo($hDownload, $INET_DOWNLOADSIZE)

			; Check for errors
			; WHAT: Did download fail?
			; WHY: Need to retry or abort
			; HOW: Check if InetGetInfo returned error
			If @error Then
				$iRetries += 1
				If $iRetries >= $iMaxRetries Then
					InetClose($hDownload)
					UpdateStatus("Download failed after " & $iMaxRetries & " retries")
					LogMessage("ERROR: Download failed after " & $iMaxRetries & " retries")
					Return False
				EndIf

				UpdateStatus("Download error, retrying... (" & $iRetries & "/" & $iMaxRetries & ")")
				LogMessage("Download error, retry " & $iRetries & " of " & $iMaxRetries)
				Sleep(2000)  ; Wait 2 seconds before retry
				ContinueLoop
			EndIf

			; Calculate progress
			; WHAT: Convert bytes to percentage
			; WHY: Update progress bar proportionally
			; HOW: (bytesRead / totalSize) * (progressEnd - progressStart) + progressStart
			If $iTotalSize > 0 Then
				Local $fDownloadPercent = ($iBytesRead / $iTotalSize)
				Local $iProgressPercent = $iProgressStart + Int($fDownloadPercent * ($iProgressEnd - $iProgressStart))

				; Update progress bar
				; WHAT: Set progress bar to current percentage
				; WHY: Visual feedback
				; HOW: GUICtrlSetData sets progress control value
				GUICtrlSetData($g_idProgressBar, $iProgressPercent)

				; Update status with MB downloaded
				; WHAT: Show user how much has downloaded
				; WHY: More informative than just percentage
				; HOW: Convert bytes to MB, format nicely, UPDATE LABEL ONLY (no TrayTip spam)
				Local $sMB = Round($iBytesRead / 1048576, 1)  ; Bytes to MB
				Local $sTotalMB = Round($iTotalSize / 1048576, 1)
				Local $sPercent = Round($fDownloadPercent * 100, 1)

				; Update status label only (no TrayTip to avoid spam)
				GUICtrlSetData($g_idLabelStatus, "Downloading: " & $sMB & " MB / " & $sTotalMB & " MB (" & $sPercent & "%)")
				; Log progress silently
				LogMessage("Download progress: " & $sMB & " MB / " & $sTotalMB & " MB (" & $sPercent & "%)", True)
			Else
				; Don't know total size yet
				; WHAT: Server hasn't sent Content-Length yet
				; WHY: Some servers delay sending size
				; HOW: Just show bytes downloaded, UPDATE LABEL ONLY
				Local $sMB = Round($iBytesRead / 1048576, 1)
				GUICtrlSetData($g_idLabelStatus, "Downloading: " & $sMB & " MB...")
				LogMessage("Download progress: " & $sMB & " MB...", True)
			EndIf

			; Brief pause before next update
			; WHAT: Don't update too frequently
			; WHY: Reduces CPU usage and GUI flicker
			; HOW: Sleep for half a second between updates
			Sleep(500)
		WEnd

		; Close download handle
		; WHAT: Clean up InetGet handle
		; WHY: Free resources
		; HOW: InetClose releases the handle
		InetClose($hDownload)

		; Set progress to end value
		; WHAT: Make sure progress reaches the end percentage
		; WHY: Might not be exactly at end due to rounding
		; HOW: Set it explicitly
		GUICtrlSetData($g_idProgressBar, $iProgressEnd)

		Return True
	EndFunc
#EndRegion

#Region Utility Functions
	Func StringRepeat($sChar, $iCount)
		; WHAT: Repeat a character multiple times
		; WHY: AutoIt doesn't have built-in string repeat function
		; HOW: Loop and concatenate character
		;
		; PARAMETERS:
		;   $sChar - Character or string to repeat
		;   $iCount - How many times to repeat
		;
		; RETURN: Repeated string
		;
		; EXAMPLE: StringRepeat("=", 70) returns "====...===" (70 equals signs)

		Local $sResult = ""
		For $i = 1 To $iCount
			$sResult &= $sChar
		Next
		Return $sResult
	EndFunc

	Func ValidateCDKey($sKey)
		; WHAT: Validate CD key format
		; WHY: Ensure key is in correct format before writing to registry
		; HOW: Check for XXXXX-XXXXX-XXXXX-XXXXX pattern (alphanumeric, 5 groups of 5)
		;
		; PARAMETERS:
		;   $sKey - CD key to validate
		;
		; RETURN: True if valid or empty (optional), False if invalid format

		; Empty is valid (CD key is optional)
		If $sKey = "" Then Return True

		; Check pattern: 5 chars, hyphen, 5 chars, hyphen, 5 chars, hyphen, 5 chars
		; WHAT: Use regex to validate format
		; WHY: CD keys must be exactly 5-5-5-5 format
		; HOW: ^[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}$
		Local $sPattern = "^[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}$"

		; Convert to uppercase for validation
		$sKey = StringUpper($sKey)

		If StringRegExp($sKey, $sPattern) Then
			Return True
		Else
			Return False
		EndIf
	EndFunc

	Func InitializeLog()
		; WHAT: Create and open the installation log file
		; WHY: Track installation progress for troubleshooting
		; HOW: Create temp directory, open log file for writing

		; Create temp directory if it doesn't exist
		; WHAT: Make sure we have a place to put the log
		; WHY: Can't write log if directory doesn't exist
		; HOW: DirCreate creates nested folders automatically
		If Not FileExists($g_sTempDir) Then
			DirCreate($g_sTempDir)
		EndIf

		; Open log file for writing
		; WHAT: Create install.log in temp directory
		; WHY: Record all installation steps with timestamps
		; HOW: FileOpen in write mode (2), store handle globally
		;      Mode 2 = erase existing file and create new
		$g_hLogFile = FileOpen($g_sTempDir & "\install.log", 2)

		If $g_hLogFile = -1 Then
			; Couldn't create log - not critical, continue anyway
			; WHAT: Log creation failed
			; WHY: Might be permissions issue
			; HOW: Set handle to 0 so we know logging is disabled
			$g_hLogFile = 0
			Return False
		EndIf

		; Write header to log
		; WHAT: Log file header with version and timestamp
		; WHY: Helps identify which installer version was used
		; HOW: FileWriteLine writes a line to the file
		LogMessage("UT2004 All-In-One Installer v" & $INSTALLER_VERSION)
		LogMessage("Installation started: " & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC)
		LogMessage("Installation Path: " & $g_sInstallPath)
		LogMessage("=" & StringRepeat("=", 70))
		LogMessage("")

		Return True
	EndFunc

	Func LogMessage($sMessage, $bLogOnly = False)
		; WHAT: Write a timestamped message to the log file
		; WHY: Track what's happening and when
		; HOW: Add timestamp, write to file, flush immediately
		;
		; PARAMETERS:
		;   $sMessage  - Message to log
		;   $bLogOnly  - Not used here (for compatibility with UpdateStatus calls)

		; Only log if file is open
		; WHAT: Check if logging is enabled
		; WHY: Don't try to write if log file failed to open
		; HOW: Check if handle is valid (not 0 or -1)
		If $g_hLogFile = 0 Or $g_hLogFile = -1 Then Return

		; Format: [HH:MM:SS] Message
		; WHAT: Add timestamp to message
		; WHY: Know exactly when each step occurred
		; HOW: Use @HOUR, @MIN, @SEC macros
		Local $sTimestamp = "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] "

		; Write to log file
		; WHAT: Write the timestamped message
		; WHY: Permanent record of installation steps
		; HOW: FileWriteLine adds a line to the file
		FileWriteLine($g_hLogFile, $sTimestamp & $sMessage)

		; Flush to disk immediately
		; WHAT: Force write to disk right away
		; WHY: If installer crashes, we don't lose recent log entries
		; HOW: FileFlush forces Windows to write buffer to disk
		FileFlush($g_hLogFile)
	EndFunc

	Func UpdateStatus($sMessage, $bLogOnly = False)
		; WHAT: Update status label and log
		; WHY: Keep user informed and create permanent record
		; HOW: Update GUI (unless log-only), write to log
		;      NOTE: No TrayTip here - add manually only at MAJOR milestones
		;
		; PARAMETERS:
		;   $sMessage  - The status message to display/log
		;   $bLogOnly  - If True, only log (don't update GUI) - for verbose logging

		; Log the message
		; WHAT: Write to install.log
		; WHY: Permanent record
		; HOW: Call LogMessage function
		LogMessage($sMessage)

		; Update GUI unless this is log-only
		; WHAT: Update status label (NO TrayTip - too spammy)
		; WHY: User needs visual feedback in the GUI
		; HOW: Set label text only
		If Not $bLogOnly Then
			GUICtrlSetData($g_idLabelStatus, $sMessage)

			; Force GUI to update immediately
			; WHAT: Make sure the status text appears right away
			; WHY: AutoIt GUI updates might be buffered
			; HOW: Sleep(10) gives GUI time to redraw
			Sleep(10)
		EndIf
	EndFunc

	Func ExitApplication()
		; WHAT: Clean up and exit the installer
		; WHY: Need to close files, clean temp folders gracefully
		; HOW:
		;   - Close log file if open
		;   - Delete temp folders (optional)
		;   - Exit AutoIt

		; Close log file
		; WHAT: Close install.log if it's open
		; WHY: Flush any remaining buffered writes
		; HOW: Check if handle is valid, then FileClose
		If $g_hLogFile <> 0 And $g_hLogFile <> -1 Then
			LogMessage("Installation cancelled by user")
			LogMessage("Installer closed: " & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC)
			FileClose($g_hLogFile)
		EndIf

		; Optional: Clean up temp directory
		; Could ask user if they want to delete temp files
		; For now, we leave temp files for debugging

		Exit
	EndFunc

	Func InstallationComplete()
		; WHAT: Handle successful installation completion
		; WHY: Show success message, clean up, offer to launch game
		; HOW: Log completion, show message, re-enable UI

		UpdateStatus("Installation complete!")
		LogMessage("")
		LogMessage("=" & StringRepeat("=", 70))
		LogMessage("Installation completed successfully!")
		LogMessage("Completed: " & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC)

		; Set progress to 100%
		GUICtrlSetData($g_idProgressBar, 100)

		; Show success message
		; WHAT: Inform user installation succeeded
		; WHY: Clear confirmation
		; HOW: MsgBox with success icon
		MsgBox(64, "Installation Complete", "UT2004 has been installed successfully!" & @CRLF & @CRLF & _
				"Installation directory: " & $g_sInstallPath)

		; Close log file
		If $g_hLogFile <> 0 And $g_hLogFile <> -1 Then
			FileClose($g_hLogFile)
			$g_hLogFile = 0
		EndIf

		; Re-enable UI (in case user wants to install to another location)
		GUICtrlSetState($g_idInputInstallPath, $GUI_ENABLE)
		GUICtrlSetState($g_idBtnBrowse, $GUI_ENABLE)
		GUICtrlSetState($g_idBtnInstall, $GUI_ENABLE)
		GUICtrlSetState($g_idCheckboxKeepFiles, $GUI_ENABLE)
		GUICtrlSetState($g_idCheckboxFileAssoc, $GUI_ENABLE)
		GUICtrlSetState($g_idCheckboxMegaPack, $GUI_ENABLE)
		GUICtrlSetState($g_idCheckboxCBP1, $GUI_ENABLE)
		GUICtrlSetState($g_idCheckboxCBP2V1, $GUI_ENABLE)
		GUICtrlSetState($g_idCheckboxCBP2V2, $GUI_ENABLE)
		If $g_iDetectedWidth > 0 Then GUICtrlSetState($g_idCheckboxAutoRes, $GUI_ENABLE)
		GUICtrlSetState($g_idCheckboxMaxDetail, $GUI_ENABLE)
		GUICtrlSetState($g_idTabBtn1, $GUI_ENABLE)
		GUICtrlSetState($g_idTabBtn2, $GUI_ENABLE)
		GUICtrlSetState($g_idTabBtn3, $GUI_ENABLE)

		; Reset progress bar
		GUICtrlSetData($g_idProgressBar, 0)
	EndFunc

	Func InstallationFailed($sReason)
		; WHAT: Handle installation failure
		; WHY: Need to inform user and clean up
		; HOW: Log error, show message, re-enable UI
		;
		; PARAMETERS:
		;   $sReason - Why installation failed

		LogMessage("")
		LogMessage("=" & StringRepeat("=", 70))
		LogMessage("INSTALLATION FAILED: " & $sReason)
		LogMessage("Failed at: " & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC)

		; Show error message
		; WHAT: Inform user installation failed
		; WHY: User needs to know what went wrong
		; HOW: MsgBox with error icon
		MsgBox(16, "Installation Failed", "Installation failed:" & @CRLF & @CRLF & $sReason & @CRLF & @CRLF & _
				"Check install.log for details:" & @CRLF & $g_sTempDir & "\install.log")

		; Close log file
		If $g_hLogFile <> 0 And $g_hLogFile <> -1 Then
			FileClose($g_hLogFile)
			$g_hLogFile = 0
		EndIf

		; Re-enable UI so user can try again
		GUICtrlSetState($g_idInputInstallPath, $GUI_ENABLE)
		GUICtrlSetState($g_idBtnBrowse, $GUI_ENABLE)
		GUICtrlSetState($g_idBtnInstall, $GUI_ENABLE)
		GUICtrlSetState($g_idCheckboxKeepFiles, $GUI_ENABLE)
		GUICtrlSetState($g_idCheckboxFileAssoc, $GUI_ENABLE)
		GUICtrlSetState($g_idCheckboxMegaPack, $GUI_ENABLE)
		GUICtrlSetState($g_idCheckboxCBP1, $GUI_ENABLE)
		GUICtrlSetState($g_idCheckboxCBP2V1, $GUI_ENABLE)
		GUICtrlSetState($g_idCheckboxCBP2V2, $GUI_ENABLE)
		If $g_iDetectedWidth > 0 Then GUICtrlSetState($g_idCheckboxAutoRes, $GUI_ENABLE)
		GUICtrlSetState($g_idCheckboxMaxDetail, $GUI_ENABLE)
		GUICtrlSetState($g_idTabBtn1, $GUI_ENABLE)
		GUICtrlSetState($g_idTabBtn2, $GUI_ENABLE)
		GUICtrlSetState($g_idTabBtn3, $GUI_ENABLE)

		; Reset progress bar
		GUICtrlSetData($g_idProgressBar, 0)
		UpdateStatus("Installation failed - see log for details")
	EndFunc

	Func SwitchToTab($iTabNumber)
		; WHAT: Switch between tabs in the GUI
		; WHY: User clicks tab buttons to view different sections
		; HOW: Hide current tab controls, show selected tab controls, update button styles
		;
		; PARAMETERS:
		;   $iTabNumber - Which tab to show (1=Installation, 2=Official Content, 3=Options)

		; Don't switch if already on this tab
		If $iTabNumber = $g_iCurrentTab Then Return

		; Hide current tab's controls
		Switch $g_iCurrentTab
			Case 1  ; Hide Installation tab
				For $i = 0 To UBound($g_aTab1Controls) - 1
					If $g_aTab1Controls[$i] <> 0 Then
						GUICtrlSetState($g_aTab1Controls[$i], $GUI_HIDE)
					EndIf
				Next
			Case 2  ; Hide Official Content tab
				For $i = 0 To UBound($g_aTab2Controls) - 1
					If $g_aTab2Controls[$i] <> 0 Then
						GUICtrlSetState($g_aTab2Controls[$i], $GUI_HIDE)
					EndIf
				Next
			Case 3  ; Hide Options tab
				For $i = 0 To UBound($g_aTab3Controls) - 1
					If $g_aTab3Controls[$i] <> 0 Then
						GUICtrlSetState($g_aTab3Controls[$i], $GUI_HIDE)
					EndIf
				Next
		EndSwitch

		; Show new tab's controls
		Switch $iTabNumber
			Case 1  ; Show Installation tab
				For $i = 0 To UBound($g_aTab1Controls) - 1
					If $g_aTab1Controls[$i] <> 0 Then
						GUICtrlSetState($g_aTab1Controls[$i], $GUI_SHOW)
					EndIf
				Next
				; Update tab button styles - Installation active
				GUICtrlSetBkColor($g_idTabBtn1, $COLOR_UT_ORANGE)
				GUICtrlSetColor($g_idTabBtn1, $COLOR_BG_DARK)
				GUICtrlSetBkColor($g_idTabBtn2, $COLOR_BG_MID)
				GUICtrlSetColor($g_idTabBtn2, $COLOR_TEXT)
				GUICtrlSetBkColor($g_idTabBtn3, $COLOR_BG_MID)
				GUICtrlSetColor($g_idTabBtn3, $COLOR_TEXT)

			Case 2  ; Show Official Content tab
				For $i = 0 To UBound($g_aTab2Controls) - 1
					If $g_aTab2Controls[$i] <> 0 Then
						GUICtrlSetState($g_aTab2Controls[$i], $GUI_SHOW)
					EndIf
				Next
				; Update tab button styles - Official Content active
				GUICtrlSetBkColor($g_idTabBtn1, $COLOR_BG_MID)
				GUICtrlSetColor($g_idTabBtn1, $COLOR_TEXT)
				GUICtrlSetBkColor($g_idTabBtn2, $COLOR_UT_ORANGE)
				GUICtrlSetColor($g_idTabBtn2, $COLOR_BG_DARK)
				GUICtrlSetBkColor($g_idTabBtn3, $COLOR_BG_MID)
				GUICtrlSetColor($g_idTabBtn3, $COLOR_TEXT)

			Case 3  ; Show Options tab
				For $i = 0 To UBound($g_aTab3Controls) - 1
					If $g_aTab3Controls[$i] <> 0 Then
						GUICtrlSetState($g_aTab3Controls[$i], $GUI_SHOW)
					EndIf
				Next
				; Update tab button styles - Options active
				GUICtrlSetBkColor($g_idTabBtn1, $COLOR_BG_MID)
				GUICtrlSetColor($g_idTabBtn1, $COLOR_TEXT)
				GUICtrlSetBkColor($g_idTabBtn2, $COLOR_BG_MID)
				GUICtrlSetColor($g_idTabBtn2, $COLOR_TEXT)
				GUICtrlSetBkColor($g_idTabBtn3, $COLOR_UT_ORANGE)
				GUICtrlSetColor($g_idTabBtn3, $COLOR_BG_DARK)
		EndSwitch

		; Update current tab tracker
		$g_iCurrentTab = $iTabNumber
	EndFunc

	Func CreateTabButtons()
		; WHAT: Create the three tab buttons at top of window
		; WHY: User needs to click tabs to switch between sections
		; HOW: Create buttons styled as tabs, first one active (orange)

		; Tab button dimensions
		Local $iTabWidth = 200
		Local $iTabHeight = 30
		Local $iTabY = 20

		; Tab 1: Installation (active by default)
		$g_idTabBtn1 = GUICtrlCreateButton("Installation", 20, $iTabY, $iTabWidth, $iTabHeight)
		GUICtrlSetFont(-1, 10, 600)
		GUICtrlSetBkColor(-1, $COLOR_UT_ORANGE)  ; Orange = active
		GUICtrlSetColor(-1, $COLOR_BG_DARK)  ; Dark text on orange

		; Tab 2: Official Content (inactive)
		$g_idTabBtn2 = GUICtrlCreateButton("Official Content", 225, $iTabY, $iTabWidth, $iTabHeight)
		GUICtrlSetFont(-1, 10, 600)
		GUICtrlSetBkColor(-1, $COLOR_BG_MID)  ; Medium gray = inactive
		GUICtrlSetColor(-1, $COLOR_TEXT)  ; Normal text

		; Tab 3: Options (inactive)
		$g_idTabBtn3 = GUICtrlCreateButton("Options", 430, $iTabY, $iTabWidth, $iTabHeight)
		GUICtrlSetFont(-1, 10, 600)
		GUICtrlSetBkColor(-1, $COLOR_BG_MID)  ; Medium gray = inactive
		GUICtrlSetColor(-1, $COLOR_TEXT)  ; Normal text
	EndFunc

	Func CreateTab1_Installation()
		; WHAT: Create controls for Installation tab
		; WHY: User needs to specify install path and CD key
		; HOW: Create labels, inputs, button - store control IDs in array
		;
		; RETURN: Array of control IDs for this tab

		Local $aControls[12]  ; Array to store control IDs (increased size)
		Local $iIdx = 0

		; Content starts at Y=60 (below tab buttons)
		Local $iContentY = 60

		; Title Label - "UT2004 All-In-One Installer"
		$aControls[$iIdx] = GUICtrlCreateLabel("UT2004 All-In-One Installer", 20, $iContentY + 5, 600, 30, $SS_CENTER)
		GUICtrlSetFont(-1, 14, 800)
		GUICtrlSetColor(-1, $COLOR_UT_ORANGE)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		$iIdx += 1

		; Version Label - small gray text below title
		$aControls[$iIdx] = GUICtrlCreateLabel("v" & $INSTALLER_VERSION, 20, $iContentY + 35, 600, 15, $SS_CENTER)
		GUICtrlSetFont(-1, 8)
		GUICtrlSetColor(-1, $COLOR_TEXT_DIM)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		$iIdx += 1

		; Installation Path Label - moved down another 10px
		$aControls[$iIdx] = GUICtrlCreateLabel("Installation Path:", 20, $iContentY + 80, 200, 20)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		$iIdx += 1

		; Installation Path Input - extended to 490px
		$g_idInputInstallPath = GUICtrlCreateInput($g_sInstallPath, 20, $iContentY + 105, 490, 25)
		GUICtrlSetBkColor(-1, $COLOR_BG_MID)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		$aControls[$iIdx] = $g_idInputInstallPath
		$iIdx += 1

		; Browse Button - moved to 520, BLUE!
		$g_idBtnBrowse = GUICtrlCreateButton("Browse...", 520, $iContentY + 105, 100, 25)
		GUICtrlSetBkColor(-1, $COLOR_UT_BLUE)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		$aControls[$iIdx] = $g_idBtnBrowse
		$iIdx += 1

		; CD Key Label
		$aControls[$iIdx] = GUICtrlCreateLabel("CD Key (Optional - for online server stats):", 20, $iContentY + 150, 400, 20)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		$iIdx += 1

		; CD Key Input with placeholder - extended to 600px (full width)
		$g_idInputCDKey = GUICtrlCreateInput("", 20, $iContentY + 175, 600, 25)
		GUICtrlSetBkColor(-1, $COLOR_BG_MID)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSendMsg(-1, 0x1501, True, "XXXXX-XXXXX-XXXXX-XXXXX")  ; EM_SETCUEBANNER - placeholder text
		$aControls[$iIdx] = $g_idInputCDKey
		$iIdx += 1

		; CD Key Hint - shortened
		$aControls[$iIdx] = GUICtrlCreateLabel("(Leave blank if you don't have one)", 20, $iContentY + 205, 550, 20)
		GUICtrlSetFont(-1, 8)
		GUICtrlSetColor(-1, $COLOR_TEXT_DIM)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		$iIdx += 1

		; Trim array to actual size
		ReDim $aControls[$iIdx]

		Return $aControls
	EndFunc

	Func CreateTab2_OfficialContent()
		; WHAT: Create controls for Official Content tab
		; WHY: User selects which bonus packs to install
		; HOW: Create checkboxes for MegaPack and Community Bonus Packs
		;
		; RETURN: Array of control IDs for this tab

		Local $aControls[20]  ; Array to store control IDs
		Local $iIdx = 0

		; Content starts at Y=60 (below tab buttons)
		Local $iContentY = 80
		Local $iSpacing = 30  ; Space between checkboxes

		; MegaPack checkbox
		$g_idCheckboxMegaPack = GUICtrlCreateCheckbox("", 20, $iContentY, 20, 20)
		GUICtrlSetState(-1, $GUI_CHECKED)  ; Checked by default
		$aControls[$iIdx] = $g_idCheckboxMegaPack
		$iIdx += 1

		; MegaPack label
		$g_idLabelMegaPack = GUICtrlCreateLabel("Install MegaPack (ECE content + 9 bonus maps) - ~190 MB download", 45, $iContentY + 2, 570, 20)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		$aControls[$iIdx] = $g_idLabelMegaPack
		$iIdx += 1
		RegisterLabelCheckboxPair($g_idLabelMegaPack, $g_idCheckboxMegaPack)

		; Community Bonus Pack 1 checkbox
		$g_idCheckboxCBP1 = GUICtrlCreateCheckbox("", 20, $iContentY + $iSpacing, 20, 20)
		GUICtrlSetState(-1, $GUI_CHECKED)  ; Checked by default
		$aControls[$iIdx] = $g_idCheckboxCBP1
		$iIdx += 1

		; CBP1 label
		$g_idLabelCBP1 = GUICtrlCreateLabel("Community Bonus Pack 1 (19 maps) - ~138 MB download", 45, $iContentY + $iSpacing + 2, 570, 20)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		$aControls[$iIdx] = $g_idLabelCBP1
		$iIdx += 1
		RegisterLabelCheckboxPair($g_idLabelCBP1, $g_idCheckboxCBP1)

		; Community Bonus Pack 2 Vol 1 checkbox
		$g_idCheckboxCBP2V1 = GUICtrlCreateCheckbox("", 20, $iContentY + ($iSpacing * 2), 20, 20)
		GUICtrlSetState(-1, $GUI_CHECKED)  ; Checked by default
		$aControls[$iIdx] = $g_idCheckboxCBP2V1
		$iIdx += 1

		; CBP2 Vol 1 label
		$g_idLabelCBP2V1 = GUICtrlCreateLabel("Community Bonus Pack 2 Volume 1 (21 maps) - ~195 MB download", 45, $iContentY + ($iSpacing * 2) + 2, 570, 20)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		$aControls[$iIdx] = $g_idLabelCBP2V1
		$iIdx += 1
		RegisterLabelCheckboxPair($g_idLabelCBP2V1, $g_idCheckboxCBP2V1)

		; Community Bonus Pack 2 Vol 2 checkbox
		$g_idCheckboxCBP2V2 = GUICtrlCreateCheckbox("", 20, $iContentY + ($iSpacing * 3), 20, 20)
		GUICtrlSetState(-1, $GUI_CHECKED)  ; Checked by default
		$aControls[$iIdx] = $g_idCheckboxCBP2V2
		$iIdx += 1

		; CBP2 Vol 2 label
		$g_idLabelCBP2V2 = GUICtrlCreateLabel("Community Bonus Pack 2 Volume 2 (20 maps) - ~192 MB download", 45, $iContentY + ($iSpacing * 3) + 2, 570, 20)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		$aControls[$iIdx] = $g_idLabelCBP2V2
		$iIdx += 1
		RegisterLabelCheckboxPair($g_idLabelCBP2V2, $g_idCheckboxCBP2V2)

		; Hide all controls initially (Tab 2 not active by default)
		For $i = 0 To $iIdx - 1
			GUICtrlSetState($aControls[$i], $GUI_HIDE)
		Next

		; Trim array to actual size
		ReDim $aControls[$iIdx]

		Return $aControls
	EndFunc

	Func CreateTab3_Options()
		; WHAT: Create controls for Options tab
		; WHY: User selects installer options and game configuration
		; HOW: Create checkboxes for active options + disabled placeholders for future features
		;
		; RETURN: Array of control IDs for this tab

		Local $aControls[20]  ; Array to store control IDs
		Local $iIdx = 0

		; Content starts at Y=80 (below tab buttons)
		Local $iContentY = 80
		Local $iSpacing = 30  ; Space between checkboxes

		; Keep installer files checkbox
		$g_idCheckboxKeepFiles = GUICtrlCreateCheckbox("", 20, $iContentY, 20, 20)
		GUICtrlSetState(-1, $GUI_UNCHECKED)  ; Unchecked by default
		$aControls[$iIdx] = $g_idCheckboxKeepFiles
		$iIdx += 1

		; Keep files label
		$g_idLabelKeepFiles = GUICtrlCreateLabel("Keep installer files (saves next to installer for portable reuse)", 45, $iContentY + 2, 570, 20)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		$aControls[$iIdx] = $g_idLabelKeepFiles
		$iIdx += 1
		RegisterLabelCheckboxPair($g_idLabelKeepFiles, $g_idCheckboxKeepFiles)

		; Register file associations checkbox
		$g_idCheckboxFileAssoc = GUICtrlCreateCheckbox("", 20, $iContentY + $iSpacing, 20, 20)
		GUICtrlSetState(-1, $GUI_CHECKED)  ; Checked by default
		$aControls[$iIdx] = $g_idCheckboxFileAssoc
		$iIdx += 1

		; File associations label
		$g_idLabelFileAssoc = GUICtrlCreateLabel("Register file associations (ut2004:// protocol and .ut4mod files)", 45, $iContentY + $iSpacing + 2, 570, 20)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		$aControls[$iIdx] = $g_idLabelFileAssoc
		$iIdx += 1
		RegisterLabelCheckboxPair($g_idLabelFileAssoc, $g_idCheckboxFileAssoc)

		; Add Windows Firewall exception checkbox
		$g_idCheckboxFirewall = GUICtrlCreateCheckbox("", 20, $iContentY + ($iSpacing * 2), 20, 20)
		GUICtrlSetState(-1, $GUI_CHECKED)  ; Checked by default
		$aControls[$iIdx] = $g_idCheckboxFirewall
		$iIdx += 1

		; Firewall label
		$g_idLabelFirewall = GUICtrlCreateLabel("Add Windows Firewall exception (required for online play)", 45, $iContentY + ($iSpacing * 2) + 2, 570, 20)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		$aControls[$iIdx] = $g_idLabelFirewall
		$iIdx += 1
		RegisterLabelCheckboxPair($g_idLabelFirewall, $g_idCheckboxFirewall)

		; === AUTO RESOLUTION ===

		; Detect monitor resolution and refresh rate via WMI
		; WHAT: Query Windows for current display settings
		; WHY: We need the values before building the label text
		; HOW: WMI Win32_VideoController query
		Local $sResLabel = ""
		Local $bResDetected = False

		Local $oWMI = ObjGet("winmgmts:\\.\root\cimv2")
		If IsObj($oWMI) Then
			Local $oDisplays = $oWMI.ExecQuery("SELECT * FROM Win32_VideoController")
			If IsObj($oDisplays) Then
				For $oDisplay In $oDisplays
					If $oDisplay.CurrentHorizontalResolution > 0 Then
						$g_iDetectedWidth   = $oDisplay.CurrentHorizontalResolution
						$g_iDetectedHeight  = $oDisplay.CurrentVerticalResolution
						$g_iDetectedRefresh = $oDisplay.CurrentRefreshRate
						$bResDetected = True
						ExitLoop
					EndIf
				Next
			EndIf
		EndIf

		; Auto resolution checkbox
		$g_idCheckboxAutoRes = GUICtrlCreateCheckbox("", 20, $iContentY + ($iSpacing * 3), 20, 20)
		$aControls[$iIdx] = $g_idCheckboxAutoRes
		$iIdx += 1

		; Auto resolution label - shows detected values or failure message
		If $bResDetected Then
			$sResLabel = "Set default resolution to (Detected: " & $g_iDetectedWidth & "x" & $g_iDetectedHeight & " @ " & $g_iDetectedRefresh & "Hz)"
			GUICtrlSetState($g_idCheckboxAutoRes, $GUI_CHECKED)  ; Checked by default if detected
			$g_idLabelAutoRes = GUICtrlCreateLabel($sResLabel, 45, $iContentY + ($iSpacing * 3) + 2, 570, 20)
			GUICtrlSetColor(-1, $COLOR_TEXT)
		Else
			$sResLabel = "Resolution detection failed - using game default (800x600)"
			GUICtrlSetState($g_idCheckboxAutoRes, $GUI_UNCHECKED)
			GUICtrlSetState($g_idCheckboxAutoRes, $GUI_DISABLE)
			$g_idLabelAutoRes = GUICtrlCreateLabel($sResLabel, 45, $iContentY + ($iSpacing * 3) + 2, 570, 20)
			GUICtrlSetColor(-1, $COLOR_TEXT_DIM)
		EndIf
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		$aControls[$iIdx] = $g_idLabelAutoRes
		$iIdx += 1
		If $bResDetected Then RegisterLabelCheckboxPair($g_idLabelAutoRes, $g_idCheckboxAutoRes)

		; === MAX DETAIL ===

		; Max detail checkbox - unchecked by default (hardware dependent)
		$g_idCheckboxMaxDetail = GUICtrlCreateCheckbox("", 20, $iContentY + ($iSpacing * 4), 20, 20)
		GUICtrlSetState(-1, $GUI_UNCHECKED)
		$aControls[$iIdx] = $g_idCheckboxMaxDetail
		$iIdx += 1

		; Max detail label
		$g_idLabelMaxDetail = GUICtrlCreateLabel("Set Holy S**t! (Maximum detail settings)", 45, $iContentY + ($iSpacing * 4) + 2, 570, 20)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		$aControls[$iIdx] = $g_idLabelMaxDetail
		$iIdx += 1
		RegisterLabelCheckboxPair($g_idLabelMaxDetail, $g_idCheckboxMaxDetail)

		; Hide all controls initially (Tab 3 not active by default)
		For $i = 0 To $iIdx - 1
			GUICtrlSetState($aControls[$i], $GUI_HIDE)
		Next

		; Trim array to actual size
		ReDim $aControls[$iIdx]

		Return $aControls
	EndFunc

	Func CopyBonusPackParts($sSourceDir, $sDestDir, $sBaseName, $iPartCount)
		; WHAT: Copy bonus pack split archive files to Installer folder
		; WHY: User wants to keep installer files for future use
		; HOW: Copy .z01, .z02, etc. and .zip files if they exist
		;
		; PARAMETERS:
		;   $sSourceDir  - Source directory containing the files
		;   $sDestDir    - Destination directory
		;   $sBaseName   - Base filename (e.g., "CBP1", "cbp2_volume1")
		;   $iPartCount  - Number of parts (3 or 4)

		If Not FileExists($sSourceDir) Then Return

		; Copy .z01, .z02, .z03 (if applicable)
		For $i = 1 To $iPartCount - 1
			Local $sPartNum = StringFormat("%02d", $i)
			Local $sSourceFile = $sSourceDir & "\" & $sBaseName & ".z" & $sPartNum

			If FileExists($sSourceFile) Then
				FileCopy($sSourceFile, $sDestDir & "\" & $sBaseName & ".z" & $sPartNum, 1)
				LogMessage("Copied: " & $sBaseName & ".z" & $sPartNum)
			EndIf
		Next

		; Copy final .zip file
		Local $sZipSource = $sSourceDir & "\" & $sBaseName & ".zip"
		If FileExists($sZipSource) Then
			FileCopy($sZipSource, $sDestDir & "\" & $sBaseName & ".zip", 1)
			LogMessage("Copied: " & $sBaseName & ".zip")
		EndIf
	EndFunc

	Func AddFirewallRules()
		; WHAT: Add Windows Firewall exceptions for UT2004
		; WHY: Required for online multiplayer
		; HOW: Use netsh to add inbound and outbound rules

		Local $sExe = $g_sInstallPath & "\System\UT2004.exe"

		; Remove any existing rules first (clean slate)
		RunWait('netsh advfirewall firewall delete rule name="Unreal Tournament 2004"', @SystemDir, @SW_HIDE)

		; Add inbound rule
		Local $sInbound = 'netsh advfirewall firewall add rule name="Unreal Tournament 2004" dir=in action=allow program="' & $sExe & '" enable=yes profile=any'
		Local $iResult = RunWait($sInbound, @SystemDir, @SW_HIDE)

		If $iResult = 0 Then
			LogMessage("Firewall inbound rule added successfully")
		Else
			LogMessage("WARNING: Failed to add firewall inbound rule (exit code: " & $iResult & ")")
		EndIf

		; Add outbound rule
		Local $sOutbound = 'netsh advfirewall firewall add rule name="Unreal Tournament 2004" dir=out action=allow program="' & $sExe & '" enable=yes profile=any'
		$iResult = RunWait($sOutbound, @SystemDir, @SW_HIDE)

		If $iResult = 0 Then
			LogMessage("Firewall outbound rule added successfully")
		Else
			LogMessage("WARNING: Failed to add firewall outbound rule (exit code: " & $iResult & ")")
		EndIf

	EndFunc

	Func LoadSettings()
		; WHAT: Load user preferences from INI file
		; WHY: Convenience for repeat users (especially testers)
		; HOW: Read installer_settings.ini from script directory
		;
		; INI File Format:
		; [Options]
		; KeepFiles=1
		; CleanTemp=0
		; [Installation]
		; CDKey=XXXXX-XXXXX-XXXXX-XXXXX

		Local $sINIFile = @ScriptDir & "\installer_settings.ini"

		; Check if settings file exists
		If Not FileExists($sINIFile) Then
			Return  ; No settings to load
		EndIf

		; Load CD Key
		Local $sCDKey = IniRead($sINIFile, "Installation", "CDKey", "")
		If $sCDKey <> "" Then
			GUICtrlSetData($g_idInputCDKey, $sCDKey)
		EndIf

		; Load Keep Files setting
		Local $iKeepFiles = IniRead($sINIFile, "Options", "KeepFiles", "0")
		If $iKeepFiles = "1" Then
			GUICtrlSetState($g_idCheckboxKeepFiles, $GUI_CHECKED)
		Else
			GUICtrlSetState($g_idCheckboxKeepFiles, $GUI_UNCHECKED)
		EndIf

		; Load Firewall setting
		Local $iFirewall = IniRead($sINIFile, "Options", "AddFirewall", "1")
		If $iFirewall = "1" Then
			GUICtrlSetState($g_idCheckboxFirewall, $GUI_CHECKED)
		Else
			GUICtrlSetState($g_idCheckboxFirewall, $GUI_UNCHECKED)
		EndIf

		; Load Clean Temp setting (inverse logic - save means DON'T clean)
		Local $iCleanTemp = IniRead($sINIFile, "Options", "CleanTemp", "1")
		If $iCleanTemp = "0" Then
			; User wants to keep temp files
			GUICtrlSetState($g_idCheckboxKeepFiles, $GUI_CHECKED)  ; Check "Keep Files" to prevent cleanup
		EndIf

		LogMessage("Loaded settings from: " & $sINIFile)
	EndFunc

	Func SaveSettings()
		; WHAT: Save current checkbox states to INI file
		; WHY: Remember user preferences for next run
		; HOW: Write to installer_settings.ini in script directory

		Local $sINIFile = @ScriptDir & "\installer_settings.ini"

		; Save CD Key (if provided)
		Local $sCDKey = StringStripWS(GUICtrlRead($g_idInputCDKey), 3)
		IniWrite($sINIFile, "Installation", "CDKey", $sCDKey)

		; Save Keep Files setting
		Local $bKeepFiles = (GUICtrlRead($g_idCheckboxKeepFiles) = $GUI_CHECKED)
		IniWrite($sINIFile, "Options", "KeepFiles", $bKeepFiles ? "1" : "0")

		; Note: CleanTemp is controlled by KeepFiles checkbox behavior
		; If KeepFiles is checked, temp is kept; if unchecked, temp is cleaned
		IniWrite($sINIFile, "Options", "CleanTemp", $bKeepFiles ? "0" : "1")

		; Save Firewall setting
		Local $bFirewall = (GUICtrlRead($g_idCheckboxFirewall) = $GUI_CHECKED)
		IniWrite($sINIFile, "Options", "AddFirewall", $bFirewall ? "1" : "0")

		; Save Max Detail setting
		Local $bMaxDetail = (GUICtrlRead($g_idCheckboxMaxDetail) = $GUI_CHECKED)
		IniWrite($sINIFile, "Options", "MaxDetail", $bMaxDetail ? "1" : "0")

		; Note: AutoRes is not saved - it's always re-detected fresh on each launch

		LogMessage("Saved settings to: " & $sINIFile)
	EndFunc
#EndRegion
