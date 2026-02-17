@echo off
:: ========================================
:: UT2004 Installer - Git Upload Script
:: ========================================
:: Commits all changes, tags as v0.6.6, and pushes to GitHub
:: After running this, go to GitHub to create the Release and attach the .exe
:: ========================================

cd /d "C:\Users\Edd\Documents\UT2004 Installer"

echo.
echo ========================================
echo  UT2004 Installer - Upload v0.6.6
echo ========================================
echo.

:: Show what's changed so you can review before committing
echo Files to be committed:
echo ----------------------------------------
git status
echo.

:: Confirm before proceeding
set /p CONFIRM=Proceed with commit and push? (y/n): 
if /i "%CONFIRM%" neq "y" (
    echo Cancelled.
    pause
    exit /b 0
)

echo.
echo Adding files...
git add .

echo.
echo Committing...
git commit -m "v0.6.6 - Portable cache fix, new shortcuts, smart cleanup

- Fixed bonus pack archives not moving to portable cache
- Phase_Finalise() now runs after all downloads complete
- Extracted folders cleaned after install, install.log preserved
- UnrealEd and Manual shortcuts added to Start Menu and install root
- Global version constant added (single change for future bumps)
- Fixed stale v0.6.4 version strings in title bar and Options tab"

echo.
echo Tagging v0.6.6...
git tag -a v0.6.6 -m "Version 0.6.6"

echo.
echo Pushing to GitHub...
git push origin main
git push origin v0.6.6

echo.
echo ========================================
echo  Done! Now go to GitHub to create the
echo  Release and attach UT2004_Installer.exe
echo  https://github.com/EddCase/UT2004-AIO-Installer/releases/new
echo ========================================
echo.
pause
