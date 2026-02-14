# UT2004 All-in-One Installer

## Version 0.1 - Basic Installer

A modern AutoIt-based installer for Unreal Tournament 2004 with a dark UT2004-themed interface.

---

## Current Features (v0.1)

- ✅ Dark themed GUI with UT2004-inspired colors (orange/blue/dark gray)
- ✅ Installation path selector with folder browser
- ✅ Automatic download of OldUnreal installer (~84 MB)
- ✅ Download progress indicator with size/percentage
- ✅ Silent installation of UT2004 base game
- ✅ Applies latest OldUnreal community patch automatically
- ✅ Status messages throughout installation
- ✅ Downloads stored in temp directory for re-use

---

## How to Use

### Running from Source (AutoIt installed):
1. Install AutoIt from: https://www.autoitscript.com/
2. Double-click `UT2004_Installer.au3` to run

### Compiling to EXE:
1. Right-click `UT2004_Installer.au3`
2. Select "Compile Script (x64)" or "Compile Script (x86)"
3. Run the generated `UT2004_Installer.exe`

---

## Installation Process

1. **Select Installation Directory**
   - Default suggestion: `@ScriptDir\UT2004`
   - Click "Browse..." to choose a different location
   - Path is saved to the input field

2. **Click "Install UT2004"**
   - Checks if OldUnreal installer exists in temp directory
   - If not found, downloads from GitHub (~84 MB)
   - Shows download progress with MB downloaded and percentage
   - Runs silent installation to selected directory
   - OldUnreal installer handles:
     - Downloading base game from Archive.org (~5.5 GB)
     - Extracting all game files
     - Applying latest community patch
     - Configuring for modern systems

3. **Installation Complete**
   - Verification checks for `UT2004.exe` in System folder
   - Success message shows installation directory
   - Ready to play!

---

## Temporary Files

Downloads are stored in: `%TEMP%\UT2004\`

Files stored here:
- `UT2004_OldUnreal.exe` - OldUnreal installer (~84 MB)

**Benefits of keeping temp files:**
- Faster re-installation (no re-download needed)
- Saves bandwidth for testing multiple installs
- Manual cleanup: Delete `%TEMP%\UT2004\` folder when done

**To auto-delete on exit:**
- Uncomment the `DirRemove()` line in the `ExitProgram()` function

---

## Color Scheme

Inspired by the official UT2004 logo:

| Color | Hex Code | Usage |
|-------|----------|-------|
| Dark Background | `#1A1A1A` | Main window background |
| Mid Background | `#2A2A2A` | Input boxes, buttons |
| UT Orange | `#FF8C00` | Title, accents, progress bar |
| UT Blue | `#4A5F7F` | Subtitle, status text |
| Light Text | `#E0E0E0` | Primary text |
| Dim Text | `#808080` | Secondary text |

---

## Technical Details

### Requirements:
- Windows 7 or later
- Internet connection (for downloads)
- ~6 GB free disk space (base game)
- AutoIt 3.3.14+ (for running/compiling source)

### OldUnreal Installer:
- **Source**: https://github.com/OldUnreal/FullGameInstallers
- **Version**: Latest Windows installer
- **Command Line**: `/S /D=<InstallPath>`
  - `/S` = Silent installation
  - `/D=` = Destination directory (must be last parameter, no quotes)

### AutoIt Includes Used:
- `ButtonConstants.au3` - Button styles
- `EditConstants.au3` - Input box styles
- `GUIConstantsEx.au3` - GUI creation
- `StaticConstants.au3` - Label styles
- `WindowsConstants.au3` - Window constants
- `File.au3` - File operations
- `InetConstants.au3` - Internet download constants

---

## Known Issues

None currently! 🎉

---

## Planned Features

### Next Version (v0.2):
- [ ] Add Mega Pack installation option
- [ ] Extract Mega Pack maps only (skip System files to avoid patch downgrade)
- [ ] Option to keep/delete downloaded files

### Future Versions:
- [ ] Community Bonus Pack 1 installation
- [ ] Community Bonus Pack 2 (Vol 1 & 2) installation
- [ ] Checkbox selection for individual packs
- [ ] Installation presets (Recommended, Full, Minimal, Custom)
- [ ] File hash verification (SHA1)
- [ ] Multi-mirror download support
- [ ] Installation size calculator
- [ ] Uninstaller option
- [ ] Launch game after install option

---

## File Structure

```
ut2004-installer-project/
│
├── UT2004_Installer.au3      - Main AutoIt script
├── README.md                  - This file
│
└── docs/
    ├── RESEARCH.md            - Detailed research on bonus packs
    └── FILE_STRUCTURE.md      - Installation file mappings
```

---

## Development Notes

### Version 0.1 Changes:
- Initial release
- Basic GUI with UT2004 theming
- OldUnreal installer integration
- Download progress tracking
- Silent installation support

### Design Decisions:
1. **No default install path**: User must choose (prevents accidental installs)
2. **Starting suggestion**: `@ScriptDir\UT2004` for convenience
3. **Temp directory**: `@TempDir\UT2004` for OS-managed cleanup
4. **Keep downloads**: Saved for re-use (user can manually delete)
5. **Silent install**: Clean, no popups from OldUnreal installer
6. **Verification**: Checks for `UT2004.exe` in `System\` folder

---

## Credits

- **OldUnreal Team**: For maintaining UT2004 patches and installers
- **Epic Games**: For the original Unreal Tournament 2004
- **Community**: For all the bonus packs and continued support

---

## License

This installer is a community project. UT2004 and all related content are property of Epic Games.

---

## Support & Feedback

Found a bug? Have a suggestion? Let us know!

Current version: **0.1** (Basic OldUnreal Installer)
