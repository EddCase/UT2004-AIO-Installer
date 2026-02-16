# TrayTip Strategy - Clean and Non-Spammy

## ✅ Fixed! Only 2 TrayTips Total

### Current TrayTip Usage (Phase 2 Only):

1. **"Downloading UT2004 (~2.8 GB) - This may take a while..."**
   - **When**: Starting ISO download
   - **Why**: User might walk away during long download
   - **Duration**: 10 seconds

2. **"Download complete! Installing..."**
   - **When**: ISO download finishes
   - **Why**: Signals transition to next phase
   - **Duration**: 3 seconds

### Future TrayTips (Phases 3-5):

When we add more phases, we'll ONLY add TrayTips for:

**Phase 3: ISO Extraction**
- Maybe: "Extracting game files..." (if it takes >30 seconds)

**Phase 4: CAB Extraction**  
- Maybe: "Installing game files..." (if it takes >1 minute)

**Phase 5: Patching**
- "Downloading patch..." (if patch is large)
- "Applying patch..."

**Final**
- "Installation complete!" (success milestone)

### What Uses GUI Updates Instead:

**Frequent updates** (progress bar + label only, NO TrayTip):
- "Downloading: 500 MB / 2800 MB (18%)"
- "Extracting: Disk1..."
- "Extracting: Disk2..."
- "Copying game files..."
- "Creating shortcuts..."
- "Writing registry..."

### Rules:

✅ **DO show TrayTip when**:
- Starting a phase that takes >30 seconds
- User might walk away
- Major milestone reached

❌ **DON'T show TrayTip for**:
- Progress updates
- Quick operations (<10 seconds)
- Status changes within a phase
- Anything that updates more than once per minute

### Result:

**Clean, professional experience!**
- User sees TrayTips only when they matter
- Progress bar + label show real-time progress
- No notification spam
- User can walk away during long operations

---

## Current Implementation:

```autoit
UpdateStatus($sMessage)  // Updates GUI label + logs, NO TrayTip
TrayTip(...)            // Add manually only at major milestones
```

This separation gives us full control over when TrayTips appear! 🎯
