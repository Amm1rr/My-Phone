@ECHO OFF
CLS
COLOR 8
TITLE=Auto Git MyPhone
ECHO.
SET MSG="Update (auto commit)"
SET MSG="Improve home list UI"
ECHO.##### Git Status
git status
ECHO.
ECHO.
ECHO.##### Git Add Files
git add *
ECHO.
ECHO.##### Git Commit:
ECHO.
ECHO.	%MSG%:
ECHO.
git commit -m %MSG%
rem git commit
ECHO.
ECHO.
ECHO.##### Git Push:
COLOR 3
git push
COLOR 2
ECHO.
ECHO.
ECHO.##### Git Status
git status
ECHO.
ECHO.
ECHO.Successfully Done!
pause
