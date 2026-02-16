# Official UT2004 Bonus Content - Research Summary

## Key Findings:

### The MegaPack IS Official Content from Epic Games
- Released December 2, 2005
- Official "thank you" pack from Epic
- NOT a community-made pack

---

## What the MegaPack Contains:

### 1. **All ECE (Editor's Choice Edition) Content**
- 6 Characters: Mekkor, Skrilax, Barktooth, Karag, Kragoth, Thannis
- 3 Vehicles: SPMA, Paladin, Cicada
- 4 ONS Maps: ONS-Adara, ONS-IslandHop, ONS-Tricky, ONS-Urban

### 2. **Patch v3369** (Latest official patch)

### 3. **9 New Maps** (Make Something Unreal Contest winners)
- **Assault (5 maps):**
  - AS-BP2-Acatana
  - AS-BP2-Jumpship
  - AS-BP2-Outback
  - AS-BP2-Subrosa
  - AS-BP2-Thrust

- **CTF (2 maps):**
  - CTF-BP2-Concentrate
  - CTF-BP2-Pistola

- **Deathmatch (2 maps):**
  - DM-BP2-Calandras
  - DM-BP2-GoopGod

**File Size:** ~200 MB  
**Original Source:** Fileplanet (now offline)

---

## Available Downloads:

### Option 1: PCGamingWiki (Recommended)
**URL:** https://community.pcgamingwiki.com/files/file/166-unreal-tournament-2004-mega-pack-windows/
- **Size:** 198.9 MB
- **Format:** Self-extracting EXE (can be extracted with 7-Zip)
- **Status:** Active mirror, 6,201 downloads
- **Verified:** Community-maintained

### Option 2: Unreal Archive
The Unreal Archive has Community Bonus Packs (CBP1, CBP2) as ZIP files:
- **CBP1:** 137.5 MB (19 maps) - Community made, Epic endorsed
- **CBP2 Volume 1:** 194.3 MB (21 maps) - Community made
- **CBP2 Volume 2:** 191.2 MB (20 maps) - Community made

These are **separate** from the MegaPack.

---

## Installation Challenge:

### The Problem:
The MegaPack is distributed as a **self-extracting EXE installer**.

### Why This is Tricky:
1. We'd need to run the EXE installer
2. Hard to automate/integrate into our installer
3. Unknown if it can be extracted cleanly

### Possible Solutions:

#### Option A: Extract with 7-Zip
- Most self-extracting ZIPs can be opened with 7-Zip
- Extract contents directly
- Copy files to game directory manually

#### Option B: Download Pre-Extracted
- Look for pre-extracted ZIP version
- Community might have repackaged it

#### Option C: Run the EXE Silently
- Find silent install parameters
- Run: `MegaPack.exe /S` or similar
- Requires testing

---

## Recommendation:

### For v1.0:

**Install the MegaPack (ECE + 9 maps)**
1. Download from PCGamingWiki
2. Extract with 7-Zip (try: `7z x MegaPack.exe`)
3. Copy extracted files to game directory
4. Skip running the patch (we already apply OldUnreal patch)

### For v1.1+ (Optional Content):

Add checkboxes for Community Bonus Packs:
- [ ] Community Bonus Pack 1 (CBP1) - 137 MB
- [ ] Community Bonus Pack 2 Volume 1 - 194 MB  
- [ ] Community Bonus Pack 2 Volume 2 - 191 MB

These are easier to handle (ZIP files from Unreal Archive).

---

## Next Steps:

1. **Download the MegaPack EXE from PCGamingWiki**
2. **Test extraction with 7-Zip:**
   ```
   7z x UT2004-Mega-Bonus-Pack.exe
   ```
3. **Examine the extracted structure**
4. **Determine what files go where**
5. **Add to installer as Phase 6 (optional)**

---

## File Structure to Research:

Once extracted, we need to find:
- What goes in `/System/` (characters, vehicles)
- What goes in `/Maps/` (the new maps)
- What goes in `/Textures/`, `/Sounds/`, `/StaticMeshes/`, etc.
- Any INI files or configuration

---

## URLs for Future Reference:

- PCGamingWiki Download: https://community.pcgamingwiki.com/files/file/166-unreal-tournament-2004-mega-pack-windows/
- Unreal Archive CBP1: https://unrealarchive.org/unreal-tournament-2004/mappacks/mixed/C/cbp-community-bonus-pack-1_1881706f.html
- Unreal Archive CBP2 Vol 1: https://unrealarchive.org/unreal-tournament-2004/mappacks/mixed/C/cbp2-community-bonus-pack-2-volume-1_719095f0.html
- Unreal Archive CBP2 Vol 2: https://unrealarchive.org/unreal-tournament-2004/mappacks/mixed/C/cbp2-community-bonus-pack-2-volume-2_dc6a08b5.html
