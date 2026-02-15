# UT2004 Bonus Pack File Structure Mapping

## Purpose
This document maps the file structure of each bonus pack to understand exactly where files need to be copied during installation.

---

## General UT2004 Installation Structure

```
<InstallDir>\UT2004\
│
├── Animations\          *.ukx (animation packages)
├── ForceFeedback\       *.ffc (force feedback)
├── Help\                *.bmp, *.htm (help files)
├── KarmaData\           *.ka (physics data)
├── Maps\                *.ut2 (map files) - PRIMARY CONTENT
├── Music\               *.ogg (music)
├── Prefabs\             *.pfb (UnrealEd prefabs)
├── Sounds\              *.uax (sound packages)
├── Speech\              *.uax (speech/voice)
├── StaticMeshes\        *.usx (static meshes)
├── System\              *.u, *.ucl, *.int, *.ini, *.dll, *.exe
├── Textures\            *.utx (textures)
└── Web\                 *.htm, *.css, *.js (webadmin)
```

---

## ECE Bonus Pack v1.1 File Structure

**Archive**: ut2004-ecebonuspack1-1.exe (self-extracting)

### Expected Files:

#### System\ folder:
```
OnslaughtBP.u           - Bonus Pack game code
OnslaughtBP.int         - Localization file
OnslaughtFull.u         - Full Onslaught code
OnslaughtFull.int       - Localization
UT2004-BonusPack.int    - Bonus Pack localization
xVehicles.u             - Vehicle code
xVehicles.int           - Vehicle localization
```

#### Maps\ folder:
```
ONS-Adara.ut2           - Onslaught map
ONS-IslandHop.ut2       - Onslaught map
ONS-Tricky.ut2          - Onslaught map
ONS-Urban.ut2           - Onslaught map

Bonus vehicle versions of existing maps:
ONS-Arcticstronghold_BP.ut2
ONS-Crossfire_BP.ut2
ONS-Dria_BP.ut2
ONS-FrostBite_BP.ut2
ONS-Primeval_BP.ut2
ONS-RedPlanet_BP.ut2
ONS-Severance_BP.ut2
ONS-Torlan_BP.ut2
(etc. - all stock ONS maps get _BP versions)
```

#### Animations\ folder:
```
ONSBPAnimations.ukx     - Bonus Pack animations
```

#### StaticMeshes\ folder:
```
ONS-BPJW1.usx          - Static meshes
PC_StaticMeshes.usx     - More static meshes
```

#### Textures\ folder:
```
AW-2k4XP.utx           - Textures
BonusParticles.utx     - Particle textures
EpicParticles.utx      - Epic particle textures
ONSBPTextures.utx      - Bonus Pack textures
```

#### Sounds\ folder:
```
ONSBPSounds.uax        - Bonus Pack sounds
```

---

## Community Bonus Pack 1 (CBP1) File Structure

**Archive**: CBP1.zip

Based on the package contents (19 maps + characters + mutator):

### Expected Files:

#### Maps\ folder (19 maps):
```
BR-CBP1-Breaklimit2004.ut2
CTF-CBP1-Betrayal.ut2
CTF-CBP1-Concentrate.ut2
CTF-CBP1-Ferris.ut2
CTF-CBP1-TechDream.ut2
DM-CBP1-Arkanos.ut2
DM-CBP1-AugustNoon.ut2
DM-CBP1-Curse3.ut2
DM-CBP1-Cybrosis.ut2
DM-CBP1-Desolation.ut2
DM-CBP1-EdenInc.ut2
DM-CBP1-IronDeity.ut2
DM-CBP1-Labrynth.ut2
DM-CBP1-Lea.ut2
DM-CBP1-Neandertalus.ut2
DM-CBP1-OceanRelic.ut2
DM-CBP1-Serpentine.ut2
DM-CBP1-Sorayama.ut2
DM-CBP1-SpiralNexus.ut2
```

#### System\ folder:
```
CBP1Mut.u              - CBP1 mutator code
CBP1Mut.int            - Localization
*.ucl files            - Cache files (auto-generated)
```

#### Animations\ folder:
```
(Character animation packages)
*.ukx files for new characters
```

#### Textures\ folder:
```
(Texture packages for maps and characters)
*.utx files
```

#### StaticMeshes\ folder:
```
(Static mesh packages for maps)
*.usx files
```

#### Sounds\ folder:
```
(Sound packages)
*.uax files
```

**Note**: The exact file list will be visible once we extract the archive. The structure should mirror the base directory structure.

---

## Community Bonus Pack 2 - Volume 1 File Structure

**Archive**: cbp2_volume1.zip (194.3 MB)

### Expected Contents:
- 21 maps (AS, BR, CTF, DM game types)
- 17 misc files (textures, sounds, static meshes, etc.)

#### Maps\ folder (21 maps):
```
AS-Thrust.ut2
BR-Aquarius.ut2
CTF-Decadence.ut2
CTF-Deep.ut2
CTF-Gazpacho.ut2
CTF-IronWorks.ut2
CTF-LavaGiant2.ut2
CTF-LifeOrDeath.ut2
CTF-Stygian.ut2
DM-Antalus2.ut2
DM-Azura.ut2
DM-Blackheart.ut2
DM-Buller.ut2
DM-Chromium.ut2
DM-Curse4.ut2
DM-Miasma.ut2
DM-ObenReinhardt.ut2
DM-Outrage.ut2
DM-PalaceUnderhill.ut2
DM-RadialEvil.ut2
DM-Singularity.ut2
```

#### Supporting files across folders:
```
System\        - *.u, *.int, *.ucl
Textures\      - *.utx
StaticMeshes\  - *.usx
Sounds\        - *.uax
Animations\    - *.ukx
```

---

## Community Bonus Pack 2 - Volume 2 File Structure

**Archive**: cbp2_volume2.zip (191.2 MB)

### Expected Contents:
- 20 maps
- 4 skins
- 2 mutators
- 20 misc files

#### Maps\ folder (20 maps):
```
BR-Bahera.ut2
CTF-Bahera.ut2
CTF-Botanic.ut2
CTF-Pistola.ut2
DM-Buliwyf.ut2
DM-Drakonis.ut2
DM-Kerosene.ut2
DM-Krakatoa.ut2
DM-Luciferium.ut2
DM-Metallurgy.ut2
DM-Nadja.ut2
DM-Necronus.ut2
DM-Osiris2.ut2
DM-Pantophobia.ut2
DM-SearingFlame.ut2
DM-Shai.ut2
DM-SingularityShock.ut2
DM-Slaughterhouse.ut2
DM-Torment.ut2
DM-Zenith.ut2
```

#### System\ folder (mutators):
```
*.u   - Mutator code files (2 mutators)
*.int - Localization files
```

#### Textures\ folder (skins):
```
*.utx - Skin texture packages (4 skins)
```

#### Supporting files:
```
StaticMeshes\  - *.usx
Sounds\        - *.uax
Animations\    - *.ukx
```

---

## Mega Pack File Structure

**Archive**: TBD

The Mega Pack is essentially:
- ECE Bonus Pack v1.1 (all files from above)
- Patch 3369 files (system updates)
- 9 additional maps

### Additional Maps (beyond ECE):
```
Maps\AS-BP2-Acatana.ut2
Maps\AS-BP2-Jumpship.ut2
Maps\AS-BP2-Outback.ut2
Maps\AS-BP2-Subrosa.ut2
Maps\AS-BP2-Thrust.ut2
Maps\CTF-BP2-Concentrate.ut2
Maps\CTF-BP2-Pistola.ut2
Maps\DM-BP2-Calandras.ut2
Maps\DM-BP2-GoopGod.ut2
```

**Note**: These "BP2" prefixed maps are the same as some maps in Community Bonus Pack 2, just with different file names. Handle potential duplicates.

---

## Installation Logic

### For each bonus pack:

```
1. Download archive to temp location
2. Verify hash (if available)
3. Extract archive to temp folder
4. For each subfolder in archive:
   a. Identify target folder in UT2004 install
   b. Check if target folder exists, create if not
   c. Copy files from temp to target
   d. Handle overwrites (prompt user or skip)
5. Clean up temp files (optional)
6. Update installation registry/log
```

### Pseudo-code for file copying:

```autoit
Func InstallBonusPack($archivePath, $installDir)
    Local $tempExtractPath = @TempDir & "\UT2004_Install_Temp"
    
    ; Extract archive
    ExtractArchive($archivePath, $tempExtractPath)
    
    ; Define folder mappings
    Local $folders[] = ["Animations", "Maps", "Sounds", "StaticMeshes", _
                        "System", "Textures", "KarmaData", "Music"]
    
    ; Copy each folder
    For $folder In $folders
        Local $sourcePath = $tempExtractPath & "\" & $folder
        Local $targetPath = $installDir & "\" & $folder
        
        If FileExists($sourcePath) Then
            ; Create target if not exists
            If Not FileExists($targetPath) Then
                DirCreate($targetPath)
            EndIf
            
            ; Copy all files
            FileCopy($sourcePath & "\*.*", $targetPath, 1) ; 1 = overwrite
        EndIf
    Next
    
    ; Cleanup
    DirRemove($tempExtractPath, 1)
EndFunc
```

---

## File Conflict Handling

### Potential Conflicts:

1. **ECE vs Mega Pack**:
   - Both have the same core files
   - Mega Pack supersedes ECE (includes everything from ECE)
   - **Solution**: Only allow one to be selected

2. **Mega Pack BP2 maps vs CBP2**:
   - Some maps have same content but different file names
   - Example: `AS-BP2-Thrust.ut2` (Mega Pack) vs `AS-Thrust.ut2` (CBP2v1)
   - **Solution**: Allow both, they're technically different files

3. **System files (.u, .int)**:
   - Multiple packs may update same system files
   - Later packs may depend on earlier ones
   - **Solution**: Install in recommended order, allow overwrites

### Overwrite Strategy:
- **Maps folder**: Always allow (maps rarely conflict)
- **System folder**: Overwrite with newer (or prompt user)
- **Textures/Sounds/etc**: Overwrite with newer
- **Log all overwrites** for troubleshooting

---

## Testing Checklist

### For Each Bonus Pack:
- [ ] Download completes successfully
- [ ] Hash verification passes (if available)
- [ ] Archive extracts without errors
- [ ] All expected folders are present
- [ ] File count matches expectations
- [ ] Files copy to correct locations
- [ ] No permission errors
- [ ] Game launches successfully after install
- [ ] Maps appear in game menus
- [ ] Vehicles/characters are selectable (ECE)
- [ ] No broken textures or missing files

---

## Additional Notes

### Archive Format Considerations:
- **ZIP files**: Standard, easy to extract with AutoIt or 7-Zip
- **EXE self-extractors**: May need to extract with 7-Zip command line
- **UMOD files**: Old format, extract with 7-Zip or UMOD Wizard

### 7-Zip Command Line Examples:
```batch
; Extract to specific folder
7z.exe x "archive.zip" -o"C:\Temp\Extract" -y

; Extract self-extracting EXE
7z.exe x "ut2004-ecebonuspack1-1.exe" -o"C:\Temp\ECE" -y

; List contents without extracting
7z.exe l "archive.zip"
```

### AutoIt ZIP Functions:
```autoit
; Using built-in AutoIt ZIP functions
#include <Zip.au3>
_Zip_Unzip($archivePath, $extractPath)

; Or shell method
ShellExecute("7z.exe", "x " & $archivePath & " -o" & $extractPath & " -y")
```

---

End of File Structure Mapping Document
