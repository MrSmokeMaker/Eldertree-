@echo off
setlocal
echo Building Eldertree for GitHub Pages...
echo.

rem Repository is MrSmokeMaker/Eldertree- (trailing dash), so the site is served
rem from /Eldertree-/ and the base href MUST contain the dash.
set BASE_HREF=/Eldertree-/

echo Step 1: Cleaning previous build...
call flutter clean || goto :error

echo Step 2: Getting dependencies...
call flutter pub get || goto :error

echo Step 3: Running code generation...
call flutter pub run build_runner build --delete-conflicting-outputs || goto :error

echo Step 4: Building web release...
if defined SUPABASE_URL (
  echo   Supabase credentials found in environment, embedding with --dart-define.
  call flutter build web --release --base-href %BASE_HREF% --no-web-resources-cdn ^
    --dart-define=SUPABASE_URL=%SUPABASE_URL% ^
    --dart-define=SUPABASE_ANON_KEY=%SUPABASE_ANON_KEY% || goto :error
) else (
  echo   WARNING: SUPABASE_URL / SUPABASE_ANON_KEY are not set.
  echo   The deployed app will show the configuration screen instead of the tree.
  call flutter build web --release --base-href %BASE_HREF% --no-web-resources-cdn || goto :error
)

echo Step 5: Verifying base href...
findstr /C:"<base href=\"%BASE_HREF%\">" build\web\index.html >nul || goto :basehref
echo   OK: base href is %BASE_HREF%

echo.
echo Build completed: build\web
echo Publish: copy the contents of build\web to the ROOT of the gh-pages branch and push.
echo URL: https://mrsmokemaker.github.io/Eldertree-/
exit /b 0

:basehref
echo ERROR: build\web\index.html has an unexpected base href.
echo Expected: ^<base href="%BASE_HREF%"^>
echo Every asset would 404 on GitHub Pages with a wrong base href.
exit /b 1

:error
echo ERROR: step failed, see output above.
exit /b 1
