# Quick Start Script for MuscleMax

Write-Host "🏋️ MuscleMax Setup & Run Script" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-String "Flutter"
    Write-Host "✓ Flutter found: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Flutter not found! Please install Flutter SDK first." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Installing dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "Checking for available devices..." -ForegroundColor Yellow
flutter devices

Write-Host ""
Write-Host "⚠️  IMPORTANT: Font Files Required!" -ForegroundColor Yellow
Write-Host "Before running, make sure you have downloaded the font files:" -ForegroundColor Yellow
Write-Host "  - Bebas Neue, Montserrat, DM Sans" -ForegroundColor White
Write-Host "  - Place them in: assets/fonts/" -ForegroundColor White
Write-Host "  - See assets/fonts/README.md for download links" -ForegroundColor White
Write-Host ""

$response = Read-Host "Have you added the font files? (y/n)"
if ($response -eq "y") {
    Write-Host ""
    Write-Host "🚀 Starting MuscleMax app..." -ForegroundColor Green
    flutter run
} else {
    Write-Host ""
    Write-Host "Please download the fonts first, then run this script again." -ForegroundColor Yellow
    Write-Host "Font download links:" -ForegroundColor Cyan
    Write-Host "  1. Bebas Neue: https://fonts.google.com/specimen/Bebas+Neue" -ForegroundColor White
    Write-Host "  2. Montserrat: https://fonts.google.com/specimen/Montserrat" -ForegroundColor White
    Write-Host "  3. DM Sans: https://fonts.google.com/specimen/DM+Sans" -ForegroundColor White
}
