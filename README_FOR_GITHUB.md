# UT2004 All-In-One Installer

A modern, user-friendly installer for Unreal Tournament 2004 with support for official and community bonus packs.

![Version](https://img.shields.io/badge/version-0.1.1--alpha-orange)
![Status](https://img.shields.io/badge/status-in%20development-yellow)
![AutoIt](https://img.shields.io/badge/AutoIt-v3.3.14+-blue)

---

## 🎮 What is This?

This is an **All-In-One installer** for Unreal Tournament 2004 that makes it easy to install:

- ✅ Base game with latest OldUnreal community patch
- 🔜 Mega Pack (9 additional official maps)
- 🔜 Community Bonus Pack 1 (19-21 community maps)
- 🔜 Community Bonus Pack 2 Vol 1 & 2 (41 community maps)

Built with AutoIt and featuring a dark UT2004-themed interface.

---

## 🚀 Current Status: v0.1.1-alpha

**What Works:**
- Dark themed GUI with UT2004-inspired colors
- Installation path selector
- Automatic download of OldUnreal installer
- Download progress tracking
- Silent installation of base game
- Latest community patch applied automatically

**In Development:**
- Mega Pack support
- Community Bonus Packs
- Installation presets
- Hash verification

See [CHANGELOG.md](CHANGELOG.md) for version history and roadmap.

---

## 📋 Requirements

- **OS**: Windows 7 or later
- **Disk Space**: ~10-12 GB (with all bonus packs)
- **Internet**: Required for downloading game files
- **AutoIt**: v3.3.14+ (for compiling from source)

---

## 🔧 How to Use

### Option 1: Download Release (Coming Soon)
Download the compiled `.exe` from [Releases](../../releases) and run it.

### Option 2: Run from Source
1. Install [AutoIt](https://www.autoitscript.com/)
2. Download `UT2004_Installer_vX.X.X-alpha.au3`
3. Double-click to run, or compile to `.exe`

---

## 📁 Project Structure

```
UT2004-AIO-Installer/
├── UT2004_Installer_vX.X.X-alpha.au3   - Main installer script
├── README.md                            - This file
├── CHANGELOG.md                         - Version history
├── LICENSE                              - Project license
│
└── docs/
    ├── RESEARCH.md                      - Bonus pack research & download links
    ├── FILE_STRUCTURE.md                - Installation file mappings
    └── TESTING.md                       - Testing procedures & checklists
```

---

## 🎨 Features

### Current (v0.1.1-alpha)
- **Dark Theme**: UT2004-inspired orange/blue color scheme
- **Smart Downloads**: Files cached in temp directory for re-use
- **Progress Tracking**: Real-time download progress with MB/percentage
- **Silent Installation**: Clean, no-popup installation process
- **Path Validation**: Checks installation completed successfully

### Planned (v0.2.0+)
- **Bonus Pack Support**: Install official and community content
- **Installation Presets**: Recommended, Full, Minimal, Custom
- **Hash Verification**: SHA1 verification for download integrity
- **Multi-Mirror Support**: Automatic fallback if download fails
- **Size Calculator**: Shows required disk space before install
- **Launch Option**: Start game immediately after installation

---

## 🧪 Testing

Currently in **alpha** - testing on various Windows configurations.

If you find bugs or have suggestions, please open an issue!

---

## 🙏 Credits

- **[OldUnreal Team](https://github.com/OldUnreal)** - For maintaining UT2004 patches and installers
- **[Unreal Archive](https://unrealarchive.org/)** - For hosting community bonus packs
- **Epic Games** - For the original Unreal Tournament 2004
- **Community** - For all the amazing bonus content over the years

---

## 📄 License

This installer is a community project. UT2004 and all related content are property of Epic Games.

See [LICENSE](LICENSE) for details.

---

## 🔗 Useful Links

- [OldUnreal UT2004 Patches](https://github.com/OldUnreal/UT2004Patches)
- [Unreal Archive](https://unrealarchive.org/unreal-tournament-2004/)
- [PCGamingWiki - UT2004](https://www.pcgamingwiki.com/wiki/Unreal_Tournament_2004)
- [UT2004 Community Discord](https://discord.gg/unrealtournament)

---

## 💬 Support

Having issues? Check the [Issues](../../issues) page or create a new issue with:
- Windows version
- Installation path used
- Error message or behavior
- Any relevant log files

---

**Current Version**: v0.1.1-alpha  
**Status**: 🚧 In Active Development  
**Last Updated**: February 14, 2026
