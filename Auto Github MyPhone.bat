@ECHO OFF
ECHO.
git status
ECHO.
ECHO.
git add *
git commit -m "Update (auto commit)"
COLOR 1
git push
COLOR 2
ECHO.
ECHO.
git status
ECHO.
ECHO.
pause
