# Phase 5: File Copy Mapping Strategy

## Extracted Folders → Install Directory Mapping

### ✅ COPY THESE (with rename):

| Extracted Folder | → | Install Folder | Notes |
|-----------------|---|----------------|-------|
| `All_Animations` | → | `Animations` | Game animations |
| `All_Benchmark` | → | `Benchmark` | Benchmark files + subfolders |
| `All_ForceFeedback` | → | `ForceFeedback` | Force feedback data |
| `All_Help` | → | `Help` | Help files (merge with English_Sounds...Help) |
| `All_KarmaData` | → | `KarmaData` | Physics data |
| `All_Maps` | → | `Maps` | Game maps |
| `All_Music` | → | `Music` | Music files |
| `All_StaticMeshes` | → | `StaticMeshes` | 3D meshes |
| `All_Textures` | → | `Textures` | Texture files |
| `All_UT2004.EXE` | → | `System` | **CRITICAL: Main exe + DLLs** |
| `All_Web` | → | `Web` | Web admin interface |
| `English_Manual` | → | `Manual` | Game manual |

### ✅ MERGE THESE (English_Sounds_Speech_System_Help):

This folder contains multiple subdirectories that go to different places:

| Subfolder | → | Install Location |
|-----------|---|------------------|
| `English_Sounds_Speech_System_Help\Help` | → | `Help` | Merge with All_Help |
| `English_Sounds_Speech_System_Help\Sounds` | → | `Sounds` | NEW folder |
| `English_Sounds_Speech_System_Help\Speech` | → | `Speech` | NEW folder |
| `English_Sounds_Speech_System_Help\System` | → | `System` | Merge with All_UT2004.EXE |

### ❌ SKIP THESE (not needed):

- `US_License.int` - License file (may copy to root if wanted)
- `_DirectX_*` - All DirectX folders (we don't install DirectX)
- `_Engine_*` - Engine placeholders (not needed)
- `_Support_*` - All support folders (installer metadata)

---

## Phase 5 Implementation Strategy

### Step 1: Copy "All_*" folders (simple rename)
```
For each folder starting with "All_":
  - Remove "All_" prefix
  - Copy entire folder to install directory
  - Example: All_Maps → D:\InstallPath\Maps
```

### Step 2: Copy English_Manual
```
English_Manual → Manual
```

### Step 3: Handle English_Sounds_Speech_System_Help (complex merge)
```
English_Sounds_Speech_System_Help\Help → Help (merge)
English_Sounds_Speech_System_Help\Sounds → Sounds (new)
English_Sounds_Speech_System_Help\Speech → Speech (new)
English_Sounds_Speech_System_Help\System → System (merge)
```

### Step 4: Optional - Copy license
```
US_License.int\License.int → root (if folder has file)
```

---

## Critical Files to Verify After Copy

After copying, verify these exist:
- ✅ `System\UT2004.exe` - Main game executable
- ✅ `System\Core.dll` - Core engine
- ✅ `System\Engine.dll` - Game engine
- ✅ `System\*.u` - Unreal packages
- ✅ `System\*.int` - Language files
- ✅ `Maps\*.ut2` - Map files
- ✅ `Sounds\*.uax` - Sound files

---

## Progress Allocation (Phase 5)

- 75% - Start copying
- 80% - "All_*" folders copied
- 85% - English folders merged
- 90% - All files copied
- 95% - Verification complete
- 100% - Installation complete

---

## AutoIt Implementation Notes

### Simple Copy (All_* folders):
```autoit
DirCopy($sSourceFolder, $sDestFolder, 1)  ; 1 = overwrite
```

### Merge Copy (System folder):
```autoit
; Copy All_UT2004.EXE\* → System\
DirCopy($sExtractDir & "\All_UT2004.EXE", $sInstallDir & "\System", 1)

; Copy English_...\System\* → System\ (merge)
FileCopy($sExtractDir & "\English_Sounds_Speech_System_Help\System\*.*", $sInstallDir & "\System\", 1)
```

### Handle Subfolders:
```autoit
; Copy System\editorres subfolder
DirCopy($sSource & "\System\editorres", $sTarget & "\System\editorres", 1)
```

---

## What Gets Skipped

Total folders: 33
Copying: ~15 folders
Skipping: ~18 folders (DirectX, Support, Engine placeholders)

This keeps the installation clean and efficient!

---

## Next Session TODO

1. Implement Phase 5 copy logic
2. Add progress tracking (75% → 90%)
3. Verify critical files exist
4. Handle OldUnreal patch (Phase 5b)
5. Create shortcuts
6. Write registry
7. Complete!
