---
name: swift-package
description: >-
  Manage dependencies with Swift Package Manager (SPM) and migrate off CocoaPods.
  Use when adding/updating Apple-platform dependencies, structuring local packages, or
  removing a Podfile. CocoaPods enters maintenance mode and shuts down in Sep 2026 — SPM
  is the only supported dependency manager for this pack.
disable-model-invocation: true
---

# swift-package

Dependency management for native Apple apps using **Swift Package Manager only**.
No CocoaPods, no Carthage.

## Why SPM (and not CocoaPods)

- CocoaPods is in **maintenance mode** and the central trunk shuts down in **September 2026**.
- SPM is built into Xcode and `swift`, integrates with the build graph, supports binary
  targets, and needs no `.xcworkspace` indirection or `pod install` step.

## Adding dependencies

**In an Xcode app project** — add via *File ▸ Add Package Dependencies…* or edit the
project's package list. Pin versions with **Up to Next Major**:

```
https://github.com/owner/SomeLib.git  →  Up to Next Major Version: 1.0.0
```

**In a Swift package (`Package.swift`)**:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FeatureKit",
    platforms: [.iOS(.v18), .macOS(.v15), .watchOS(.v11), .visionOS(.v2)],
    products: [
        .library(name: "FeatureKit", targets: ["FeatureKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/owner/SomeLib.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(name: "FeatureKit", dependencies: ["SomeLib"]),
        .testTarget(name: "FeatureKitTests", dependencies: ["FeatureKit"])
    ]
)
```

## Local packages (recommended structure)

Split features into **local Swift packages** for fast builds, clear boundaries, and
testability. Reference them from the app target as local package dependencies:

```
MyApp/
├── MyApp.xcodeproj
├── App/                     # thin app target (entry point, composition root)
└── Packages/
    ├── FeatureHome/         # Package.swift + Sources + Tests
    ├── FeatureProfile/
    └── CoreNetworking/
```

## Common commands

```bash
# Resolve / update (package or project that vendors packages)
swift package resolve
swift package update                 # respects version rules in Package.swift
xcodebuild -resolvePackageDependencies -workspace MyApp.xcworkspace -scheme MyApp

# Build/test a standalone Swift package
swift build
swift test

# Inspect the dependency graph
swift package show-dependencies --format tree
```

Commit `Package.resolved` so CI builds are reproducible.

## Migrating off CocoaPods

When a `Podfile` exists (the `cocoapods-migration` optional feature), migrate, do not extend:

1. **Inventory** pods: `pod list` / read `Podfile`. For each pod, find its SPM URL (most
   popular pods ship `Package.swift`).
2. For each pod, add the **SPM** equivalent (project package list or `Package.swift`).
3. Remove CocoaPods integration:

```bash
pod deintegrate          # removes Pods/ build phases from the .xcodeproj
rm -rf Pods Podfile Podfile.lock
# If the workspace existed ONLY for CocoaPods, you can build the .xcodeproj directly.
# Keep .xcworkspace only if it groups multiple real projects/local packages.
```

4. Replace `#import <Pod/...>` / `import Pod` usages; fix any `use_frameworks!`-specific
   imports. Build and run tests.
5. Update `.gitignore` (drop `Pods/`), update CI to remove `pod install`, and update the
   `ios.packageManager` field in `pipeline.manifest.json` to `spm`.
6. If a pod has **no SPM support**, prefer an alternative library, vendor it as a binary
   `xcframework` target, or wrap it in a local package — document the decision in an ADR.

## Checkpoint

```powershell
swift package show-dependencies --format tree 2>&1 | pwsh .cursor/skills/checkpoint/scripts/save-artifact.ps1 `
  -Session <session> -ArtifactRel deps/spm-tree.txt -Mode --stdin
```

Cite the resolved dependency list and any migration decisions in chat; do not paste full
`Package.resolved`.

## Constraints

- Never reintroduce CocoaPods or Carthage.
- Pin with `.upToNextMajor`; commit `Package.resolved`.
- Keep platform floors aligned with the app's deployment target (iOS 18+).
