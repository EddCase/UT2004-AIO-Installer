# UT2004 All-In-One Installer

A modern, self-contained installer for Unreal Tournament 2004 with full control over the installation process.

![Version](https://img.shields.io/badge/version-0.3.0--alpha-orange)
![Status](https://img.shields.io/badge/status-in%20development-yellow)
![AutoIt](https://img.shields.io/badge/AutoIt-v3.3.14+-blue)

---

## 🎮 What is This?

A completely custom installer for Unreal Tournament 2004 that:
- Downloads and extracts the game ISO ourselves
- Applies the latest OldUnreal community patch
- Requires **NO CD KEY** (patch removes validation)
- Features a dark UT2004-themed interface
- Self-contained (all tools bundled)

---

## 🚀 Current Status: v0.3.0-alpha

**Complete rewrite with custom installation process.**

### What Works:
- Nothing yet - fresh start! 🎉

### In Development:
- Phase 1: GUI with UT2004 theme
- Phase 2: ISO download with progress
- Phase 3: ISO extraction (7-Zip)
- Phase 4: CAB extraction (unshield)
- Phase 5: Patch application and finalization

---

## 📋 Requirements

- **OS**: Windows 7 or later
- **Disk Space**: ~20 GB temporary, ~15 GB final
- **Internet**: Required for downloading game files (~2.76 GB ISO + patches)
- **AutoIt**: v3.3.14+ (for compiling from source)

---

## 🔧 How to Use

### Download Release (Coming Soon)
Download the compiled `.exe` from [Releases](../../releases) and run it.

### Run from Source
1. Install [AutoIt](https://www.autoitscript.com/)
2. Download `UT2004_Installer_v0.3.0-alpha.au3`
3. Double-click to run, or compile to `.exe`

---

## 🎨 Key Features

### Custom Installation
- ✅ **Full control** over every installation step
- ✅ **No CD key required** - OldUnreal patch removes validation
- ✅ **Self-contained** - All tools bundled (7-Zip, unshield)
- ✅ **Efficient** - Only extracts what's needed
- ✅ **Works offline** - Once files are downloaded

### Dark Theme UI
- UT2004-inspired orange/blue color scheme
- Clean, modern interface
- Real-time progress tracking
- TrayTip notifications for major milestones

### Smart Download Management
- Resumes interrupted downloads
- Verifies file integrity
- Caches downloads for re-installation
- Optional: Keep or delete cached files

---

## 📁 Project Structure

```
UT2004-AIO-Installer/
├── UT2004_Installer_v0.3.0-alpha.au3  - Main installer script
├── README.md                           - This file
├── CHANGELOG.md                        - Version history
├── LICENSE                             - MIT License
├── .gitignore                          - Git ignore rules
│
├── Tools/                              - Bundled tools (FileInstall)
│   ├── 7z.exe                          - 7-Zip console (1.4 MB)
│   ├── 7z.dll                          - 7-Zip library
│   ├── unshield.exe                    - CAB extractor
│   └── zlib1.dll                       - unshield dependency
│
├── Licenses/                           - Required licenses
│   ├── 7zip-LICENSE.txt
│   └── unshield-LICENSE.txt
│
└── docs/                               - Documentation
    ├── INSTALLATION_PROCESS.md         - How installation works
    ├── DEVELOPMENT_NOTES.md            - Development process
    └── ISO_STRUCTURE.md                - ISO format details

Runtime folders (created when installer runs, not committed):
├── _Downloads/                         - Cached ISO files
├── _Temp/                              - Temporary extraction
└── _Temp_CABs/                         - Extracted CAB files
```

**Convention**: Underscore prefix (_) = temporary/local, No underscore = part of project

---

## 🛠️ Installation Process

Our custom installer works as follows:

1. **Download UT2004.ISO** from files.oldunreal.net (~2.76 GB)
2. **Extract CAB files** from ISO using 7-Zip (flattened structure)
3. **Extract game files** from each CAB using unshield
4. **Download OldUnreal patch** (latest community patch)
5. **Apply patch** to installation
6. **Create shortcuts** (Desktop + Start Menu)
7. **Write registry** (install location only - no CD key!)
8. **Complete!**

---

## 🙏 Credits

- **[OldUnreal Team](https://github.com/OldUnreal)** - For maintaining UT2004 patches
- **[7-Zip](https://www.7-zip.org/)** - Igor Pavlov (LGPL)
- **[unshield](https://github.com/twogood/unshield)** - David Eriksson (MIT)
- **Epic Games** - For the original Unreal Tournament 2004
- **Community** - For keeping the game alive

---

## 📄 License

This installer: MIT License (see [LICENSE](LICENSE))

Bundled tools: See [Licenses/](Licenses/) for individual tool licenses

UT2004 game content: Property of Epic Games

---

## 💬 Support

Having issues? Check the [Issues](../../issues) page or create a new issue.

---

**Current Version**: v0.3.0-alpha  
**Status**: 🚧 In Active Development (Fresh Start!)  
**Last Updated**: February 15, 2026
