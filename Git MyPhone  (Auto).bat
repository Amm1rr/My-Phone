@ECHO OFF
ECHO.
git status
ECHO.
ECHO.
git add *
git commit -m "Update (auto commit)"
git push
ECHO.
ECHO.
COLOR 2
git status
ECHO.
ECHO.
pause
