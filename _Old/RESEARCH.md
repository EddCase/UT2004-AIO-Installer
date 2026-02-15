# UT2004 Installer - Research Documentation

## Project Overview
Creating an AutoIt-based installer for Unreal Tournament 2004 that:
1. Installs the base game using OldUnreal's installer
2. Provides options to install official bonus packs
3. Provides options to install community bonus packs
4. Features a modern dark-themed UI

---

## Base Game Installation

### OldUnreal Installer
- **URL**: https://github.com/OldUnreal/FullGameInstallers/releases/download/windows-game-installers/UT2004.exe
- **Size**: ~84 MB (downloads full game from Archive.org)
- **Installation Method**: Silent install with command line parameters
- **Command**: `UT2004.exe /S /D="C:\Path\To\Install"`
- **Notes**: 
  - The `/S` flag enables silent installation
  - The `/D` parameter MUST be the last parameter
  - Downloads UT2004 ECE from Archive.org and applies latest OldUnreal patch automatically
  - No quotes needed around the install path unless it contains spaces

---

## Official Bonus Content

### 1. ECE Bonus Pack v1.1 (Editor's Choice Edition)
**Overview**: The original official bonus pack from Epic Games

**Content**:
- 6 new characters: Mekkor, Skrilax, Barktooth, Karag, Kragoth, Thannis
- 3 new vehicles: SPMA (mobile artillery), Paladin (tank), Cicada (helicopter)
- 4 new Onslaught maps:
  - ONS-Adara
  - ONS-IslandHop
  - ONS-Tricky
  - ONS-Urban
- Bonus vehicle versions of stock ONS maps

**Download Sources**:
- GameFront: https://www.gamefront.com/games/unreal-tournament-2004/file/unreal-tournament-2004-ece-bonus-pack-v1-1
- ModDB: https://www.moddb.com/games/unreal-tournament-2004/downloads/ut2004-ecebonuspack1
- File: `ut2004-ecebonuspack1-1.exe` (84.43 MB)
- MD5: 759bf2d14ebad4f79e9c65e0ef8630d5

**Installation Notes**:
- Self-extracting EXE that installs directly to UT2004 folder
- Must be installed BEFORE patch 3369 (though OldUnreal installer handles this)
- Can extract files with 7-Zip or WinZip if needed

---

### 2. Mega Pack (Official Compilation)
**Overview**: Contains ECE Bonus Pack + additional community maps + patch 3369

**Content**:
- All ECE Bonus Pack content (6 characters, 3 vehicles, 4 maps)
- Patch 3369
- 9 additional maps:
  - AS-BP2-Acatana (Assault)
  - AS-BP2-Jumpship (Assault)
  - AS-BP2-Outback (Assault)
  - AS-BP2-Subrosa (Assault)
  - AS-BP2-Thrust (Assault)
  - CTF-BP2-Concentrate (Capture the Flag)
  - CTF-BP2-Pistola (Capture the Flag)
  - DM-BP2-Calandras (Deathmatch)
  - DM-BP2-GoopGod (Deathmatch)

**Download Sources**:
- PCGamingWiki Community: https://community.pcgamingwiki.com/files/file/166-unreal-tournament-2004-mega-pack-windows/
- Original FilePlanet (may be offline): http://www.fileplanet.com/145962/140000/fileinfo/UT2004-Mega-Bonus-Pack

**Installation Notes**:
- Since OldUnreal installer already includes the latest patch, we mainly need this for the 9 additional maps
- The ECE content is redundant if ECE Bonus Pack is already installed
- These 9 maps are also included in Community Bonus Pack 2

---

### 3. XP Bonus Maps (Two Maps Pack)
**Overview**: Two additional Onslaught maps

**Content**:
- ONS-Ascendancy
- ONS-Aridoom

**Download Sources**:
- Need to find reliable source (check unrealarchive.org)

---

## Community Bonus Packs

### 1. Community Bonus Pack 1 (CBP1)
**Overview**: First community-created bonus pack, originally for UT2003, converted for UT2004

**Content**:
- 19-21 maps (varies by source):
  - BR-CBP1-Breaklimit2004 (Bombing Run)
  - CTF-CBP1-Betrayal
  - CTF-CBP1-Concentrate
  - CTF-CBP1-Ferris
  - CTF-CBP1-TechDream
  - DM-CBP1-Arkanos
  - DM-CBP1-AugustNoon
  - DM-CBP1-Curse3
  - DM-CBP1-Cybrosis
  - DM-CBP1-Desolation
  - DM-CBP1-EdenInc
  - DM-CBP1-IronDeity
  - DM-CBP1-Labrynth
  - DM-CBP1-Lea
  - DM-CBP1-Neandertalus (bonus map)
  - DM-CBP1-OceanRelic
  - DM-CBP1-Serpentine
  - DM-CBP1-Sorayama
  - DM-CBP1-SpiralNexus
- 4 new characters
- 1 mutator

**Download Sources**:
- Unreal Archive (ZIP version): https://unrealarchive.org/unreal-tournament-2004/mappacks/mixed/C/cbp-community-bonus-pack-1_1881706f.html
  - File: `CBP1.zip` (137.5 MB)
  - SHA1: 1881706fdd31a954c3df1bf63063042c78c09a7e
- Unreal Archive (UMOD version): https://unrealarchive.org/unreal-tournament-2004/mappacks/mixed/C/cbp-community-bonus-pack-1-umod_bd604926.html
  - File: `cbp1-umod.zip` (137.5 MB)
  - SHA1: bd604926e7c5b20384a4753d70b492df8614c205
- ModDB: https://www.moddb.com/games/unreal-tournament-2004/downloads/community-bonus-pack-1
- PCGamingWiki (Re-release): https://community.pcgamingwiki.com/files/file/174-unreal-tournament-2004-community-bonus-pack-1-re-release/

**Installation Method**:
- ZIP version: Extract and copy folders to UT2004 installation
- UMOD version: Use UMOD installer or extract manually

---

### 2. Community Bonus Pack 2 - Volume 1 (CBP2v1)
**Overview**: First volume of the second community bonus pack

**Content**:
- 21 maps:
  - AS-Thrust (Assault)
  - BR-Aquarius (Bombing Run)
  - CTF-Decadence
  - CTF-Deep
  - CTF-Gazpacho
  - CTF-IronWorks
  - CTF-LavaGiant2
  - CTF-LifeOrDeath
  - CTF-Stygian
  - DM-Antalus2
  - DM-Azura
  - DM-Blackheart
  - DM-Buller
  - DM-Chromium
  - DM-Curse4
  - DM-Miasma
  - DM-ObenReinhardt
  - DM-Outrage
  - DM-PalaceUnderhill
  - DM-RadialEvil
  - DM-Singularity
- 17 misc files (mutators, textures, etc.)

**Download Sources**:
- Unreal Archive: https://unrealarchive.org/unreal-tournament-2004/mappacks/mixed/C/cbp2-community-bonus-pack-2-volume-1_719095f0.html
  - File: `cbp2_volume1.zip` (194.3 MB)
  - SHA1: 719095f073de635638696f71dbd9597e6ba903a5
- ModDB: https://www.moddb.com/games/unreal-tournament-2004/downloads/community-bonus-pack-2-vol1

---

### 3. Community Bonus Pack 2 - Volume 2 (CBP2v2)
**Overview**: Second volume of the second community bonus pack

**Content**:
- 20 maps:
  - BR-Bahera (Bombing Run)
  - CTF-Bahera
  - CTF-Botanic
  - CTF-Pistola
  - DM-Buliwyf
  - DM-Drakonis
  - DM-Kerosene
  - DM-Krakatoa
  - DM-Luciferium
  - DM-Metallurgy
  - DM-Nadja
  - DM-Necronus
  - DM-Osiris2
  - DM-Pantophobia
  - DM-SearingFlame
  - DM-Shai
  - DM-SingularityShock
  - DM-Slaughterhouse
  - DM-Torment
  - DM-Zenith
- 4 new skins
- 2 new mutators
- 20 misc files

**Download Sources**:
- Unreal Archive: https://unrealarchive.org/unreal-tournament-2004/mappacks/mixed/C/cbp2-community-bonus-pack-2-volume-2_dc6a08b5.html
  - File: `cbp2_volume2.zip` (191.2 MB)
  - SHA1: dc6a08b5f2022590c2b0f86cc01535e7a2b6ff9d
- ModDB: https://www.moddb.com/games/unreal-tournament-2004/downloads/community-bonus-pack-2-vol2

---

## UT2004 Directory Structure

Understanding where files go is crucial for proper installation:

```
UT2004/
├── Animations/         - Character animations (.ukx files)
├── ForceFeedback/      - Force feedback files
├── Help/               - Help files and documentation
├── KarmaData/          - Physics data files (.ka files)
├── Maps/               - Map files (.ut2 files) ***IMPORTANT***
├── Music/              - Music files (.ogg files)
├── Prefabs/            - UnrealEd prefabs
├── Saves/              - Save games
├── Screenshots/        - Screenshots
├── Sounds/             - Sound files (.uax files)
├── Speech/             - Voice/speech files
├── StaticMeshes/       - Static mesh files (.usx files)
├── System/             - Game executables, DLLs, .u, .int, .ini files ***IMPORTANT***
├── Textures/           - Texture files (.utx files)
└── Web/                - Web admin files
```

### Key File Extensions:
- `.ut2` - Map files (go in Maps/)
- `.u` - UnrealScript compiled packages (go in System/)
- `.ukx` - Animation packages (go in Animations/)
- `.uax` - Audio packages (go in Sounds/ or Music/)
- `.utx` - Texture packages (go in Textures/)
- `.usx` - Static mesh packages (go in StaticMeshes/)
- `.ka` - Karma physics data (go in KarmaData/)
- `.int` - Localization files (go in System/)
- `.ini` - Configuration files (go in System/)
- `.ucl` - Cache files (go in System/)

---

## File Format Analysis

### ZIP Archives
Most bonus packs come as ZIP files with the following structure:
```
CBP1.zip/
├── Animations/
│   └── [.ukx files]
├── Maps/
│   └── [.ut2 files]
├── Sounds/
│   └── [.uax files]
├── StaticMeshes/
│   └── [.usx files]
├── System/
│   └── [.u, .int, .ucl files]
└── Textures/
    └── [.utx files]
```

### UMOD Files
Some packs use the old Unreal Module (.umod) format:
- These are self-extracting installers for Unreal Engine games
- Can be extracted with UMOD Wizard or 7-Zip
- Modern approach: Extract with 7-Zip and copy files manually

---

## Installation Order Recommendations

Based on research, the recommended installation order is:

1. **Base Game** (via OldUnreal installer)
   - Includes latest patch
   - Includes base game files

2. **ECE Bonus Pack v1.1** (if not using Mega Pack)
   - Core official content
   - Vehicles and characters

3. **Mega Pack** (alternative to ECE if preferred)
   - Includes ECE content
   - Adds 9 additional maps
   - Note: Some overlap with CBP2

4. **Community Bonus Pack 1**
   - 19-21 community maps
   - No conflicts with official content

5. **Community Bonus Pack 2 - Volume 1**
   - 21 additional community maps

6. **Community Bonus Pack 2 - Volume 2**
   - 20 additional community maps

### Important Notes:
- The OldUnreal installer already applies the latest patch, so we don't need to worry about patch order
- ECE Bonus Pack and Mega Pack have overlapping content - choose one or the other
- CBP2 volumes have some maps that overlap with Mega Pack (the 9 "BP2" maps)
- Total installation size: ~10-12 GB with all content

---

## Download Mirror Strategy

For reliability, we should implement multiple mirror support:

### Primary Mirrors:
1. **Unreal Archive** - Most reliable, has SHA1 hashes for verification
   - US Mirror: Available
   - EU Mirror: Available
   - Singapore Mirror: Available

2. **ModDB** - Good fallback

3. **PCGamingWiki Community** - For some specific packs

4. **GameFront** - Historical downloads (may be slow)

### Download Strategy:
1. Try primary mirror
2. If fails, try secondary mirror
3. Verify file integrity using SHA1 hash (if available)
4. Resume support for large files (INet library in AutoIt)

---

## Next Steps for Development

### Phase 1: Core Installer
- [ ] Create basic AutoIt GUI with dark theme
- [ ] Implement OldUnreal installer execution with `/S /D=` parameters
- [ ] Add installation directory picker
- [ ] Add progress indication for base install
- [ ] Test silent installation process

### Phase 2: Download System
- [ ] Implement HTTP download functionality (INet UDF)
- [ ] Add download progress bars
- [ ] Implement hash verification (SHA1)
- [ ] Add mirror fallback system
- [ ] Test with actual bonus pack downloads

### Phase 3: File Extraction & Installation
- [ ] Implement ZIP extraction (7-Zip command line or AutoIt ZIP functions)
- [ ] Create file copying routines
- [ ] Verify target directories exist
- [ ] Handle file conflicts/overwrites
- [ ] Test with each bonus pack

### Phase 4: GUI Enhancement
- [ ] Design complete UI mockup
- [ ] Implement checkboxes for each pack
- [ ] Add descriptions for each pack
- [ ] Implement installation size calculations
- [ ] Add "Select All" / "Deselect All" options

### Phase 5: Polish & Testing
- [ ] Add error handling
- [ ] Implement logging
- [ ] Create uninstaller or restore point
- [ ] Test on clean Windows installation
- [ ] Create installer package

---

## Technical Considerations

### AutoIt Libraries Needed:
- **INet.au3** - For HTTP downloads with progress
- **7Zip UDF** or **Zip.au3** - For archive extraction
- **GUIConstants** - For UI creation
- **String functions** - For path manipulation
- **File functions** - For file operations

### Error Handling Scenarios:
- Download failures (network issues)
- Insufficient disk space
- Permission errors (UAC on Windows)
- Corrupted downloads (hash mismatch)
- Missing base game installation
- File conflicts

### Performance Considerations:
- Large file downloads (200+ MB files)
- Multiple simultaneous downloads?
- Extract while downloading next file?
- Temp file cleanup

---

## File Size Summary

| Component | Size | Notes |
|-----------|------|-------|
| OldUnreal Installer | ~84 MB | Downloads full game (~5.5 GB) |
| ECE Bonus Pack | 84.43 MB | Or included in Mega Pack |
| Mega Pack | TBD | Includes ECE + 9 maps + patch |
| CBP1 | 137.5 MB | 19-21 maps + content |
| CBP2 Volume 1 | 194.3 MB | 21 maps + content |
| CBP2 Volume 2 | 191.2 MB | 20 maps + content |
| **Total Downloads** | ~690 MB | (excluding base game) |
| **Total Installed** | ~10-12 GB | (including base game) |

---

## Useful Resources

### Documentation:
- OldUnreal GitHub: https://github.com/OldUnreal/UT2004Patches
- Unreal Archive: https://unrealarchive.org/unreal-tournament-2004/
- PCGamingWiki: https://www.pcgamingwiki.com/wiki/Unreal_Tournament_2004
- UT2004 Admin Wiki: https://wiki.unrealadmin.org/UT2004

### Download Hashes (for verification):
- CBP1.zip: SHA1 = 1881706fdd31a954c3df1bf63063042c78c09a7e
- cbp2_volume1.zip: SHA1 = 719095f073de635638696f71dbd9597e6ba903a5
- cbp2_volume2.zip: SHA1 = dc6a08b5f2022590c2b0f86cc01535e7a2b6ff9d
- ECE Bonus Pack: MD5 = 759bf2d14ebad4f79e9c65e0ef8630d5

---

## Questions for User:

1. **Mega Pack vs ECE**: Should we offer both options or just recommend one?
   - Mega Pack = ECE content + 9 additional maps
   - ECE = Just the vehicle pack content
   
2. **Download location**: Where should we store temp files?
   - System temp folder?
   - Installer directory?
   - User choice?

3. **File verification**: Should we always verify SHA1 hashes?
   - Slower but safer
   - Optional verification?

4. **Installation options**:
   - "Recommended" preset (all official + CBP1)?
   - "Full" preset (everything)?
   - "Minimal" preset (base game only)?
   - Custom selection?

5. **Cleanup**: Delete downloaded archives after installation?
   - Save disk space
   - Allow reinstall without re-download?

---

End of Research Document - Ready for Development Phase
