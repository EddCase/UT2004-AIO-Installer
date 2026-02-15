#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.16.1
	Author:         EddCase
	Version:        0.3.0-alpha

	Script Function:
		UT2004 All-In-One Installer
		Custom installation with full control over the process

	Phase 1: GUI with UT2004 Theme (CURRENT)
	Phase 2: ISO Download
	Phase 3: ISO Extraction
	Phase 4: CAB Extraction
	Phase 5: Patch & Finalize

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

		; FileInstall("Tools\7z.exe", @ScriptDir & "\Tools\7z.exe", 1)
		; FileInstall("Tools\7z.dll", @ScriptDir & "\Tools\7z.dll", 1)
		; FileInstall("Tools\unshield.exe", @ScriptDir & "\Tools\unshield.exe", 1)
		; FileInstall("Tools\zlib1.dll", @ScriptDir & "\Tools\zlib1.dll", 1)

		; Verify tools extracted successfully
		; WHAT: Make sure the critical tools are available
		; WHY: Better to fail early with clear error than fail later mysteriously
		; HOW: Check if files exist, show error and exit if missing

		; For now, just check if Tools folder exists (since FileInstall is commented out)
		; Later, uncomment this to verify actual tool files
		; If Not FileExists($g_s7Zip) Then
		;     MsgBox(16, "Missing Tool", "Failed to extract 7z.exe" & @CRLF & "Installer may be corrupt.")
		;     Exit
		; EndIf
		;
		; If Not FileExists($g_sUnshield) Then
		;     MsgBox(16, "Missing Tool", "Failed to extract unshield.exe" & @CRLF & "Installer may be corrupt.")
		;     Exit
		; EndIf

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
		$g_hGUI = GUICreate("Unreal Tournament 2004 - Community Installer", 600, 400, -1, -1, _
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

		; Options Section
		; WHAT: Checkbox for keeping installer files (without text)
		; WHY: AutoIt checkboxes don't support text coloring, so we use a separate label
		; HOW: Create checkbox without text, then label next to it
		$g_idCheckboxKeepFiles = GUICtrlCreateCheckbox("", 20, 180, 20, 20)
		GUICtrlSetState(-1, $GUI_CHECKED)  ; Checked by default

		; Label for checkbox (clickable to toggle checkbox)
		; WHAT: Themed label next to checkbox
		; WHY: We can color this label, unlike checkbox text
		; HOW: Position it right after the checkbox, register in mapping system
		$g_idLabelKeepFiles = GUICtrlCreateLabel("Keep installer files in game directory (~2.8 GB)", 45, 182, 535, 20)
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
		Local $idLabelKeepInfo = GUICtrlCreateLabel("(Saves ISO and patch for future use)", 40, 205, 540, 20)
		GUICtrlSetFont(-1, 8)
		GUICtrlSetColor(-1, $COLOR_TEXT_DIM)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

		; Progress Bar
		; WHAT: Visual indicator of installation progress
		; WHY: User needs to see installation is working
		; HOW: Progress bar control, initially at 0%
		;   - PBS_SMOOTH: Smooth progress (not chunky blocks)
		$g_idProgressBar = GUICtrlCreateProgress(20, 250, 560, 25)
		GUICtrlSetColor(-1, $COLOR_UT_ORANGE)  ; Orange progress bar

		; Status Label
		; WHAT: Text description of current step
		; WHY: User should know what's happening
		; HOW: Label below progress bar, will be updated during installation
		$g_idLabelStatus = GUICtrlCreateLabel("Ready to install", 20, 285, 560, 20, $SS_CENTER)
		GUICtrlSetColor(-1, $COLOR_TEXT)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

		; Install Button
		; WHAT: Big button to start installation
		; WHY: Primary action of the installer
		; HOW: Large, centered button with orange background
		;   - Height: 40 (bigger than other buttons)
		$g_idBtnInstall = GUICtrlCreateButton("Install UT2004", 200, 330, 200, 40)
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

		; Get current install path from input box
		; WHAT: Read what's in the installation path text box
		; WHY: User might have typed a path instead of browsing
		; HOW: GUICtrlRead gets text from input control
		$g_sInstallPath = GUICtrlRead($g_idInputInstallPath)

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
		; WHY: Changing paths during installation would cause problems
		; HOW: Disable input, browse, and install buttons
		GUICtrlSetState($g_idInputInstallPath, $GUI_DISABLE)
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
		;   Phase 2: Download ISO (current)
		;   Phase 3: Extract ISO
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

		; Phase 3: Extract ISO (to be implemented)
		UpdateStatus("Phase 3 (ISO extraction) will be implemented next")
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
				; HOW: Convert bytes to MB, format nicely
				Local $sMB = Round($iBytesRead / 1048576, 1)  ; Bytes to MB
				Local $sTotalMB = Round($iTotalSize / 1048576, 1)
				Local $sPercent = Round($fDownloadPercent * 100, 1)

				UpdateStatus("Downloading: " & $sMB & " MB / " & $sTotalMB & " MB (" & $sPercent & "%)")
			Else
				; Don't know total size yet
				; WHAT: Server hasn't sent Content-Length yet
				; WHY: Some servers delay sending size
				; HOW: Just show bytes downloaded
				Local $sMB = Round($iBytesRead / 1048576, 1)
				UpdateStatus("Downloading: " & $sMB & " MB...")
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
		LogMessage("UT2004 All-In-One Installer v0.3.0-alpha")
		LogMessage("Installation started: " & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC)
		LogMessage("Installation Path: " & $g_sInstallPath)
		;LogMessage("=" & String(70, "="))
		LogMessage("=" & String(70))
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
		; WHAT: Update status label, TrayTip, and log
		; WHY: Keep user informed and create permanent record
		; HOW: Update GUI (unless log-only), show TrayTip, write to log
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
		; WHAT: Update status label and show TrayTip
		; WHY: User needs visual feedback
		; HOW: Set label text and show notification
		If Not $bLogOnly Then
			GUICtrlSetData($g_idLabelStatus, $sMessage)
			TrayTip("UT2004 Installer", $sMessage, 5, 1)  ; 5 seconds, info icon

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
		;LogMessage("=" & String(70, "="))
		LogMessage("=" & String(70))
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
		;LogMessage("=" & String(70, "="))
		LogMessage("=" & String(70))
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
