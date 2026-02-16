# Phase 3: ISO Extraction - Complete! ✅

## What Phase 3 Does:

Extracts CAB files from the downloaded UT2004.ISO using 7-Zip.

### Process Flow:

```
1. Verify ISO exists (from Phase 2)
2. Clean/create CAB output directory
3. Run 7za.exe to extract only *.cab files
4. Flatten directory structure (no Disk1-5 folders)
5. Verify CABs extracted successfully
6. Log all CAB filenames
```

### Technical Details:

**7-Zip Command**:
```
7za.exe e "UT2004.ISO" -o"_Temp_CABs" *.cab -r -y
```

**Command Breakdown**:
- `e` = Extract without paths (flatten)
- `"UT2004.ISO"` = Source file
- `-o"_Temp_CABs"` = Output directory (no space after -o!)
- `*.cab` = Only CAB files
- `-r` = Recursive search
- `-y` = Yes to all prompts (non-interactive)

**Result**:
```
_Temp_CABs/
├── data1.cab
├── data2.cab
├── data3.cab
├── data4.cab
└── data5.cab
```

No Disk1/, Disk2/ folders - all CABs in one flat directory!

### Progress Bar:

- **50%**: Start of extraction
- **60%**: Extraction complete

(10% allocated for ISO extraction)

### Error Handling:

✅ **Checks for**:
- ISO file exists
- 7za.exe starts successfully
- 7za.exe exits with code 0 (success)
- At least one CAB file extracted

✅ **Logs**:
- Full 7za command executed
- Number of CABs found
- Each CAB filename

### What User Sees:

**Status Label**:
- "Extracting CAB files from ISO..."
- "Extracting CAB files (this may take a minute)..."
- "Extracted 5 CAB files"

**Progress Bar**:
- Jumps from 50% → 60%

**TrayTip**:
- None (extraction is relatively quick, ~1-2 minutes)

### What Gets Logged:

```
[10:30:00] Starting ISO extraction
[10:30:00] Created CAB output directory: C:\Users\...\Temp\UT2004_Install\_Temp_CABs
[10:30:00] Executing: "...\7za.exe" e "...\UT2004.ISO" -o"...\Temp_CABs" *.cab -r -y
[10:31:30] Successfully extracted 5 CAB files
[10:31:30]   - data1.cab
[10:31:30]   - data2.cab
[10:31:30]   - data3.cab
[10:31:30]   - data4.cab
[10:31:30]   - data5.cab
```

### Why Flatten?

**Benefits**:
- Works with both OldUnreal ISO (Disk1-5) and Archive.org ISO (CD1-7)
- Simpler to process in Phase 4
- No need to search subdirectories
- Clean, predictable structure

### Testing:

To test Phase 3:
1. Run installer
2. Accept TOS
3. Let it download ISO (or skip if cached)
4. Watch extraction happen
5. Check `%TEMP%\UT2004_Install\_Temp_CABs\` for CABs
6. Check install.log for details

---

## Next: Phase 4

Extract game files from CABs using unshield.exe!

Progress: 60% → 90%
