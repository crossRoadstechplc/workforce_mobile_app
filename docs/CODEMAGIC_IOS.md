# Codemagic — iOS (TestFlight)

This repo includes [`codemagic.yaml`](../codemagic.yaml) at the Flutter project root. Codemagic builds on macOS; you do **not** need a local Mac for CI.

The `npx prisma migrate deploy` error from the **workforce-backend** folder is unrelated — Prisma lives in the API repo, not in this mobile app.

## 1. Connect the repository

1. Sign in at [codemagic.io](https://codemagic.io).
2. Add application → **GitHub** → `crossRoadstechplc/workforce_mobile_app`.
3. Codemagic detects `codemagic.yaml` automatically.

## 2. Apple Developer & App Store Connect

1. Register an **App ID** whose bundle ID matches `IOS_BUNDLE_ID` in `codemagic.yaml` (today: `com.example.workforceEmployeeApp` — change this to your production ID in Apple Developer and in the yaml).
2. Create the app in **App Store Connect** with the same bundle ID.
3. In Codemagic: **Team settings → Integrations → App Store Connect** → add API key (Issuer ID, Key ID, `.p8` file). Name the integration **`workforce_app_store`** (must match `codemagic.yaml`).

## 3. iOS code signing (Codemagic)

1. **Team settings → Code signing identities** → upload **Distribution** certificate (or let Codemagic create one via ASC API).
2. **Team settings → iOS provisioning profiles** → App Store profile for your bundle ID.
3. In the app workflow, confirm **Automatic code signing** uses that bundle ID.

Alternatively, use Codemagic’s **iOS code signing** wizard tied to your App Store Connect integration.

## 4. Environment group `workforce_ios`

Create a group named **`workforce_ios`** (referenced in `codemagic.yaml`) with:

| Variable | Required | Example |
|----------|----------|---------|
| `API_BASE_URL` | yes | `https://your-api.com/api/v1` |
| `SOCKET_BASE_URL` | yes | `https://your-api.com` |
| `ENABLE_FIREBASE` | no | `true` |
| `APP_VERSION` | no | `1.0.2` (defaults from `pubspec.yaml`) |
| `GOOGLE_SERVICE_INFO_PLIST_BASE64` | yes for push | Base64 of `GoogleService-Info.plist` |
| `FIREBASE_OPTIONS_DART_BASE64` | optional | Base64 of generated `lib/firebase_options.dart` |
| `BUILD_NOTIFICATION_EMAIL` | no | Build success/failure email |

Encode a file (macOS/Linux):

```bash
base64 -i GoogleService-Info.plist | pbcopy
base64 -i lib/firebase_options.dart | pbcopy
```

PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("ios\Runner\GoogleService-Info.plist"))
```

Commit `lib/firebase_options.dart` after `flutterfire configure`, or supply it via `FIREBASE_OPTIONS_DART_BASE64`.

## 5. Workflows

| Workflow | Trigger | Result |
|----------|---------|--------|
| **iOS → TestFlight** | Push to `main` or `release/*` | IPA + upload to TestFlight |
| **iOS → IPA only** | Git tag `v*` (e.g. `v1.0.2`) | IPA artifact download only |

Update the email recipient in `codemagic.yaml` under `publishing.email.recipients`.

## 6. Local parity

Same build flags as CI:

```bash
export API_BASE_URL=https://your-api.com/api/v1
export SOCKET_BASE_URL=https://your-api.com
export APP_VERSION=1.0.2
tool/build_release.sh ios
```

## 7. Checklist before first green build

- [ ] Production bundle ID set in Xcode (`ios/Runner.xcodeproj`) and `IOS_BUNDLE_ID` in yaml
- [ ] App Store Connect app + API key linked in Codemagic
- [ ] Distribution cert + App Store provisioning profile
- [ ] `workforce_ios` group with HTTPS API/Socket URLs
- [ ] Firebase iOS app + `GoogleService-Info.plist` (secret or committed for local only)
- [ ] Push Notifications + Background Modes in Xcode (see `docs/FIREBASE_SETUP.md`)
- [ ] Commit `lib/firebase_options.dart` stub or generated file (no longer gitignored)
