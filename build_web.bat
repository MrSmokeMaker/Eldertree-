@echo off
echo Building Eldertree for web deployment...
echo.

echo Step 1: Cleaning build directory...
flutter clean

echo Step 2: Getting dependencies...
flutter pub get

echo Step 3: Running code generation...
flutter pub run build_runner build --delete-conflicting-outputs

echo Step 4: Building web release...
flutter build web --release --base-href /Eldertree/

echo.
echo ========================================
echo Build completed successfully!
echo Output files are in: build/web
echo To deploy: commit and push to GitHub
echo GitHub Pages URL: https://mrsmokemaker.github.io/Eldertree/
echo ========================================
pause