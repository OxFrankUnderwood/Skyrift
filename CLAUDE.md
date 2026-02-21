# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

Open `Skyrift.xcodeproj` in Xcode, or use the command line:

```bash
# Build (Debug)
xcodebuild -project Skyrift.xcodeproj -scheme Skyrift -configuration Debug build

# Build (Release)
xcodebuild -project Skyrift.xcodeproj -scheme Skyrift -configuration Release build

# Run tests (if added)
xcodebuild -project Skyrift.xcodeproj -scheme Skyrift -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Architecture

**Skyrift** is a SwiftUI application targeting iOS, macOS, and visionOS (all deployment targets: 26.2).

- **`SkyriftApp.swift`** — App entry point (`@main`), defines the `WindowGroup` scene
- **`ContentView.swift`** — Root view loaded by the app
- **`Assets.xcassets/`** — App icons (multi-platform) and accent color

There are currently no external dependencies — pure Apple frameworks only, no Swift Package Manager packages, CocoaPods, or Carthage.

## Project Details

- **Bundle ID:** `com.skyrift.Skyrift`
- **Team ID:** `53RP7GR7HR`
- **Code signing:** Automatic (development team)
- **Supported orientations:** Portrait + landscape on iPhone/iPad; spatial on visionOS
- **App Sandbox and Hardened Runtime** are both enabled

## Swift Configuration

- Swift concurrency fully enabled (`SWIFT_APPROACHABLE_CONCURRENCY`)
- `@MainActor` default isolation enabled
- Debug builds: `-Onone`, testability enabled
- Release builds: Whole-module optimization
