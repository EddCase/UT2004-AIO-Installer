# Changelog

All notable changes to the UT2004 All-In-One Installer will be documented here.

---

## [0.3.0-alpha] - 2026-02-15

### 🎉 Complete Rewrite - Fresh Start

**Breaking Changes:**
- Complete rewrite of installation process
- No longer uses OldUnreal's installer
- Custom extraction and installation logic

**Added:**
- Custom ISO download and extraction
- 7-Zip integration for ISO extraction
- unshield integration for CAB extraction
- FileInstall for bundled tools (self-contained)
- Flattened CAB extraction (works with multiple ISO types)

**Design Decisions:**
- Download ISO ourselves (full control)
- Extract only CAB files (efficient)
- Flatten directory structure (handles Disk1-5 or CD1-7)
- Bundle tools with installer (no external dependencies)
- No CD key required (OldUnreal patch removes validation)

**Development Phases:**
- [ ] Phase 1: GUI with UT2004 theme
- [ ] Phase 2: ISO download with progress
- [ ] Phase 3: ISO extraction (7-Zip)
- [ ] Phase 4: CAB extraction (unshield)
- [ ] Phase 5: Patch and finalization

---

## [0.1.1-alpha] - 2026-02-14

### Fixed
- Replaced `Run()` with `ShellExecuteWait()` for better path handling
- Fixed installation to paths with spaces
- Improved error handling

### Changed
- More reliable execution of OldUnreal installer

---

## [0.1.0-alpha] - 2026-02-14

### Added
- Initial release
- Dark themed GUI with UT2004-inspired colors
- Integration with OldUnreal installer
- Silent installation support
- Download progress tracking
- Installation path selector

### Known Issues
- Installation fails with paths containing spaces (fixed in 0.1.1)

---

## Version Naming Convention

- **Alpha** (v0.x.x-alpha): Early development, features being built
- **Beta** (v0.x.x-beta): Feature complete, testing phase
- **Release** (v1.0.0): Stable, public release

**Semantic Versioning**: MAJOR.MINOR.PATCH
- **MAJOR**: Breaking changes, major milestones
- **MINOR**: New features added
- **PATCH**: Bug fixes, small improvements

---

**Legend:**
- 🎉 Major milestone
- ✨ New feature
- 🐛 Bug fix
- 🔧 Improvement
- 🚨 Breaking change
- 📝 Documentation
