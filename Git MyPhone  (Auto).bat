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

git status
ECHO.
ECHO.
pause
