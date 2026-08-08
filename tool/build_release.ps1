param([ValidateSet('android','ios')][string]$Target = 'android')

if (-not $env:API_BASE_URL) { throw 'Set API_BASE_URL to the production HTTPS API URL' }
if (-not $env:SOCKET_BASE_URL) { throw 'Set SOCKET_BASE_URL to the production HTTPS Socket.IO URL' }

$defines = @(
  '--release',
  '--dart-define=APP_ENV=production',
  "--dart-define=API_BASE_URL=$($env:API_BASE_URL)",
  "--dart-define=SOCKET_BASE_URL=$($env:SOCKET_BASE_URL)",
  '--dart-define=ENABLE_FIREBASE=true'
)

flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
flutter analyze
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
flutter test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if ($Target -eq 'android') {
  flutter build appbundle @defines
} else {
  flutter build ipa @defines
}
