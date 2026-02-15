# UT2004 Installer - Changelog

---

## 📌 CURRENT VERSION: v0.1.1-alpha
**Status**: Testing ShellExecuteWait fix  
**Date**: February 14, 2026  
**Next**: Add Mega Pack support (v0.2.0-alpha)

---

## Version History

### v0.1.1-alpha - ShellExecuteWait Fix
**Date**: February 14, 2026  
**Status**: ⚠️ TESTING REQUIRED

#### Fixed:
- Replaced `Run()` + `ProcessWaitClose()` with `ShellExecuteWait()`
- Better handling of installation paths with spaces
- Cleaner parameter separation
- Proper return code checking

#### Changed:
- `RunOldUnrealInstaller()` function now uses ShellExecuteWait for better reliability

#### Technical Details:
**Old code:**
```autoit
Local $iPID = Run($g_sInstallerPath & ' ' & $sCommandLine, $g_sTempDir)
If $iPID = 0 Then
    Return False
EndIf
ProcessWaitClose($iPID)
```

**New code:**
```autoit
Local $sParameters = '/S /D=' & $g_sInstallDir
Local $iReturnCode = ShellExecuteWait($g_sInstallerPath, $sParameters, $g_sTempDir, "", @SW_HIDE)
If $iReturnCode = -1 Then
    UpdateStatus("Error: Failed to execute installer")
    Return False
EndIf
```

---

### v0.1.0-alpha - Initial Release
**Date**: February 14, 2026  
**Status**: ✅ SUPERSEDED by v0.1.1-alpha

#### Added:
- Dark themed GUI with UT2004-inspired colors (orange/blue/dark gray)
- Installation path selector with folder browser
- Automatic download of OldUnreal installer (~84 MB)
- Download progress indicator with size/percentage
- Silent installation of UT2004 base game
- Applies latest OldUnreal community patch automatically
- Status messages throughout installation
- Downloads stored in temp directory for re-use

#### Known Issues:
- ❌ Installation fails when run from AutoIt script (works from command line)
- ❌ Issue: Run() command doesn't handle paths properly
- ✅ **Fixed in v0.1.1-alpha**

---

## Planned Versions

### v0.2.0-alpha - Mega Pack Support
**Planned Features**:
- Download Mega Pack from unrealarchive.org
- Extract only Maps/Textures/StaticMeshes folders
- Skip System folder to avoid patch downgrade
- Checkbox option to install Mega Pack
- Hash verification (SHA1)

### v0.3.0-alpha - Community Bonus Packs
**Planned Features**:
- Community Bonus Pack 1 support
- Community Bonus Pack 2 Vol 1 & 2 support
- Multiple checkbox selections
- Installation size calculator

### v0.4.0-beta - Polish & Testing
**Planned Features**:
- Installation presets (Recommended, Full, Custom)
- Multi-mirror download support
- "Keep downloaded files" option
- "Launch game after install" option
- Comprehensive error handling
- Installation log file

### v1.0.0 - Public Release
**Goals**:
- Fully tested on clean Windows installations
- All features working reliably
- User documentation complete
- Community feedback incorporated

---

## Version Naming Convention

**Alpha** (v0.x.x-alpha): Early development, features being built, may be unstable  
**Beta** (v0.x.x-beta): Feature complete, testing phase, bug fixing  
**Release Candidate** (v0.x.x-rc): Almost ready, final testing  
**Release** (v1.0.0): Stable, public release

**Semantic Versioning**: MAJOR.MINOR.PATCH
- **MAJOR**: Breaking changes, major milestones
- **MINOR**: New features added
- **PATCH**: Bug fixes, small improvements
