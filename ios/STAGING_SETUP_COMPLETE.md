# iOS Staging Flavor Setup - Complete

## What Was Done

### 1. iOS Deployment Target
- Updated to iOS 15.0 in:
  - `ios/Podfile`
  - All build configurations in `ios/Runner.xcodeproj/project.pbxproj`

### 2. Staging Build Configurations
Added three staging build configurations in Xcode:
- **stagingDebug** - For development/debugging
- **stagingRelease** - For release builds
- **stagingProfile** - For profiling

### 3. Bundle Identifiers
- **Production**: `life.doxa.pray`
- **Staging**: `life.doxa.pray.staging`

### 4. Application Group (for OneSignal)
Updated from `group.app.prayer.doxa.onesignal` to `group.life.doxa.pray.onesignal`
- Updated in: `ios/Runner/Runner.entitlements`
- Updated in: `ios/Runner/Info.plist`

### 5. Staging Scheme
Created `ios/Runner.xcodeproj/xcshareddata/xcschemes/staging.xcscheme`
- Uses `stagingDebug` for testing and launch
- Uses `stagingProfile` for profiling
- Uses `stagingRelease` for archiving

### 6. Firebase Configuration Setup
Created build phase to automatically copy the correct `GoogleService-Info.plist` based on flavor:
- Staging configurations → `ios/config/staging/GoogleService-Info.plist`
- Production configurations → `ios/config/production/GoogleService-Info.plist`

## What You Need to Do

### Required: Download Firebase Configuration Files

The app will **crash on launch** until you provide the Firebase configuration files.

#### For Production (`life.doxa.pray`):
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings → Your apps
4. Find or create the iOS app with bundle ID: `life.doxa.pray`
5. Download `GoogleService-Info.plist`
6. Place it at: `ios/config/production/GoogleService-Info.plist`

#### For Staging (`life.doxa.pray.staging`):
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings → Your apps
4. Find or create the iOS app with bundle ID: `life.doxa.pray.staging`
5. Download `GoogleService-Info.plist`
6. Place it at: `ios/config/staging/GoogleService-Info.plist`

### Required: Apple Developer Account Setup

You need to register the following in your Apple Developer account:

1. **App IDs**:
   - `life.doxa.pray` (production)
   - `life.doxa.pray.staging` (staging)

2. **App Group** (for both app IDs):
   - `group.life.doxa.pray.onesignal`

3. **Provisioning Profiles**:
   - Create provisioning profiles for both bundle identifiers
   - Or enable "Automatically manage signing" in Xcode

## How to Build

### Production:
```bash
# Debug
flutter run --flavor production

# Release
flutter build ios --flavor production --release
```

### Staging:
```bash
# Debug
flutter run --flavor staging

# Release
flutter build ios --flavor staging --release
```

Or in Xcode, select the "staging" scheme from the scheme selector.

## Directory Structure

```
ios/
├── config/
│   ├── production/
│   │   ├── GoogleService-Info.plist  ← YOU NEED TO ADD THIS
│   │   └── README.md
│   ├── staging/
│   │   ├── GoogleService-Info.plist  ← YOU NEED TO ADD THIS
│   │   └── README.md
│   └── .gitignore
├── Podfile (updated to iOS 15.0)
└── Runner.xcodeproj/ (staging configurations added)
```

## Notes

- The `GoogleService-Info.plist` files are **gitignored** (they contain sensitive keys)
- Both apps can be installed side-by-side on the same device (different bundle IDs)
- The staging app uses a different icon (AppIcon-staging)
- The staging app displays as "Doxa Staging"
