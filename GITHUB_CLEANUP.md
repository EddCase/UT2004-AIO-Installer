# GitHub Repository Cleanup Guide

## Current Situation
Your local files are now clean, but GitHub still has the old messy structure.

## Option 1: Clean Commit (Recommended)
This will remove old files from GitHub while keeping git history.

### Steps:

1. **Add the new .gitignore**
   ```bash
   copy .gitignore "C:\Users\Edd\Documents\UT2004 Installer\.gitignore"
   ```

2. **Navigate to your repo**
   ```bash
   cd "C:\Users\Edd\Documents\UT2004 Installer"
   ```

3. **Remove old files from git tracking**
   ```bash
   git rm --cached UT2004_Installer_v0.3.*.au3
   git rm --cached UT2004_Installer_v0.4.*.au3
   git rm --cached UT2004_Installer_v0.5.*.au3
   git rm --cached UT2004_Installer_v0.6.0.au3
   git rm --cached UT2004_Installer_v0.6.1.au3
   git rm --cached *.exe
   git rm --cached -r _Old/
   git rm --cached BONUS_CONTENT_RESEARCH.md
   git rm --cached PHASE*.md
   git rm --cached FIXES_*.md
   git rm --cached TAB_SYSTEM_PLAN.md
   git rm --cached TRAYTIP_STRATEGY.md
   git rm --cached files.zip
   git rm --cached gitignore.txt
   git rm --cached DIR.txt
   git rm --cached repack_bonus_packs.bat
   git rm --cached CHANGELOG_v0.6.1.md
   ```

4. **Stage the current clean files**
   ```bash
   git add .
   git add .gitignore
   ```

5. **Commit the cleanup**
   ```bash
   git commit -m "v0.6.2 - Repository cleanup and organization"
   ```

6. **Push to GitHub**
   ```bash
   git push origin main
   ```

## Option 2: Fresh Start (Nuclear Option)
If you want a completely clean history:

1. Delete the `.git` folder in your project
2. Re-initialize: `git init`
3. Add files: `git add .`
4. Initial commit: `git commit -m "v0.6.2 - Clean repository structure"`
5. Force push to GitHub

## What Will Remain on GitHub

### Root Files:
- ✅ UT2004_Installer_v0.6.2.au3 (latest source)
- ✅ Uninstaller.au3 (latest source)
- ✅ README.md
- ✅ CHANGELOG.md
- ✅ LICENSE
- ✅ .gitignore
- ✅ UT2004.ico
- ✅ _upload.bat

### Folders:
- ✅ BonusPacks/ (bonus pack archives)
- ✅ Licences/ (license files)
- ✅ Tools/ (7z, unshield, etc. - NOT compiled Uninstaller.exe)

### NOT on GitHub (ignored):
- ❌ Old installer versions
- ❌ Compiled .exe files
- ❌ _Old/ folder
- ❌ Research/planning docs
- ❌ Temp files

## After Cleanup

Your GitHub will look professional and clean, with only:
- Current source files
- Documentation
- Required assets
- No clutter!

Users will download source and compile themselves, or download releases.
