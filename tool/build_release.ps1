param(
  [ValidateSet('android','apk','ios','web')]
  [string]$Target = 'android'
)

if (-not $env:API_BASE_URL) { throw 'Set API_BASE_URL to the production HTTPS API URL' }
if (-not $env:SOCKET_BASE_URL) { throw 'Set SOCKET_BASE_URL to the production HTTPS Socket.IO URL' }

$enableFirebase = if ($env:ENABLE_FIREBASE) { $env:ENABLE_FIREBASE } elseif ($Target -eq 'web') { 'false' } else { 'true' }
$appVersion = if ($env:APP_VERSION) { $env:APP_VERSION } else { '1.0.0' }

$defines = @(
  '--release',
  '--dart-define=APP_ENV=production',
  "--dart-define=API_BASE_URL=$($env:API_BASE_URL)",
  "--dart-define=SOCKET_BASE_URL=$($env:SOCKET_BASE_URL)",
  "--dart-define=ENABLE_FIREBASE=$enableFirebase",
  "--dart-define=APP_VERSION=$appVersion"
)

flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
flutter analyze
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
flutter test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if ($Target -eq 'android') {
  flutter build appbundle @defines
} elseif ($Target -eq 'apk') {
  flutter build apk @defines
  Write-Host ''
  Write-Host 'APK artifact: build/app/outputs/flutter-apk/app-release.apk'
} elseif ($Target -eq 'ios') {
  flutter build ipa @defines
} else {
  flutter build web @defines
  Write-Host ''
  Write-Host 'Web artifact: build/web'
  Write-Host 'Deploy: firebase deploy --only hosting'
}
