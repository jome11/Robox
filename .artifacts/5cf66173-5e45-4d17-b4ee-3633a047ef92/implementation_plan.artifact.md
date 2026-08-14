# Implementation Plan - Fix Gradle Download Failure

The previous attempt to upgrade Gradle to `8.14.0` failed because that specific version (or its distribution URL) was not found. I will roll back to a known stable and compatible version that satisfies the AGP `8.11.1` requirement while avoiding the "dropped support" warning if possible.

## User Review Required

> [!WARNING]
> The version `8.14.0` recommended by the Flutter warning appears to be unavailable or has a broken download link. I am switching to `8.11.1`, which is the minimum recommended for Android Gradle Plugin `8.11.1`.

## Proposed Changes

### [Component] Gradle Configuration

#### [MODIFY] [gradle-wrapper.properties](file:///C:/Users/PAVILION/Desktop/Robox/android/gradle/wrapper/gradle-wrapper.properties)
- Change `distributionUrl` from `gradle-8.14.0-all.zip` to `gradle-8.11.1-all.zip`.

## Verification Plan

### Automated Tests
- The user should run `flutter build apk` or `flutter run` again.
- If it still fails with a 404, we will try `8.10.2` (the original working version) and ignore the warning for now.

### Manual Verification
- Check if the download starts successfully.
