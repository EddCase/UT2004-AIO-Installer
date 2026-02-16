# Tab System Implementation Plan - v0.5.2

## Overview
Convert single-page GUI to tabbed interface to reduce clutter and organize features logically.

## Window Specifications
- **Size:** 640x480 (old-school friendly!)
- **Layout:** Fixed areas for tabs (top), content (middle), progress/controls (bottom)

## Layout Breakdown

```
┌────────────────────────────────────────────────────────────┐
│  UT2004 All-In-One Installer                    v0.5.2     │ Y=0-20
├────────────────────────────────────────────────────────────┤
│ [Installation] [Official Content] [Options]                │ Y=20-50 (Tab buttons)
├────────────────────────────────────────────────────────────┤
│                                                             │
│  ╔═════════════════════════════════════════════════════╗   │
│  ║                                                     ║   │
│  ║  TAB CONTENT AREA (changes per tab)                ║   │ Y=60-340
│  ║  - Installation: Path, CD Key                      ║   │ (280px height)
│  ║  - Official Content: 4 checkboxes                  ║   │
│  ║  - Options: 2 active + 3 disabled checkboxes       ║   │
│  ║                                                     ║   │
│  ╚═════════════════════════════════════════════════════╝   │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│  [████████████████████░░░░░░] 85%                          │ Y=350-375 (Progress)
│  Status: Installing files...                               │ Y=380-400 (Status)
│                    [Install UT2004]                         │ Y=410-450 (Button)
└─────────────────────────────────────────────────────────────┘ Y=480
```

## Tab Contents

### Tab 1: Installation
**Controls:**
- Label: "Installation Path:"
- Input: Install path textbox
- Button: Browse button
- Label: "CD Key (Optional):"
- Input: CD Key textbox  
- Label: Hint text about CD Key

**Position:** Y=80 to Y=200

### Tab 2: Official Content
**Controls:**
- Checkbox + Label: Install MegaPack (~190 MB)
- Checkbox + Label: Community Bonus Pack 1 (~140 MB)
- Checkbox + Label: Community Bonus Pack 2 Vol 1 (~195 MB)
- Checkbox + Label: Community Bonus Pack 2 Vol 2 (~192 MB)

**Position:** Y=80 to Y=220
**Spacing:** 30px between each checkbox

### Tab 3: Options
**Active Controls:**
- Checkbox + Label: Keep installer files
- Checkbox + Label: Register file associations

**Disabled/Grayed Controls (Coming Soon):**
- Checkbox + Label: Configure default resolution
- Checkbox + Label: Configure refresh rate  
- Checkbox + Label: Pre-configure game settings

**Position:** Y=80 to Y=250
**Spacing:** 30px between each checkbox

## Implementation Steps

### Step 1: Add Tab Switching Function
```autoit
Func SwitchToTab($iTabNumber)
    ; Hide all tab controls
    ; Show selected tab controls
    ; Update tab button styles (active/inactive)
    ; Update $g_iCurrentTab
EndFunc
```

### Step 2: Create Tab Button Function
```autoit
Func CreateTabButtons()
    ; Create 3 buttons at Y=20-50
    ; Style them as tabs
    ; Set click handlers
EndFunc
```

### Step 3: Create Individual Tab Functions
```autoit
Func CreateTab1_Installation()
    ; Create and return array of control IDs
    ; Initially visible
EndFunc

Func CreateTab2_OfficialContent()
    ; Create and return array of control IDs
    ; Initially hidden
EndFunc

Func CreateTab3_Options()
    ; Create and return array of control IDs
    ; Initially hidden
EndFunc
```

### Step 4: Modify CreateGUI()
- Keep window size: 640x480
- Keep title at top (smaller now)
- Call CreateTabButtons()
- Call all three CreateTab functions
- Store returned control IDs in global arrays
- Initially show only Tab 1

### Step 5: Add Click Handler
- Detect tab button clicks in main loop
- Call SwitchToTab() with appropriate tab number

## State Persistence
- **Method:** Arrays (no INI files needed)
- Checkbox states persist automatically (AutoIt handles this)
- Only need to show/hide controls when switching tabs
- Each tab's control array stays in memory

## Benefits
- ✅ Cleaner UI - no more clutter
- ✅ Room for future expansion
- ✅ Logical grouping of features
- ✅ Professional appearance
- ✅ Easy to add more options later

## Migration Notes
**Moving these controls:**
- CD Key → Stays on Installation tab
- MegaPack checkbox → Moves to Official Content tab
- Keep files checkbox → Moves to Options tab
- File associations checkbox → Moves to Options tab

**Staying always visible:**
- Progress bar
- Status label
- Install button

## Testing Checklist
- [ ] Tab buttons switch correctly
- [ ] Each tab shows/hides properly
- [ ] Checkbox states persist when switching tabs
- [ ] Installation still works from any tab
- [ ] Progress bar visible on all tabs
- [ ] Window size feels good (640x480)
