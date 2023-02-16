@ECHO OFF
CLS
COLOR 8
ECHO.
SET MSG="Update (auto commit)"
ECHO.##### Git Status:
git status
ECHO.
ECHO.
ECHO.##### Git Add Files:
git add *
git ECHO.
ECHO.
ECHO.
ECHO.##### Git Commit:
ECHO. 				%MSG%:
git commit -m %MSG%
ECHO.
COLOR 3
git push
COLOR 2
ECHO.
ECHO.
git status
ECHO.
ECHO.
pause
