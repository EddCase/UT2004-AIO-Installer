#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.16.1
	Author:         EddCase
	Version:        0.3.2-alpha
	
	Script Function:
		UT2004 All-In-One Installer
		Custom installation with full control over the process
		
	Phase 1: GUI with UT2004 Theme (COMPLETE)
	Phase 2: ISO Download (COMPLETE)
	Phase 3: ISO Extraction (COMPLETE)
	Phase 4: CAB Extraction (COMPLETE)
	Phase 5: Copy Files & Finalize (CURRENT)

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
	
	; Working directories (temporary)
	Global $g_sTempDir = @TempDir & "\UT2004_Install"      ; Main temp folder
	Global $g_sDownloadDir = $g_sTempDir & "\_Downloads"   ; Where we download ISO
	Global $g_sTempCABs = $g_sTempDir & "\_Temp_CABs"      ; Extracted CAB files
	
	; Tool paths (bundled with installer)
	Global $g_s7Zip = @ScriptDir & "\Tools\7z.exe"
	Global $g_sUnshield = @ScriptDir & "\Tools\unshield.exe"
	
	; Download URLs
	Global $g_sISOUrl = "https://files.oldunreal.net/UT2004.ISO"
	Global $g_sPatchUrl = "https://github.com/OldUnreal/UT2004Patches/releases/latest"  ; We'll parse this for actual download
	
	; Installation log
	Global $g_hLogFile = 0  ; File handle for install.log
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
		
		; Create and show the GUI
		; WHAT: Build the installer window with all controls
		; WHY: User needs interface to choose install location and start installation
		; HOW: CreateGUI() function creates window and all controls
		CreateGUI()
		
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
		;      The files must exist in the source location when compiling
		
		; Create Tools directory if it doesn't exist
		; WHAT: Make sure we have somewhere to put the extracted tools
		; WHY: FileInstall will fail if the directory doesn't exist
		; HOW: DirCreate creates the folder, won't error if already exists
		If Not FileExists(@ScriptDir & "\Tools") Then
			DirCreate(@ScriptDir & "\Tools")
		EndIf
		
		; NOTE: FileInstall lines are commented out for now because we don't have the actual tool files yet
		; When you add the tools to the Tools/ folder, uncomment these lines
		; The syntax is: FileInstall("source_path", "destination_path", overwrite_flag)
		;   - source_path: Where the file is during development
		;   - destination_path: Where to extract it at runtime
		;   - 1 = overwrite if exists
		
		FileInstall("Tools\7z.exe", @ScriptDir & "\Tools\7z.exe", 1)
		FileInstall("Tools\7z.dll", @ScriptDir & "\Tools\7z.dll", 1)
		FileInstall("Tools\unshield.exe", @ScriptDir & "\Tools\unshield.exe", 1)
		FileInstall("Tools\zlib1.dll", @ScriptDir & "\Tools\zlib1.dll", 1)
		
		; Verify tools extracted successfully
		; WHAT: Make sure the critical tools are available
		; WHY: Better to fail early with clear error than fail later mysteriously
		; HOW: Check if files exist, show error and exit if missing
		
		If Not FileExists($g_s7Zip) Then
		    MsgBox(16, "Missing Tool", "Failed to extract 7z.exe" & @CRLF & "Installer may be corrupt.")
		    Exit
		EndIf
		
		If Not FileExists($g_sUnshield) Then
		    MsgBox(16, "Missing Tool", "Failed to extract unshield.exe" & @CRLF & "Installer may be corrupt.")
		    Exit
		EndIf
		
	EndFunc
#EndRegion

#Region GUI Creation
	Func CreateGUI()
		; WHAT: Create the main installer window with UT2004 theming
		; WHY: User needs a GUI to interact with the installer
		; HOW: Use GUICreate and GUICtrlCreate functions to build interface
		;      Apply UT2004 color scheme throughout
		
		; Create main window
		; WHAT: The main installer window
		; WHY: Container for all our controls
		; HOW: GUICreate(title, width, height, x, y, style)
		;   - -1, -1: Center on screen
		;   - $WS_CAPTION + $WS_SYSMENU: Title bar with close button, no resize
		;   - $WS_EX_TOPMOST: Keep window on top (optional, can remove)
		$g_hGUI = GUICreate("Unreal Tournament 2004 - Community Installer", 600, 480, -1, -1, _
				BitOR($WS_CAPTION, $WS_SYSMENU))
		
		; WHAT: Set window background color
		; WHY: Match UT2004's dark theme
		; HOW: GUISetBkColor sets background, takes RGB color value
		GUISetBkColor($COLOR_BG_DARK, $g_hGUI)
		
		; Title Label
		; WHAT: Large title at top of window
		; WHY: Clearly identify what this installer does
		; HOW: GUICtrlCreateLabel(text, x, y, width, height, style)
		;   - $SS_CENTER: Center the text
		;   - Position: 20 pixels from top, full width minus margins
		Local $idLabelTitle = GUICtrlCreateLabel("UT2004 All-In-One Installer", 20, 20, 560, 40, $SS_CENTER)
		GUICtrlSetFont(-1, 18, 800)  ; -1 = last created control, 18pt, bold (800)
		GUICtrlSetColor(-1, $COLOR_UT_ORANGE)  ; Orange text
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)  ; Transparent background
		
		; Version Label
		; WHAT: Version number under title
		; WHY: User knows which version they're running
		; HOW: Similar to title but smaller, dimmed color
		Local $idLabelVersion = GUICtrlCreateLabel("Version 0.3.0-alpha", 20, 65, 560, 20, $SS_CENTER)
		GUICtrlSetFont(-1, 9)
		GUICtrlSetColor(-1, $COLOR_TEXT_DIM)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		
		; Installation Path Section
		; WHAT: Label for installation path input
		; WHY: User needs to know what they're selecting
		; HOW: Label positioned above the input box
		Local $idLabelInstallPath = GUICtrlCreateLabel("Installation Directory:", 20, 110, 560, 20)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		
		; Installation path input box
		; WHAT: Text box showing where UT2004 will be installed
		; WHY: User can see and edit install location
		; HOW: Input control with default path
		;   - Width: 470 (leaves room for Browse button)
		$g_idInputInstallPath = GUICtrlCreateInput($g_sInstallPath, 20, 135, 470, 25)
		GUICtrlSetColor(-1, $COLOR_TEXT)  ; Light gray text
		GUICtrlSetBkColor(-1, $COLOR_BG_MID)  ; Mid-dark background
		
		; Browse button
		; WHAT: Button to open folder picker dialog
		; WHY: Easier than typing a path manually
		; HOW: Button positioned next to input box
		;   - X: 500 (right of input box)
		;   - Width: 80
		$g_idBtnBrowse = GUICtrlCreateButton("Browse...", 500, 135, 80, 25)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $COLOR_UT_BLUE)  ; Blue button
		
		; CD Key Section (Optional)
		; WHAT: Label for CD key input
		; WHY: Optional - allows users to add CD key for server stats
		; HOW: Label positioned below installation path
		Local $idLabelCDKey = GUICtrlCreateLabel("CD Key (Optional - for online server stats):", 20, 175, 560, 20)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		
		; CD Key input box
		; WHAT: Text box for optional CD key
		; WHY: Servers track stats by CD key
		; HOW: Input control with placeholder hint
		;   - Format: XXXXX-XXXXX-XXXXX-XXXXX (validated on install)
		$g_idInputCDKey = GUICtrlCreateInput("", 20, 200, 470, 25)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $COLOR_BG_MID)
		GUICtrlSendMsg(-1, 0x1501, True, "XXXXX-XXXXX-XXXXX-XXXXX")  ; EM_SETCUEBANNER - placeholder text
		
		; CD Key hint
		; WHAT: Explain CD key is optional
		; WHY: User should know they can skip it
		; HOW: Dimmed text as a hint
		Local $idLabelCDKeyHint = GUICtrlCreateLabel("(Leave blank if you don't have one - not required for single player)", 40, 230, 540, 20)
		GUICtrlSetFont(-1, 8)
		GUICtrlSetColor(-1, $COLOR_TEXT_DIM)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		
		; Options Section
		; WHAT: Checkbox for keeping installer files (without text)
		; WHY: AutoIt checkboxes don't support text coloring, so we use a separate label
		; HOW: Create checkbox without text, then label next to it
		$g_idCheckboxKeepFiles = GUICtrlCreateCheckbox("", 20, 260, 20, 20)
		GUICtrlSetState(-1, $GUI_CHECKED)  ; Checked by default
		
		; Label for checkbox (clickable to toggle checkbox)
		; WHAT: Themed label next to checkbox
		; WHY: We can color this label, unlike checkbox text
		; HOW: Position it right after the checkbox, register in mapping system
		$g_idLabelKeepFiles = GUICtrlCreateLabel("Keep installer files in game directory (~2.8 GB)", 45, 262, 535, 20)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		
		; Register this label/checkbox pair for click handling
		; WHAT: Add to our mapping array so clicking label toggles checkbox
		; WHY: Reusable system - works for all future checkboxes too
		; HOW: Call RegisterLabelCheckboxPair() helper function
		RegisterLabelCheckboxPair($g_idLabelKeepFiles, $g_idCheckboxKeepFiles)
		
		; Info label about what gets kept
		; WHAT: Explain what "keep files" means
		; WHY: User should know what they're keeping
		; HOW: Dimmed text as a hint/note
		Local $idLabelKeepInfo = GUICtrlCreateLabel("(Saves ISO and patch for future use)", 40, 285, 540, 20)
		GUICtrlSetFont(-1, 8)
		GUICtrlSetColor(-1, $COLOR_TEXT_DIM)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		
		; Progress Bar
		; WHAT: Visual indicator of installation progress
		; WHY: User needs to see installation is working
		; HOW: Progress bar control, initially at 0%
		;   - PBS_SMOOTH: Smooth progress (not chunky blocks)
		$g_idProgressBar = GUICtrlCreateProgress(20, 330, 560, 25)
		GUICtrlSetColor(-1, $COLOR_UT_ORANGE)  ; Orange progress bar
		
		; Status Label
		; WHAT: Text description of current step
		; WHY: User should know what's happening
		; HOW: Label below progress bar, will be updated during installation
		$g_idLabelStatus = GUICtrlCreateLabel("Ready to install", 20, 365, 560, 20, $SS_CENTER)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		
		; Install Button
		; WHAT: Big button to start installation
		; WHY: Primary action of the installer
		; HOW: Large, centered button with orange background
		;   - Height: 40 (bigger than other buttons)
		$g_idBtnInstall = GUICtrlCreateButton("Install UT2004", 200, 410, 200, 40)
		GUICtrlSetFont(-1, 12, 600)  ; 12pt, semi-bold
		GUICtrlSetColor(-1, $COLOR_BG_DARK)  ; Dark text on orange
		GUICtrlSetBkColor(-1, $COLOR_UT_ORANGE)  ; Orange button
		
		; Show the window
		; WHAT: Make the window visible
		; WHY: User needs to see the GUI we just created
		; HOW: GUISetState displays the window
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
			; Convert to uppercase for consistency
			$sCDKey = StringUpper($sCDKey)
			LogMessage("CD Key provided: " & $sCDKey)
		Else
			LogMessage("No CD Key provided (optional)")
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
		
		; Disable UI during installation
		; WHAT: Prevent user from changing things mid-install
		; WHY: Changing paths/keys during installation would cause problems
		; HOW: Disable input, browse, and install buttons
		GUICtrlSetState($g_idInputInstallPath, $GUI_DISABLE)
		GUICtrlSetState($g_idInputCDKey, $GUI_DISABLE)
		GUICtrlSetState($g_idBtnBrowse, $GUI_DISABLE)
		GUICtrlSetState($g_idBtnInstall, $GUI_DISABLE)
		GUICtrlSetState($g_idCheckboxKeepFiles, $GUI_DISABLE)
		
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
		
		; Temporary: Mark as complete
		UpdateStatus("Installation complete (patching will be added in Phase 5b)")
		Sleep(2000)
		
		; Temporary: Mark as complete for testing
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
		
		; Define ISO path
		; WHAT: Where the ISO will be downloaded
		; WHY: Centralized location for downloads
		; HOW: Use global download directory + filename
		Local $sISOPath = $g_sDownloadDir & "\UT2004.ISO"
		
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
		Local $iExpectedSize = InetGetSize($g_sISOUrl)
		
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
		; HOW: FileExists checks for file, FileGetSize checks if complete
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
		; WHAT: Download UT2004.ISO from OldUnreal
		; WHY: We need it and don't have it (or it was wrong size)
		; HOW: Call DownloadFileWithProgress function
		UpdateStatus("Downloading UT2004.ISO from files.oldunreal.net...")
		TrayTip("UT2004 Installer", "Downloading UT2004 (~2.8 GB) - This may take a while...", 10, 1)
		LogMessage("Starting ISO download from: " & $g_sISOUrl)
		
		If Not DownloadFileWithProgress($g_sISOUrl, $sISOPath, 0, 50) Then
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
		TrayTip("UT2004 Installer", "Download complete! Installing...", 3, 1)
		
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
		
		UpdateStatus("Files copied successfully")
		LogMessage("File copy complete - all game files installed")
		
		Return True
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
		LogMessage("UT2004 All-In-One Installer v0.3.2-alpha")
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
		
		; Reset progress bar
		GUICtrlSetData($g_idProgressBar, 0)
		UpdateStatus("Installation failed - see log for details")
	EndFunc
#EndRegion
