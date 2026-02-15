# GitHub Setup Instructions

Follow these steps to get your UT2004-AIO-Installer project on GitHub.

---

## Part 1: Create the Repository on GitHub.com

1. **Go to GitHub**: https://github.com/
2. **Sign in** with your account (EddCase)
3. **Click the "+" button** in the top-right corner
4. **Select "New repository"**
5. **Fill in the details**:
   - Repository name: `UT2004-AIO-Installer`
   - Description: `All-In-One installer for UT2004 with bonus packs`
   - Privacy: ✅ **Private**
   - ❌ **DO NOT** initialize with README, .gitignore, or license (we have our own)
6. **Click "Create repository"**

GitHub will show you a page with setup instructions - **keep this page open**, we'll use it in Part 3.

---

## Part 2: Prepare Your Local Files

### Step 1: Check Git Installation

Open Command Prompt or PowerShell and run:
```bash
git --version
```

- ✅ If you see a version number (e.g., `git version 2.40.0`), you're good!
- ❌ If you get an error, install Git from: https://git-scm.com/download/win

### Step 2: Configure Git (First Time Only)

If this is your first time using Git on this computer:

```bash
git config --global user.name "EddCase"
git config --global user.email "your-email@example.com"
```

Replace `your-email@example.com` with the email you used for GitHub.

### Step 3: Navigate to Your Project Folder

```bash
cd C:\Users\Edd\Documents\UT2004 Installer
```

Or use File Explorer:
- Navigate to `C:\Users\Edd\Documents\UT2004 Installer`
- Type `cmd` in the address bar and press Enter (opens Command Prompt in that folder)

---

## Part 3: Initialize Git and Push to GitHub

### Step 1: Initialize Git Repository

In your project folder, run:

```bash
git init
```

You should see: `Initialized empty Git repository in C:/Users/Edd/Documents/UT2004 Installer/.git/`

### Step 2: Add Your Files

First, let's see what files we have:
```bash
git status
```

This shows all files that aren't tracked yet. Now add them all:

```bash
git add .
```

The `.` means "add everything in this folder"

### Step 3: Create Your First Commit

```bash
git commit -m "Initial commit - v0.1.1-alpha with ShellExecuteWait fix"
```

### Step 4: Rename Branch to 'main'

GitHub uses 'main' as the default branch name:

```bash
git branch -M main
```

### Step 5: Connect to GitHub

Replace `YOUR_GITHUB_URL` with the URL from the GitHub page (from Part 1).

It will look like: `https://github.com/EddCase/UT2004-AIO-Installer.git`

```bash
git remote add origin https://github.com/EddCase/UT2004-AIO-Installer.git
```

### Step 6: Push to GitHub

```bash
git push -u origin main
```

**First time?** Git will ask for your GitHub credentials:
- Username: `EddCase`
- Password: You'll need a **Personal Access Token** (not your GitHub password)

#### Creating a Personal Access Token:

1. Go to: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Give it a name: `UT2004 Installer`
4. Check the `repo` scope (full control of private repositories)
5. Click "Generate token"
6. **COPY THE TOKEN** - you won't see it again!
7. Use this token as your password when Git asks

---

## Part 4: Verify It Worked

1. Go to: https://github.com/EddCase/UT2004-AIO-Installer
2. You should see all your files!
3. You should see your commit message
4. README.md should be displayed at the bottom

🎉 **Success!** Your project is now on GitHub!

---

## Daily Workflow (After Initial Setup)

### Option 1: Manual Git Commands

When you make changes to your files:

```bash
# See what changed
git status

# Add all changed files
git add .

# Commit with a message describing what you changed
git commit -m "Added Mega Pack support"

# Push to GitHub
git push
```

### Option 2: Use the Automation Batch File (Recommended!)

We've created `_upload.bat` to automate the entire workflow:

1. Download `files.zip` from Claude sidebar
2. Extract to your project folder
3. Run `_upload.bat`
4. Enter your commit message
5. Done! Files are copied, committed, and pushed automatically

The batch file:
- ✅ Copies `gitignore.txt` → `.gitignore`
- ✅ Copies `README_FOR_GITHUB.md` → `README.md`
- ✅ Keeps originals for next download
- ✅ Shows what changed before committing
- ✅ Handles errors gracefully
- ✅ Won't be committed to Git (uses underscore prefix)

**Note:** `_upload.bat` starts with underscore so Git ignores it (it's your personal tool).

---

## Syncing Between Computers

### On your OTHER computer (first time):

```bash
# Navigate to where you want the project
cd C:\Users\YourName\Documents

# Clone the repository
git clone https://github.com/EddCase/UT2004-AIO-Installer.git

# Enter the folder
cd UT2004-AIO-Installer
```

### Pulling latest changes:

```bash
# Get the latest changes from GitHub
git pull
```

---

## Useful Git Commands

```bash
# See what changed
git status

# See commit history
git log --oneline

# Undo changes to a file (before committing)
git checkout -- filename.au3

# See what's different
git diff

# Add specific file instead of everything
git add UT2004_Installer.au3

# Commit with detailed message
git commit -m "Title" -m "Detailed description here"
```

---

## Troubleshooting

### "fatal: not a git repository"
You're not in the project folder. Run `cd C:\Users\Edd\Documents\UT2004 Installer`

### "failed to push some refs"
Someone else (or you on another computer) pushed changes. Run `git pull` first, then `git push`

### "Authentication failed"
Your Personal Access Token expired or is wrong. Create a new one at: https://github.com/settings/tokens

### Need to change your commit message?
```bash
git commit --amend -m "New message"
```

### Want to see what's on GitHub vs local?
```bash
git fetch
git status
```

---

## Files to Put in Your Repository

Make sure these files are in `C:\Users\Edd\Documents\UT2004 Installer\`:

**Required:**
- ✅ `UT2004_Installer_v0.1.1-alpha.au3` - Main script
- ✅ `.gitignore` - Tells Git what to ignore
- ✅ `README.md` - Project description (rename README_GITHUB.md to README.md)
- ✅ `CHANGELOG.md` - Version history
- ✅ `LICENSE` - License file (create if you want)

**Optional but Recommended:**
- ✅ `docs/RESEARCH.md` - Research documentation
- ✅ `docs/FILE_STRUCTURE.md` - File mappings
- ✅ `docs/TESTING.md` - Testing procedures (when we create it)

---

## Need Help?

If you get stuck at any step, let me know which error message you're seeing and I'll help troubleshoot!

---

**Quick Reference:**

```bash
# Basic workflow
git status          # What changed?
git add .           # Stage all changes
git commit -m "msg" # Save changes
git push            # Upload to GitHub
git pull            # Download from GitHub
```

That's it! You're ready to use Git and GitHub! 🚀
